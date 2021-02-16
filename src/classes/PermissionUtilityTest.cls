/**
*
* @author : JP Horton <jhorton@alteryx.com>
* @description : Test class for the PermissionUtility.cls
* @date : 20171027
*
 */
@isTest
private class PermissionUtilityTest {

    static testMethod void checkForFalse() {
        //Create User
        Id ProfId = [SELECT Id, Name FROM Profile WHERE Name = 'Alteryx - Sales - Account Executives'].Id;
        Id userId= [SELECT Id FROM User WHERE IsActive=true AND ProfileId =: ProfId LIMIT 1].Id;
        String CPermName = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName =: 'Allow_Add_Referrer_Partners' LIMIT 1].DeveloperName;
        
        Test.StartTest();
            boolean checkFlag = PermissionUtility.checkUsersCustPerm(CPermName, userId);
            system.assertEquals(checkFlag, false);
        Test.StopTest();
    }
    
    static testMethod void checkForTrue() {
        //Create User
        Id ProfId = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator'].Id;
        Id userId= [SELECT Id FROM User WHERE IsActive=true AND ProfileId =: ProfId LIMIT 1].Id;
        String CPermName = [SELECT Id, DeveloperName FROM CustomPermission WHERE DeveloperName =: 'Allow_Add_Referrer_Partners' LIMIT 1].DeveloperName;
        
        Test.StartTest();
            boolean checkFlag = PermissionUtility.checkUsersCustPerm(CPermName, userId);
            system.assertEquals(checkFlag, true);
        Test.StopTest();
    }
    
    static testMethod void checkBadName() {
        //Create User
        Id ProfId = [SELECT Id, Name FROM Profile WHERE Name = 'Alteryx - Sales - Account Executives'].Id;
        Id userId= [SELECT Id FROM User WHERE IsActive=true AND ProfileId =: ProfId LIMIT 1].Id;
        String CPermName = 'BadName';
        
        Test.StartTest();
            boolean checkFlag = PermissionUtility.checkUsersCustPerm(CPermName, userId);
            system.assertEquals(checkFlag, false);
        Test.StopTest();
    }
}