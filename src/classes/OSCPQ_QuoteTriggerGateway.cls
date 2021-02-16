public with sharing class OSCPQ_QuoteTriggerGateway {
    //Hemendra 05/28/2019
    public static Map<Id, List<Custom_Partner__c>> getOppIdToPartnerMap(Set<Id> oppIds) {
        Map<Id, List<Custom_Partner__c>> oppIdToPartnerMap = new Map<Id, List<Custom_Partner__c>>();

        for (Opportunity opp : [SELECT Id,
        (SELECT Id, AccountToId__c, OpportunityId__c, Role__c,
                IsPrimary__c FROM Custom_Partners__r)
        FROM Opportunity WHERE Id IN :oppIds]) {

            if (!opp.Custom_Partners__r.isEmpty()) {
                oppIdToPartnerMap.put(opp.Id, opp.Custom_Partners__r);
            }
        }

        return oppIdToPartnerMap;
    }



    /**
     * W-009835
     * Add Proposal ID to Opps
     *
     * @param {Set<Id>} oppIds - Opportunity Ids.
     * @description Update the Primary Proposal field on Opportunity. 
     * @author Hemendra Singh Rajawat
     * @since January 16, 2019
     */
    public static List<Opportunity> addPrimaryQuote(Set<Id> opportunityIdsStampPrimaryQuote) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for(SBQQ__Quote__c quote : [SELECT Id, SBQQ__Opportunity2__c
        FROM SBQQ__Quote__c
        WHERE SBQQ__Primary__c = TRUE
        AND SBQQ__Opportunity2__c IN : opportunityIdsStampPrimaryQuote
        ORDER BY LastModifiedDate DESC])
        {
            Opportunity o = new Opportunity();
            o.Id = quote.SBQQ__Opportunity2__c;
            o.SBQQ__PrimaryQuote__c = quote.Id;
            oppsToUpdate.add(o);
        }

        return oppsToUpdate;
    }

    //Sergio Flores
    //Date: 05/30/2019
    //W-012126
    //this is to remove the primary quote from the opportunity
    public static List<Opportunity> removePrimaryQuote(Set<Id> opportunityIdsUnStampPrimaryQuote) {
        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        for(Opportunity opp : [SELECT Id, SBQQ__PrimaryQuote__c
        FROM Opportunity
        WHERE Id IN : opportunityIdsUnStampPrimaryQuote])
        {
            opp.SBQQ__PrimaryQuote__c = null;
            oppsToUpdate.add(opp);
        }

        return oppsToUpdate;
    }

    //Sergio Flores
    //Date: 05/13/2019
    //W-011795
    public static void updatePilotOpportunity(Set<Id> quoteIds) {
        //Check quotes line if there is an adoption
        //If there is then add the opportunity to opportunity list
        List<SBQQ__QuoteLine__c> quoteLinesWithAdoption = [SELECT Id, SBQQ__Quote__r.SBQQ__Opportunity2__c
        FROM SBQQ__QuoteLine__c
        WHERE SBQQ__Quote__c IN : quoteIds
        AND SBQQ__ProductFamily__c = 'Adoption'];

        List<Opportunity> oppsToUpdate = new List<Opportunity>();

        if(!quoteLinesWithAdoption.isEmpty())
        {
            Set<Id> oppIds = new Set<Id>();

            for(SBQQ__QuoteLine__c ql : quoteLinesWithAdoption)
            {
                if(!oppIds.contains(ql.SBQQ__Quote__r.SBQQ__Opportunity2__c))
                {
                    Opportunity o = new Opportunity();
                    o.Id = ql.SBQQ__Quote__r.SBQQ__Opportunity2__c;
                    o.Pilot__c = true;
                    oppsToUpdate.add(o);
                    oppIds.add(o.Id);
                }

            }
        }

        if(!oppsToUpdate.isEmpty())
        {
            try
            {
                update oppsToUpdate;
                System.debug('oppsToUpdate' + oppsToUpdate);
            }
            catch(Exception ex)
            {
                System.debug('inside catch exception');
                Trigger.new[0].addError(ex.getMessage());
            }
        }
    }



    //Sergio Flores
    //Date: 05/13/2019
    //W-011832
    public static void updateShipToANDBillTo(Set<Id> primaryContactIds, Set<Id> accountIds, List<SBQQ__Quote__c> newQuoteList) {
        System.debug('inside update shipToAndBillTo ' + primaryContactIds + accountIds + newQuoteList);
        //Need to query the primary contact
        Map<Id,Contact> contactIdToContactMap = new Map<Id,Contact>([SELECT Id, Account.Name, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry, pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c, pw_ccpro__MailingCountryLookup__r.Price_Book__c
        FROM Contact WHERE Id IN: primaryContactIds]);


        for(SBQQ__Quote__c quote : newQuoteList)
        {
            Contact primaryContact = contactIdToContactMap.get(quote.SBQQ__PrimaryContact__c);
            if(primaryContact !=null )
            {
                //Updating from the Primary Contact Information
                System.debug('Inside primaryContact ' + primaryContact);
                quote.SBQQ__ShippingName__c = primaryContact.Account.Name;
                quote.SBQQ__ShippingStreet__c = primaryContact.MailingStreet;
                quote.SBQQ__ShippingCity__c = primaryContact.MailingCity;
                quote.SBQQ__ShippingState__c = primaryContact.MailingState;
                quote.SBQQ__ShippingPostalCode__c = primaryContact.MailingPostalCode;
                quote.SBQQ__ShippingCountry__c = primaryContact.MailingCountry;

                quote.Ship_to_Price_Book__c = primaryContact.pw_ccpro__MailingCountryLookup__r.Price_Book__c ;
                quote.Ship_To_Currency__c = primaryContact.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c;
            }
            else
            {
                System.debug('Inside primaryContact else ' + primaryContact);
                //Updating from the Primary Contact Information
                //There is no primary contact so must be null
                quote.SBQQ__ShippingName__c = null;
                quote.SBQQ__ShippingStreet__c = null;
                quote.SBQQ__ShippingCity__c = null;
                quote.SBQQ__ShippingState__c = null;
                quote.SBQQ__ShippingPostalCode__c = null;
                quote.SBQQ__ShippingCountry__c = null;
            }
        }


        //Need to query the Account
        Map<Id,Account> accountIdToAccountMap = new Map<Id,Account>([SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry
        FROM Account
        WHERE Id IN: accountIds]);


        for(SBQQ__Quote__c quote : newQuoteList)
        {
            Account account = accountIdToAccountMap.get(quote.BillToAccount__c);

            if(account !=null )
            {
                //Updating from the Account Bill To Information
                System.debug('Inside account ' + account);
                quote.SBQQ__BillingName__c = account.Name;
                quote.SBQQ__BillingStreet__c = account.BillingStreet;
                quote.SBQQ__BillingCity__c = account.BillingCity;
                quote.SBQQ__BillingState__c = account.BillingState;
                quote.SBQQ__BillingPostalCode__c = account.BillingPostalCode;
                quote.SBQQ__BillingCountry__c = account.BillingCountry;
            }
            else
            {
                //Updating from the Account Bill To Information
                System.debug('Inside account else' + account);
                quote.SBQQ__BillingName__c = null;
                quote.SBQQ__BillingStreet__c = null;
                quote.SBQQ__BillingCity__c = null;
                quote.SBQQ__BillingState__c = null;
                quote.SBQQ__BillingPostalCode__c = null;
                quote.SBQQ__BillingCountry__c = null;
            }
        }

    }

    //Sergio Flores
    //Date: 06/10/2019
    //W-012227
    public static void stampOnInsertFields(Set<Id> oppIdSet, List<SBQQ__Quote__c> newQuoteList) {

        Map<Id,Opportunity> oppIdToOppMap = new Map<Id,Opportunity>([SELECT Id, SBQQ__PrimaryQuote__c, Contract_Start_Date__c, Contract_End_Date__c, Term_in_Months__c, SBQQ__RenewedContract__r.StartDate, SBQQ__RenewedContract__r.ContractTerm, Type, AdoptionBundle__c, Original_Close_Date__c, SBQQ__RenewedContract__r.EndDate
        FROM Opportunity
        WHERE Id IN : oppIdSet]);

        System.debug('Inside stampOnInsertFields ' + oppIdToOppMap);

        for(SBQQ__Quote__c quote : newQuoteList)
        {
            Opportunity oppRelatedToQuote = oppIdToOppMap.get(quote.SBQQ__Opportunity2__c);

            System.debug('Inside stampPrimaryOnFirstPurchasedQuote loop ' + oppRelatedToQuote + ' quote ' + quote);

            if(oppRelatedToQuote != null)
            {
                if(quote.Quote_Type__c != 'Evaluation' && oppRelatedToQuote.SBQQ__PrimaryQuote__c == null)
                {
                    System.debug('Inside stampOnInsertFields primary' + oppRelatedToQuote);
                    //This means there is no quotes that are purchase for this opportunity
                    //so this is the first purchase quote and it must be marked primary
                    quote.SBQQ__Primary__c = true;
                }

                //Sergio Flores
                //Date: 06/13/2019
                //W-012192
                //Updated by: Sharma Nemani | W-012715 | 01/24/2020 - Added "quote.Purchase_Type__c != 'Co-term' &&" to the line below" .
                /**
                 * @author Sergio Flores
                 * @date 08/04/2020
                 * @description need to update on how start date is being populated
                 * @workItems W-006037
                */
                if( (oppRelatedToQuote.Type == 'NB' || oppRelatedToQuote.Type == 'NBEC') && oppRelatedToQuote.Contract_Start_Date__c !=null && oppRelatedToQuote.Contract_End_Date__c !=null && oppRelatedToQuote.Term_in_Months__c !=null)
                {
                    System.debug('Inside stampOnInsertFields ' + oppRelatedToQuote);
                    quote.SBQQ__StartDate__c = oppRelatedToQuote.Contract_Start_Date__c;
                    //quote.SBQQ__EndDate__c = oppRelatedToQuote.Contract_End_Date__c;
                    quote.SBQQ__SubscriptionTerm__c = oppRelatedToQuote.Term_in_Months__c;
                }
                //Stamp start date for ECUR non adoption
                if( oppRelatedToQuote.Type == 'ECUR' && oppRelatedToQuote.SBQQ__RenewedContract__r.EndDate != null && oppRelatedToQuote.SBQQ__RenewedContract__r.ContractTerm !=null && oppRelatedToQuote.AdoptionBundle__c == null)
                {
                    System.debug('Inside stampOnInsertFields ' + oppRelatedToQuote);
                    quote.SBQQ__StartDate__c = oppRelatedToQuote.SBQQ__RenewedContract__r.EndDate.addDays(1);
                    quote.SBQQ__SubscriptionTerm__c = oppRelatedToQuote.SBQQ__RenewedContract__r.ContractTerm;
                }
                //Stamp start date for ECUR for adoption with original close date
                else if( oppRelatedToQuote.Type == 'ECUR' && oppRelatedToQuote.Original_Close_Date__c != null && oppRelatedToQuote.AdoptionBundle__c != null)
                {
                    System.debug('Inside stampOnInsertFields ' + oppRelatedToQuote);
                    quote.SBQQ__StartDate__c = oppRelatedToQuote.Original_Close_Date__c.addDays(1);
                    quote.SBQQ__SubscriptionTerm__c = 12;
                }

            }


        }

    }

    //Sergio Flores
    //Date: 06/13/2019
    //W-012192
    //This is to update the subscription dates on the opportunity
    public static void updateSubscriptionOppDates(Map<Id, SBQQ__Quote__c> oppToPrimaryQuoteMap) {

        List<Opportunity> oppList = [SELECT Id, Contract_Start_Date__c, Contract_End_Date__c
        FROM Opportunity
        WHERE Id IN : oppToPrimaryQuoteMap.keySet()];

        System.debug('inside updateSubscriptionOppDates ' + oppList);

        List<Opportunity> oppListToUpdate = new List<Opportunity>();

        if(!oppList.isEmpty())
        {
            for(Opportunity opp : oppList)
            {
                SBQQ__Quote__c primaryQuote = oppToPrimaryQuoteMap.get(opp.Id);

                if(primaryQuote !=null)
                {
                    opp.Contract_Start_Date__c = primaryQuote.SBQQ__StartDate__c;
                    opp.Contract_End_Date__c = primaryQuote.CustomEndDate__c;
                    oppListToUpdate.add(opp);
                }
            }
        }

        try
        {
            if(!oppListToUpdate.isEmpty())
            {
                update oppListToUpdate;
            }
        }
        catch(Exception ex)
        {
            System.debug('inside catch exception');
            Trigger.new[0].addError(ex.getMessage());
        }

    }

    public static void deleteLGAndLA(Set<Id> ordergroupIds){
        List<License_Administrator__c> laToDelete = new List<License_Administrator__c>();
        List<Order_Group__c> lgToDelete = new List<Order_Group__c>();

        for(Order_Group__c LG : [SELECT Id, (SELECT Id FROM Quotes__r),
        (SELECT Id FROM License_Administrators__r)
        FROM Order_Group__c WHERE Id IN : ordergroupIds])
        {
            if(LG.Quotes__r.isEmpty()){
                lgToDelete.add(LG);
                laToDelete.addAll(LG.License_Administrators__r);
            }
        }

        if(!laToDelete.isEmpty()){
            delete laToDelete;
        }
        if(!lgToDelete.isEmpty()){
            delete lgToDelete;
        }
    }


    /*public static void updateOpportunityRecordType(Set<Id> oppIds) {
        List<Opportunity> oppList = new List<Opportunity>();
        Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partner Opportunity').getRecordTypeId();
        Id altxRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Alteryx Record Type').getRecordTypeId();

        if (!oppIds.isEmpty()) {
            for (Opportunity opp : [SELECT ID, RecordTypeId, (SELECT ID FROM Custom_Partners__r)
                                    FROM Opportunity WHERE Id In : oppIds])
            {
                if(!opp.Custom_Partners__r.isEmpty()){
                    if(opp.RecordTypeId != partnerRecordTypeId){
                        opp.RecordTypeId = partnerRecordTypeId;
                        oppList.add(opp);
                    }
                } else {
                    if(opp.RecordTypeId != altxRecordTypeId){
                        opp.RecordTypeId = altxRecordTypeId;
                        oppList.add(opp);
                    }
                }
            }
        }
        if (!oppList.isEmpty()) {
            update oppList;
        }
    }
    */

    /*
    * Name: Chris Salgado
    * Date: 5/2/19
    * Helper Method that updates Quote Lines with Charge Type and Optional
    */
    public static void bundleQuoteLines(Set<Id> acceptedQuotesIdSet) {
        System.debug('** CSALGADO ** In OSCPQ_QuoteTriggerGateway. bundleQuoteLines');

        List<SBQQ__QuoteLine__c> qLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        Map<Decimal, SBQQ__QuoteLine__c> numberedQuoteLines = new Map<Decimal, SBQQ__QuoteLine__c>();
        Map<Id, SBQQ__QuoteLine__c> qlIdToQuoteLines = new Map<Id, SBQQ__QuoteLine__c>(); //Name: Chris Salgado Date: 5/4/20 Purpose: W-005147

        SBQQ__Quote__c Quote = [
                SELECT Id, (
                        SELECT Id,
                                SBQQ__Product__r.NS_Integration_Logic__c,
                                SBQQ__Product__r.Logical_Bundle__c,
                                SBQQ__Product__r.Name,
                                SBQQ__ProductOption__c,
                                SBQQ__ProductFamily__c,
                                SBQQ__Number__c,
                                SBQQ__OptionLevel__c,
                                SBQQ__Bundle__c,
                                SBQQ__Bundled__c,
                                Recurring_Rev_Product__c,
                                Has_Options__c,
                                Logical_Bundle__c,
                                SBQQ__RequiredBy__c
                        FROM SBQQ__LineItems__r
                )
                FROM SBQQ__Quote__c
                WHERE Id IN :acceptedQuotesIdSet
                LIMIT 1
        ];
        System.debug('inside bundle quotes ' + Quote);

        //Create Quote Line map by Number sequence
        for (SBQQ__QuoteLine__c qLine : Quote.SBQQ__LineItems__r) {
            numberedQuoteLines.put(qLine.SBQQ__Number__c, qLine);
            qlIdToQuoteLines.put(qLine.Id, qLine); //Name: Chris Salgado Date: 5/4/20 Purpose: W-005147
        }
        System.debug('inside bundle quotes numberedQuoteLines' + numberedQuoteLines);

        Boolean adoption = false;
        String bundleName = '';
        String parentQL = ''; //Name: Chris Salgado Date: 5/4/20 Purpose: W-005147
        String NSLogic = '';
        String lastLogicalBundleId = '';
        Boolean inLogicalBundle = false;
        Boolean inBundle = false;
        Integer lineCounter = 1;
        Integer seqCounter = 1;
        for (Integer i = 1; i < numberedQuoteLines.size() + 1; i++) {
            SBQQ__QuoteLine__c quoteL = numberedQuoteLines.get(i);
            //NEW LOGIC
            //Logical Header
            System.debug('inside bundle quotes quoteL: ' + quoteL);
            if (quoteL.SBQQ__Product__r.Logical_Bundle__c) {
                //Name: Chris Salgado Date: 4/21/20 Purpose: W-005147
                if (i < numberedQuoteLines.size()
                        && numberedQuoteLines.get(i + 1).SBQQ__Bundle__c) {
                    inLogicalBundle = false;
                    bundleName = '';
                } else {
                    bundleName = quoteL.SBQQ__Product__r.Name;
                    inLogicalBundle = true;
                }
                lastLogicalBundleId = quoteL.Id;
                lineCounter--;
                seqCounter = 1;
                SBQQ__QuoteLine__c qlin = createUpdateQuoteLine(quoteL, lineCounter, seqCounter);
                qlin.Has_Options__c = true;
                qlin.Logical_Bundle__c = true;
                qlin.Bundle_Header__c = bundleName;
                qLinesToUpdate.add(qlin);
                lineCounter++;

                //Not Logical Header
                //In Logical Bundle
            } else if (inLogicalBundle) {
                seqCounter = 1;
                SBQQ__QuoteLine__c qlin = createUpdateQuoteLine(quoteL, lineCounter, seqCounter);
                qlin.Logical_Bundle__c = true;
                qlin.Bundle_Header__c = bundleName;
                qLinesToUpdate.add(qlin);
                lineCounter++;
                //Name: Chris Salgado Date: 4/21/20 Purpose: W-005147
                if (i < numberedQuoteLines.size()
                        && (numberedQuoteLines.get(i + 1).SBQQ__ProductOption__c == null || numberedQuoteLines.get(i + 1).SBQQ__Bundle__c)) {
                    inLogicalBundle = false;
                    bundleName = '';
                }

                //Not Logical Bundle Option
                //In Bundle
            } else if (inBundle && quoteL.SBQQ__ProductOption__c != null) {
                //Product Option not blank
                //if (quoteL.SBQQ__ProductOption__c != null) {
                seqCounter++;
                SBQQ__QuoteLine__c qlin = createUpdateQuoteLine(quoteL, lineCounter, seqCounter);
                qlin.NS_Integration_Logic__c = NSLogic;
                qlin.Bundle_Header__c = bundleName;
                qlin.Adoption__c = adoption;
                qLinesToUpdate.add(qlin);
                //Name: Chris Salgado Date: 4/21/20 Purpose: W-005147
                if (i < numberedQuoteLines.size()
                        && (numberedQuoteLines.get(i + 1).SBQQ__ProductOption__c == null
                        || /*(numberedQuoteLines.get(i + 1).SBQQ__Bundle__c &&*/ findParentQL(numberedQuoteLines.get(i + 1).Id, qlIdToQuoteLines) != parentQL)) //Name: Chris Salgado Purpose: W-005641
                {
                    inBundle = false;
                    NSLogic = '';
                    bundleName = '';
                    parentQL = ''; //Name: Chris Salgado Date: 5/4/20 Purpose: W-005147
                    adoption = false;
                    lineCounter++;
                    //If the QL Parent is Logical Bundle then make inLogicalBundle = true //Name: Chris Salgado Date: 6/ 11/ 20Purpose: W-005641
                    System.debug('Before Logical Bundle check: ' + findGrandParentQL(numberedQuoteLines.get(i + 1).Id, qlIdToQuoteLines) + ' = ' + lastLogicalBundleId);
                    if(i < numberedQuoteLines.size()
                            && numberedQuoteLines.get(i + 1).SBQQ__ProductOption__c != null && !numberedQuoteLines.get(i + 1).SBQQ__Bundle__c
                            && findGrandParentQL(numberedQuoteLines.get(i + 1).Id, qlIdToQuoteLines) == lastLogicalBundleId) {
                        bundleName = quoteL.SBQQ__Product__r.Name;
                        inLogicalBundle = true;
                    }
                }
                //}

                //Not Bundle Option
                //Bundle Header
            } else if (!inBundle && quoteL.SBQQ__Bundle__c) {
                if (quoteL.SBQQ__ProductFamily__c == 'Adoption') {
                    adoption = true;
                }
                bundleName = quoteL.SBQQ__Product__r.Name;
                parentQL = quoteL.Id; //Name: Chris Salgado Date: 5/4/20 Purpose: W-005147
                System.debug('**CSALGADO** ParentQL: ' + parentQL);
                NSLogic = quoteL.SBQQ__Product__r.NS_Integration_Logic__c;
                seqCounter = 1;
                SBQQ__QuoteLine__c qlin = createUpdateQuoteLine(quoteL, lineCounter, seqCounter);
                qlin.Has_Options__c = true;
                qlin.NS_Integration_Logic__c = NSLogic;
                qlin.Bundle_Header__c = bundleName;
                qlin.Adoption__c = adoption;
                qLinesToUpdate.add(qlin);
                inBundle = true;

                //Not Bundle Header
                //Stand Alone Product
            } else {
                seqCounter = 1;
                SBQQ__QuoteLine__c qlin = createUpdateQuoteLine(quoteL, lineCounter, seqCounter);
                qLinesToUpdate.add(qlin);
                lineCounter++;
            }
        }

        if (qLinesToUpdate.size() > 0) {
            SBQQ.TriggerControl.disable();
            update qLinesToUpdate;
            SBQQ.TriggerControl.enable();
        }
    }

    private static SBQQ__QuoteLine__c createUpdateQuoteLine(SBQQ__QuoteLine__c quoteL, Integer lineCounter, Integer seqCounter){
        SBQQ__QuoteLine__c qlin = new SBQQ__QuoteLine__c(Id = quoteL.Id);
        qlin.Line_Number__c = lineCounter;
        qlin.Sequence__c = seqCounter;
        return qlin;
    }

    //Name: Chris Salgado Date: 5/4/20 Purpose: W-005147
    private static String findParentQL(Id qlToSearch, Map<Id, SBQQ__QuoteLine__c> qlIdToQuoteLines){
        String parentQLId = '';
        Boolean hasRB = true;
        SBQQ__QuoteLine__c currentQL = qlIdToQuoteLines.get(qlToSearch);

        while(hasRB == true){
            if(currentQL.SBQQ__RequiredBy__c == null){
                if(!currentQL.SBQQ__Product__r.Logical_Bundle__c){
                    parentQLId = currentQL.Id;
                }
                hasRB = false;
            } else{
                parentQLId = currentQL.Id;
                currentQL = qlIdToQuoteLines.get(currentQL.SBQQ__RequiredBy__c);
            }
        }

        System.debug('**CSALGADO** ParentQLId: ' + parentQLId);
        return parentQLId;
    }

    //Name: Chris Salgado Date: 6/12/29 Purpose: W-005641
    private static String findGrandParentQL(Id qlToSearch, Map<Id, SBQQ__QuoteLine__c> qlIdToQuoteLines){
        String gParentQLId = '';
        Boolean hasRB = true;
        SBQQ__QuoteLine__c currentQL = qlIdToQuoteLines.get(qlToSearch);

        while(hasRB == true){
            if(currentQL.SBQQ__RequiredBy__c == null){
                gParentQLId = currentQL.Id;
                hasRB = false;
            } else{
                gParentQLId = currentQL.Id;
                currentQL = qlIdToQuoteLines.get(currentQL.SBQQ__RequiredBy__c);
            }
        }

        System.debug('**CSALGADO** GrandParentQLId: ' + gParentQLId);
        return gParentQLId;
    }


    /*public static boolean calculateRecurring(SBQQ__QuoteLine__c qline){
        //Exclude some Product Family's from getting Recurring Revenue Product = true
        if (qLine.SBQQ__ProductFamily__c != 'Events' && qLine.SBQQ__ProductFamily__c != 'Professional Services' && qLine.SBQQ__ProductFamily__c != 'Customer Support' && qLine.SBQQ__ProductFamily__c != 'Adoption') {
            return true;
        }else{
            return false;
        }
    }*/

    /*
    * Helper method that simply converts the year number (eg 1) to a string
    *   for the Year__c field on Subscription Schedule (1st/2nd/3rd/4th/5th/6th/7th/8th/9th/10th)
    */
    public static String yearStringConversion(Integer yearNum) {
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

    /*
    * Name: Chris Salgado
    * Date: 4/30/19
    * Helper Method that prepares and sends the Quotes to QuoteQueueable to create License Products and NetSuite Sales Orders
    */

    //Name: Chris Salgado Date: 7/8/19 Purpose: adding Rerun_NSSO_Creation__c to manually execute
    public static void getQuoteReadyForQueueable(List<SBQQ__Quote__c> newQuoteList, Map<Id, SBQQ__Quote__c> oldQuoteMap) {
        Set<Id> NetsuiteQuoteIds = new Set<Id>();
        List<SBQQ__Quote__c> updateQuotes = new List<SBQQ__Quote__c>();
        String createProcess;

        //Check for Quote Accepted
        for(SBQQ__Quote__c newQuote : newQuoteList) {
            if (oldQuoteMap.get(newQuote.Id).SBQQ__Status__c != 'Accepted' && newQuote.SBQQ__Status__c == 'Accepted') {
                NetsuiteQuoteIds.add(newQuote.Id);
                createProcess = 'Standard';
            }
            else if(newQuote.Rerun_NSSO_Creation__c && newQuote.NetSuite_Sales_Order_Number__c == null){
                NetsuiteQuoteIds.add(newQuote.Id);
                createProcess = 'Rerun NSSO';
            }
            else if(newQuote.Rerun_LP_Creation__c){
                NetsuiteQuoteIds.add(newQuote.Id);
                createProcess = 'Rerun LP';
            }

            if(newQuote.Rerun_NSSO_Creation__c || newQuote.Rerun_LP_Creation__c){
                SBQQ__Quote__c upQuote = new SBQQ__Quote__c(Id = newQuote.Id, Rerun_NSSO_Creation__c = false, Rerun_LP_Creation__c = false);
                updateQuotes.add(upQuote);
            }
        }

        //Queue QuoteQueueable Job
        if(!NetsuiteQuoteIds.isEmpty() && Recursionhandler.IsProposalTriggerExecuted == false)
        {
            Recursionhandler.IsProposalTriggerExecuted = true;
            QuoteQueueable executeCreateLicProd = new QuoteQueueable(NetsuiteQuoteIds, createProcess);
            Id jobID = System.enqueueJob(executeCreateLicProd);
        }

        //Date: 7/8/19 Purpose: Quote Update to un-check Recalculate NSSO Creation
        if(!updateQuotes.isEmpty()){
            try{
                update updateQuotes;
            }
            catch(Exception ex){
                System.debug('inside catch exception');
                Trigger.new[0].addError(ex.getMessage());
            }
        }
    }

    /*
     * Helper method that actually performs the twin mapping
     */
    public static void twinMapToOpp(List<SBQQ__Quote__c> newQuoteList, CPQ_Setting__mdt settings){
        List<SBQQ__Quote__c> quotesToMap = new List<SBQQ__Quote__c>();
        if(settings.TwinMapping_PrimaryQuoteToOpp__c == 'ALWAYS' || settings.TwinMapping_PrimaryQuoteToOpp__c == 'ON_ACCEPTED') {
            for(SBQQ__Quote__c newQuote : newQuoteList){
                if(newQuote.SBQQ__Primary__c == true &&
                        (settings.TwinMapping_PrimaryQuoteToOpp__c == 'ALWAYS' ||
                                (settings.TwinMapping_PrimaryQuoteToOpp__c == 'ON_ACCEPTED' && newQuote.SBQQ__Status__c == 'Accepted'))) {
                    quotesToMap.add(newQuote);
                }
            }
        }

        if(!quotesToMap.isEmpty()){
            OSCPQ_Utils.twinMapFieldsPush(newQuoteList, 'Opportunity', 'SBQQ__Opportunity2__c', false);
        }
    }

    //Sergio Flores
    //Date: 07/08/2019
    //W-012477
    public static void stampRequiredFieldsOnInsert(Map<Id, Contract> renewedContractToOppMap, List<SBQQ__Quote__c> newQuoteList){
        System.debug('inside stampContractStartDate ' + renewedContractToOppMap);

        for(SBQQ__Quote__c quote : newQuoteList)
        {
            Contract contract;
            if (quote.OSCPQ_Amended_Contract__c != null) {
                contract = renewedContractToOppMap.get(quote.OSCPQ_Amended_Contract__c);
            }

            if(contract != null)
            {
                if(contract.SBQQ__Opportunity__r.Type == 'NBEC' || contract.SBQQ__Opportunity__r.Type == 'ECUR' || contract.SBQQ__Opportunity__r.Type == 'NB')
                {
                    System.debug('contract ' + contract + ' quote  ' + quote);
                    quote.SBQQ__PrimaryContact__c = contract.SBQQ__Opportunity__r.Primary_Contact__c;
                    quote.MLA_Option__c = contract.SBQQ__Quote__r.MLA_Option__c;
                    //Commented for 2019-12-05 Release
                    quote.MLA_Effective_Date__c = contract.SBQQ__Quote__r.MLA_Effective_Date__c; //SF 11/26/2019 W-013628
                    quote.PaymentMethod__c = contract.SBQQ__Quote__r.PaymentMethod__c;
                    quote.Tax_Reg_Number__c = contract.SBQQ__Quote__r.Tax_Reg_Number__c;
                    quote.SBQQ__BillingFrequency__c = contract.SBQQ__Quote__r.SBQQ__BillingFrequency__c;
                    quote.Is_Purchase_Order_Required__c = contract.SBQQ__Quote__r.Is_Purchase_Order_Required__c;
                    quote.SBQQ__PaymentTerms__c = contract.SBQQ__Quote__r.SBQQ__PaymentTerms__c;
                    quote.Payment_Schedule__c = contract.SBQQ__Quote__r.Payment_Schedule__c;
                    quote.Purchase_Type__c = 'Upsell Co-term';
                    quote.RecordTypeId = System.Label.Quote_Default_RecordType;
                }


            }
        }
    }

    //Chris Salgado
    //Date: 07/19/2019
    //W-012608
    public static void stampAmendmentContract(Set<Id> quoteIds, Map<Id, SBQQ__Quote__c> quoteIdToQuoteAmenedMap){

        //Map the Quote to the Related Contract
        /*Map<Id, SBQQ__Quote__c> quoteToContractMap = new Map<Id, SBQQ__Quote__c>();
        for( SBQQ__Quote__c quo : [SELECT Id, SBQQ__Type__c, OSCPQ_Amended_Contract__c, OSCPQ_Amended_Contract__r.ContractNumber, Related_Contract__c  FROM SBQQ__Quote__c WHERE Id IN :quotes]){
            if(quo.SBQQ__Type__c == 'Amendment' && quo.OSCPQ_Amended_Contract__c != null && quo.Related_Contract__c == null){
                quoteToContractMap.put(quo.Id, quo);
            }
        }

        //Update the Quote Related Contract
        for(SBQQ__Quote__c quot : quotes){
            if(quoteToContractMap.containsKey(quot.Id)){
                quot.Related_Contract__c = quoteToContractMap.get(quot.Id).OSCPQ_Amended_Contract__c;
                quot.Related_Contract_Number__c = quoteToContractMap.get(quot.Id).OSCPQ_Amended_Contract__r.ContractNumber;
            }
        }*/

        for(SBQQ__Quote__c quote : [SELECT Id, SBQQ__Type__c, OSCPQ_Amended_Contract__c, OSCPQ_Amended_Contract__r.ContractNumber, Related_Contract__c  FROM SBQQ__Quote__c WHERE Id IN :quoteIds])
        {
            SBQQ__Quote__c originalQuote = quoteIdToQuoteAmenedMap.get(quote.Id);
            originalQuote.Related_Contract__c = quote.OSCPQ_Amended_Contract__c;
            originalQuote.Related_Contract_Number__c = quote.OSCPQ_Amended_Contract__r.ContractNumber;
        }


    }

    //Chris Salgado
    //Date: 08/14/2019
    //W-012807
    //Update the Tax Reg Number on the Quote from the Account
    public static void stampTaxRegNumber( Set<Id> acctsFromQuotes, List<SBQQ__Quote__c> newQuotes){
        Map<Id, String>  acctsWithTaxNum = new Map<Id, String>();
        //Query and Iterate through the Source Field and the Map the Matching Field to the Source Field.
        for(Account acct : [SELECT Id, Tax_Reg_Number__c FROM Account WHERE Tax_Reg_Number__c != '' AND Id IN :acctsFromQuotes]) {
            acctsWithTaxNum.put(acct.Id, acct.Tax_Reg_Number__c);
        }
        //Iterate through Trigger.new and update the Target Field with the Source Field value from the Map
        for(SBQQ__Quote__c quot : newQuotes){
            if(acctsWithTaxNum.containsKey(quot.SBQQ__Account__c)){
                quot.Tax_Reg_Number__c = acctsWithTaxNum.get(quot.SBQQ__Account__c);
            }
        }
    }

    //Name: Chris Salgado
    //Date: 5/13/19
    //Purpose: Updates a static list of Quotes to Resend to Boomi
    public static void quotes2ResendToBoomi(Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap) {
        try{
            List<License_Product__c> lps2UpdateList = new List<License_Product__c>();

            //Eddie Wong || 09/16/2020 || W-005994 || To resend License Product Update to Boomi

            List<License_Product_Update__c> licProdUpdate2UpdateList = new List<License_Product_Update__c>();
            List<License_Product_Update__c> licProdUpdateList = [SELECT Id,Dell_Boomi_In_Progress__c,Integration_Error__c,Dell_Boomi_Received__c,Quote__r.Resend_To_Boomi__c
                                                                FROM License_Product_Update__c
                                                                WHERE Update_Success__c = false
                                                                AND Quote__c IN :quoteIdToQuoteMap.keySet()];


            Integer size = 0;
            for(SBQQ__Quote__c q : quoteIdToQuoteMap.values())
            {
                size = 1 + size;
            }
            if(size==1){
                List<License_Product__c> licProds2Update = [SELECT Id, Dell_Boomi_In_Progress__c, Integration_Error__c, Dell_Boomi_Received__c, Quote__r.Resend_To_Boomi__c
                FROM License_Product__c
                WHERE Activation_Id__c = NULL
                AND Quote__c IN: quoteIdToQuoteMap.keySet()];

                System.debug('LPs to Update List' + licProds2Update);
                //Update all the LP's that need to be resent to boomi
                for(License_Product__c lp2u : licProds2Update)
                {

                    System.debug('inside updating LPs');
                    lp2u.Dell_Boomi_In_Progress__c = false;
                    lp2u.Integration_Error__c = null;
                    lp2u.Dell_Boomi_Received__c = null;
                    lp2u.Resend_To_Boomi__c = true;
                    lps2UpdateList.add(lp2u);
                    ResendToBoomiList.licProdList2Update(lps2UpdateList);
                }

                //Eddie Wong || 09/16/2020 || W-005994 || To resend License Product Update to Boomi
                if(!licProdUpdateList.isEmpty()) {
                    for (License_Product_Update__c lpu2u : licProdUpdateList) {
                        System.debug('inside updating LPUs = ' + lpu2u);
                        lpu2u.Dell_Boomi_In_Progress__c = false;
                        lpu2u.Integration_Error__c = null;
                        lpu2u.Dell_Boomi_Received__c = null;
                        lpu2u.Resend_To_Boomi__c = true;
                        licProdUpdate2UpdateList.add(lpu2u);
                    }
                }

                if(!licProdUpdate2UpdateList.isEmpty()){
                    ResendToBoomiList.licProdUpdateList2Update(licProdUpdate2UpdateList);
                }

                //Update all the Quotes to have "Resend to Boomi" unchecked so that they may be executed again
                for(SBQQ__Quote__c newQuote : quoteIdToQuoteMap.values())
                {
                    newQuote.Resend_To_Boomi__c = false;
                }
            }
            else{
                for(SBQQ__Quote__c newProposal : quoteIdToQuoteMap.values()) {
                    newProposal.Resend_To_Boomi__c.addError('Only 1 Quote can be sent to Boomi at a time');
                }
            }

        }
        catch(Exception ex){
            System.debug('inside catch exception');
            Trigger.new[0].addError(ex.getMessage());
        }
    }

    //Commented for 2020-01-21 Release
    //Name: Sergio Flores
    //Date: 09/10/2019
    //W-012806
    /*public static void validateOrderGroupSelected(Set<Id> quoteLicenseAdminIds, Map<String,SBQQ__Quote__c> quoteNumberToQuoteMap) {

        system.debug('inside validate order group selected ' + quoteLicenseAdminIds + ' quote map ' + quoteNumberToQuoteMap);

        String usrProfileName = [select u.Profile.Name from User u where u.id = :Userinfo.getUserId()].Profile.Name;
        String adminProfiles = System.Label.QuoteAdminProfiles;

        if(!adminProfiles.Contains(usrProfileName))
        {
            Map<Id, Order_Group__c> licenseGroupIdToLicenseGroup;

            Map<Id, License_Administrator__c> licenseAdminIdToLicenseAdmin = new Map<Id, License_Administrator__c>();

            if(!quoteLicenseAdminIds.isEmpty())
            licenseAdminIdToLicenseAdmin =new Map<Id, License_Administrator__c>([Select Id, Contact__r.AccountId From License_Administrator__c Where Id IN : quoteLicenseAdminIds]);

            for(SBQQ__Quote__c quote : quoteNumberToQuoteMap.Values())
            {

                if(!licenseAdminIdToLicenseAdmin.isEmpty())
                {
                    License_Administrator__c licenseAdmin = licenseAdminIdToLicenseAdmin.get(quote.License_Administrator__c);

                    system.debug('validate license admin ' + licenseAdmin);

                    if(licenseAdmin.Contact__r.AccountId == quote.SBQQ__Partner__c || licenseAdmin.Contact__r.AccountId == quote.SBQQ__Distributor__c)
                    quote.addError('The order group or license admin selected has an account associated to the partner on the quote. Please use another order group.');
                }

            }
        }*/

    //Reverted for 2019-12-05 Release
    public static void validateOrderGroupSelected( Set<Id> quoteOrderGroupIds, Set<Id> quoteLicenseAdminIds, Map<Id,SBQQ__Quote__c> quoteIdToQuoteMap) {

        Map<Id, Order_Group__c> licenseGroupIdToLicenseGroup;

        Map<Id, License_Administrator__c> licenseAdminIdToLicenseAdmin = new Map<Id, License_Administrator__c>();

        if (!quoteOrderGroupIds.isEmpty()) {
            licenseGroupIdToLicenseGroup = new Map<Id, Order_Group__c>([SELECT Id, Account__c FROM Order_Group__c WHERE Id IN :quoteOrderGroupIds]);
        }

        if (!quoteLicenseAdminIds.isEmpty()) {
            licenseAdminIdToLicenseAdmin = new Map<Id, License_Administrator__c>([SELECT Id, Account__c FROM License_Administrator__c WHERE Id IN :quoteLicenseAdminIds]);
        }

        for(SBQQ__Quote__c quote : quoteIdToQuoteMap.values())
        {
            if(!licenseGroupIdToLicenseGroup.isEmpty())
            {
                Order_Group__c orderGroup = licenseGroupIdToLicenseGroup.get(quote.Order_Group__c);

                if (quote.SBQQ__Account__c != orderGroup.Account__c) {
                    quote.addError('The order group or license admin selected has a different account from the main quote account. Select another order group that has an account matching the quote account. ');
                }
            }

            if(!licenseAdminIdToLicenseAdmin.isEmpty())
            {
                License_Administrator__c licenseAdmin = licenseAdminIdToLicenseAdmin.get(quote.License_Administrator__c);

                if (quote.SBQQ__Account__c != licenseAdmin.Account__c) {
                    quote.addError('The order group or license admin selected has a different account from the main quote account. Select another order group that has an account matching the quote account. ');
                }
            }

        }

    }



    //Name: Chris Salgado
    //Date: 10/24/2019
    //Purpose: W-012834
    public static void getPartnerContactFromOppOrCont(Set<Id> OppIds, List<SBQQ__Quote__c> newQuotes){
        System.debug('** CSALGADO ** In getPartnerContactFromOppOrCont ');
        //Opportunity Map
        Map<Id, Opportunity> oppIdToOpportunitytMap = new Map<Id, Opportunity>([SELECT Id, Partner_Contact__c, Primary_Contact__c
        FROM Opportunity
        WHERE Id IN :OppIds]);

        Set<Id> partnerContactIds = new Set<Id>();
        Set<Id> primaryContactIds = new Set<Id>();
        for(Opportunity oppo : oppIdToOpportunitytMap.values())
        {
            System.debug('Opportunity: ' + oppo);
            partnerContactIds.add(oppo.Partner_Contact__c);
            primaryContactIds.add(oppo.Primary_Contact__c);
        }

        //Primary Contact Map
        Map<Id, Contact> contactIdToContactMap = new Map<Id, Contact>([SELECT Id, Partner_Contact__c
        FROM Contact
        WHERE Id IN :primaryContactIds]);

        for(Contact cont : contactIdToContactMap.values()){
            System.debug('Contact: ' + cont);
            partnerContactIds.add(cont.Partner_Contact__c);
        }

        //Partner Contact Map
        Map<Id, Contact> partnerContactMap = new Map<Id, Contact>([SELECT Id, Account.Id
        FROM Contact
        WHERE Id IN :partnerContactIds]);
        if(!partnerContactMap.isEmpty())
        {
            for(SBQQ__Quote__c quote : newQuotes)
            {
                Opportunity opp = oppIdToOpportunitytMap.get(quote.SBQQ__Opportunity2__c);
                Contact con = contactIdToContactMap.get(opp.Primary_Contact__c);
                System.debug('Opportunity: ' + opp + ' / Contact: ' + con);
                System.debug('Partner Contact contains: ' + partnerContactMap.containsKey(con.Partner_Contact__c));
                System.debug('Partner Contact return: ' + partnerContactMap.get(con.Partner_Contact__c));

                if(opp != null && opp.Partner_Contact__c != null &&
                        partnerContactMap.containsKey(opp.Partner_Contact__c) && partnerContactMap.get(opp.Partner_Contact__c).Account.Id == quote.SBQQ__Partner__c)
                {
                    System.debug('In Opp Partner Contact');
                    quote.Partner_Contact__c = opp.Partner_Contact__c;
                }
                else if(con != null && con.Partner_Contact__c != null &&
                        partnerContactMap.containsKey(con.Partner_Contact__c) && partnerContactMap.get(con.Partner_Contact__c).Account.Id == quote.SBQQ__Partner__c)
                {
                    System.debug('In Primary Cont Partner Contact');
                    quote.Partner_Contact__c = con.Partner_Contact__c;
                }
            }
        }


    }

    ///Sergio Flores
    //W-002462
    //Date: 02/27/2020
    //Refactor Quote Approval Status Changed (Invocable) Process Builder
    public static void archiveApprovals(Map<Id, SBQQ__Quote__c> quotesIdToQuoteMap)
    {
        Map<Id, sbaa__Approval__c> approvalIdToApprovalsMap = new Map<Id, sbaa__Approval__c>(
        [SELECT Quote__c, zQuoteArchive__c, sbaa__Status__c, Quote__r.ApprovalStatus__c, Quote__r.Quote_Has_Had_Approvals__c, sbaa__Archived__c
        FROM sbaa__Approval__c
        WHERE Quote__c IN : quotesIdToQuoteMap.keySet()]
        );

        List<sbaa__Approval__c> approvalsToUpdateList = new List<sbaa__Approval__c>();

        for(sbaa__Approval__c approval : approvalIdToApprovalsMap.values())
        {
            System.debug('inside archive approval for loop ' + approval.sbaa__Status__c + ' ' +  approval.Quote__r.ApprovalStatus__c);
            if(approval.sbaa__Archived__c == true && approval.zQuoteArchive__c == null)
            {
                approval.zQuoteArchive__c = approval.Quote__c;
                approval.Quote__c = null;
                approvalsToUpdateList.add(approval);
            }

        }

        try
        {
            if(!approvalsToUpdateList.isEmpty())
            {
                update approvalsToUpdateList;
            }
        }
        catch(Exception ex)
        {
            System.debug('inside catch exception');
            Trigger.new[0].addError(ex.getMessage());
        }

    }

    //Segio Flores
    //Date: 04/14/2020
    //W-005055
    public static void stamProductsForWinAlert(Map<Id, SBQQ__Quote__c> quoteIdToQuoteMapForEmailProducts)
    {
        System.debug('inside stamProductsForWinAlert');
        //Grab all the quotelines where email friendly is not null
        Map<Id, SBQQ__QuoteLine__c> quoteLineIdToQuoteMap = new Map<Id, SBQQ__QuoteLine__c>
                ([SELECT Id, SBQQ__Quote__c, Email_Friendly_Name__c, SBQQ__ProductFamily__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c IN : quoteIdToQuoteMapForEmailProducts.keySet()
                AND Email_Friendly_Name__c != NULL]);

        Map<Id, SBQQ__Quote__c> quoteIdToFinalProduct = new Map<Id, SBQQ__Quote__c>();
        Set<String> productsToBeAdded = new Set<String>();
        Set<String> servicesToBeAdded = new Set<String>();

        for(SBQQ__QuoteLine__c ql : quoteLineIdToQuoteMap.values())
        {
            SBQQ__Quote__c quote = quoteIdToFinalProduct.get(ql.SBQQ__Quote__c);

            System.debug('inside quote line loop ' + quote);
            //If the quoteProduct is null that means we are adding to it for the first time
            if( (quote == null && ql.SBQQ__ProductFamily__c == 'Alteryx Software') || (quote !=null && quote.Products_To_Be_Added_to_Email_Alert__c == null && ql.SBQQ__ProductFamily__c == 'Alteryx Software') )
            {
                System.debug('inside adding product 1st time ' + quote );
                if (quote == null) {
                    quote = new SBQQ__Quote__c();
                }
                quote.Products_To_Be_Added_to_Email_Alert__c = ql.Email_Friendly_Name__c;
                quoteIdToFinalProduct.put(ql.SBQQ__Quote__c, quote);
                productsToBeAdded.add(ql.Email_Friendly_Name__c);
            }
            //This means that we already added a software product to the quote and now we need to concatenate
            else if(quote != null && quote.Products_To_Be_Added_to_Email_Alert__c != null && ql.SBQQ__ProductFamily__c == 'Alteryx Software')
            {
                System.debug('inside adding product 2nd time ' + quote );
                if(!productsToBeAdded.contains(ql.Email_Friendly_Name__c))
                {
                    quote.Products_To_Be_Added_to_Email_Alert__c = quote.Products_To_Be_Added_to_Email_Alert__c + ',' + ql.Email_Friendly_Name__c;
                    quoteIdToFinalProduct.put(ql.SBQQ__Quote__c, quote);
                    productsToBeAdded.add(ql.Email_Friendly_Name__c);
                }
            }
            //If the quoteServiceProduct is null that means we are adding to it for the first time
            else if( (quote == null && ql.SBQQ__ProductFamily__c == 'Professional Services') || (quote !=null && quote.Services_To_Be_Added_to_Email_Alert__c == null && ql.SBQQ__ProductFamily__c == 'Professional Services') )
            {
                System.debug('inside adding service 1st time ' + quote );
                if (quote == null) {
                    quote = new SBQQ__Quote__c();
                }
                quote.Services_To_Be_Added_to_Email_Alert__c = ql.Email_Friendly_Name__c;
                quoteIdToFinalProduct.put(ql.SBQQ__Quote__c, quote);
                servicesToBeAdded.add(ql.Email_Friendly_Name__c);
            }
            //This means that we already added a professional service product to the quote and now we need to concatenate
            else if(quote != null && quote.Services_To_Be_Added_to_Email_Alert__c != null && ql.SBQQ__ProductFamily__c == 'Professional Services')
            {
                System.debug('inside adding service 2nd time ' + quote );
                if(!servicesToBeAdded.contains(ql.Email_Friendly_Name__c))
                {
                    quote.Services_To_Be_Added_to_Email_Alert__c = quote.Services_To_Be_Added_to_Email_Alert__c + ',' + ql.Email_Friendly_Name__c;
                    quoteIdToFinalProduct.put(ql.SBQQ__Quote__c, quote);
                    servicesToBeAdded.add(ql.Email_Friendly_Name__c);
                }
            }
        }

        System.debug('quoteIdToFinalProduct ' + quoteIdToFinalProduct);

        for(SBQQ__Quote__c quoteToUpdate : quoteIdToQuoteMapForEmailProducts.values())
        {
            SBQQ__Quote__c quoteWithProduct = quoteIdToFinalProduct.get(quoteToUpdate.Id);

            if (quoteWithProduct != null && quoteWithProduct.Products_To_Be_Added_to_Email_Alert__c != null) {
                quoteToUpdate.Products_To_Be_Added_to_Email_Alert__c = quoteWithProduct.Products_To_Be_Added_to_Email_Alert__c;
            }

            if (quoteWithProduct != null && quoteWithProduct.Services_To_Be_Added_to_Email_Alert__c != null) {
                quoteToUpdate.Services_To_Be_Added_to_Email_Alert__c = quoteWithProduct.Services_To_Be_Added_to_Email_Alert__c;
            }
        }
    }

    //Sergio Flores
    //Date: 02/27/2020
    //W-005474
    public static void lockECURStartDate(Map<Id, SBQQ__Quote__c> opportunityIdToQuoteMap)
    {
        //Use this to get the Contract End Date from Opportunity
        Map<Id, Opportunity> oppIdToOpp = new Map<Id, Opportunity>
                ([SELECT Id, SBQQ__RenewedContract__r.EndDate, AdoptionBundle__r.CustomEndDate__c FROM Opportunity WHERE Id IN : opportunityIdToQuoteMap.keySet()]);

        for(SBQQ__Quote__c quote : opportunityIdToQuoteMap.values())
        {
            Opportunity opp = oppIdToOpp.get(quote.SBQQ__Opportunity2__c);

            if(opp !=null && opp.AdoptionBundle__r.CustomEndDate__c !=null && opp.AdoptionBundle__r.CustomEndDate__c >= System.today())
            {
                quote.addError('You cannot edit the Start Date because the adoption has not expired. Do not create an NBEC. Please reach out to your DD coordinator for assistance with this adjustment');
            }
            else if(opp !=null && opp.AdoptionBundle__r.CustomEndDate__c ==null && opp.SBQQ__RenewedContract__r.EndDate >= System.today())
            {
                quote.addError('You cannot edit the Start Date because the renewed contract has not expired. Do not create an NBEC. Please reach out to your DD coordinator for assistance with this adjustment ');
            }
        }
    }

    //Date: 02/27/2020
    //W-005474
    public static void verifyTaxRegNumber(Map<Id, SBQQ__Quote__c> quoteIdToQuoteMapFoTaxReg)
    {
        for(SBQQ__Quote__c quote : quoteIdToQuoteMapFoTaxReg.values())
        {
            //Check to see if the Tax Reg number is equal to the Bill To Account Tax Reg number
            //If not then we need to update it
            if (quote.Tax_Reg_Num__c != quote.Tax_Reg_Number__c) {
                quote.Tax_Reg_Number__c = quote.Tax_Reg_Num__c;
            }
        }
    }

    //Name: Chris Salgado
    //Date: 6/18/20
    //Purpose: W-005430
    //Eddie Wong || 08/10/2020 || W-006017 || CoTerm Enhancement
    public static void coTermQuoteGeneration(List<SBQQ__Quote__c> newQuoteList, Set<Id> coTermOppCheck){
        System.debug('**CSALGADO** In OSCPQ_QuoteTriggerGateway - coTermQuoteGeneration');
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity> ();
        Set<Id> contractSearch = new Set<Id>();
        for(Opportunity opp : [SELECT Id, SBQQ__AmendedContract__c, SBQQ__RenewedContract__c, Type FROM Opportunity WHERE Id IN :coTermOppCheck]){
            if(opp.SBQQ__AmendedContract__c != null){
                oppMap.put(opp.Id, opp);
                contractSearch.add(opp.SBQQ__AmendedContract__c);
                contractSearch.add(opp.SBQQ__RenewedContract__c);
            }
        }

        Map<Id, Contract> contraMap = new Map<Id, Contract>([SELECT Id, StartDate, EndDate FROM Contract WHERE Id IN :contractSearch]);

        for(SBQQ__Quote__c quot : newQuoteList){
            if(oppMap.containsKey(quot.SBQQ__Opportunity2__c) && oppMap.get(quot.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c != null
                    && contraMap.containsKey(oppMap.get(quot.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c) && contraMap.get(oppMap.get(quot.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).EndDate != null){
                quot.Quote_Type__c = 'Purchase';
                quot.Payment_Schedule__c = 'Equal ACV Per Year'; // Eddie Wong || W-006276 || 09/10/2020 || Default payment schedule to 'Equal ACV Per Year'
                //quot.SBQQ__Type__c = 'Amendment';
                quot.SBQQ__MasterContract__c = oppMap.get(quot.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c;
                quot.OSCPQ_Amended_Contract__c = oppMap.get(quot.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c;
                if(oppMap.get(quot.SBQQ__Opportunity2__c).Type == 'ECUR') {
                    quot.Purchase_Type__c = 'Renewal';
                    //Need to add the Renewal Contract End Date + 1 since the Renewal is being Amended to the existing (Amendment) Contract
                    if(oppMap.get(quot.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c != null && contraMap.containsKey(oppMap.get(quot.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c)) {
                        quot.SBQQ__StartDate__c = contraMap.get(oppMap.get(quot.SBQQ__Opportunity2__c).SBQQ__RenewedContract__c).EndDate.addDays(1);
                    }
                    quot.SBQQ__ExpirationDate__c = quot.SBQQ__StartDate__c.addDays(90);
                    if(quot.SBQQ__Type__c != 'Amendment'){
                        quot.SBQQ__MasterContract__c = NULL;
                        quot.OSCPQ_Amended_Contract__c = NULL;
                    }
                    else if(quot.SBQQ__Type__c == 'Amendment'){
                        quot.SBQQ__EndDate__c = contraMap.get(oppMap.get(quot.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).EndDate;
                    }
                }
                else if(oppMap.get(quot.SBQQ__Opportunity2__c).Type == 'NBEC') {
                    if (quot.Purchase_Type__c == 'Upsell Standalone') {
                        quot.SBQQ__Type__c = 'Quote';
                        quot.SBQQ__MasterContract__c = NULL;
                        quot.OSCPQ_Amended_Contract__c = NULL;
                        quot.SBQQ__StartDate__c = Date.today();
                        quot.SBQQ__ExpirationDate__c = quot.SBQQ__StartDate__c.addDays(30);
                    }
                    else {
                        quot.Purchase_Type__c = 'Upsell Co-term';
                        quot.SBQQ__Type__c = 'Amendment';
                        quot.SBQQ__StartDate__c = Date.today();
                        quot.SBQQ__ExpirationDate__c = quot.SBQQ__StartDate__c.addDays(30);
                        quot.SBQQ__EndDate__c = contraMap.get(oppMap.get(quot.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).EndDate;
                    }
                }
                //Co-Term End Date
                //quot.SBQQ__EndDate__c = contraMap.get(oppMap.get(quot.SBQQ__Opportunity2__c).SBQQ__AmendedContract__c).EndDate;
                System.debug('**CSALGADO** Insert Quote: ' + JSON.serializePretty(quot));
            }
        }
    }

    //Name: Eddie Wong
    //Date: 7/14/2020
    //Purpose: W-005162
    public static void amendmentQuoteUpdate(List<SBQQ__Quote__c> newQuoteList, Set<Id> coTermOppCheckSet) {

        System.debug('eddie inside amendmentQuoteUpdate' + newQuoteList);

        List<Amendment_Quote_Update_Event__e> amendQuoteUpdateEvents = new List<Amendment_Quote_Update_Event__e>();

        for (SBQQ__Quote__c quote : newQuoteList) {
            Amendment_Quote_Update_Event__e singleAmendQuoteUpdateEvent = new Amendment_Quote_Update_Event__e(
                    Contract_Id__c = quote.OSCPQ_Amended_Contract__c,
                    Opportunity_Id__c = quote.SBQQ__Opportunity2__c,
                    Quote_Id__c = quote.Id
            );

            amendQuoteUpdateEvents.add(singleAmendQuoteUpdateEvent);
        }

        //Publish Events
        List<Database.SaveResult> saveResults = EventBus.publish(amendQuoteUpdateEvents);

        //Publish Results
        for (Database.SaveResult sr : saveResults) {
            if (sr.isSuccess()) {
                System.debug('Successfully published event.');
            } else {
                for (Database.Error err : sr.getErrors()) {
                    System.debug('Error Returned: ' + err.getStatusCode() + ' - ' + err.getMessage()) ;
                }
            }
        }

    }

}