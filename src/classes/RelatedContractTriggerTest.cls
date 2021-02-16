/* Author: Sharma Nemani | W-011617
 * Date: 06/12/2019
 * Description: Test class for Trigger - RelatedContractTrigger.
*/ 
@isTest
private class RelatedContractTriggerTest {
    @testSetup static void dataSetup(){
        Account acc = new Account();
        Acc.name = 'testAcc';
        Acc.Type = 'Customer';
        insert acc;
        
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        cont.StartDate = system.today();
        insert cont;
        
        Opportunity opp1 = new opportunity();
        opp1.AccountId = acc.Id;
        opp1.name = 'test1';
        opp1.CloseDate = system.today().addDays(5);
        opp1.StageName = '1 - Identification';
        opp1.type ='ECUR';
        insert opp1;
        
        Opportunity opp = [select id,SBQQ__RenewedContract__c from Opportunity where Id = : opp1.Id];
        opp.SBQQ__RenewedContract__c = cont.Id;
        update opp;
        system.assertEquals(1,[select id from Related_Contract__c].size());
    }
    
    static testMethod void RelatedContractHandlerTest() {
        delete [select id from Related_Contract__c];
        system.assertEquals(0,[select id from Related_Contract__c].size());
    }
}