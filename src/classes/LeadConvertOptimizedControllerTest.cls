/*
 * Class Name - LeadConvertOptimizedControllerTest.
 * 
 * %W% %E% Grazitti Team
 * This is the test class for "LeadConvertOptimizedController" class.
 */

/**
 * This class contains different methods to check the code coverage.
 * 
 * @author Hemendra Singh Rajawat
 * @version 1.0 March 16, 2018
 */

@isTest
public class LeadConvertOptimizedControllerTest {

    /**
     * Test when opportunity is not created and existing account is not 
     * selected.
     */

    @isTest
    public static void testScenario1() {
        Lead ld = OrgWideTestUtil.createLead(false);
        ld.RLM_Status_Field__c = 'Responder';
        insert ld;

        Test.startTest();

        PageReference pg = Page.LeadConvertOptimized;
        pg.getParameters().put('id', ld.Id);
        pg.getParameters().put('AcceptMQL', 'Yes');
        Test.setCurrentPage(pg);

        LeadConvertOptimizedController lcOb 
            = new LeadConvertOptimizedController();

        LeadStatus ls = [SELECT MasterLabel 
                         FROM LeadStatus 
                         WHERE IsConverted = true 
                         LIMIT 1];

        lcOb.sendnotification = true;
        lcOb.selectedAccount = 'NEW';
        lcOb.dummyLead.Lead_Close_Reason__c 
            = 'Duplicate Record - Non Existing User';

        lcOb.selectedAccountChange();
        lcOb.ConvertLead();
        lcOb.Cancel();

        Test.stopTest();
    }

    /**
     * Test when opportunity is created and existing account is not selected.
     */

    @isTest
    public static void testScenario2() {
        Lead ld = OrgWideTestUtil.createLead(false);
        ld.RLM_Status_Field__c = 'MQL';
        insert ld;

        Test.startTest();

        PageReference pg = Page.LeadConvertOptimized;
        pg.getParameters().put('id', ld.Id);
        pg.getParameters().put('AcceptMQL', 'Yes');
        Test.setCurrentPage(pg);

        LeadConvertOptimizedController lcOb 
            = new LeadConvertOptimizedController();

        LeadStatus ls = [SELECT MasterLabel 
                         FROM LeadStatus 
                         WHERE IsConverted = true 
                         LIMIT 1];

        Date cd = Date.today().addDays(10);
        lcOb.createopp = true;
        lcOb.sendnotification = true;
        lcOb.selectedAccount = 'NEW';
        lcOb.dummyLead.Lead_Close_Reason__c 
            = 'Duplicate Record - Non Existing User';

        lcOb.dummyOpp.CloseDate = cd;
        lcOb.OppType = 'NB';
        lcOb.getClassOfBusiness();
        lcOb.ConvertLead();

        Test.stopTest();
    }

    /**
     * Test when opportunity is created and existing account is selected.
     */

    @isTest
    public static void testScenario3() {
        Account acc = OrgWideTestUtil.createAccount(true);

        Lead ld = OrgWideTestUtil.createLead(false);
        ld.Company = 'OWTU';
        insert ld;

        Test.startTest();

        PageReference pg = Page.LeadConvertOptimized;
        pg.getParameters().put('id', ld.Id);
        pg.getParameters().put('AcceptMQL', 'Yes');
        Test.setCurrentPage(pg);

        LeadConvertOptimizedController lcOb 
            = new LeadConvertOptimizedController();

        LeadStatus ls = [SELECT MasterLabel 
                         FROM LeadStatus 
                         WHERE IsConverted = true 
                         LIMIT 1];

        Date cd = Date.today().addDays(10);
        lcOb.createopp = true;
        lcOb.sendnotification = true;
        lcOb.selectedAccount = acc.Id;
        lcOb.dummyLead.Lead_Close_Reason__c 
            = 'Duplicate Record - Non Existing User';

        lcOb.dummyOpp.CloseDate = cd;
        lcOb.dummyContact.AccountId = acc.Id;
        lcOb.OppType = 'NB';
        lcOb.getClassOfBusiness();
        lcOb.AccountLookedUp();
        lcOb.selectedAccountChange();
        lcOb.ConvertLead();

        Test.stopTest();
    }

    /**
     * Test when opportunity is created and existing account and contact
     * is selected.
     */

    @isTest
    public static void testScenario4() {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(true, acc.Id);

        Lead ld = OrgWideTestUtil.createLead(false);
        ld.FirstName = cont.FirstName;
        ld.LastName = cont.LastName;
        ld.Email = cont.Email;
        ld.Company = acc.Name;
        ld.Warm_SLA_Date__c = System.today();
        insert ld;

        Test.startTest();

        PageReference pg = Page.LeadConvertOptimized;
        pg.getParameters().put('id', ld.Id);
        pg.getParameters().put('AcceptMQL', 'Yes');
        Test.setCurrentPage(pg);

        LeadConvertOptimizedController lcOb 
            = new LeadConvertOptimizedController();

        LeadStatus ls = [SELECT MasterLabel 
                         FROM LeadStatus 
                         WHERE IsConverted = true 
                         LIMIT 1];

        Date cd = Date.today().addDays(10);
        lcOb.createopp = true;
        lcOb.sendnotification = true;
        lcOb.selectedAccount = acc.Id;
        lcOb.selectedContact = cont.Id;
        lcOb.dummyLead.Lead_Close_Reason__c 
            = 'Duplicate Record - Non Existing User';

        lcOb.dummyOpp.CloseDate = cd;
        lcOb.dummyContact.AccountId = acc.Id;
        lcOb.OppType = 'NB';
        lcOb.getClassOfBusiness();
        lcOb.AccountLookedUp();
        lcOb.selectedAccountChange();
        lcOb.ConvertLead();

        Test.stopTest();
    }

    /**
     * Method to cover the catch block of "ConvertLead".
     */

    @isTest
    public static void testScenario5() {
        Lead ld = OrgWideTestUtil.createLead(true);

        Test.startTest();

        PageReference pg = Page.LeadConvertOptimized;
        pg.getParameters().put('id', ld.Id);
        Test.setCurrentPage(pg);

        LeadConvertOptimizedController lcOb 
            = new LeadConvertOptimizedController();

        lcOb.sendnotification = true;
        lcOb.selectedAccount = 'NEW';
        lcOb.dummyLead.Lead_Close_Reason__c = '';
        lcOb.ConvertLead();

        Test.stopTest();
    }

    /**
     * Method to cover the error message in "LeadConvertOptimizedHelper" class.
     */

    @isTest
    public static void testScenario6() {
        Lead ld = OrgWideTestUtil.createLead(true);

        Test.startTest();

        PageReference pg = Page.LeadConvertOptimized;
        pg.getParameters().put('id', ld.Id);
        Test.setCurrentPage(pg);

        LeadConvertOptimizedController lcOb 
            = new LeadConvertOptimizedController();

        lcOb.sendnotification = false;
        lcOb.selectedAccount = 'NEW';
        lcOb.createOpp = true;
        lcOb.dummyOpp = new Opportunity();
        lcOb.ConvertLead();
        lcOb.selectedAccount = 'NONE';
        lcOb.dummyLead.Lead_Close_Reason__c = '';
        lcOb.ConvertLead();
        lcOb.selectedAccount = 'NEW';
        Id ownerId = lcOb.dummyAccount.ownerId;
        lcOb.dummyAccount.ownerId = null;
        lcOb.ConvertLead();
        lcOb.dummyAccount.ownerId = ownerId;
        lcOb.oppName = '';
        lcOb.createOpp = true;
        lcOb.ConvertLead();
        lcOb.createOpp = false;
        lcOb.hascontact = true;
        lcOb.selectedContact = 'NONE';
        lcOb.ConvertLead();

        Test.stopTest();
    }

    /**
     * Method to cover the error message in "LeadConvertOptimizedHelper" class.
     */

    @isTest
    public static void testScenario7() {
        Lead ld = OrgWideTestUtil.createLead(true);

        Test.startTest();

        PageReference pg = Page.LeadConvertOptimized;
        pg.getParameters().put('id', ld.Id);
        Test.setCurrentPage(pg);

        LeadConvertOptimizedController lcOb 
            = new LeadConvertOptimizedController();

        lcOb.sendnotification = false;
        lcOb.createOpp = false;
        lcOb.selectedContact = 'NONE';
        lcOb.ConvertLead();

        Test.stopTest();
    }

    /**
     * Test when "NBEC" opportunity is created and existing account and contact
     * is selected to generate the error.
     */

    @isTest
    public static void testScenario8() {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(true, acc.Id);

        Lead ld = OrgWideTestUtil.createLead(false);
        ld.FirstName = cont.FirstName;
        ld.LastName = cont.LastName;
        ld.Email = cont.Email;
        ld.Company = acc.Name;
        insert ld;

        Test.startTest();

        PageReference pg = Page.LeadConvertOptimized;
        pg.getParameters().put('id', ld.Id);
        Test.setCurrentPage(pg);

        LeadConvertOptimizedController lcOb 
            = new LeadConvertOptimizedController();

        LeadStatus ls = [SELECT MasterLabel 
                         FROM LeadStatus 
                         WHERE IsConverted = true 
                         LIMIT 1];

        Date cd = Date.today().addDays(10);
        lcOb.createopp = true;
        lcOb.sendnotification = true;
        lcOb.selectedAccount = acc.Id;
        lcOb.selectedContact = cont.Id;
        lcOb.dummyLead.Lead_Close_Reason__c 
            = 'Duplicate Record - Non Existing User';

        lcOb.dummyOpp.CloseDate = cd;
        lcOb.dummyContact.AccountId = acc.Id;
        lcOb.OppType = 'NBEC';
        lcOb.ConvertLead();

        Test.stopTest();
    }

    /**
     * Method to cover "SetLeadOwner" in "LeadConvertOptimizedHelper" class.
     */

    @isTest
    public static void testScenario9() {
        Lead ld = OrgWideTestUtil.createLead(true);

        Test.startTest();

        PageReference pg = Page.LeadConvertOptimized;
        pg.getParameters().put('id', ld.Id);
        Test.setCurrentPage(pg);

        LeadConvertOptimizedController lcOb 
            = new LeadConvertOptimizedController();

        LeadStatus ls = [SELECT MasterLabel 
                         FROM LeadStatus 
                         WHERE IsConverted = true 
                         LIMIT 1];

        String uniqueUserNameA = 'testscenario9a@testorg.com';
        Profile pA = [SELECT Id 
                      FROM Profile 
                      WHERE Name = 'Alteryx - ANZ - Customer Support'];

        User uA = new User(Alias = 'standt', Email='standarduser@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', 
                           LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pA.Id, 
                           TimeZoneSidKey='America/Los_Angeles', 
                           UserName=uniqueUserNameA);

        System.runAs(uA) {
            Date cd = Date.today().addDays(10);
            lcOb.createopp = true;
            lcOb.sendnotification = true;
            lcOb.selectedAccount = 'NEW';
            lcOb.dummyLead.Lead_Close_Reason__c 
            = 'Duplicate Record - Non Existing User';

            lcOb.dummyOpp.CloseDate = cd;
            lcOb.OppType = 'NB';
            lcOb.ConvertLead();
        }

        Test.stopTest();
    }

    /**
     * Method to cover "SetLeadOwner" in "LeadConvertOptimizedHelper" class.
     */

    @isTest
    public static void testScenario10() {
        Lead ld = OrgWideTestUtil.createLead(true);

        Test.startTest();

        PageReference pg = Page.LeadConvertOptimized;
        pg.getParameters().put('id', ld.Id);
        Test.setCurrentPage(pg);

        LeadConvertOptimizedController lcOb 
            = new LeadConvertOptimizedController();

        LeadStatus ls = [SELECT MasterLabel 
                         FROM LeadStatus 
                         WHERE IsConverted = true 
                         LIMIT 1];

        String uniqueUserNameA = 'testscenario9b@testorg.com';
        Profile pA = [SELECT Id 
                      FROM Profile 
                      WHERE Name = 'Alteryx - Denmark - Partner Sales Rep'];

        User uA = new User(Alias = 'standt', Email='standarduser@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', 
                           LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = pA.Id, 
                           TimeZoneSidKey='America/Los_Angeles', 
                           UserName=uniqueUserNameA);

        System.runAs(uA) {
            Date cd = Date.today().addDays(10);
            lcOb.createopp = true;
            lcOb.sendnotification = true;
            lcOb.selectedAccount = 'NEW';
            lcOb.dummyLead.Lead_Close_Reason__c 
            = 'Duplicate Record - Non Existing User';

            lcOb.dummyOpp.CloseDate = cd;
            lcOb.OppType = 'NB';
            lcOb.ConvertLead();
        }

        Test.stopTest();
    }

    //Sergio Flores
    //Testing no close date scenario
    @isTest
    public static void noCloseDate() {
        Account acc = OrgWideTestUtil.createAccount(true);

        Lead ld = OrgWideTestUtil.createLead(false);
        ld.Company = 'OWTU';
        insert ld;

        Test.startTest();

        PageReference pg = Page.LeadConvertOptimized;
        pg.getParameters().put('id', ld.Id);
        pg.getParameters().put('AcceptMQL', 'Yes');
        Test.setCurrentPage(pg);

        LeadConvertOptimizedController lcOb 
            = new LeadConvertOptimizedController();

        LeadStatus ls = [SELECT MasterLabel 
                         FROM LeadStatus 
                         WHERE IsConverted = true 
                         LIMIT 1];

        Date cd = Date.today().addDays(10);
        lcOb.createopp = true;
        lcOb.sendnotification = true;
        lcOb.selectedAccount = acc.Id;
        lcOb.dummyLead.Lead_Close_Reason__c 
            = 'Duplicate Record - Non Existing User';

        //lcOb.dummyOpp.CloseDate = cd;
        lcOb.dummyContact.AccountId = acc.Id;
        lcOb.OppType = 'NB';
        lcOb.getClassOfBusiness();
        lcOb.AccountLookedUp();
        lcOb.selectedAccountChange();
        lcOb.ConvertLead();

        Test.stopTest();
    }
}