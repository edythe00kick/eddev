global class CreateECRTasksonAgreement implements Database.Batchable<sObject>
{
public String query; 
  
    global Database.QueryLocator start(Database.BatchableContext BC)
    {

        query = 'SELECT Id,Subscription_Start_Date__c,Days_left_in_Subscription_Start__c,Agreement__c,Year__c from Billing_Schedule__c where Agreement__c != NULL AND Year__c != NULL AND Year__c != \'1st\'  AND Subscription_Start_Date__c != NULL AND Days_left_in_Subscription_Start__c != NULL AND Days_left_in_Subscription_Start__c = 75 AND Agreement__r.Apttus__Status__c != NULL AND Agreement__r.Apttus__Status__c = \'Activated\' ';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Task> tasksListforInsertion = new List<Task>();
        
        List<Billing_Schedule__c> subscriptionScheduleList = (List<Billing_Schedule__c>)scope;
        
        System.debug('subscriptionScheduleList is ==>'+subscriptionScheduleList);
         
         for(Billing_Schedule__c subSchedule : subscriptionScheduleList)
         {
             Task t = new Task();
             t.ActivityDate = subSchedule.Subscription_Start_Date__c.addDays(-30);
             t.OwnerId = Label.FulfillmentTeamUserId;
             t.Priority = 'Normal';
             t.RecordTypeId = Label.ECR_Fulfillment_Task_RecordTypeId;
             t.Status = 'Not Started';
             t.WhatId = subSchedule.Agreement__c;
             t.Subject = 'ECR to be fulfilled Year '+subSchedule.Year__c;
             tasksListforInsertion.add(t);        
         }
     
         if(!tasksListforInsertion.isEmpty()){
             System.debug('tasksListforInsertion is ==>'+tasksListforInsertion);
             insert tasksListforInsertion; 
         }
         
         
    }   
    global void finish(Database.BatchableContext BC)
    { 
    }
}