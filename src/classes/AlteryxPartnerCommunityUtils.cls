public class AlteryxPartnerCommunityUtils {
    public static void shareLeadWithUsers(Map<Id,Id> leadToContactMap){
        Map<Id,Id> contactToAccountMap = new Map<Id,Id>();
        Map<Id,List<Id>> AccountToUserMap = new  Map<Id,List<Id>>();
        List<LeadShare> leadShareList = new List<LeadShare>();
      
        for(Contact con : [SELECT Id, AccountId FROM Contact WHERE Id In : leadToContactMap.values() and AccountId != null]){
            contactToAccountMap.put(con.Id, con.AccountId);                
        }
        for(User user : [SELECT Id, ContactId, Contact.AccountId, AccountId FROM User where userType = 'PowerPartner' and contactId != null AND AccountId In : contactToAccountMap.values() and IsActive = true]){
            if(AccountToUserMap.containsKey(user.Contact.AccountId)){
                list<id> userIds = AccountToUserMap.get(user.Contact.AccountId);
                userIds.add(user.id);
                AccountToUserMap.put(user.Contact.AccountId,userIds);
            }else{
                AccountToUserMap.put(user.Contact.AccountId,new list<Id>{user.id});
            }
        }
        
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
        
        
        
        if(! leadShareList.isEmpty()){
            insert leadShareList;
        }
    }
}