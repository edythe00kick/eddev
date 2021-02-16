/**
 * Edited by csalgado on 4/30/2019.
 */

/**
 * Builds the necessary request, and sends the necessary request to the Dell Boomi Cloud Server Listener
 *
 * @author Taylor Krause <tkrause@alteryx.com>
 * @version 1.0
 * @since 1.0
 */


public class DellBoomi {

    //** VARIABLES **
    public Map<Id, License_Product__c> newItems;
    //public Map<Id, License_Product_Update__c> newLPUItems;
    public Map<Id, String> licProd2Product = new Map<Id,String>();
    public List<License_Product__c> newItemsList;
    public String triggerEvent;


    //** METHODS **
    /**
     * Takes the current Asset Line Items being created from Trigger.NewMap and currentEvent - OnAfterInsert Constructor
     * @param newTriggerItems Being passed via Trigger.newMap in the MasterAssetLineItemTrigger
     * @param currentTriggerEvent Being passed via currentEvent in the MasterAssetLineItemTrigger
     */

    public DellBoomi(Map<Id, License_Product__c> newTriggerItems, String currentTriggerEvent) {
        System.debug('**CSALGADO**: In DellBoomi Constructor 1');
        newItems = newTriggerItems;
        triggerEvent = currentTriggerEvent;

        mapLicProdToProduct(newTriggerItems.values());
    }

    /**
     * Takes the current Asset Line Items being created from Trigger.New and currentEvent - OnBeforeInsert Constructor
     * @param newTriggerItemsList Being passed via Trigger.new in the MasterAssetLineItemTrigger
     * @param currentTriggerEvent Being passed via currentEvent in the MasterAssetLineItemTrigger
     */

    public DellBoomi(List<License_Product__c> newTriggerItemsList, String currentTriggerEvent) {
        System.debug('**CSALGADO**: In DellBoomi Constructor 2');
        newItemsList = newTriggerItemsList;
        triggerEvent = currentTriggerEvent;

        mapLicProdToProduct(newTriggerItemsList);
    }

    /**
     * Takes the current Asset Line Items being created from Trigger.New, Trigger.NewMap and currentEvent - OnBeforeUpdate Constructor
     * @param newTriggerItems Being passed via Trigger.newMap in the MasterAssetLineItemTrigger
     * @param newTriggerItemsList Being passed via Trigger.new in the MasterAssetLineItemTrigger
     * @param currentTriggerEvent Being passed via currentEvent in the MasterAssetLineItemTrigger
     */

    public DellBoomi(Map<Id, License_Product__c> newTriggerItems, List<License_Product__c> newTriggerItemsList, String currentTriggerEvent) {
        System.debug('**CSALGADO**: In DellBoomi Constructor 3');
        newItems = newTriggerItems;
        newItemsList = newTriggerItemsList;
        triggerEvent = currentTriggerEvent;

        mapLicProdToProduct(newTriggerItems.values());
    }

    /**
     * Builds JSON from Objects, and then calls the method to build and send a request to Boomi
     */

    public void sendToBoomi() {
        System.debug('**CSALGADO**: In DellBoomi sendToBoomi ');
        if (!System.isFuture()) {
            Set<ID> lineItemIds = new Set<ID>();
            for (License_Product__c newItem : newItems.values()) {
                System.debug('**CSALGADO**: Product' + licProd2Product.get(newItem.Id));
                String prodFamily = licProd2Product.get(newItem.Id);
                //if ((newItem.Product__r.Family == 'Alteryx Software' || newItem.Product__r.Family == 'Adoption') && newItem.X11_7__c == false) {
                // Eddie Wong || 09/23/2020 || W-006329 || To exclude SheerID LP in this process
                if ((prodFamily == 'Alteryx Software' || prodFamily == 'Adoption') && newItem.SheerID__c == false && newItem.X11_7__c == false && newItem.NoSendToDellBoomi__c == false) {
                    lineItemIds.add(newItem.Id);
                }
            }
            System.Debug('Inside sendToBoomi' + lineItemIds);
            if (lineItemIds.size() > 0) {
                buildRequest(lineItemIds);
            }
        }
    }

    // Eddie Wong
    // 09/23/2020
    // W-006329
    // To build HTTP call for SheerID License Product
    @future(callout=true)
    public static void sendSheerIDLPToBoomi(Set<Id> lProdIDSet) {
        System.debug('**Eddie**: In DellBoomi sendSheerIDLPToBoomi');

        List<License_Product__c> licProdList = [SELECT Id, Name,Start_Date__c,End_Date__c,Quantity__c,Product__r.ProductCode,
                Account__c,Account__r.Name,Account__r.Account_Owner_Email__c,License_Group__r.Name,Licensed_Owner__r.Email,
                Licensed_Owner__r.Phone,Licensed_Owner__r.FirstName,Licensed_Owner__r.LastName,
                Licensed_Owner__r.Preferred_Language__c,Licensed_Owner__r.SheerID_Verification_ID__c
                FROM License_Product__c
                WHERE Id IN : lProdIDSet];

        System.debug('eddie check licProdList = ' + licProdList);

        if(!licProdList.isEmpty()){
            for(License_Product__c licProd : licProdList){

                JSONGenerator generator2 = JSON.createGenerator(true);
                generator2.writeStartObject();
                generator2.writeFieldName('data');
                generator2.writeStartObject();
                generator2.writeStringField('type', 'sheerIdLP');
                generator2.writeStringField('licenseproductid', licProd.Id);
                generator2.writeStringField('licenseproductname', licProd.Name);
                generator2.writeDateField('startdate', licProd.Start_Date__c);
                generator2.writeDateField('enddate', licProd.End_Date__c);
                generator2.writeNumberField('quantity', licProd.Quantity__c);
                generator2.writeStringField('productcode', System.Label.SheerID_Product_Code);
                generator2.writeStringField('accountid', licProd.Account__c);
                generator2.writeStringField('accountname', licProd.Account__r.Name);
                generator2.writeStringField('accountowneremail', licProd.Account__r.Account_Owner_Email__c);
                generator2.writeStringField('ordergroupname', licProd.License_Group__r.Name);
                generator2.writeStringField('laphone', licProd.Licensed_Owner__r.Phone);
                generator2.writeStringField('lafirstname', licProd.Licensed_Owner__r.FirstName);
                generator2.writeStringField('lalastname', licProd.Licensed_Owner__r.LastName);
                generator2.writeStringField('lalanguage', licProd.Licensed_Owner__r.Preferred_Language__c);
                generator2.writeStringField('laemail', licProd.Licensed_Owner__r.Email);
                generator2.writeStringField('sheeridverificationid', licProd.Licensed_Owner__r.SheerID_Verification_ID__c);

                generator2.writeEndObject();
                generator2.writeEndObject();
                String jsonString = generator2.getAsString();
                System.debug('EWONG - Test SheerID LP JSON String = ' + jsonString);

                final String url = label.boomi_sheerid_login; //------------> What's the url? '
                Http boomiListener = new Http();
                HttpRequest requestListener = new HttpRequest();
                String findReturnStatus;

                requestListener.setEndpoint(url);
                requestListener.setMethod('POST');
                requestListener.setBody(jsonString);
                requestListener.setTimeout(120000);

                if (!Test.isRunningTest()) {
                    HttpResponse response = boomiListener.send(requestListener);
                    findReturnStatus = response.getStatus();

                    System.debug(findReturnStatus);
                }

            }
        }

    }


    // Eddie Wong
    // 06/25/200
    // W-004987
    // To build HTTP call for License Product Update
    /**
 * Builds JSON from Objects, and then calls the method to build and send a request to Boomi
 */

    @future(callout=true)
    public static void sendLPUToBoomi(Set<Id> licProUpSet, Set<Id> licProSet) {

        System.debug('eddie check RecursionHandler.IsLPUToBoomiExecuted = ' + RecursionHandler.IsLPUToBoomiExecuted);
        System.debug('**Eddie**: In DellBoomi sendLPUToBoomi ');

        List<License_Product_Update__c> licProdUpList = new List<License_Product_Update__c>([SELECT Id, Quote__r.Name,Name, Quote__c, Quote_Line__r.SBQQ__Quantity__c, Quote_Line__r.SBQQ__EffectiveQuantity__c, License_Product__r.Activation_Id__c,
                Dell_Boomi_In_Progress__c,Dell_Boomi_Received__c,Entitlement_ID__c,FNO_Received__c,Integration_Error__c,License_Product__c,Quote_Line__c,Send_Entitlement_Email__c,License_Product__r.Quote__c,License_Product__r.Quote__r.Name
        from License_Product_Update__c
        WHERE Id IN : licProUpSet]);

        /*Potential option to handle additional quote # for FNO
        List<License_Product_Update__c> licProdUpQuoteConcateList = new List<License_Product_Update__c>([SELECT Quote__r.Name FROM License_Product_Update__c WHERE License_Product__c IN : licProSet GROUP BY License_Product__c]);

        List<String> quoteConcat;

        if (!licProdUpQuoteConcateList.isEmpty()){
            for (License_Product_Update__c lic : licProdUpQuoteConcateList){
                quoteConcat.add(lic.Quote__r.Name + ';');
            }
        }

         */

        System.debug('eddie inside licProdUpList = ' + licProdUpList );

        if (!licProdUpList.isEmpty()) {
            for (License_Product_Update__c licProdUp : licProdUpList) { //Eddie Wong || 09/16/2020 || W-005994 || To resend License Product Updates to Boomi
                integer i = 0;

                JSONGenerator generator2 = JSON.createGenerator(true);
                generator2.writeStartObject();
                generator2.writeFieldName('data');
                generator2.writeStartObject();
                generator2.writeStringField('type', 'lpu');
                generator2.writeStringField('licenseproductid', licProdUp.Id);
                generator2.writeStringField('licenseproductname', licProdUp.Name);
                generator2.writeNumberField('Quantity', licProdUp.Quote_Line__r.SBQQ__Quantity__c);
                generator2.writeNumberField('EffectiveQuantity', licProdUp.Quote_Line__r.SBQQ__EffectiveQuantity__c);
                generator2.writeStringField('newquoteid', licProdUp.Quote__c);
                generator2.writeStringField('newquotename', licProdUp.Quote__r.Name);
                generator2.writeStringField('originalquoteid', licProdUp.License_Product__r.Quote__c);
                generator2.writeStringField('originalquotename', licProdUp.License_Product__r.Quote__r.Name);
                //generator2.writeStringField('quoteNameConcat',licProdUpList[0].Quote__r.Name );
                generator2.writeStringField('ActivationId', licProdUp.License_Product__r.Activation_Id__c);
                generator2.writeEndObject();
                generator2.writeEndObject();
                String jsonString = generator2.getAsString();
                System.debug('EWONG - Test LPU JSON String = ' + jsonString);

                final String url = label.boomi_lpu_login;
                Http boomiListener = new Http();
                HttpRequest requestListener = new HttpRequest();
                String findReturnStatus;

                requestListener.setEndpoint(url);
                requestListener.setMethod('POST');
                requestListener.setBody(jsonString);
                requestListener.setTimeout(120000);

                if (!Test.isRunningTest()) {
                    HttpResponse response = boomiListener.send(requestListener);
                    findReturnStatus = response.getStatus();

                    System.debug(findReturnStatus);
                }

            }

        }

    }

    /**
     * Builds the resend for boomi through JSON from Objects, and then calls the method to build and send a request to Boomi
     */

    public void resendToBoomi() {
        System.debug('**CSALGADO**: In DellBoomi resendToBoomi ');
        if (!System.isFuture()) {
            Set<ID> lineItemIds = new Set<ID>();
            for (License_Product__c newItem : newItems.values()) {
                System.debug('**CSALGADO**: Product' + licProd2Product.get(newItem.Id));
                String prodFamily = licProd2Product.get(newItem.Id);
                System.debug('**CSALGADO**: License Product - ' + newItem);
                System.debug('**CSALGADO**: License Product & Product - ' + newItem.Product__c);
                System.debug('**CSALGADO**: License Product & Product & Family - ' + newItem.Product__r.Family);
                //if ((newItem.Product__r.Family == 'Alteryx Software' || newItem.Product__r.Family == 'Adoption') && newItem.Resend_To_Boomi__c == true && newItem.Dell_Boomi_In_Progress__c == false & newItem.X11_7__c == false) {
                // Eddie Wong || 09/23/2020 || W-006329 || To exclude SheerID LP in this process
                if ((prodFamily == 'Alteryx Software' || prodFamily == 'Adoption') && newItem.Resend_To_Boomi__c == true && newItem.SheerID__c != true && newItem.Dell_Boomi_In_Progress__c == false & newItem.X11_7__c == false && newItem.NoSendToDellBoomi__c == false) {
                    lineItemIds.add(newItem.Id);
                }
            }
            if (lineItemIds.size() != 0) {
                System.Debug('Inside resendToBoomi' + lineItemIds);
                buildRequest(lineItemIds);
            }
        }
    }

    /**
     * Gurantees that we won't end up in a recursive loop, sending multiple requests from the same object at once
     */

    public void updateSyncInProgress() {
        System.debug('**CSALGADO**: In DellBoomi updateSynInProgress ');
        for (License_Product__c newItem : newItemsList) {
            System.debug('**CSALGADO**: Product' + licProd2Product.get(newItem.Id));
            String prodFamily = licProd2Product.get(newItem.Id);
            //if ((newItem.Product__r.Family == 'Alteryx Software' || newItem.Product__r.Family == 'Adoption') && triggerEvent == 'OnBeforeInsert' && newItem.X11_7__c == false) {
            if ((prodFamily == 'Alteryx Software' || prodFamily == 'Adoption') && triggerEvent == 'OnBeforeInsert' && newItem.X11_7__c == false && newItem.NoSendToDellBoomi__c == false) {
                newItem.Dell_Boomi_In_Progress__c = true;
            } //else if ((newItem.Product__r.Family == 'Alteryx Software' || newItem.Product__r.Family == 'Adoption') && triggerEvent == 'OnBeforeUpdate' && newItem.Resend_To_Boomi__c == true && newItem.X11_7__c == false) {
            // Eddie Wong || 09/23/2020 || W-006329 || To exclude SheerID LP in this process
            else if ((prodFamily == 'Alteryx Software' || prodFamily == 'Adoption') && triggerEvent == 'OnBeforeUpdate' && newItem.Resend_To_Boomi__c == true && newItem.SheerID__c != true && newItem.X11_7__c == false && newItem.NoSendToDellBoomi__c == false) {
                newItem.Dell_Boomi_In_Progress__c = true;
            } else {

            }
        }
    }

    /**
     * Builds the request to be send to boomi using Auth etc, sends to Boomi, updates the response
     * @param licProdsForCall This is the Asset Line Items that will be passed in for a request to be built and sent
     */

    @future(callout=true)
    private static void buildRequest(Set<ID> licProdsForCall) {
        System.debug('**CSALGADO**: In DellBoomi buildRequest ');
        List<License_Product__c> licProdsResponseUpdate = new List<License_Product__c>();
        List<License_Product__c> licProdsJson = [SELECT Id, Quote__c
        FROM License_Product__c
        WHERE Id IN :licProdsForCall]; // Eddie Wong || 09/23/2020 || W-006329 || To exclude SheerID LP in this process

        String jsonEntitlement = JSON.serialize(licProdsJson);
        final String url = label.boomi_login;
        Http boomiListener = new Http();
        HttpRequest requestListener = new HttpRequest();
        String findReturnStatus;

        requestListener.setEndpoint(url);
        requestListener.setMethod('POST');
        requestListener.setBody(jsonEntitlement);
        requestListener.setTimeout(120000);

        if (!Test.isRunningTest()) {
            HttpResponse response = boomiListener.send(requestListener);
            findReturnStatus = response.getStatus();

            System.Debug(findReturnStatus);
            System.Debug(jsonEntitlement);
        }
        for (ID lProd : licProdsForCall) {
            License_Product__c lProdToUpdate = new License_Product__c();
            lProdToUpdate.Id = lProd;
            lProdToUpdate.Dell_Boomi_Received__c = findReturnStatus;
            licProdsResponseUpdate.add(lProdToUpdate);
        }
        if (!licProdsResponseUpdate.isEmpty()) {
            update licProdsResponseUpdate;

            Integer lastItemInList = licProdsResponseUpdate.size() - 1;
            licProdsResponseUpdate[lastItemInList].Send_Entitlement_Email__c = true;
            update licProdsResponseUpdate;

            Database.DMLOptions assignOption = new Database.dmlOptions();
            assignOption.assignmentRuleHeader.useDefaultRule = true;

            
            SBQQ__Quote__c quoteAccepted = [
                    SELECT SBQQ__Type__c, Class_of_Business__c, Right_to_Install_on_Two_Machines__c, SBQQ__Account__c, SBQQ__PrimaryContact__c
                    FROM SBQQ__Quote__c
                    WHERE Id = :licProdsJson[0].Quote__c
                    LIMIT 1
            ];

            List<License_Product__c> licenseProduct = [
                    SELECT Id, Product__r.Name, Quote__c, Quote__r.Id, Account__c
                    FROM License_Product__c
                    WHERE Id
                            IN :licProdsForCall
            ];
            List<Id> connectPromote = new List<Id>();
            Set<Id> quoteQuery = new Set<Id>();
            for (License_Product__c licProduct : licenseProduct) {
                if (licProduct.Product__r.Name == 'Alteryx Connect' || licProduct.Product__r.Name == 'Alteryx Promote' || licProduct.Product__r.Name == 'Alteryx Connect Sandbox'/*SF 01/07/2020  W-013771*/) {
                    connectPromote.add(licProduct.Quote__c);
                    quoteQuery.add(licProduct.Quote__r.Id);
                }
            }
            
            //Query Quote for Case creation
            SBQQ__Quote__c caseQuote = new SBQQ__Quote__c();
            if(!quoteQuery.isEmpty()){            
                 caseQuote = [SELECT Id,SBQQ__Account__r.Id, License_Administrator__r.Contact__r.Id FROM SBQQ__Quote__c WHERE id IN :quoteQuery LIMIT 1];
            }

            List<Case> casesToInsert = new List<Case>();
                
            if (connectPromote.size() > 0) {
                Case licenseTypeCase = new Case();
                licenseTypeCase.setOptions(assignOption);
                licenseTypeCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Alteryx Fulfillment Case').getRecordTypeId();
                licenseTypeCase.Quote__c = connectPromote[0];
                licenseTypeCase.AccountId = !quoteQuery.isEmpty()? caseQuote.SBQQ__Account__r.Id : '';
                licenseTypeCase.ContactId = !quoteQuery.isEmpty()? caseQuote.License_Administrator__r.Contact__r.Id : '';
                licenseTypeCase.Category__c = 'License Type';
                licenseTypeCase.Origin = 'fulfillment@alteryx.com';
                licenseTypeCase.Status = 'Fulfillment response required';
                licenseTypeCase.Subject = 'Alteryx Promote or Alteryx Connect Fulfillment';
                casesToInsert.add(licenseTypeCase);
            }

            //Sergio Flores
            //Date: 08/20/2019
            //W-012661
            System.debug('inside dell boomi outside create right to install case ' + quoteAccepted.Right_to_Install_on_Two_Machines__c);
            if(quoteAccepted.Right_to_Install_on_Two_Machines__c)
            {
                Case licenseTypeCase = new Case();
                licenseTypeCase.setOptions(assignOption);
                licenseTypeCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Alteryx Fulfillment Case').getRecordTypeId();
                licenseTypeCase.Quote__c = quoteAccepted.Id;
                licenseTypeCase.AccountId = quoteAccepted.SBQQ__Account__c;
                licenseTypeCase.ContactId = quoteAccepted.SBQQ__PrimaryContact__c;
                licenseTypeCase.Category__c = 'License Type';
                licenseTypeCase.Origin = 'fulfillment@alteryx.com';
                licenseTypeCase.Status = 'Fulfillment response required';
                licenseTypeCase.Subject = 'Right to Install on Two Machines';
                casesToInsert.add(licenseTypeCase);
            }

            if(!casesToInsert.isEmpty())
            {
                insert casesToInsert;
            }
        }
    }

    private void mapLicProdToProduct(List<License_Product__c> newTriggerItemsList){
        System.debug('**CSALGADO**: In Map License Product to Product ');
        //Map the Product Family
        Set<id> licProdIds = new Set<id>();
        for(License_Product__c licProd : newTriggerItemsList){
            System.debug('**CSALGADO**: Product Id: ' + licProd.Product__c);
            licProdIds.add(licProd.Product__c);
        }

        if(!licProdIds.isEmpty()) {
            List<Product2> queryProducts = [
                    SELECT id, Family
                    FROM Product2
                    WHERE id IN :licProdIds];
            for(License_Product__c lPro : newTriggerItemsList){
                System.debug('**CSALGADO**: Product Id: ' + lPro.Product__c);
                for(Product2 pro : queryProducts) {
                    if (lPro.Product__c == pro.Id){
                        System.debug('**CSALGADO**: License Product Id: ' + lPro.Id);
                        System.debug('**CSALGADO**: Product Family: ' + pro.Family);
                        licProd2Product.put(lPro.Id, pro.Family);
                    }
                }
            }
        }
    }
}