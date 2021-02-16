@isTest
public class AddPartnerControllerTest {

    @testSetup 
    public static void testData(){
        
        
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
        Account_BD_Owners_and_States__c  bdOwner = new Account_BD_Owners_and_States__c();
        bdOwner.Name = 'AK';
        
        bdOwner.BD_Owner_ID__c = [select id from User where Email = 'puser000@amamama.com'].Id;
        insert bdOwner;
        
        List<Partner_Type_Validation__c> ptyList = new List<Partner_Type_Validation__c>();
        
        AddPartnerOnQuote_Setting__c partnerSetting = new AddPartnerOnQuote_Setting__c();
        partnerSetting.Enable_Admin__c = true;
        partnerSetting.Enable_Opportunity_Owner__c = true;
        partnerSetting.Enable_Opportunity_Team_Member__c = true;
        partnerSetting.Name = 'Default Setting';
        insert partnerSetting;
        
        Partner_Type_Validation__c ptv1 = new Partner_Type_Validation__c();
        ptv1.Allow_Secondary_Partner__c = true;
        ptv1.Primary_Partner_Role__c = 'Collaborate';
        ptv1.Secondary_Partner_Role__c = 'DMR';
        ptv1.Name = 'Collaborate';
        ptyList.add(ptv1);
        
        Partner_Type_Validation__c ptv2 = new Partner_Type_Validation__c();
        ptv2.Allow_Secondary_Partner__c = false;
        ptv2.Primary_Partner_Role__c = 'DMR';
        ptv2.Name = 'DMR';
        ptyList.add(ptv2);
        
        Partner_Type_Validation__c ptv3 = new Partner_Type_Validation__c();
        ptv3.Allow_Secondary_Partner__c = true;
        ptv3.Primary_Partner_Role__c = 'Software Distributor';
        ptv3.Secondary_Partner_Role__c = 'Value Added Reseller';
        ptv3.Name = 'Software Distributor';
        ptyList.add(ptv3);
        
        Partner_Type_Validation__c ptv4 = new Partner_Type_Validation__c();
        ptv4.Allow_Secondary_Partner__c = false;
        ptv4.Primary_Partner_Role__c = 'Value Added Reseller';
        ptv4.Name = 'Value Added Reseller';
        ptyList.add(ptv4);
        
        insert ptyList;
    }
    
    /**
     * Tests add new Primary Partner is added on Opportunity When Partner role Type is VAR.
     */
    @isTest
    public static void addVARWithAdditionalPartner() {
        List<Account> accList = new List<Account>();
        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'Channel';
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'DMR';
        acc1.Managed_Partner__c = true;
        acc1.BillingState = 'AK';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        acc2.Managed_Partner__c = true;
        acc2.BillingState = 'AK';
        accList.add(acc2);
        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Referral_Discount__c = '15%';
        acc3.Partner_Type__c = 'Technology';
        acc3.Managed_Partner__c = true;
        acc3.BillingState = 'AK';
        accList.add(acc3);
        
        insert accList;

        Contact cont = OrgWideTestUtil.createContact(false, accList[1].Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, accList[1].Id);
        opp1.Primary_Contact__c = cont.Id;
        insert opp1;

        List<Custom_Partner__c> cpOldList = [SELECT Id FROM Custom_Partner__c];
        List<Opportunity> oppOldList = [SELECT Partner_Account_Lookup__c, Partner_Role__c, Referral_Discount__c FROM Opportunity];

        System.assertEquals(0,cpOldList.Size());
        System.assertEquals(null,oppOldList[0].Partner_Account_Lookup__c);
        System.assertEquals(null,oppOldList[0].Partner_Role__c);

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', opp1.Id);
        AddPartnerController controller = new AddPartnerController();
        
        controller.con1.Partner_Account__c = accList[0].Id;
        controller.primaryPartnerRole = 'Value Added Reseller';
        controller.primaryPartnerRole();
        controller.con3.Partner_Account__c = accList[3].Id;
        controller.influencerPartnerRole = 'Deal Influencer';
        controller.influencerPartnerRole();
        controller.saveThisOpp();

        Test.stopTest();

        List<Custom_Partner__c> cpNewList = [SELECT Id FROM Custom_Partner__c];
        List<Opportunity> oppNewList = [SELECT Partner_Account_Lookup__c, Partner_Role__c, Referral_Discount__c FROM Opportunity];

        System.assertEquals(2,cpNewList.Size());
        System.assertEquals(accList[0].Id,oppNewList[0].Partner_Account_Lookup__c);
        System.assertEquals('Value Added Reseller',oppNewList[0].Partner_Role__c);
    }

    /**
     * Tests add new Primary Partner is added on Opportunity When Partner role type is Distributor.
     */
    @isTest
    public static void addNewDistributorPartner() {
        List<Account> accList = new List<Account>();
        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'Channel';
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'DMR';
        acc1.Managed_Partner__c = true;
        acc1.BillingState = 'AK';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        acc2.Managed_Partner__c = true;
        acc2.BillingState = 'AK';
        accList.add(acc2);
        
        insert accList;

        Contact cont = OrgWideTestUtil.createContact(false, accList[1].Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, accList[1].Id);
        opp1.Primary_Contact__c = cont.Id;
        insert opp1;

        List<Custom_Partner__c> cpOldList = [SELECT Id FROM Custom_Partner__c];
        List<Opportunity> oppOldList = [SELECT Partner_Account_Lookup__c, Partner_Role__c, Referral_Discount__c FROM Opportunity];

        System.assertEquals(0,cpOldList.Size());
        System.assertEquals(null,oppOldList[0].Partner_Account_Lookup__c);
        System.assertEquals(null,oppOldList[0].Partner_Role__c);

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', opp1.Id);
        AddPartnerController controller = new AddPartnerController();
        
        controller.con1.Partner_Account__c = accList[2].Id;
        controller.primaryPartnerRole = 'Software Distributor';
        controller.primaryPartnerRole();
        controller.checkPartner();
        controller.con2.Partner_Account__c = null;
        controller.saveThisOpp();

        Test.stopTest();

        List<Custom_Partner__c> cpNewList = [SELECT Id FROM Custom_Partner__c];
        List<Opportunity> oppNewList = [SELECT Partner_Account_Lookup__c, Partner_Role__c, Referral_Discount__c FROM Opportunity];

        System.assertEquals(1,cpNewList.Size());
        System.assertEquals(accList[2].Id, oppNewList[0].Partner_Account_Lookup__c);
        System.assertEquals('Software Distributor', oppNewList[0].Partner_Role__c);
    }

    /**
     * Tests add new Primary and Secondary Partner is added on Opportunity 
     * When Primary Partner role type is Distributor.
     */
    /*@isTest
    public static void addNewDistributorVARPartner() {
        List<Account> accList = new List<Account>();
        
        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'Channel';
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'DMR';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        accList.add(acc2);
        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Referral_Discount__c = '20%';
        acc3.Partner_Type__c = 'Master Reseller';
        accList.add(acc3);
        
        insert accList;

        Contact cont = OrgWideTestUtil.createContact(false, accList[1].Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, accList[1].Id);
        opp1.Primary_Contact__c = cont.Id;
        insert opp1;

        List<Custom_Partner__c> cpOldList = [SELECT Id FROM Custom_Partner__c];
        List<Opportunity> oppOldList = [SELECT Partner_Account_Lookup__c, Partner_Role__c, Referral_Discount__c FROM Opportunity];

        System.assertEquals(0,cpOldList.Size());
        System.assertEquals(null,oppOldList[0].Partner_Account_Lookup__c);
        System.assertEquals(null,oppOldList[0].Partner_Role__c);

        Test.startTest();

        ApexPages.PageReference myVfPage = Page.AddPartnerOnOpp;
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(opp1);
        AddPartnerOnOppController controller = new AddPartnerOnOppController(sc);
        
        controller.con1.Partner_Account__c = accList[2].Id;
        controller.primaryPartnerRole();
        controller.primaryPartnerRole = 'Software Distributor';
        controller.checkPartner();
        controller.con2.Partner_Account__c = accList[3].Id;
        controller.secondaryPartnerRole();
        controller.secondaryPartnerRole = 'Value Added Reseller';
        controller.saveThisOpp();

        Test.stopTest();

        List<Custom_Partner__c> cpNewList = [SELECT Id FROM Custom_Partner__c];
        List<Opportunity> oppNewList = [SELECT Partner_Account_Lookup__c, Partner_Role__c, Referral_Discount__c FROM Opportunity];
        System.debug('custom partner 1' + cpNewList);
        System.assertEquals(2, cpNewList.Size());
        System.assertEquals(accList[2].Id, oppNewList[0].Partner_Account_Lookup__c);
        System.assertEquals('Software Distributor', oppNewList[0].Partner_Role__c);
    }*/

    /**
     * Tests add new Primary, Secondary Partner and Additional Partner on Opportunity 
     * When Primary Partner role type is Distributor.
     */
    @isTest
    public static void addAllPartner() {
        List<Account> accList = new List<Account>();

        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'Channel';
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'DMR';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        accList.add(acc2);
        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Referral_Discount__c = '15%';
        acc3.Partner_Type__c = 'Technology';
        accList.add(acc3);
        
        insert accList;

        Contact cont = OrgWideTestUtil.createContact(false, accList[1].Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, accList[1].Id);
        opp1.Primary_Contact__c = cont.Id;
        insert opp1;

        List<Custom_Partner__c> cpOldList = [SELECT Id FROM Custom_Partner__c];
        List<Opportunity> oppOldList = [SELECT Partner_Account_Lookup__c, Partner_Role__c, Referral_Discount__c FROM Opportunity];

        System.assertEquals(0,cpOldList.Size());
        System.assertEquals(null,oppOldList[0].Partner_Account_Lookup__c);
        System.assertEquals(null,oppOldList[0].Partner_Role__c);

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', opp1.Id);
        AddPartnerController controller = new AddPartnerController();
        
        controller.con1.Partner_Account__c = accList[2].Id;
        controller.primaryPartnerRole();
        controller.primaryPartnerRole = 'Software Distributor';
        controller.checkPartner();
        controller.con2.Partner_Account__c = accList[0].Id;
        controller.secondaryPartnerRole();
        controller.secondaryPartnerRole = 'Value added Reseller';
        controller.con3.Partner_Account__c = accList[3].Id;
        controller.influencerPartnerRole = 'Deal Influencer';
        controller.influencerPartnerRole();
        controller.saveThisOpp(); 

        Test.stopTest();

        List<Custom_Partner__c> cpNewList = [SELECT Id FROM Custom_Partner__c];
        List<Opportunity> oppNewList = [SELECT Partner_Account_Lookup__c, Partner_Role__c, Referral_Discount__c FROM Opportunity];

//        System.assertEquals(3, cpNewList.Size());
          System.assertEquals(3, cpNewList.Size());
        //System.assertEquals(accList[2].Id, oppNewList[0].Partner_Account_Lookup__c);
        //System.assertEquals('Software Distributor',oppNewList[0].Partner_Role__c);

    }

    /**
     * Tests updation of Primary Partner with Primary Partner role type is VAR on Opportunity having Partners.
     */
    @isTest
    public static void updatePrimaryToVARType() {
        List<Account> accList = new List<Account>();
        List<Custom_Partner__c> cpList = new List<Custom_Partner__c>();

        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'Master Reseller';
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'DMR';
        acc1.Managed_Partner__c = true;
        acc1.BillingState = 'AK';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        acc2.Managed_Partner__c = true;
        acc2.BillingState = 'AK';
        accList.add(acc2);
        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Referral_Discount__c = '15%';
        acc3.Partner_Type__c = 'Technology';
        acc3.Managed_Partner__c = true;
        acc3.BillingState = 'AK';
        accList.add(acc3);
        
        insert accList;

        Contact cont = OrgWideTestUtil.createContact(false, accList[1].Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, accList[1].Id);
        opp1.Primary_Contact__c = cont.Id;
        insert opp1;

        Custom_Partner__c cp = OrgWideTestUtil.createCustomPartner(false, opp1.Id, accList[2].Id);
        cp.IsPrimary__c = true;
        cp.Role__c = 'Software Distributor';
        cpList.add(cp);
        Custom_Partner__c cp1 = OrgWideTestUtil.createCustomPartner(false, opp1.Id, accList[0].Id);
        cp1.Role__c = 'Value Added Reseller';
        cpList.add(cp1);
        Custom_Partner__c cp3 = OrgWideTestUtil.createCustomPartner(false, opp1.Id, accList[3].Id);
        cp3.Role__c = 'Deal Influencer';
        cpList.add(cp3);

        insert cpList;

        List<Custom_Partner__c> cpOldList = [SELECT Id FROM Custom_Partner__c];
        List<Opportunity> oppOldList = [SELECT Partner_Account_Lookup__c, Partner_Role__c, Referral_Discount__c FROM Opportunity];

        System.assertEquals(3,cpOldList.Size());

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', opp1.Id);
        AddPartnerController controller = new AddPartnerController();
        
        controller.con1.Partner_Account__c = accList[0].Id;
        controller.primaryPartnerRole();
        controller.primaryPartnerRole = 'Referrer';
        controller.primaryReferralFee();
        controller.checkPartner();
        controller.con2.Partner_Account__c = null;
        controller.secondaryPartnerRole = null;
        controller.secondaryPartnerRole();
        controller.saveThisOpp();

        Test.stopTest();

        List<Custom_Partner__c> cpNewList = [SELECT Id FROM Custom_Partner__c];
        List<Opportunity> oppNewList = [SELECT Partner_Account_Lookup__c, Partner_Role__c, Referral_Discount__c FROM Opportunity];

        System.assertEquals(2, cpNewList.Size());
        System.assertEquals(accList[0].Id, oppNewList[0].Partner_Account_Lookup__c);
        System.assertEquals('Referrer',oppNewList[0].Partner_Role__c);
    }

    /**
     * Tests updation of Secondary Partner on Opportunity having Partners.
    */ 
    @isTest
    public static void updateSecondaryPartners() {
        List<Account> accList = new List<Account>();
        List<Custom_Partner__c> cpList = new List<Custom_Partner__c>();

        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'Channel';
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'DMR';
        acc1.Managed_Partner__c = true;
        acc1.BillingState = 'AK';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        acc2.Managed_Partner__c = true;
        acc2.BillingState = 'AK';
        accList.add(acc2);
        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Referral_Discount__c = '15%';
        acc3.Partner_Type__c = 'Technology';
        acc3.Managed_Partner__c = true;
        acc3.BillingState = 'AK';
        accList.add(acc3);
        Account acc4 = OrgWideTestUtil.createPartnerAccount(false);
        acc4.Referral_Discount__c = '10%';
        acc4.Partner_Type__c = 'Channel';
        acc4.Managed_Partner__c = true;
        acc4.BillingState = 'AK';
        accList.add(acc4);
        
        insert accList;

        Contact cont = OrgWideTestUtil.createContact(false, accList[1].Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, accList[1].Id);
        opp1.Primary_Contact__c = cont.Id;
        insert opp1;

        Custom_Partner__c cp = OrgWideTestUtil.createCustomPartner(false, opp1.Id, accList[2].Id);
        cp.IsPrimary__c = true;
        cp.Role__c = 'Software Distributor';
        cpList.add(cp);
        Custom_Partner__c cp3 = OrgWideTestUtil.createCustomPartner(false, opp1.Id, accList[3].Id);
        cp3.Role__c = 'Deal Influencer';
        cpList.add(cp3);

        insert cpList;

        List<Custom_Partner__c> cpOldList = [SELECT Id FROM Custom_Partner__c];

        System.assertEquals(2,cpOldList.Size());

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', opp1.Id);
        AddPartnerController controller = new AddPartnerController();
        
        controller.con1.Partner_Account__c = accList[2].Id;
        controller.primaryPartnerRole();
        controller.primaryPartnerRole = 'Software Distributor';
        controller.checkPartner();
        controller.con2.Partner_Account__c = accList[4].Id;
        controller.secondaryPartnerRole = 'Value Added Reseller';
        controller.secondaryReferralFee();
        controller.saveThisOpp();

        Test.stopTest();

        List<Custom_Partner__c> cpNewList = [SELECT Id FROM Custom_Partner__c];

        System.assertEquals(3, cpNewList.Size());

    }
    /**
     * Tests removal of Primary, Secondary and Additional Partner. 
     */
    @isTest
    public static void removeAllPartners() {
        List<Account> accList = new List<Account>();
        List<Custom_Partner__c> cpList = new List<Custom_Partner__c>();

        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'Channel';
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'DMR';
        acc1.Managed_Partner__c = true;
        acc1.BillingState = 'AK';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        acc2.Managed_Partner__c = true;
        acc2.BillingState = 'AK';
        accList.add(acc2);
        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Referral_Discount__c = '15%';
        acc3.Partner_Type__c = 'Technology';
        acc3.Managed_Partner__c = true;
        acc3.BillingState = 'AK';
        accList.add(acc3);
        
        insert accList;

        Contact cont = OrgWideTestUtil.createContact(false, accList[1].Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, accList[1].Id);
        opp1.Primary_Contact__c = cont.Id;
        insert opp1;

        Custom_Partner__c cp = OrgWideTestUtil.createCustomPartner(false, opp1.Id, accList[2].Id);
        cp.IsPrimary__c = true;
        cp.Role__c = 'Software Distributor';
        cpList.add(cp);
        Custom_Partner__c cp1 = OrgWideTestUtil.createCustomPartner(false, opp1.Id, accList[0].Id);
        cp1.Role__c = 'Value Added Reseller';
        cpList.add(cp1);
        Custom_Partner__c cp3 = OrgWideTestUtil.createCustomPartner(false, opp1.Id, accList[3].Id);
        cp3.Role__c = 'Deal Influencer';
        cpList.add(cp3);

        insert cpList;

        List<Custom_Partner__c> cpOldList = [SELECT Id FROM Custom_Partner__c];

        System.assertEquals(3,cpOldList.Size());

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', opp1.Id);
        AddPartnerController controller = new AddPartnerController();
        
        controller.con1.Partner_Account__c = null;
        controller.primaryPartnerRole = null;
        controller.primaryPartnerRole();
        controller.checkPartner();
        controller.con2.Partner_Account__c = null;
        controller.secondaryPartnerRole = null;
        controller.secondaryPartnerRole();
        controller.con3.Partner_Account__c = null;
        controller.influencerPartnerRole = null;
        controller.influencerPartnerRole();
        controller.saveThisOpp();

        Test.stopTest();
        List<Custom_Partner__c> cpNewList = [SELECT Id FROM Custom_Partner__c];
        
        System.assertEquals(0,cpNewList.Size());

    }

    /**
     * Tests Updation of Primary Referrer Partner on Opportunity. 
     */
    @isTest
    public static void updateReferrerPartner() {
        List<Account> accList = new List<Account>();
        List<Custom_Partner__c> cpList = new List<Custom_Partner__c>();

        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'Channel';
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'DMR';
        acc1.Managed_Partner__c = true;
        acc1.BillingState = 'AK';
        
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        accList.add(acc2);
        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Referral_Discount__c = '15%';
        acc3.Partner_Type__c = 'Technology';
        accList.add(acc3);
        
        insert accList;

        Contact cont = OrgWideTestUtil.createContact(false, accList[1].Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, accList[1].Id);
        opp1.Primary_Contact__c = cont.Id;
        insert opp1;

        Custom_Partner__c cp = OrgWideTestUtil.createCustomPartner(false, opp1.Id, accList[0].Id);
        cp.IsPrimary__c = true;
        cp.Role__c = 'Referrer';
        cpList.add(cp);
        
        insert cpList;

        List<Custom_Partner__c> cpOldList = [SELECT Id FROM Custom_Partner__c];
        
        System.assertEquals(1,cpOldList.Size());

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', opp1.Id);
        AddPartnerController controller = new AddPartnerController();
        
        controller.con1.Partner_Account__c = accList[2].Id;
        controller.primaryPartnerRole = 'Sofware Distributor';
        controller.primaryPartnerRole();

        Test.stopTest();

        List<Custom_Partner__c> cpNewList = [SELECT Id FROM Custom_Partner__c];
        
        System.assertEquals(1, cpNewList.Size());
    }
    /**
     * Tests Cancel functionality.
     */
    @isTest
    public static void cancelTest() {
        List<Account> accList = new List<Account>();
        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'Channel';
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'DMR';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        accList.add(acc2);
        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Referral_Discount__c = '15%';
        acc3.Partner_Type__c = 'Technology';
        accList.add(acc3);
        
        insert accList;

        Contact cont = OrgWideTestUtil.createContact(false, accList[1].Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, accList[1].Id);
        opp1.Primary_Contact__c = cont.Id;
        insert opp1;

        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', opp1.Id);
        AddPartnerController controller = new AddPartnerController();
        
        controller.Cancel();

        Test.stopTest();
    }
    /**
     * Tests add new Primary, Secondary Partner and Additional Partner on Quote
     * When Primary Partner role type is Distributor.
     */
    @isTest
    public static void addAllPartnerOnQuote() {
        List<Account> accList = new List<Account>();
        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'Channel';
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'DMR';
        acc1.Managed_Partner__c = true;
        acc1.BillingState = 'AK';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        acc2.Managed_Partner__c = true;
        acc2.BillingState = 'AK';
        accList.add(acc2);
        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Referral_Discount__c = '15%';
        acc3.Partner_Type__c = 'Technology';
        acc3.Managed_Partner__c = true;
        acc3.BillingState = 'AK';
        accList.add(acc3);
        
        insert accList;
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(true, accList[2].Id);
        SBQQ__Quote__c quotes = OrgWideTestUtil.createProposal(true, opp.Id, accList[2].Id); 
        
        List<SBQQ__Quote__c> qt = [SELECT SBQQ__Partner__c, SBQQ__Distributor__c, Partner_Role__c, Distributor_Role__c, Influencer_Account__c, Influencer_Role__c,SBQQ__Opportunity2__r.Referral_Discount__c FROM SBQQ__Quote__c];
               
        System.assertEquals(null, qt[0].SBQQ__Partner__c);
        System.assertEquals(null, qt[0].Partner_Role__c);
        System.assertEquals(null, qt[0].SBQQ__Distributor__c);
        System.assertEquals(null, qt[0].Distributor_Role__c);
        System.assertEquals(null, qt[0].Influencer_Account__c);
        System.assertEquals(null, qt[0].Influencer_Role__c);
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', quotes.Id);
        AddPartnerController controller = new AddPartnerController();
        controller.con1.Partner_Account__c = accList[1].Id;
        controller.primaryPartnerRole = 'Software Distributor';
        controller.primaryReferralFee();
        controller.con2.Partner_Account__c = accList[0].Id;
        controller.secondaryPartnerRole = 'Value Added Reseller';
        controller.secondaryReferralFee();
        controller.con3.Partner_Account__c = accList[3].Id;
        controller.influencerPartnerRole = 'Deal Influencer';
        controller.influencerPartnerRole();
        controller.saveThisOpp();

        Test.stopTest();
        
        List<SBQQ__Quote__c> qt1 = [SELECT SBQQ__Partner__c, SBQQ__Distributor__c, Partner_Role__c, Distributor_Role__c, Influencer_Account__c, Influencer_Role__c,SBQQ__Opportunity2__r.Referral_Discount__c FROM SBQQ__Quote__c];
        
        System.assertEquals(accList[1].Id, qt1[0].SBQQ__Partner__c);
        System.assertEquals('Software Distributor', qt1[0].Partner_Role__c);
        System.assertEquals(accList[0].Id, qt1[0].SBQQ__Distributor__c);
        System.assertEquals('Value Added Reseller', qt1[0].Distributor_Role__c);
        System.assertEquals(accList[3].Id, qt1[0].Influencer_Account__c);
        System.assertEquals('Deal Influencer', qt1[0].Influencer_Role__c);

    }
    /**
     * Tests when referrer partner is added as primary partner in Quote.
     */
    /*Referrer test scenario no longer needed, waiting for new Collaborate Sale
    @isTest
    public static void addReferrerPartner(){
        List<Account> accList = new List<Account>();
        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'DMR';
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'Channel';
        acc1.Managed_Partner__c = true;
        acc1.BillingState = 'AK';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        acc2.Managed_Partner__c = true;
        acc2.BillingState = 'AK';
        accList.add(acc2);
        
        insert accList;
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(true, accList[2].Id);
        SBQQ__Quote__c quotes = OrgWideTestUtil.createProposal(false, opp.Id, accList[2].Id); 
        quotes.SBQQ__Primary__c = true;
        insert quotes;
        
        List<SBQQ__Quote__c> qt = [SELECT SBQQ__Partner__c, SBQQ__Distributor__c, Partner_Role__c, Distributor_Role__c, SBQQ__Opportunity2__r.Referral_Discount__c FROM SBQQ__Quote__c];
               
        System.assertEquals(null, qt[0].SBQQ__Partner__c);
        System.assertEquals(null, qt[0].Partner_Role__c);
        System.assertEquals(null, qt[0].SBQQ__Opportunity2__r.Referral_Discount__c);

        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', quotes.Id);
        AddPartnerController controller = new AddPartnerController();
        controller.con1.Partner_Account__c = accList[1].Id;
        controller.primaryPartnerRole = 'Referrer';
        controller.primaryReferralFee();
        controller.saveThisOpp();

        Test.stopTest();
        
        List<SBQQ__Quote__c> qt1 = [SELECT SBQQ__Partner__c, SBQQ__Distributor__c, Partner_Role__c, Distributor_Role__c, SBQQ__Opportunity2__r.Referral_Discount__c FROM SBQQ__Quote__c];
        System.assertEquals(accList[1].Id, qt1[0].SBQQ__Partner__c);
        System.assertEquals('Referrer', qt1[0].Partner_Role__c);
        System.assertEquals(10, qt1[0].SBQQ__Opportunity2__r.Referral_Discount__c);
    }*/

    /**
     * Tests when referrer partner is removeed as Distributor in Quote.
     */
    @isTest
    public static void addPrimarySecondaryReferrer(){
        List<Account> accList = new List<Account>();

        Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partner Opportunity').getRecordTypeId();
        Id altxRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Alteryx Record Type').getRecordTypeId();
        
        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Partner_Type__c = 'Channel';
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Partner_Type__c = 'Channel';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Partner_Type__c = 'DMR';
        accList.add(acc2);
        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Referral_Discount__c = '15%';
        acc3.Partner_Type__c = 'Technology';
        accList.add(acc3);
        
        insert accList;
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(true, accList[2].Id);
        
        SBQQ__Quote__c quotes = OrgWideTestUtil.createProposal(false, opp.Id, accList[2].Id);
        quotes.SBQQ__Primary__c = true;
        quotes.SBQQ__Partner__c = accList[0].Id;
        quotes.Partner_Role__c = 'Referrer';
        quotes.SBQQ__Distributor__c = accList[1].Id;
        quotes.Distributor_Role__c = 'Referrer';
        insert quotes;
        
        List<SBQQ__Quote__c> qt = [SELECT SBQQ__Partner__c, SBQQ__Distributor__c, Partner_Role__c, Distributor_Role__c, Influencer_Account__c, Influencer_Role__c, SBQQ__Opportunity2__r.RecordTypeId FROM SBQQ__Quote__c];

        System.assertEquals(accList[0].Id, qt[0].SBQQ__Partner__c);
        System.assertEquals('Referrer', qt[0].Partner_Role__c);
        System.assertEquals(accList[1].Id, qt[0].SBQQ__Distributor__c);
        System.assertEquals('Referrer', qt[0].Distributor_Role__c);
        
        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', quotes.Id);
        AddPartnerController controller = new AddPartnerController();
        controller.con1.Partner_Account__c = null;
        controller.primaryPartnerRole = null;
        controller.con2.Partner_Account__c = null;
        controller.secondaryPartnerRole = null;
        controller.con3.Partner_Account__c = null;
        controller.influencerPartnerRole = null;
        controller.saveThisOpp();
        controller.cancel();
        
        
        Test.stopTest();
        
        List<SBQQ__Quote__c> qt1 = [SELECT SBQQ__Partner__c, SBQQ__Distributor__c, Partner_Role__c, Distributor_Role__c, Influencer_Account__c, Influencer_Role__c, SBQQ__Opportunity2__r.RecordTypeId  FROM SBQQ__Quote__c];

        System.assertEquals(null, qt1[0].SBQQ__Partner__c);
        System.assertEquals(null, qt1[0].Partner_Role__c);
        System.assertEquals(null, qt1[0].SBQQ__Distributor__c);
        System.assertEquals(null, qt1[0].Distributor_Role__c);
        System.assertEquals(null, qt[0].Influencer_Account__c);
        System.assertEquals(null, qt[0].Influencer_Role__c);
    }
    /**
     * Tests when new VAR Primary is added in Quote.
     */
    
    @isTest
    public static void addVarPartnerOnQuote(){
        List<Account> accList = new List<Account>();
        Account acc = OrgWideTestUtil.createPartnerAccount(false);
        acc.Referral_Discount__c = '20%';
        acc.Partner_Type__c = 'DMR';
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        accList.add(acc);
        Account acc1 = OrgWideTestUtil.createPartnerAccount(false);
        acc1.Referral_Discount__c = '10%';
        acc1.Partner_Type__c = 'Channel';
        acc1.Managed_Partner__c = true;
        acc1.BillingState = 'AK';
        accList.add(acc1);
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Referral_Discount__c = '15%';
        acc2.Partner_Type__c = 'DMR';
        acc2.Managed_Partner__c = true;
        acc2.BillingState = 'AK';
        accList.add(acc2);
        
        insert accList;
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(true, accList[2].Id);
        SBQQ__Quote__c quotes = OrgWideTestUtil.createProposal(false, opp.Id, accList[2].Id); 
        quotes.SBQQ__Primary__c = true;
        insert quotes;
        
        List<SBQQ__Quote__c> qt = [SELECT SBQQ__Partner__c, SBQQ__Distributor__c, Partner_Role__c, Distributor_Role__c, SBQQ__Opportunity2__r.Referral_Discount__c FROM SBQQ__Quote__c];
               
        System.assertEquals(null, qt[0].SBQQ__Partner__c);
        System.assertEquals(null, qt[0].Partner_Role__c);
        System.assertEquals(null, qt[0].SBQQ__Opportunity2__r.Referral_Discount__c);

        Test.startTest();
        
        ApexPages.currentPage().getParameters().put('id', quotes.Id);
        AddPartnerController controller = new AddPartnerController();
        controller.con1.Partner_Account__c = accList[1].Id;
        controller.primaryPartnerRole = 'Value Added Reseller';
        controller.primaryReferralFee();
        controller.saveThisOpp();

        Test.stopTest();
        
        List<SBQQ__Quote__c> qt1 = [SELECT SBQQ__Partner__c, SBQQ__Distributor__c, Partner_Role__c, Distributor_Role__c, SBQQ__Opportunity2__r.Referral_Discount__c FROM SBQQ__Quote__c];
        System.assertEquals(accList[1].Id, qt1[0].SBQQ__Partner__c);
        System.assertEquals('Value Added Reseller', qt1[0].Partner_Role__c);
        System.assertEquals(null, qt1[0].SBQQ__Opportunity2__r.Referral_Discount__c);
    }
}