@isTest
public class Test_SendQuickStartExpirationEmails{
    private static testMethod void testSendQuickStartExpirationEmails(){
     
      Account a = new Account();
      a.name = 'Test Acct';
      insert a;
      
      Case newCase = new Case();
      newCase.RecordTypeId = Label.QuickstartCaseId;
      newCase.accountid = a.id;
      newCase.status = 'Onboarding Scheduled';
      insert newCase;
      
      Test.startTest();
          SendQuickStartExpirationEmails obj = new SendQuickStartExpirationEmails();
          Database.executeBatch(obj);
      Test.stopTest();
    }
    
    private static testMethod void testScheduleSendQuickStartExpirationEmails(){
      Test.startTest();
          ScheduleSendQuickStartExpirationEmails obj = new ScheduleSendQuickStartExpirationEmails();
          obj.execute(null);
      Test.stopTest();
    }
}