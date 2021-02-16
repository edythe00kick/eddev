global class UpdateCampaignMemberTypeField implements Database.Batchable<sObject>{

    global Database.QueryLocator start(Database.BatchableContext BC){
        /*String query = 'select id, ' 
            + 'leadid, ' 
            + 'contactid '
            + 'from campaignmember '
            + 'where hasResponded=true ' 
            + 'AND Lead.isConverted = false';*/
        //String query = 'select id, contactid from campaignmember where hasResponded=true and contactid!=null and contact.Most_Recent_Campaign_ID__c!=null';
        String query = 'select id, '
            + 'leadid '
            + 'from campaignmember '
            + 'where hasResponded=true '
            + 'and lead.isConverted = false ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<CampaignMember> scope){
        // Lead ids that are to be searched for campaign members
        Set<Id> lead_ids = new Set<Id>();
        // Contact ids that are to be searched for campaign members
        Set<Id> contact_ids = new Set<Id>();
        
        for(CampaignMember cm : scope) {
            if(cm.LeadId != null) {
                lead_ids.add(cm.LeadId);
            }
            /*if(cm.ContactId != null) {
                contact_ids.add(cm.ContactId);
            }*/
        }
        
        // Lead ids with corresponding campaign member type
        Map<ID, String> lead_map = new Map<Id, String>();
        // Contact ids with corresponding campaign member type
        Map<ID, String> contact_map = new Map<Id, String>();
        
        if(!lead_ids.isEmpty()) {
            for(CampaignMember cm : [SELECT Id, Campaign.Name, LeadId
                    , Lead.Campaign_Member_Type__c
                    , ContactId
                    , Contact.Campaign_Member_Type__c
                    FROM CampaignMember
                    WHERE LeadId IN :lead_ids
                    AND Lead.isConverted = false
                    AND hasResponded=true]) {
                
                String name = cm.Campaign.Name;
                String temp_member_type = '';
                
                if(name.containsIgnoreCase('salesforce')
                        || name.containsIgnoreCase('sfdc')) {
                    temp_member_type = 'Salesforce';
                }
                if(name.containsIgnoreCase('tableau') 
                        || name.containsIgnoreCase('tcc')) {
                    temp_member_type = 'Tableau';
                }
                if(name.containsIgnoreCase('qlik')
                        || name.containsIgnoreCase('qcc')) {
                    temp_member_type = 'Qlik';
                }
                if(!name.containsIgnoreCase('tableau') && 
                        !name.containsIgnoreCase('tcc')) {
                    if(name.containsIgnoreCase('amazon')
                            || name.containsIgnoreCase('AMZN')) {
                        temp_member_type = 'Amazon';
                    } else if (name.containsIgnoreCase('excel')) {
                        temp_member_type = 'Excel';
                    } else if (name.containsIgnoreCase('microsoft')
                            || name.containsIgnoreCase('power bi')
                            || name.containsIgnoreCase('msft')) {
                        temp_member_type = 'Microsoft';
                    }
                }
                
                if(temp_member_type == '') {
                    temp_member_type = 'Data Blending';
                }
                
                if(!lead_map.containsKey(cm.LeadId)) {
                    lead_map.put(cm.LeadId, temp_member_type);
                } else {
                    String member_type = lead_map
                            .get(cm.LeadId);
                    if(!member_type.contains(temp_member_type)) {
                        member_type = member_type + ';' + temp_member_type;
                    }
                    lead_map.put(cm.LeadId, member_type);
                }
            }
        }
        
        /*if(!contact_ids.isEmpty()) {
            for(CampaignMember cm : [SELECT Id, Campaign.Name, LeadId
                    , Lead.Campaign_Member_Type__c
                    , ContactId
                    , Contact.Campaign_Member_Type__c
                    FROM CampaignMember
                    WHERE ContactId IN :contact_ids]) {
                        
                String name = cm.Campaign.Name;
                String temp_member_type = '';
                
                if(name.containsIgnoreCase('salesforce')) {
                    temp_member_type = 'Salesforce';
                }
                if(name.containsIgnoreCase('tableau') 
                        || name.containsIgnoreCase('tcc')) {
                    temp_member_type = 'Tableau';
                }
                if(name.containsIgnoreCase('qlik')
                        || name.containsIgnoreCase('qcc')) {
                    temp_member_type = 'Qlik';
                }
                if(!name.containsIgnoreCase('tableau') && 
                        !name.containsIgnoreCase('tcc')) {
                    if(name.containsIgnoreCase('amazon')
                            || name.containsIgnoreCase('AMZN')) {
                        temp_member_type = 'Amazon';
                    } else if (name.containsIgnoreCase('excel')) {
                        temp_member_type = 'Excel';
                    } else if (name.containsIgnoreCase('microsoft')
                            || name.containsIgnoreCase('power bi')
                            || name.containsIgnoreCase('msft')) {
                        temp_member_type = 'Microsoft';
                    }
                }
                
                if(temp_member_type == '') {
                    temp_member_type = 'Data Blending';
                }
                
                if(!contact_map.containsKey(cm.ContactId)) {
                    contact_map.put(cm.ContactId, temp_member_type);
                } else {
                    String member_type = contact_map
                            .get(cm.ContactId);
                    if(!member_type.contains(temp_member_type)) {
                        member_type = member_type + ';' + temp_member_type;
                    }
                    contact_map.put(cm.ContactId, member_type);
                }
            }
        }*/
        
        // Leads to update
        List<Lead> leads_to_update = new List<Lead>();
        // Contacts to update
        List<Contact> contacts_to_update = new List<Contact>();
        
        for(Id lead_id : lead_map.keySet()) {
            Lead l = new Lead();
            l.Id = lead_id;
            l.Campaign_Member_Type__c = lead_map.get(lead_id);
            leads_to_update.add(l);
        }
        
        /*for(Id contact_id : contact_map.keySet()) {
            Contact c = new Contact();
            c.Id = contact_id;
            c.Campaign_Member_Type__c = contact_map.get(contact_id);
            contacts_to_update.add(c);
        }*/
        
        if(!leads_to_update.isEmpty()) {
            update leads_to_update;
        }
        /*if(!contacts_to_update.isEmpty()) {
            update contacts_to_update;
        }*/
    }
    
    global void finish(Database.BatchableContext BC){}
   
}