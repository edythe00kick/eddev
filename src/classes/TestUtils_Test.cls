/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestUtils_Test {

    static testMethod void myUnitTest() {
         Test.StartTest(); 
     
     // TO DO: implement unit test
     //Add Account
     Account acc1 = TestUtils.getAccount('Test Account');
     insert acc1;
     system.assertEquals(acc1.Name,'Test Account');
     
     Contact con1 = TestUtils.getContact('Test',acc1.Id);
     insert con1;
     system.assertEquals(con1.AccountID,acc1.Id);
     
     //Add Opportunity
     Id OppRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Opportunity' AND Name = 'Alteryx Record Type' LIMIT 1].Id;
     Opportunity opp1 = TestUtils.getOpportunity('test opp',acc1.Id, OppRecId);
     insert opp1;
     system.assertEquals(opp1.AccountID,acc1.Id);
       
     //Add Attachment
     Attachment attach1 = TestUtils.getAttachment('test attach',opp1.Id);
     insert attach1;
     system.assertEquals(attach1.parentId,opp1.Id);
     
     Id CaseRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Business Systems Support Ticket' LIMIT 1].Id;
     Case c = TestUtils.getCase(CaseRecId);
     
     Id profId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
     User u = TestUtils.getUser('Test Man',profId);
     
     Id workRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'agf__ADM_Work__c' AND Name = 'User Story' LIMIT 1].Id;
     agf__ADM_Work__c w = TestUtils.getWork('Test Work',workRecId);
     
     Test.StopTest(); 
     
    }
    
    static testMethod void myUnitTest2() {
    
    Map<String, Double> conversionRatesMap = new Map<String,Double> ();
    
    Test.StartTest();
    conversionRatesMap = UtilityClass.getConversionRates();
    Test.StopTest();
    }
}