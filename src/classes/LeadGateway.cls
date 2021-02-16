public without sharing class LeadGateway
{

    public static List<CampaignMember> getCampaignMembers(Set<Id> lead_ids, Set<Id> campaign_ids) {
        List<CampaignMember> cms = new List<CampaignMember>();

        for(CampaignMember cm : [SELECT Id
                ,Lead_Source_Most_Recent__c
                ,LeadId
                ,CampaignId
        FROM CampaignMember
        WHERE LeadId IN :lead_ids
        AND CampaignId IN :campaign_ids
        AND hasResponded = true
        ORDER BY FirstRespondedDate DESC, createddate DESC]) {
            cms.add(cm);
        }

        return cms;
    }

    /* 
* Get campaign member corresponding to lead id and id of campaign
* mentioned in "Campaign Channel Attribution" field.
*/
    public static Map<Id, CampaignMember> getCampaignMemberFromCCA(Set<Id> lead_ids
            , Set<Id> campaign_ids
            , Map<Id, Id> leadIdToMostRecentCampaignId) {
        Map<Id, CampaignMember> lead_id_to_recent_cm = new Map<Id, CampaignMember>();
        List<CampaignMember> cms = LeadGateway.getCampaignMembers(lead_ids, campaign_ids);

        System.debug('lg> cms:' + cms);

        for(CampaignMember cm : cms) {
            Id campaign_id = leadIdToMostRecentCampaignId.get(cm.LeadId);
            if(cm.CampaignId == campaign_id) {
                lead_id_to_recent_cm.put(cm.LeadId, cm);
            }
        }

        System.debug('lg> lead_id_to_recent_cm:' + lead_id_to_recent_cm);

        return lead_id_to_recent_cm;
    }

    /*
* Update Channel field on Campaign Member from third value stored
* in "Campaign Channel Attribution" field on lead
*/
    public static void updateCampaignMemberCCA(Map<Id, CampaignMember> lead_id_to_recent_cm,
            Map<Id, String> leadIdToLeadSourceMostRecent,
            Set<Id> leadsWithLSMR) {
        List<CampaignMember> cms = new List<CampaignMember>();

        for(Id lead_id : lead_id_to_recent_cm.keySet()) {
            CampaignMember cm = lead_id_to_recent_cm.get(lead_id);
            if(leadIdToLeadSourceMostRecent.containsKey(cm.LeadId)) {

                String lead_source_most_recent = leadIdToLeadSourceMostRecent.get(cm.LeadId);
                System.debug('lg> leadsWithLSMR.contains(cm.LeadId):' + leadsWithLSMR.contains(cm.LeadId));

                if(leadsWithLSMR.contains(cm.LeadId)) {

                    System.debug('lg> cm.Lead_Source_Most_Recent__c:' + cm.Lead_Source_Most_Recent__c);

                    if(cm.Lead_Source_Most_Recent__c == null) {
                        cm.Lead_Source_Most_Recent__c = lead_source_most_recent;
                        cms.add(cm);
                    }

                } else {
                    cm.Lead_Source_Most_Recent__c = lead_source_most_recent;
                    cms.add(cm);
                }

            }
            System.debug('lg> cm.Lead_Source_Most_Recent__c:'
                    + cm.Lead_Source_Most_Recent__c);

        }

        try {
            update cms;
        } catch (Exception ex) {
            for(Lead l : ((List<Lead>) Trigger.new)) { Exception cause = ex.getCause(); String msg = cause != null ? cause.getMessage() : ex.getMessage(); l.addError(msg); }
        }
    }

    /********************** For Lead Sharing ****************************/
    /*public static void shareLeadWithUsers(Map<Id,Id> leadToContactMap){
map<Id ,Id> userid= new map<Id,Id>();
for(User u :[select id,contactid from User where contactid in:leadtocontactMap.values() and contactid!=null]){
userid.put(u.contactid ,u.id); 
}
System.debug('userid--> '+userid);
List<LeadShare> leadShareList = new List<LeadShare>();
for(Id leadId:leadToContactMap.keyset()){
LeadShare lead_share = new LeadShare();
lead_share.LeadAccessLevel='Edit';
lead_share.LeadId=leadId;
if(userid.containsKey(leadToContactMap.get(leadId)))
{   lead_share.UserOrGroupId=userid.get(leadToContactMap.get(leadId));
leadShareList.add(lead_share);
}
system.debug('leadShareList @@ '+leadShareList+' ------>'+leadToContactMap.get(leadId));

}  
if(! leadShareList.isEmpty()){
insert leadShareList;
}
}*/
    public static void shareLeadWithUsers(Map<Id,Id> leadToContactMap){
        Map<Id,Id> contactToAccountMap = new Map<Id,Id>();
        Map<Id,List<Id>> AccountToUserMap = new  Map<Id,List<Id>>();
        List<LeadShare> leadShareList = new List<LeadShare>();
        system.debug('leadToContactMap.size() in gateway is@##@ '+leadToContactMap);
        for(Contact con : [SELECT Id, AccountId FROM Contact WHERE Id In : leadToContactMap.values() and AccountId != null]){
            contactToAccountMap.put(con.Id, con.AccountId);
        }
        system.debug('contactToAccountMap size is '+contactToAccountMap.size());
        for(User user : [SELECT Id, ContactId, Contact.AccountId, AccountId FROM User where AccountId In : contactToAccountMap.values() and ISACTIVE = true]){
            if(AccountToUserMap.containsKey(user.Contact.AccountId)){
                list<id> userIds = AccountToUserMap.get(user.Contact.AccountId);
                userIds.add(user.id);
                AccountToUserMap.put(user.Contact.AccountId,userIds);
            }else{
                AccountToUserMap.put(user.Contact.AccountId,new list<Id>{user.id});
            }
        }
        /*List<LeadShare> balanceList = [select id, Leadid, userorgroupid from LeadShare where RowCause='Manual'];
        system.debug('balanceList '+balanceList);
        system.debug('balanceList size is '+balanceList.size());*/
        if(AccountToUserMap.size() > 0){
            for(Id leadId : leadToContactMap.keySet()){
                if(contactToAccountMap.containsKey(leadToContactMap.get(leadId))){
                    if(AccountToUserMap.containsKey(contactToAccountMap.get(leadToContactMap.get(leadId)))){
                        for(Id userId : AccountToUserMap.get(contactToAccountMap.get(leadToContactMap.get(leadId)))){
                            LeadShare lead_share = new LeadShare();
                            lead_share.LeadAccessLevel='Edit';
                            lead_share.LeadId=leadId;
                            lead_share.UserOrGroupId=userId;
                            leadShareList.add(lead_share);
                            system.debug('leadShareList @@ '+leadShareList);
                        }
                    }
                }
            }
        }

        system.debug('Lead share list size is '+leadShareList.size());

        if(! leadShareList.isEmpty()){
            insert leadShareList;
        }
    }

    //Name: Eddie Wong
    //WOrk: W-006542
    //Date: 10/22/2020
    //Desc: Lead Sharing for XDR leads
    public static void shareLeadWithXDRUsers(Map<Id, Id> leadIdToXDRMap) {

        List<LeadShare> leadShareList = new List<LeadShare>();
        Map<Id, User> userIdToUserMap = new Map<Id, User>([SELECT Id,ManagerId FROM User WHERE Id IN :leadIdToXDRMap.values()]);

        if(!userIdToUserMap.isEmpty()) {
            for (Id id : leadIdToXDRMap.keySet()) {
                List<Id> xdrUserIdList = new List<Id>();
                xdrUserIdList.add(leadIdToXDRMap.get(id));
                Id leadId = id;
                for (Id i : xdrUserIdList) {
                    LeadShare lead_share = new LeadShare();
                    lead_share.LeadAccessLevel = 'Edit';
                    lead_share.LeadId = leadId;
                    lead_share.UserOrGroupId = userIdToUserMap.get(i).ManagerId;
                    leadShareList.add(lead_share);
                    system.debug('shareLeadWithXDRUsers leadShareList @@ ' + leadShareList);
                }
            }
        }

    System.debug('checking leadShareList = ' + leadShareList);

        if(!leadShareList.isEmpty()) {
            try {
                insert leadShareList;
                System.debug('inside leadShareList insert ');
            } catch (Exception e) {
                System.debug('Error message = ' + e.getMessage());
            }
        }
    }



    public static Map<Id,id> createContactToAccountMap(set<Id> conIds){
        Map<Id,id> ContactToAccountMap = new Map<Id,Id>();
        List<Contact> conList = [select id, AccountId from Contact where Id In : conIds];
        for(Contact con : conList){
            ContactToAccountMap.put(con.Id, con.AccountId);
        }
        return ContactToAccountMap;
    }
    public static void deleteLeadshare(set<Id> leadIds){
        List<LeadShare> leadshare = [select id from LeadShare where LeadId In : leadIds and RowCause='Manual'];
        delete leadshare;
    }

    //Author: Sergio Flores
    //Date: 9-18
    //Functionality: SafeToSend workflow logic convered to Code

    //Update: Chris Salgado Date: 4-19 Work: W-011631
    public static void updateSafeToSend(List<Lead> safe2SendLeadsList)
    {
        try
        {
            system.debug('inside updateSafeToSend method' + safe2SendLeadsList);
            for(Lead l : safe2SendLeadsList)
            {
                date currentDate = date.today();
                date twoYearsAgo = currentDate.addYears(-2);
                date threeYearsAgo = currentDate.addYears(-3);

                boolean boolRecentComm = false;
                boolean boolSafeToSend = false;

                //First Calculate if GDPR Country & Most Recent Campaign Responded Date is Safe to Send
                //GDPR Country
                system.debug('Lead.GDPR_Country__c =' + l.GDPR_Country__c + ' & Lead.Most_Recent_Campaign_Responded_Date__c =' + l.Most_Recent_Campaign_Responded_Date__c);
                if(l.GDPR_Country__c == true) {
                    //Most Recent Campaign Responded Date is not empty AND within the last 3 years
                    if(l.Most_Recent_Campaign_Responded_Date__c != null && l.Most_Recent_Campaign_Responded_Date__c >= threeYearsAgo){
                        boolRecentComm = true;
                    }
                    else{
                        boolRecentComm = false;
                    }
                }
                //NOT GDPR Country / l.GDPR_Country__c == false
                else{
                    //Most Recent Campaign Responded Date is not empty AND within the last 2 years
                    if(l.Most_Recent_Campaign_Responded_Date__c != null && l.Most_Recent_Campaign_Responded_Date__c >= twoYearsAgo){
                        boolRecentComm = true;
                    }
                    else{
                        boolRecentComm = false;
                    }
                }

                //Second calculate all other GDPR fields to determine if Safe to Send
                //Unsubscribed
                if(l.HasOptedOutofEmail == true) {
                    system.debug('Lead.HasOptedOutofEmail =' + l.HasOptedOutofEmail);
                    boolSafeToSend = false;
                }
                //NOT Unsubscribed / HasOptedOutofEmail == false
                //Opt Out Bucket
                else if(l.Safe_to_Send_Bucket__c == 'Opt Out Bucket'){
                    system.debug('Lead.Safe_to_Send_Bucket__c =' + l.Safe_to_Send_Bucket__c);
                    boolSafeToSend = true;
                }
                //NOT Opt Out Bucket
                //Lean Data Matched Account Type = Customer
                else if (l.LD_MatchedAccountType__c == 'Customer'){
                    system.debug('Lead.LD_MatchedAccountType__c =' + l.LD_MatchedAccountType__c);
                    boolSafeToSend = true;
                }
                //NOT Lean Data Matched Account Type = Customer
                //EmailOptIn *****************************************************************************
                else if(l.Email_Opt_In__c == true){
                    system.debug('Lead.Email_Opt_In__c =' + l.Email_Opt_In__c);
                    //Opt In Bucket
                    if(l.Safe_to_Send_Bucket__c == 'Opt in Bucket'){
                        system.debug('Lead.Safe_to_Send_Bucket__c =' + l.Safe_to_Send_Bucket__c);
                        boolSafeToSend = true;
                    }
                    //NOT Opt In Bucket
                    //Implied Consent Bucket
                    else if(l.Safe_to_Send_Bucket__c == 'Implied Consent Bucket'){
                        system.debug('Lead.Safe_to_Send_Bucket__c =' + l.Safe_to_Send_Bucket__c);
                        //OR Email Implied Consent /Email_Implied_Consent__c == true
                        //THEN SafeToSend
                        boolSafeToSend = true;
                    }
                    //NOT Implied Consent Bucket
                    //Double Opt In Bucket
                    else if(l.Safe_To_Send_Bucket__c == 'Double Opt In Bucket'){
                        system.debug('Lead.Safe_to_Send_Bucket__c =' + l.Safe_to_Send_Bucket__c);
                        //Double Email Opt In / l.Double_Email_Opt_In__c == true
                        if(l.Double_Email_Opt_In__c == true){
                            system.debug('Lead.Double_Email_Opt_In__c =' + l.Double_Email_Opt_In__c);
                            boolSafeToSend = true;
                        }
                        //NOT Double Email Opt In / l.Double_Email_Opt_In__c == false
                        else{
                            boolSafeToSend = false;
                        }
                    }
                    //NOT Double Opt In Bucket / l.Safe_To_Send_Bucket__c Misspelling or Null
                    else {
                        system.debug('ERROR - l.Safe_To_Send_Bucket__c Misspelling or Null');
                        boolSafeToSend = false;
                    }
                }
                //NOT EmailOptIn / Email_Opt_In__c == false *********************************************
                else{
                    system.debug('Lead.Email_Opt_In__c =' + l.Email_Opt_In__c);
                    //Opt In Bucket
                    if(l.Safe_to_Send_Bucket__c == 'Opt in Bucket') {
                        system.debug('Lead.Safe_to_Send_Bucket__c =' + l.Safe_to_Send_Bucket__c);
                        //Recent Communication
                        if(boolRecentComm == true){
                            system.debug('Lead.boolRecentComm =' + boolRecentComm);
                            boolSafeToSend = true;
                        }
                        //NOT Recent Communication
                        else{
                            system.debug('Lead.boolRecentComm =' + boolRecentComm);
                            boolSafeToSend = false;
                        }

                    }
                    //NOT Opt In Bucket
                    //Implied Consent Bucket
                    else if(l.Safe_to_Send_Bucket__c == 'Implied Consent Bucket'){
                        system.debug('Lead.Safe_to_Send_Bucket__c =' + l.Safe_to_Send_Bucket__c);
                        //NOT Email Implied Consent /Email_Implied_Consent__c == false
                        if(l.Email_Implied_Consent__c == false) {
                            system.debug('Lead.Email_Implied_Consent__c =' + l.Email_Implied_Consent__c);
                            //Recent Communication
                            if(boolRecentComm == true){
                                system.debug('Lead.boolRecentComm =' + boolRecentComm);
                                boolSafeToSend = true;
                            }
                            //NOT Recent Communication
                            else {
                                system.debug('Lead.boolRecentComm =' + boolRecentComm);
                                boolSafeToSend = false;
                            }
                        }
                        //Email Implied Consent /Email_Implied_Consent__c == true
                        else{
                            system.debug('Lead.Email_Implied_Consent__c =' + l.Email_Implied_Consent__c);
                            boolSafeToSend = true;
                        }
                    }
                    //NOT Implied Consent Bucket
                    //Double Opt In Bucket
                    else if(l.Safe_To_Send_Bucket__c == 'Double Opt In Bucket'){
                        system.debug('Lead.Safe_to_Send_Bucket__c =' + l.Safe_to_Send_Bucket__c);
                        //AND NOT Double Email Opt In / l.Double_E`mail_Opt_In__c == false
                        //THEN Recent Communication
                        if(boolRecentComm == true){
                            system.debug('Lead.boolRecentComm =' + boolRecentComm);
                            boolSafeToSend = true;
                        }
                        //NOT Recent Communication
                        else {
                            system.debug('Lead.boolRecentComm =' + boolRecentComm);
                            boolSafeToSend = false;
                        }
                    }
                    //NOT Double Opt In Bucket / l.Safe_To_Send_Bucket__c Misspelling or Null
                    else {
                        system.debug('ERROR - Lead.Safe_To_Send_Bucket__c Misspelling or Null');
                        boolSafeToSend = false;
                    }
                }


                if(boolSafeToSend){
                    //Need to track today's date since all conditions are true
                    system.debug('inside update SafeToSend');
                    l.Email_Implied_Consent_Eligibility_Date__c = currentDate;
                    l.Safe_to_Send_as_of_Date__c = currentDate;
                    l.Safe_to_Send__c = 'Yes';
                }
                else{
                    system.debug('inside update notSafeToSend');
                    l.Email_Implied_Consent_Eligibility_Date__c = null;
                    l.Safe_to_Send_as_of_Date__c = null;
                    l.Safe_to_Send__c = 'No';
                }


                //First check if the lead is safe to send
                /*if( l.HasOptedOutofEmail == false
                   && (l.Safe_to_Send_Bucket__c == 'Implied Consent Bucket' && (l.Email_Opt_in__c == true || l.Email_Implied_Consent__c == true))
                   || (l.Safe_to_Send_Bucket__c == 'Opt Out Bucket')
                   || (l.Email_Opt_In__c == true && l.Safe_To_Send_Bucket__c == 'Double Opt In Bucket' && l.Double_Email_Opt_In__c == true)
                   || (l.Email_Opt_In__c == true && l.Safe_to_Send_Bucket__c == 'Opt in Bucket')
                   || l.LD_MatchedAccountType__c == 'Customer'
                   || (l.Most_Recent_Campaign_Responded_Date__c >= twoYearsAgo && l.GDPR_Country__c == false))
                {
                    //Need to track today's date since all conditions are true
                    system.debug('inside update SafeToSend');
                    l.Email_Implied_Consent_Eligibility_Date__c = date.today();
                    l.Safe_to_Send_as_of_Date__c = date.today();
                    l.Safe_to_Send__c = 'Yes';
                    //l.SalesLoft_Do_Not_Email__c = false;
                
                }
                //Second, check if the lead is not safe to send
                if( (l.GDPR_Country__c || ((l.Most_Recent_Campaign_Responded_Date__c <= twoYearsAgo || l.Most_Recent_Campaign_Responded_Date__c == null) && l.GDPR_Country__c == false ) ) 
                   && l.LD_MatchedAccountType__c != 'Customer'
                   && ( ( l.Safe_to_Send_Bucket__c == 'Double Opt In Bucket' && ( l.Double_Email_Opt_In__c == false || l.Email_Opt_In__c == false) ) 
                       || ( l.Email_Opt_In__c == false && l.Safe_to_Send_Bucket__c == 'Opt In Bucket' ) 
                       || ( l.Email_Opt_In__c == false && l.Email_Implied_Consent__c == false && l.Safe_to_Send_Bucket__c == 'Implied Consent Bucket') )
                    ||  l.HasOptedOutofEmail == true)
                    
                {
                    system.debug('inside update notSafeToSend');
                    l.Email_Implied_Consent_Eligibility_Date__c = null;
                    l.Safe_to_Send_as_of_Date__c = null;
                    l.Safe_to_Send__c = 'No';
                    //l.SalesLoft_Do_Not_Email__c = true;
                }*/
            }
        }

        catch(Exception ex) {
            system.debug('inside catch exception');
            trigger.new[0].addError(ex.getMessage());
        }
    }


    /*  Added by: Sharma Nemani | W-012857 & W-013059
     *  Date: 11/01/2019
   */
    // Description: PRM Lead Emails

    public static void sendEmail(Map<Id,String> mapLeadsCase1,Map<Id,String> mapLeadsCase2){
        // list of single email messaging to send .
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        if(mapLeadsCase1.size() > 0){
            allmsg = sendEmail(mapLeadsCase1,'Template_O1');
        }
        if(mapLeadsCase2.size() > 0){
            allmsg = sendEmail(mapLeadsCase2,'Template_O1a');
        }

        try {
            if(allmsg.size() == 0){
                return;
            }
            Messaging.SendEmailResult [] r = Messaging.sendEmail(allmsg,false);
            if(r[0].IsSuccess()){
                System.debug('sent :: '+'');
            }else{
                System.debug('error in sent :: '+r[0].getErrors()[0].getMessage());
            }
            return;
        } catch (Exception e) {
            System.debug('email sending error'+e.getMessage());
        }
    }

    public static List<Messaging.SingleEmailMessage> sendEmail(Map<Id,String> mapLeads,String tempName){// Template_O1
        // as per conditions meeting querying email template.
        EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName =:tempName];
        system.debug('tempName :: '+tempName);
        Map<Id,Lead> leadMap = new Map<Id,Lead>([select id,Owner.Email,wi__Associated_Partner__r.Business_Development_Owner_Email__c from Lead where Id IN : mapLeads.keyset()]);

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();

        // map of leads along with their email after meeting eighter case 1 or case 2 conditons .
        for(Id idLead :  leadMap.keySet()){
            system.debug('leadMap :: '+leadMap.get(idLead).Owner.Email);
            system.debug('leadMap1 :: '+leadMap.get(idLead).wi__Associated_Partner__r.Business_Development_Owner_Email__c);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);
            if(tempName == 'Template_O1'){
                // lead case 1 W-012857
                mail.setToAddresses(new List<String>{leadMap.get(idLead).Owner.Email});
            }else if(tempName == 'Template_O1a'){
                // lead case 2 W-013059
                mail.setToAddresses(new List<String>{leadMap.get(idLead).Owner.Email,leadMap.get(idLead).wi__Associated_Partner__r.Business_Development_Owner_Email__c});
            }

            //mail.setSubject(et.subject);
            //mail.setHTMLBody(et.Body);
            // target Object id to provide values in merge fields  .
            mail.setTargetObjectId(idLead);
            mail.setTreatTargetObjectAsRecipient(false);
            //mail.setWhatId(primaryAccount);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            allmsg.add(mail);
        }
        return allmsg;
    }

    public static void checkStatusHistory(Map<Id,Lead> leadIdToLeadMap)
    {
        //New map to push into SLA Queuable
        Map<Id, Lead> leadIdToLeadSLAMap = new Map<Id, Lead>();

        Map<Id, LeadHistory> leadHistoryIdleadHistoryMap = new  Map<Id, LeadHistory>
                ([SELECT LeadId, NewValue FROM LeadHistory WHERE LeadID IN : leadIdToLeadMap.keySet() and Field = 'status' and createddate = last_n_days:14]);

        Map<Id, LeadHistory> leadIdleadHistoryMap = new  Map<Id, LeadHistory>();

        for(LeadHistory lh : leadHistoryIdleadHistoryMap.values())
        {
            leadIdleadHistoryMap.put(lh.LeadId, lh);
        }

        for(Lead l : leadIdToLeadMap.values())
        {
            LeadHistory leadHistory = leadIdleadHistoryMap.get(l.Id);
            system.debug('inside checking lead history ' + leadHistory);

            if(leadHistory == null)
            {
                leadIdToLeadSLAMap.put(l.Id, l);
            }
            else
            {
                if(l.Hot_SLA_Date__c == System.Today() && (leadHistory.NewValue == '2 - Attempting Contact' || leadHistory.NewValue == '3 - In Conversation'))
                {
                    l.Dispensation_SLA_QL__c = 'Hot SLA In-policy Completed';
                    leadIdToLeadSLAMap.put(l.Id, l);
                }
                else if(l.Warm_SLA_Date__c == System.Today() && (leadHistory.NewValue == '2 - Attempting Contact' || leadHistory.NewValue == '3 - In Conversation'))
                {
                    l.Dispensation_SLA_QL__c = 'Warm SLA In-policy Completed';
                    leadIdToLeadSLAMap.put(l.Id, l);
                }

            }
        }

        //Sergio Flores
        //Date: 08/29/2019
        //Refactoring SLA into Queuable
        if(!leadIdToLeadSLAMap.isEmpty() && RecursionHandler.IsLeadSLAQueuableExecuted == false)
        {
            System.debug('inside executeLeadSLQTaskAndEmail queuable ' +leadIdToLeadSLAMap);
            RecursionHandler.IsLeadSLAQueuableExecuted = true;
            LeadSLAQueuable executeLeadSLQTaskAndEmail = new LeadSLAQueuable(leadIdToLeadSLAMap);
            ID jobID = System.enqueueJob(executeLeadSLQTaskAndEmail);

        }

    }
}