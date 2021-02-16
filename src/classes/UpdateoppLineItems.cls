global class UpdateoppLineItems implements Database.Batchable<sObject>{
   global Database.QueryLocator start(Database.BatchableContext BC){
       if(Test.isRunningTest())
        {
            return Database.getQueryLocator('select id,  name from opportunitylineitem limit 1');
        }
        else{
          return Database.getQueryLocator('select id,  name from opportunitylineitem');
          }
   }

   global void execute(Database.BatchableContext BC, 
                       List<sObject> scope){
      for(Sobject s : scope){ 
      }      update scope;
   }

   global void finish(Database.BatchableContext BC){

   }

}