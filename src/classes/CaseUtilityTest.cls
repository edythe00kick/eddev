/**
 * Test Class the CaseUtility.cls
 * 
 * @author  JP Horton <jhorton@alteryx.com>
 * @since   20171010
 */
@isTest
private class CaseUtilityTest {

    //Project
    static testMethod void testCreateProject() {
        // TO DO: implement unit test
        Account a = TestUtils.getAccount('Test Acct A');
        insert a;

        Contact n = TestUtils.getContact('Test Contact',a.Id);
        insert n;
        
        agf__ADM_Scrum_Team__c ST = new agf__ADM_Scrum_Team__c(Name = 'SFDC', agf__Cloud__c = 'IT');
        insert ST;
        
        agf__ADM_Product_Tag__c PT = new agf__ADM_Product_Tag__c(Name = 'SFDC', agf__Team__c = ST.Id);
        insert PT;
        
        agf__ADM_Build__c b = new agf__ADM_Build__c(Name = 'Test');
        insert b;
        
        Id CaseRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Business Systems Support Ticket' LIMIT 1].Id;
        Case c = TestUtils.getCase(CaseRecId);
        c.Task_or_Project__c = 'Project';
        c.Type = 'New Feature';
        c.ContactID = n.Id;
        c.Business_System__c = 'SFDC';
        insert c;
        
        Test.StartTest(); 
        CaseUtility.CreateNewAgileWork(c.Id);
        Test.StopTest(); 
    }
    
    //Bug
    static testMethod void testCreateBug() {
        // TO DO: implement unit test
        Account a = TestUtils.getAccount('Test Acct A');
        insert a;

        Contact n = TestUtils.getContact('Test Contact',a.Id);
        insert n;
        
        agf__ADM_Scrum_Team__c ST = new agf__ADM_Scrum_Team__c(Name = 'SFDC', agf__Cloud__c = 'IT');
        insert ST;
        
        agf__ADM_Product_Tag__c PT = new agf__ADM_Product_Tag__c(Name = 'SFDC', agf__Team__c = ST.Id);
        insert PT;
        
        agf__ADM_Build__c b = new agf__ADM_Build__c(Name = 'Test');
        insert b;

        Id CaseRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Business Systems Support Ticket' LIMIT 1].Id;
        Case c = TestUtils.getCase(CaseRecId);
        c.Task_or_Project__c = 'Task';
        c.Type = 'Bug';
        c.ContactID = n.Id;
        c.Business_System__c = 'SFDC';
        insert c;
        
        Test.StartTest(); 
        CaseUtility.CreateNewAgileWork(c.Id);
        Test.StopTest(); 
    }
    
    //Enhancement
    static testMethod void testCreateEnhancement() {
        // TO DO: implement unit test
        Account a = TestUtils.getAccount('Test Acct A');
        insert a;
        
        Contact n = TestUtils.getContact('Test Contact',a.Id);
        insert n;
        
        Id profId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User u = TestUtils.getUser('Test Man',profId);
        insert u;

        agf__ADM_Scrum_Team__c ST = new agf__ADM_Scrum_Team__c(Name = 'SFDC', agf__Cloud__c = 'IT');
        insert ST;
        
        agf__ADM_Product_Tag__c PT = new agf__ADM_Product_Tag__c(Name = 'SFDC', agf__Team__c = ST.Id);
        insert PT;
        
        agf__ADM_Build__c b = new agf__ADM_Build__c(Name = 'Test');
        insert b;

        Id CaseRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Business Systems Support Ticket' LIMIT 1].Id;
        Case c = TestUtils.getCase(CaseRecId);
        c.Task_or_Project__c = 'Task';
        c.Type = 'New Feature';
        c.ContactID = n.Id;
        c.OwnerID = u.Id;
        c.Business_System__c = 'SFDC';
        insert c;
        
        Test.StartTest(); 
        CaseUtility.CreateNewAgileWork(c.Id);
        Test.StopTest(); 
    }
    
    static testMethod void testCreateWithWork() {
        // TO DO: implement unit test
        Account a = TestUtils.getAccount('Test Acct A');
        insert a;
        
        Contact n = TestUtils.getContact('Test Contact',a.Id);
        insert n;
        
        Id profId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id;
        User u = TestUtils.getUser('Test Man',profId);
        insert u;

        agf__ADM_Scrum_Team__c ST = new agf__ADM_Scrum_Team__c(Name = 'SFDC', agf__Cloud__c = 'IT');
        insert ST;
        
        agf__ADM_Product_Tag__c PT = new agf__ADM_Product_Tag__c(Name = 'SFDC', agf__Team__c = ST.Id);
        insert PT;

        Id workRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'agf__ADM_Work__c' AND Name = 'User Story' LIMIT 1].Id;
        agf__ADM_Work__c w = TestUtils.getWork('Test Work',workRecId);
        w.agf__Product_Tag__c = PT.Id;
        insert w;

        agf__ADM_Build__c b = new agf__ADM_Build__c(Name = 'Test');
        insert b;

        Id CaseRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Business Systems Support Ticket' LIMIT 1].Id;
        Case c = TestUtils.getCase(CaseRecId);
        c.Task_or_Project__c = 'Task';
        c.Type = 'New Feature';
        c.ContactID = n.Id;
        c.OwnerID = u.Id;
        c.agf__ADM_Work__c = w.Id;
        c.Business_System__c = 'SFDC';
        insert c;
        
        Test.StartTest();      
        CaseUtility.CreateNewAgileWork(c.Id);
        Test.StopTest(); 
    }
}