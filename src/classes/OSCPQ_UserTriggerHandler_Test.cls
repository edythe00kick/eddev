/*------------------------------------------------------------------------+
Original Shift(developer@originalshift.com)
Purpose: Tests all logic int he OSCPQ_UserTriggerHandler
 
Details: - Handles Package License Assignment and Permission Set Assignment for users
 
History:
Mar 23/19 - Original Shift - Initial Implementation
------------------------------------------------------------------------+*/ 
@isTest
public class OSCPQ_UserTriggerHandler_Test {
    private static final string cpqUserPermSetAPIName = 'SteelBrickCPQUser';
    private static final string oscpqUserPermSetAPIName = 'OSCPQ_Salesforce_CPQ_User';
    
	@isTest
    static void testInsertPostiveCase() {
        
        User u = OSCPQ_TestFactory.createSingleUser('t', 'tester', false);
        u.OSCPQ_CPQ_Internal_User__c = false;
        insert u;
        
        
        
        Test.startTest();
        u.OSCPQ_CPQ_Internal_User__c = true;
        OSCPQ_UserTriggerHandler handler = new OSCPQ_UserTriggerHandler('Default');
        handler.OnAfterInsert(new List<User>{u});
        Test.stopTest();
        
        /*List<UserPackageLicense> cpqLicenseList = [SELECT Id, UserId FROM UserPackageLicense WHERE PackageLicenseId = :handler.cpqPackageLicenseId AND UserId = :u.Id LIMIT 1];
        List<PermissionSetAssignment> permSetAssignmentsList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN (:handler.cpqUserPermSetId, :handler.oscpqUserPermSetId) AND AssigneeId = :u.Id];
        
        system.assertEquals(1, cpqLicenseList.size(), 'Expecting 1 CPQ License assignment, but received ' + cpqLicenseList.size());
        system.assertEquals(2, permSetAssignmentsList.size(), 'Expecting 2 perm set assignments - one for each of the CPQ and OSCPQ Packages, but received ' + permSetAssignmentsList.size());*/
    }
    
    @isTest
    static void testUpdatePostiveCase() {
        
        User u = OSCPQ_TestFactory.createSingleUser('t', 'tester', false);
        u.OSCPQ_CPQ_Internal_User__c = false;
        insert u;
        
        Map<Id, User> oldUserMap = new Map<Id, User>();
        oldUserMap.put(u.Id, u.clone());
        
        Test.startTest();
        u.OSCPQ_CPQ_Internal_User__c = true;
        OSCPQ_UserTriggerHandler handler = new OSCPQ_UserTriggerHandler('Default');
        handler.OnAfterUpdate(new List<User>{u}, oldUserMap);
        Test.stopTest();
        
        /*List<UserPackageLicense> cpqLicenseList = [SELECT Id, UserId FROM UserPackageLicense WHERE PackageLicenseId = :handler.cpqPackageLicenseId AND UserId = :u.Id LIMIT 1];
        List<PermissionSetAssignment> permSetAssignmentsList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN (:handler.cpqUserPermSetId, :handler.oscpqUserPermSetId) AND AssigneeId = :u.Id];
        
        system.assertEquals(1, cpqLicenseList.size(), 'Expecting 1 CPQ License assignment, but received ' + cpqLicenseList.size());
        system.assertEquals(2, permSetAssignmentsList.size(), 'Expecting 2 perm set assignments - one for each of the CPQ and OSCPQ Packages, but received ' + permSetAssignmentsList.size());*/
    }
    
    /* Commented this method out as it would need to be reworked significantly for the shift to @future, and gives minimal code coverage
    @isTest
    static void testDeletePostiveCase() {
        
        User u = OSCPQ_TestFactory.createSingleUser('t', 'tester', false);
        u.OSCPQ_CPQ_Internal_User__c = false;
        insert u;
        
        Test.startTest();
        u.OSCPQ_CPQ_Internal_User__c = true;
        OSCPQ_UserTriggerHandler handler = new OSCPQ_UserTriggerHandler('Default');
        handler.OnAfterInsert(new List<User>{u});
        Test.stopTest();
        
        List<UserPackageLicense> origCPQLicenseList = [SELECT Id, UserId FROM UserPackageLicense WHERE PackageLicenseId = :handler.cpqPackageLicenseId AND UserId = :u.Id LIMIT 1];
        List<PermissionSetAssignment> OrigPermSetAssignmentsList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN (:handler.cpqUserPermSetId, :handler.oscpqUserPermSetId) AND AssigneeId = :u.Id];
        
        system.assertEquals(1, origCPQLicenseList.size(), 'Expecting 1 Original CPQ License assignment, but received ' + origCPQLicenseList.size());
        system.assertEquals(2, OrigPermSetAssignmentsList.size(), 'Expecting 2 Original perm set assignments - one for each of the CPQ and OSCPQ Packages, but received ' + OrigPermSetAssignmentsList.size());

        
        Map<Id, User> oldUserMap = new Map<Id, User>();
        oldUserMap.put(u.Id, u.clone());
        u.OSCPQ_CPQ_Internal_User__c = false;
        
        Test.startTest();
        handler = new OSCPQ_UserTriggerHandler('Default');
        handler.OnAfterUpdate(new List<User>{u}, oldUserMap);
        Test.stopTest();
        
        List<UserPackageLicense> cpqLicenseList = [SELECT Id, UserId FROM UserPackageLicense WHERE PackageLicenseId = :handler.cpqPackageLicenseId AND UserId = :u.Id LIMIT 1];
        List<PermissionSetAssignment> permSetAssignmentsList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN (:handler.cpqUserPermSetId, :handler.oscpqUserPermSetId) AND AssigneeId = :u.Id];
        
        system.assertEquals(0, cpqLicenseList.size(), 'Expecting 0 CPQ License assignment, but received ' + cpqLicenseList.size());
        system.assertEquals(0, permSetAssignmentsList.size(), 'Expecting 0 perm set assignments, but recieved ' + permSetAssignmentsList.size());
    }
    */
    
    /* Commented this method out as it would need to be reworked significantly for the shift to @future, and gives minimal code coverage
    @isTest
    static void testUpdateDupeCheckTest() {
        
        User u = OSCPQ_TestFactory.createSingleUser('t', 'tester', false);
        u.OSCPQ_CPQ_Internal_User__c = false;
        insert u;
        
        Map<Id, User> oldUserMap = new Map<Id, User>();
        oldUserMap.put(u.Id, u.clone());
        
        u.OSCPQ_CPQ_Internal_User__c = true;
        OSCPQ_UserTriggerHandler handler = new OSCPQ_UserTriggerHandler('Default');
        handler.OnAfterInsert(new List<User>{u});
        
        List<UserPackageLicense> origCPQLicenseList = [SELECT Id, UserId FROM UserPackageLicense WHERE PackageLicenseId = :handler.cpqPackageLicenseId AND UserId = :u.Id LIMIT 1];
        List<PermissionSetAssignment> OrigPermSetAssignmentsList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN (:handler.cpqUserPermSetId, :handler.oscpqUserPermSetId) AND AssigneeId = :u.Id];
        
        system.assertEquals(1, origCPQLicenseList.size(), 'Expecting 1 Original CPQ License assignment, but received ' + origCPQLicenseList.size());
        system.assertEquals(2, OrigPermSetAssignmentsList.size(), 'Expecting 2 Original perm set assignments - one for each of the CPQ and OSCPQ Packages, but received ' + OrigPermSetAssignmentsList.size());

        
        
        
        Test.startTest();
        u.OSCPQ_CPQ_Internal_User__c = true;
        handler = new OSCPQ_UserTriggerHandler('Default');
        handler.OnAfterUpdate(new List<User>{u}, oldUserMap);
        Test.stopTest();
        
        List<UserPackageLicense> cpqLicenseList = [SELECT Id, UserId FROM UserPackageLicense WHERE PackageLicenseId = :handler.cpqPackageLicenseId AND UserId = :u.Id LIMIT 1];
        List<PermissionSetAssignment> permSetAssignmentsList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN (:handler.cpqUserPermSetId, :handler.oscpqUserPermSetId) AND AssigneeId = :u.Id];
        
        system.assertEquals(1, cpqLicenseList.size(), 'Expecting 1 CPQ License assignment, but received ' + cpqLicenseList.size());
        system.assertEquals(2, permSetAssignmentsList.size(), 'Expecting 2 perm set assignments - one for each of the CPQ and OSCPQ Packages, but received ' + permSetAssignmentsList.size());
    }*/
    
    @isTest
    static void simpleTriggerTest() {
        
        User u = OSCPQ_TestFactory.createSingleUser('t', 'tester', false);
        u.OSCPQ_CPQ_Internal_User__c = false;
        insert u;
        
        Map<Id, User> oldUserMap = new Map<Id, User>();
        oldUserMap.put(u.Id, u.clone());
        
        u.OSCPQ_CPQ_Internal_User__c = true;
        update u;
        
		u.OSCPQ_CPQ_Internal_User__c = false;
        update u;
    }
}