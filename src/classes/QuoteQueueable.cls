/*
//Author: Chris Salgado
//Date: 4/17/2019
//Quote Queueable
//This queueable class was created to execute the creation of License Products at a later time so that it may be sent to Boomi in an @future call
//This removes the need for QuoteGateway.createLicenseProducts method
 */
public without sharing class QuoteQueueable implements Queueable {
    private Set<Id> quotes;
    private String createProcess;

    public QuoteQueueable(Set<Id> records, String createProcess) {
        this.quotes = records;
        this.createProcess = createProcess;
    }

    //**Commented for 11/7 Deployment **
    /* Added by: Sharma Nemani | W-013383 | Case: 00298094 --> START
     * Date: 11/05/2019
     * Description: To send email to Ethan Ekkens when an Adoption/Premium Support SKU is sold.
    */
    /*public static void sendEmail(SBQQ__Quote__c  quote1){
        
            SBQQ__Quote__c Quote = [
                SELECT Id,SBQQ__Opportunity2__c, SBQQ__ExpirationDate__c , SBQQ__SalesRep__c , Approval_Stage__c ,SBQQ__Opportunity2__r.StageName, SBQQ__PrimaryContact__c, NetSuite_Sales_Order_Number__c,
                SBQQ__MasterContract__c, RecordTypeId, currencyISOcode,
                SBQQ__Account__c, SBQQ__Status__c, Related_Contract__c, Rerun_NSSO_Creation__c,
                Support_Entitlement__c, RecordType.Name, Order_Group__c, Quote_Type__c,
                SBQQ__Partner__r.Name, Partner_Contact__r.Name, Partner_Contact__r.FirstName,
                Partner_Contact__r.LastName, Partner_Contact__r.Email, SBQQ__StartDate__c,
                SBQQ__EndDate__c, CustomEndDate__c, Class_of_Business__c, (
                    SELECT ID, Name,currencyISOcode, API__c, ServerOS__c,
                    SBQQ__Quote__c,
                    SBQQ__ProductFamily__c,
                    SBQQ__ProductCode__c,
                    SBQQ__Product__c,
                    SBQQ__Product__r.NS_Integration_Logic__c,
                    SBQQ__Product__r.Licensing_System__c, 
                    SBQQ__Product__r.Logical_Bundle__c,
                    SBQQ__ProductName__c,
                    SBQQ__ProductOption__r.SBQQ__OptionalSKU__c,
                    SBQQ__ProductOption__r.SBQQ__OptionalSKU__r.Id,
                    SBQQ__StartDate__c,
                    SBQQ__EndDate__c,
                    SBQQ__EffectiveStartDate__c,
                    SBQQ__EffectiveEndDate__c,
                    SBQQ__EffectiveQuantity__c,                             
                    SBQQ__Number__c,
                    SBQQ__OptionLevel__c,
                    CustomEndDate__c,
                    Shipping_Required__c,
                    Logical_Bundle__c,
                    Bundle_Header__c
                    FROM SBQQ__LineItems__r
                )
                FROM SBQQ__Quote__c
                WHERE Id =:quote1.Id
                limit 1
            ];
        	
        	Boolean sendEmail = false;   
        	system.debug('sent :: '+'Sent');
            for (SBQQ__QuoteLine__c qLine : Quote.SBQQ__LineItems__r){
                
                // Added by: Sharma Nemani | W-013383 | Case: 00298094 | Date: 11/05/2019 --> START
                If(qLine.SBQQ__ProductName__c == 'Alteryx Premium Support' || qLine.SBQQ__ProductFamily__c == 'Adoption'){
                    sendEmail = true;
                }
            }
        system.debug('1stCond@@ :: '+sendEmail);
        	// Added by: Sharma Nemani | W-013383 | Case: 00298094 | Date: 11/05/2019 --> START
            if(sendEmail && Quote.SBQQ__Status__c  == 'Accepted' && Quote.SBQQ__Opportunity2__r.StageName == '5 - Closed Won'){
                // Approval_Stage__c
                sendEmail = true;
            }else{
                sendEmail = false;
            }
        	system.debug('2ndCond@@ :: '+sendEmail);
            if(!sendEmail){
                return;
            }
        
        	user usr = [select name,id,Email from user where name = 'Sharma Nemani'];
        
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        	mail.setToAddresses(new String[]{usr.Email});
            mail.setSubject('An Adoption/Premium Support SKU has been sold!');
        	String Body = 'Hi Ethan Ekkens'; 
        	Body+='<br></br>'; 
        	
        	Body+='Sales Rep :: '+ quote.SBQQ__SalesRep__c+'<br></br>';
            Body+='Customer Company Name :: '+ quote.SBQQ__Account__c+'<br></br>';
        	Body+='Expires On :: '+ quote.SBQQ__ExpirationDate__c+'<br></br>';
        	
            Body+='<a target="_blank" href="/'+quote.SBQQ__Opportunity2__c+'">Go to opportunity : </a>';
        	
            mail.setHTMLBody(Body); 
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);  
        	
        	Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {mail};
			Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        if(results[0].isSuccess()){
            system.debug('sent :: '+'Sent');
        }else{
            system.debug('getErrors :: '+results[0].getErrors()[0].getMessage());
        }
        
    }*/
    // Sharma Nemani | W-013383 | Case: 00298094 | Date: 11/05/2019 --> END


    public void execute(QueueableContext context)
    {
        System.debug('**CSALGADO**: In QuoteQueueable execute method');
        if (quotes.isEmpty())
        {
            return;
        }

        //ONLY 1 Quote can be processed at a time due to a limit on Dell Boomi or Flexera
        SBQQ__Quote__c Quote = [
                SELECT Id,SBQQ__Opportunity2__c, SBQQ__SalesRep__c , Approval_Stage__c ,SBQQ__Opportunity2__r.StageName, SBQQ__PrimaryContact__c, NetSuite_Sales_Order_Number__c,
                        SBQQ__MasterContract__c, RecordTypeId, currencyISOcode,
                        SBQQ__Account__c, SBQQ__Status__c, Related_Contract__c, Rerun_NSSO_Creation__c,
                        Support_Entitlement__c, RecordType.Name, Order_Group__c, Quote_Type__c,
                        SBQQ__Partner__r.Name, Partner_Contact__r.Name, Partner_Contact__r.FirstName,
                        Partner_Contact__r.LastName, Partner_Contact__r.Email, SBQQ__StartDate__c,
                        SBQQ__EndDate__c, CustomEndDate__c, Class_of_Business__c, (
                        SELECT ID, Name,currencyISOcode, API__c, ServerOS__c,
                                SBQQ__Quote__c,
                                SBQQ__ProductFamily__c,
                                SBQQ__ProductCode__c,
                                SBQQ__Product__c,
                                SBQQ__Product__r.NS_Integration_Logic__c,
                                SBQQ__Product__r.Licensing_System__c,
                                SBQQ__Product__r.Logical_Bundle__c,
                                SBQQ__ProductName__c,
                                SBQQ__ProductOption__r.SBQQ__OptionalSKU__c,
                                SBQQ__ProductOption__r.SBQQ__OptionalSKU__r.Id,
                                SBQQ__StartDate__c,
                                SBQQ__EndDate__c,
                                SBQQ__EffectiveStartDate__c,
                                SBQQ__EffectiveEndDate__c,
                                SBQQ__EffectiveQuantity__c,
                                SBQQ__Number__c,
                                SBQQ__OptionLevel__c,
                                CustomEndDate__c,
                                Shipping_Required__c,
                                Logical_Bundle__c,
                                Bundle_Header__c,
                                SBQQ__Quantity__c,              //Eddie Wong || 06/22/2020 || W-005163 || Flexera LP Update
                                License_Product__c,             //Eddie Wong || 2/4/2020 || W-007155 || Updating reference from upgraded subscription to license product
                                License_Product__r.Quantity__c  //Eddie Wong || 2/4/2020 || W-007155 || Updating reference from upgraded subscription to license product
//                                SBQQ__PriorQuantity__c,         //Eddie Wong || 06/22/2020 || W-005163 || Flexera LP Update
//                                SBQQ__UpgradedSubscription__c,  //Eddie Wong || 06/22/2020 || W-005163 || Flexera LP Update
//                                SBQQ__UpgradedSubscription__r.SBQQ__OriginalQuoteLine__c,  //Eddie Wong || 06/22/2020 || W-005163 || Flexera LP Update
//                                SBQQ__UpgradedSubscription__r.License_Product__c, //Eddie Wong || 06/22/2020 || W-005163 || Flexera LP Update
//                                SBQQ__UpgradedSubscription__r.License_Product__r.Quantity__c  //Eddie Wong || 06/22/2020 || W-005163 || Flexera LP Update
                        FROM SBQQ__LineItems__r
                )
                FROM SBQQ__Quote__c
                WHERE Id IN :quotes
                limit 1
        ];

        System.debug('**CSALGADO**: Past Quote Query: ' + Quote);


        //Needed to query for License Product ID's after Insert
        Set<Id> quoteLinesToQueryforLP = new Set<id>();

        //Eddie Wong || 06/22/2020 || W-005163 || Needed to query for LP ID for original quote line
        //Set<Id> originalQuoteLinesToQueryForLP = new Set<Id>();
        Map<Id,Id> quoteToOriginalLPMap = new Map<Id, Id>();

        //Map Quote to list of Quote Line Items
        Map<Id, List<SBQQ__QuoteLine__c>> QuoteID2QuoteLineItems = new Map<Id, List<SBQQ__QuoteLine__c >>();
        QuoteID2QuoteLineItems.put(Quote.Id, Quote.SBQQ__LineItems__r);

        // Name: Chris Salgado Date: 7/8/19 Purpose: Exclude License Product Creation from Rerun_NSSO_Creation__c
        if(createProcess == 'Standard' || createProcess == 'Rerun LP')
        {

            //Name: Chris Salgado
            //Date: 6/11/19
            //Work: W-012177
            //Purpose: Quote Type replaced Quote Record Type

            //Quote Type Name
            String QuoteTypeName = Quote.Quote_Type__c;

            //Products that don't require a License Product unless they are an Option in a Bundle
            String Special_Product = Label.Special_Products;

            //Create a Set of Quote Types that require a specific License Product Record Type
            Set<String> recordTypeIds = new Set<String>();
            String recordLabel = Label.AFG_NFR_Record_type_Ids;
            for (String s : recordLabel.split(';')) {
                recordTypeIds.add(s);
            }

            //Map License Product Record Types to Name
            Schema.DescribeSObjectResult LP_obj = License_Product__c.sObjectType.getDescribe();
            Map<String, Schema.RecordTypeInfo> rtMapByName = LP_obj.getRecordTypeInfosByName();

            //Delete existing License Products
            List<License_Product__c> deleteLicProduct = [Select ID
            FROM License_Product__c
            WHERE Quote__c = :Quote.Id];

            If (!deleteLicProduct.IsEmpty()) {
                if (!Test.IsRunningTest())
                    delete deleteLicProduct;
            }

            //Declare variables needed for License Product creation
            boolean insert_lProds = false;
            List<License_Product__c> insertLicProduct = new List<License_Product__c>();
            List<License_Product_Update__c> insertLicProductUpdate = new List<License_Product_Update__c>(); //Eddie Wong || 06/22/2020 || W-005163 || Flexera LP Update
            List<License_Product__c> updateLicenseProduct = new List<License_Product__c>(); //Eddie Wong || 06/22/2020 || W-005163 || Flexera LP Update

            //Eddie Wong || 06/22/2020 || W-005163 || Flexera LP Update
            Map<Id, Decimal> qLineToQuantity = new Map<Id, Decimal>();
            Map<Id, String> qLineToLPMap = new Map<Id, String>();
            Map<Id, SBQQ__QuoteLine__c> qLineIdToQLine = new Map<Id, SBQQ__QuoteLine__c>();

            // -- Create License Product records from Quote Lines --
            //**Commented for 11/7 Deployment **
            //Boolean sendEmail = false;
            for (SBQQ__QuoteLine__c qLine : QuoteID2QuoteLineItems.get(Quote.ID))
            {

                //Eddie Wong || 06/22/2020 || W-005163 || Flexera LP Update
                qLineToLPMap.put(qLine.Id, qLine.License_Product__c); //Eddie Wong || 2/4/2020 || W-007155 || Updating reference from upgraded subscription to license product
                qLineToQuantity.put(qLine.Id, qLine.SBQQ__Quantity__c);
                qLineIdToQLine.put(qLine.Id, qLine);

                System.debug('Eddie inside QuoteID2QuoteLineItems for loop' + qLineToLPMap);

                // Sharma Nemani | W-013383 | Case: 00298094 | Date: 11/05/2019  --> END

                String Product_Family = qLine.SBQQ__ProductFamily__c == null ? '' : qLine.SBQQ__ProductFamily__c.toLowerCase().trim();
                System.debug('**CSALGADO**:Product Family: ' + Product_Family);
                String Product_code = qLine.SBQQ__ProductCode__c != null ? qLine.SBQQ__ProductCode__c : '';
                System.debug('**CSALGADO**:Product Code: ' + Product_code);
                String Option = qLine.SBQQ__ProductOption__r.SBQQ__OptionalSKU__r.id;
                System.debug('**CSALGADO**:Option: ' + Option);
                boolean shipment = (!String.isBlank(qLine.Shipping_Required__c) &&  ((String.ValueOf(qLine.Shipping_Required__c)).trim().toLowerCase() == 'yes')) ? true : false;
                System.debug('**CSALGADO**:Shipment: ' + shipment);
                System.debug('inside license product creation loop ' + qLine + ' ' + Special_Product);

                //Name: Chris Salgado
                //Date: 6/4/19
                //Work: W-12139
                //Purpose: Replacing the Product Family criteria for a Licensing System picklist field
                //Name: Chris Salgado Date: 10/22/19 Purpose: W-013442 Fix Adoption LP Dates

                // Eddie Wong
                // 06/22/2020
                // W-005163
                // Flexera LP Update
                //Eddie Wong || 2/4/2020 || W-007155 || Updating reference from upgraded subscription to license product
                if (qLine.SBQQ__Quantity__c != null && qLine.License_Product__c == null) {

                    if (  qLine.SBQQ__EffectiveQuantity__c > 0 && qLine.SBQQ__Product__r.Licensing_System__c == 'Flexera' && !qLine.SBQQ__Product__r.Logical_Bundle__c
                            && ((!Special_Product.contains(Product_code)) || (Special_Product.contains(Product_code) && !String.IsBlank(Option))))
                    {

                        System.debug('**CSALGADO**: In License Product Create: ' + qline);

                        License_Product__c lProduct = new License_Product__c();
                        lProduct.Name__c = qLine.SBQQ__ProductName__c;
                        lProduct.CurrencyIsoCode = qLine.CurrencyIsoCode;
                        lProduct.Quote__c = qLine.SBQQ__Quote__c;
                        lProduct.Licensed_Owner__c = Quote.SBQQ__PrimaryContact__c;
                        lProduct.Product__c = qLine.SBQQ__Product__c;
                        lProduct.Option__c = qLine.SBQQ__ProductOption__r.SBQQ__OptionalSKU__c;
                        lProduct.Start_Date__c = qLine.SBQQ__EffectiveStartDate__c != null ? qLine.SBQQ__EffectiveStartDate__c : Quote.SBQQ__StartDate__c;
                        lProduct.End_Date__c = qLine.CustomEndDate__c != null ? qLine.CustomEndDate__c : Quote.CustomEndDate__c;
                        lProduct.Quantity__c = qLine.SBQQ__EffectiveQuantity__c;
                        lProduct.Account__c = Quote.SBQQ__Account__c;
                        lProduct.Quote_Line__c = qLine.Id;
                        lProduct.Shipment_Required__c = shipment;
                        lProduct.License_Group__c = Quote.Order_Group__c;
                        lProduct.API__c = qLine.API__c;
                        lProduct.ServerOS__c = qLine.ServerOS__c;
                        lProduct.Bundle_Header__c = qLine.Bundle_Header__c;
                        lProduct.Partner_Account_Name__c = Quote.SBQQ__Partner__r.Name;
                        lProduct.Partner_Contact_Name__c = Quote.Partner_Contact__r.Name;
                        lProduct.Partner_Contact_Email__c = Quote.Partner_Contact__r.Email;
                        lProduct.Contract__c = Quote.Related_Contract__c != null ? Quote.Related_Contract__c : null;

                        //Support Entitlement
                        If (Quote.Support_Entitlement__c != null)
                        {
                            lProduct.Entitlement_ID__c = Quote.Support_Entitlement__c;
                        }

                        System.debug('**CSALGADO**: Quote Type Check: ' + QuoteTypeName);

                        //Decide License Product Record Type
                        If (//Quote.SBQQ__Status__c == 'Accepted' &&
                                //Csalgado removed record type
                                //!recordTypeIds.contains(QuoteTypeName) &&
                                QuoteTypeName == 'Purchase')
                        {
                            lProduct.RecordTypeId = rtMapByName.get('Purchased License Product').getRecordTypeId();
                            insert_lProds = true;
                            //insertLicProduct.add(lProduct);

                            //system.debug('@@@@ lProds  ' + Quote.Related_Contract__c);

                            //else If (recordTypeIds.contains(QuoteTypeName)) {
                            //system.debug('@@@   This is it --> ' + recordTypeIds + '      '  + Quote.RecordTypeId);
                        }

                        else If (QuoteTypeName == 'NFR')
                        {
                            lProduct.RecordTypeId = rtMapByName.get('NFR License Product').getRecordTypeId();
                            insert_lProds = true;
                        } else If (QuoteTypeName == 'Evaluation')
                        {
                            lProduct.RecordTypeId = rtMapByName.get('Eval License Product').getRecordTypeId();
                            insert_lProds = true;
                        }
                        else If (QuoteTypeName == 'AFG')
                        {
                            lProduct.RecordTypeId = rtMapByName.get('AFG License Product').getRecordTypeId();
                            insert_lProds = true;
                        }

                        If (insert_lProds)
                        {
                            System.debug('**CSALGADO**: Insert Line Products ');
                            insertLicProduct.add(lProduct);
                        }
                    }
                }

                //Eddie Wong || 06/22/2020 || W-005163 || Flexera LP Update
                //Eddie Wong || 2/4/2020 || W-007155 || Updating reference from upgraded subscription to license product
                if (qLine.License_Product__c != null) {
                    quoteToOriginalLPMap.put(qLine.Id, qLine.License_Product__c);
                }
                //Needed to map LP name
                quoteLinesToQueryforLP.add(qLine.Id);
            }


            //Eddie Wong || 06/22/2020 || W-005163 || To map original License Product, quote line Id, and quote Id to LOU
            if (!quoteToOriginalLPMap.isEmpty() && quoteToOriginalLPMap != null) {
                for (SBQQ__QuoteLine__c qLine : [Select Id,SBQQ__Quote__c From SBQQ__QuoteLine__c WHERE Id IN : quoteToOriginalLPMap.KeySet()]){

                    License_Product_Update__c lProductUpdate = new License_Product_Update__c();
                    lProductUpdate.License_Product__c = quoteToOriginalLPMap.get(qLine.Id);
                    lProductUpdate.Quote_Line__c = qLine.Id; //links to the new quoteline
                    lProductUpdate.Quote__c = qLine.SBQQ__Quote__c; //links to the new quote
                    insertLicProductUpdate.add(lProductUpdate);
                }
            }


            //Eddie Wong || 06/22/2020 || W-005163 ||To update LP's quantity with the latest quantity from quoteline
            //Eddie Wong || 2/4/2020 || W-007155 || Updating reference from upgraded subscription to license product
            if (qLineIdToQLine != null && !qLineIdToQLine.isEmpty()) {
                for (SBQQ__QuoteLine__c qLine : qLineIdToQLine.values()) {
                    if (qLineIdToQLine.get(qLine.Id).SBQQ__Quantity__c != qLineIdToQLine.get(qLine.Id).License_Product__r.Quantity__c && qLineIdToQLine.get(qLine.Id).License_Product__c != null) {

                        System.debug('Eddie inside LP Update'+ qLineIdToQLine.get(qLine.Id).License_Product__c);

                        License_Product__c lProd = new License_Product__c();
                        lProd.Id = qLineIdToQLine.get(qLine.Id).License_Product__c;
                        lProd.Quantity__c = qLineIdToQLine.get(qLine.Id).SBQQ__Quantity__c;
                        updateLicenseProduct.add(lProd);  //LP that needs to update quantity
                    }
                }
            }

            //Eddie Wong || 06/22/2020 || W-005163 || Insert LPU record
            if (insertLicProductUpdate != null && !insertLicProductUpdate.isEmpty()){
                insert insertLicProductUpdate;
            }

            //Eddie Wong || 06/22/2020 || W-005163 || Update LP record
            if (updateLicenseProduct != null & !updateLicenseProduct.isEmpty()){
                update updateLicenseProduct;
            }

            // Added by: Sharma Nemani | W-013383 | Case: 00298094 | Date: 11/05/2019 --> END

            //Name: Chris Salgado Date: 1/8/20 Purpose: W-013840
            //try {

            If (insert_lProds && !insertLicProduct.isEmpty()) {
                insert insertLicProduct;
            }

            /*} catch (Exception ex) {
                system.debug('inside catch exception');
                //Name: Chris Salgado Date: 1/8/20 Purpose: W-013840
                //trigger.new[0].addError(ex.getMessage());
            }*/
        }
        else
        {
            for (SBQQ__QuoteLine__c qLine : QuoteID2QuoteLineItems.get(Quote.ID))
            {
                quoteLinesToQueryforLP.add(qLine.Id);
            }
        }

        /**
        * Sharma Nemani | W - 011397 | Case: 00268425
        * Date: 03/28/2019
        * Removed the code from "ProposalGateway" Class that creates NetSuite Sales Orders and placed it in here so that the NetSuite Sales Orders and AssetLine Items are
        created from this Class.
        * Builds Netsuite Sales Orders for syncing to Netsuite
        * @param triggerNewList looking at the current values of Trigger.new
        */

        if(createProcess == 'Standard' || createProcess == 'Rerun NSSO')
        {
            //Query for Quotes
            List<SBQQ__Quote__c> pr = [
                    SELECT Id, SBQQ__Status__c, Proposal_Accepted_Date__c, StubPeriod__c
                    from SBQQ__Quote__c
                    where Id IN:quotes
            ];

            system.debug('Quote for ns order creation' + pr);

            //Delete existing netsuite sales orders
            List<Netsuite_Sales_Order__c> existingNetSuiteOrdersList = new List<Netsuite_Sales_Order__c>();

            existingNetSuiteOrdersList = [
                    Select ID
                    FROM Netsuite_Sales_Order__c
                    WHERE Quote__c IN :quotes
            ];

            system.debug('existingNetSuiteOrdersList ' + existingNetSuiteOrdersList);

            if (!existingNetSuiteOrdersList.isEmpty()) {
                delete existingNetSuiteOrdersList;
            }


            List<Netsuite_Sales_Order__c> salesOrderFinal = new List<Netsuite_Sales_Order__c>();

            if (quotes.size() > 0) {
                List<SBQQ__QuoteLine__c> nsOrderItems = [
                        SELECT Id, SBQQ__Description__c, SBQQ__Product__r.NetSuite_Id__c, SBQQ__NetTotal__c, SBQQ__NetPrice__c, SBQQ__ProductFamily__c, SBQQ__Quote__c, SBQQ__ProductOption__c, SBQQ__UnproratedNetPrice__c,
                                SBQQ__StartDate__c, SBQQ__EndDate__c, SBQQ__ProductOption__r.SBQQ__OptionalSKU__c, CurrencyIsoCode, Recurring_Rev_Product__c, Has_Options__c, SBQQ__ProductOption__r.SBQQ__OptionalSKU__r.NetSuite_Id__c, SBQQ__ProductOption__r.Name,
                                SBQQ__ProductOption__r.SBQQ__OptionalSKU__r.Name, SBQQ__ProductName__c, Line_Number__c, Sequence__c, SBQQ__Product__r.NS_Integration_Logic__c, SBQQ__Quote__r.SBQQ__BillingFrequency__c,
                                SBQQ__ProrateMultiplier__c, OSCPQ_Net_MRR__c, OSCPQ_Net_ARR__c, SBQQ__EffectiveStartDate__c, CustomEndDate__c, SBQQ__EffectiveQuantity__c, Logical_Bundle__c, Bundle_Header__c, Adoption__c, NS_Integration_Logic__c
                        FROM SBQQ__QuoteLine__c
                        WHERE SBQQ__Quote__c IN :quotes
                ];

                //System.debug('**CSALGADO**: Past Quote Line Query: ' + nsOrderItems[0]);

                List<Quote_Subscription_Schedule__c> currentSchedule = [
                        SELECT Id, Quote__c, Subscription_Start_Date__c, Subscription_End_Date__c, Year__c, Includes_Partial_Period__c, Net_Total__c,
                        (
                                SELECT  Quote_Line__r.Id, Start_Date__c, End_Date__c, Net_Total__c, Prorate_Multiplier_Portion__c
                                FROM Line_Item_Subscription_Schedules__r
                        )
                        FROM Quote_Subscription_Schedule__c
                        WHERE Quote__c IN :quotes
                        ORDER BY Subscription_Start_Date__c ASC
                ]; //Name: Chris Salgado Date: 10/9/2019 Purpose: W-012929

                //System.debug('**CSALGADO**: Past Billing Schedule Query: ' + currentSchedule[0]);

                //Map of Quote Line to Line Item Subscription Schedule
                Map<String, Line_Item_Subscription_Schedule__c> qlToLISubSchedMap = new Map<String, Line_Item_Subscription_Schedule__c>();
                for(Quote_Subscription_Schedule__c cs: currentSchedule) {
                    for (Line_Item_Subscription_Schedule__c liss : cs.Line_Item_Subscription_Schedules__r) {
                        String subSchedKey = String.valueOf(cs.Id) + String.valueOf(liss.Quote_Line__r.Id);
                        qlToLISubSchedMap.put(subSchedKey, liss);
                    }
                }

                //Bundle List
                List<SBQQ__QuoteLine__c> bundleList = new List<SBQQ__QuoteLine__c>();

                //OptionsList
                List<SBQQ__QuoteLine__c> optionList = new List<SBQQ__QuoteLine__c>();

                /*EI - @W-011119 - 2019-02-14
                * Enhanced logic for Bundles Revenue Recognition.
                * Removed "Apttus_QPConfig__OptionId__c = null" from condition for Adoption and Software lists.
                * Updates Line_Type__c and replaces the primary PLI's product with Apttus_QPConfig__OptionId__r info if line type is Option.
                */

                //License Product Query + Map
                Map<Id ,String> quoteLineToLicProductName = new Map<Id ,String>();

                for(License_Product__c lp : [SELECT Id, Name, Quote_Line__r.Id FROM License_Product__c WHERE Quote_Line__c IN :quoteLinesToQueryforLP])
                {
                    quoteLineToLicProductName.put(lp.Quote_Line__r.Id,lp.Name);
                }


                //-- NON SOFTWARE NetSuite Sales Orders
                for (SBQQ__QuoteLine__c eachItem : nsOrderItems)
                {
                    if (eachItem.SBQQ__EffectiveQuantity__c > 0 && !eachITem.Recurring_Rev_Product__c && (eachItem.SBQQ__ProductOption__c == null || (eachItem.SBQQ__ProductOption__c != null && eachItem.Logical_Bundle__c))
                            && (eachItem.SBQQ__ProductFamily__c == 'Events' || eachItem.SBQQ__ProductFamily__c == 'Professional Services' || eachItem.SBQQ__ProductFamily__c == 'Customer Support')) {

                        System.debug('**CSALGADO**: In NONSOFTWARE Netsuite Sales Order Create');
                        //-- NetSuite Sales Order Created
                        Netsuite_Sales_Order__c nonSoftware = createNetsuiteSalesOrder(Quote, eachItem, quoteLineToLicProductName);

                        //Find the QSS for the NONSOFTWARE Product
                        for (Quote_Subscription_Schedule__c sched : currentSchedule) {
                            //Key for Net Price Map
                            String subSchedKey = String.valueOf(sched.Id) + String.valueOf(eachItem.Id);
                            if(qlToLISubSchedMap.containsKey(subSchedKey)){
                                nonSoftware.Contract_Start_Date__c = qlToLISubSchedMap.get(subSchedKey).Start_Date__c;
                                nonSoftware.Contract_End_Date__c = qlToLISubSchedMap.get(subSchedKey).End_Date__c;
                                nonSoftware.Line_Item_Start_Date__c = qlToLISubSchedMap.get(subSchedKey).Start_Date__c;
                                nonSoftware.Line_Item_End_Date__c = qlToLISubSchedMap.get(subSchedKey).End_Date__c;
                                nonSoftware.Net_Price__c = qlToLISubSchedMap.get(subSchedKey).Net_Total__c;
                                nonSoftware.Unit_Net_Price__c = qlToLISubSchedMap.get(subSchedKey).Net_Total__c / eachitem.SBQQ__EffectiveQuantity__c;
                            }
                        }

                        //-- Add nonSoftware to Sales Order Final if Quote Line has NO Production Options and is NOT an Option
                        //   OR is a Product Option in a Logical Bundle
                        if ((eachItem.Has_Options__c != True && eachItem.SBQQ__ProductOption__c == null)
                                || (eachItem.Logical_Bundle__c && eachItem.SBQQ__ProductOption__c != null )){
                            nonsoftware.Line_Type__c = 'Standard';
                            salesOrderFinal.add(nonSoftware);
                        }

                    } else if (eachItem.SBQQ__EffectiveQuantity__c > 0 && !eachItem.Adoption__c && !eachItem.Logical_Bundle__c
                            && (eachItem.Recurring_Rev_Product__c || (!eachItem.Recurring_Rev_Product__c && eachItem.SBQQ__ProductOption__c != null))) {
                        System.debug('**CSALGADO**: Product Option -> Optional SKU NOT null: ' + eachItem.SBQQ__ProductOption__r.SBQQ__OptionalSKU__c != null);
                        //-- Bundle List add recurring Quote Lines that are Optional
                        //Name: Chris Salgado Date: 5/6/20 Purpose: W-005339
                        if (eachItem.Has_Options__c == True /*&& eachItem.SBQQ__ProductOption__c == null*/) {
                            bundleList.add(eachItem);
                        }
                        //-- Option List adds recurring Quote Lines that are NOT Optional and have a Production Option
                        else if (eachItem.SBQQ__ProductOption__c != null){
                            optionList.add(eachitem);
                        }
                    }
                }

                //These is to handle only the adoptions
                Set<Id> adoptionIds = new Set<Id>();

                //--ADOPTION NetSuite Sales Orders
                for (SBQQ__QuoteLine__c eachItem : nsOrderItems) {
                    //if (eachItem.SBQQ__EffectiveQuantity__c > 0 && !eachItem.Recurring_Rev_Product__c
                    //&& eachItem.SBQQ__ProductFamily__c == 'Adoption')
                    if (eachItem.SBQQ__EffectiveQuantity__c > 0 && eachItem.Adoption__c)
                    {

                        System.debug('**CSALGADO**: In ADOPTION Netsuite Sales Order Create');

                        //-- NetSuite Sales Order Created
                        Netsuite_Sales_Order__c adoption = createNetsuiteSalesOrder(Quote, eachItem, quoteLineToLicProductName);

                        //-- Line Type & Other attributes added
                        if(eachItem.Sequence__c == 1){
                            adoption.Line_Type__c = 'Bundle';
                        }
                        else
                        {
                            adoption.Line_Type__c = 'Option';
                            adoption.Option_Product_Name__c = eachItem.SBQQ__ProductOption__r.SBQQ__OptionalSKU__r.Name;
                            adoption.Option_Product_Code__c = eachItem.SBQQ__ProductOption__r.SBQQ__OptionalSKU__r.NetSuite_Id__c;
                        }

                        //NS Integration Logic
                        adoption.NS_Integration_Logic__c = eachItem.NS_Integration_Logic__c;

                        //** Commented for 10/22 Deployment **
                        //Name: Chris Salgado Date: 10/9/2019 Purpose: W-012932
                        /*Quote_Subscription_Schedule__c sched = currentSchedule[0];
                        //Key for Net Price Map
                        String subSchedKey = String.valueOf(sched.Id) + String.valueOf(eachItem.Id);
                        if(qlToLISubSchedMap.containsKey(subSchedKey)){
                            adoption.Contract_Start_Date__c = qlToLISubSchedMap.get(subSchedKey).Start_Date__c;
                            adoption.Contract_End_Date__c = qlToLISubSchedMap.get(subSchedKey).End_Date__c;
                            adoption.Line_Item_Start_Date__c = qlToLISubSchedMap.get(subSchedKey).Start_Date__c;
                            adoption.Line_Item_End_Date__c = qlToLISubSchedMap.get(subSchedKey).End_Date__c;
                            adoption.Net_Price__c = qlToLISubSchedMap.get(subSchedKey).Net_Total__c;
                            adoption.Unit_Net_Price__c = qlToLISubSchedMap.get(subSchedKey).Net_Total__c / eachitem.SBQQ__EffectiveQuantity__c;
                        }*/

                        salesOrderFinal.add(adoption);
                        adoptionIds.add(eachItem.Id);
                    }
                }

                system.debug('before bundle and before billing shcedule loop' + salesOrderFinal);

                //This is to add the end of line to the adoption bundle
                if(!adoptionIds.isEmpty())
                {

                    System.debug('**CSALGADO**: In END OF ADOPTION BUNDLE Netsuite Sales Order Create');

                    Netsuite_Sales_Order__c endOfAdoptionBundle = new Netsuite_Sales_Order__c();
                    endOfAdoptionBundle.Product_Name__c = 'END';
                    endOfAdoptionBundle.Product_Code__c = '0';
                    endOfAdoptionBundle.Net_Price__c = 0.00;
                    endOfAdoptionBundle.Quote__c = Quote.Id;
                    endOfAdoptionBundle.CurrencyIsoCode = Quote.CurrencyIsoCode;
                    endOfAdoptionBundle.NS_Integration_Logic__c = 'No End Lines';// Elad Idan | W-011815 | Date: 04/15/2019
                    salesOrderFinal.add(endOfAdoptionBundle);
                }

                //Name: Chris Salgado
                //Date: 6/4/19
                //Work: W-012134

                //Years Counter
                Integer yrCounter = 0;
                //Total Number of Years
                String totalNumYrs = String.valueOf(currentSchedule.size());

                //-- SOFTWARE NetSuite Sales Orders
                //This is to create netsuite sales orders for non bundle items that are recurring
                for (Quote_Subscription_Schedule__c sched : currentSchedule) {

                    //Increment Year Counter
                    yrCounter ++;

                    for (SBQQ__QuoteLine__c eachItem : nsOrderItems) {
                        if (eachItem.SBQQ__EffectiveQuantity__c > 0 && eachItem.Recurring_Rev_Product__c
                                && !eachItem.Adoption__c
                                && ((eachItem.Has_Options__c != True && eachItem.SBQQ__ProductOption__c == null)
                                || (eachItem.Logical_Bundle__c && eachItem.SBQQ__ProductOption__c != null ))){

                            //Key for Net Price Map
                            String subSchedKey = String.valueOf(sched.Id) + String.valueOf(eachItem.Id);

                            System.debug('**CSALGADO**: In SOFTWARE  Netsuite Sales Order Create' );

                            //-- NetSuite Sales Order Created
                            Netsuite_Sales_Order__c software = createNetsuiteSalesOrder(Quote, eachItem, quoteLineToLicProductName);

                            //-- Line Type & Other attributes added
                            //Name: Chris Salgado Date: 7/2/19 Purpose: Fix Premium Support Bundle Line Type
                            if(eachItem.SBQQ__ProductName__c == Label.CPQ_NSSO_Product_Name){
                                software.Line_Type__c = 'Bundle';
                            }
                            else if(eachItem.SBQQ__ProductOption__r.Name == Label.CPQ_NSSO_Product_Option){
                                software.Line_Type__c = 'Option';
                                software.Option_Product_Code__c = '4779';
                                software.Option_Product_Name__c = 'Alteryx Enablement Day';
                                software.NS_Integration_Logic__c = 'Header Only'; //Name: Chris Salgado Date: 12/9/19 Purpose: W-012955
                            }
                            else{
                                software.Line_Type__c = 'Standard';
                            }

                            if(qlToLISubSchedMap.containsKey(subSchedKey)){
                                software.Net_Price__c = qlToLISubSchedMap.get(subSchedKey).Net_Total__c;
                                software.Unit_Net_Price__c = qlToLISubSchedMap.get(subSchedKey).Net_Total__c / eachitem.SBQQ__EffectiveQuantity__c;
                            }
                            else{
                                software.Net_Price__c = 0.00;
                                software.Unit_Net_Price__c = 0.00;
                            }
                            software.Billing_Year__c = sched.Year__c;
                            software.Billing_Year_Name__c = 'Year ' + String.valueOf(yrCounter) + ' of ' + totalNumYrs;
                            software.Class_of_Business__c = sched.Year__c == '1st' ? Quote.Class_of_Business__c : 'ECR';
                            software.Contract_Start_Date__c = sched.Subscription_Start_Date__c;
                            software.Contract_End_Date__c = sched.Subscription_End_Date__c;
                            salesOrderFinal.add(software);
                        }
                    }
                }


                system.debug('after adding to bundle and before billing shcedule loop' + bundleList);
                system.debug('after adding to options and before billing shcedule loop' + optionList);

                //Now we need to find which options relate to which bundle using the line number so we can
                //create a map of bundle to options
                Map<Id, List<SBQQ__QuoteLine__c>> bundleToLineItemsMap = new Map<Id, List<SBQQ__QuoteLine__c>>();

                for (SBQQ__QuoteLine__c bli : bundleList) {
                    System.debug('**CSALGADO**: For Bundle Quote Line: ' + bli.id);

                    for (SBQQ__QuoteLine__c oli : optionList) {
                        System.debug('**CSALGADO**: For Option Quote Line: ' + oli.id);

                        if (bli.Line_Number__c == oli.Line_Number__c) {
                            System.debug('**CSALGADO**: Line Number MATCH ');
                            if (bundleToLineItemsMap.containsKey(bli.Id)) {
                                System.debug('**CSALGADO**: Existing Option in MAP');
                                List<SBQQ__QuoteLine__c> oliList = bundleToLineItemsMap.get(bli.Id);
                                oliList.add(oli);
                            } else {
                                System.debug('**CSALGADO**: New Option in MAP');
                                List<SBQQ__QuoteLine__c> oliList = new List<SBQQ__QuoteLine__c>();
                                oliList.add(oli);
                                bundleToLineItemsMap.put(bli.Id, oliList);
                            }
                        }

                    }

                }
                system.debug('bundle to option map' + bundleToLineItemsMap);

                //Name: Chris Salgado
                //Date: 6/4/19
                //Work: W-012134

                //Reset Years Counter
                yrCounter = 0;

                //--BUNDLE & OPTION NetSuite Sales Orders

                //Now that we have our bundle to options map, we can create our Netsuite Sales Orders
                //for every bundle, loop through its related option
                //then in the outloop add another ns sales order record with the sequence = to ther list
                //count + 1

                if(!bundleToLineItemsMap.isEmpty())
                {
                    for (Quote_Subscription_Schedule__c sched : currentSchedule) {

                        //Increment Year Counter
                        yrCounter ++;

                        for (SBQQ__QuoteLine__c bli : bundleList) {

                            System.debug('**CSALGADO**: In BUNDLE Netsuite Sales Order Create');

                            //Get the Options for this Bundle
                            List<SBQQ__QuoteLine__c> options = bundleToLineItemsMap.get(bli.Id);

                            if(!options.isEmpty())
                            {
                                //End of Bundle Sequence #
                                Double optionSize = (Double) options.size();

                                //-- NetSuite Sales Order Created
                                Netsuite_Sales_Order__c bundle = createNetsuiteSalesOrder(Quote, bli, quoteLineToLicProductName);

                                //Key for Net Price Map
                                //Sergio Flores
                                //Date: 04/10/2020
                                //W-005066
                                String subKey = String.valueOf(sched.Id) + String.valueOf(bli.Id);

                                //-- Line Type & Other attributes added
                                bundle.Line_Type__c = 'Bundle';
                                /*bundle.Net_Price__c = sched.Net_Total__c;
                                bundle.Unit_Net_Price__c = sched.Net_Total__c / bli.SBQQ__EffectiveQuantity__c;*/
                                bundle.Net_Price__c = qlToLISubSchedMap.get(subKey).Net_Total__c; //SF 04/10.2020 W-005066
                                bundle.Unit_Net_Price__c = qlToLISubSchedMap.get(subKey).Net_Total__c / bli.SBQQ__EffectiveQuantity__c; //SF 04/10.2020 W-005066
                                bundle.Contract_Start_Date__c = sched.Subscription_Start_Date__c;
                                bundle.Contract_End_Date__c = sched.Subscription_End_Date__c;
                                bundle.Billing_Year__c = sched.Year__c;
                                bundle.Billing_Year_Name__c = 'Year ' + String.valueOf(yrCounter) + ' of ' + totalNumYrs;
                                bundle.Class_of_Business__c = sched.Year__c == '1st' ? Quote.Class_of_Business__c : 'ECR';
                                salesOrderFinal.add(bundle);

                                //Add first layer bundle to the list
                                //Add for every billing schedule for loop here?

                                //--Option NetSuite Sales Orders
                                for (SBQQ__QuoteLine__c pli : options) {

                                    System.debug('**CSALGADO**: In OPTION Netsuite Sales Order Create');

                                    //Key for Net Price Map
                                    String subSchedKey = String.valueOf(sched.Id) + String.valueOf(pli.Id);

                                    //-- NetSuite Sales Order Created
                                    Netsuite_Sales_Order__c option = createNetsuiteSalesOrder(Quote, pli, quoteLineToLicProductName);

                                    //-- Line Type & Other attributes added
                                    option.Line_Type__c = 'Option';
                                    option.Option_Product_Name__c = pli.SBQQ__ProductOption__r.SBQQ__OptionalSKU__r.Name;
                                    option.Option_Product_Code__c = pli.SBQQ__ProductOption__r.SBQQ__OptionalSKU__r.NetSuite_Id__c;
                                    if(qlToLISubSchedMap.containsKey(subSchedKey)){
                                        option.Net_Price__c = qlToLISubSchedMap.get(subSchedKey).Net_Total__c;
                                        option.Unit_Net_Price__c = qlToLISubSchedMap.get(subSchedKey).Net_Total__c / pli.SBQQ__EffectiveQuantity__c;
                                    }
                                    else{
                                        option.Net_Price__c = 0.00;
                                        option.Unit_Net_Price__c = 0.00;
                                    }
                                    option.Contract_Start_Date__c = sched.Subscription_Start_Date__c;
                                    option.Contract_End_Date__c = sched.Subscription_End_Date__c;
                                    option.Billing_Year__c = sched.Year__c;
                                    option.Billing_Year_Name__c = 'Year ' + String.valueOf(yrCounter) + ' of ' + totalNumYrs;
                                    option.Class_of_Business__c = sched.Year__c == '1st' ? Quote.Class_of_Business__c : 'ECR';
                                    option.NS_Integration_Logic__c = pli.NS_Integration_Logic__c;
                                    salesOrderFinal.add(option);
                                }

                                //Here is where we create the last bundle ns sales record and give if the
                                //sequence number of the size of optionSize + 1.0

                                //--EndOfBundle NetSuite Sales Orders

                                System.debug('**CSALGADO**: In END OF BUNDLE Netsuite Sales Order Create');

                                Netsuite_Sales_Order__c endOfBundle = new Netsuite_Sales_Order__c();
                                endOfBundle.Product_Name__c = 'END';
                                endOfBundle.Product_Code__c = '0';
                                endOfBundle.Net_Price__c = 0.00;
                                endOfBundle.Unit_Net_Price__c = 0.00;
                                endOfBundle.Quote__c = bli.SBQQ__Quote__c;
                                endOfBundle.CurrencyIsoCode = bli.CurrencyIsoCode;
                                endOfBundle.Line_Number__c = bli.Line_Number__c;
                                endOfBundle.Sequence__c = optionSize + 2;
                                endOfBundle.NS_Integration_Logic__c = bli.SBQQ__Product__r.NS_Integration_Logic__c;// Elad Idan | W-011815 | Date: 04/15/2019
                                endOfBundle.Billing_Year__c = sched.Year__c;
                                endOfBundle.Class_of_Business__c = sched.Year__c == '1st' ? Quote.Class_of_Business__c : 'ECR';
                                salesOrderFinal.add(endOfBundle);
                            }



                        }
                    }
                }


                system.debug('salesorderfinal list ' + salesOrderFinal);
                if (salesOrderFinal.size() != 0) {
                    System.debug('**CSALGADO**: Inside of Insert NS Sales Orders');
                    insert salesOrderFinal;
                }
            }
        }

        /*Author: Sharma Nemani | W-010323 | Case: 00234328 | Date: 03-12-2019
        * Description: To send Win Alerts to Cailin, Pete Robie, Carlos Avila and Jessica Silveri
        * when the Quote/Quote's Stage is "Approved" and the Opportunity's Stage is "5- Closed Won" and the
        * Quote/Quote has Line Items belonging to the Products "Alteryx Premium Support, Alteryx Advanced Support
        * and Alteryx Promote 24x7 Support".
        */

        Set<String> productCodes = new Set<String>();
        List<SBQQ__Quote__c> proposalDetails = new List<SBQQ__Quote__c>();
        Map<Id, SBQQ__Quote__c> proposalforEmail = new Map<Id, SBQQ__Quote__c>();

        //Fetch the matching Product codes from the Custom Settings AlteryxClosedWonProduct__c
        List<AlteryxClosedWonProduct__c> productCodeListCS = [Select Name from AlteryxClosedWonProduct__c];
        if (productCodeListCS.size() > 0) {
            for (AlteryxClosedWonProduct__c acwp : productCodeListCS) {
                productCodes.add(acwp.Name);
            }

            //Querying the Quote/Quote and its Line Items where Quote/Quote = Accepted
            for (SBQQ__Quote__c quo : [
                    Select id, Order_Group__c, Order_Group__r.Name, Order_Group__r.License_Group_Name__c, SBQQ__Opportunity2__c, (SELECT id, Name, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__ProductCode__c from SBQQ__LineItems__r),
                            SBQQ__Status__c, Name, SBQQ__Account__c, SBQQ__Account__r.Name
                    from SBQQ__Quote__c
                    where Id IN:quotes
            ]) {
                if (quo.SBQQ__Status__c == 'Accepted') {
                    //Checking Quote/Quote that has Line Items
                    if (quo.SBQQ__LineItems__r.size() > 0) {
                        //Looping over the Quote Line Items.
                        for (SBQQ__QuoteLine__c qli : quo.SBQQ__LineItems__r) {
                            if (productCodes.contains(qli.SBQQ__ProductCode__c)) //Checking if the Quote Line Items' Product Name matches the given Product Names - 'Alteryx Premium Support','Alteryx Advanced Support', 'Alteryx Promote 24x7 Support'.
                                proposalforEmail.put(quo.Id, quo);
                        }
                    }
                }
            }
            if (!proposalforEmail.isEmpty())
                sendEmailProposalAcceptance(proposalforEmail.values(), productCodes);

        }
    }

    public Netsuite_Sales_Order__c createNetsuiteSalesOrder(SBQQ__Quote__c quo, SBQQ__QuoteLine__c ql, Map<Id ,String> quoteLineToLicProductName)
    {
        Netsuite_Sales_Order__c nsso = new Netsuite_Sales_Order__c();

        //Product
        nsso.Product_Name__c = ql.SBQQ__ProductName__c;
        nsso.Product_Code__c = ql.SBQQ__Product__r.NetSuite_Id__c;

        //Quantity & Price
        nsso.Quantity__c = ql.SBQQ__EffectiveQuantity__c;
        nsso.Net_Price__c = ql.SBQQ__NetTotal__c;
        nsso.Unit_Net_Price__c = ql.SBQQ__NetTotal__c / ql.SBQQ__EffectiveQuantity__c;

        //Dates
        nsso.Contract_Start_Date__c = ql.SBQQ__EffectiveStartDate__c;
        nsso.Contract_End_Date__c = ql.CustomEndDate__c;
        nsso.Line_Item_Start_Date__c = ql.SBQQ__EffectiveStartDate__c;
        nsso.Line_Item_End_Date__c = ql.CustomEndDate__c;

        //Other
        nsso.Class_of_Business__c = quo.Class_of_Business__c;
        nsso.Billing_Year_Name__c = 'Year 1 of 1';
        nsso.Billing_Frequency__c = ql.SBQQ__Quote__r.SBQQ__BillingFrequency__c;
        nsso.CurrencyIsoCode = ql.CurrencyIsoCode;

        //Integration
        nsso.Line_Number__c = ql.Line_Number__c;
        nsso.Sequence__c = ql.Sequence__c;
        nsso.NS_Integration_Logic__c = ql.SBQQ__Product__r.NS_Integration_Logic__c; // Elad Idan | W-011815 | Date: 04/15/2019

        //Relationships
        nsso.Quote__c = ql.SBQQ__Quote__c;
        nsso.Quote_Line__c = ql.Id; // Sharma Nemani | W - 011397 | Case: 00268425 | Date: 03/26/2019
        nsso.License_Product_Name__c = quoteLineToLicProductName.containsKey(ql.Id)? quoteLineToLicProductName.get(ql.Id) : '';

        return nsso;
    }


    // Method for sending Email. Parameter = List<Quote/Quote>
    public void sendEmailProposalAcceptance(List<SBQQ__Quote__c> proposalforEmail, Set<String> productCodes) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<String> emailAddresses = new List<String>();
        //Fetching the email addresses from the Custom Settings AlteryxClosedWonEmail__c
        List<AlteryxClosedWonEmail__c> emailAddressListCS = [Select Name from AlteryxClosedWonEmail__c];
        if (emailAddressListCS.size() > 0) {
            for (AlteryxClosedWonEmail__c acwp : emailAddressListCS) {
                emailAddresses.add(acwp.Name);
            }
            for (SBQQ__Quote__c quotes : proposalforEmail) {
                string supportLevel = '';
                if (quotes.SBQQ__LineItems__r.size() > 0) {
                    for (SBQQ__QuoteLine__c qli : quotes.SBQQ__LineItems__r) {
                        if (productCodes.contains(qli.SBQQ__ProductCode__c) && !supportLevel.contains(qli.SBQQ__ProductName__c))
                            supportLevel += '[' + qli.SBQQ__ProductName__c + ']';
                    }
                }
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                //mail.toAddresses = new String[] { 'cavila@alteryx.com', 'cswingle@alteryx.com', 'probie@alteryx.com', 'jsilveri@alteryx.com' }; // Set the email addresses.
                mail.settoAddresses(emailAddresses);  // Set the email addresses.
                mail.setHTMLBody(setEmailBody(quotes, supportLevel));
                mail.setSubject('A New ' + supportLevel + ' Deal has been Sold!');
                emailsToSend.add(mail);
            }
            try {
                if (!Test.isRunningTest()) {
                    Messaging.sendEmail(emailsToSend, false);
                }
            } catch (Exception err) {
                System.debug('emailSendDebug: ' + err);
            }
        }

    }

    // Email Body Creation method
    public String setEmailBody(SBQQ__Quote__c Quote, string supportLevel) {

        String returnStr = '<html><body> A New ' + supportLevel + ' Deal has been Sold!<br/> <br/>' +
                'Account Name: ' + Quote.SBQQ__Account__r.Name + '<br/>';
        if (Quote.Order_Group__c != null) {
            returnStr += 'Order Group: ' + Quote.Order_Group__r.Name + '<br/>' +
                    'Order Group Name: ' + Quote.Order_Group__r.License_Group_Name__c + '<br/>';

        }
        returnStr += 'Quote: <a href="' + System.URL.getSalesforceBaseUrl().toExternalForm() + '/' + Quote.Id + '">' + Quote.Name + '</a></body></html>';
        return returnStr;
    }
}