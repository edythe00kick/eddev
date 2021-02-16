@isTest
public class OSCPQ_OrderAutomation_Test {
	@testSetup
    static void testSetup(){
        Account acct = OSCPQ_TestFactory.createSingleAccount(true);
        Opportunity opp = OSCPQ_TestFactory.createSingleOpp(acct, true);
        SBQQ__Quote__c quote = OSCPQ_TestFactory.createSingleQuote(acct, opp, true, true);
        
        
        Product2 prod = OSCPQ_TestFactory.createBasicRenewableProduct(1, true);
        List<PricebookEntry> pbeList = OSCPQ_TestFactory.createPBEntries(new List<Product2>{prod}, true);
        
        Order ord = OSCPQ_TestFactory.createSingleOrder(acct, opp, quote, true);
        OrderItem oi = OSCPQ_TestFactory.createSingleOrderitem(ord, prod, pbeList[0], true);
    }
    
    @isTest static void testImmediateActivationAndContract(){
        Order ord = [SELECT Id, SBQQ__Contracted__c, Status FROM Order];
        system.debug([SELECT Id FROM OrderItem WHERE OrderId = :ord.Id]);
        //Check initial state
        system.assert(ord.SBQQ__Contracted__c == false, 'Initialized value of SBQQ__Contracted__c is NOT false and will interfere with this test');
        system.assert(ord.Status == 'Draft', 'Initialized value of Status is NOT Draft and will interfere with this test');

        Test.startTest();
        OSCPQ_OrderAutomation_Batch batch = new OSCPQ_OrderAutomation_Batch('Default');
        batch.settings.Ordering_AutomaticActivation__c = 'OnCreate';
        batch.settings.Contracting_GenerationPoint__c = 'Order';
        
		Id batchId = Database.executeBatch(batch, 1);
        Test.stopTest();
        
        ord = [SELECT Id, SBQQ__Contracted__c, Status FROM Order WHERE Id = :ord.Id];
        system.assert(Ord.Status == 'Activated', 'Status should be Activated, but is ' + ord.Status);

        ApexClass aC = [SELECT Id, Name FROM ApexClass WHERE Name ='OSCPQ_OrderAutomation_Queueable' LIMIT 1];
        List<AsyncApexJob> jobsList = [SELECT Id, ApexClassID FROM AsyncApexJob WHERE ApexClassID = :aC.Id];
        system.debug(jobsList);
        //Name: Chris Salgado Date: 9/17/2019 Purpose: W-012815 Change: From 1 To 0
        system.assertEquals(0, jobsList.size(), 'Expecting a single enqueue job, but there are ' + jobsList.size());
        
    }
    
    @isTest static void testOnStartDateActivationPostive(){
        Order ord = [SELECT Id, SBQQ__Contracted__c, Status FROM Order];
        system.debug([SELECT Id FROM OrderItem WHERE OrderId = :ord.Id]);
        //Check initial state
        system.assert(ord.SBQQ__Contracted__c == false, 'Initialized value of SBQQ__Contracted__c is NOT false and will interfere with this test');
        system.assert(ord.Status == 'Draft', 'Initialized value of Status is NOT Draft and will interfere with this test');

        Test.startTest();
        OSCPQ_OrderAutomation_Batch batch = new OSCPQ_OrderAutomation_Batch('Default');
        batch.settings.Ordering_AutomaticActivation__c = 'OnStartDate';
        batch.settings.Contracting_GenerationPoint__c = 'Order';
        
		Id batchId = Database.executeBatch(batch, 1);
        Test.stopTest();
        
        ord = [SELECT Id, SBQQ__Contracted__c, Status FROM Order WHERE Id = :ord.Id];
        system.assert(Ord.Status == 'Activated', 'Status should be Activated, but is ' + ord.Status);
        
        ApexClass aC = [SELECT Id, Name FROM ApexClass WHERE Name ='OSCPQ_OrderAutomation_Queueable' LIMIT 1];
        List<AsyncApexJob> jobsList = [SELECT Id, ApexClassID FROM AsyncApexJob WHERE ApexClassID = :aC.Id];
        system.debug(jobsList);
        //Name: Chris Salgado Date: 9/17/2019 Purpose: W-012815 Change: From 1 To 0
        system.assertEquals(0, jobsList.size(), 'Expecting a single enqueue job, but there are ' + jobsList.size());
    }
    
    @isTest static void testOnStartDateActivationNegative(){
        Order ord = [SELECT Id, SBQQ__Contracted__c, Status, EffectiveDate FROM Order];
        ord.EffectiveDate = Date.today() + 30;
        update ord;
        
        system.debug([SELECT Id FROM OrderItem WHERE OrderId = :ord.Id]);
        //Check initial state
        system.assert(ord.SBQQ__Contracted__c == false, 'Initialized value of SBQQ__Contracted__c is NOT false and will interfere with this test');
        system.assert(ord.Status == 'Draft', 'Initialized value of Status is NOT Draft and will interfere with this test');

        Test.startTest();
        OSCPQ_OrderAutomation_Batch batch = new OSCPQ_OrderAutomation_Batch('Default');
        batch.settings.Ordering_AutomaticActivation__c = 'OnStartDate';
        batch.settings.Contracting_GenerationPoint__c = 'Order';
        
		Id batchId = Database.executeBatch(batch, 1);
        Test.stopTest();
        
        ord = [SELECT Id, SBQQ__Contracted__c, Status FROM Order WHERE Id = :ord.Id];
        system.assert(Ord.Status == 'Draft', 'Status should be Draft still, but is ' + ord.Status);
        
        ApexClass aC = [SELECT Id, Name FROM ApexClass WHERE Name ='OSCPQ_OrderAutomation_Queueable' LIMIT 1];
        List<AsyncApexJob> jobsList = [SELECT Id, ApexClassID FROM AsyncApexJob WHERE ApexClassID = :aC.Id];
        system.debug(jobsList);
        system.assertEquals(0, jobsList.size(), 'Expecting no enqueue jobs, but there are ' + jobsList.size());
    }
    
    @isTest static void testNoActivation(){
        Order ord = [SELECT Id, SBQQ__Contracted__c, Status FROM Order];
        system.debug([SELECT Id FROM OrderItem WHERE OrderId = :ord.Id]);
        //Check initial state
        system.assert(ord.SBQQ__Contracted__c == false, 'Initialized value of SBQQ__Contracted__c is NOT false and will interfere with this test');
        system.assert(ord.Status == 'Draft', 'Initialized value of Status is NOT Draft and will interfere with this test');

        Test.startTest();
        OSCPQ_OrderAutomation_Batch batch = new OSCPQ_OrderAutomation_Batch('Default');
        batch.settings.Ordering_AutomaticActivation__c = 'Never';
        batch.settings.Contracting_GenerationPoint__c = 'Order';
        
		Id batchId = Database.executeBatch(batch, 1);
        Test.stopTest();
        
        ord = [SELECT Id, SBQQ__Contracted__c, Status FROM Order WHERE Id = :ord.Id];
        system.assert(Ord.Status == 'Draft', 'Status should be Draft, but is ' + ord.Status);
        
        ApexClass aC = [SELECT Id, Name FROM ApexClass WHERE Name ='OSCPQ_OrderAutomation_Queueable' LIMIT 1];
        List<AsyncApexJob> jobsList = [SELECT Id, ApexClassID FROM AsyncApexJob WHERE ApexClassID = :aC.Id];
        system.debug(jobsList);
        system.assertEquals(0, jobsList.size(), 'Expecting no single enqueue jobs, but there are ' + jobsList.size());
        
    }
    
    @isTest static void testQueueableSingle(){
    	Order ord = [SELECT Id, SBQQ__Contracted__c, Status FROM Order LIMIT 1];
        ord.Status = 'Activated';
        update ord;
        
        List<Id> ordIdList = new List<Id>{ord.Id};
            
        CPQ_Setting__mdt settings = OSCPQ_Utils.getContractSettings('Default');
        settings.Contracting_GenerationPoint__c = 'Order';
        
        OSCPQ_OrderAutomation_Queueable que = new OSCPQ_OrderAutomation_Queueable(ordIdList, settings);
        Test.startTest();
        System.enqueueJob(que);
        Test.stopTest();
        
        ord = [SELECT Id, SBQQ__Contracted__c, Status FROM Order LIMIT 1];
        system.assert(ord.SBQQ__Contracted__c == true);
    }

    //Existing Order Schedule
    @isTest static void testSchedule(){
        String CRON_EXP = '0 0 0 15 3 ? 2022';
        
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('OSCPQ_OrderAutomation_Schedule', CRON_EXP, new OSCPQ_OrderAutomation_Schedule());         
        // Get list of already-scheduled jobs for a reference point
        List<AsyncApexJob> ltOld = [SELECT Id FROM AsyncApexJob];
        Test.stopTest();
        
        List<AsyncApexJob> ltNew = [SELECT Id FROM AsyncApexJob];
        System.assert(ltNew.size() > ltOld.size(), 'New AsyncApexJobs were not created');
    }

    //Name: Chris Salgado Date: 9/17/2019 Purpose: W-012815
    //New Contract Schedule
    @isTest static void testContractSchedule(){
        String CRON_EXP = '0 0 0 15 3 ? 2022';

        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('OSCPQ_ContractAutomation_Schedule', CRON_EXP, new OSCPQ_OrderAutomation_Schedule());
        // Get list of already-scheduled jobs for a reference point
        List<AsyncApexJob> ltOld = [SELECT Id FROM AsyncApexJob];
        Test.stopTest();

        List<AsyncApexJob> ltNew = [SELECT Id FROM AsyncApexJob];
        System.assert(ltNew.size() > ltOld.size(), 'New AsyncApexJobs were not created');
    }
}