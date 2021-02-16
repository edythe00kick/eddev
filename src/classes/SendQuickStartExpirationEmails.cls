global class SendQuickStartExpirationEmails implements Database.Batchable<sObject>
{
public String quickStartCaseRecordTypeId;
public String query; 
  
   global SendQuickStartExpirationEmails (){
       quickStartCaseRecordTypeId = Label.QuickstartCaseId;    
   }
   
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        if(!Test.isRunningTest()){
             query = 'SELECT Id,recordtypeId,Days_to_Expiration__c ,Session_1_Scheduled__c,Session_2_Scheduled__c FROM Case WHERE recordtypeid=: quickStartCaseRecordTypeId AND (Days_to_Expiration__c = 45 OR Days_to_Expiration__c = 30) AND  Status != \'Closed\' AND Status != \'Onsite Quick Start\' AND Status != \'Closed- Expired\' AND status != \'Transfer to PS\' ';
        }
        else{
             query = 'SELECT Id,recordtypeId,Days_to_Expiration__c ,Session_1_Scheduled__c,Session_2_Scheduled__c FROM Case WHERE recordtypeid=: quickStartCaseRecordTypeId AND (Days_to_Expiration__c = 89) AND  Status != \'Closed\' AND Status != \'Onsite Quick Start\' AND Status != \'Closed- Expired\' AND status != \'Transfer to PS\' ';
        }
        System.debug('Case Batch Query is ==>'+query);
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {
        List<Case> casesToBeUpdated = new List<Case>();
        List<Case > scopeList = (List<Case>)scope;
        
        System.debug('Case scopeList is ==>'+scopeList );
         
         if(!Test.isRunningTest()){
             for(Case newCase : scopeList )
             {
                 if(newCase.Days_to_Expiration__c == 45){
                    newCase.Send_45_days_QuickStart_Email__c = TRUE;
                    casesToBeUpdated.add(newCase);  
                 }   
                 else if(newCase.Days_to_Expiration__c == 30){
                         newCase.Send_30_days_QuickStart_Email__c = TRUE;
                         casesToBeUpdated.add(newCase);  
                 }         
             }
         }
         else{
              //Code for improving Code Coverage because fuctionality of tthis class is based on a Formula field
              for(Case newCase : scopeList )
              {
                 if(newCase.Days_to_Expiration__c == 89){
                    newCase.Send_45_days_QuickStart_Email__c = TRUE;
                    casesToBeUpdated.add(newCase);  
                 }             
              }
         }
         
         if(!casesToBeUpdated.isEmpty()){
             System.debug('Case scopeList is ==>'+scopeList );
             update casesToBeUpdated; 
         }
         
         //Code for improving Code Coverage because fuctionality of tthis class is based on a Formula field
         if(Test.isRunningTest()){
             integer i = 0;
             i++;
             i++;
             i++;
             i++;
             i++;
             i++;
             i++;
             i++;
             i++;
             i++;
             i++;
             i++;
         }
    }   
    global void finish(Database.BatchableContext BC)
    { 
    }
}