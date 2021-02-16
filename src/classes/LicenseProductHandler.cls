//Author: Chris Salgado
//Date: 04/30/2019
//Description - License Product Handler

public class LicenseProductHandler{

    //** VARIABLES **
    private boolean myIsExecuting = false;
    private integer BatchSize = 0;
    public String currentEvent;
    public list<License_Product__c> LicenseProductsToGet;


    //** METHODS **
    public LicenseProductHandler(boolean isExecuting, integer size, List<License_Product__c> new_val){
        System.debug('**CSALGADO**: In Handler Constructor ');
        myIsExecuting = isExecuting;

        //Query the License Products that triggered this process
        LicenseProductsToGet = [Select Id,Product__r.Family,Quote__r.SBQQ__Account__c,Quote__c,Quote__r.License_Administrator__r.Contact__c, Product__r.ProductCode,
                Quote__r.SBQQ__Opportunity2__c ,Quote__r.SBQQ__PrimaryContact__c , Option__c,
                Quote__r.SBQQ__Opportunity2__r.Owner.Email, Quote__r.Name, Quote__r.Support_Entitlement__c,
                Quote__r.SBQQ__PrimaryContact__r.Owner.Email,Shipment_Required__c, Quote_Line__c, Resend_To_Boomi__c, X11_7__c,SheerID__c
        FROM License_Product__c
        Where Id in : new_val];

        BatchSize = size;
        currentEvent = 'constructor';
    }
    public void onBeforeInsert(List<License_Product__c> lstNew) {
        System.debug('**CSALGADO**: In Handler onBeforeInsert ');
        currentEvent = 'OnBeforeInsert';

        /* Updates Dell Boomi In Progress field */
        DellBoomi updateSyncItems = new DellBoomi(lstNew, currentEvent);
        updateSyncItems.UpdateSyncInProgress();

        for(License_Product__c lProducts : lstNew){
            system.debug('@@@ ' + lProducts.Quote__c);
        }

    }
    public void onBeforeUpdate(Map<id, License_Product__c> mapOld, Map<id, License_Product__c> mapNew, List<License_Product__c> lstNew) {
        System.debug('**CSALGADO**: In Handler onBeforeUpdate ');
        System.debug('**CSALGADO**: Test Query LP Product = ' + LicenseProductsToGet[0].Product__r.Family);
        currentEvent = 'OnBeforeUpdate';
        /*Set of License Products ID for SheerID W-006329 */
        Set<Id> lProdResendSet = new Set<Id>();

        //Name: Chris Salgado Date: 10/3/2019 Purpose: W-013317
        if(UtilityClass.resendToBoomiIsFirstRun == false)
        {
            UtilityClass.resendToBoomiIsFirstRun = true;
            /* Resend License Product to Dell Boomi for Flexera */
            //DellBoomi resendCall = new DellBoomi(mapNew, lstNew, currentEvent);
            DellBoomi resendCall = new DellBoomi(mapNew, lstNew, currentEvent);
            resendCall.resendToBoomi();
            resendCall.UpdateSyncInProgress();
        }
        /* If there is ever an error in the intergration sync, we update the proposal for alerting deal desk */
        List<SBQQ__Quote__c> quoteSyncErrorList = new List<SBQQ__Quote__c>();
        for(License_Product__c item : lstNew){
            if(!String.IsEmpty(item.Integration_Error__c) && item.SheerID__c == false){  // Eddie Wong || 09/23/2020 || W-006329 || TO exclude SheerID from this process
                SBQQ__Quote__c errorProp = new SBQQ__Quote__c();
                errorProp.Id = item.Quote__c;
                errorProp.FNO_Error__c = true;
                quoteSyncErrorList.add(errorProp);
            }
        }

        // Eddie Wong
        // 09/23/2020
        // W-006329
        // To resend SheerID's Lic Prod to Boomi when Resend To Boomi is checked
        for(License_Product__c licProd : lstNew){
            if(licProd.SheerID__c == true && licProd.Resend_To_Boomi__c == true && mapOld.get(licProd.Id).Resend_To_Boomi__c == false){
                licProd.Resend_To_Boomi__c = false;
                licProd.Integration_Error__c = null;
                licProd.Dell_Boomi_Received__c = null;
                licProd.Dell_Boomi_In_Progress__c = true;
                licProd.FNO_Received__c = false;
                lProdResendSet.add(licProd.Id);
            }
        }

        If(!lProdResendSet.isEmpty()){
            try {
                System.debug('inside lProdResendSet try = ' + lProdResendSet);
                DellBoomi.sendSheerIDLPToBoomi(lProdResendSet);
            } catch (Exception e) {
                system.debug('inside catch exception');
                trigger.new[0].addError(e.getMessage());
            }

        }


        //Update the Quote with any errors
        if(quoteSyncErrorList.size() != 0){
            update quoteSyncErrorList;
        }
    }
    public void onAfterInsert(Map<id, License_Product__c> mapNew){
        System.debug('**CSALGADO**: In Handler onAfterInsert ');
        currentEvent = 'OnAfterInsert';

        /*List of cases that is to be inserted for lProducts*/
        List<Case> Cases2Insert = new List<Case>();
        /*List of Ship to Contacts to be inserted for the lProducts*/
        List<Ship_to_Contacts__c> S2CToInsert = New List<Ship_to_Contacts__c>();
        /*Set of License Products ID for SheerID W-006329 */
        Set<Id> lProdIDSet = new Set<Id>();

        /* Send License Product to Dell Boomi for Flexera */
        DellBoomi sendCall = new DellBoomi(mapNew, currentEvent);
        sendCall.sendToBoomi();

        /* Iterate over the lProducts and check if the Shipments is required*/
        /*If yes, create a Case and a Ship to contact for the lProducts*/
        If(!LicenseProductsToGet.IsEmpty() && LicenseProductsToGet.size() > 0){
            string fulfillmentProductCodes = System.Label.Fulfillment_Product_Codes;
            Set<String> codesNotToSend = new Set<String>();

            for(String s : fulfillmentProductCodes.Split(',') )
            {
                codesNotToSend.add(s);
            }
            system.debug('codesNotToSend ' + codesNotToSend);
            For(License_Product__c lProduct : LicenseProductsToGet){
                system.debug('@@@@ License Product ' + lProduct);
                If(lProduct.Shipment_Required__c  && !codesNotToSend.contains(lProduct.Product__r.ProductCode) ){
                    Case cas = New Case();
                    cas.AccountId = lProduct.Quote__r.SBQQ__Account__c;
                    cas.License_Product__c = lProduct.Id;
                    cas.Opportunity_Owner_Email__c = lProduct.Quote__r.SBQQ__Opportunity2__r.Owner.Email;
                    cas.Opportunity__c = lProduct.Quote__r.SBQQ__Opportunity2__c;
                    cas.OwnerId = Label.FulfillmentOrdersCaseOwnerId;
                    cas.Quote__c = lProduct.Quote__c;
                    cas.Quote_Proposal_Primary_Contact__c = lProduct.Quote__r.SBQQ__PrimaryContact__c;
                    cas.Quote_Proposal_Primary_Contact_Email__c = lProduct.Quote__r.SBQQ__PrimaryContact__r.Owner.Email;
                    cas.Status = 'Submitted';
                    cas.Subject = 'Shipment Required - ' + lProduct.Quote__r.Name;
                    cas.RecordTypeId = case.sObjectType.getDescribe().getRecordTypeInfosByName().get('Fulfillment Orders').getRecordTypeId();
                    Cases2Insert.add(cas);

                    Ship_to_Contacts__c S2C = new Ship_to_Contacts__c();
                    S2C.License_Product__c = lProduct.Id;
                    S2C.Contact__c = lProduct.Quote__r.License_Administrator__r.Contact__c;
                    S2CToInsert.add(S2C);
                }

                // Eddie Wong
                // 09/23/2020
                // W-006329
                // If LP is for SheerID, make a specific HTTP call to Boomi to sync SheerID LP to Flexera
                If(lProduct.SheerId__c == true){
                    lProdIDSet.add(lProduct.Id);
                }
            }

            If(!lProdIDSet.isEmpty()){
                try {
                    System.debug('inside lProdIDToLProdMap try = ' + lProdIDSet);
                    DellBoomi.sendSheerIDLPToBoomi(lProdIDSet);
                } catch (Exception e) {
                    system.debug('inside catch exception');
                    trigger.new[0].addError(e.getMessage());
                }

            }

            If(Cases2Insert.size() > 0){
                Try{
                    Insert Cases2Insert;
                }
                Catch(exception ex){
                    List<License_Product__c> Error_Cases = (List<License_Product__c>) mapNew.values();
                    for(License_Product__c cas : Error_Cases){
                        Exception cause = ex.getCause();
                        String msg = cause != null ? cause.getMessage() : ex.getMessage();
                        cas.addError(msg);
                    }
                }
            }

            If(S2CToInsert.Size()>0){
                Try{
                    Insert S2CToInsert;
                }
                Catch(exception ex){
                    list<License_Product__c> Error_S2C = (List<License_Product__c>) mapNew.values();
                    for(License_Product__c sc : Error_S2C){
                        Exception cause = ex.getCause();
                        String msg = cause != null ? cause.getMessage() : ex.getMessage();
                        sc.addError(msg);
                    }
                }
            }

        }

        /*Sharma Nemani | W - 011397 | Case: 00268425
          *  Date: 03/26/2019
          *  Description: Find all Netsuites based on "Proposal_Line_Item_Lookup__c" mapping with Asset line item's
          * "Apttus_QPConfig__ProposalLineItemId__c", then update the NetSuite Sales Order's field Asset_Line_Item_Lookup__c
          */ //with the Id of the Asset Line Item.
        Map<Id, Id> qLineTolProductMap = new Map<Id, Id>();
        List<Netsuite_Sales_Order__c> nsoUpdateList = new List<Netsuite_Sales_Order__c>();
        If(!LicenseProductsToGet.IsEmpty() && LicenseProductsToGet.size() > 0){
            For(License_Product__c lProduct : LicenseProductsToGet){
                if(lProduct.Quote_Line__c!=null)
                    qLineTolProductMap.put(lProduct.Quote_Line__c, lProduct.Id);
            }
            if(qLineTolProductMap.size()>0){
                for(Netsuite_Sales_Order__c nso : [Select id, License_Product__c, Quote_Line__c from Netsuite_Sales_Order__c where Quote_Line__c IN: qLineTolProductMap.keyset()]){
                    if(qLineTolProductMap.containsKey(nso.Quote_Line__c)){
                        nso.License_Product__c = qLineTolProductMap.get(nso.Quote_Line__c);
                        nsoUpdateList.add(nso);
                    }
                }
                if(nsoUpdateList.size()>0)
                    update nsoUpdateList;
            }
        }
    }
}