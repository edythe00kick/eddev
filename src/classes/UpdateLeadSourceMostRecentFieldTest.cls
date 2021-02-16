@isTest
public class UpdateLeadSourceMostRecentFieldTest{
  @isTest
    private static void testScenario1() {
        Campaign c = new Campaign();
        c.Name = 'ULSMRFT_Amazon';
        c.IsActive = true;
        c.Status = 'Planned';
        c.Program_Name__c = 'ULSMRFT_Amazon';
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
        l.LastName = 'ULSMRFT_Lead';
        l.Lead_Source_Most_Recent__c ='3rd Party - Download Sites'; 
        l.isConverted = false;
       // l.CreatedDate = Date.Today();
        l.Company = 'ULSMRFT_Company';
        l.Campaign_Member_Type__c = 'Tableau';
        // l.Campaign_Referred_Partner_ID__c = '001001001001001';
        insert l;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c.Id;
        cm.LeadId = l.Id;
        cm.Status = 'Responded';
        //cm.hasResponded = true;
        insert cm;
        
        Test.startTest();
        UpdateLeadSourceMostRecentField ulsmrf = new  UpdateLeadSourceMostRecentField();
        Database.executeBatch( ulsmrf );
        Test.stopTest();
        }
           @isTest
    private static void testScenario2() {
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
        con.Contact_Source_Most_Recent__c ='3rd Party - Content Syndication';
        //con.Most_Recent_Campaign_ID__c  != null;
        // con.CreatedDate=Date.Today();
        
        insert con;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = c.Id;
        cm.ContactId = con.Id;
        cm.Status = 'Responded';
        insert cm;
        
        Test.startTest();
       UpdateLeadSourceMostRecentField  ulsmrf  = new  UpdateLeadSourceMostRecentField();
        Database.executeBatch( ulsmrf );
        Test.stopTest();
        }

}