global class LeadShareCreateBatchClass implements Database.Batchable<sObject>{
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        string leadRecordId =System.Label.Altx_Partner_Lead_Record_Type_Id;
        string query = 'SELECT id, Partner_Representative__c, OwnerId, RecordTypeId FROM Lead where RecordTypeId =: leadRecordId and Partner_Representative__c != null ';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<Lead> scope){
        Map<Id,Id> leadToContactMap = new Map<Id,Id>();
        for(Lead ld : scope){                               
            leadToContactMap.put(ld.id,ld.Partner_Representative__c);
            system.debug('@@--contactToLeadMap-- in batch class '+leadToContactMap);
        }
        
        if(leadToContactMap.size() > 0 ){
            AlteryxPartnerCommunityUtils.shareLeadWithUsers(leadToContactMap);
        }
    }
    
    global void finish(Database.BatchableContext BC){
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        system.debug('job is '+job);
    }
    
}