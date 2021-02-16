/*------------------------------------------------------------------------+
Original Shift(developer@originalshift.com)
Purpose: Handles the OSCPQ Quote Line Trigger
 
Details: - Performs Quote Line Group Cloning
 
History:
Mar 06/19 - Original Shift - Initial Implementation
Apr 18/19 - Subscription Schedules
------------------------------------------------------------------------+*/
public with sharing class OSCPQ_QuoteLineTriggerHandler {
    @testVisible private CPQ_Setting__mdt settings; //Testvisible so that test classes can inject special settings.
    @testVisible private CPQ_Custom_Setting__mdt customSettings;
    private boolean isExecuting = false; // Stores the value of Trigger.isExecuting
    private integer batchSize = 0; // Stores the value of Trigger.size
    public static boolean firstRun = true; //used to prevent these methods from running more than once per transaction
    private static final string billFreqUpfrontValue = 'Upfront';
    private static final string billFreqAnnualValue = 'Annual';
    private Map<Id, Date> quoteIdToEndDateMap = new Map<Id,Date>(); //Map that tracks the end date of the quote by quote id
    /*
     * Constructor - takes a metadata record API name, so that
     *  more scenarios can be accomodated as needed in an implemenation.
     *  For example, Partner quotes may not have the same level of automation
     */
    public OSCPQ_QuoteLineTriggerHandler(Boolean isExecuting, Integer batchSize, String settingsAPIName) {
        if(settingsAPIName != null && settingsAPIName != '') {
            this.isExecuting = isExecuting;
            this.batchSize = batchSize;

            CPQ_Setting__mdt tmpSettings = OSCPQ_Utils.getContractSettings(settingsAPIName);
            if(tmpSettings != null){
                settings = tmpSettings;
            }

            CPQ_Custom_Setting__mdt tmpCPQSettings = OSCPQ_Utils.getCPQCustomSettings(settingsAPIName);
            if(tmpCPQSettings != null){
                customSettings = tmpCPQSettings;
            }
        }
    }

    /*
     * On After Insert method. Primary function is doing a quote line group cloning
     */
    public void onAfterInsert(List<SBQQ__QuoteLine__c> newQuoteLineList) {
        system.debug('calling QL onAfterInsert');
        this.cloneQuoteLineGroups(newQuoteLineList);
        this.subscriptionScheduleCreator(newQuoteLineList);

        Set<Id> adoptionQuoteIds = new Set<Id>();
        Set<Id> adoptionQuoteLineIds = new Set<Id>();

        for(SBQQ__QuoteLine__c ql : newQuoteLineList)
        {
            if(ql.SBQQ__ProductFamily__c != null && ql.SBQQ__ProductFamily__c == 'Adoption' && ql.SBQQ__RequiredBy__c == null)
            {
                adoptionQuoteIds.add(ql.SBQQ__Quote__c);
            }

        }

        if(!adoptionQuoteIds.isEmpty())
        {
            OSCPQ_QuoteLineTriggerGateway.checkForAdoptionQls(adoptionQuoteIds, adoptionQuoteLineIds);
        }



        //updateQuotesELADLACheckBoxTrue(newQuoteLineList); @Ryan Conaghan - Deprecated as this is handled in CPQ Price Rules
    }

    // created by Sharma || Date 16 June 2019 .
    // Update ELADLACheckBox checkbox on quote to true If any of QL has product code  'AX-100076','AX-100077' .
    // when Insert QL.
    /*@Ryan Conaghan - Deprecated as this is handled in CPQ Price Rules
    public void updateQuotesELADLACheckBoxTrue(List<SBQQ__QuoteLine__c> newQuoteLineList) {
        List<Id> quoteIds = new List<Id>();
        for(SBQQ__QuoteLine__c ql : newQuoteLineList){
            quoteIds.add(ql.SBQQ__Quote__c);
        }
        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c  qt : [select id,Includes_ELA_DLA__c,(select SBQQ__ProductCode__c from SBQQ__LineItems__r where SBQQ__ProductCode__c IN ('AX-100076','AX-100077')) from SBQQ__Quote__c where Id IN: quoteIds]){
            if(qt.SBQQ__LineItems__r.size() > 0){
                qt.Includes_ELA_DLA__c = true;
                lstQuote.add(qt);
            }
        }
        update lstQuote;
    }
    */

    // created by Sharma || Date 16 June 2019 .
    // Update ELADLACheckBox checkbox on quote to false If No QL have product code  'AX-100076','AX-100077' .
    // when delete QL
    /* @Ryan Conaghan - Deprecated as this is handled in CPQ Price Rules
    public static void updateQuotesELADLACheckBoxFalse(List<SBQQ__QuoteLine__c> newQuoteLineList){
        List<Id> quoteIds = new List<Id>();
        List<Id> qlIds = new List<Id>();
        for(SBQQ__QuoteLine__c ql : newQuoteLineList){
            quoteIds.add(ql.SBQQ__Quote__c);
            qlIds.add(ql.Id);
        }

        List<SBQQ__Quote__c> lstQuote = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c  qt : [select id,Includes_ELA_DLA__c,(select SBQQ__ProductCode__c from SBQQ__LineItems__r where SBQQ__ProductCode__c IN ('AX-100076','AX-100077') AND Id NOT IN : qlIds) from SBQQ__Quote__c where Id IN: quoteIds]){
            if(qt.SBQQ__LineItems__r.size() > 0){
                qt.Includes_ELA_DLA__c = false;
                lstQuote.add(qt);
            }
        }
        update lstQuote;
    }
    */


    /*
     * On After Insert method. Primary function is doing a quote line group cloning
     */
    public void onAfterUpdate(List<SBQQ__QuoteLine__c> newQuoteLineList) {
        system.debug('calling QL onAfterUpdate');
        //possibly need to add a check here if unequal payments is true
        //not to execute subscription shcedule recalc
        List<SBQQ__QuoteLine__c> updatedQUoteLinelist = new List<SBQQ__QuoteLine__c>();

        Set<Id> adoptionQuoteIds = new Set<Id>();
        Set<Id> adoptionQuoteLineIds = new Set<Id>();

        for(SBQQ__QuoteLine__c ql : newQuoteLineList)
        {
            SBQQ__QuoteLine__c oldQL = (SBQQ__QuoteLine__c)Trigger.oldMap.get(ql.Id);

            if(ql.Unequal_Payments_Override__c == false)
                updatedQUoteLinelist.add(ql);

            if(ql.SBQQ__ProductFamily__c != null && ql.SBQQ__ProductFamily__c == 'Adoption' && ql.SBQQ__RequiredBy__c == null && ql.SBQQ__EffectiveSubscriptionTerm__c != oldQL.SBQQ__EffectiveSubscriptionTerm__c)
            {
                adoptionQuoteIds.add(ql.SBQQ__Quote__c);
            }

        }
        this.subscriptionScheduleCreator(updatedQUoteLinelist);

        if(!adoptionQuoteIds.isEmpty())
        {
            OSCPQ_QuoteLineTriggerGateway.checkForAdoptionQls(adoptionQuoteIds, adoptionQuoteLineIds);
        }
    }

    /*
    * On Before Delete Method. Primary purpose is to clean up any Line Item Subscription Schedules
    */
    public void onBeforeDelete(Map<Id, SBQQ__QuoteLine__c> oldQuoteLineMap) {
        List<Line_Item_Subscription_Schedule__c> liSchedulesToDelete = [SELECT Id FROM Line_Item_Subscription_Schedule__c WHERE Quote_Line__c IN :oldQuoteLineMap.keySet()];
        if(!liSchedulesToDelete.isEmpty()) {
            delete liSchedulesToDelete;
        }
    }

    public void onAfterDelete(List<SBQQ__QuoteLine__c> deletedQuoteLineList) {
        system.debug('inside onAfterDelete ql ');

        Set<Id> adoptionQuoteIds = new Set<Id>();
        Set<Id> adoptionQuoteLineIds = new Set<Id>();

        for(SBQQ__QuoteLine__c ql : deletedQuoteLineList)
        {
            adoptionQuoteIds.add(ql.SBQQ__Quote__c);
            adoptionQuoteLineIds.add(ql.Id);
        }

        if(!adoptionQuoteIds.isEmpty())
        {
            OSCPQ_QuoteLineTriggerGateway.checkForAdoptionQls(adoptionQuoteIds, adoptionQuoteLineIds);
        }
    }


    private static List<String> getFieldsToClone() {
        List<String> fieldsToClone = new List<String>();

        //Get all fields from the QLG and determine which ones the user has appropriate access to for cloning purposes.
        List<String> twinMappableFieldNames = new List<String>();
        Map<String, Schema.SObjectField> allQLGFieldsMap = Schema.SObjectType.SBQQ__QuoteLineGroup__c.fields.getMap();
        for(String qlgFieldApiName : allQLGFieldsMap.keySet()){
            Schema.DescribeFieldResult fieldDescribeRes = allQLGFieldsMap.get(qlgFieldApiName).getDescribe();
            //Unlike the true twin mapping feature, allow for package fields to be cloned
            if(fieldDescribeRes.isAccessible() && fieldDescribeRes.isUpdateable() && !fieldDescribeRes.isExternalId() && !fieldDescribeRes.isCalculated()) {
                twinMappableFieldNames.add(qlgFieldApiName);
            }
        }

        //Loop through fields in the clonable field set, and check them against the twinMappable set
        List<Schema.FieldSetMember> clonableFSMembers;
        Schema.FieldSet clonableFieldSet = Schema.SObjectType.SBQQ__QuoteLineGroup__c.fieldSets.OSCPQ_Clonable_Fields;
        if(clonableFieldSet != null) {
            clonableFSMembers = clonableFieldSet.getFields();
            //Loop through the clonable fields from the field set, check that the user has appropriate access (from the twin map util), and add to the result
            if(!clonableFSMembers.isEmpty() && !twinMappableFieldNames.isEmpty()) {
                for(Schema.FieldSetMember fsMember : clonableFSMembers) {
                    string fieldName = fsMember.getFieldPath();
                    if(twinMappableFieldNames.contains(fieldName.toLowerCase())) {
                        fieldsToClone.add(fieldName);
                    }
                }
            }
        }

        return fieldsToClone;
    }


    /*
     * Method that does quote line group cloning for renewals and/or amendments as appropriate
     */
    private void cloneQuoteLineGroups(List<SBQQ__QuoteLine__c> newQuoteLineList) {
        Set<Id> origQuoteLineGroupIds = new Set<Id>();
        List<Id> parentIds = new List<Id>();
        Id quoteId;

        if(settings.TwinMapping_CloneQuoteGroups__c != 'Never') {
            //Initial loop; pull list of Original Group Ids and get the Quote Id
            for (SBQQ__QuoteLine__c qli : newQuoteLineList) {
                quoteId = qli.SBQQ__Quote__c;

                //Since parent items get inserted in call before children, we should only get Ids from the parent
                if (qli.SBQQ__RequiredBy__c == null && qli.OSCPQ_Original_Quote_Line_Group_Id__c != null) {
                    origQuoteLineGroupIds.add(qli.OSCPQ_Original_Quote_Line_Group_Id__c);
                } //Child items are always grouped together with the parent, so we just need to get the various parent Ids
                else if(qli.SBQQ__RequiredBy__c != null) {
                    parentIds.add(qli.SBQQ__RequiredBy__c);
                }
            }

            //Check if we are in a valid case for group cloning
            SBQQ__Quote__c quote = [SELECT Id, SBQQ__Type__c FROM SBQQ__Quote__c WHERE Id = :quoteId LIMIT 1];
            if((quote.SBQQ__Type__c == 'Amendment' && (settings.TwinMapping_CloneQuoteGroups__c == 'On Amendment' || settings.TwinMapping_CloneQuoteGroups__c == 'Always'))
                    || (quote.SBQQ__Type__c == 'Renewal' && (settings.TwinMapping_CloneQuoteGroups__c == 'On Renewal' || settings.TwinMapping_CloneQuoteGroups__c == 'Always'))
                    ) {
                List<String> clonableFields = getFieldsToClone();
                Map<Id, SBQQ__QuoteLineGroup__c> oldQLGMap = new Map<Id, SBQQ__QuoteLineGroup__c>();
                if(!clonableFields.isEmpty()) {
                    List<SBQQ__QuoteLineGroup__c> currentQLGs = new List<SBQQ__QuoteLineGroup__c>([SELECT Id, OSCPQ_Original_Quote_Line_Group__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :quoteId]);

                    //Pull Query for the original quote line groups
                    String queryStr = 'Select ' + String.join(clonableFields, ', ') + ', Id'
                            + ' FROM SBQQ__QuoteLineGroup__c WHERE Id IN :origQuoteLineGroupIds';
                    List<SBQQ__QuoteLineGroup__c> oldQLGList = (List<SBQQ__QuoteLineGroup__c>)database.query(queryStr);
                    //Fields selected and old QLGs queried - now need to map
                    List<SBQQ__QuoteLineGroup__c> newQLGList = new List<SBQQ__QuoteLineGroup__c>();

                    //make sure we don't duplicate groups created in prior calls
                    List<String> existingCheck = new List<String>();

                    for (SBQQ__QuoteLineGroup__c qlg : currentQLGs) {
                        existingCheck.add(qlg.OSCPQ_Original_Quote_Line_Group__c);
                    }

                    //Loop that actually does the mapping from old group to new group
                    for (SBQQ__QuoteLineGroup__c oldQLG : oldQLGList) {
                        if (!existingCheck.contains(oldQLG.Id)) { //If we haven't already created this group
                            SBQQ__QuoteLineGroup__c newQLG = new SBQQ__QuoteLineGroup__c();
                            for(String fieldName : clonableFields) {
                                newQLG.put(fieldName, oldQLG.get(fieldName));
                            }

                            newqlg.SBQQ__Quote__c = quoteId;
                            newqlg.OSCPQ_Original_Quote_Line_Group__c = oldQLG.Id;
                            newQLGList.add(newqlg);
                        }
                    }
                    //Actually insert the new QLGs
                    if (newQLGList.size() > 0) {
                        insert newQLGList;
                        currentQLGs.addAll(newQLGList);
                    }

                    //Finally, associate quote lines with the appropriate group
                    Map<Id,SBQQ__QuoteLine__c> parentLines = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Group__c FROM SBQQ__QuoteLine__c WHERE Id IN :parentIds]);
                    for (SBQQ__QuoteLine__c qli : newQuoteLineList) {
                        for (SBQQ__QuoteLineGroup__c qlg : currentQLGs) {
                            if (qlg.OSCPQ_Original_Quote_Line_Group__c == qli.OSCPQ_Original_Quote_Line_Group_Id__c) {
                                qli.SBQQ__Group__c = qlg.Id;
                            } else if(qli.SBQQ__RequiredBy__c != null){
                                SBQQ__QuoteLine__c parentQLI = parentLines.get(qli.SBQQ__RequiredBy__c);
                                qli.SBQQ__Group__c = parentQLI.SBQQ__Group__c;
                            }
                        }
                    }
                }


            }
        }
    }


    /*
     * Method that creates new quote and quote line item subscription schedules
     * Assumptions with the following Logic:
     *     - No more than 1 partial-year segment on any quote (except for MDQ where entire segments may be < 1 year)
     */
    private void subscriptionScheduleCreator(List<SBQQ__QuoteLine__c> newQuoteLineList) {
        system.debug('inside subscriptionScheduleCreator ' + newQuoteLineList);
        Map<Id, Decimal> qlIdToCurrentNetTotalMap = new Map<Id, Decimal>(); //Map that stores the total Net on all QL sub schedules. Used to reconcile rounding issues
        List<Line_Item_Subscription_Schedule__c> newSubSchList = new List<Line_Item_Subscription_Schedule__c>(); //New Line-Level subscription schedules to create
        Map<String, Quote_Subscription_Schedule__c> newSubScheduleMap = new Map<String, Quote_Subscription_Schedule__c>(); //key = External_Key__c
        Map<Id, List<Quote_Subscription_Schedule__c>> quoteIdToSubScheduleListMap = new Map<Id, List<Quote_Subscription_Schedule__c>>(); //Key = quote Id
        Set<Id> quoteIdSet = new Set<Id>(); //List of quotes where status is valid.
        Map<Id, Date> quoteIdToEarliestStartDateMap = new Map<Id, Date>(); //Earliest explicit line-level start date for each quote
        Map<Id, Date> quoteIdToLatestEndDateMap = new Map<Id, Date>(); //Latest explicit line-level end date for each quote
        List<String> qlSubSchExternalKeyList = new list<String>(); //List of all external keys being added for QL subscription schedules, so that others can be cleaned out.
        Set<Id> quoteLineIds = new Set<Id>(); //Eddie Add - List of quote line ids

        //Small loop just to collect Quote Ids and to get the earliest start and latest end dates that are explcitily populatated on the QL level.
        for(SBQQ__QuoteLine__c newQL : newQuoteLineList) {
            quoteIdSet.add(newQL.SBQQ__Quote__c);
            qlIdToCurrentNetTotalMap.put(newQL.Id, 0.0);
            Date subStartDate = (quoteIdToEarliestStartDateMap.containsKey(newQL.SBQQ__Quote__c)) ? quoteIdToEarliestStartDateMap.get(newQL.SBQQ__Quote__c) : null; //Iniitalization
            Date subEndDate = (quoteIdToLatestEndDateMap.containsKey(newQL.SBQQ__Quote__c)) ? quoteIdToLatestEndDateMap.get(newQL.SBQQ__Quote__c) : null; //Iniitalization
            if(newQL.SBQQ__EffectiveStartDate__c != null && (subStartDate == null || newQL.SBQQ__EffectiveStartDate__c < subStartDate)) {
                quoteIdToEarliestStartDateMap.put(newQL.SBQQ__Quote__c, newQL.SBQQ__EffectiveStartDate__c);
            }
            if(newQL.SBQQ__EffectiveEndDate__c != null && (subStartDate == null || newQL.SBQQ__EffectiveEndDate__c > subEndDate)) {
                quoteIdToLatestEndDateMap.put(newQL.SBQQ__Quote__c, newQL.SBQQ__EffectiveEndDate__c);
            }
        }



        //Create Quote-level subscription schedule headers
        createQuoteLevelSubSchedules(quoteIdSet, quoteIdToEarliestStartDateMap, quoteIdToLatestEndDateMap, newSubScheduleMap, quoteIdToSubScheduleListMap);

        //Insert the Quote-level subscriptions
        Set<String> externalKeyList = newSubScheduleMap.keySet();
        if(!quoteIdSet.isEmpty() && !externalKeyList.isEmpty()) { //Clean up any irrelevant existing schedules
            delete [SELECT Id FROM Quote_Subscription_Schedule__c WHERE Quote__c IN :quoteIdSet AND External_Key__c NOT IN :externalKeyList];
        }
        if(!newSubScheduleMap.isEmpty()) {
            upsert newSubScheduleMap.values() External_Key__c;
        }

        //Eddie Add - loop through newQuoteLineList and add quote line ids to quoteLineIds
        for(SBQQ__QuoteLine__c newQL : newQuoteLineList){
            quoteLineIds.add(newQL.Id);
        }

        //Eddie Add - query required fields from quote lines and assign to a map
        Map<Id, SBQQ__QuoteLine__c> lQuoteLine = new Map<Id, SBQQ__QuoteLine__c>([SELECT Id,SBQQ__EffectiveStartDate__c,CustomEndDate__c,SBQQ__ProductFamily__C,SBQQ__RequiredBy__c,SBQQ__RequiredBy__r.SBQQ__ProductFamily__c,SBQQ__RequiredBy__r.SBQQ__Product__r.Family
                                        FROM SBQQ__QuoteLine__c
                                        WHERE Id = :quoteLineIds]);

        //Primary quote line loop
        for(SBQQ__QuoteLine__c newQL : newQuoteLineList) {
            Date quoteEndDate = quoteIdToEndDateMap.get(newQL.SBQQ__Quote__c);
            Decimal qlProrateMultiplier = (newQL.SBQQ__ProrateMultiplier__c != null) ? newQL.SBQQ__ProrateMultiplier__c : 1.0;

            //Find & loop through sub shcedules and then start adding onto the quote line
            List<Quote_Subscription_Schedule__c> fetchedSubSchList = (quoteIdToSubScheduleListMap.containskey(newQL.SBQQ__Quote__c)) ? quoteIdToSubScheduleListMap.get(newQL.SBQQ__Quote__c) : new List<Quote_Subscription_Schedule__c>();
            for(Quote_Subscription_Schedule__c quoteSubSch : fetchedSubSchList) {
                //See if the sub schedule relates to this quote line at all

                Date qlEffStartDate = (newQL.SBQQ__EffectiveStartDate__c != null) ? newQL.SBQQ__EffectiveStartDate__c : quoteSubSch.Subscription_Start_Date__c;
                Date qlEffEndDate = (newQL.SBQQ__EffectiveEndDate__c != null) ? newQL.SBQQ__EffectiveEndDate__c : quoteEndDate;
                if(newQL.Recurring_Rev_Product__c == false) {
                    qlEffEndDate = qlEffStartDate; //Assets should only belong in one period
                }

                if((newQL.Recurring_Rev_Product__c
                        && (qlEffStartDate <= quoteSubSch.Subscription_Start_Date__c && qlEffEndDate >= quoteSubSch.Subscription_End_Date__c) //sub sch is a subset of overall QL term
                        ||  (qlEffStartDate <= quoteSubSch.Subscription_Start_Date__c && qlEffEndDate >= quoteSubSch.Subscription_Start_Date__c) //starts prior and ends sometime in this sub sch
                        || (qlEffStartDate >= quoteSubSch.Subscription_Start_Date__c && qlEffStartDate <= quoteSubSch.Subscription_End_Date__c) //start in the middle of this sub sch
                )
                        || ((newQL.Recurring_Rev_Product__c == false)
                        && (qlEffStartDate <= quoteSubSch.Subscription_Start_Date__c && quoteSubsch.Year__c == '1st')
                        || (qlEffStartDate >= quoteSubSch.Subscription_Start_Date__c && qlEffStartDate <= quoteSubSch.Subscription_End_Date__c)
                )
                        ) {

                    String externalKey = quoteSubSch.External_Key__c + ' - ' + newQL.Name;
                    qlSubSchExternalKeyList.add(externalKey);
                    Date qlSchStartDate = (qlEffStartDate < quoteSubSch.Subscription_Start_Date__c) ? quoteSubSch.Subscription_Start_Date__c : qlEffStartDate;
                    Date qlSchEndDate = (qlEffEndDate <= quoteSubSch.Subscription_End_Date__c) ? qlEffEndDate : quoteSubSch.Subscription_End_Date__c;
                    //Non-recurring get end dated to the Quote sub sch
                    if(newQL.Recurring_Rev_Product__c == false) {
                        qlSchEndDate = quoteSubSch.Subscription_End_Date__c;
                    }
                    //Sergio Flores
                    //Date: 08/12/2019
                    //W-012838
                    //Check to see if QL ProductName = 'Alteryx Enablement Day', if so then grab QL Custom EndDate
                    system.debug('inside checking to see if Alteryx Enabalment Day is custom end date ' + newQl);
                    if(newQl.SBQQ__ProductName__c == 'Alteryx Enablement Day')
                    {
                        qlSchEndDate = newQL.CustomEndDate__c;
                    }

                    //Eddie Wong
                    //Date: 04/05/2020
                    //W-002266
                    //For Adoption, use SBQQ__EffectiveStartDate__c and CustomEndDate__c from the quoteline
                    System.debug('inside lQuoteLine.get(newQL.Id) ' + lQuoteLine.get(newQL.Id));
                    System.debug('inside lQuoteLine.get(newQL.Id).SBQQ__ProductFamily__c ' + lQuoteLine.get(newQL.Id).SBQQ__ProductFamily__c);
                    System.debug('inside lQuoteLine.get(newQL.Id).SBQQ__RequiredBy__r.SBQQ__ProductFamily__c ' + lQuoteLine.get(newQL.Id).SBQQ__RequiredBy__r.SBQQ__ProductFamily__c);
                    System.debug('inside lQuoteLine.get(newQL.Id).SBQQ__EffectiveStartDate__c ' + lQuoteLine.get(newQL.Id).SBQQ__EffectiveStartDate__c);
                    System.debug('inside lQuoteLine.get(newQL.Id).CustomEndDate__c ' + lQuoteLine.get(newQL.Id).CustomEndDate__c);
                    if(!lQuoteLine.isEmpty()) {
                        if (lQuoteLine.get(newQL.Id).SBQQ__ProductFamily__c == 'Adoption' || lQuoteLine.get(newQL.Id).SBQQ__RequiredBy__r.SBQQ__ProductFamily__c == 'Adoption') {
                            qlSchStartDate = lQuoteLine.get(newQL.Id).SBQQ__EffectiveStartDate__c;
                            qlSchEndDate = lQuoteLine.get(newQL.Id).CustomEndDate__c;
                        }
                    }

                    Line_Item_Subscription_Schedule__c newLISubSch = new Line_Item_Subscription_Schedule__c(Quote_Line__c = newQL.Id,
                            Quote_Subscription_Schedule__c = quoteSubSch.Id,
                            External_Key__c = externalKey,
                            Prorate_Multiplier_Portion__c = 0,
                            Name = newQL.SBQQ__ProductName__c,
                            Start_Date__c = qlSchStartDate,
                            CurrencyIsoCode = newQL.CurrencyIsoCode,
                            Net_Total__c = 0.0,
                            End_Date__c = qlSchEndDate,
                            Recurring_Rev_Product__c = newQL.Recurring_Rev_Product__c
                    );

                    if(newQL.Recurring_Rev_Product__c == false) {
                        newLISubSch.Prorate_Multiplier_Portion__c = 1.0;
                    }
                    else if((quoteSubSch.Subscription_Start_Date__c).addMonths(12) - 1 <= quoteSubSch.Subscription_End_Date__c) { //if at least a full year
                        newLISubSch.Prorate_Multiplier_Portion__c = 1.0; //ASSUMES THAT ALL PRODUCTS HAVE A SUBSCRIPTION TERM OF 12 (Months)
                        if(quoteSubSch.Includes_Partial_Period__c == true) { //factor in partial years if necessary
                            newLISubSch.Prorate_Multiplier_Portion__c += (qlProrateMultiplier - qlProrateMultiplier.intValue());
                            system.debug(newLISubSch.Prorate_Multiplier_Portion__c);
                        }
                    }
                    else if(quoteSubSch.Subscription_Start_Date__c.daysBetween(quoteSubSch.Subscription_End_Date__c) < quoteSubSch.Subscription_Start_Date__c.daysBetween(quoteSubSch.Subscription_Start_Date__c.addMonths(12) -1)) { //If < 1 year
                        newLISubSch.Prorate_Multiplier_Portion__c += qlProrateMultiplier - qlProrateMultiplier.intValue();
                    }
                    //Perform pricing calculations
                    if(newQL.SBQQ__NetTotal__c != null && newLISubSch.Prorate_Multiplier_Portion__c != null && newLISubSch.Prorate_Multiplier_Portion__c != 0) {
                        newLISubSch.Net_Total__c = (newQL.SBQQ__NetTotal__c / qlProrateMultiplier) * newLISubSch.Prorate_Multiplier_Portion__c;
                        //Rounding logic
                        Integer scale = (newQL.CurrencyIsoCode != 'JPY') ? 2 : 0; //JPY rounds to nearest whole.
                        newLISubSch.Net_Total__c = newLISubSch.Net_Total__c.setScale(scale, RoundingMode.HALF_UP);
                        //Handle rounding issues on last segment.
                        Decimal totalNet = qlIdToCurrentNetTotalMap.get(newQL.Id) + newLISubSch.Net_Total__c;
                        if(qlEffEndDate <= quoteSubSch.Subscription_End_Date__c) { //If last sub schedule for this QL, check for rounding issues
                            Decimal delta = newQL.SBQQ__NetTotal__c - totalnet;
                            if(delta != 0) {
                                newLISubSch.Net_Total__c += delta;
                                totalNet = newLISubSch.Net_Total__c;
                            }
                        }
                        qlIdToCurrentNetTotalMap.put(newQL.Id, totalNet);

                    }


                    newSubSchList.add(newLISubSch);
                    qlSubSchExternalKeyList.add(newLiSubSch.External_Key__c);
                }
            }
        }

        if(!quoteIdSet.isEmpty() && !qlSubSchExternalKeyList.isEmpty()) { //Clean up any irrelevant existing schedules
            delete [SELECT Id FROM Line_Item_Subscription_Schedule__c WHERE Quote_Line__c IN :newQuoteLineList AND External_Key__c NOT IN :qlSubSchExternalKeyList];
        }
        if(!newSubSchList.isEmpty()) {
            upsert newSubSchList External_Key__c;
        }
    }

    /*
    * Helper method that creates the quote level subscription schedules (Quote_Subscription_Schedule__c)
    * Takes parameters including two Maps which will be updated referentially (be sure to instantiate those maps prior to calling this method)
    */
    private void createQuoteLevelSubSchedules(Set<Id> quoteIdSet, Map<Id, Date> quoteIdToEarliestStartDateMap, Map<Id, Date> quoteIdToLatestEndDateMap, Map<String, Quote_Subscription_Schedule__c> newSubScheduleMap, Map<Id, List<Quote_Subscription_Schedule__c>> quoteIdToSubScheduleListMap) {
        system.debug('inside createQuoteLevelSubSchedules ' + quoteIdSet + ' ' + quoteIdToEarliestStartDateMap + ' ' + quoteIdToLatestEndDateMap  + ' ' + newSubScheduleMap + ' ' + quoteIdToSubScheduleListMap);
        for(SBQQ__Quote__c quote : [SELECT Id, Name, OwnerId, SBQQ__StartDate__c, SBQQ__SubscriptionTerm__c, SBQQ__EndDate__c, SBQQ__BillingFrequency__c, CurrencyIsoCode, Allow_Stub_Periods__c, Effective_Subscription_Term__c FROM SBQQ__Quote__c WHERE Id IN :quoteIdSet]) {
            Integer stubMonths = (quote.Allow_Stub_Periods__c == false && customSettings.Months_for_Stub_Sub_Schedule__c != null) ? (customSettings.Months_for_Stub_Sub_Schedule__c).intValue() : null;
            //Calculate # segments
            Decimal quoteTerm = (quote.SBQQ__SubscriptionTerm__c != null) ? quote.SBQQ__SubscriptionTerm__c : 12;
            Date quoteStartDate = (quote.SBQQ__StartDate__c != null) ? quote.SBQQ__StartDate__c : Date.today();
            Date quoteEndDate = (quote.SBQQ__EndDate__c != null) ? quote.SBQQ__EndDate__c : quoteStartDate.addMonths(quoteTerm.intValue()) - 1;
            quoteIdToEndDateMap.put(quote.Id, quoteEndDate);
            Date lineStartDate = (quoteIdToEarliestStartDateMap.containsKey(quote.Id)) ? quoteIdToEarliestStartDateMap.get(quote.Id) : quote.SBQQ__StartDate__c;
            Date lineEndDate = (quoteIdToLatestEndDateMap.containsKey(quote.Id)) ? quoteIdToLatestEndDateMap.get(quote.Id) : quote.SBQQ__EndDate__c;
            //Start by normalizing things so that everything has a specific start & end date
            system.debug('inside line dates ' + lineStartDate + ' ' + lineEndDate);
            if(lineStartDate < quoteStartDate) {
                quoteStartDate = lineStartDate;
            }
            if(lineEndDate > quoteEndDate) {
                quoteEndDate = lineEndDate;
            }

            if(quote.SBQQ__BillingFrequency__c == billFreqUpfrontValue) { //Create a single quote-wide schedule if frequency = Upfront
                system.debug('inside billing frequency ' + quote.SBQQ__BillingFrequency__c);
                String externalKey = quote.Name + '-' + yearStringConversion(1);
                Quote_Subscription_Schedule__c newSch = new Quote_Subscription_Schedule__c(Subscription_Start_Date__c = quoteStartDate,
                        Subscription_End_Date__c = quoteEndDate,
                        Year__c = yearStringConversion(1),
                        Quote__c = quote.Id,
                        External_Key__c = externalKey,
                        Proposal_Currency_ISO_Code__c = quote.CurrencyIsoCode,
                        CurrencyIsoCode = quote.CurrencyIsoCode,
                        Includes_Partial_Period__c = false
                );
                newSubScheduleMap.put(externalKey, newSch);
                List<Quote_Subscription_Schedule__c> tmpList = (quoteIdToSubScheduleListMap.containsKey(quote.Id)) ? quoteIdToSubScheduleListMap.get(quote.Id) : new List<Quote_Subscription_Schedule__c>();
                tmpList.add(newSch);
                quoteIdToSubScheduleListMap.put(quote.Id, tmpList);
            }
            else if(quote.SBQQ__BillingFrequency__c == null || quote.SBQQ__BillingFrequency__c == billFreqAnnualValue) { //Annual
                system.debug('inside else if billing frequency ' + quote.SBQQ__BillingFrequency__c);

                //Integer numMos = quoteStartDate.monthsBetween(quoteEndDate + 1);
                //Commented out the above since it doesn't work when start and end date are
                //the same month
                //Sergio Flores
                //Date 08/20/2019
                //W-012856
                //Get the baseline # months, plus the difference in days for any partial year
                Integer numMos = (Integer)quote.Effective_Subscription_Term__c;
                if(numMos == 0) //Sergio Flores
                    numMos = 1;
                Integer schStartMo = (quoteEndDate + 1).month();
                Integer schStartDay = (quoteEndDate + 1).day();
                Date previousEndDate;

                //Build up the subscription schedule headers for each year
                Boolean combineFirstYear = false; //Flag that determines whether the 1st (partial) year should be rolled into the next year
                for(integer yearNum = 0; yearNum < ((Decimal)numMos).divide(12, 0, System.RoundingMode.CEILING); yearNum++) {
                    Date schStartDate;
                    Date schEndDate;
                    if(previousEndDate != null) {
                        //Name: Chris Salgado
                        //Date: 6/29/19
                        //Purpose: Fix Stub Term
                        if(yearNum == 1 && combineFirstYear ) {
                            schStartDate = quoteStartDate;
                        }
                        else{
                            schStartDate = previousEndDate + 1;
                        }
                        schEndDate = previousEndDate.addYears(1);
                    }
                    else {
                        system.debug('inside previous End Date == null');
                        schStartDate = (yearNum == 0) ? quoteStartDate : Date.newInstance(quoteStartDate.year() + yearNum, schStartMo, schStartDay);
                        schEndDate = Date.newInstance(quoteStartDate.year() + 1 + yearNum, quoteEndDate.month(), quoteEndDate.day()); //Typical case
                        system.debug('CSALGADO: ' + schStartDate + ' / ' + schEndDate);
                        system.debug('CSALGADO: ' + quoteStartDate + ' / ' + quoteEndDate);
                        if(yearNum == 0 && (quoteStartDate.month() < quoteEndDate.month() || (quoteStartDate.month() == quoteEndDate.month() && quoteStartDate.day() < quoteEndDate.day()))) {
                            system.debug('inside partial year if ' + quoteStartDate + ' ' + quoteEndDate);
                            schEndDate = Date.newInstance(quoteStartDate.year() + yearNum, quoteEndDate.month(), quoteEndDate.day()); //1st year where 1st year is partial
                        }
                    }
                    previousEndDate = schEndDate;

                    system.debug('Year #' + yearNum + ' with dates of ' + schStartDate + ' - ' + schEndDate + ' and combine 1st yr = ' + combineFirstYear);

                    //If in first year, check is this should be rolled into the next schedule
                    //Ryan Conaghan 7/3/19: added schEndDate < quoteEndDate check to allow for quotes who's entire term is < the stub term.
                    if(yearNum == 0 && stubMonths != null && schEndDate < quoteEndDate && schEndDate < (schStartDate.addMonths(stubMonths) -1)) {
                        combineFirstYear = true;
                    }

                    //Actually create the billing/subscription schedule
                    if(yearNum > 0 || !combineFirstYear) {
                        Integer yearNumToConvert = (combineFirstYear == false) ? yearNum + 1 : yearNum; //If a partial period exists, then the 2nd year (1st full year) becomes the '1st' segment and so on
                        String yearConverted = yearStringConversion(yearNumToConvert);
                        String externalKey = quote.Name + '-' + yearConverted;
                        Quote_Subscription_Schedule__c newSch = new Quote_Subscription_Schedule__c(Subscription_Start_Date__c = schStartDate,
                                Subscription_End_Date__c = schEndDate,
                                Year__c = yearConverted,
                                Quote__c = quote.Id,
                                External_Key__c = externalKey,
                                Proposal_Currency_ISO_Code__c = quote.CurrencyIsoCode,
                                CurrencyIsoCode = quote.CurrencyIsoCode,
                                Includes_Partial_Period__c = false
                        );
                        if(yearNum == 1 && combineFirstYear) {
                            newSch.Includes_Partial_Period__c = true;
                        }
                        newSubScheduleMap.put(externalKey, newSch);
                        List<Quote_Subscription_Schedule__c> tmpList = (quoteIdToSubScheduleListMap.containsKey(quote.Id)) ? quoteIdToSubScheduleListMap.get(quote.Id) : new List<Quote_Subscription_Schedule__c>();
                        tmpList.add(newSch);
                        quoteIdToSubScheduleListMap.put(quote.Id, tmpList);
                    }
                }
            }
        }
    }

    /*
    * Helper method that simply converts the year number (eg 1) to a string
    *   for the Year__c field on Subscription Schedule (1st/2nd/3rd/4th/5th/6th/7th/8th/9th/10th)
    */
    private string yearStringConversion(Integer yearNum) {
        String formattedYear = yearNum.format();
        Integer modYear = Math.mod(yearNum, 10);
        if(modYear == 1) { //1st/11th/21st/31st etc
            formattedYear = (yearNum == 11) ? formattedYear + 'th' : formattedYear + 'st';
        }
        else if(modYear == 2) {
            formattedYear = (yearNum == 12) ? formattedYear + 'th' : formattedYear + 'nd';
        }
        else if(modYear == 3) {
            formattedYear = (yearNum == 13) ? formattedYear + 'th' : formattedYear + 'rd';
        }
        else { //modYear 4-0
            formattedYear = formattedYear + 'th';
        }

        return formattedYear;
    }
}