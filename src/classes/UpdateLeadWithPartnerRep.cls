public without sharing class  UpdateLeadWithPartnerRep {
    
    @InvocableMethod(label='update lead with partner rep')
    public static void Updatelead(List<Id> leadids){
        Lead ld= [select id, CreatedById from lead where id in :leadids limit 1];
        User u= [select id,contactid from User where id = :ld.CreatedById  and contactid != Null limit 1];
        if(u.ContactId != null){
            ld.Partner_Representative__c = u.ContactId;
            ld.OwnerId = System.Label.MQLMatchingQueueId;
            update ld;
        }
    }
}