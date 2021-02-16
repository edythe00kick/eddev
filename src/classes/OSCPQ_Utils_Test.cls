@isTest
public class OSCPQ_Utils_Test {
    @isTest static void testGetContractSettings(){
        CPQ_Setting__mdt settings = OSCPQ_Utils.getContractSettings('Default');
        system.assert(settings != null); 
        
        settings = OSCPQ_Utils.getContractSettings('DOES_NOT_EXIST_TESTING');
        system.assert(settings == null);
    }
    
    @isTest static void testGetCustomCPQSettings(){
        CPQ_Custom_Setting__mdt settings = OSCPQ_Utils.getCPQCustomSettings('Default');
        system.assert(settings != null); 
        
        settings = OSCPQ_Utils.getCPQCustomSettings('DOES_NOT_EXIST_TESTING');
        system.assert(settings == null);
    }
    
    @isTest static void testCreateQTCError(){
        OSCPQ_Error__c err = OSCPQ_Utils.createQTCError('Error Testing', //Subject
                                    'CPQ', //targetPackage
                                    'Renewal Automation', //process
                                    'OSCPQ_Utils_Test.createQTCError', //classMethodName
                                    'This is a test error message', //Description
                                    null, //runningUserId
                                    true
        );
        
        List<OSCPQ_Error__c> errList = [Select Id FROM OSCPQ_Error__c];
        system.assertEquals(1, errList.size());
    }
    
    @isTest static void testCreateQTCErrorFromDMLSave(){
        Database.SaveResult sr1 = (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);
        Database.SaveResult sr2 = (Database.SaveResult)JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.SaveResult.class);	
        
		//Test 'create single error' scenario
        List<OSCPQ_Error__c> errs = OSCPQ_Utils.createQTCErrorFromDMLSave('Test Save Error',
                                                                          'CPQ',
                                                                          'Renewal Automation',
                                                                          'TestClass',
                                                                          null,
                                                                          new List<Database.SaveResult>{sr1},
                                                                          false,
                                                                          true
                                                                         );
        
        
        List<OSCPQ_Error__c> errList = [Select Id FROM OSCPQ_Error__c];
        system.assertEquals(1, errList.size());
		delete errList;
        
        //Test 'create multiple errors' scenario
        errs = OSCPQ_Utils.createQTCErrorFromDMLSave('Test Save Error',
                                                   'CPQ',
                                                   'Renewal Automation',
                                                   'TestClass',
                                                   null,
                                                   new List<Database.SaveResult>{sr1, sr2},
                                                   true,
                                                   true
                                                  );
        errList = [Select Id FROM OSCPQ_Error__c];
        system.assertEquals(2, errList.size());
    }
    
    @isTest static void testCreateQTCErrorFromDMLSaveDelete() {
        Database.DeleteResult dr1 = (Database.DeleteResult)JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.DeleteResult.class);
        Database.DeleteResult dr2 = (Database.DeleteResult)JSON.deserialize('{"success":false,"errors":[{"message":"You cannot do this...","statusCode":"FIELD_CUSTOM_VALIDATION_EXCEPTION"}]}', Database.DeleteResult.class);	
        
		//Test 'create single error' scenario
        List<OSCPQ_Error__c> errs = OSCPQ_Utils.createQTCErrorFromDMLSave('Test Save Error',
                                                                          'CPQ',
                                                                          'Renewal Automation',
                                                                          'TestClass',
                                                                          null,
                                                                          new List<Database.DeleteResult>{dr1},
                                                                          false,
                                                                          true
                                                                         );
        
        
        List<OSCPQ_Error__c> errList = [Select Id FROM OSCPQ_Error__c];
        system.assertEquals(1, errList.size());
		delete errList;
        
        //Test 'create multiple errors' scenario
        errs = OSCPQ_Utils.createQTCErrorFromDMLSave('Test Save Error',
                                                   'CPQ',
                                                   'Renewal Automation',
                                                   'TestClass',
                                                   null,
                                                   new List<Database.DeleteResult>{dr1, dr2},
                                                   true,
                                                   true
                                                  );
        errList = [Select Id FROM OSCPQ_Error__c];
        system.assertEquals(2, errList.size());
    }
    
    @isTest static void testTwinMappingPull() {
        Account acct = OSCPQ_TestFactory.createSingleAccount(true);
        Opportunity opp = OSCPQ_TestFactory.createSingleOpp(acct, true);
        SBQQ__Quote__c quote = OSCPQ_TestFactory.createSingleQuote(acct, opp, true, false);
        quote.SBQQ__OrderGroupID__c = 'test123'; //This field exists on both Opp and Quote;
		insert quote;
        opp.SBQQ__PrimaryQuote__c = quote.Id;
        update opp;
        
        Test.startTest();
        OSCPQ_Utils.twinMapFieldsPull(new List<Opportunity>{opp}, 'SBQQ__Quote__c', 'SBQQ__PrimaryQuote__c', true);
        Test.stopTest();
        
        Opportunity oppPostTest = [SELECT Id, SBQQ__OrderGroupID__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        system.assert(oppPostTest.SBQQ__OrderGroupID__c == 'test123', 'Actual OrderGroupId was ' +oppPostTest.SBQQ__OrderGroupID__c );
    }
    
    @isTest static void testTwinMappingPush() {
        Account acct = OSCPQ_TestFactory.createSingleAccount(true);
        Opportunity opp = OSCPQ_TestFactory.createSingleOpp(acct, true);
        SBQQ__Quote__c quote = OSCPQ_TestFactory.createSingleQuote(acct, opp, true, false);
        quote.SBQQ__OrderGroupID__c = 'test123'; //This field exists on both Opp and Quote;
		insert quote;
        
        Test.startTest();
        OSCPQ_Utils.twinMapFieldsPush(new List<SBQQ__Quote__c>{quote}, 'Opportunity', 'SBQQ__Opportunity2__c', true);
        Test.stopTest();
        
        Opportunity oppPostTest = [SELECT Id, SBQQ__OrderGroupID__c FROM Opportunity WHERE Id = :opp.Id LIMIT 1];
        system.assert(oppPostTest.SBQQ__OrderGroupID__c == 'test123');
    }
}