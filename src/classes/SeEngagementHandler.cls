public class SeEngagementHandler {
    
    // Stores the value of Trigger.isExecuting
    private Boolean myIsExecuting = false;
    // Stores the value of Trigger.size
    private integer batchSize = 0;
    
    public SeEngagementHandler(Boolean isExecuting, Integer size, List<SE_Engagement__c> newRecords) {
        
        //Add/set any contstructor variables        
    }
    
    public void onAfterInsert(List<SE_Engagement__c> newRecords)
    {
        SeEngagementGateway.createOpportunityTeamMember(newRecords);
        
    }
    
    public void onAfterUpdate(List<SE_Engagement__c> newRecords)
    {
        system.debug('Inside Update');
        List<SE_Engagement__c> engagementsToUpdateList = new List<SE_Engagement__c>();
        
        for(SE_Engagement__c engagement : newRecords)
        {
            SE_Engagement__c oldEngagement = (SE_Engagement__c)Trigger.oldMap.get(engagement.ID);
            
            if(engagement.Opportunity__c != null && (oldEngagement.Opportunity__c == null || (engagement.Opportunity__c != oldEngagement.Opportunity__c)))
            {
                system.debug('Inside Opportunity Updated , new opp ' + engagement.Opportunity__c + ', old opp ' +  oldEngagement.Opportunity__c);
                engagementsToUpdateList.add(engagement);
            }
        }
        
        if(!engagementsToUpdateList.IsEmpty())
        {
            system.debug('Inside Update List');
            SeEngagementGateway.createOpportunityTeamMember(engagementsToUpdateList);
        }
        
    }

}