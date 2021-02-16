public with sharing class FeedItemGateway {  
    
    public static Map<Id, Id> createRecordToOwnerIdMap(List<FeedItem> feedItemList){
        string objectName='';
        Map<Id, Id> recordToOwnerIdMap = new Map<Id, Id>();
        List<Id> oppIds = new List<Id>();
        List<Id> leadIds = new List<Id>();
        For(FeedItem feed : feedItemList){
            objectName = feed.ParentId.getSObjectType().getDescribe().getName();
            if(objectName.equalsIgnoreCase('lead')){
                leadIds.add(feed.ParentId);
            }
            if(objectName.equalsIgnoreCase('opportunity')){
                oppIds.add(feed.ParentId);
            }
        }
        
        if(! leadIds.isEmpty()){            
            for(Lead ld : [Select id, OwnerId,RecordTypeId, Owner.Name, Owner.ProfileId From Lead where Id In : leadIds]){
                recordToOwnerIdMap.put(ld.Id, ld.OwnerId);
                System.debug('OwnerId__+'+ld.OwnerId);
            }
        }
        if(! oppIds.isEmpty()){            
            for(Opportunity op : [Select id, OwnerId,RecordTypeId, Owner.Name, Owner.ProfileId From Opportunity  where Id In : oppIds]){
                recordToOwnerIdMap.put(op.Id, op.OwnerId );
                System.debug('OwnerId__+'+op.OwnerId);
            }
        }
        return recordToOwnerIdMap;
    }
    public static Set<Id> userForSpecificProfile(){
        Set<Id> userNamesId = new Set<Id>();
        String labelProfileId = System.Label.ProfileIdForChatterOnOppDetail;
        for(User user : [Select Id, Name From User Where ProfileId = : labelProfileId and IsActive=true]){
            userNamesId.add(user.Id);
        }
        return userNamesId;
    }
    
    // Added by Ayushi Mahawer on Dec 20, 2019
    public static Map<Id, Case> listOfCasesFromFeedItem(Set<Id> CaseIds) {
        List<Case> caseToUpdate = new List<Case>();
        Map<Id, case> caseRecMap = new Map<Id, Case>();
        if (!CaseIds.isEmpty()) {
            for(Case caseRec: [SELECT Id, RecordTypeId, OwnerId, Type, status 
                                FROM Case 
                                WHERE Id IN: CaseIds and IsClosed = false
                                and RecordTypeId=: label.SFDC_Internal_Support_Ticket_RecordTypeId]){

                caseRecMap.put(caseRec.Id, caseRec);
            }
        } 
        return caseRecMap;
    }           
}