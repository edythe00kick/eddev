/*------------------------------------------------------------------------+
Original Shift(developer@originalshift.com)
Purpose: Handles the CPQ Quote Trigger
 
Details: - Performs record type transition for the quote record for New-->Draft-->Submitted
     - Twin maps from the Quote to Opp on Insert/Update as appropriate
 
History:
Feb 08/19 - Original Shift - Initial Implementation
------------------------------------------------------------------------+*/
public with sharing class OSCPQ_QuoteTriggerHandler {
    public static Boolean firstRun = true; //used to prevent these methods from running more than once per transaction

    @TestVisible private CPQ_Setting__mdt settings; //Testvisible so that test classes can inject special settings.
    @TestVisible private CPQ_Custom_Setting__mdt customSettings;

    private Boolean isExecuting = false; // Stores the value of Trigger.isExecuting
    private Integer batchSize = 0; // Stores the value of Trigger.size
    public Set<Id> oppIds = new Set<Id>(); //stores the Opportunity Id, to delete/insert custom partners
    public Set<Id> oppsId = new Set<Id>(); //stores the Opportunity Id, to update the opp on partner addition
    public List<Custom_Partner__c> partnersToInsert = new List<Custom_Partner__c>();
    public List<Custom_Partner__c> partnersToDelete = new List<Custom_Partner__c>();
    public Set<Id> ordergroupIds = new Set<Id>();
    String additionalRole; //Graz Partner Changes 6/11/2019
    Map<Id, List<Custom_Partner__c>> oppIdToPartnerMap = new Map<Id, List<Custom_Partner__c>>();//Hemendra 05/28/2019

    List<SBQQ__Quote__c> quoteListForQueueable = new List<SBQQ__Quote__c>();//Sergio Added for and finally call 05/20/19
    Map<Id, SBQQ__Quote__c> oldQuoteMapForQueueable = new Map<Id, SBQQ__Quote__c>();//Sergio Added for and finally call 05/20/19
    /**
     * @author Grazitti - CPQ Go-Live 2019-07-04
     * @param isExecuting set if the Handler is currently in execution, used to prevent looping
     * @param batchSize batch size of the list which fired the handler, used to avoid DML Limits
     * @param settingsAPIName which CPQ_Setting__mdt settings configuration lookups to use
     * @description
     * Constructor - takes a metadata record API name, so that
     *  more scenarios can be accomodated as needed in an implemenation.
     *  For example, Partner quotes may not have the same level of automation
     */
    public OSCPQ_QuoteTriggerHandler(Boolean isExecuting, Integer batchSize, String settingsAPIName) {
        this.isExecuting = isExecuting;
        this.batchSize = batchSize;
        Set<Id> partnerIds = new Set<Id>();
        Set<Id> opportunityIds = new Set<Id>(); //Hemendra 05/28/2019
        additionalRole = Label.AdditionalPartnerRoles; //Graz Partner Changes 6/11/2019

        System.debug('settingsAPIName ' + settingsAPIName);
        if(settingsAPIName != null && settingsAPIName != '') {
            CPQ_Setting__mdt tmpSettings = OSCPQ_Utils.getContractSettings(settingsAPIName);
            if(tmpSettings != null){
                settings = tmpSettings;
            }

            CPQ_Custom_Setting__mdt tmpCPQSettings = OSCPQ_Utils.getCPQCustomSettings(settingsAPIName);
            if(tmpCPQSettings != null){
                customSettings = tmpCPQSettings;
            }
            System.debug('Final Step');//Hemendra 05/28/2019
        }

        // @TODO : jhorton : refactor the entire grazitti partner process
        /**
         * @author  Hemendra Singh
         * @date 05/28/2019
         * @description
         * BUILD THE LIST oppIds to build the list partnersToDelete to use in the And Finally
         * BUILD THE LIST opportunityIds Populate the Partner details during creation in BeforeInsert
         * BUILD THE LIST ordergroupIds to run OSCPQ_QuoteTriggerGateway.deleteLGAndLA in and Finally
         * @TODO : oppsId is a list built here, but used nowhere, this should be deleted
         * @TODO : This block of code should be moved from the constructor to the BeforeInsert; AfterInsert; AfterUpdate; onDelete as 3 methods to construct the lists for use in the finally block
         * Add Partners on Opportunity
         * Delete LA/LG
        */
        if(isExecuting) {
            if (Trigger.isBefore) {
                if (Trigger.isInsert || Trigger.isUpdate) {
                    for (SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) Trigger.new) {
                        if (Trigger.isInsert) {
                            if (quote.SBQQ__Opportunity2__c != null) {
                                opportunityIds.add(quote.SBQQ__Opportunity2__c);
                            }
                        }
                    }
                }
            } else if(Trigger.isAfter){
                if(Trigger.isInsert || Trigger.isUpdate){
                    for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) Trigger.new){
                        SBQQ__Quote__c oldQuote = Trigger.isUpdate ? (SBQQ__Quote__c) Trigger.oldMap.get(quote.Id) : new SBQQ__Quote__c();

                        if(Trigger.isInsert){
                            if(quote.SBQQ__Opportunity2__c != null && quote.SBQQ__Primary__c &&
                                    (quote.SBQQ__Partner__c != null || quote.SBQQ__Distributor__c != null
                                            || quote.Influencer_Account__c != null)){ //Graz Partner Changes 6/11/2019

                                oppIds.add(quote.SBQQ__Opportunity2__c);
                                oppsId.add(quote.SBQQ__Opportunity2__c);
                            }

                        } else if (Trigger.isUpdate){
                            if(quote.SBQQ__Opportunity2__c != null){
                                //jhorton - AfterUpdate - IF one of 3 partner lookups or primary is updated THEN add opp to oppsid
                                if(quote.SBQQ__Primary__c != oldQuote.SBQQ__Primary__c
                                        || quote.Influencer_Account__c != oldQuote.Influencer_Account__c //Graz Partner Changes 6/11/2019
                                        || quote.SBQQ__Distributor__c != oldQuote.SBQQ__Distributor__c
                                        || quote.SBQQ__Partner__c != oldQuote.SBQQ__Partner__c){

                                    oppsId.add(quote.SBQQ__Opportunity2__c);
                                }
                                //Hemendra 05/28/2019
                                //jhorton - AfterUpdate - IF Old Role is Referrer AND Update to Role occurs; THEN add to oppsId
                                if(((quote.Partner_Role__c == 'Referrer' || oldQuote.Partner_Role__c == 'Referrer')
                                        && quote.Partner_Role__c != oldQuote.Partner_Role__c) ||
                                        ((quote.Distributor_Role__c == 'Referrer' || oldQuote.Distributor_Role__c == 'Referrer')
                                                && quote.Distributor_Role__c != oldQuote.Distributor_Role__c)){

                                    oppsId.add(quote.SBQQ__Opportunity2__c);
                                }
                                //jhorton - AfterUpdate - IF Primary is updated add to oppIds
                                if(quote.SBQQ__Primary__c != oldQuote.SBQQ__Primary__c){
                                    oppIds.add(quote.SBQQ__Opportunity2__c);
                                }
                                //jhorton - AfterUpdate - If quote is primary check for partner changes
                                if(quote.SBQQ__Primary__c){
                                    //Graz Partner Changes 6/11/2019
                                    System.debug('Test quote.SBQQ__Partner__c ' + quote.SBQQ__Partner__c);
                                    System.debug('Test oldQuote.SBQQ__Partner__c ' +  oldQuote.SBQQ__Partner__c);
                                    System.debug('Test quote.Partner_Role__c ' +  quote.Partner_Role__c);
                                    System.debug('Test oldQuote.Partner_Role__c ' + oldQuote.Partner_Role__c);

                                    if(quote.SBQQ__Partner__c != oldQuote.SBQQ__Partner__c
                                            || quote.Partner_Role__c != oldQuote.Partner_Role__c){ //Graz Partner Changes 6/11/2019
                                        partnerIds.add(quote.SBQQ__Partner__c);
                                        partnerIds.add(oldQuote.SBQQ__Partner__c);
                                    }
                                    if(quote.SBQQ__Distributor__c != oldQuote.SBQQ__Distributor__c
                                            || quote.Distributor_Role__c != oldQuote.Distributor_Role__c){ //Graz Partner Changes 6/11/2019
                                        partnerIds.add(quote.SBQQ__Distributor__c);
                                        partnerIds.add(oldQuote.SBQQ__Distributor__c);
                                    }
                                    if(quote.Influencer_Account__c != oldQuote.Influencer_Account__c
                                            || quote.Influencer_Role__c != oldQuote.Influencer_Role__c){ //Graz Partner Changes 6/11/2019
                                        partnerIds.add(quote.Influencer_Account__c);
                                        partnerIds.add(oldQuote.Influencer_Account__c);
                                    }
                                    if(!partnerIds.isEmpty() && !oppIds.contains(quote.SBQQ__Opportunity2__c)){
                                        oppIds.add(quote.SBQQ__Opportunity2__c);
                                    }
                                }
                            } if(oldQuote.Order_Group__c != null && quote.Order_Group__c != oldQuote.Order_Group__c){
                                ordergroupIds.add(oldQuote.Order_Group__c);
                            }
                        }
                    }
                } else if(Trigger.isDelete){
                    for(SBQQ__Quote__c quote : (List<SBQQ__Quote__c>) Trigger.old){
                        if(quote.Order_Group__c != null){
                            ordergroupIds.add(quote.Order_Group__c);
                        }
                    }
                }
            }
        }

        if(!oppIds.isEmpty()){
            String query = 'SELECT Id from Custom_Partner__c WHERE OpportunityId__c In : oppIds';
            //List<String> additionalRole = label.AdditionalPartnerRoles.split(','); //Graz Partner Changes 6/11/2019
            String additional_where = (Trigger.isUpdate && !partnerIds.isEmpty()) ?
                    ' AND AccountToId__c in : partnerIds' : ''; //Graz Partner Changes 6/11/2019

            partnersToDelete = (List<Custom_Partner__c>) Database.query(query + additional_where);
        }

        //Handling recordtype scenarios
        /*SF 6/5/2019 W-012146
        String recordLabel = label.AFG_NFR_Record_type_Ids;
        for (String s : recordLabel.split(';')) {
            String recordtypes = SBQQ__Quote__c.sObjectType.getDescribe().getRecordTypeInfosByName().get(s).getRecordTypeId();
            recordTypeIds.add(recordtypes);
        }*/
        //Hemendra 05/28/2019
        if (!opportunityIds.isEmpty()) {
            //jhorton - oppIdToPartnerMap is used in the before insert
            oppIdToPartnerMap = OSCPQ_QuoteTriggerGateway.getOppIdToPartnerMap(opportunityIds);
        }
    }

    /*
     * Before Insert Method
     *   - Moves quotes from new to draft record type & Status
     *   - Populates Bill-TO Information
     *   - Twin Maps in from Contract as appropriate
     */
    public void onBeforeInsert(List<SBQQ__Quote__c> newQuoteList) {
        Set<Id> oppIdSet = new Set<Id>(); //set of opportunity Ids for the set of quotes
        Set<Id> contactIdSet = new Set<Id>(); //set of (primary) Contact Ids for the set of quote
        List<SBQQ__Quote__c> renewedQuotesToMapList = new List<SBQQ__Quote__c>(); //For twin mapping. List of quotes that are renewals
        List<SBQQ__Quote__c> amendedQuotesToMapList = new List<SBQQ__Quote__c>(); //For twin mapping. List of quotes that are amendments
        Set<Id> primaryContactIds = new Set<Id>(); //Used for updating primary contact ship to on quote
        Set<Id> partnerContact_OppIds = new Set<Id>();
        Set<Id> accounttIds = new Set<Id>();
        List<Opportunity> oppsToUpdateList = new List<Opportunity>(); //List of opps that need to be updated due to quote defaults needing to override.
        Set<Id> acctsFromQuotes = new Set<Id>();
        Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap = new  Map<Id,SBQQ__Quote__c>();
        Set<Id> coTermOppCheck = new Set<Id>(); //Name: Chris Salgado Date: 6/18/20 Purpose: W-005430

        Map<String, Id> pbNameToIdMap = new Map<String, Id>();
        for(Pricebook2 pb : [SELECT Id, Name FROM Pricebook2 WHERE IsActive = TRUE]) {
            pbNameToIdMap.put(pb.Name, pb.Id);
        }


        //First loop - build Opp Id Set, and do logic that is independent of Opp
        for(SBQQ__Quote__c quote : newQuoteList){
            //Hemendra 05/28/2019
            if (quote.SBQQ__Opportunity2__c != null) {
                oppIdSet.add(quote.SBQQ__Opportunity2__c);

                // Populate the Partner details during creation.
                if (oppIdToPartnerMap.containsKey(quote.SBQQ__Opportunity2__c)) {
                    for (Custom_Partner__c partner : oppIdToPartnerMap.get(quote.SBQQ__Opportunity2__c)) {
                        if(!additionalRole.containsIgnoreCase(partner.Role__c)){ //Graz Partner Changes 6/11/2019
                            if (partner.IsPrimary__c) {
                                quote.SBQQ__Partner__c = partner.AccountToId__c;
                                quote.Partner_Role__c  = partner.Role__c;
                            } else {
                                quote.SBQQ__Distributor__c = partner.AccountToId__c;
                                quote.Distributor_Role__c = partner.Role__c;
                            }
                        } else { //Graz Partner Changes 6/11/2019
                            quote.Influencer_Account__c = partner.AccountToId__c;
                            quote.Influencer_Role__c = partner.Role__c;
                        }
                    }
                }
            }
            if(quote.SBQQ__PrimaryContact__c != null) {
                contactIdSet.add(quote.SBQQ__PrimaryContact__c);
            }

            //Sergio Flores
            //Date: 06/04/2019
            //W-012132
            if (quote.SBQQ__Account__c != null) {
                quote.BillToAccount__c = quote.SBQQ__Account__c;
            }

            //Sergio Flores
            //Date: 05/24/2019
            //W-011831
            if(quote.Reseller_Deal__c == true)
            {
                quote.MLA_Option__c = 'Reseller';
            }

            //Sergio Flores
            //Date: 05/29/2019
            //W-011832
            //This is to keep the Order Form updated with the correct Ship To and Bill To
            //Address incase they change on order form sent
            if(quote.SBQQ__PrimaryContact__c != null ||  quote.BillToAccount__c != null)
            {
                if (quote.SBQQ__PrimaryContact__c != null) {
                    primaryContactIds.add(quote.SBQQ__PrimaryContact__c);
                }
                if (quote.BillToAccount__c != null) {
                    accounttIds.add(quote.BillToAccount__c);
                }
            }

            //Chris Salgado
            //Date: 08/14/2019
            //W-012807
            //Update the Tax Reg Number on the Quote from the Account

            //If the Matching Field is not blank add the Matching Field to a Set
            if(quote.SBQQ__Account__c != null /*&&  quote.SBQQ__Primary__c == TRUE*/){
                acctsFromQuotes.add(quote.SBQQ__Account__c);
            }

            //Name: Chris Salgado
            //Date: 10/24/2019
            //Purpose: W-012834
            if(quote.Partner_Contact__c == null && quote.SBQQ__Partner__c != null)
            {
                partnerContact_OppIds.add(quote.SBQQ__Opportunity2__c);
            }

            if(quote.Resend_To_Boomi__c == true){
                System.debug('Quote2Update :' + quote.Id);
                quoteIdToQuoteMap.put(quote.Id, quote);
            }

            //Name: Chris Salgado
            //Date: 6/18/20
            //Purpose: W-005430
            if(quote.SBQQ__Opportunity2__c != null) {
                coTermOppCheck.add(quote.SBQQ__Opportunity2__c);
            }
        }

        if(!quoteIdToQuoteMap.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.quotes2ResendToBoomi(quoteIdToQuoteMap);
        }

        //Name: Chris Salgado
        //Date: 10/24/2019
        //Purpose: W-012834
        if(!partnerContact_OppIds.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.getPartnerContactFromOppOrCont(partnerContact_OppIds, newQuoteList);
        }

        //Sergio Flores
        //Date: 05/29/2019
        //W-011832
        if(!primaryContactIds.isEmpty() || !accounttIds.isEmpty() )
        {
            OSCPQ_QuoteTriggerGateway.updateShipToANDBillTo(primaryContactIds,accounttIds, newQuoteList);
        }

        //Sergio Flores
        //Date: 06/07/2019
        //This is for checking primary on first purchased for Lauren
        if(!oppIdSet.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.stampOnInsertFields(oppIdSet, newQuoteList);
        }


        //Query relevant Opp and Acct fields
        Map<Id, Opportunity> oppIdToRecordMap = new Map<Id, Opportunity>([SELECT Id,
                SBQQ__RenewedContract__c,
                SBQQ__AmendedContract__c,
                Primary_Contact__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c,
                SBQQ__QuotePricebookId__c,
                CurrencyIsoCode,
                TotalOpportunityQuantity
        FROM Opportunity WHERE Id IN:oppIdSet]);

        //Second Loop - apply any logic dependant on the Opps
        if(!oppIdToRecordMap.isEmpty()) {
            for(SBQQ__Quote__c quote : newQuoteList) {
                if(quote.SBQQ__Opportunity2__c != null && oppIdToRecordMap.containsKey(quote.SBQQ__Opportunity2__c)) {
                    Opportunity opp = oppIdToRecordMap.get(quote.SBQQ__Opportunity2__c);
                    //Populate the Amendment/Renewal contract fields
                    if(opp.SBQQ__AmendedContract__c != null) {
                        quote.OSCPQ_Amended_Contract__c = opp.SBQQ__AmendedContract__c;
                        amendedQuotesToMapList.add(quote);
                    }

                    else if(opp.SBQQ__RenewedContract__c != null) {
                        quote.OSCPQ_Renewed_Contract__c = opp.SBQQ__RenewedContract__c;
                        renewedQuotesToMapList.add(quote);
                    }

                    /* OS Changes 6/17/2019: Commenting out quote-level Currency Selection in favor of doing it only at the Opp*/
                    //If opp already has product or the quote is a renewal/amendment, we will inherit from there (OOTB functionality)
                    if(opp != null) {
                        quote.CurrencyIsoCode = opp.CurrencyIsoCode;
                    }
                }
            }
        }



        //Do twin maps from the amended or renewed contract
        if(settings.TwinMapping_MapFromContractToQuote__c == true) {
            if(!amendedQuotesToMapList.isEmpty()) {
                OSCPQ_Utils.twinMapFieldsPull(amendedQuotesToMapList, 'Contract', 'OSCPQ_Amended_Contract__c', false);
            }
            else if(!renewedQuotesToMapList.isEmpty()) {
                OSCPQ_Utils.twinMapFieldsPull(renewedQuotesToMapList, 'Contract', 'OSCPQ_Renewed_Contract__c', false);
            }
        }

        //Do updates to other objects as needed
        if(!oppsToUpdateList.isEmpty()) {
            update oppsToUpdateList;
        }

        //Chris Salgado
        //Date: 08/14/2019
        //W-012807
        //If the Set is not empty call the Stamp Reg Number method
        if(!acctsFromQuotes.isEmpty()) {
            OSCPQ_QuoteTriggerGateway.stampTaxRegNumber(acctsFromQuotes, newQuoteList);
        }

        //Name: Chris Salgado
        //Date: 6/18/20
        //Purpose: W-005430
        if(!coTermOppCheck.isEmpty()){
            OSCPQ_QuoteTriggerGateway.coTermQuoteGeneration(newQuoteList ,coTermOppCheck);
        }
    }

    /*
     * Before Update Method
     *   - Moves quotes between draft and submitted record types and the appropriate status based on the ApprovalStatus__c field
     */
    public void onBeforeUpdate(List<SBQQ__Quote__c> newQuoteList, Map<Id, SBQQ__Quote__c> oldQuoteMap/*,Map<Id, SBQQ__Quote__c> newQuoteMap*/) {


        //   quoteOnUpdate(newQuoteList,oldQuoteMap,newQuoteMap);
        System.debug('inside onBeforeUpdate new quote ' + newQuoteList + ' old quote ' + oldQuoteMap );
        Set<Id> accountIds = new Set<Id>();
        Set<String> purchaseOrders = new Set<String>();
        List<SBQQ__Quote__c> proposalsWithUpdatedPOList = new List<SBQQ__Quote__c>();
        Set<Id> primaryContactIds = new Set<Id>(); //Used for updating primary contact ship to on quote
        Set<Id> accounttIds = new Set<Id>(); //Used for updating account bill to on quote
        Set<Id> partnerContact_OppIds = new Set<Id>();
        Set<Id> oppRenewedContractIds = new Set<Id>();
        Set<Id> amendedQuoteIds = new Set<Id>();
        Map<Id, SBQQ__Quote__c> quoteIdToQuoteAmenedMap = new Map<Id, SBQQ__Quote__c>();
        Set<Id> acctsFromQuotes = new Set<Id>();
        Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap = new  Map<Id,SBQQ__Quote__c>();
        //Commented for 2020-01-09 Release
        //Map<String,SBQQ__Quote__c> quoteNameToQuoteMap = new  Map<String,SBQQ__Quote__c>();
        //Reverted for 2020-01-02 Release
        Set<Id> quoteOrderGroupIds = new  Set<Id>();
        Set<Id> quoteLicenseAdminIds = new  Set<Id>();
        Map<Id, SBQQ__Quote__c> quoteIdToQuoteMapForEmailProducts = new Map<Id, SBQQ__Quote__c>(); //SF 04/14/2020 W-005055
        Map<Id, SBQQ__Quote__c> quoteIdToQuoteMapFoTaxReg = new Map<Id, SBQQ__Quote__c>(); //SF 06/16/2020 W-005661

        //Name: Chris Salgado
        //Purpose: Amendment - Related Contract Stamp
        //Date: 7/19/19
        //OSCPQ_QuoteTriggerGateway.stampAmendmentContract(Trigger.new);


        String usrProfileName = [SELECT u.Profile.Name FROM User u WHERE u.Id = :UserInfo.getUserId()].Profile.Name;
        String adminProfiles = System.Label.QuoteAdminProfiles;
        //Name: Chris Salgado Date: 4/17/20 Purpose: W-004439
        String dealDeskProfile = System.Label.AlteryxSalesDealDeskProfileId;
        String dealDeskApproverQueue = System.Label.AlteryxSalesDealDeskApproverQueueId;
        String errorMSG = 'Only Quotes owned by Deal Desk rep and in process of getting signed can be put On Hold.';

        Map<Id, SBQQ__Quote__c> opportunityIdToQuoteMap = new Map<Id, SBQQ__Quote__c>();

        List<Id> lstQuoteIdToUpdateApproval = new List<Id>();

        for(SBQQ__Quote__c quote : newQuoteList)
        {
            SBQQ__Quote__c oldQuote = oldQuoteMap.get(quote.Id);

            //Name: Chris Salgado Date: 4/17/20 Purpose: W-004439
            if(quote.SBQQ__Status__c == 'On Hold' && quote.SBQQ__Status__c != oldQuote.SBQQ__Status__c && !(oldQuote.SBQQ__Status__c == 'Sent for Signature' || oldQuote.SBQQ__Status__c == 'Waiting for Alteryx Counter Signature')){
                switch on String.valueOf(quote.OwnerId).left(3) {
                    when '005' {
                        Id OwnerProfileId = [SELECT Id, ProfileId FROM User WHERE Id = :quote.OwnerId].ProfileId;
                        System.debug('**CSALADO** Profile ID - ' + OwnerProfileId);
                        if (OwnerProfileId != dealDeskProfile) {
                            quote.addError(errorMSG);
                        }
                    }
                    when '00G' {
                        System.debug('**CSALADO** Queue ID - ' + quote.OwnerId);
                        if (quote.OwnerId != dealDeskApproverQueue) {
                            quote.addError(errorMSG);
                        }
                    }
                }
            }

            // Eddie Wong
            // W-005772
            // Date: 07/21/2020
            // Null out On Hold Reason unless quote status is On Hold
            if(quote.SBQQ__Status__c !='On Hold' ){
                quote.On_Hold_Reason__c  = null;
            }
            // Sharma Nemani | W-013451 | Case: 00295754 --> END

            //Sergio Flores
            //W-002462
            //Date: 02/27/2020
            //Refactor Quote Approval Status Changed (Invocable) Process Builder
            if( quote.ApprovalStatus__c != oldQuote.ApprovalStatus__c)
            {
                if(quote.ApprovalStatus__c == 'Pending')
                {
                    System.debug('inside approva; status update ' + quote );
                    quote.Quote_Has_Had_Approvals__c = true;
                    if (quote.Quote_Type__c == 'Evaluation') {
                        quote.RecordTypeId = QuoteRecordTypeIds__c.getValues('Submit_Simple').RecordTypeId__c;
                    } else {
                        quote.RecordTypeId = QuoteRecordTypeIds__c.getValues('Submitted').RecordTypeId__c;
                    }
                    quote.SBQQ__Status__c = 'In Review';
                }
                else if(quote.ApprovalStatus__c == 'Approved' && quote.Quote_Type__c != 'Purchase')
                {
                    quote.RecordTypeId = QuoteRecordTypeIds__c.getValues('Submit_Simple').RecordTypeId__c;
                    quote.SBQQ__Status__c = 'Accepted';
                }
                else if(quote.ApprovalStatus__c == 'Approved' && quote.Quote_Type__c == 'Purchase')
                {
                    quote.RecordTypeId = QuoteRecordTypeIds__c.getValues('Submitted').RecordTypeId__c;
                    if (quote.Quote_Has_Had_Approvals__c) {
                        quote.SBQQ__Status__c = 'Approved';
                    } else {
                        quote.SBQQ__Status__c = 'No Approval Required';
                    }
                }
                else if(quote.ApprovalStatus__c == 'Rejected' && quote.Quote_Has_Had_Approvals__c == false)
                {
                    quote.OwnerId = quote.SBQQ__SalesRep__c;
                    if (quote.Quote_Type__c == 'Evaluation' || quote.Quote_Type__c == 'AFG') {
                        quote.RecordTypeId = QuoteRecordTypeIds__c.getValues('Draft_Simple').RecordTypeId__c;
                    } else {
                        quote.RecordTypeId = QuoteRecordTypeIds__c.getValues('Draft').RecordTypeId__c;
                    }
                    quote.SBQQ__Status__c = 'Rejected';
                }
                else if(quote.ApprovalStatus__c == 'Recalled')
                {
                    quote.OwnerId = quote.SBQQ__SalesRep__c;
                    quote.Quote_Has_Had_Approvals__c = false;
                    if (quote.Quote_Type__c == 'Evaluation' || quote.Quote_Type__c == 'AFG') {
                        quote.RecordTypeId = QuoteRecordTypeIds__c.getValues('Draft_Simple').RecordTypeId__c;
                    } else {
                        quote.RecordTypeId = QuoteRecordTypeIds__c.getValues('Draft').RecordTypeId__c;
                    }
                    quote.SBQQ__Status__c = 'Draft';
                }
            }


            //Sergio Flores
            //Date:02/21/2020
            //W-004548
            if(quote.Effective_Subscription_Term__c != oldQuote.Effective_Subscription_Term__c || quote.SBQQ__NetAmount__c != oldQuote.SBQQ__NetAmount__c)
            {
                Recursionhandler.IsquoteUpdatedTCV = true;
            }

            //Sergio Flores
            //Date: 11/12/2019
            //W-013460 Updated the else if condition to include record type != draft
            //SF W-005653 06/15/2020 removed the updateAllowed boolean and added adminprofile check directly into the if statment
            //EW || W-005162 || 07/14/2020 || Added recursion handler and usrProfileName null check to bypass for co-term process
            if(Recursionhandler.IsContractAmendExecuted == False) {

                if(usrProfileName != null && !adminProfiles.Contains(usrProfileName) && quote.Quote_Type__c != 'Evaluation' && quote.Locked_For_Reps__c == true && oldQuote.Locked_For_Reps__c == true  && oldQuote.RecordTypeId != '0122R0000006GwGQAU')
                {
                    quote.addError('You cannot edit this Quote as it is with Deal Desk. Please reach out to Quote Owner to make updates.');
                }
            }

            //Sergio Flores - W-005474 - 20200227
            //JP HORTON - W-006127 - 20200820 - ADDED QUOTETYPE != 'Evaluation'
            //EW || W-005162 || 07/14/2020 || Added recursion handler and usrProfileName null check to bypass for co-term process
            if(RecursionHandler.IsContractAmendExecuted == false) {
                if(usrProfileName != null && !adminProfiles.contains(usrProfileName) && quote.SBQQ__StartDate__c != oldQuote.SBQQ__StartDate__c && quote.Class_of_Business__c == 'ECUR' && quote.Quote_Type__c != 'Evaluation') {
                    opportunityIdToQuoteMap.put(quote.SBQQ__Opportunity2__c, quote);
                }
            }


            //Handle setting the recalculation flag
            if(oldQuoteMap.containsKey(quote.Id)) {

                if(quote.SBQQ__Partner__c != oldQuote.SBQQ__Partner__c
                        || quote.SBQQ__Distributor__c != oldQuote.SBQQ__Distributor__c
                        || quote.Influencer_Account__c != oldQuote.Influencer_Account__c) { //Graz Partner Changes 6/11/2019

                    quote.Recalculate_Quote__c = !quote.Recalculate_Quote__c;
                }
            }

            /*
            * Remove Partner role, if the partner fields are nullified
            */
            if(quote.SBQQ__Partner__c != oldQuote.SBQQ__Partner__c && quote.SBQQ__Partner__c == null){
                quote.Partner_Role__c = null;
                quote.Partner_Contact__c = null; //Name: Chris Salgado Date: 11/12/19 Purpose: W-012834
            }

            if(quote.SBQQ__Distributor__c != oldQuote.SBQQ__Distributor__c && quote.SBQQ__Distributor__c == null){
                quote.Distributor_Role__c = null;
            }

            //Graz Partner Changes 6/11/2019
            if(quote.Influencer_Account__c != oldQuote.Influencer_Account__c && quote.Influencer_Account__c == null){
                quote.Influencer_Role__c = null;
            }

            //Author: Sergio Flores
            //Date: 11/12/2018
            //W-010133
            //If the Purchase_Order__c has changed and is not empty then go in here
            //Here we have to check whether the proposal has an account, if no account exists then check that there is a partner account,
            //Use either account or partner account to build the query, so add the account Ids to a set
            //Create a map of proposal id to proposal purchase order number, we will use this after we loop through all the proposals using the map, then we can do
            //another for loop in the Trigger is update check, and see if the proposal purchase order number is the same in the query result list by looping through the map,
            //then if the proposal is the same, grab the proposal name ex: Q-000123 and add them to a string, then outside the inner for loop we will need to populate this string
            //to the new field "Duplicate POs on Quotes".
            //New CPQ: W-011719


            if(quote.Purchase_Order__c != oldQuote.Purchase_Order__c && (quote.Purchase_Order__c != null))
            {
                if (quote.BillToAccount__c != null) {
                    accountIds.add(quote.BillToAccount__c);
                }

                System.debug('Proposal Account ID ' + accountIds);
                purchaseOrders.add(quote.Purchase_Order__c);
                proposalsWithUpdatedPOList.add(quote);
                System.debug('Purchase Orders ' + purchaseOrders);
            }

            //If new field Duplicate POs on quote is not null and the Purchase order is null, then we need to nullify the new field
            if(quote.Duplicate_POs_on_Quotes__c != null && quote.Purchase_Order__c == null)
            {
                quote.Duplicate_POs_on_Quotes__c = null;
            }

            //Sergio Flores
            //Date: 05/09/2019
            //W-011736
            //Need to Stamp When Quote is Accepted also lock the quote
            if(quote.SBQQ__Status__c == 'Accepted' && oldQuote.SBQQ__Status__c != 'Accepted')
            {
                quote.Proposal_Accepted_Date__c = Date.today();
                quote.Quote_is_Locked__c = true;
                quoteIdToQuoteMapForEmailProducts.put(quote.Id, quote); //SF 04/14/2020 W-005055

            }

            //Sergio Flores
            //Date: 05/24/2019
            //W-011831
            if( (quote.Reseller_Deal__c == true && oldQuote.Reseller_Deal__c != true) || (quote.Reseller_Deal__c == true && quote.MLA_Option__c != 'Reseller') )
            {
                quote.MLA_Option__c = 'Reseller';
            }

            //Sergio Flores
            //Date: 05/29/2019
            //W-011832
            //This is to keep the Order Form updated with the correct Ship To and Bill To
            //Address incase they change on order form sent
            if(quote.SBQQ__PrimaryContact__c != oldQuote.SBQQ__PrimaryContact__c ||  quote.BillToAccount__c != oldQuote.BillToAccount__c )
            {
                primaryContactIds.add(quote.SBQQ__PrimaryContact__c);
                if (quote.BillToAccount__c != null) {
                    accounttIds.add(quote.BillToAccount__c);
                }
            }

            //Sergio Flores
            //Date: 07/08/2019
            //W-012477
            if(quote.OSCPQ_Amended_Contract__c !=null && quote.SBQQ__PrimaryContact__c == null)
            {
                System.debug('inside amended contract logic ' + quote);
                oppRenewedContractIds.add(quote.OSCPQ_Amended_Contract__c);
            }

            //Name: Chris Salgado
            //Purpose: Amendment - Related Contract Stamp
            //Date: 7/19/19
            if(quote.SBQQ__Type__c == 'Amendment' && quote.OSCPQ_Amended_Contract__c != null && quote.Related_Contract__c == null)
            {
                amendedQuoteIds.add(quote.Id);
                quoteIdToQuoteAmenedMap.put(quote.Id, quote);
            }

            //Name: Chris Salgado
            //Date: 08/14/2019
            //W-012807
            //Update the Tax Reg Number on the Quote from the Account
            //If the Matching Field is not blank and the Quote was changed to Primary add the Matching Field to a Set
            if(quote.SBQQ__Account__c != null && quote.SBQQ__Primary__c != oldQuote.SBQQ__Primary__c &&  quote.SBQQ__Primary__c == true){
                acctsFromQuotes.add(quote.SBQQ__Account__c);
            }

            if(quote.Resend_To_Boomi__c == true)
            {
                System.debug('Quote2Update :' + quote.Id);
                quoteIdToQuoteMap.put(quote.Id, quote);
            }


            //Partially Commented for 2020-01-09 Release
            //Sergio Flores
            //Date: 09/10/2019
            //W-012806
            if( (quote.Order_Group__c != null && quote.Order_Group__c != oldQuote.Order_Group__c)
                    ||(quote.License_Administrator__c != null && quote.License_Administrator__c != oldQuote.License_Administrator__c)
                    /*|| (quote.SBQQ__Partner__c !=null && quote.SBQQ__Partner__c != oldQuote.SBQQ__Partner__c)
                    || (quote.SBQQ__Distributor__c !=null && quote.SBQQ__Distributor__c != oldQuote.SBQQ__Distributor__c)*/
                    )
            {
                //Reverted for 2020-01-02 Release
                if(!quoteIdToQuoteMap.containsKey(quote.Id))
                {
                    quoteIdToQuoteMap.put(quote.Id, quote);
                    if (quote.Order_Group__c != null) {
                        quoteOrderGroupIds.add(quote.Order_Group__c);
                    }
                    if (quote.License_Administrator__c != null) {
                        quoteLicenseAdminIds.add(quote.License_Administrator__c);
                    }
                }

            }

            //Name: Chris Salgado
            //Date: 10/24/2019
            //Purpose: W-012834
            if(quote.Partner_Contact__c == null && quote.SBQQ__Partner__c != null && oldQuote.SBQQ__Partner__c != quote.SBQQ__Partner__c)
            {
                partnerContact_OppIds.add(quote.SBQQ__Opportunity2__c);
            }

            //Sergio Flores
            //Date: 06/16/2020
            //W-005661
            if(quote.Quote_Type__c == 'Purchase' && quote.SBQQ__Status__c == 'Fully Signed' && oldQuote.SBQQ__Status__c != 'Fully Signed')
            {
                quoteIdToQuoteMapFoTaxReg.put(quote.Id, quote);
            }

        }

        if(!quoteIdToQuoteMapFoTaxReg.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.verifyTaxRegNumber(quoteIdToQuoteMapFoTaxReg);
        }

        //Sergio Flores
        //Date: 02/27/2020
        //W-005474
        if(!opportunityIdToQuoteMap.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.lockECURStartDate(opportunityIdToQuoteMap);
        }

        //Segio Flores
        //Date: 04/14/2020
        //W-005055
        if(!quoteIdToQuoteMapForEmailProducts.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.stamProductsForWinAlert(quoteIdToQuoteMapForEmailProducts);
        }

        //Name: Chris Salgado
        //Date: 10/24/2019
        //Purpose: W-012834
        if(!partnerContact_OppIds.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.getPartnerContactFromOppOrCont(partnerContact_OppIds, newQuoteList);
        }

        //Commented for 2020-01-09 Release
        //Sergio Flores
        //Date: 09/10/2019
        //W-012806
        /*if(!quoteLicenseAdminIds.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.validateOrderGroupSelected(quoteLicenseAdminIds ,  quoteNameToQuoteMap );
        }*/
        //Reverted for 2020-01-02 Release
        if(!quoteOrderGroupIds.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.validateOrderGroupSelected(quoteOrderGroupIds, quoteLicenseAdminIds ,  quoteIdToQuoteMap );
        }

        if(!quoteIdToQuoteMap.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.quotes2ResendToBoomi(quoteIdToQuoteMap);
        }

        //Name: Chris Salgado
        //Purpose: Amendment - Related Contract Stamp
        //Date: 7/19/19
        if(!amendedQuoteIds.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.stampAmendmentContract(amendedQuoteIds, quoteIdToQuoteAmenedMap);
        }

        //Name: Chris Salgado
        //Date: 08/14/2019
        //W-012807
        //If the Set is not empty call the Stamp Reg Number method
        if(!acctsFromQuotes.isEmpty()) {
            OSCPQ_QuoteTriggerGateway.stampTaxRegNumber(acctsFromQuotes, newQuoteList);
        }

        //Sergio Flores
        //Date: 07/08/2019
        //W-012477
        if(!oppRenewedContractIds.isEmpty())
        {
            System.debug('inside quoteRenewedContractIds ' + oppRenewedContractIds);
            Map<Id, Contract> renewedContractToOppMap = new Map<Id, Contract>([
                    SELECT Id, SBQQ__Opportunity__r.Primary_Contact__c, SBQQ__Quote__r.MLA_Option__c, SBQQ__Quote__r.MLA_Effective_Date__c, SBQQ__Quote__r.PaymentMethod__c,
                            SBQQ__Quote__r.Tax_Reg_Number__c,SBQQ__Quote__r.SBQQ__BillingFrequency__c,SBQQ__Quote__r.Is_Purchase_Order_Required__c,
                            SBQQ__Quote__r.SBQQ__PaymentTerms__c,SBQQ__Quote__r.Payment_Schedule__c, SBQQ__Opportunity__r.Type
                    FROM Contract WHERE Id IN : oppRenewedContractIds]);

            //Sergio Flores
            //Date: 07/08/2019
            //W-012477
            if(!renewedContractToOppMap.isEmpty())
            {
                OSCPQ_QuoteTriggerGateway.stampRequiredFieldsOnInsert(renewedContractToOppMap, newQuoteList);
            }
        }

        if(!primaryContactIds.isEmpty() || !accounttIds.isEmpty() )
        {
            OSCPQ_QuoteTriggerGateway.updateShipToANDBillTo(primaryContactIds,accounttIds, newQuoteList);
        }

        if(!purchaseOrders.isEmpty())
        {
            //Author: Sergio Flores
            //Date: 11-05-2018
            //W-010133
            List<SBQQ__Quote__c> proposalsWithDuplicatePurchaseOrders = [SELECT Name, Purchase_Order__c, BillToAccount__c
            FROM SBQQ__Quote__c
            WHERE  Purchase_Order__c IN : purchaseOrders
            AND BillToAccount__c IN : accountIds];
            System.debug('Proposals with Duplicate Purchase Orders '+ proposalsWithDuplicatePurchaseOrders);
            //Now we need to loop through all the new proposals, get the purchase order number using the map created above
            //then compare that value to the value in the proposalsWithDuplicatePurchaseOrders, if its a match then
            //we need to add that value inside the inner for loop to a string on the outer for loop, basically concatenate
            //then update the new field "Duplicate POs on Quotes" with the string
            //Check that the proposalsWithDuplicatePurchaseOrders isn't empty
            if(!proposalsWithDuplicatePurchaseOrders.isEmpty())
            {
                for(SBQQ__Quote__c pro : proposalsWithUpdatedPOList)
                {

                    String duplicatePOsOnQuotes;
                    for(SBQQ__Quote__c duplicateProp : proposalsWithDuplicatePurchaseOrders)
                    {
                        if(pro.Purchase_Order__c == duplicateProp.Purchase_Order__c
                                && ((pro.BillToAccount__c == duplicateProp.BillToAccount__c))
                                && (pro.Name != duplicateProp.Name) )
                        {
                            System.debug('Inside updating duplicate prop name' + duplicatePOsOnQuotes);
                            duplicatePOsOnQuotes += duplicateProp.Name + ',';
                        }
                    }
                    //Remove null
                    duplicatePOsOnQuotes = duplicatePOsOnQuotes.remove('null');
                    //Remove any trailing commas
                    duplicatePOsOnQuotes = duplicatePOsOnQuotes.removeEnd(',');
                    System.debug('Final duplicatePOsOnQuotes' + duplicatePOsOnQuotes);
                    //Set the new field to the duplicatePOsOnQuotes string
                    pro.Duplicate_POs_on_Quotes__c = duplicatePOsOnQuotes;
                }

            }
        }
        //Name: Chris Salgado Purpose: CPQ Project Date: 5/2/2019
        //OSCPQ_QuoteTriggerGateway.bundleQuoteLines(newQuoteList, oldQuoteMap);


    }

    /*
     * After Insert Method
     *   - Twin Maps from Quote to Opp
     */
    public void onAfterInsert(List<SBQQ__Quote__c> newQuoteList) {
        OSCPQ_QuoteTriggerGateway.twinMapToOpp(newQuoteList, settings);
        Custom_Partner__c partner;

        Set<Id> coTermOppCheckSet = new Set<Id>(); //EW || W-005162 || 07/14/2020

        for(SBQQ__Quote__c quote : newQuoteList)
        {
            if(oppIds.contains(quote.SBQQ__Opportunity2__c)){
                if(quote.SBQQ__Partner__c != null){
                    partner = new Custom_Partner__c();
                    partner.OpportunityId__c = quote.SBQQ__Opportunity2__c;
                    partner.AccountToId__c = quote.SBQQ__Partner__c;
                    partner.IsPrimary__c = true;
                    partner.Role__c = quote.Partner_Role__c;
                    partnersToInsert.add(partner);
                }

                if(quote.SBQQ__Distributor__c != null){
                    partner = new Custom_Partner__c();
                    partner.OpportunityId__c = quote.SBQQ__Opportunity2__c;
                    partner.AccountToId__c = quote.SBQQ__Distributor__c;
                    partner.IsPrimary__c = false;
                    partner.Role__c = quote.Distributor_Role__c;
                    partnersToInsert.add(partner);
                }

                //Graz Partner Changes 6/11/2019
                if(quote.Influencer_Account__c != null){
                    partner = new Custom_Partner__c();
                    partner.OpportunityId__c = quote.SBQQ__Opportunity2__c;
                    partner.AccountToId__c = quote.Influencer_Account__c;
                    partner.IsPrimary__c = false;
                    partner.Role__c = quote.Influencer_Account__c;
                    partnersToInsert.add(partner);
                }
            }


            //Name: Eddie Wong
            //Date: 7/14/2020
            //Purpose: W-005162
            if(quote.SBQQ__Opportunity2__c != null && Recursionhandler.IsContractAmendExecuted == true) {
                coTermOppCheckSet.add(quote.SBQQ__Opportunity2__c);
            }
        }


        //Name: Eddie Wong
        //Date: 7/14/20
        //Purpose: W-005162
        if(!coTermOppCheckSet.isEmpty()){
            OSCPQ_QuoteTriggerGateway.amendmentQuoteUpdate(newQuoteList ,coTermOppCheckSet);
        }
    }

    /*
     * After Update Method
     *   - Twin Maps from Quote to Opp
     */
    public void onAfterUpdate(List<SBQQ__Quote__c> newQuoteList, Map<Id, SBQQ__Quote__c> oldQuoteMap) {

        System.debug('inside on afer update quote trigger handler');
        OSCPQ_QuoteTriggerGateway.twinMapToOpp(newQuoteList, settings);
        Custom_Partner__c partner;

        // W-009835 - Add Proposal ID to Opps
        // Added by Hemendra Singh Rajawt on January 16, 2019
        Map<Id, SBQQ__Quote__c> oppToPrimaryQuoteMap = new Map<Id, SBQQ__Quote__c>(); //Sergio Flores 06/13/2019 W-012192
        Set<Id> opportunityIdsStampPrimaryQuote = new Set<Id>();
        Set<Id> opportunityIdsUnStampPrimaryQuote = new Set<Id>();
        Set<Id> acceptedPropIds = new Set<Id>(); //Used to query the alis associated to the proposal to check the support level
        List<SBQQ__Quote__c> acceptedProps = new List<SBQQ__Quote__c>(); //used for checking support level
        Map<Id, SBQQ__Quote__c> quotesIdToQuoteMap = new Map<Id, SBQQ__Quote__c>(); //This is used for the quotes that had approval status changed


        for(SBQQ__Quote__c newQuote : newQuoteList)
        {
            SBQQ__Quote__c oldQuote = (SBQQ__Quote__c) Trigger.oldMap.get(newQuote.Id);

            //Sergio Flores
            //W-002462
            //Date: 02/27/2020
            if( newQuote.ApprovalStatus__c != oldQuote.ApprovalStatus__c)
            {
                System.debug('inside after insert quote apporval status changed ' + oldQuote);
                quotesIdToQuoteMap.put(newQuote.Id, newQuote);
            }
            /*Add Partner on Quote Code Starts Here*/
            //Graz Partner Changes 6/11/2019
            System.debug('newQuote ' + newQuote.SBQQ__Primary__c);
            System.debug('oldQuote ' + oldQuote.SBQQ__Primary__c);

            if (newQuote.SBQQ__Primary__c) {

                if(newQuote.SBQQ__Partner__c != null && (newQuote.SBQQ__Partner__c != oldQuote.SBQQ__Partner__c
                        || (newQuote.SBQQ__Primary__c != oldQuote.SBQQ__Primary__c && newQuote.SBQQ__Primary__c)
                        || newQuote.Partner_Role__c != oldQuote.Partner_Role__c)){
                    partner = new Custom_Partner__c();
                    partner.OpportunityId__c = newQuote.SBQQ__Opportunity2__c;
                    partner.AccountToId__c = newQuote.SBQQ__Partner__c;
                    partner.IsPrimary__c = true;
                    partner.Role__c = newQuote.Partner_Role__c;
                    partnersToInsert.add(partner);
                    //oppsId.add(newQuote.SBQQ__Opportunity2__c);
                }

                if(newQuote.SBQQ__Distributor__c != null && (newQuote.SBQQ__Distributor__c != oldQuote.SBQQ__Distributor__c
                        || (newQuote.SBQQ__Primary__c != oldQuote.SBQQ__Primary__c && newQuote.SBQQ__Primary__c)
                        || newQuote.Distributor_Role__c != oldQuote.Distributor_Role__c)){
                    partner = new Custom_Partner__c();
                    partner.OpportunityId__c = newQuote.SBQQ__Opportunity2__c;
                    partner.AccountToId__c = newQuote.SBQQ__Distributor__c;
                    partner.IsPrimary__c = false;
                    partner.Role__c = newQuote.Distributor_Role__c;
                    partnersToInsert.add(partner);
                    //oppsId.add(newQuote.SBQQ__Opportunity2__c);
                }

                if(newQuote.Influencer_Account__c != null && (newQuote.Influencer_Account__c != oldQuote.Influencer_Account__c
                        || (newQuote.SBQQ__Primary__c != oldQuote.SBQQ__Primary__c && newQuote.SBQQ__Primary__c)
                        || newQuote.Influencer_Role__c != oldQuote.Influencer_Role__c)){
                    partner = new Custom_Partner__c();
                    partner.OpportunityId__c = newQuote.SBQQ__Opportunity2__c;
                    partner.AccountToId__c = newQuote.Influencer_Account__c;
                    partner.IsPrimary__c = false;
                    partner.Role__c = newQuote.Influencer_Role__c;
                    partnersToInsert.add(partner);
                    //oppsId.add(newQuote.SBQQ__Opportunity2__c);
                }
                /*Add Partner on Quote Code Ends Here*/
            }


            // W-009835 - Add Proposal ID to Opps
            // Added by Hemendra Singh Rajawt on January 16, 2019
            //Sergio Flores
            //Date: 04/19/2019
            //New CPQ: W-011732
            if (newQuote.SBQQ__Opportunity2__c != null && newQuote.SBQQ__Primary__c == true)
            {
                if (oldQuote.SBQQ__Primary__c != newQuote.SBQQ__Primary__c) {
                    opportunityIdsStampPrimaryQuote.add(newQuote.SBQQ__Opportunity2__c);
                }

                if(newQuote.SBQQ__StartDate__c != oldQuote.SBQQ__StartDate__c || newQuote.SBQQ__EndDate__c != oldQuote.SBQQ__EndDate__c)
                {
                    oppToPrimaryQuoteMap.put(newQuote.SBQQ__Opportunity2__c, newQuote);
                }
            }
            //Sergio Flores
            //Date: 05/30/2019
            //W-012126
            //this is to remove the primary quote from the opportunity
            else if(newQuote.SBQQ__Opportunity2__c != null
                    && oldQuote.SBQQ__Primary__c != newQuote.SBQQ__Primary__c && newQuote.SBQQ__Primary__c == false)
            {
                opportunityIdsUnStampPrimaryQuote.add(newQuote.SBQQ__Opportunity2__c);
            }

            //Need to add the ALI Ids to a set here so that we may query them later, loop through them, and check to see
            //what support level they fall under, then we can update the corresponding Order Group
            if(newQuote.SBQQ__Status__c == 'Accepted' && oldQuote.SBQQ__Status__c != 'Accepted'
                    && (newQuote.Order_Group__c != null /*&& newQuote.License_Administrator__c !=null*/))
            {
                if (!acceptedPropIds.contains(newQuote.Id)) {
                    acceptedPropIds.add(newQuote.Id);
                }
                acceptedProps.add(newQuote);
                System.debug('acceptedPropIds' + acceptedPropIds);
            }

            else if(newQuote.SBQQ__Status__c == 'Accepted' && oldQuote.SBQQ__Status__c != 'Accepted')
            {
                //Sergio Flores
                //Date: 05/13/2019
                //W-011795
                //Here we need to check all the accepted quotes
                if (!acceptedPropIds.contains(newQuote.Id)) {
                    acceptedPropIds.add(newQuote.Id);
                }
                System.debug('inside all accepted quotes' + acceptedPropIds);
            }
        }

        //Sergio Flores
        //W-002462
        //Date: 02/27/2020
        if(!quotesIdToQuoteMap.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.archiveApprovals(quotesIdToQuoteMap);
        }

        //Sergio Flores
        //Date: 06/13/2019
        //W-012192
        //This is to update the subscription dates on the opportunity
        if(!oppToPrimaryQuoteMap.isEmpty())
        {
            OSCPQ_QuoteTriggerGateway.updateSubscriptionOppDates(oppToPrimaryQuoteMap);
        }

        if(!acceptedPropIds.isEmpty())
        {
            //This method is for updating the opportunity Pilot field
            //This field is used to determine if there is an adoption product
            OSCPQ_QuoteTriggerGateway.updatePilotOpportunity(acceptedPropIds);
        }

        // W-009835 - Add Proposal ID to Opps
        // Added by Hemendra Singh Rajawt on January 16, 2019
        //Sergio Flores
        //Date: 04/19/2019
        //New CPQ: W-011732
        if(!opportunityIdsStampPrimaryQuote.isEmpty())
        {
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            oppsToUpdate = OSCPQ_QuoteTriggerGateway.addPrimaryQuote(opportunityIdsStampPrimaryQuote);

            if(!oppsToUpdate.isEmpty())
            {
                try{
                    update oppsToUpdate;
                }

                catch (Exception ex) {
                    System.debug('inside catch exception');
                    Trigger.new[0].addError(ex.getMessage());
                }

            }
        }

        //Sergio Flores
        //Date: 05/30/2019
        //W-012126
        //this is to remove the primary quote from the opportunity
        if(!opportunityIdsUnStampPrimaryQuote.isEmpty())
        {
            List<Opportunity> oppsToUpdate = new List<Opportunity>();
            oppsToUpdate = OSCPQ_QuoteTriggerGateway.removePrimaryQuote(opportunityIdsUnStampPrimaryQuote);

            if(!oppsToUpdate.isEmpty())
            {
                try{
                    update oppsToUpdate;
                }

                catch (Exception ex) {
                    System.debug('inside catch exception');
                    Trigger.new[0].addError(ex.getMessage());
                }

            }
        }

        //Author: Sergio Flores
        //Date: 11/27/2018
        //W-010668
        //New CPQ : W-011742
        //Refactored Date: 04/22/2019
        if(!acceptedProps.isEmpty())
        {
            QuoteUtilityClass.stampOrderGroupSupport(acceptedPropIds, acceptedProps);
        }

        //Name: Chris Salgado
        //Date: 5/2/2019
        //Purpose: CPQ Project - Bundle Quote Lines like Legacy System: Apttus did for Proposal Line Items
        if(!acceptedPropIds.isEmpty() && Recursionhandler.IsBundleQuoteLinesExecuted == false) {
            Recursionhandler.IsBundleQuoteLinesExecuted = true;
            OSCPQ_QuoteTriggerGateway.bundleQuoteLines(acceptedPropIds);
        }

        //Sergio Flores
        //Created this for quotequeueable call
        //Date: 05/20/2019
        quoteListForQueueable = newQuoteList;
        oldQuoteMapForQueueable = oldQuoteMap;

    }

    public void andFinally(){
        try{


            if(!partnersToDelete.isEmpty()){
                delete partnersToDelete;
            }
            if(!partnersToInsert.isEmpty()){
                insert partnersToInsert;
            }

            if(!ordergroupIds.isEmpty()){
                OSCPQ_QuoteTriggerGateway.deleteLGAndLA(ordergroupIds);
            }

            //Name: Chris Salgado
            //Purpose: CPQ Refactor
            //Date: 4/30/19
            //Sergio Flores moved to andFinally
            OSCPQ_QuoteTriggerGateway.getQuoteReadyForQueueable(quoteListForQueueable, oldQuoteMapForQueueable);

            //Name: Chris Salgado
            //Date: 8/27/2019
            //Purpose: W-012681
            if(!ResendToBoomiList.finalLicProdList.isEmpty()){
                update ResendToBoomiList.finalLicProdList;
            }

            //Name: Eddie Wong
            //Date: 9/16/2020
            //Purpose: W-005994
            if(!ResendToBoomiList.finalLicProdUpdateList.isEmpty()){
                update ResendToBoomiList.finalLicProdUpdateList;
            }

        } catch(Exception ex){
            List<SBQQ__Quote__c> quotes = (Trigger.isDelete) ? (List<SBQQ__Quote__c>) Trigger.old
                    : (List<SBQQ__Quote__c>) Trigger.new;

            for (SBQQ__Quote__c quote : quotes) {
                String msg = 'Error Message : ' + ex.getMessage();
                quote.addError(msg);
            }
        }
    }
}