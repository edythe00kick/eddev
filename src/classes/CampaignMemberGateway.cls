/*
Test Class- 1) TestSpecialCampaignType
2) TestCampaignMemberType
*/
public without sharing class CampaignMemberGateway {

    Set < ID > ldsID = new Set < ID > ();
    Set < ID > consID = new Set < ID > ();
    List < Lead > upLead = new List < Lead > ();
    List < Lead > upLead2 = new List < Lead > ();
    List < Contact > upCon = new List < Contact > ();
    List < Contact > upCon2 = new List < Contact > ();
    Map < Id, String > camName = new Map < Id, String > ();
    Map < ID, String > LeadMap = new Map < Id, String > ();
    Map < ID, List < CampaignMember >> LeadMap2 = new Map < Id, List < CampaignMember >> ();
    Map < ID, List < CampaignMember >> ContactMap2 = new Map < Id, List < CampaignMember >> ();
    Map < ID, String > ContactMap = new Map < Id, String > ();
    String val = '';
    String val2 = '';
    public Static Boolean Flag = False;
    
    public List < Lead > Lead_Records_Update(Set < ID > leadIds) {
        for (CampaignMember cm: [SELECT Id, CampaignID,createddate, Campaign.MQL_Worthy__c,
                        Campaign.Name, LeadID, Lead.Campaign_Member_Type__c,
                        Lead.Most_Recent_Campaign_ID__c,Lead.Most_Recent_Responded_Campaign__c, 
                        Lead.Most_Recent_Campaign_Responded_Date__c, FirstRespondedDate,
                        Lead.X1st_Responded_Campaign__c, Lead.X1st_Campaign_Responded_Date__c,
                        Lead.First_Responded_CampaignID__c,lead.status,lead.isconverted
                        FROM CampaignMember
                        WHERE hasResponded = True AND LeadID IN: leadIds AND 
                        lead.isconverted != TRUE ORDER BY FirstRespondedDate DESC,
                        createddate DESC]) {
            String campaign_name = cm.Campaign.Name.toLowerCase();
            System.debug('campaign_name_gateway-'+ campaign_name);
            if (campaign_name.contains('tcc') || campaign_name.contains('qlik') 
                || campaign_name.contains('tableau') || campaign_name.contains('qcc')
                || campaign_name.contains('amazon') || campaign_name.contains('excel') 
                || campaign_name.contains('captora') || campaign_name.contains('get well guide')
                || campaign_name.contains('microsoft') || campaign_name.contains('power bi')
                || campaign_name.contains('msft') || campaign_name.contains('salesforce') 
                || campaign_name.contains('sfdc') || campaign_name.contains('sql')) {
                
                If( campaign_name.contains('sql') ){
                    val = 'SQL';
                }

                if (campaign_name.contains('salesforce') || campaign_name.contains('sfdc')) {
                    val = 'Salesforce';
                }
                if (campaign_name.contains('tcc') || campaign_name.contains('tableau')) {
                    val = 'Tableau';
                    val2 = 'TCC';
                }
                if (campaign_name.contains('qlik') || campaign_name.contains('qcc')) {
                    val = 'Qlik';
                    val2 = 'QCC';
                }
                if(!campaign_name.containsIgnoreCase('tableau') && 
                        !campaign_name.containsIgnoreCase('tcc')) {
                    if(campaign_name.containsIgnoreCase('amazon')
                            || campaign_name.containsIgnoreCase('AMZN')) {
                        val = 'Amazon';
                    } else if (campaign_name.containsIgnoreCase('excel')) {
                        val = 'Excel';
                    } else if (campaign_name.containsIgnoreCase('microsoft')
                            || campaign_name.containsIgnoreCase('power bi')
                            || campaign_name.containsIgnoreCase('msft')) {
                        val = 'Microsoft';
                    }
                }
                
                if (LeadMap.ContainsKey(cm.LeadID)) {
                    if (!LeadMap.get(cm.LeadID).contains(val)) {
                        LeadMap.put(cm.LeadID, LeadMap.get(cm.LeadID) + ';' + val);
                    }
                } else {
                    LeadMap.put(cm.LeadID, val);
                }
            }
            Else{
                val='Data Blending';
                 if (LeadMap.ContainsKey(cm.LeadID)) {
                    if (!LeadMap.get(cm.LeadID).contains(val)) {
                        LeadMap.put(cm.LeadID, LeadMap.get(cm.LeadID) + ';' + val);
                    }
                } else {
                    LeadMap.put(cm.LeadID, val);
                }
                
            }
            IF(LeadMap2.ContainsKey(cm.LeadID)) {
                List < CampaignMember > camList = LeadMap2.get(cm.LeadID);
                camList.add(cm);
                LeadMap2.put(cm.LeadID, camList);
            } else {
                LeadMap2.put(cm.LeadID, new List < CampaignMember > {cm});
            }
        }
        ldsID = LeadMap.KeySet();
        for (ID i: leadIds) {
            Lead ld = new Lead(id = i);     
            IF(LeadMap2.ContainsKey(i)) {
                ld.Campaign_Member_Type__c = LeadMap.get(i);
                List < CampaignMember > TempList = LeadMap2.get(i);
                ld.Most_Recent_Campaign_Responded_Date__c = TempList[0].FirstRespondedDate;
                ld.Most_Recent_Campaign_ID__c = TempList[0].CampaignID;
                ld.Most_Recent_Responded_Campaign__c = TempList[0].Campaign.Name;
                ld.X1st_Responded_Campaign__c = TempList[TempList.Size() - 1].Campaign.Name;
                ld.X1st_Campaign_Responded_Date__c = TempList[TempList.Size() - 1].FirstRespondedDate;
                ld.First_Responded_CampaignID__c = TempList[TempList.Size() - 1].CampaignID;
                ld.Number_of_Campaigns__c = TempList.Size();
                ld.MQL_Worthy__c = TempList[0].Campaign.MQL_Worthy__c;
            }
              else {
                ld.Campaign_Member_Type__c = '';
                ld.Most_Recent_Campaign_Responded_Date__c = Null;
                ld.Most_Recent_Campaign_ID__c = '';
                ld.Most_Recent_Responded_Campaign__c = '';
                ld.X1st_Responded_Campaign__c = '';
                ld.X1st_Campaign_Responded_Date__c = Null;
                ld.First_Responded_CampaignID__c = '';
                ld.Number_of_Campaigns__c = Null;
                ld.MQL_Worthy__c = False;
                upLead2.add(ld);
            }           
            upLead.add(ld);
        }
        if (!upLead.isEmpty()) {
            System.Debug('Lead List To Update Size  >>'+upLead.Size());
            System.Debug('Lead List To Update  >>'+upLead);
            return upLead;
        }
        else{
            return Null;
        }
    }
    public List < Contact > Contact_Records_Update(Set < ID > conIds) {
        for (CampaignMember cm: [SELECT Id,createddate,CampaignID,Campaign.MQL_Worthy__c,
                    Campaign.Name, ContactID, Contact.Campaign_Member_Type__c,
                    Contact.X1st_Campaign_Responded_Date__c, Contact.X1st_Responded_Campaign__c,
                    Contact.First_Responded_CampaignID__c, Contact.Most_Recent_Campaign_ID__c,
                    Contact.Most_Recent_Campaign_Responded_Date__c,
                    Contact.Most_Recent_Responded_Campaign__c, FirstRespondedDate 
                    FROM CampaignMember 
                    WHERE hasResponded = True AND ContactID IN: conIds ORDER BY 
                    FirstRespondedDate DESC, createddate DESC]) {

            String campaign_name = cm.Campaign.Name.toLowerCase();
            if (campaign_name.contains('tcc') || campaign_name.contains('qlik') ||
                campaign_name.contains('tableau') || campaign_name.contains('qcc') ||
                campaign_name.contains('amazon') || campaign_name.contains('excel') ||
                campaign_name.contains('captora') || campaign_name.contains('get well guide') ||
                campaign_name.contains('microsoft') || campaign_name.contains('power bi') || 
                campaign_name.contains('msft') || campaign_name.contains('salesforce') || 
                campaign_name.contains('sfdc') || campaign_name.contains('sql')) {

                if(campaign_name.contains('sql')){
                    val = 'SQL';
                }

                if (campaign_name.contains('salesforce') || campaign_name.contains('sfdc')) {
                    val = 'Salesforce';
                }
                if (campaign_name.contains('tcc') || campaign_name.contains('tableau')) {
                    val = 'Tableau';
                    val2 = 'TCC';
                }
                if (campaign_name.contains('qlik') || campaign_name.contains('qcc')) {
                    val = 'Qlik';
                    val2 = 'QCC';
                }
                if(!campaign_name.containsIgnoreCase('tableau') && 
                        !campaign_name.containsIgnoreCase('tcc')) {
                    if(campaign_name.containsIgnoreCase('amazon')
                            || campaign_name.containsIgnoreCase('AMZN')) {
                        val = 'Amazon';
                    } else if (campaign_name.containsIgnoreCase('excel')) {
                        val = 'Excel';
                    } else if (campaign_name.containsIgnoreCase('microsoft')
                            || campaign_name.containsIgnoreCase('power bi')
                            || campaign_name.containsIgnoreCase('msft')) {
                        val = 'Microsoft';
                    }
                }
                
                if (ContactMap.ContainsKey(cm.ContactID)) {
                    if (!ContactMap.get(cm.ContactID).contains(val)) {
                        ContactMap.put(cm.ContactID, ContactMap.get(cm.ContactID) + ';' + val);
                    }
                } else {
                    ContactMap.put(cm.ContactID, val);
                }
            }
            Else{
                val='Data Blending';
            
                if (ContactMap.ContainsKey(cm.ContactID)) {
                    if (!ContactMap.get(cm.ContactID).contains(val)) {
                        ContactMap.put(cm.ContactID, ContactMap.get(cm.ContactID) + ';' + val);
                    }
                } else {
                    ContactMap.put(cm.ContactID, val);
                }
            }
           
            IF(ContactMap2.ContainsKey(cm.ContactID)) {
                List < CampaignMember > camList = ContactMap2.get(cm.ContactID);
                camList.add(cm);
                ContactMap2.put(cm.ContactID, camList);
            } else {
                ContactMap2.put(cm.ContactID, new List < CampaignMember > {cm});
            }
        }
        consID = ContactMap.KeySet();
        for (ID i: conIds) {
            Contact ld = new Contact(id = i);
            IF(ContactMap2.ContainsKey(i)) {
                ld.Campaign_Member_Type__c = ContactMap.get(i);
                List < CampaignMember > TempList = ContactMap2.get(i);
                ld.Most_Recent_Campaign_Responded_Date__c = TempList[0].FirstRespondedDate;
                ld.Most_Recent_Campaign_ID__c = TempList[0].CampaignID;
                ld.Most_Recent_Responded_Campaign__c = TempList[0].Campaign.Name;
                ld.X1st_Responded_Campaign__c = TempList[TempList.Size() - 1].Campaign.Name;
                ld.X1st_Campaign_Responded_Date__c = TempList[TempList.Size() - 1].FirstRespondedDate;
                ld.First_Responded_CampaignID__c = TempList[TempList.Size() - 1].CampaignID;
                ld.Number_of_Responded_Campaigns__c = TempList.Size();
                ld.MQL_Worthy__c = TempList[0].Campaign.MQL_Worthy__c;
            }
             else {
                ld.Campaign_Member_Type__c = '';
                ld.Most_Recent_Campaign_Responded_Date__c = NULL;
                ld.Most_Recent_Campaign_ID__c = '';
                ld.Most_Recent_Responded_Campaign__c = '';
                ld.X1st_Responded_Campaign__c = '';
                ld.X1st_Campaign_Responded_Date__c = NULL;
                ld.First_Responded_CampaignID__c = '';
                ld.Number_of_Responded_Campaigns__c = NULL;
                ld.MQL_Worthy__c = False;
            }
            upCon.add(ld);
        }
        if (!upCon.isEmpty()) {
            System.Debug('Contact List To Update Size  >>'+upLead.Size());
            System.Debug('Contact List To Update  >>'+upLead);
            return upCon;
        }
        else{
            Return Null;
        }
    }

    //RETURN A MAP OF LEADS IF THEY CONTAIN PARTNER
    public static Set<String> getPartnerLeads(Set<String> campaignIdSetCustomSetting) {
      
      Set<String> leadsIdSet = new Set<String>();
      Set<String> partnerLeadsIdSet = new Set<String>();
    
      for(Sobject sobj: Trigger.new){
          CampaignMember cm = (CampaignMember)sobj;
          //if(cm.leadid != NULL && cm.campaignId == Label.CampaignNameWithCampaignMemberCountId){
          if(cm.leadid != NULL && campaignIdSetCustomSetting.contains(cm.campaignId)){
              leadsIdSet.add(cm.LeadId);
          }
      }  
      system.debug('LeadsIdSet==>'+leadsIdSet);
      
      if(LeadsIdSet.size() > 0){
          for(Lead l : [select id,Partner_ID__c 
                        FROM lead 
                        WHERE id in: leadsIdSet AND Partner_ID__c  != NULL AND 
                        Status != '4 - Converted' ]){
              partnerLeadsIdSet.add(l.id);
          }
      }
      system.debug('partnerLeadsIdSet in CampaignMemberGateway==>'+partnerLeadsIdSet);      
      return partnerLeadsIdSet;
    }
    
    //RETURN A MAP OF CONTACTS IF THEY CONTAIN PARTNER
    public static Set<String> getPartnerContacts(Set<String> campaignIdSetCustomSetting) {
      Set<String> contactsIdSet = new Set<String>();
      Set<String> partnerContactsIdSet = new Set<String>();
    
      for(Sobject sobj: Trigger.new){
          CampaignMember cm = (CampaignMember)sobj;
          //if(cm.ContactId != NULL && cm.campaignId == Label.CampaignNameWithCampaignMemberCountId){
          if(cm.ContactId != NULL && campaignIdSetCustomSetting.contains(cm.campaignId)){
              contactsIdSet.add(cm.ContactId);
          }
      }  
      system.debug('contactsIdSet in campaign gateway==>'+contactsIdSet);
      if(contactsIdSet.size() > 0){
          for(Contact c : [select id,Partner_ID__c
                           FROM contact 
                           WHERE id in: contactsIdSet AND Partner_ID__c  != NULL ]){
              partnerContactsIdSet.add(c.id);
          }
      }
      system.debug('partnerContactsIdSet in campaign gateway==>'+partnerContactsIdSet);
      return partnerContactsIdSet;
    }
 
    public static Map<Id, Campaign> getCampaigns(Set<Id> campaign_ids) {
        Map<Id, Campaign> campaign_map = new Map<Id, Campaign>();
        for(Campaign c : [SELECT Id,Name,Event_Cap_Qualified__c,Maximum_Number_of_Subscribers__c,
                          Total_number_of_Seats__c 
                          FROM Campaign 
                          WHERE Id IN :campaign_ids]) {
            campaign_map.put(c.Id, c);
        }
        return campaign_map;
    }    
    
    public static map<id,string> getPartnerIdFromLeadOrContact(set<string> leadIds,set<string> contactIds){
        map<id,string> idToPartnerIdMap = new map<id,string>();
        
        if(leadIds != null && leadIds.size() > 0){
             for(lead ld : [select id,Campaign_Referred_Partner_ID__c
                            FROM lead 
                            WHERE id in :leadIds and Campaign_Referred_Partner_ID__c != null]){
                  idToPartnerIdMap.put(ld.id,ld.Campaign_Referred_Partner_ID__c);
            }
        }
        if(contactIds != null && contactIds.size() > 0){
            for(contact con : [select id,Campaign_Referred_Partner_ID__c 
                               FROM contact 
                               WHERE id in :contactIds and Campaign_Referred_Partner_ID__c != null]){
                  idToPartnerIdMap.put(con.id,con.Campaign_Referred_Partner_ID__c);
            }
        }
        return idToPartnerIdMap;
    }
    
    public static void updateChannelFromLeadCCA(Set<Id> leadIds4) {
        Map<id,lead> leads = new Map<id,lead>([select id,
                Campaign_Channel_Attribution__c,
                Most_Recent_Campaign_ID__c,
                Lead_Source_Most_Recent__c
                from lead 
                where Id IN :leadIds4]);
                
        List<CampaignMember> cms = new List<CampaignMember>();
        
        for(SObject so : Trigger.new) {
            CampaignMember cm = (CampaignMember) so;
            
            if(cm.LeadId != null && leads.containsKey(cm.LeadId)) {
                String lsmr = leads.get(cm.LeadId).Lead_Source_Most_Recent__c;
                String cca = leads.get(cm.LeadId).Campaign_Channel_Attribution__c;
                if(String.isNotEmpty(lsmr)) {
                    if(cm.Lead_Source_Most_Recent__c != lsmr) {
                        CampaignMember temp = new CampaignMember();
                        temp.Id = cm.Id;
                        temp.Lead_Source_Most_Recent__c = lsmr;
                        cms.add(temp);
                    }
                } else if(String.isNotEmpty(cca) && CampaignChannelAttributionHelper.checkCCA(cca)) {
                    // Lead has campaign channel attribution filled and in correct format.
                    List<string> cca_splitted = cca.split(';');
                    String campaign_id = cca_splitted.get(0).trim();
                    String channel = cca_splitted.get(2).trim();
                    // Campaign Member's campaign id matches with campaign id in CCa field
                    if(String.valueOf(cm.CampaignId).contains(campaign_id)) {
                        if(cm.Lead_Source_Most_Recent__c != channel) {
                            System.debug('cca> update channel field on campaign member');
                            CampaignMember temp = new CampaignMember();
                            temp.Id = cm.Id;
                            temp.Lead_Source_Most_Recent__c = channel;
                            cms.add(temp);
                        }
                    }
                }
            }
        }
        
        if(!cms.isEmpty()) {
            update cms;
            CampaignMemberHandler.ranForCCAAfterInsert = true;
        }
    }
    
    public static void updateChannelFromContactCCA(Set<Id> contactIds4) {
        Map<id,contact> contacts = new Map<id,contact>([select id,
                Campaign_Channel_Attribution__c,
                Most_Recent_Campaign_ID__c,
                Contact_Source_Most_Recent__c
                from contact 
                where Id IN :contactIds4]);
                
        List<CampaignMember> cms = new List<CampaignMember>();
        
        for(SObject so : Trigger.new) {
            CampaignMember cm = (CampaignMember) so;
            
            if(cm.ContactId != null && contacts.containsKey(cm.ContactId)) {
                String csmr = contacts.get(cm.ContactId).Contact_Source_Most_Recent__c;
                String cca = contacts.get(cm.ContactId).Campaign_Channel_Attribution__c;
                if(String.isNotEmpty(csmr)) {
                    if(cm.Lead_Source_Most_Recent__c != csmr) {
                        CampaignMember temp = new CampaignMember();
                        temp.Id = cm.Id;
                        temp.Lead_Source_Most_Recent__c = csmr;
                        cms.add(temp);
                    }
                } else if(String.isNotEmpty(cca) && CampaignChannelAttributionHelper.checkCCA(cca)) {
                    // Lead has campaign channel attribution filled and in correct format.
                    List<string> cca_splitted = cca.split(';');
                    String campaign_id = cca_splitted.get(0).trim();
                    String channel = cca_splitted.get(2).trim();
                    // Campaign Member's campaign id matches with campaign id in CCa field
                    if(String.valueOf(cm.CampaignId).contains(campaign_id)) {
                        if(cm.Lead_Source_Most_Recent__c != channel) {
                            System.debug('cca> update channel field on campaign member');
                            CampaignMember temp = new CampaignMember();
                            temp.Id = cm.Id;
                            temp.Lead_Source_Most_Recent__c = channel;
                            cms.add(temp);
                        }
                    }
                }
            }
        }
        
        if(!cms.isEmpty()) {
            update cms;
            CampaignMemberHandler.ranForCCAAfterUpdate = true;
        }
    }

    /**
     * #W-009847
     * Track Most Recent Campaign Status to Lead and Contact
     *
     * @param {Map<Id, String>} cmToStatusMap - Campaign member to Status Map
     * @param {Map<Id, Id>} cmToLeadIdMap - Campaign member to Lead Id Map
     * @return leadToUpdateList - Leads to update.
     * @description Update the Lead's Most_Recent_Responded_Campaign_Status__c field.
     * @author Hemendra Singh Rajawat
     * @since June 19, 2018
     */
    public static List<Lead> updateLeads(Map<Id, String> cmToStatusMap, 
                                         Map<Id, Id> cmToLeadIdMap) {

        List<Lead> leadToUpdateList = new List<Lead>();
        Set<Lead> leadsList = new Set<Lead>();
        for (Id cmId : cmToLeadIdMap.keySet()) {
            if (cmToLeadIdMap.containsKey(cmId) && cmToStatusMap.containsKey(cmId)) {
                Lead ld = new Lead(Id = cmToLeadIdMap.get(cmId));
                ld.Most_Recent_Responded_Campaign_Status__c = cmToStatusMap.get(cmId);
                leadsList.add(ld);
            }
        }
        leadToUpdateList.addAll(leadsList);
        return leadToUpdateList;
    }

    /**
     * #W-009847
     * Track Most Recent Campaign Status to Lead and Contact
     *
     * @param {Map<Id, String>} cmToStatusMap - Campaign member to Status Map
     * @param {Map<Id, Id>} cmToContIdMap - Campaign member to Contact Id Map
     * @return contsToUpdate - Contacts to update.
     * @description Update the Contact's Most_Recent_Responded_Campaign_Status__c field.
     * @author Hemendra Singh Rajawat
     * @since June 19, 2018
     */
    public static List<Contact> updateContacts(Map<Id, String> cmToStatusMap, 
                                               Map<Id, Id> cmToContIdMap) {

        List<Contact> contsToUpdate = new List<Contact>();
        Set<Contact> contsList = new Set<Contact>();
        for (Id cmId : cmToContIdMap.keySet()) {
            if (cmToContIdMap.containsKey(cmId) && cmToStatusMap.containsKey(cmId)) {
                Contact cont = new Contact(Id = cmToContIdMap.get(cmId));
                cont.Most_Recent_Responded_Campaign_Status__c = cmToStatusMap.get(cmId);
                contsList.add(cont);
            }
        }
        contsToUpdate.addAll(contsList);
        return contsToUpdate;
    }
}