@isTest
private class TEST_LeadMQLAcceptProcessController{

static testMethod void myUnitTest3(){
        Lead newLead4 = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',RLM_Status_Field__c='Responder',
                        LeadSource = 'Web',  
                        Status = '4 - Converted',CurrencyIsoCode = 'USD', recordTypeId = '012E0000000VRBaIAO');
        
        Insert newLead4;
        LeadMQLAcceptProcessController objk = new LeadMQLAcceptProcessController(null);
        Flow.Interview.AcceptMQLFlow myFlow;
        myFlow =null;
        objk.getmyID();
        PageReference reference = new PageReference('/apex/leadConvertPage?id='+newlead4.id);
        objk.getOID();
        TaskRedirectController tObj = new TaskRedirectController (null);
        Task tt = new Task(WhoId=newlead4.id,Subject='Call',Status='Not Started',Priority='Normal' );
        PageReference pageRef = new PageReference('/'+tt.id); 
        tObj.taskpageRedirect(); 
 }
}