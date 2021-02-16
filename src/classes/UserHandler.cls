public class UserHandler implements ITrigger{
    public map<id,id> contactIdToUserIdMap = new map<id,id>();
    public UserHandler(){}
    public void bulkBefore() {}
    public void bulkAfter(){
    }
        
    public void beforeInsert(SObject so){
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
    }
    
    public void beforeDelete(SObject so){     
    }
    
    public void afterInsert(SObject so){
        User newUser = (User)so;
        if(newUser.contactId != null && newUser.profileId == System.Label.PartnerProfileId){
            contactIdToUserIdMap.put(newUser.ContactId,newUser.Id);
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
    }
    public void afterDelete(SObject so){
    }
    
    public void andFinally(){
        if(contactIdToUserIdMap.size() > 0){
            userGateway.createNewPartnerSharingRules(contactIdToUserIdMap);
        }
    }
}