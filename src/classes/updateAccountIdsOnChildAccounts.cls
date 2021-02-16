global class updateAccountIdsOnChildAccounts implements Database.Batchable<sObject>, Database.Stateful
{
      public String query;
      
    
    global updateAccountIdsOnChildAccounts(String query){
        this.query = query;
    }
      
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        //String query = '';
        
        if(query != NULL){
            system.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$');
            return Database.getQueryLocator(query);
        }
        else{
              if(Label.X2016UmbrellaAccounts == 'true'){
                    query = 'SELECT Id,Name,createddate,X2016_Strategic_Account__c,X2016_Enterprise_Umbrella__c,Umbrella_Account_Id__c,Umbrella_Fields_Last_Modified__c FROM Account WHERE createddate = Yesterday OR Umbrella_Fields_Last_Modified__c = Yesterday';
              }
              else if(Label.X2016UmbrellaAccounts == 'false'){
                        query = 'SELECT Id,Name,createddate,X2016_Strategic_Account__c,X2016_Enterprise_Umbrella__c,Umbrella_Account_Id__c,Umbrella_Fields_Last_Modified__c FROM Account where X2016_Strategic_Account__c = true or X2016_Enterprise_Umbrella__c = true ';
              }
              return Database.getQueryLocator(query);
        }
        
        
        //String query = 'SELECT Id,Name,createddate,X2016_Strategic_Account__c,X2016_Enterprise_Umbrella__c,Umbrella_Account_Id__c,Umbrella_Fields_Last_Modified__c FROM Account WHERE id'+' '+'='+' '+'\'001E000001JdqK0\'';
        
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
         List<Account> scopeList = (List<Account>)scope;
          for(Account a : scopeList){
              AccountStructures accS = new AccountStructures();
              accS.setcurrentId(a.id);
              accS.getObjectStructure();
          }       
         
    }   
    global void finish(Database.BatchableContext BC)
    {
    }
}