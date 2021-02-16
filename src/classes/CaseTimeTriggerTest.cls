/**
 * Custom Trigger for the Case_Time_Entry__c
 * 
 * @author		:	JP Horton <jhorton@alteryx.com>
 * @since 		:	20171018
 */
@isTest
private class CaseTimeTriggerTest {

    static testMethod void insertCaseTime() {
        // TO DO: implement unit test
        Id CaseRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Alteryx Standard Case' LIMIT 1].Id;
        Case c1 = new case(Subject='Test this Code',Description='This Description',Products__c ='Data',Business_System_Category__c='Feature Enhancement',Business_System__c='SFDC',Requested_Completion_Date__c=Date.today().AddDays(7),Case_Category__c='SDK',Severity__c='SEV 1');
        insert c1;
        Case checkCasetemp = [SELECT Id, Case_Time_Total__c FROM Case WHERE Id =: c1.Id];
        system.assertEquals(checkCasetemp.Case_Time_Total__c,0);
        
        Test.StartTest();
        Case_Time_Entry__c cte 
        = new Case_Time_Entry__c(
        	Active_Time_Spent__c = '1', 
        	Case__c = c1.Id, 
        	Date_Completed__c = system.today(), 
        	CurrencyIsoCode = 'USD',
        	Support_Type__c = 'Customer Support',
        	Support_Type_Detail__c = 'C2C');
        insert cte;
        	
        Case checkCase = [SELECT Id, Case_Time_Total__c FROM Case WHERE Id =: c1.Id];
        system.assertEquals(checkcase.Case_Time_Total__c,1);
        
        delete cte; 
        Case checkCase2 = [SELECT Id, Case_Time_Total__c FROM Case WHERE Id =: c1.Id];
        system.assertEquals(checkcase2.Case_Time_Total__c,0);
        
        undelete cte; 
        Case checkCase3 = [SELECT Id, Case_Time_Total__c FROM Case WHERE Id =: c1.Id];
        system.assertEquals(checkcase3.Case_Time_Total__c,1);
        Test.StopTest();
    }
    
    static testMethod void transferCaseTime() {
        // TO DO: implement unit test
        Id CaseRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'Case' AND Name = 'Alteryx Standard Case' LIMIT 1].Id;
        Case c1 = new case(Subject='Test this Code',Description='This Description',Products__c ='Data',Business_System_Category__c='Feature Enhancement',Business_System__c='SFDC',Requested_Completion_Date__c=Date.today().AddDays(7),Case_Category__c='SDK',Severity__c='SEV 1');
        insert c1;
        Case c2 = new case(Subject='Test this Code',Description='This Description',Products__c ='Data',Business_System_Category__c='Feature Enhancement',Business_System__c='SFDC',Requested_Completion_Date__c=Date.today().AddDays(7),Case_Category__c='SDK',Severity__c='SEV 1');
        insert c2;
        Case checkCasetemp1 = [SELECT Id, Case_Time_Total__c FROM Case WHERE Id =: c1.Id];
        system.assertEquals(checkCasetemp1.Case_Time_Total__c,0);
        Case checkCasetemp2 = [SELECT Id, Case_Time_Total__c FROM Case WHERE Id =: c1.Id];
        system.assertEquals(checkCasetemp2.Case_Time_Total__c,0);
        
        
        Case_Time_Entry__c cte 
        = new Case_Time_Entry__c(
        	Active_Time_Spent__c = '1', 
        	Case__c = c1.Id, 
        	Date_Completed__c = system.today(), 
        	CurrencyIsoCode = 'USD',
        	Support_Type__c = 'Customer Support',
        	Support_Type_Detail__c = 'C2C');
        insert cte;
        
        Case checkCase1a = [SELECT Id, Case_Time_Total__c FROM Case WHERE Id =: c1.Id];
        Case checkCase2a = [SELECT Id, Case_Time_Total__c FROM Case WHERE Id =: c2.Id];
        system.assertEquals(checkCase1a.Case_Time_Total__c,1);
        system.assertEquals(checkCase2a.Case_Time_Total__c,0);
        
        Test.StartTest();
        cte.Case__c = c2.Id;
        update cte;
        
        Case checkCase1b = [SELECT Id, Case_Time_Total__c FROM Case WHERE Id =: c1.Id];
        Case checkCase2b = [SELECT Id, Case_Time_Total__c FROM Case WHERE Id =: c2.Id];
        system.assertEquals(checkCase1b.Case_Time_Total__c,0);
        system.assertEquals(checkCase2b.Case_Time_Total__c,1);
        Test.StopTest();
        
    }
}