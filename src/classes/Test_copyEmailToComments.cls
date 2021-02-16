@isTest
public class Test_copyEmailToComments{
    static testMethod void EmailToComments() {
       Test.startTest() ;
           Case c = new Case();
           c.status = 'Submitted';
           c.recordtypeid=System.Label.SalesOpsCaseRecordTypeid;
           insert c;
           EmailMessage[] newEmail = new EmailMessage[0];
           newEmail.add(new EmailMessage(FromAddress = 'test@abc.org', Incoming = True, ToAddress= 'hello@670ocglw7xhomi4oyr5yw2zvf.8kp7yeag.8.case.salesforce.com', Subject = 'Test email', TextBody = 'Test it On ##-Please reply above this line-## ref:_', ParentId =c.Id)); 
           insert newEmail;        
       Test.stopTest();
    }
 }