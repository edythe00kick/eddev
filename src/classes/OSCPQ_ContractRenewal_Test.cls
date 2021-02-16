@isTest
public class OSCPQ_ContractRenewal_Test {
	@testSetup
    static void testSetup(){
        Account a = OSCPQ_TestFactory.createSingleAccount(true);
        Contract c = OSCPQ_TestFactory.createSingleContract(a, true);
    	Id cpqContractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();
    }
    
    @isTest static void testAllImmediateBatch(){
        //Force parameters to make this true
        Contract c = [SELECT Id, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Status FROM Contract];
        system.assert(c.SBQQ__RenewalForecast__c == false, 'Initialized value of SBQQ__RenewalForecast__c is NOT false and will interfere with this test');
        system.assert(c.SBQQ__RenewalQuoted__c == false, 'Initialized value of SBQQ__RenewalQuoted__c is NOT false and will interfere with this test');
        system.assert(c.Status == 'Draft', 'Initialized value of Status is NOT Draft and will interfere with this test');
        
        Test.startTest();
        SBQQ.TriggerControl.disable(); //disable CPQ trigger so that no opp is created in the 
        OSCPQ_ContractRenewal_Batch batch = new OSCPQ_ContractRenewal_Batch('Default');
        batch.settings.Contracting_AutomaticActivation__c = 'OnStartDate';
        batch.settings.AutoForecast_Enabled__c = true;
        batch.settings.AutoForecast_Timing__c = 'DaysBefore';
        batch.settings.AutoForecast_NumDays__c = 0;
        batch.settings.AutoForecast_ReferenceField__c = 'CreatedDate';
        batch.settings.AutoRenewQuote_Enabled__c = true;
        batch.settings.AutoRenewQuote_Timing__c = 'DaysBefore';
        batch.settings.AutoRenewQuote_NumDays__c = 0;
        batch.settings.AutoRenewQuote_ReferenceField__c = 'CreatedDate';
        
		Id batchId = Database.executeBatch(batch, 1);
        Test.stopTest();
        
        c = [SELECT Id, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Status FROM Contract];
        /*Commented by Sergio, 1/17/2019 Due to updated Contract Settings this no longer applies
        system.assert(c.SBQQ__RenewalForecast__c == true, 'SBQQ__RenewalForecast__c should be true');
        system.assert(c.SBQQ__RenewalQuoted__c == true, 'SBQQ__RenewalQuoted__c should be true');
        system.assert(c.Status == 'Activated', 'Status should be Activated, but is ' + c.Status);*/
    }
    
    @isTest static void testAllTimeDelayBatch() {
        //Force parameters to make this true
        Contract c = [SELECT Id, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Status FROM Contract];
        system.assert(c.SBQQ__RenewalForecast__c == false, 'Initialized value of SBQQ__RenewalForecast__c is NOT false and will interfere with this test');
        system.assert(c.SBQQ__RenewalQuoted__c == false, 'Initialized value of SBQQ__RenewalQuoted__c is NOT false and will interfere with this test');
        system.assert(c.Status == 'Draft', 'Initialized value of Status is NOT Draft and will interfere with this test');
        
        Test.startTest();
		SBQQ.TriggerControl.disable(); //disable CPQ trigger so that no opp is created in the 
        OSCPQ_ContractRenewal_Batch batch = new OSCPQ_ContractRenewal_Batch('Default');
        batch.settings.Contracting_AutomaticActivation__c = 'OnCreate';
        batch.settings.AutoForecast_Enabled__c = true;
        batch.settings.AutoForecast_Timing__c = 'Immediately';
        batch.settings.AutoForecast_NumDays__c = null;
        batch.settings.AutoForecast_ReferenceField__c = '';
        batch.settings.AutoRenewQuote_Enabled__c = true;
        batch.settings.AutoRenewQuote_Timing__c = 'Immediately';
        batch.settings.AutoRenewQuote_NumDays__c = null;
        batch.settings.AutoRenewQuote_ReferenceField__c = '';
        
		Id batchId = Database.executeBatch(batch, 1);

        Test.stopTest();
        
        c = [SELECT Id, SBQQ__RenewalForecast__c, SBQQ__RenewalQuoted__c, Status FROM Contract];
        /*Commented by Sergio, 1/17/2019 Due to updated Contract Settings this no longer applies
        system.assert(c.SBQQ__RenewalForecast__c == true, 'SBQQ__RenewalForecast__c should be true');
        system.assert(c.SBQQ__RenewalQuoted__c == true, 'SBQQ__RenewalQuoted__c should be true');
        system.assert(c.Status == 'Activated', 'Status should be Activated, but is ' + c.Status);*/
    }
    
    @isTest static void testSchedule(){
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('OSCPQ_ContractRenewal_Schedule', CRON_EXP, new OSCPQ_ContractRenewal_Schedule());         
        // Get list of already-scheduled jobs for a reference point
        List<AsyncApexJob> ltOld = [SELECT Id FROM AsyncApexJob];
        Test.stopTest();
        
        List<AsyncApexJob> ltNew = [SELECT Id FROM AsyncApexJob];
        System.assert(ltNew.size() > ltOld.size(), 'New AsyncApexJobs were not created');
    }
}