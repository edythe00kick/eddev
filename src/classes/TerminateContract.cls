/* Autor: Sharma Nemani | W-013343
 * Date: 10/14/2019
 * Description: This Batch Class is to Terminate/Expire all the Contracts that are Activated which have End Date < 7.
 * Scheduler class is included in this Batch Class.
*/
global class TerminateContract implements Database.Batchable<sObject>, Schedulable {
   global Database.QueryLocator start(Database.BatchableContext BC){
      
      Date endDate = system.today().addDays(-7);
      String query = 'select id,Status, EndDate ,Status_Category__c from contract where Status='+'\''+'Activated'+'\''+'AND EndDate >:endDate AND EndDate<=Today';
      return Database.getQueryLocator(query);
   }

   global void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Contract> lstScope = (List<Contract>)scope;
       for(contract contr : lstScope){
           contr.Status = 'Terminated';
           contr.Status_Category__c = 'Expired';
       } 
       update lstScope;
   }

   global void finish(Database.BatchableContext BC){
   		
   }
    
   global void execute(SchedulableContext SC) {
     	database.executeBatch(new TerminateContract(),1);
   }
}