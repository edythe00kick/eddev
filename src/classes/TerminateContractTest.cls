/* Autor: Sharma Nemani | W-013343
 * Date: 10/14/2019
 * Description: This Test Class is for 'TerminateContract' Batch Class.
*/
@isTest
private class TerminateContractTest {
    private static testMethod void testTerminateContract() {
        Account acc = new Account();
        acc.Name = 'testAcc';
        insert acc;
        
        Opportunity opp = new opportunity();
        opp.name = 'test';
        opp.CloseDate = system.today().addDays(5);
        opp.StageName = '1 - Identification';
        opp.Total_Contract_Value_Amount__c = 5000;
        insert opp;
        
        Contract cont = new Contract();
        cont.Name = 'testCon';
        cont.SBQQ__Opportunity__c  = opp.Id;
        cont.AccountId = acc.Id;
        //cont.status = 'Activated';
        cont.EndDate = system.today().addDays(-2);
        cont.ContractTerm = 12;
        
        insert cont;
        Contract contr = [select status from Contract where Id =:cont.Id];
        contr.Status = 'Activated';
        update contr;
        
        Test.startTest();
        	system.schedule('test', '0 0 22 * * ? *', new TerminateContract());
        	database.executeBatch(new TerminateContract(),1);
        Test.stopTest();
        System.assertEquals('Terminated', [select status from Contract where Id =:cont.Id].status);
    }
}