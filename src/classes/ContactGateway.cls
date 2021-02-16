public without sharing class ContactGateway {
    Public Static Boolean runOnce = true;
    public static List<CampaignMember> getCampaignMembers(Set<Id> contact_ids, Set<Id> campaign_ids) {
        List<CampaignMember> cms = new List<CampaignMember>();

        for(CampaignMember cm : [SELECT Id
                ,Lead_Source_Most_Recent__c
                ,ContactId
                ,CampaignId
        FROM CampaignMember
        WHERE ContactId IN :contact_ids
        AND CampaignId IN :campaign_ids
        AND hasResponded = true
        ORDER BY FirstRespondedDate DESC, createddate DESC]) {
            cms.add(cm);
        }

        return cms;
    }

    /*
    * Get campaign member corresponding to contact id and id of campaign
    * mentioned in "Campaign Channel Attribution" fiecon.
    */
    public static Map<Id, CampaignMember> getCampaignMemberFromCCA(Set<Id> contact_ids
            , Set<Id> campaign_ids
            , Map<Id, Id> contactIdToMostRecentCampaignId) {
        Map<Id, CampaignMember> contact_id_to_recent_cm = new Map<Id, CampaignMember>();
        List<CampaignMember> cms = getCampaignMembers(contact_ids, campaign_ids);

        System.debug('cg> cms:' + cms);

        for(CampaignMember cm : cms) {
            Id campaign_id = contactIdToMostRecentCampaignId.get(cm.ContactId);
            if(cm.CampaignId == campaign_id) {
                contact_id_to_recent_cm.put(cm.ContactId, cm);
            }
        }

        System.debug('cg> contact_id_to_recent_cm:' + contact_id_to_recent_cm);

        return contact_id_to_recent_cm;
    }

    /*
     * Update Channel field on Campaign Member from third value stored
     * in "Campaign Channel Attribution" field on contact
     */
    public static void updateCampaignMemberCCA(Map<Id, CampaignMember> contact_id_to_recent_cm,
            Map<Id, String> contactIdToContactSourceMostRecent,
            Set<Id> contactsWithLSMR) {
        List<CampaignMember> cms = new List<CampaignMember>();

        for(Id contact_id : contact_id_to_recent_cm.keySet()) {
            CampaignMember cm = contact_id_to_recent_cm.get(contact_id);
            if(contactIdToContactSourceMostRecent.containsKey(cm.ContactId)) {

                String contact_source_most_recent = contactIdToContactSourceMostRecent.get(cm.ContactId);

                if(contactsWithLSMR.contains(cm.ContactId)) {
                    if(cm.Lead_Source_Most_Recent__c == null) {
                        cm.Lead_Source_Most_Recent__c = contact_source_most_recent;
                        cms.add(cm);
                    }
                } else {
                    cm.Lead_Source_Most_Recent__c = contact_source_most_recent;
                    cms.add(cm);
                }

            }
            System.debug('cg> cm.Lead_Source_Most_Recent__c:'
                    + cm.Lead_Source_Most_Recent__c);

        }

        try {
            update cms;
        } catch (Exception ex) {
            for(Contact c : ((List<Contact>) Trigger.new)) { Exception cause = ex.getCause(); String msg = cause != null ? cause.getMessage() : ex.getMessage(); c.addError(msg); }
        }
    }

    //Sergio Flores
    //Date: 11/27/2019
    //W-013601
    public static void syncQuoteAddress(Map<Id, Contact> contactIdToContactMap)
    {
        string Status_To_Sync_Quote_Address = System.Label.Status_To_Sync_Quote_Address;

        Set<String> quoteStatus = new Set<String>();

        for(String s : Status_To_Sync_Quote_Address.Split(',') )
        {
            quoteStatus.add(s);
        }

        //Need to query all open primary quotes where we need to sync the address to
        Map<Id, SBQQ__Quote__c> quoteIdToQuotes = new Map<Id, SBQQ__Quote__c>(
        [Select Id, SBQQ__PrimaryContact__c,SBQQ__ShippingName__c, SBQQ__ShippingStreet__c, SBQQ__ShippingCity__c,
                SBQQ__ShippingState__c, SBQQ__ShippingPostalCode__c, SBQQ__ShippingCountry__c, SBQQ__PrimaryContact__r.pw_ccpro__MailingCountryLookup__r.Price_Book__c,
                SBQQ__PrimaryContact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c,
                SBQQ__PrimaryContact__r.Account.Name, SBQQ__Opportunity2__r.isclosed
        From SBQQ__Quote__C Where SBQQ__PrimaryContact__c IN : contactIdToContactMap.keySet() AND SBQQ__Primary__c = true AND SBQQ__Status__c IN : quoteStatus]);

        if(!quoteIdToQuotes.isEmpty())
        {
            List<SBQQ__Quote__C> quoteAddressToUpdateList = new List<SBQQ__Quote__C>();

            for(SBQQ__Quote__c quote : quoteIdToQuotes.values())
            {
                Contact primaryContact = contactIdToContactMap.get(quote.SBQQ__PrimaryContact__c);
                if(primaryContact !=null && !quote.SBQQ__Opportunity2__r.isclosed)
                {
                    //Updating from the Primary Contact Information
                    system.debug('Inside syncQuoteAddress ' + primaryContact);
                    quote.SBQQ__ShippingName__c = quote.SBQQ__PrimaryContact__r.Account.Name;
                    quote.SBQQ__ShippingStreet__c = primaryContact.MailingStreet;
                    quote.SBQQ__ShippingCity__c = primaryContact.MailingCity;
                    quote.SBQQ__ShippingState__c = primaryContact.MailingState;
                    quote.SBQQ__ShippingPostalCode__c = primaryContact.MailingPostalCode;
                    quote.SBQQ__ShippingCountry__c = primaryContact.MailingCountry;
                    //quote.Ship_to_Price_Book__c = quote.SBQQ__PrimaryContact__r.pw_ccpro__MailingCountryLookup__r.Price_Book__c ;
                    //quote.Ship_To_Currency__c = quote.SBQQ__PrimaryContact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c;
                    quoteAddressToUpdateList.add(quote);
                }
            }

            if(!quoteAddressToUpdateList.isEmpty())
                update quoteAddressToUpdateList;

        }

    }

    //Eddie Wong
    //Date: 04/05/2020
    //W-004839
    public static void checkStatusHistory(Map<Id, Contact> contactIdToContactMap)
    {
        //New map to push into SLA Queueable
        Map<Id, Contact> contactIdToContactSLAMap = new Map<Id, Contact>();

        Map<Id, ContactHistory> contactHistoryIdContactHistoryMap = new Map<Id, ContactHistory>
                ([SELECT ContactId, NewValue FROM ContactHistory
                WHERE ContactId IN : contactIdToContactMap.keySet()
                AND Field = 'Contact_Status__c' and createddate = last_n_days:14]);

        Map<Id, ContactHistory> contactIdContactHistoryMap = new Map<Id, ContactHistory>();

        for(ContactHistory cH : contactHistoryIdContactHistoryMap.values())
        {
            contactIdContactHistoryMap.put(cH.ContactId, cH);
        }

        for(Contact c : contactIdToContactMap.values())
        {
            ContactHistory contactHistory = contactIdContactHistoryMap.get(c.Id);
            System.debug('inside checking contact history ' + contactHistory);

            if(contactHistory == null)
            {
                contactIdToContactSLAMap.put(c.Id, c);
            }
            else
            {
                if(c.Hot_SLA_Date__c == System.Today() && (contactHistory.NewValue == '2 - Attempting Contact' || contactHistory.NewValue == '3 - In Conversation'))
                {
                    c.Dispensation_SLA_QL__c = 'Hot SLA In-policy Completed';
                    contactIdToContactSLAMap.put(c.Id, c);
                }
                else if (c.Warm_SLA_Date__c == System.Today() && (contactHistory.NewValue == '2 - Attempting Contact' || contactHistory.NewValue == '3 - In Conversation'))
                {
                    c.Dispensation_SLA_QL__c = 'Warm SLA In-policy Completed';
                    contactIdToContactSLAMap.put(c.Id, c);
                }
            }
        }

        if(!contactIdToContactSLAMap.isEmpty() && Recursionhandler.IsContactSLAQueuableExecuted == false)
        {
            System.debug('inside executeContactSLQTaskAndEmail queuable ' + contactIdToContactSLAMap);
            Recursionhandler.IsContactSLAQueuableExecuted = true;
            ContactSLAQueuable executeContactSLQTaskAndEmail = new ContactSLAQueuable(contactIdToContactSLAMap);
            ID jobId = System.enqueueJob(executeContactSLQTaskAndEmail);
        }
    }


}