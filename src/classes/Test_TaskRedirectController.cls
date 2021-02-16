@isTest
public class Test_TaskRedirectController{
    static testMethod void myUnitTest32() {
       Lead newLead = new Lead(
                        Company = 'Test Accoucnt', LastName= 'Tesct Lead',
                        LeadSource = 'Web',  
                        Status = '4 - Converted',CurrencyIsoCode = 'USD', recordTypeId = '012E0000000VRBaIAO');
        
        Insert newLead;
        TaskRedirectController tObj = new TaskRedirectController (null);
        Task tt = new Task(WhoId=newlead.id,Subject='Call',Status='Not Started',Priority='Normal' );
        insert tt;
        PageReference pageRef = new PageReference('/'+tt.id); 
        tObj.taskpageRedirect();
    }
 }