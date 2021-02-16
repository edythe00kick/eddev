global class scheduleUpdateAccountIdsOnChildAccounts implements Schedulable {

    /*public static void scheduleJobs(){
        System.schedule('Scheduled Job updateAccountIdsOnChildAccounts 1', '0 0 1 ? * MON-FRI', new updateAccountIdsOnChildAccounts());
        System.schedule('Scheduled Job updateAccountIdsOnChildAccounts 2', '0 0 7 ? * MON-FRI', new updateAccountIdsOnChildAccounts());
        System.schedule('Scheduled Job updateAccountIdsOnChildAccounts 3', '0 0 13 ? * MON-FRI', new updateAccountIdsOnChildAccounts());
        System.schedule('Scheduled Job updateAccountIdsOnChildAccounts 4', '0 0 19 ? * MON-FRI', new updateAccountIdsOnChildAccounts());
    }*/
    
    global void execute(SchedulableContext sc) {
      //string s = 'SELECT Id,Name,createddate,X2016_Strategic_Account__c,X2016_Enterprise_Umbrella__c,Umbrella_Account_Id__c,Umbrella_Fields_Last_Modified__c FROM Account where X2016_Strategic_Account__c = true or X2016_Enterprise_Umbrella__c = true';  
      
      string s = 'SELECT Id,Name,createddate,X2016_Strategic_Account__c,X2016_Enterprise_Umbrella__c,Umbrella_Account_Id__c,Umbrella_Fields_Last_Modified__c FROM Account WHERE createddate = Yesterday OR Umbrella_Fields_Last_Modified__c = Yesterday';
      updateAccountIdsOnChildAccounts obj = new updateAccountIdsOnChildAccounts(s);
      ID batchprocessid = Database.executeBatch(obj,1);
   }
}