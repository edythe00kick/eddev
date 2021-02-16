@isTest
private class EducationalLicenseRequestControllerTest {
    @isTest
    private static void testController() {
        Account acc = new Account();
        acc.Name = 'Test AccountELRC';
        insert acc;
        PageReference pageRef = Page.EducationalLicenseRequestPage;
        pageRef.getParameters().put('AccntID',acc.Id);
        Test.setCurrentPageReference(pageRef);
        EducationalLicenseRequestPageController elrp = new EducationalLicenseRequestPageController(null);
    }
    
    @isTest
    private static void testSaveScenario1() {
        Account acc = new Account();
        acc.Name = 'Test AccountELRC';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'ContactELRC';
        con.Email = 'test@contactelrc.edu';
        con.AccountId = acc.Id;
        insert con;
        
        EducationalLicenseRequestPageController elrp = new EducationalLicenseRequestPageController(null);
        elrp.elr.Account__c = acc.Id;
        // Assign Educational License Record Type
        elrp.elr.RecordTypeId = Evaluation_License_Request__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Educational License Record Type').getRecordTypeId();
        elrp.elr.Product_Bundle__c = 'Alteryx Designer Academic Use';
        elrp.elr.Contact__c = con.Id;
        elrp.elr.Number_Of_Licenses__c = 1;
        elrp.elr.Expiration_Date__c = Date.today() + 67;
        elrp.save();
        elrp.cancel();
    }
    
    @isTest
    private static void testSaveScenario2() {
        Account acc = new Account();
        acc.Name = 'Test AccountELRC';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'ContactELRC';
        con.Email = 'test@contactelrc.com';
        con.AccountId = acc.Id;
        insert con;
        
        EducationalLicenseRequestPageController elrp = new EducationalLicenseRequestPageController(null);
        elrp.elr.Account__c = acc.Id;
        // Assign Educational License Record Type
        elrp.elr.RecordTypeId = Evaluation_License_Request__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Educational License Record Type').getRecordTypeId();
        elrp.elr.Product_Bundle__c = 'Alteryx Designer Academic Use';
        elrp.elr.Contact__c = con.Id;
        elrp.elr.Number_Of_Licenses__c = 1;
        elrp.elr.Expiration_Date__c = Date.today() + 91;
        elrp.save();
    }
    
    @isTest
    private static void testSaveScenario3() {
        Account acc = new Account();
        acc.Name = 'Test AccountELRC';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'ContactELRC';
        con.Email = 'test@contactelrc.edu';
        con.AccountId = acc.Id;
        insert con;
        
        EducationalLicenseRequestPageController elrp = new EducationalLicenseRequestPageController(null);
        elrp.elr.Account__c = acc.Id;
        // Assign Educational License Record Type
        elrp.elr.RecordTypeId = Evaluation_License_Request__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Educational License Record Type').getRecordTypeId();
        elrp.elr.Product_Bundle__c = 'Alteryx Designer Academic Use';
        elrp.elr.Contact__c = con.Id;
        elrp.elr.Number_Of_Licenses__c = 1;
        elrp.elr.Expiration_Date__c = Date.today() + 200;
        elrp.save();
    }
    
    @isTest
    private static void testLeftover() {
        EducationalLicenseRequestPageController elrp = new EducationalLicenseRequestPageController(null);
        elrp.licenseType = 'Educational License';
        elrp.setLicenseToEdit();
        elrp.licenseType = 'NFR License';
        elrp.setLicenseToEdit();
        elrp.getLicenseTypes();
        elrp.showEditPage = false;
    }
}