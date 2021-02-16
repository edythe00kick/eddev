/**
 * Class ContactHandler
 *
 * Trigger Handler for the Account SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class ContactHandler{

    // Contacts with Campaign_Channel_Attribution__c field filled
    Set<Id> cca_contactIds = new Set<Id>();
    // Campaign id in Campaign_Channel_Attribution__c field on contact
    Set<Id> cca_campaignIds = new Set<Id>();
    // Contact id to Most_Recent_Campaign_ID__c field on contact
    Map<Id, Id> cca_contactIdToMostRecentCampaignId = new Map<Id, Id>();
    // Contact id to Contact Source - Most Recent field on contact
    Map<Id, String> cca_contactIdToContactSourceMostRecent = new Map<Id, String>();
    // Contact ids where Lead Source - Most Recent field is filled
    Set<Id> contactsWithLSMR = new Set<Id>();
    // Stores the value of Trigger.isExecuting
    private Boolean myIsExecuting = false;
    // Stores the value of Trigger.size
    private integer batchSize = 0;
    public boolean isInsertTrigger = false;

    public ContactHandler(Boolean isExecuting, Integer size, List<Contact> newRecords, Boolean isInsert) {
        this.isInsertTrigger = isInsert;
    }

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */


    public void onBeforeInsert(List<Contact> newRecords, Map<Id, Contact> oldMaps) {

        for(Contact c : newRecords)
        {
            if(c.Cadence_Stage__c !=null)
            {
                String cadenceStage = c.Cadence_Stage__c;
                if(cadenceStage.Contains('/'))
                {
                    List<String> cadenceStageString = cadenceStage.split('/', 2);
                    c.Contact_Status__c = cadenceStageString[0];
                    c.Contact_Outcome_Reason__c = cadenceStageString[1];
                }
                else
                {
                    c.Contact_Status__c = cadenceStage;
                    c.Contact_Outcome_Reason__c = null;
                }
            }
        }

    }

    public void onBeforeUpdate(List<Contact> newRecords, Map<Id, Contact> oldMaps) {

        Map<Id, Contact> oldmap =  (Map<Id, Contact>)Trigger.oldMap;
        //Sharma Nemani | PDG Workflow Rules
        //Date: 03/27/2019
        //Description: Contact workflow's logic for the SLA
        String DGLeadStatusValues = 'Prospect, Engaged, Open, Re-Qualified';
        String warmInPolicy = 'warm sla in-policy';
        String warmOutPolicy = 'warm sla out-of-policy';
        String hotInPolicy = 'hot sla in-policy';
        String hotOutPolicy = 'hot sla out-of-policy';
        Map<Id, Contact> contactIdToContactMap = new Map<Id, Contact>();

        string ownersSLANotToSend = System.Label.ownersSLANotToSend;
        Set<String> userIdNotToSendSLAAlerts = new Set<String>();
        for(String s : ownersSLANotToSend.Split(',') )
        {
            userIdNotToSendSLAAlerts.add(s);
        }

        Date today = System.Today();

        for(Contact c : newRecords)
        {

            Contact oldContact = (Contact)Trigger.oldMap.get(c.ID);

            if((c.Cadence_Stage__c != oldContact.Cadence_Stage__c) && (c.Contact_Outcome_Reason__c == oldContact.Contact_Outcome_Reason__c || c.Contact_Status__c == oldContact.Contact_Status__c ))
            {
                system.debug('Inside Cadence Stage before update');
                String cadenceStage = c.Cadence_Stage__c;
                if(cadenceStage.Contains('/'))
                {
                    List<String> cadenceStageString = cadenceStage.split('/', 2);
                    c.Contact_Status__c = cadenceStageString[0];
                    c.Contact_Outcome_Reason__c = cadenceStageString[1];
                }
                else
                {
                    c.Contact_Status__c = cadenceStage;
                    c.Contact_Outcome_Reason__c = null;
                }


                system.debug('Status ' + c.Contact_Status__c + ' Outcome Reason ' + c.Lead_Close_Reason__c);
            }

            //Sergio Flores
            //Date 03/04/2019
            //W-011205
            if( (c.Contact_Status__c != oldContact.Contact_Status__c && c.DG_Lead_Status__c != 'Converted to Opportunity') || (c.Contact_Outcome_Reason__c != oldContact.Contact_Outcome_Reason__c && c.Contact_Status__c == '5 - Closed') )
            {
                system.debug('Inside status update');
                Lead_Contact_DG_Status_Update__c contactDGStatus = Lead_Contact_DG_Status_Update__c.getValues(c.Contact_Status__c);
                if(contactDGStatus !=null)
                    c.DG_Lead_Status__c = contactDGStatus.DG_Lead_Status__c;
                if(c.Contact_Status__c == '5 - Closed')
                {
                    List<Lead_Contact_DG_Status_Update__c> leadContactStatusCSList = Lead_Contact_DG_Status_Update__c.getall().values();
                    if(!leadContactStatusCSList.isEmpty())
                    {
                        for(Lead_Contact_DG_Status_Update__c leadContactStatusCS : leadContactStatusCSList)
                        {
                            if(leadContactStatusCS.Name == c.Contact_Outcome_Reason__c)
                                c.DG_Lead_Status__c = leadContactStatusCS.DG_Lead_Status__c;
                            else if(c.Contact_Outcome_Reason__c == leadContactStatusCS.Lead_Outcome_Reason__c)
                                c.DG_Lead_Status__c = leadContactStatusCS.DG_Lead_Status__c;
                        }
                    }
                }
            }

            String ownerId = (String)c.OwnerId;
            Boolean ownedByRep = false;
            String startDate = System.label.PDGGoLiveDate;
            Date goliveDate = Date.valueOf(startDate);

            if(ownerId.startsWith('005') && !userIdNotToSendSLAAlerts.contains(ownerId))
                ownedByRep = true;

            system.debug('before ownership SLA changed ' + c);

            //Sergio Flores
            //Date: 01/03/2020
            //W-013772
            if(c.ownerId == oldContact.ownerId && (c.Rep_Owned_Warm_SLA_Date__c == null && c.Rep_Owned_Hot_SLA_Date__c == null)
                    && ownedByRep
                    //The above checks to see if a rep already owns the lead and the SLA dates haven't been stamped
                    ||
                    //The below checks to see if rep ownership changes to another rep
                    (c.ownerId != oldContact.ownerId
                            && ownedByRep)
                    ||
                    //The below checks to see if only the hot or warm sla dates are changed and the owner is a rep
                    ( (c.Hot_SLA_Date__c != oldContact.Hot_SLA_Date__c || c.Warm_SLA_Date__c != oldContact.Warm_SLA_Date__c)
                            && ownedByRep)  )
            {
                //Basically here we check to see if its owned by a rep, if so then we can start the PDG SLA time tracking
                //Eddie Wong || 04/27/2020 || W-005127 || To exclude contacts that already have dispensation and conversion populated
                if(c.Warm_SLA_Date__c !=null && c.Warm_SLA_Date__c >= goliveDate && c.Dispensation_SLA_QL__c == null && c.Conversion_SLA_QL__c == null)
                    c.Rep_Owned_Warm_SLA_Date__c = today;
                else if(c.Hot_SLA_Date__c !=null  && c.Hot_SLA_Date__c >= goliveDate && c.Dispensation_SLA_QL__c == null && c.Conversion_SLA_QL__c == null)
                    c.Rep_Owned_Hot_SLA_Date__c = today;
                else if(c.Warm_SLA_Date__c != oldContact.Warm_SLA_Date__c && c.Dispensation_SLA_QL__c != null && c.Conversion_SLA_QL__c != null)
                    c.Rep_Owned_Warm_SLA_Date__c = today;
                else if(c.Hot_SLA_Date__c != oldContact.Hot_SLA_Date__c && c.Dispensation_SLA_QL__c != null && c.Conversion_SLA_QL__c != null)
                    c.Rep_Owned_Hot_SLA_Date__c = today;
            }

            if(c.DG_Lead_Status__c != null && c.DG_Lead_Status__c != oldContact.DG_Lead_Status__c)
            {
                if(!DGLeadStatusValues.contains(c.DG_Lead_Status__c)){
                    if(warmInPolicy.equalsIgnoreCase(c.Dispensation_SLA_QL__c)  && c.Business_Days_Since_Warm_SLA__c <= 2){  //W-011325
                        c.Dispensation_SLA_QL__c = 'Warm SLA In-policy Completed';
                    }
                    if(warmOutPolicy.equalsIgnoreCase(c.Dispensation_SLA_QL__c)){ //W-011330
                        c.Dispensation_SLA_QL__c = 'Warm SLA Out-of-policy Completed';
                    }
                    if(hotInPolicy.equalsIgnoreCase(c.Dispensation_SLA_QL__c) && c.Business_Days_Since_Hot_SLA__c <= 1){ //W-011332
                        c.Dispensation_SLA_QL__c = 'Hot SLA In-policy Completed';
                    }
                    if(hotOutPolicy.equalsIgnoreCase(c.Dispensation_SLA_QL__c)){ //W-011336
                        c.Dispensation_SLA_QL__c = 'Hot SLA Out-of-policy Completed';
                    }
                }
                if(c.DG_Lead_Status__c != null && (c.DG_Lead_Status__c.startsWithIgnoreCase('recycle') || c.DG_Lead_Status__c.startsWithIgnoreCase('rejected') || c.DG_Lead_Status__c.startsWithIgnoreCase('converted'))){
                    if(warmInPolicy.equalsIgnoreCase(c.Conversion_SLA_QL__c)){  //W-011338
                        c.Conversion_SLA_QL__c = 'Warm SLA In-policy Completed';
                    }
                    if(warmOutPolicy.equalsIgnoreCase(c.Conversion_SLA_QL__c)){ //W-011343
                        c.Conversion_SLA_QL__c = 'Warm SLA Out-of-policy Completed';
                    }
                    if(hotInPolicy.equalsIgnoreCase(c.Conversion_SLA_QL__c)){ //W-011345
                        c.Conversion_SLA_QL__c = 'Hot SLA In-policy Completed';
                    }
                    if(hotOutPolicy.equalsIgnoreCase(c.Conversion_SLA_QL__c)){ //W-011336
                        c.Conversion_SLA_QL__c = 'Hot SLA Out-of-policy Completed';
                    }
                }
            }

            //Here we check to see if the time stamping has started, if it has then we need to update the dispensation, if the owner changes in the same day that also needs to be accounted for
            //Eddie Wong || 04/27/2020 || W-005127 || To exclude contacts that already have dispensation and conversion populated
            if(c.Rep_Owned_Warm_SLA_Date__c != null
                    && (c.Rep_Owned_Warm_SLA_Date__c != oldContact.Rep_Owned_Warm_SLA_Date__c
                        || (ownedByRep && c.ownerId != oldContact.ownerId && c.Contact_Status__c != '5 - Closed') )
                    && c.Rep_Owned_Warm_SLA_Date__c == System.Today() ){  //W-011318
                c.Dispensation_SLA_QL__c = 'Warm SLA In-policy';
            }
            //Here we check to see if the time stamping has started, if it has then we need to update the dispensation, if the owner changes in the same day that also needs to be accounted for
            //Eddie Wong || 04/27/2020 || W-005127 || To exclude contacts that already have dispensation and conversion populated
            if(c.Rep_Owned_Hot_SLA_Date__c != null
                    && (c.Rep_Owned_Hot_SLA_Date__c != oldContact.Rep_Owned_Hot_SLA_Date__c
                        || (ownedByRep && c.ownerId != oldContact.ownerId && c.Contact_Status__c != '5 - Closed') )
                    && c.Rep_Owned_Hot_SLA_Date__c == System.Today() ){  //W-011322
                c.Dispensation_SLA_QL__c = 'Hot SLA In-policy';
            }

            System.debug('before sla logic  ' + c);
            if( (c.Dispensation_SLA_QL__c !=null || c.Conversion_SLA_QL__c !=null)
                    && (  (c.Dispensation_SLA_QL__c != oldContact.Dispensation_SLA_QL__c || c.Conversion_SLA_QL__c != oldContact.Conversion_SLA_QL__c) || (c.ownerId != oldContact.ownerId)  )
                    && ownerId.startsWith('005')
                    && !userIdNotToSendSLAAlerts.contains(ownerId)
                    && (c.Hot_SLA_Date__c >= goliveDate || c.Warm_SLA_Date__c >= goliveDate)
                    && c.Contact_Status__c != '5 - Closed')
            {
                contactIdToContactMap.put(c.Id, c);
            }

            //Sergio Flores
            //Date 09/13/2019
            //W-013044
            //Here we check to see if the time stamping has started, if it has then we need to update the conversion, if the owner changes in the same day that also needs to be accounted for
            //also email alerts should not be sent for this scenario
            //Eddie Wong || 04/27/2020 || W-005127 || To exclude contacts that already have dispensation and conversion populated
            if( (c.Rep_Owned_Warm_SLA_Date__c != oldContact.Rep_Owned_Warm_SLA_Date__c
                    || (ownedByRep && c.ownerId != oldContact.ownerId && c.Contact_Status__c != '5 - Closed') )
                    && c.Rep_Owned_Warm_SLA_Date__c == today)
            {
                c.Conversion_SLA_QL__c = 'Warm SLA In-policy';
            }

            //Sergio Flores
            //Date 09/13/2019
            //W-013046
            //Here we check to see if the time stamping has started, if it has then we need to update the conversion, if the owner changes in the same day that also needs to be accounted for
            //also email alerts should not be sent for this scenario
            //Eddie Wong || 04/27/2020 || W-005127 || To exclude contacts that already have dispensation and conversion populated
            if( (c.Rep_Owned_Hot_SLA_Date__c != oldContact.Rep_Owned_Hot_SLA_Date__c
                    || (ownedByRep && c.ownerId != oldContact.ownerId && c.Contact_Status__c != '5 - Closed') )
                    && c.Rep_Owned_Hot_SLA_Date__c == today)
            {
                c.Conversion_SLA_QL__c = 'Hot SLA In-policy';
            }
        }

        //Eddie Wong
        //Date: 04/05/2020
        //W-004839
        if(!contactIdToContactMap.isEmpty() && RecursionHandler.IsContactSLAQueuableExecuted == false)
        {
            System.debug('inside executeContactSLQTaskAndEmail queueable ' + contactIdToContactMap);
            ContactGateway.checkStatusHistory(contactIdToContactMap);
        }

    }

    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void onBeforeDelete(List<Contact> newRecords) {

    }

    public void onAfterInsert(List<Contact> newRecords, Map<Id, Contact> oldMaps) {
        RecursionHandler.IsContactTriggerInserted = true;
    }

    public void onAfterUpdate(List<Contact> newRecords, Map<Id, Contact> oldMaps)  {
        Map<String, Contact> contactEmailToContact = new Map<String, Contact>();
        Map<String, Contact> contactUTMToUTM = new Map<String, Contact>();
        Boolean emailChanged = false;
        Map<Id, Contact> contactIdToContactMap = new Map<Id, Contact>();

        for(Contact contact : newRecords)
        {
            if(Trigger.oldMap!=null){ //Sharma Nemani | PDG Workflow Rules | Date:03/27/2019 | Added Null Check for trigger.old
                Contact oldContact = (Contact)Trigger.oldMap.get(contact.ID);

                System.debug('ch> contact.Campaign_Channel_Attribution__c:'
                        + contact.Campaign_Channel_Attribution__c);
                System.debug('ch> oldContact.Campaign_Channel_Attribution__c:'
                        + oldContact.Campaign_Channel_Attribution__c);

                if(contact.Contact_Source_Most_Recent__c != null
                        && contact.Contact_Source_Most_Recent__c != oldContact.Contact_Source_Most_Recent__c)
                {

                    if(contact.Most_Recent_Campaign_ID__c != null)
                    {
                        cca_contactIds.add(contact.Id);
                        contactsWithLSMR.add(contact.Id);
                        cca_campaignIds.add(contact.Most_Recent_Campaign_ID__c);
                        cca_contactIdToMostRecentCampaignId.put(contact.Id, contact.Most_Recent_Campaign_ID__c);
                        cca_contactIdToContactSourceMostRecent.put(contact.Id, contact.Contact_Source_Most_Recent__c);
                    }

                }
                else if(contact.Contact_Source_Most_Recent__c == null
                        && contact.Campaign_Channel_Attribution__c != null
                        && contact.Campaign_Channel_Attribution__c
                        != oldContact.Campaign_Channel_Attribution__c)
                {

                    String cca = contact.Campaign_Channel_Attribution__c;
                    if(CampaignChannelAttributionHelper.checkCCA(cca)) {
                        List<String> temp_val = cca.split(';');
                        cca_contactIds.add(contact.Id);
                        cca_campaignIds.add(temp_val.get(0).trim());
                        cca_contactIdToMostRecentCampaignId.put(contact.Id, (temp_val.get(0).trim()));
                        cca_contactIdToContactSourceMostRecent.put(contact.Id, (temp_val.get(2).trim()));
                    }

                }

                //Sergio Flores
                //Date: 08/07/2019
                //W-011320
                //Need to check if following GPDR fields are changed on a contact, if they are
                //need to update related individual object record
                if(contact.Email !=null && contact.Safe_to_Send__c != oldContact.Safe_to_Send__c && contact.Email == oldContact.Email)
                {
                    system.debug('inside contact handler safe to send updated');
                    contactEmailToContact.put(contact.Email, contact);
                }

                if(contact.Email !=null && contact.Email != oldContact.Email && contact.Safe_to_Send__c == oldContact.Safe_to_Send__c)
                {
                    system.debug('inside contact handler email updated');
                    emailChanged = true;
                    contactEmailToContact.put(contact.Email, contact);
                }

                //Sergio Flores
                //Date: 11/27/2019
                //W-013601
                if(    (contact.MailingStreet != oldContact.MailingStreet)
                        || (contact.MailingCity != oldContact.MailingCity)
                        || (contact.MailingState != oldContact.MailingState)
                        || (contact.MailingCountry != oldContact.MailingCountry)
                        || (contact.MailingPostalCode != oldContact.MailingPostalCode)
                        )
                {
                    system.debug('contact address changed');
                    contactIdToContactMap.put(contact.Id, contact);
                }


                //Eddie Wong
                //Date: 12/20/2019
                //W-013648
                //To check if UTM fields in Contact are being updated
                system.debug('after update before UTM critieria ' + contact.Most_Recent_Campaign_ID__c + contact.UTM_Source__c + contact.UTM_Medium__c );
                //When contact is INSERTED (or UPDATED) with UTM values, we check to make sure Most Recent Campaign ID, UTM Source, and UTM Medium fields are not blank
                //When Campaign Member is created and contact is updated with UTM values, we check to make sure Most Recent Campaign ID, UTM Source, and UTM Medium fields are not blank
                if (contact.Most_Recent_Campaign_ID__c != null
                        && (contact.UTM_Source__c      != null
                        || contact.UTM_Medium__c       != null)) {
                    System.debug('inside contact handler utm field track' + contact.UTM_Campaign_Name__c);
                    contactUTMToUTM.put(contact.Id, contact);
                }

            }
        }

        if(!contactIdToContactMap.isEmpty())
        {
            ContactGateway.syncQuoteAddress(contactIdToContactMap);
        }

        //Adding toggle to execute individual functionality
        string toggleForIndividual = System.Label.Individual_Toggle;

        //Sergio Flores
        //Date: 08/07/2019
        //W-011320
        if(!contactEmailToContact.isEmpty() && RecursionHandler.IsContactTriggerExecuted == false && toggleForIndividual == 'True' && Recursionhandler.IsContactSLAQueuableExecuted == false)
        {
            System.debug('inside executeCreateIndividualRecord queuable ' + contactEmailToContact +  ' '  + isInsertTrigger + ' ' + emailChanged);
            RecursionHandler.IsContactTriggerExecuted = true;
            ContactQueueable executeCreateIndividualRecord = new ContactQueueable(contactEmailToContact, RecursionHandler.IsContactTriggerInserted, emailChanged);
            ID jobID = System.enqueueJob(executeCreateIndividualRecord);

        }


        //Eddie Wong
        //Date: 12/20/2019
        //W-013648
        //To call queueable class - UTMQueueable
        if(!contactUTMToUTM.isEmpty() && Recursionhandler.IsContactUTMTriggerExecuted == false && Recursionhandler.IsContactSLAQueuableExecuted == false){
            Recursionhandler.IsContactUTMTriggerExecuted = true;
            /*UTMQueueable executeUTMFieldTracking = new UTMQueueable(contactUTMToUTM);
            ID jobID = System.enqueueJob(executeUTMFieldTracking);*/
            Map<String,Lead> leadUTMToUTM = new Map<String,Lead>();
            UTMQueueable.executeUTM(leadUTMToUTM, contactUTMToUTM);
        }



    }

    public void onAfterDelete(List<Contact> newRecords) {
    }



    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally() {
        System.debug('ch> cca_contactIds:' + cca_contactIds);
        System.debug('ch> contactsWithLSMR:' + contactsWithLSMR);
        System.debug('ch> cca_campaignIds:' + cca_campaignIds);
        System.debug('ch> cca_contactIdToMostRecentCampaignId:'
                + cca_contactIdToMostRecentCampaignId);
        System.debug('ch> cca_contactIdToContactSourceMostRecent:'
                + cca_contactIdToContactSourceMostRecent);

        Map<Id, CampaignMember> contact_id_to_recent_cm
                = ContactGateway.getCampaignMemberFromCCA(cca_contactIds,
                        cca_campaignIds,
                        cca_contactIdToMostRecentCampaignId);
        ContactGateway.updateCampaignMemberCCA(contact_id_to_recent_cm,
                cca_contactIdToContactSourceMostRecent,
                contactsWithLSMR);
    }
}