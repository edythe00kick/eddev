public class returnSubscriptionSchedules{

//capture the quote id
    public ID quoteID {get; set;}
    
    public List<Quote_Subscription_Schedule__c> subScheduleList = new List<Quote_Subscription_Schedule__c>();

    public List<Quote_Subscription_Schedule__c> getSubScheduleList() {
        List<Quote_Subscription_Schedule__c> subScheduleList = [Select Year__c,  Subscription_Start_Date__c, 
                                                                Subscription_End_Date__c,Net_Total__c                                                
                                                  	From Quote_Subscription_Schedule__c Where Quote__c =: quoteID];
        system.debug('subScheduleList ' + subScheduleList);
        
        return subScheduleList;
    }

}