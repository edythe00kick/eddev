public class UserGateway{
    // Created By Mohit Gupta
    // Get the Lead Shares AND Opportunity Shares for new partner User on account Basis
    @Future
    public static void createNewPartnerSharingRules(map<id,id> contactIdToUserIdMap){
        list<LeadShare> ListOfLeadShare = new list<LeadShare>();
        list<OpportunityShare> ListOfOppShare = new list<OpportunityShare>();
        map<id,id> contactIdToAccountIdMap = new map<id,id>();
        map<id,list<id>> accountToLeadIdsMap = new map<id,list<id>>();
        map<id,list<id>> accountToOpportunityIdsMap = new map<id,list<id>>();
        for(contact c : [select id,accountId from contact where id in :contactIdToUserIdMap.keySet()]){
            contactIdToAccountIdMap.put(c.id,c.accountId);
        }
        // FOR OPPORTUNITY SHARING
        if(contactIdToAccountIdMap.size() > 0){
            for(custom_Partner__c cp : [select id,AccountToId__c,OpportunityId__c from custom_Partner__c where AccountToId__c in :contactIdToAccountIdMap.values() and IsPrimary__c = true and OpportunityId__c  != null]){
                if(accountToOpportunityIdsMap.containsKey(cp.AccountToId__c)){
                    list<id> opportunityIds = accountToOpportunityIdsMap.get(cp.AccountToId__c);
                    opportunityIds.add(cp.OpportunityId__c);
                    accountToOpportunityIdsMap.put(cp.AccountToId__c,opportunityIds);
                }else{
                    accountToOpportunityIdsMap.put(cp.AccountToId__c,new list<id>{cp.OpportunityId__c});
                }
            }
            if(accountToOpportunityIdsMap.size() > 0){
                for(id contId : contactIdToUserIdMap.keyset()){
                    if(contactIdToAccountIdMap.containsKey(contId)){
                        if(accountToOpportunityIdsMap.containsKey(contactIdToAccountIdMap.get(contId))){
                            for(id oppId: accountToOpportunityIdsMap.get(contactIdToAccountIdMap.get(contId))){
                                LeadShare ls = new LeadShare();
                                OpportunityShare os = new OpportunityShare();
                                os.OpportunityAccessLevel = 'Read';
                                os.OpportunityId = oppId;
                                os.UserOrGroupId = contactIdToUserIdMap.get(contId);
                                ListOfOppShare.add(os);
                            }
                        }
                    }
                }
            }
        }
        
        // FOR LEAD SHARING
        if(contactIdToAccountIdMap.size() > 0){
            for(Lead l:[select id,Partner_Representative__c,Partner_Representative__r.accountId from lead where Partner_Representative__r.accountId in :contactIdToAccountIdMap.values()]){
                if(accountToLeadIdsMap.containsKey(l.Partner_Representative__r.accountId)){
                    list<id> leadIds = accountToLeadIdsMap.get(l.Partner_Representative__r.accountId);
                    leadIds.add(l.id);
                    accountToLeadIdsMap.put(l.Partner_Representative__r.accountId,leadIds);
                }else{
                    accountToLeadIdsMap.put(l.Partner_Representative__r.accountId,new list<string>{l.id});
                }
            }
            if(accountToLeadIdsMap.size() > 0){
                for(id contId : contactIdToUserIdMap.keyset()){
                    if(contactIdToAccountIdMap.containsKey(contId)){
                        if(accountToLeadIdsMap.containsKey(contactIdToAccountIdMap.get(contId))){
                            for(id leadId : accountToLeadIdsMap.get(contactIdToAccountIdMap.get(contId))){
                                LeadShare ls = new LeadShare();
                                ls.leadId = leadId;
                                ls.UserOrGroupId = contactIdToUserIdMap.get(contId);
                                ls.LeadAccessLevel = 'Edit';
                                listOfLeadShare.add(ls);
                            }
                        }
                    }
                }
            }
        }
        if(ListOfOppShare.size() > 0){
            Database.insert(ListOfOppShare);
        }
        if(listOfLeadShare.size() > 0){
            Database.insert(listOfLeadShare);
        }
    }
}