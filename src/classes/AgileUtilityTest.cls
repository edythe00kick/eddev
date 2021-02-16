@isTest
public with sharing class AgileUtilityTest {
    @isTest
    public static void createCaseScenrio1() {

        Account acc = TestUtils.getAccount('Test Account');
        insert acc;
        
        Product_Tag__c product = new Product_Tag__c();
        product.Name = 'SFDC';
        insert product;

        Id CaseRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Business Systems Support Ticket' LIMIT 1].Id;
        Case cs = TestUtils.getCase(CaseRecId);
        cs.Business_System__c = 'SFDC';
        insert cs;

        List<Case> caseList = [SELECT Id, Work__c FROM Case];

        System.assertEquals(null, caseList[0].Work__c);

        Test.startTest();

        AgileUtility.createNewAgileWork(cs.Id);

        Test.stopTest();

        caseList = [SELECT Id, Work__c FROM Case];

    }

    @isTest
    public static void createReleaseScenario2() {
        Id profId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1].Id;
        User user =  TestUtils.getUser('Test User',profId);
        insert user;

        Release__c release= new Release__c();
        release.Name = 'Test release';
        release.Release_Manager__c= user.Id;
        insert release;

        List<Release__c> releaseList = [SELECT Id, Change_Control_Case__c FROM Release__c];

        System.assertEquals(null, releaseList[0].Change_Control_Case__c);
        
        Test.startTest();

        AgileUtility.CreateChangeControl(release.Id);

        Test.stopTest();

        releaseList = [SELECT Id, Change_Control_Case__c FROM Release__c];
    }
}