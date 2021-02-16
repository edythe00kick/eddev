public with sharing class FeedItemHandler implements ITrigger{
    
    public Set<Id> CaseIds = new Set<Id>(); // Added by Ayushi Mahawer on Dec 12, 2019
    public List<FeedItem> recordList = new List<FeedItem>();
    public List<Case> caseToUpdate = new List<Case>();
    public Set<Id> useridList = new Set<Id>();
    public Map<Id, Id> recordToOwnerIdMap = new Map<Id, Id>();
    public Map<Id, Case> caseRecordMap = new Map<Id, Case>();
    public FeedItemHandler(){
        
    }
    
    public void bulkBefore() {
    }
    
    public void bulkAfter(){
        if(trigger.isInsert){
            // Added by Ayushi Mahawer on Dec 12, 2019  
            for (SObject fdItem : Trigger.New) {
                FeedItem feed =  (FeedItem)fdItem;
                recordList.add((FeedItem)fdItem);
                if(feed.ParentId.getSObjectType().getDescribe().getName() == 'Case') {
                    CaseIds.add(feed.ParentId);
                } 
            }      
            recordToOwnerIdMap = FeedItemGateway.createRecordToOwnerIdMap(recordList);
            useridList = FeedItemGateway.userForSpecificProfile();
            if(!CaseIds.isEmpty()) {
                caseRecordMap = FeedItemGateway.listOfCasesFromFeedItem(CaseIds);
            }
        }
    }
    
    public void beforeInsert(SObject so){
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
    }
    
    public void beforeDelete(SObject so){     
    }
    
    public void afterInsert(SObject sObjLead){
        FeedItem feed =  (FeedItem)sObjLead;
        String objectName = feed.ParentId.getSObjectType().getDescribe().getName();
        String PartnerProfileIds = Label.PartnerProfileId;

        if(objectName.equalsIgnoreCase('lead')|| objectName.equalsIgnoreCase('opportunity')){
            ConnectApi.FeedElement feedItem = ConnectApi.ChatterFeeds.getFeedElement(Null, feed.Id);
            String AllInvalidMentions='';
            List<ConnectApi.MessageSegment> messageSegments = feedItem.body.messageSegments;
            for (ConnectApi.MessageSegment messageSegment : messageSegments) {
                if (messageSegment instanceof ConnectApi.MentionSegment){ 
                    If(String.ValueOf(messageSegment.type) == 'Mention'){
                        ConnectApi.MentionSegment mentionSegment = (ConnectApi.MentionSegment) messageSegment;
                        id mentionid=mentionSegment.record.id;
                        string name=mentionSegment.name;
                        if(recordToOwnerIdMap.get(feed.ParentId)!=mentionid && !useridList.contains(mentionid)){
                            if(AllInvalidMentions==''){
                                AllInvalidMentions=name;
                            }else{
                                AllInvalidMentions=AllInvalidMentions+', '+name;
                            } 
                        }
                    }
                }
            }
            if(AllInvalidMentions!='' && PartnerProfileIds.contains(String.valueOf(UserInfo.getProfileId()).substring(0, 15))){
                If(!Test.isRunningTest())
                    feed.id.addError('You are not allowed to mention ' + AllInvalidMentions);
            }    
        }
        // Added by Ayushi Mahawer on Dec 20, 2019 
        if (!caseRecordMap.isEmpty() && caseRecordMap.containsKey(feed.ParentId)) {
            Case csRecord = caseRecordMap.get(feed.ParentId);
            if (feed.CreatedById == csRecord.OwnerId/*&& csRecord.Type == 'TextPost'*/
                && (csRecord.status == 'New' || csRecord.status == 'Assigned')) {

                csRecord.status = 'Responded';
                csRecord.First_Responded_Date__c = System.now();
                caseToUpdate.add(csRecord);
            }
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
    }
    
    public void afterDelete(SObject sLead){
    }
    
    public void andFinally(){     
        try {
            if (!caseToUpdate.isEmpty()) {
                update caseToUpdate;
            } 
        } catch (Exception ex) {
            System.debug(ex.getMessage());
        }
         
    }
    
}