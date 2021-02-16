@isTest
public class UpdateCampaignMemberTypeFieldTest {
    @isTest
    private static void testScenario1() {
        Campaign c = new Campaign();
        c.Name = 'UCMTFT_Amazon';
        c.IsActive = true;
        c.Status = 'Planned';
        c.Program_Name__c = 'UCMTFT_Amazon';
        c.Region__c = 'Global';
        c.Fiscal_Year__c = '2014';
        c.Quarter__c = 'Q1';
        c.Campaign_Tactic__c = '3rd Party Email';
        c.Campaign_Offer__c = 'Analyst Report';
        c.Vendor_Sponsored__c = 'Yes';
        c.StartDate = Date.today();
        c.EndDate = Date.today() + 2;
        insert c;
        
        Lead l = new Lead();
        l.LastName = 'UCMTFT_Lead';
        l.Company = 'UCMTFT_Company';
        l.Campaign_Member_Type__c = 'Tableau';
        // l.Campaign_Referred_Partner_ID__c = '001001001001001';
        insert l;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c.Id;
        cm.LeadId = l.Id;
        cm.Status = 'Responded';
        insert cm;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        l = [SELECT Id, Campaign_Member_Type__c FROM Lead WHERE Id = :l.Id];
        System.assert(l.Campaign_Member_Type__c == 'Amazon');
    }
    
    @isTest
    private static void testScenario2() {
        Campaign c1 = new Campaign();
        c1.Name = 'UCMTFT_Amazon';
        c1.IsActive = true;
        c1.Status = 'Planned';
        c1.Program_Name__c = 'UCMTFT_Amazon';
        c1.Region__c = 'Global';
        c1.Fiscal_Year__c = '2014';
        c1.Quarter__c = 'Q1';
        c1.Campaign_Tactic__c = '3rd Party Email';
        c1.Campaign_Offer__c = 'Analyst Report';
        c1.Vendor_Sponsored__c = 'Yes';
        c1.StartDate = Date.today();
        c1.EndDate = Date.today() + 2;
        
        Campaign c2 = new Campaign();
        c2.Name = 'UCMTFT_Excel';
        c2.IsActive = true;
        c2.Status = 'Planned';
        c2.Program_Name__c = 'UCMTFT_Excel';
        c2.Region__c = 'Global';
        c2.Fiscal_Year__c = '2014';
        c2.Quarter__c = 'Q1';
        c2.Campaign_Tactic__c = '3rd Party Email';
        c2.Campaign_Offer__c = 'Analyst Report';
        c2.Vendor_Sponsored__c = 'Yes';
        c2.StartDate = Date.today();
        c2.EndDate = Date.today() + 2;
        
        List<Campaign> cs = new List<Campaign>();
        cs.add(c1);
        cs.add(c2);
        insert cs;
        
        Lead l = new Lead();
        l.LastName = 'UCMTFT_Lead';
        l.Company = 'UCMTFT_Company';
        l.Campaign_Member_Type__c = 'Tableau';
        insert l;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = c1.Id;
        cm1.LeadId = l.Id;
        cm1.Status = 'Responded';
        
        CampaignMember cm2 = new CampaignMember();
        cm2.CampaignId = c2.Id;
        cm2.LeadId = l.Id;
        cm2.Status = 'Responded';
        
        List<CampaignMember> cms = new List<CampaignMember>();
        cms.add(cm1);
        cms.add(cm2);
        insert cms;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        l = [SELECT Id, Campaign_Member_Type__c FROM Lead WHERE Id = :l.Id];
        System.assert(l.Campaign_Member_Type__c == 'Amazon;Excel' || l.Campaign_Member_Type__c == 'Excel;Amazon');
    }
    
    @isTest
    private static void testScenario3() {
        Campaign c1 = new Campaign();
        c1.Name = 'UCMTFT_Amazon';
        c1.IsActive = true;
        c1.Status = 'Planned';
        c1.Program_Name__c = 'UCMTFT_Amazon';
        c1.Region__c = 'Global';
        c1.Fiscal_Year__c = '2014';
        c1.Quarter__c = 'Q1';
        c1.Campaign_Tactic__c = '3rd Party Email';
        c1.Campaign_Offer__c = 'Analyst Report';
        c1.Vendor_Sponsored__c = 'Yes';
        c1.StartDate = Date.today();
        c1.EndDate = Date.today() + 2;
        
        Campaign c2 = new Campaign();
        c2.Name = 'UCMTFT_Amazon';
        c2.IsActive = true;
        c2.Status = 'Planned';
        c2.Program_Name__c = 'UCMTFT_Amazon';
        c2.Region__c = 'Global';
        c2.Fiscal_Year__c = '2014';
        c2.Quarter__c = 'Q1';
        c2.Campaign_Tactic__c = '3rd Party Email';
        c2.Campaign_Offer__c = 'Analyst Report';
        c2.Vendor_Sponsored__c = 'Yes';
        c2.StartDate = Date.today();
        c2.EndDate = Date.today() + 2;
        
        List<Campaign> cs = new List<Campaign>();
        cs.add(c1);
        cs.add(c2);
        insert cs;
        
        Lead l = new Lead();
        l.LastName = 'UCMTFT_Lead';
        l.Company = 'UCMTFT_Company';
        l.Campaign_Member_Type__c = 'Tableau';
        insert l;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = c1.Id;
        cm1.LeadId = l.Id;
        cm1.Status = 'Responded';
        
        CampaignMember cm2 = new CampaignMember();
        cm2.CampaignId = c2.Id;
        cm2.LeadId = l.Id;
        cm2.Status = 'Responded';
        
        List<CampaignMember> cms = new List<CampaignMember>();
        cms.add(cm1);
        cms.add(cm2);
        insert cms;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        l = [SELECT Id, Campaign_Member_Type__c FROM Lead WHERE Id = :l.Id];
        System.assert(l.Campaign_Member_Type__c == 'Amazon');
    }
    
    @isTest
    private static void testScenario4() {
        Campaign c1 = new Campaign();
        c1.Name = 'UCMTFT_Amazon';
        c1.IsActive = true;
        c1.Status = 'Planned';
        c1.Program_Name__c = 'UCMTFT_Amazon';
        c1.Region__c = 'Global';
        c1.Fiscal_Year__c = '2014';
        c1.Quarter__c = 'Q1';
        c1.Campaign_Tactic__c = '3rd Party Email';
        c1.Campaign_Offer__c = 'Analyst Report';
        c1.Vendor_Sponsored__c = 'Yes';
        c1.StartDate = Date.today();
        c1.EndDate = Date.today() + 2;
        
        Campaign c2 = new Campaign();
        c2.Name = 'UCMTFT_Amazon';
        c2.IsActive = true;
        c2.Status = 'Planned';
        c2.Program_Name__c = 'UCMTFT_Amazon';
        c2.Region__c = 'Global';
        c2.Fiscal_Year__c = '2014';
        c2.Quarter__c = 'Q1';
        c2.Campaign_Tactic__c = '3rd Party Email';
        c2.Campaign_Offer__c = 'Analyst Report';
        c2.Vendor_Sponsored__c = 'Yes';
        c2.StartDate = Date.today();
        c2.EndDate = Date.today() + 2;
        
        List<Campaign> cs = new List<Campaign>();
        cs.add(c1);
        cs.add(c2);
        insert cs;
        
        Lead l = new Lead();
        l.LastName = 'UCMTFT_Lead';
        l.Company = 'UCMTFT_Company';
        insert l;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = c1.Id;
        cm1.LeadId = l.Id;
        cm1.Status = 'Responded';
        
        CampaignMember cm2 = new CampaignMember();
        cm2.CampaignId = c2.Id;
        cm2.LeadId = l.Id;
        cm2.Status = 'Responded';
        
        List<CampaignMember> cms = new List<CampaignMember>();
        cms.add(cm1);
        cms.add(cm2);
        insert cms;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        l = [SELECT Id, Campaign_Member_Type__c FROM Lead WHERE Id = :l.Id];
        System.assert(l.Campaign_Member_Type__c == 'Amazon');
    }
    
    @isTest
    private static void testScenario5() {
        Campaign c1 = new Campaign();
        c1.Name = 'UCMTFT_Amazon';
        c1.IsActive = true;
        c1.Status = 'Planned';
        c1.Program_Name__c = 'UCMTFT_Amazon';
        c1.Region__c = 'Global';
        c1.Fiscal_Year__c = '2014';
        c1.Quarter__c = 'Q1';
        c1.Campaign_Tactic__c = '3rd Party Email';
        c1.Campaign_Offer__c = 'Analyst Report';
        c1.Vendor_Sponsored__c = 'Yes';
        c1.StartDate = Date.today();
        c1.EndDate = Date.today() + 2;
        
        Campaign c2 = new Campaign();
        c2.Name = 'UCMTFT_Amazon';
        c2.IsActive = true;
        c2.Status = 'Planned';
        c2.Program_Name__c = 'UCMTFT_MSFT';
        c2.Region__c = 'Global';
        c2.Fiscal_Year__c = '2014';
        c2.Quarter__c = 'Q1';
        c2.Campaign_Tactic__c = '3rd Party Email';
        c2.Campaign_Offer__c = 'Analyst Report';
        c2.Vendor_Sponsored__c = 'Yes';
        c2.StartDate = Date.today();
        c2.EndDate = Date.today() + 2;
        
        List<Campaign> cs = new List<Campaign>();
        cs.add(c1);
        cs.add(c2);
        insert cs;
        
        Lead l = new Lead();
        l.LastName = 'UCMTFT_Lead';
        l.Company = 'UCMTFT_Company';
        insert l;
        
        Account acc = new Account();
        acc.Name = 'UCMTFT Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'UCMTFT';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        // con.Campaign_Referred_Partner_ID__c = '001001001001001';
        insert con;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = c1.Id;
        cm1.LeadId = l.Id;
        cm1.Status = 'Responded';
        
        CampaignMember cm2 = new CampaignMember();
        cm2.CampaignId = c2.Id;
        cm2.ContactId = con.Id;
        cm2.Status = 'Responded';
        
        List<CampaignMember> cms = new List<CampaignMember>();
        cms.add(cm1);
        cms.add(cm2);
        insert cms;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        l = [SELECT Id, Campaign_Member_Type__c FROM Lead WHERE Id = :l.Id];
        System.assert(l.Campaign_Member_Type__c == 'Amazon');
        con = [SELECT Id, Campaign_Member_Type__c FROM Contact WHERE Id = :con.Id];
        System.assert(con.Campaign_Member_Type__c == 'Microsoft');
    }
    
    @isTest
    private static void testScenario6() {
        Campaign c1 = new Campaign();
        c1.Name = 'UCMTFT_GET WELL GUIDE';
        c1.IsActive = true;
        c1.Status = 'Planned';
        c1.Program_Name__c = 'UCMTFT_GET WELL GUIDE';
        c1.Region__c = 'Global';
        c1.Fiscal_Year__c = '2014';
        c1.Quarter__c = 'Q1';
        c1.Campaign_Tactic__c = '3rd Party Email';
        c1.Campaign_Offer__c = 'Analyst Report';
        c1.Vendor_Sponsored__c = 'Yes';
        c1.StartDate = Date.today();
        c1.EndDate = Date.today() + 2;
        insert c1;
        
        Lead l = new Lead();
        l.LastName = 'UCMTFT_Lead';
        l.Company = 'UCMTFT_Company';
        insert l;
        
        Account acc = new Account();
        acc.Name = 'UCMTFT Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'UCMTFT';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        insert con;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = c1.Id;
        cm1.LeadId = l.Id;
        cm1.Status = 'Responded';
        
        CampaignMember cm2 = new CampaignMember();
        cm2.CampaignId = c1.Id;
        cm2.ContactId = con.Id;
        cm2.Status = 'Responded';
        
        List<CampaignMember> cms = new List<CampaignMember>();
        cms.add(cm1);
        cms.add(cm2);
        insert cms;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        l = [SELECT Id, Campaign_Member_Type__c FROM Lead WHERE Id = :l.Id];
        //System.assert(l.Campaign_Member_Type__c == 'Data Blending');
        con = [SELECT Id, Campaign_Member_Type__c FROM Contact WHERE Id = :con.Id];
        //System.assert(con.Campaign_Member_Type__c == 'Data Blending');
    }
    
    @isTest
    private static void testScenario7() {
        Campaign c1 = new Campaign();
        c1.Name = 'UCMTFT_Amazon';
        c1.IsActive = true;
        c1.Status = 'Planned';
        c1.Program_Name__c = 'UCMTFT_Amazon';
        c1.Region__c = 'Global';
        c1.Fiscal_Year__c = '2014';
        c1.Quarter__c = 'Q1';
        c1.Campaign_Tactic__c = '3rd Party Email';
        c1.Campaign_Offer__c = 'Analyst Report';
        c1.Vendor_Sponsored__c = 'Yes';
        c1.StartDate = Date.today();
        c1.EndDate = Date.today() + 2;
        
        Campaign c2 = new Campaign();
        c2.Name = 'UCMTFT_Excel';
        c2.IsActive = true;
        c2.Status = 'Planned';
        c2.Program_Name__c = 'UCMTFT_Excel';
        c2.Region__c = 'Global';
        c2.Fiscal_Year__c = '2014';
        c2.Quarter__c = 'Q1';
        c2.Campaign_Tactic__c = '3rd Party Email';
        c2.Campaign_Offer__c = 'Analyst Report';
        c2.Vendor_Sponsored__c = 'Yes';
        c2.StartDate = Date.today();
        c2.EndDate = Date.today() + 2;
        
        List<Campaign> cs = new List<Campaign>();
        cs.add(c1);
        cs.add(c2);
        insert cs;
        
        Account acc = new Account();
        acc.Name = 'UCMTFT Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'UCMTFT';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        insert con;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = c1.Id;
        cm1.ContactId = con.Id;
        cm1.Status = 'Responded';
        
        CampaignMember cm2 = new CampaignMember();
        cm2.CampaignId = c2.Id;
        cm2.ContactId = con.Id;
        cm2.Status = 'Responded';
        
        List<CampaignMember> cms = new List<CampaignMember>();
        cms.add(cm1);
        cms.add(cm2);
        insert cms;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        con = [SELECT Id, Campaign_Member_Type__c FROM Contact WHERE Id = :con.Id];
        System.assert(con.Campaign_Member_Type__c == 'Amazon;Excel' || con.Campaign_Member_Type__c == 'Excel;Amazon');
    }
    
    @isTest
    private static void testScenario8() {
        Campaign c = new Campaign();
        c.Name = 'UCMTFT_Amazon';
        c.IsActive = true;
        c.Status = 'Planned';
        c.Program_Name__c = 'UCMTFT_Tableau';
        c.Region__c = 'Global';
        c.Fiscal_Year__c = '2014';
        c.Quarter__c = 'Q1';
        c.Campaign_Tactic__c = '3rd Party Email';
        c.Campaign_Offer__c = 'Analyst Report';
        c.Vendor_Sponsored__c = 'Yes';
        c.StartDate = Date.today();
        c.EndDate = Date.today() + 2;
        insert c;
        
        Lead l = new Lead();
        l.LastName = 'UCMTFT_Lead';
        l.Company = 'UCMTFT_Company';
        l.Campaign_Member_Type__c = 'Tableau';
        insert l;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c.Id;
        cm.LeadId = l.Id;
        cm.Status = 'Responded';
        insert cm;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        l = [SELECT Id, Campaign_Member_Type__c FROM Lead WHERE Id = :l.Id];
        System.assert(l.Campaign_Member_Type__c == 'Tableau');
    }
    
    @isTest
    private static void testScenario9() {
        Campaign c1 = new Campaign();
        c1.Name = 'UCMTFT_Tableau';
        c1.IsActive = true;
        c1.Status = 'Planned';
        c1.Program_Name__c = 'UCMTFT_Tableau';
        c1.Region__c = 'Global';
        c1.Fiscal_Year__c = '2014';
        c1.Quarter__c = 'Q1';
        c1.Campaign_Tactic__c = '3rd Party Email';
        c1.Campaign_Offer__c = 'Analyst Report';
        c1.Vendor_Sponsored__c = 'Yes';
        c1.StartDate = Date.today();
        c1.EndDate = Date.today() + 2;
        
        Campaign c2 = new Campaign();
        c2.Name = 'UCMTFT_Amazon';
        c2.IsActive = true;
        c2.Status = 'Planned';
        c2.Program_Name__c = 'UCMTFT_Amazon';
        c2.Region__c = 'Global';
        c2.Fiscal_Year__c = '2014';
        c2.Quarter__c = 'Q1';
        c2.Campaign_Tactic__c = '3rd Party Email';
        c2.Campaign_Offer__c = 'Analyst Report';
        c2.Vendor_Sponsored__c = 'Yes';
        c2.StartDate = Date.today();
        c2.EndDate = Date.today() + 2;
        
        List<Campaign> cs = new List<Campaign>();
        cs.add(c1);
        cs.add(c2);
        insert cs;
        
        Lead l = new Lead();
        l.LastName = 'UCMTFT_Lead';
        l.Company = 'UCMTFT_Company';
        l.Campaign_Member_Type__c = 'Tableau';
        insert l;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = c1.Id;
        cm1.LeadId = l.Id;
        cm1.Status = 'Responded';
        
        CampaignMember cm2 = new CampaignMember();
        cm2.CampaignId = c2.Id;
        cm2.LeadId = l.Id;
        cm2.Status = 'Responded';
        
        List<CampaignMember> cms = new List<CampaignMember>();
        cms.add(cm1);
        cms.add(cm2);
        insert cms;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        l = [SELECT Id, Campaign_Member_Type__c FROM Lead WHERE Id = :l.Id];
        System.assert(l.Campaign_Member_Type__c == 'Amazon;Tableau' || l.Campaign_Member_Type__c == 'Tableau;Amazon');
    }
    
    @isTest
    private static void testScenario10() {
        Campaign c = new Campaign();
        c.Name = 'UCMTFT_Salesforce';
        c.IsActive = true;
        c.Status = 'Planned';
        c.Program_Name__c = 'UCMTFT_Salesforce';
        c.Region__c = 'Global';
        c.Fiscal_Year__c = '2014';
        c.Quarter__c = 'Q1';
        c.Campaign_Tactic__c = '3rd Party Email';
        c.Campaign_Offer__c = 'Analyst Report';
        c.Vendor_Sponsored__c = 'Yes';
        c.StartDate = Date.today();
        c.EndDate = Date.today() + 2;
        insert c;
        
        Lead l = new Lead();
        l.LastName = 'UCMTFT_Lead';
        l.Company = 'UCMTFT_Company';
        l.Campaign_Member_Type__c = 'Tableau';
        // l.Campaign_Referred_Partner_ID__c = '001001001001001';
        insert l;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c.Id;
        cm.LeadId = l.Id;
        cm.Status = 'Responded';
        insert cm;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        l = [SELECT Id, Campaign_Member_Type__c FROM Lead WHERE Id = :l.Id];
        System.assert(l.Campaign_Member_Type__c == 'Salesforce');
    }
    
    @isTest
    private static void testScenario11() {
        Campaign c = new Campaign();
        c.Name = 'UCMTFT_Salesforce';
        c.IsActive = true;
        c.Status = 'Planned';
        c.Program_Name__c = 'UCMTFT_Salesforce';
        c.Region__c = 'Global';
        c.Fiscal_Year__c = '2014';
        c.Quarter__c = 'Q1';
        c.Campaign_Tactic__c = '3rd Party Email';
        c.Campaign_Offer__c = 'Analyst Report';
        c.Vendor_Sponsored__c = 'Yes';
        c.StartDate = Date.today();
        c.EndDate = Date.today() + 2;
        insert c;
        
        Account acc = new Account();
        acc.Name = 'UCMTFT Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'UCMTFT';
        con.LastName = 'Contact';
        con.Email = 'contact@ucmtft.com';
        con.AccountId = acc.id;
        insert con;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c.Id;
        cm.ContactId = con.Id;
        cm.Status = 'Responded';
        insert cm;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        con = [SELECT Id, Campaign_Member_Type__c FROM Contact WHERE Id = :con.Id];
        System.assert(con.Campaign_Member_Type__c == 'Salesforce');
    }
    
    @isTest
    private static void testScenario12() {
        Campaign c1 = new Campaign();
        c1.Name = 'UCMTFT_Amazon';
        c1.IsActive = true;
        c1.Status = 'Planned';
        c1.Program_Name__c = 'UCMTFT_Salesforce';
        c1.Region__c = 'Global';
        c1.Fiscal_Year__c = '2014';
        c1.Quarter__c = 'Q1';
        c1.Campaign_Tactic__c = '3rd Party Email';
        c1.Campaign_Offer__c = 'Analyst Report';
        c1.Vendor_Sponsored__c = 'Yes';
        c1.StartDate = Date.today();
        c1.EndDate = Date.today() + 2;
        
        Campaign c2 = new Campaign();
        c2.Name = 'UCMTFT_Excel';
        c2.IsActive = true;
        c2.Status = 'Planned';
        c2.Program_Name__c = 'UCMTFT_Excel';
        c2.Region__c = 'Global';
        c2.Fiscal_Year__c = '2014';
        c2.Quarter__c = 'Q1';
        c2.Campaign_Tactic__c = '3rd Party Email';
        c2.Campaign_Offer__c = 'Analyst Report';
        c2.Vendor_Sponsored__c = 'Yes';
        c2.StartDate = Date.today();
        c2.EndDate = Date.today() + 2;
        
        List<Campaign> cs = new List<Campaign>();
        cs.add(c1);
        cs.add(c2);
        insert cs;
        
        Lead l = new Lead();
        l.LastName = 'UCMTFT_Lead';
        l.Company = 'UCMTFT_Company';
        l.Campaign_Member_Type__c = 'Tableau';
        insert l;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = c1.Id;
        cm1.LeadId = l.Id;
        cm1.Status = 'Responded';
        
        CampaignMember cm2 = new CampaignMember();
        cm2.CampaignId = c2.Id;
        cm2.LeadId = l.Id;
        cm2.Status = 'Responded';
        
        List<CampaignMember> cms = new List<CampaignMember>();
        cms.add(cm1);
        cms.add(cm2);
        insert cms;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        l = [SELECT Id, Campaign_Member_Type__c FROM Lead WHERE Id = :l.Id];
        System.assert(l.Campaign_Member_Type__c == 'Salesforce;Excel' || l.Campaign_Member_Type__c == 'Excel;Salesforce');
    }
    
    @isTest
    private static void testScenario13() {
        Campaign c1 = new Campaign();
        c1.Name = 'UCMTFT_Amazon';
        c1.IsActive = true;
        c1.Status = 'Planned';
        c1.Program_Name__c = 'UCMTFT_Salesforce';
        c1.Region__c = 'Global';
        c1.Fiscal_Year__c = '2014';
        c1.Quarter__c = 'Q1';
        c1.Campaign_Tactic__c = '3rd Party Email';
        c1.Campaign_Offer__c = 'Analyst Report';
        c1.Vendor_Sponsored__c = 'Yes';
        c1.StartDate = Date.today();
        c1.EndDate = Date.today() + 2;
        
        Campaign c2 = new Campaign();
        c2.Name = 'UCMTFT_Excel';
        c2.IsActive = true;
        c2.Status = 'Planned';
        c2.Program_Name__c = 'UCMTFT_Excel';
        c2.Region__c = 'Global';
        c2.Fiscal_Year__c = '2014';
        c2.Quarter__c = 'Q1';
        c2.Campaign_Tactic__c = '3rd Party Email';
        c2.Campaign_Offer__c = 'Analyst Report';
        c2.Vendor_Sponsored__c = 'Yes';
        c2.StartDate = Date.today();
        c2.EndDate = Date.today() + 2;
        
        List<Campaign> cs = new List<Campaign>();
        cs.add(c1);
        cs.add(c2);
        insert cs;
        
        Account acc = new Account();
        acc.Name = 'UCMTFT Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'UCMTFT';
        con.LastName = 'Contact';
        con.Email = 'contact@ucmtft.com';
        con.AccountId = acc.id;
        insert con;
        
        CampaignMember cm1 = new CampaignMember();
        cm1.CampaignId = c1.Id;
        cm1.ContactId = con.Id;
        cm1.Status = 'Responded';
        
        CampaignMember cm2 = new CampaignMember();
        cm2.CampaignId = c2.Id;
        cm2.ContactId = con.Id;
        cm2.Status = 'Responded';
        
        List<CampaignMember> cms = new List<CampaignMember>();
        cms.add(cm1);
        cms.add(cm2);
        insert cms;
        
        Test.startTest();
        UpdateCampaignMemberTypeField ucmtf = new UpdateCampaignMemberTypeField();
        Database.executeBatch(ucmtf);
        Test.stopTest();
        
        con = [SELECT Id, Campaign_Member_Type__c FROM Contact WHERE Id = :con.Id];
        System.assert(con.Campaign_Member_Type__c == 'Salesforce;Excel' || con.Campaign_Member_Type__c == 'Excel;Salesforce');
    }
}