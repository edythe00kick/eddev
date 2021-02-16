/* Created by: Sharma Nemani
 * Date: 06/25/2019
 * Description: This Test Class is for BatchContractExpiration Batch Class and ScheduleBatchContractExpiration 
 * Scheduler Class.
*/
@isTest
private class BatchContractExpirationTest {
    static testMethod void testBatchClass() {
    	Account acc = new Account();
        Acc.name = 'testAcc';
        Acc.ShippingCountry = 'Germany';
        Acc.ShippingCity = 'Frankfurt';
        Acc.ShippingState = 'Hamburg';
        Acc.ShippingPostalCode = '60306';
        insert Acc;
        
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        cont.StartDate = system.today().addDays(-40);
        //cont.EndDate = system.today().addDays(-2);
        cont.Status_Category__c = 'In Effect';
        cont.ContractTerm  = 1;
        insert cont;
        
        String sch = '20 30 8 10 2 ?';
        Test.startTest();
        	database.executeBatch(new BatchContractExpiration(),10);
        	system.Schedule('test',sch,new ScheduleBatchContractExpiration());
        Test.stopTest();
        
    }
}