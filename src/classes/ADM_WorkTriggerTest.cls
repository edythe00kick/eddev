/*
* @name : ADM_WorkTriggerTest : test class to cover the WorkTrigger and its handler
* @author : JP Horton 
* @date : 20171013
*/
@isTest
private class ADM_WorkTriggerTest {

    static testMethod void testCreateReleaseFlag1() {
        // CASE: Add a release to a work item, verify the creation of the new Release Tag
        Id WorkRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'agf__ADM_Work__c' and Name = 'Bug'].Id;
        agf__ADM_Work__c w = TestUtils.getWork('Test Item A', WorkRecId);
        insert w;
        
        agf__ADM_Release__c r = new agf__ADM_Release__c();
        r.Name = 'Test A';
        insert r;
        
        Test.StartTest();
	        w.agf__Status__c = 'Closed';
	        w.Release__c = r.Id;
			update w;
			
			agf__ADM_Released_In__c RFlag = [SELECT Id, agf__Release__c, Release_Status__c, agf__Selected__c FROM agf__ADM_Released_In__c WHERE agf__Work__c =: w.Id];
			
			system.assertEquals(RFlag.agf__Release__c , r.Id);
			system.assertEquals(RFlag.Release_Status__c , 'Selected for Release');
			system.assertEquals(RFlag.agf__Selected__c , true);			
		Test.StopTest();        
    }
    
    static testMethod void testCreateReleaseFlag2() {
        // CASE: Add a release to a work item, verify the creation of the new Release Tag, swap the Work to a different release
        Id WorkRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'agf__ADM_Work__c' and Name = 'Bug'].Id;
        agf__ADM_Work__c w = TestUtils.getWork('Test Item A', WorkRecId);
        insert w;
        
        agf__ADM_Release__c r1 = new agf__ADM_Release__c();
        r1.Name = 'Test A';
        insert r1;
        
		w.agf__Status__c = 'Closed';
	    w.Release__c = r1.Id;
		update w;
			
		agf__ADM_Released_In__c RFlag = [SELECT Id, agf__Release__c, Release_Status__c, agf__Selected__c FROM agf__ADM_Released_In__c WHERE agf__Work__c =: w.Id];
			
		system.assertEquals(RFlag.agf__Release__c , r1.Id);
		system.assertEquals(RFlag.Release_Status__c , 'Selected for Release');
		system.assertEquals(RFlag.agf__Selected__c , true);		
		
		RFlag.Deployed_to_Production__c = true;	
		update RFlag;
		
		agf__ADM_Release__c r2 = new agf__ADM_Release__c();
        r2.Name = 'Test B';
        insert r2;
        
		Test.StartTest();
		 	w.Release__c = r2.Id;
			update w;
			
			agf__ADM_Released_In__c RFlag2 = [SELECT Id, agf__Release__c, Release_Status__c, agf__Selected__c FROM agf__ADM_Released_In__c WHERE agf__Work__c =: w.Id AND agf__Release__c =: r2.Id];
			
			system.assertEquals(RFlag2.agf__Release__c , r2.Id);
			system.assertEquals(RFlag2.Release_Status__c , 'Selected for Release');
			system.assertEquals(RFlag2.agf__Selected__c , true);
			
			agf__ADM_Released_In__c RFlag1 = [SELECT Id, agf__Release__c, Release_Status__c, agf__Selected__c, agf__Reverted__c FROM agf__ADM_Released_In__c WHERE agf__Work__c =: w.Id AND agf__Release__c =: r1.Id];
			
			system.assertEquals(RFlag1.agf__Release__c , r1.Id);
			system.assertEquals(RFlag1.Release_Status__c , 'Reverted');
			system.assertEquals(RFlag1.agf__Selected__c , true);
			system.assertEquals(RFlag1.agf__Reverted__c , true);
		Test.StopTest();        
    }
    
    static testMethod void testCreateReleaseFlag3() {
        // CASE: Add a release to a work item, verify the creation of the new Release Tag, remove the item from the release
        Id WorkRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'agf__ADM_Work__c' and Name = 'Bug'].Id;
        agf__ADM_Work__c w = TestUtils.getWork('Test Item A', WorkRecId);
        insert w;
        
        agf__ADM_Release__c r1 = new agf__ADM_Release__c();
        r1.Name = 'Test A';
        insert r1;
        
		w.agf__Status__c = 'Closed';
	    w.Release__c = r1.Id;
		update w;
			
		agf__ADM_Released_In__c RFlag = [SELECT Id, agf__Release__c, Release_Status__c, agf__Selected__c FROM agf__ADM_Released_In__c WHERE agf__Work__c =: w.Id];
			
		system.assertEquals(RFlag.agf__Release__c , r1.Id);
		system.assertEquals(RFlag.Release_Status__c , 'Selected for Release');
		system.assertEquals(RFlag.agf__Selected__c , true);			
        
		Test.StartTest();
		 	w.Release__c = null;
			update w;
			
			agf__ADM_Released_In__c RFlag1 = [SELECT Id, agf__Release__c, Release_Status__c, agf__Selected__c FROM agf__ADM_Released_In__c WHERE agf__Work__c =: w.Id AND agf__Release__c =: r1.Id];
			
			system.assertEquals(RFlag1.agf__Release__c , r1.Id);
			system.assertEquals(RFlag1.Release_Status__c , 'Removed Prior to Release');
			system.assertEquals(RFlag1.agf__Selected__c , false);
		Test.StopTest();        
    }
    
    static testMethod void testCreateReleaseFlag4() {
        // CASE: Add a release to a work item, verify the creation of the new Release Tag, remove it from the release, then add it back to the release
        Id WorkRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'agf__ADM_Work__c' and Name = 'Bug'].Id;
        agf__ADM_Work__c w = TestUtils.getWork('Test Item A', WorkRecId);
        insert w;
        
        agf__ADM_Release__c r1 = new agf__ADM_Release__c();
        r1.Name = 'Test A';
        insert r1;
        
		w.agf__Status__c = 'Closed';
	    w.Release__c = r1.Id;
		update w;
			
		agf__ADM_Released_In__c RFlag = [SELECT Id, agf__Release__c, Release_Status__c, agf__Selected__c FROM agf__ADM_Released_In__c WHERE agf__Work__c =: w.Id];
			
		system.assertEquals(RFlag.agf__Release__c , r1.Id);
		system.assertEquals(RFlag.Release_Status__c , 'Selected for Release');
		system.assertEquals(RFlag.agf__Selected__c , true);			
        
		w.Release__c = null;
		update w;
			
		agf__ADM_Released_In__c RFlag1 = [SELECT Id, agf__Release__c, Release_Status__c, agf__Selected__c FROM agf__ADM_Released_In__c WHERE agf__Work__c =: w.Id AND agf__Release__c =: r1.Id];
			
		system.assertEquals(RFlag1.agf__Release__c , r1.Id);
		system.assertEquals(RFlag1.Release_Status__c , 'Removed Prior to Release');
		system.assertEquals(RFlag1.agf__Selected__c , false);
		
		Test.StartTest();
			w.Release__c = r1.Id;
			update w;
				
			agf__ADM_Released_In__c RFlag1b = [SELECT Id, agf__Release__c, Release_Status__c, agf__Selected__c FROM agf__ADM_Released_In__c WHERE agf__Work__c =: w.Id AND agf__Release__c =: r1.Id];
				
			system.assertEquals(RFlag1b.agf__Release__c , r1.Id);
			system.assertEquals(RFlag1b.Release_Status__c , 'Selected for Release');
			system.assertEquals(RFlag1b.agf__Selected__c , true);
		Test.StopTest();    
    }
    
    static testMethod void testCreateReleaseFlag5() {
        // CASE: coverage for the delete and undelete functionality
        Id WorkRecId = [SELECT Id,Name FROM RecordType WHERE SobjectType = 'agf__ADM_Work__c' and Name = 'Bug'].Id;
        agf__ADM_Work__c w = TestUtils.getWork('Test Item A', WorkRecId);
        insert w;
        
		Test.StartTest();
		 	delete w;
		 	undelete w;
		Test.StopTest();        
    }
}