@isTest
public class UpdateCampaignMemberTypeFieldTestContact {
    @isTest
    private static void testScenario1() {
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
        insert c1;
        
        Campaign c2 = new Campaign();
        c2.Name = 'UCMTFT_Qlik';
        c2.IsActive = true;
        c2.Status = 'Planned';
        c2.Program_Name__c = 'UCMTFT_Qlik';
        c2.Region__c = 'Global';
        c2.Fiscal_Year__c = '2014';
        c2.Quarter__c = 'Q1';
        c2.Campaign_Tactic__c = '3rd Party Email';
        c2.Campaign_Offer__c = 'Analyst Report';
        c2.Vendor_Sponsored__c = 'Yes';
        c2.StartDate = Date.today();
        c2.EndDate = Date.today() + 2;
        insert c2;
        
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
        UpdateCampaignMemberTypeFieldContacts ucmtfc = new UpdateCampaignMemberTypeFieldContacts();
        Database.executeBatch(ucmtfc);
        Test.stopTest();
    }
}