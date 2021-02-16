/**
***    @description:    Test for Trigger and Handler of Event_Registration__c object
***    @author:         JP Horton (jhorton@alteryx.com)
***    @createdDate :   December 1, 2017
***	   @testclass : 	EventRegistrationTriggerTest.cls
 */
@isTest
private class EventRegistrationTriggerTest {

    static testMethod void insertEventRegWithContact() {
        // TO DO: implement unit test
        Account acc1 = TestUtils.getAccount('Test Account');
     	insert acc1;
        
        Contact con1 = TestUtils.getContact('Test',acc1.Id);
     	con1.Email = 'test@alteryx.com';
     	insert con1;
     	
     	Event__c v = new Event__c(Name = 'Test Event');
     	insert v;
     	
     	Test.startTest();
     	Event_Registration__c e = new Event_Registration__c(Event_Name__c = v.Id, Email_Address__c = 'test@alteryx.com', Last_Name__c = 'test', Company__c = 'test');
     	insert e;
     	
     	Event_Registration__c eCheck = [SELECT Id, Lead__c, Contact__c FROM Event_Registration__c WHERE Id =: e.Id];
     	system.assertEquals(eCheck.Contact__c, con1.Id);
     	Test.stopTest();
    }
    
    static testMethod void insertEventRegWithLead() {
        // TO DO: implement unit test                
        Lead l = new Lead(LastName = 'test', Company = 'test company', Status = '1 - Not Contacted', Email = 'test@alteryx.com');
        insert l;
     	
     	Event__c v = new Event__c(Name = 'Test Event');
     	insert v;
     	
     	Test.startTest();
     	Event_Registration__c e = new Event_Registration__c(Event_Name__c = v.Id, Email_Address__c = 'test@alteryx.com', Last_Name__c = 'test', Company__c = 'test');
     	insert e;
     	
     	Event_Registration__c eCheck = [SELECT Id, Lead__c, Contact__c FROM Event_Registration__c WHERE Id =: e.Id];
     	system.assertEquals(eCheck.Lead__c, l.Id);
     	Test.stopTest();
    }
    
    static testMethod void insertEventRegWithNoLead() {
        // TO DO: implement unit test       
     	Event__c v = new Event__c(Name = 'Test Event');
     	insert v;
     	
     	Test.startTest();
     	Event_Registration__c e = new Event_Registration__c(Event_Name__c = v.Id, Email_Address__c = 'test@alteryx.com', Last_Name__c = 'test', Company__c = 'test');
     	insert e;
     	Test.stopTest();
     	
     	Event_Registration__c eCheck = [SELECT Id, Lead__c FROM Event_Registration__c WHERE Id =: e.Id];
     	system.assertNotEquals(eCheck.Lead__c,null);
    }
}