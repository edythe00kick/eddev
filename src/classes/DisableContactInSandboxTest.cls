/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class DisableContactInSandboxTest {

    static testMethod void DisableContactInSandboxScheduler_test() {
        // 
        // Test class to test DisableContactInSandboxScheduler class
        // coverage at 100%
        // 06/05/2018 - jhorton
        //
        String CRON_EXP = '0 0 0 3 9 ? 2022';
        
        test.startTest();
        
            // Schedule the test job
            String jobId = System.schedule('testBasicScheduledApex',
                                           CRON_EXP, new DisableContactInSandboxScheduler());
            
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, NextFireTime
                              FROM CronTrigger WHERE id = :jobId];
            
            // Verify the expressions are the same
            system.assertEquals(CRON_EXP, ct.CronExpression);
            
            // Verify the job has not run
            system.assertEquals(0, ct.TimesTriggered);
            
            // Verify the next time the job will run
            system.assertEquals('2022-09-03 00:00:00', String.valueOf(ct.NextFireTime));      
           
        test.stopTest();        
    }
    
    static testMethod void DisableContactInSandboxLoader_test() {
        // 
        // Test class to test DisableContactInSandboxLoader class
        // coverage at 100%
        // 06/05/2018 - jhorton
        //
        
        Account a = TestUtils.getAccount('Test Acc');
        a.Type = 'Customer';
        insert a;
        
        //
        // Create contact
        //
        Contact myC = TestUtils.getContact('TestName',a.Id);
        myC.email = 'Testing@test.com';
        insert myC;
         
        DisableContactInSandboxLoader myLoader = new DisableContactInSandboxLoader();
        
        //
        // Query for Accounts
        //
        myLoader.query = 'select id, Email from Contact where Email != null ';
        test.startTest();
            ID batchprocessid = Database.executeBatch(myLoader,200);  // <- set to the rows to process in the batch 
        test.stopTest();
        system.assertNotEquals(batchprocessid, null);
    }
}