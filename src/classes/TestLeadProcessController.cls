@isTest(seeAllData = true)
public class TestLeadProcessController{
    static testmethod void TestFlow(){
       Test.StartTest();
       Lead newLead1 = new Lead(
                        Company = 'Test Accounts', LastName= 'Test Leads',RLM_Status_Field__c='Responder',
                        LeadSource = 'Web',  
                        Status = '4 - Converted',CurrencyIsoCode = 'USD', recordTypeId = '012E0000000VRBaIAO');
        
        Insert newLead1;
        PageReference pageRefff = Page.ConvLead;
        pageRefff.getParameters().put('id',newLead1.id);
        Test.setCurrentPage(pageRefff); 
        LeadProcessController objk = new LeadProcessController(null);
        //Flow.Interview.AskOpportunityCreation myFlow;
        //myFlow=null;
        objk.myFlow = NULL;
        objk.getmyID();
        objk.getOID();
        objk.getRenderVariable();
        Test.StopTest();
    }
}