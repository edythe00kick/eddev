public without sharing class LeadHandler{
    // Leads with Campaign_Channel_Attribution__c field filled
    Set<Id> cca_leadIds = new Set<Id>();
    // Campaign id in Campaign_Channel_Attribution__c field on lead
    Set<Id> cca_campaignIds = new Set<Id>();
    // Lead id to Most_Recent_Campaign_ID__c field on lead
    Map<Id, Id> cca_leadIdToMostRecentCampaignId = new Map<Id, Id>();
    // Lead id to Lead Source - Most Recent field on lead
    Map<Id, String> cca_leadIdToLeadSourceMostRecent = new Map<Id, String>();
    // Lead ids where Lead Source - Most Recent field is filled
    Set<Id> leadsWithLSMR = new Set<Id>();
    // Lead Ids to Delete
    set<Id> LeadIds_del = new set<Id>();
    // lead to contact map at time of lead creation
    public Map<Id,Id> leadToContactMap = new Map<Id,Id>();
    public Map<Id, Id> leadIdToXDRMap = new Map<Id, Id>(); //EWONG || 10/22/2020 || W-006542 || XDR Lead code sharing
    // set of contact ids needed in lead updation conditions.
    set<Id> contactIds = new set<Id>();
    // Map of Contact to Account for lead updation
    public Map<Id,Id> contactToAccountMap;
    // Set Of leadIds to run assignment Rules
    set<ID> leadset= new set<ID>();
    //data store in the custom metadata for the Territory Mapping
    List<Territory_Mapping__mdt> fields;
    //List of the active users
    List<User> userList;
    //Map of the active users
    Map<Id,User> userMap = new Map<Id,User>();

    public LeadHandler(Boolean isExecuting, List<Lead> newRecords) {
        //Recursionhandler.IsleadTriggerExecuted = isExecuting;

    }

    public void onBeforeInsert(List<Lead> newRecords)
    {
        //Set of owners
        Set<Id> userIds = New Set<Id>();
        // String Variable to store the user query
        string userQuery = '';
        // String variable used to store the user fields for territory Mapping
        string userFields = '';
        //Name: Chris Salgado Date: 4/21/20 Purpose: W-001799
        Id partnerCommunityProfileId = [SELECT Id FROM Profile WHERE Name = :Label.Partner_Community_Profile].Id;
        Set<Id> contactIdSet = new Set<Id>();

        system.debug('inside before trigger');
        //Author: Sergio Flores
        //Date: 9-18
        //Functionality, converting the existing Workflows on Leads 'Safe to Send'and 'Not Safe to Send' into Code
        List<Lead> updatedCadenceStageList = new List<Lead>();
        for (Lead ld : newRecords)
        {
            userIds.add(ld.OwnerId);

            if(ld.Cadence_Stage__c != null)
            {
                String cadenceStage = ld.Cadence_Stage__c;
                if(cadenceStage.Contains('/'))
                {
                    List<String> cadenceStageString = cadenceStage.split('/', 2);
                    ld.Status = cadenceStageString[0];
                    ld.Lead_Close_Reason__c = cadenceStageString[1];
                }
                else
                {
                    ld.Status = cadenceStage;
                    ld.Lead_Close_Reason__c = null;
                }
            }

            //Sergio Flores
            //Date: 03/04/2019
            //W--011135
            if(ld.Status !=null)
            {
                system.debug('Inside status insert');
                Lead_Contact_DG_Status_Update__c leadDGStatus = Lead_Contact_DG_Status_Update__c.getValues(ld.Status);
                if(leadDGStatus !=null)
                    ld.DG_Lead_Status__c = leadDGStatus.DG_Lead_Status__c;
                if(ld.Status == '5 - Closed')
                {
                    Lead_Contact_DG_Status_Update__c leadDGStatusClosed = Lead_Contact_DG_Status_Update__c.getValues(ld.Lead_Close_Reason__c);
                    if(leadDGStatusClosed !=null)
                        ld.DG_Lead_Status__c = leadDGStatusClosed.DG_Lead_Status__c;
                }
            }

            //Name: Chris Salgado Date: 4/21/20 Purpose: W-001799
            if(userinfo.getProfileId() == partnerCommunityProfileId){
                contactIdSet.add(ld.Partner_Representative__c);
            }
        }

        if (!userIds.isEmpty()) {
            fields = [SELECT Id,Lead_Field__c,User_Field__c
            FROM Territory_Mapping__mdt
            WHERE Lead_Field__c != null];

            for (Territory_Mapping__mdt field : fields) {
                userFields += field.User_Field__c + ',';
            }

            userFields = userFields.removeEnd(',');

            if (userFields != '') {
                userQuery = 'SELECT Id,' + userFields
                        + ' FROM USER WHERE IsActive=True AND Id in :UserIds';

                userList = Database.query(userQuery);
                if (!userList.isEmpty()) {
                    userMap = New Map<Id,User>(userList);
                }
            }
        }

        //Name: Chris Salgado Date: 4/21/20 Purpose: W-001799
        Map<Id, Id> contactIdToAccountId = new Map<Id, Id>();
        Map<Id, Boolean> contactIdToAccountWIShare = new Map<Id, Boolean>();
        if(!contactIdSet.isEmpty()) {
            for(Contact con : [SELECT Id, AccountId, Account.wi__Share_to_WI__c FROM Contact WHERE Id IN :contactIdSet]){
                contactIdToAccountId.put(con.Id, con.AccountId);
                //Need to check if the Account is Shared to WI otherwise it won't save
                contactIdToAccountWIShare.put(con.Id, con.Account.wi__Share_to_WI__c);
            }
        }

        for(Lead ld : newRecords)
        {
            if (!userMap.isEmpty() && userMap.containsKey(ld.OwnerId) && !fields.isEmpty() && String.valueOf(ld.OwnerId).startsWith('005'))
            {
                for (Territory_Mapping__mdt field : fields) {
                    if (ld.get(field.Lead_Field__c) != userMap.get(ld.OwnerId).get(field.User_Field__c)) {
                        ld.put(field.Lead_Field__c , userMap.get(ld.OwnerId).get(field.User_Field__c));
                    }
                }
            }

            //Name: Chris Salgado Date: 4/21/20 Purpose: W-001799
            if(!contactIdToAccountId.isEmpty() && contactIdToAccountWIShare.get(ld.Partner_Representative__c)) {
                ld.wi__Share_to_WI__c = true;
                ld.wi__Associated_Partner__c = contactIdToAccountId.get(ld.Partner_Representative__c);
            }
        }


        LeadGateway.updateSafeToSend(newRecords);

    }

    public void onBeforeUpdate(List<Lead> newRecords)
    {
        //Set of owners
        Set<Id> userIds = New Set<Id>();
        // String Variable to store the user query
        string userQuery = '';
        // String variable used to store the user fields for territory Mapping
        string userFields = '';
        Map<id, Lead> oldmap =  (Map<Id, Lead>)Trigger.oldMap;
        String DGLeadStatusValues = 'Prospect, Engaged, Open, Re-Qualified';
        String warmInPolicy = 'warm sla in-policy';
        String warmOutPolicy = 'warm sla out-of-policy';
        String hotInPolicy = 'hot sla in-policy';
        String hotOutPolicy = 'hot sla out-of-policy';
        Map<Id, Lead> leadIdToLeadMap = new Map<Id, Lead>();

        string ownersSLANotToSend = System.Label.ownersSLANotToSend;
        Set<String> userIdNotToSendSLAAlerts = new Set<String>();
        for(String s : ownersSLANotToSend.Split(',') )
        {
            userIdNotToSendSLAAlerts.add(s);
        }

        Date today = System.Today();

        for(Lead ld : newRecords)
        {
            userIds.add(ld.OwnerId);

            Lead oldLead = (Lead)Trigger.oldMap.get(ld.ID);

            if((ld.Cadence_Stage__c != oldLead.Cadence_Stage__c) && (ld.Lead_Close_Reason__c == oldLead.Lead_Close_Reason__c || ld.Status == oldLead.Status ))
            {
                system.debug('Inside Cadence Stage before update');
                String cadenceStage = ld.Cadence_Stage__c;
                if(cadenceStage.Contains('/'))
                {
                    List<String> cadenceStageString = cadenceStage.split('/', 2);
                    ld.Status = cadenceStageString[0];
                    ld.Lead_Close_Reason__c = cadenceStageString[1];
                }
                else
                {
                    ld.Status = cadenceStage;
                    ld.Lead_Close_Reason__c = null;
                }


                system.debug('Status ' + ld.Status + ' Outcome Reason ' + ld.Lead_Close_Reason__c);
            }

            //Sergio Flores
            //Date: 03/04/2019
            //W--011135
            //This is to update the lead DG status whenever status is updated on a lead
            if(ld.Status != oldLead.Status || (ld.Lead_Close_Reason__c != oldLead.Lead_Close_Reason__c && ld.Status == '5 - Closed') )
            {
                system.debug('Inside status update');
                Lead_Contact_DG_Status_Update__c leadDGStatus = Lead_Contact_DG_Status_Update__c.getValues(ld.Status);
                if(leadDGStatus !=null)
                    ld.DG_Lead_Status__c = leadDGStatus.DG_Lead_Status__c;
                if(ld.Status == '5 - Closed')
                {

                    List<Lead_Contact_DG_Status_Update__c> leadContactStatusCSList = Lead_Contact_DG_Status_Update__c.getall().values();
                    if(!leadContactStatusCSList.isEmpty())
                    {
                        for(Lead_Contact_DG_Status_Update__c leadContactStatusCS : leadContactStatusCSList)
                        {
                            if(leadContactStatusCS.Name == ld.Lead_Close_Reason__c)
                                ld.DG_Lead_Status__c = leadContactStatusCS.DG_Lead_Status__c;
                            else if(ld.Lead_Close_Reason__c == leadContactStatusCS.Lead_Outcome_Reason__c)
                                ld.DG_Lead_Status__c = leadContactStatusCS.DG_Lead_Status__c;
                        }
                    }
                }
            }
            String ownerId = (String)ld.OwnerId;
            Boolean ownedByRep = false;

            if(ownerId.startsWith('005') && !userIdNotToSendSLAAlerts.contains(ownerId))
                ownedByRep = true;
            String startDate = System.label.PDGGoLiveDate;
            Date goliveDate = Date.valueOf(startDate);

            system.debug('before ownership SLA changed ' + ld);

            //Sergio Flores
            //Date: 01/03/2020
            //W-013772
            if(ld.ownerId == oldLead.ownerId && (ld.Rep_Owned_Warm_SLA_Date__c == null && ld.Rep_Owned_Hot_SLA_Date__c == null)
                    && ownedByRep
                    //The above checks to see if a rep already owns the lead and the SLA dates haven't been stamped
                    ||
                    //The below checks to see if rep ownership changes to another rep
                    (ld.ownerId != oldlead.ownerId
                            && ownedByRep)
                    ||
                    //The below checks to see if only the hot or warm sla dates are changed and the owner is a rep
                    ( (ld.Hot_SLA_Date__c != oldLead.Hot_SLA_Date__c || ld.Warm_SLA_Date__c != oldlead.Warm_SLA_Date__c)
                            && ownedByRep)  )
            {
                //Basically here we check to see if its owned by a rep, if so then we can start the PDG SLA time tracking
                //Eddie Wong || 04/27/2020 || W-005127 || To exclude leads that already have dispensation and conversion populated
                if(ld.Warm_SLA_Date__c !=null && ld.Warm_SLA_Date__c >= goliveDate && ld.Dispensation_SLA_QL__c == null && ld.Conversion_SLA_QL__c == null)
                    ld.Rep_Owned_Warm_SLA_Date__c = today;
                else if(ld.Hot_SLA_Date__c !=null && ld.Hot_SLA_Date__c >= goliveDate && ld.Dispensation_SLA_QL__c == null && ld.Conversion_SLA_QL__c == null)
                    ld.Rep_Owned_Hot_SLA_Date__c = today;
                else if(ld.Warm_SLA_Date__c != oldLead.Warm_SLA_Date__c && ld.Dispensation_SLA_QL__c != null && ld.Conversion_SLA_QL__c != null)
                    ld.Rep_Owned_Warm_SLA_Date__c = today;
                else if(ld.Hot_SLA_Date__c != oldLead.Hot_SLA_Date__c && ld.Dispensation_SLA_QL__c != null && ld.Conversion_SLA_QL__c != null)
                    ld.Rep_Owned_Hot_SLA_Date__c = today;
            }

            system.debug('PDG SLA Before DG Lead Status Change ' + ld.Dispensation_SLA_QL__c);

            if(ld.DG_Lead_Status__c != null && ld.DG_Lead_Status__c != oldLead.DG_Lead_Status__c)
            {
                if(!DGLeadStatusValues.contains(ld.DG_Lead_Status__c)){
                    if(warmInPolicy.equalsIgnoreCase(ld.Dispensation_SLA_QL__c) && ld.Business_Days_Since_Warm_SLA__c <= 2){  //W-011325
                        ld.Dispensation_SLA_QL__c = 'Warm SLA In-policy Completed';
                    }
                    if(warmOutPolicy.equalsIgnoreCase(ld.Dispensation_SLA_QL__c)){ //W-011330
                        ld.Dispensation_SLA_QL__c = 'Warm SLA Out-of-policy Completed';
                    }
                    if(hotInPolicy.equalsIgnoreCase(ld.Dispensation_SLA_QL__c) && ld.Business_Days_Since_Hot_SLA__c <= 1){ //W-011332
                        ld.Dispensation_SLA_QL__c = 'Hot SLA In-policy Completed';
                    }
                    if(hotOutPolicy.equalsIgnoreCase(ld.Dispensation_SLA_QL__c)){ //W-011336
                        ld.Dispensation_SLA_QL__c = 'Hot SLA Out-of-policy Completed';
                    }

                }
                if(ld.DG_Lead_Status__c != null && (ld.DG_Lead_Status__c.startsWithIgnoreCase('recycle') || ld.DG_Lead_Status__c.startsWithIgnoreCase('rejected') || ld.DG_Lead_Status__c.startsWithIgnoreCase('converted'))){
                    if(warmInPolicy.equalsIgnoreCase(ld.Conversion_SLA_QL__c)){  //W-011338
                        ld.Conversion_SLA_QL__c = 'Warm SLA In-policy Completed';
                    }
                    if(warmOutPolicy.equalsIgnoreCase(ld.Conversion_SLA_QL__c)){ //W-011343
                        ld.Conversion_SLA_QL__c = 'Warm SLA Out-of-policy Completed';
                    }
                    if(hotInPolicy.equalsIgnoreCase(ld.Conversion_SLA_QL__c)){ //W-011345
                        ld.Conversion_SLA_QL__c = 'Hot SLA In-policy Completed';
                    }
                    if(hotOutPolicy.equalsIgnoreCase(ld.Conversion_SLA_QL__c)){ //W-011336
                        ld.Conversion_SLA_QL__c = 'Hot SLA Out-of-policy Completed';
                    }
                }
            }

            system.debug('PDG SLA Afer DG Lead Status Change ' + ld.Dispensation_SLA_QL__c);
            System.debug('eddie inside ld.Rep_Owned_Warm_SLA_Date__c' + ld.Rep_Owned_Warm_SLA_Date__c); //2020-04-28 00...
            System.debug('eddie inside oldLead.Rep_Owned_Warm_SLA_Date__c' + oldLead.Rep_Owned_Warm_SLA_Date__c); //2020-04-28 00:00:00
            System.debug('eddie inside ownedByRep' + ownedByRep);  //true
            System.debug('eddie inside ld.ownerId' + ld.ownerId); //0052R000009pKDTQA2
            System.debug('eddie inside oldLead.ownerId' + oldLead.ownerId); //00544000008plr7AAA
            System.debug('eddie inside system.today' + System.Today()); //020-04-28 00:00:00
            //Here we check to see if the time stamping has started, if it has then we need to update the dispensation, if the owner changes in the same day that also needs to be accounted for
            //Eddie Wong || 04/27/2020 || W-005127 || To exclude leads that already have dispensation and conversion populated
            if(ld.Rep_Owned_Warm_SLA_Date__c != null
                    && (ld.Rep_Owned_Warm_SLA_Date__c != oldLead.Rep_Owned_Warm_SLA_Date__c
                        || (ownedByRep && ld.ownerId != oldLead.ownerId && ld.Status != '5 - Closed') )
                    && ld.Rep_Owned_Warm_SLA_Date__c == System.Today() ){  //W-011318
                System.debug('eddie inside ld.Rep_Owned_Warm_SLA_Date__c != null');
                ld.Dispensation_SLA_QL__c = 'Warm SLA In-policy';
            }
            //Here we check to see if the time stamping has started, if it has then we need to update the dispensation, if the owner changes in the same day that also needs to be accounted for
            //Eddie Wong || 04/27/2020 || W-005127 || To exclude leads that already have dispensation and conversion populated
            if(ld.Rep_Owned_Hot_SLA_Date__c != null
                    && (ld.Rep_Owned_Hot_SLA_Date__c != oldLead.Rep_Owned_Hot_SLA_Date__c
                        || (ownedByRep && ld.ownerId != oldLead.ownerId && ld.Status != '5 - Closed') )
                    && ld.Rep_Owned_Hot_SLA_Date__c == System.Today() ){  //W-011322
                ld.Dispensation_SLA_QL__c = 'Hot SLA In-policy';
            }

            System.debug('before sla logic  ' + ld);

            if( (ld.Dispensation_SLA_QL__c !=null || ld.Conversion_SLA_QL__c !=null)
                    && ( (ld.Dispensation_SLA_QL__c != oldLead.Dispensation_SLA_QL__c || ld.Conversion_SLA_QL__c != oldLead.Conversion_SLA_QL__c) || (ld.ownerId != oldlead.ownerId) )
                    && ownerId.startsWith('005')
                    && !userIdNotToSendSLAAlerts.contains(ownerId)
                    && (ld.Hot_SLA_Date__c >= goliveDate || ld.Warm_SLA_Date__c >= goliveDate)
                    && ld.Status != '5 - Closed')
            {
                leadIdToLeadMap.put(ld.Id, ld);
            }

            //Sergio Flores
            //Date 09/13/2019
            //W-013044
            //Here we check to see if the time stamping has started, if it has then we need to update the conversion, if the owner changes in the same day that also needs to be accounted for
            //also email alerts should not be sent for this scenario
            //Eddie Wong || 04/27/2020 || W-005127 || To exclude leads that already have dispensation and conversion populated
            if( (ld.Rep_Owned_Warm_SLA_Date__c != oldLead.Rep_Owned_Warm_SLA_Date__c
                    || (ownedByRep && ld.ownerId != oldLead.ownerId && ld.Status != '5 - Closed') )
                    && ld.Rep_Owned_Warm_SLA_Date__c == today)
            {
                ld.Conversion_SLA_QL__c = 'Warm SLA In-policy';
            }

            //Sergio Flores
            //Date 09/13/2019
            //W-013046
            //Here we check to see if the time stamping has started, if it has then we need to update the conversion, if the owner changes in the same day that also needs to be accounted for
            //also email alerts should not be sent for this scenario
            //Eddie Wong || 04/27/2020 || W-005127 || To exclude leads that already have dispensation and conversion populated
            if( (ld.Rep_Owned_Hot_SLA_Date__c != oldLead.Rep_Owned_Hot_SLA_Date__c
                    || (ownedByRep && ld.ownerId != oldLead.ownerId && ld.Status != '5 - Closed') )
                    && ld.Rep_Owned_Hot_SLA_Date__c == today)
            {
                ld.Conversion_SLA_QL__c = 'Hot SLA In-policy';
            }
        }

        //Sergio FLores
        //Date: 03/27/2020
        //W-004839
        if(!leadIdToLeadMap.isEmpty() && RecursionHandler.IsLeadSLAQueuableExecuted == false)
        {
            system.debug('inside checking to see lead status history ' + leadIdToLeadMap);
            LeadGateway.checkStatusHistory(leadIdToLeadMap);
        }

        LeadGateway.updateSafeToSend(newRecords);

        System.debug('inside AFTER leadgateway'); //eddie add

        if (!userIds.isEmpty()) {
            fields = [SELECT Id,Lead_Field__c,User_Field__c
            FROM Territory_Mapping__mdt
            WHERE Lead_Field__c != null];

            for (Territory_Mapping__mdt field : fields) {
                userFields += field.User_Field__c + ',';
            }

            userFields = userFields.removeEnd(',');

            if (userFields != '') {
                userQuery = 'SELECT Id,' + userFields
                        + ' FROM USER WHERE IsActive=True AND Id in :UserIds';

                userList = Database.query(userQuery);
                if (!userList.isEmpty()) {
                    userMap = New Map<Id,User>(userList);
                }
            }
        }

        for(Lead ld : newRecords)
        {
            Lead ldOld = (Lead)Trigger.oldMap.get(ld.ID);

            if (!userMap.isEmpty() && userMap.containsKey(ld.OwnerId)
                    && !fields.isEmpty() && ld.OwnerId != ldOld.OwnerId
                    && String.valueOf(ld.OwnerId).startsWith('005')) {

                for (Territory_Mapping__mdt field : fields) {
                    if (ld.get(field.Lead_Field__c) != userMap.get(ld.OwnerId).get(field.User_Field__c)) {
                        ld.put(field.Lead_Field__c , userMap.get(ld.OwnerId).get(field.User_Field__c));
                    }
                }
            }
        }

    }

    public void onAfterInsert(List<Lead> newRecords)
    {
        System.debug('inside leadhandler onafterinsert'); //eddie add
        Map<id, Lead> oldmap =  (Map<Id, Lead>)Trigger.oldMap;
        Map<id, Lead> newmap =  (Map<Id, Lead>)Trigger.newMap;
        Map<String, List<Lead>> leadTaskEmailMap = new Map<String, List<Lead>>();
        Map<Id, Lead> leads = new Map<Id, Lead>([SELECT Id, Conversion_SLA_QL__c, Dispensation_SLA_QL__c,CreatedBy.Name,OwnerId,Owner.Profile.Id FROM Lead WHERE Id IN:newmap.keySet()]); //EWONG || 10/22/2020 || W-006542 || Added more fields to query
        System.debug('eddie check leads1 = ' + JSON.serializePretty(leads));
        System.debug('eddie check leads = ' + leads);

        //added by sharma || 31st JAN 2020
        Map<String, Lead> leadUTMToUTM = new Map<String, Lead>();

        for(Lead ld : newRecords)
        {

            //added by sharma || 19 JAN 2020 || START
            if (ld.Most_Recent_Campaign_ID__c != null
                    && (ld.UTM_Source__c      != null
                    || ld.UTM_Medium__c       != null)) {
                System.debug('inside lead handler utm field track' + ld.UTM_Campaign_Name__c);
                System.debug('inside lead handler utm field track' + ld.Most_Recent_Campaign_ID__c);
                leadUTMToUTM.put(ld.Id, ld);
            }
            //added by sharma || 19 JAN 2020 || END

            // Fill the Set if owner is MQL Staging Queue
            if(ld.ownerid == Label.MQLStagingQueueId_Original){
                leadset.add(ld.id);
            }
            //if(contactToLeadMap == null ) contactToLeadMap = contactToLeadMap = new Map<Id,Id>();
            if(ld.RecordTypeId == System.Label.Altx_Partner_Lead_Record_Type_Id && ld.Partner_Representative__c != null){
                leadToContactMap.put(ld.id,ld.Partner_Representative__c);
                system.debug('@@--contactToLeadMap-->>'+leadToContactMap);
            }

            //Name: Eddie Wong
            //WOrk: W-006542
            //Date: 10/22/2020
            //Desc: Lead Sharing for XDR leads
            System.debug('eddie check ld.Owner.ProfileId = ' + leads.get(ld.Id));
            if(leads.get(ld.Id).Owner.Profile.Id == System.Label.XDR_Partner_Community_Profile_Id && ld.RecordTypeId == System.Label.Altreyx_Lead_Record_Type_Id){
                leadIdToXDRMap.put(ld.Id, ld.OwnerId);
                System.debug('***inside xdr partner onAfterInsert = ' + leadIdToXDRMap);
            }
        }

        //added by sharma || 19 JAN 2020 || START
        if(!leadUTMToUTM.isEmpty() && Recursionhandler.IsLeadUTMTriggerExecuted == false && Recursionhandler.IsLeadSLAQueuableExecuted == false){
            Recursionhandler.IsLeadUTMTriggerExecuted = true;
            System.debug('inside !leadUTMToUTM.isEmpty() ' + Recursionhandler.IsLeadUTMTriggerExecuted);
            /*UTMQueueable executeUTMFieldTracking = new UTMQueueable(leadUTMToUTM);
            ID jobID = System.enqueueJob(executeUTMFieldTracking);*/
            Map<String,Contact> contactUTMToUTM = new Map<String,Contact>();
            UTMQueueable.executeUTM(leadUTMToUTM, contactUTMToUTM);

        }
        //added by sharma || 19 JAN 2020 || END*/
    }

    public void onAfterUpdate(List<Lead> newRecords)
    {
        Map<id, Lead> oldmap =  (Map<Id, Lead>)Trigger.oldMap;
        Map<id, Lead> newmap =  (Map<Id, Lead>)Trigger.newMap;
        Map<Id, Lead> leads = new Map<Id, Lead>([Select id,Conversion_SLA_QL__c, Dispensation_SLA_QL__c,OwnerId,Owner.Profile.Id from Lead where Id IN:  newmap.keySet()]); //EWONG || 10/22/2020 || W-006542 || Added more fields to query
        Map<String, Lead> leadEmailToLead = new Map<String, Lead>();
        Map<String, Lead> leadUTMToUTM = new Map<String, Lead>(); //eddie add
        Boolean emailChanged = false;
        contactToAccountMap = LeadGateway.createContactToAccountMap(contactIds);

        // Added by: Sharma Nemani | W-012857 & W-013059 | Date: 01/14/2020 --> START
        Map<Id,String> mapLeadsCase1 = new Map<Id,String>();
        Map<Id,String> mapLeadsCase2 = new Map<Id,String>();
        // Added by: Sharma Nemani | W-012857 & W-013059 | Date: 01/14/2020 --> END

        for(Lead ld : newRecords){



            // Added by: Sharma Nemani | W-012857 & W-013059 | Date: 01/14/2020 --> START
            // Case 1 --- W-012857
            if((oldmap != null && ld.OwnerId != oldmap.get(ld.Id).OwnerId && String.valueOf(ld.OwnerId).startswith('005')) &&
                    (ld.wi__Share_to_WI__c || ld.RecordTypeId == '012E0000000VRBaIAO')){
                // mapLeadsCase1.put(ld.Id,ld.Email); //Eddie Wong W-004799 04/13/2020
            }

            // Case 2 --- W-013059
            if(ld.CreatedBy.Name  != 'Webinfinity Integration' && ld.wi__Share_to_WI__c && ld.wi__Associated_Partner__c!=null &&
                    ld.Deal_Summary__c!=null && ld.Deal_Summary__c != oldmap.get(ld.Id).Deal_Summary__c){
                //  mapLeadsCase2.put(ld.Id,ld.Email); //Eddie Wong W-004799 04/13/2020
            }

            // Added by: Sharma Nemani | W-012857 & W-013059 | Date: 01/14/2020 --> END

            Lead oldLead = (Lead)Trigger.oldMap.get(ld.id);
            contactIds.add(ld.Partner_Representative__c);
            contactIds.add(oldLead.Partner_Representative__c);
            system.debug('contactIds in new map '+contactIds);

            // Fill the Set if owner is MQL Staging Queue
            if(ld.ownerid == Label.MQLStagingQueueId_Original)
            {
                leadset.add(ld.id);
            }
            //Get the Lead Ids along with their partner representative to create lead sharing
            if(Recursionhandler.IsleadTriggerExecuted == false) {
                //NON XDR Leads
                if (leads.get(ld.Id).Owner.Profile.Id != System.Label.XDR_Partner_Community_Profile_Id) {
                    if ((ld.OwnerId != oldLead.OwnerId) ||
                            (ld.RecordTypeId == System.Label.Altx_Partner_Lead_Record_Type_Id &&
                                    ld.Partner_Representative__c != oldLead.Partner_Representative__c &&
                                    contactToAccountMap.get(ld.Partner_Representative__c) != contactToAccountMap.get(oldLead.Partner_Representative__c)
                            )) {
                        if (!leadToContactMap.containsKey(ld.id) && ld.Partner_Representative__c != NULL) {
                            leadToContactMap.put(ld.id, ld.Partner_Representative__c);
                            LeadIds_del.add(oldLead.Id);
                        }
                    }
                    //Name: Eddie Wong
                    //WOrk: W-006542
                    //Date: 10/22/2020
                    //Desc: Lead Sharing for XDR leads
                    
                    //XDR Leads
                } else if (leads.get(ld.Id).Owner.Profile.Id == System.Label.XDR_Partner_Community_Profile_Id && ld.OwnerId != oldLead.OwnerId && ld.RecordTypeId == System.Label.Altreyx_Lead_Record_Type_Id) {
                    leadIdToXDRMap.put(ld.Id, ld.OwnerId);
                    System.debug('***inside xdr partner onAfterUpdate = ' + leadIdToXDRMap);
                }
            }

            System.debug('lg> ld.Campaign_Channel_Attribution__c:'
                    + ld.Campaign_Channel_Attribution__c);
            System.debug('lg> oldLead.Campaign_Channel_Attribution__c:'
                    + oldLead.Campaign_Channel_Attribution__c);

            if(ld.Lead_Source_Most_Recent__c != null
                    && ld.Lead_Source_Most_Recent__c != oldLead.Lead_Source_Most_Recent__c) {

                if(ld.Most_Recent_Campaign_ID__c != null) {
                    cca_leadIds.add(ld.Id);
                    leadsWithLSMR.add(ld.Id);
                    cca_campaignIds.add(ld.Most_Recent_Campaign_ID__c);
                    cca_leadIdToMostRecentCampaignId.put(ld.Id, ld.Most_Recent_Campaign_ID__c);
                    cca_leadIdToLeadSourceMostRecent.put(ld.Id, ld.Lead_Source_Most_Recent__c);
                }

            }
            else if(ld.Lead_Source_Most_Recent__c == null
                    && ld.Campaign_Channel_Attribution__c != null
                    && ld.Campaign_Channel_Attribution__c
                    != oldLead.Campaign_Channel_Attribution__c) {

                String cca = ld.Campaign_Channel_Attribution__c;

                if(CampaignChannelAttributionHelper.checkCCA(cca)) {
                    List<String> temp_val = cca.split(';');
                    cca_leadIds.add(ld.Id);
                    cca_campaignIds.add(temp_val.get(0).trim());
                    cca_leadIdToMostRecentCampaignId.put(ld.Id, (temp_val.get(0).trim()));
                    cca_leadIdToLeadSourceMostRecent.put(ld.Id, (temp_val.get(2).trim()));
                }

            }


            //Sergio Flores
            //Date: 08/07/2019
            //W-011320
            //Need to check if following GPDR fields are changed on a contact, if they are
            //need to update related individual object record
            if(ld.Email !=null && ld.Safe_to_Send__c != oldLead.Safe_to_Send__c && ld.Email == oldLead.Email)
            {
                system.debug('inside lead handler safe to send updated');
                leadEmailToLead.put(ld.Email, ld);
            }

            //W-011320
            if(ld.Email !=null && ld.Email != oldLead.Email && ld.Safe_to_Send__c == oldLead.Safe_to_Send__c)
            {
                system.debug('inside lead handler email updated');
                emailChanged = true;
                leadEmailToLead.put(ld.Email, ld);
            }

            system.debug('beofre UTM criteria ' + ld.Most_Recent_Campaign_ID__c + ld.UTM_Source__c + ld.UTM_Medium__c);
            //Eddie Wong
            //Date: 12/20/2019
            //W-013648
            //To check if UTM fields in Lead are being updated

            //When lead is INSERTED (or UPDATED) with UTM values, we check to make sure Most Recent Campaign ID, UTM Source, and UTM Medium fields are not blank
            //When Campaign Member is created and lead is updated with UTM values, we check to make sure Most Recent Campaign ID, UTM Source, and UTM Medium fields are not blank
            if (ld.Most_Recent_Campaign_ID__c != null
                    && (ld.UTM_Source__c      != null
                    || ld.UTM_Medium__c       != null)) {
                System.debug('inside lead handler utm field track 2' + ld.UTM_Campaign_Name__c);
                leadUTMToUTM.put(ld.Id, ld);
            }

            // Added by: Sharma Nemani | W-002548 | To handle recursion |Date: 01/16/2020 --> START
            if(Recursionhandler.IsLeadSendEmailExecuted == false && (!mapLeadsCase1.isEmpty() || !mapLeadsCase2.isEmpty())){ //Eddie Wong W-004799 04/13/2020
                System.debug('inside before leadgateway');
                LeadGateway.sendEmail(mapLeadsCase1,mapLeadsCase2);
                Recursionhandler.IsLeadSendEmailExecuted = true;
            }
            // Added by: Sharma Nemani | W-002548 |Date: 01/16/2020 --> END
        }

        //Adding toggle to execute individual functionality
        string toggleForIndividual = System.Label.Individual_Toggle;

        //Sergio Flores
        //Date: 08/07/2019
        //W-011320
        if(!leadEmailToLead.isEmpty() && RecursionHandler.IsLeadTriggerExecuted == false && toggleForIndividual == 'True' && Recursionhandler.IsLeadSLAQueuableExecuted == false)
        {
            RecursionHandler.IsLeadTriggerExecuted = true;
            LeadQueueable executeCreateIndividualRecord = new LeadQueueable(leadEmailToLead, emailChanged);
            ID jobID = System.enqueueJob(executeCreateIndividualRecord);

        }


        //Eddie Wong
        //Date: 12/20/2019
        //W-013648
        //To call queueable class - UTMQueueable
        System.debug('eddie inside after update leadUTMToUTM.size' + leadUTMToUTM.size());
        System.debug('eddie inside Recursionhandler.IsLeadUTMTriggerExecuted' + Recursionhandler.IsLeadUTMTriggerExecuted);

        if(!leadUTMToUTM.isEmpty() && Recursionhandler.IsLeadUTMTriggerExecuted == false && Recursionhandler.IsLeadSLAQueuableExecuted == false && RecursionHandler.IsLeadTriggerExecuted == false){
            Recursionhandler.IsLeadUTMTriggerExecuted = true;
            System.debug('inside !leadUTMToUTM.isEmpty() eddie ' + Recursionhandler.IsLeadUTMTriggerExecuted);
            /*UTMQueueable executeUTMFieldTracking = new UTMQueueable(leadUTMToUTM);
            ID jobID = System.enqueueJob(executeUTMFieldTracking);*/
            Map<String,Contact> contactUTMToUTM = new Map<String,Contact>();
            UTMQueueable.executeUTM(leadUTMToUTM, contactUTMToUTM);
        }


    }

    public void onAfterDelete (List<Lead> newRecords)
    {
        for(Lead ld : newRecords)
        {
            LeadIds_del.add(ld.Id);
        }
    }


    public void andFinally(){
        // Check that we are not in future invocation and eun the assignment rules
        System.debug('lg> cca_leadIds:' + cca_leadIds);
        System.debug('lg> leadsWithLSMR:' + leadsWithLSMR);
        System.debug('lg> cca_campaignIds:' + cca_campaignIds);
        System.debug('lg> cca_leadIdToMostRecentCampaignId:'
                + cca_leadIdToMostRecentCampaignId);
        System.debug('lg> cca_leadIdToLeadSourceMostRecent:'
                + cca_leadIdToLeadSourceMostRecent);

        Map<Id, CampaignMember> lead_id_to_recent_cm
                = LeadGateway.getCampaignMemberFromCCA(cca_leadIds,
                        cca_campaignIds,
                        cca_leadIdToMostRecentCampaignId);
        LeadGateway.updateCampaignMemberCCA(lead_id_to_recent_cm,
                cca_leadIdToLeadSourceMostRecent,
                leadsWithLSMR);
        if(! LeadIds_del.isEmpty()){
            LeadGateway.deleteLeadshare(LeadIds_del);
        }
        if(!leadToContactMap.isEmpty()){
            LeadGateway.shareLeadWithUsers(leadToContactMap);
            Recursionhandler.IsleadTriggerExecuted = true;
        }

        //Name: Eddie Wong
        //WOrk: W-006542
        //Date: 10/22/2020
        //Desc: Lead Sharing for XDR leads
        if(!leadIdToXDRMap.isEmpty()) {
            LeadGateway.shareLeadWithXDRUsers(leadIdToXDRMap);
            Recursionhandler.IsleadTriggerExecuted = true;
        }
    }
}