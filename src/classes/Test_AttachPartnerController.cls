@isTest
//@isTest(SeeAllData=true)
public class Test_AttachPartnerController{
  
     
     // New set of test after lunch
     // checks that account is partner type and partner_type field is filled
     
     static testMethod void testscenario6() {
         Account acc1 = new Account();
         acc1.Name = 'Test Account';
         
         Account acc2 = new Account();
         acc2.Name = 'Test Account';
         acc2.Partner_Type__c = 'Alliance';
         acc2.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         accs.add(acc2);
         insert accs;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = acc1.Id;
         insert opp;
         
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = acc2.Id;
         insert con;
         
         Partner prtnr = new Partner();
         prtnr.OpportunityId = opp.Id;
         prtnr.AccountToId = acc2.Id;
//         insert prtnr;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con, opp.Id, prtnr, 'Deal Influencer', 'Partner brought us the deal');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.doChangePartner();
     }
     
     //checks that account is not partner type
     static testMethod void testscenario7() {
         Account acc1 = new Account();
         acc1.Name = 'Test Account';
         
         Account acc2 = new Account();
         acc2.Name = 'Test Account';
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         accs.add(acc2);
         insert accs;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = acc1.Id;
         insert opp;
         
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = acc2.Id;
         insert con;
         
         Partner prtnr = new Partner();
         prtnr.OpportunityId = opp.Id;
         prtnr.AccountToId = acc2.Id;
//         insert prtnr;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con, opp.Id, prtnr, 'Deal Influencer', 'Partner brought us the deal');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.doChangePartner();
     }
     
     //checks that account is partner type but partner_type field is null
	static testMethod void testscenario8() {
         Account acc1 = new Account();
         acc1.Name = 'Test Account';
         
         Account acc2 = new Account();
         acc2.Name = 'Test Account';
         acc2.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         accs.add(acc2);
         insert accs;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = acc1.Id;
         insert opp;
         
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = acc2.Id;
         insert con;
         
         Partner prtnr = new Partner();
         prtnr.OpportunityId = opp.Id;
         prtnr.AccountToId = acc2.Id;
//         insert prtnr;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con, opp.Id, prtnr, 'Deal Influencer', 'Partner brought us the deal');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.doChangePartner();
     }
     
     //checks that partnerinfluence field of wrapclass is blank
	static testMethod void testscenario9() {
         Account acc1 = new Account();
         acc1.Name = 'Test Account';
         
         Account acc2 = new Account();
         acc2.Name = 'Test Account';
         acc2.Partner_Type__c = 'Alliance';
         acc2.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         accs.add(acc2);
         insert accs;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = acc1.Id;
         insert opp;
         
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = acc2.Id;
         insert con;
         
         Partner prtnr = new Partner();
         prtnr.OpportunityId = opp.Id;
         prtnr.AccountToId = acc2.Id;
//         insert prtnr;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con, opp.Id, prtnr, 'Deal Influencer', '');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.doChangePartner();
     }
     
     //checks that a partner can be added only once
	static testMethod void testscenario10() {
         Account acc1 = new Account();
         acc1.Name = 'Test Account';
         
         Account acc2 = new Account();
         acc2.Name = 'Test Account';
         acc2.Partner_Type__c = 'Alliance';
         acc2.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         accs.add(acc2);
         insert accs;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = acc1.Id;
         insert opp;
         
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = acc2.Id;
         insert con;
         
         Partner prtnr = new Partner();
         prtnr.OpportunityId = opp.Id;
         prtnr.AccountToId = acc2.Id;
//         insert prtnr;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con, opp.Id, prtnr, 'Deal Influencer', 'Partner brought us the deal');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.wrapclasslist.add(wc);
         
         apc.doChangePartner();
     }
     
     //checks that role is none
	static testMethod void testscenario11() {
         Account acc1 = new Account();
         acc1.Name = 'Test Account';
         
         Account acc2 = new Account();
         acc2.Name = 'Test Account';
         acc2.Partner_Type__c = 'Alliance';
         acc2.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         accs.add(acc2);
         insert accs;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = acc1.Id;
         insert opp;
         
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = acc2.Id;
         insert con;
         
         Partner prtnr = new Partner();
         prtnr.OpportunityId = opp.Id;
         prtnr.AccountToId = acc2.Id;
//         insert prtnr;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con, opp.Id, prtnr, 'none', 'Partner brought us the deal');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.doChangePartner();
     }
     
     //An opportunity may have a partner. If a new partner with the role of an existing partner is added
	static testMethod void testscenario12() {
         Account acc1 = new Account();
         acc1.Name = 'Test Account';
         
         Account acc2 = new Account();
         acc2.Name = 'Test Account';
         acc2.Partner_Type__c = 'Alliance';
         acc2.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         
         Account acc3 = new Account();
         acc3.Name = 'Test Account';
         acc3.Partner_Type__c = 'Alliance';
         acc3.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         accs.add(acc2);
         accs.add(acc3);
         insert accs;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = acc1.Id;
         insert opp;
         
         Contact con1 = new Contact();
         con1.FirstName = 'Test';
         con1.LastName = 'Contact';
         con1.AccountId = acc2.Id;
         
         Contact con2 = new Contact();
         con2.FirstName = 'Test';
         con2.LastName = 'Contact';
         con2.AccountId = acc2.Id;
         
         List<Contact> contacts = new List<Contact>();
         contacts.add(con1);
         contacts.add(con2);
         insert contacts;
         
         Partner prtnr1 = new Partner();
         prtnr1.OpportunityId = opp.Id;
         prtnr1.AccountToId = acc2.Id;
         prtnr1.Role='Deal Influencer';
         
         Partner prtnr2 = new Partner();
         prtnr2.OpportunityId = opp.Id;
         prtnr2.AccountToId = acc3.Id;
         prtnr2.Role='Deal Influencer';
         
         List<Partner> partners = new List<Partner>();
         partners.add(prtnr1);
         partners.add(prtnr2);
//         insert partners;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con2, opp.Id, prtnr2, 'Deal Influencer', 'Partner brought us the deal');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.doChangePartner();
     }
     
     //covers rest of the methods
	static testMethod void testscenario13() {
         Account acc1 = new Account();
         acc1.Name = 'Test Account';
         
         Account acc2 = new Account();
         acc2.Name = 'Test Account';
         acc2.Partner_Type__c = 'Alliance';
         acc2.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         accs.add(acc2);
         insert accs;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = acc1.Id;
         insert opp;
         
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = acc2.Id;
         insert con;
         
         Partner prtnr = new Partner();
         prtnr.OpportunityId = opp.Id;
         prtnr.AccountToId = acc2.Id;
//         insert prtnr;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con, opp.Id, prtnr, 'Deal Influencer', 'Partner brought us the deal');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.doChangePartner();
         
         apc.doCancel();
         apc.getItems();
//         apc.getRoleItems();
         apc.getpartnerInfluenceItems();
     }
     
     
     //tests accounts whose record type is not partner
	static testMethod  void testscenario14() {
         Account acc1 = new Account();
         acc1.Name = 'Test Account';
         
         Account acc2 = new Account();
         acc2.Name = 'Test Account';
         acc2.Partner_Type__c = 'Alliance';
         acc2.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Account Record Type').getRecordTypeId();
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         accs.add(acc2);
         insert accs;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = acc1.Id;
         insert opp;
         
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = acc2.Id;
         insert con;
         
         Partner prtnr = new Partner();
         prtnr.OpportunityId = opp.Id;
         prtnr.AccountToId = acc2.Id;
//         insert prtnr;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con, opp.Id, prtnr, 'Deal Influencer', 'Partner brought us the deal');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.doChangePartner();
     }
     
     //checks that contact's accountid is null
	static testMethod void testscenario15() {
         Account acc1 = new Account();
         acc1.Name = 'Test Account';
         
         Account acc2 = new Account();
         acc2.Name = 'Test Account';
         acc2.Partner_Type__c = 'Alliance';
         acc2.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Account Record Type').getRecordTypeId();
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         accs.add(acc2);
         insert accs;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = acc1.Id;
         insert opp;
         
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         insert con;
         
         Partner prtnr = new Partner();
         prtnr.OpportunityId = opp.Id;
         prtnr.AccountToId = acc2.Id;
//         insert prtnr;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con, opp.Id, prtnr, 'Deal Influencer', 'Partner brought us the deal');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.doChangePartner();
     }
     
     
     //covers partner whose role is 'value added reseller'
	static testMethod void testscenario16() {
         Account acc1 = new Account();
         acc1.Name = 'Test Account';
         
         Account acc2 = new Account();
         acc2.Name = 'Test Account';
         acc2.Partner_Type__c = 'Master Reseller';
         acc2.Reseller_Hold__c =true;
         acc2.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         accs.add(acc2);
         insert accs;
         
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = acc1.Id;
         insert opp;
         
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = acc2.Id;
         insert con;
         
         Partner prtnr = new Partner();
         prtnr.OpportunityId = opp.Id;
         prtnr.AccountToId = acc2.Id;
//         insert prtnr;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con, opp.Id, prtnr, 'Value Added Reseller', 'Partner brought us the deal');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.doChangePartner();
     }
     
     // Add a partner to cover controller the stores existing partner role
	static testMethod void testscenario17() {
         Account acc1 = createAccount(false, 'Alliance');
         
         List<Account> accs = new List<Account>();
         accs.add(acc1);
         insert accs;
         
         Contact con = createContact(true);
         Opportunity opp = createOpportunity(true, con.AccountId);
         createPartner(true, opp.Id, acc1.Id, opp.AccountId, true, 'Deal Influencer');
         createPartner(true, opp.Id, acc1.Id, opp.AccountId, true, 'Collaborative Sale');
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         AttachPartnerController apc = new AttachPartnerController();
     }
     
	static testMethod void testScenario18() {
        Account acc1 = new Account();
        acc1.Name = 'APC Account';
        insert acc1;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact';
        con1.Email = 'apc@contact.com';
        con1.Phone = '010101';
        con1.MailingStreet = 'apc test street';
        con1.MailingCity = 'hollywood';
        con1.MailingState = 'fl';
        con1.MailingPostalCode = '88345';
        con1.MailingCountry = 'United States';
        con1.AccountId = acc1.Id;
        insert con1;
        
        Opportunity opp = createOpportunity(true, con1.AccountId);

        //Name: Chris Salgado Date: 2/11/20 Purpose: Failing Test Class cause User is no longer active
        User usr = OrgWideTestUtil.getUser();
        /*User usr = [SELECT Id FROM User
            WHERE Username LIKE '%aayusa@alteryx.com%' AND IsActive=true
            LIMIT 1];*/
            
        Account acc2 = new Account();
        acc2.Name = 'APC Partner Account';
        acc2.Partner_Type__c = 'Alliance';
        acc2.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc2.Business_Development_Owner__c = usr.Id;
        insert acc2;
                
        Contact con2 = new Contact();
        con2.FirstName = 'APC Partner';
        con2.LastName = 'Contact';
        con2.Email = 'apc_partner@contact.com';
        con2.Phone = '010101';
        con2.MailingStreet = 'apc test street';
        con2.MailingCity = 'hollywood';
        con2.MailingState = 'fl';
        con2.MailingPostalCode = '88345';
        con2.MailingCountry = 'United States';
        con2.AccountId = acc2.Id;
        con2.Partner_Account__c = acc2.Id;
        insert con2;
        
        
        PageReference pageRef = Page.Attach_Partner_Page;
        pageRef.getParameters().put('oppId', opp.Id);
        Test.setCurrentPage(pageRef);
        AttachPartnerController apc = new AttachPartnerController();
        
        apc.wrapclassList[0].contac = con2;
        apc.wrapclassList[0].rol = 'Reseller';
        apc.wrapclassList[0].isAccountPartnerType = true;
        apc.wrapclassList[0].isPartnerTypefilled = true;
        apc.wrapclassList[0].selected = true;
        
        apc.doChangePartner();
    }
    
	static testMethod void testScenario19() {
        Account acc1 = new Account();
        acc1.Name = 'APC Account';
        insert acc1;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact';
        con1.Email = 'apc@contact.com';
        con1.Phone = '010101';
        con1.MailingStreet = 'apc test street';
        con1.MailingCity = 'hollywood';
        con1.MailingState = 'fl';
        con1.MailingPostalCode = '88345';
        con1.MailingCountry = 'United States';
        con1.AccountId = acc1.Id;
        insert con1;
        
        Opportunity opp = createOpportunity(true, con1.AccountId);
        
        
        
        Account acc2 = new Account();
        acc2.Name = 'APC Normal Account';
        acc2.Partner_Type__c = 'Alliance';
        acc2.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Account Record Type')
                .getRecordTypeId();
        
        insert acc2;
                
        Contact con2 = new Contact();
        con2.FirstName = 'APC Normal';
        con2.LastName = 'Contact';
        con2.Email = 'apc_partner@contact.com';
        con2.Phone = '010101';
        con2.MailingStreet = 'apc test street';
        con2.MailingCity = 'hollywood';
        con2.MailingState = 'fl';
        con2.MailingPostalCode = '88345';
        con2.MailingCountry = 'United States';
        con2.AccountId = acc2.Id;
        //con2.Partner_Account__c = acc2.Id;
        insert con2;
        
        
        PageReference pageRef = Page.Attach_Partner_Page;
        pageRef.getParameters().put('oppId', opp.Id);
        Test.setCurrentPage(pageRef);
        AttachPartnerController apc = new AttachPartnerController();
        
        apc.wrapclassList[0].contac = con2;
        apc.wrapclassList[0].rol = 'Reseller';
        apc.wrapclassList[0].isAccountPartnerType = true;
        apc.wrapclassList[0].isPartnerTypefilled = true;
        
        apc.doChangePartner();
    }
    
	static testMethod void testScenario20() {
        Account acc1 = new Account();
        acc1.Name = 'APC Account';
        insert acc1;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact';
        con1.Email = 'apc@contact.com';
        con1.Phone = '010101';
        con1.MailingStreet = 'apc test street';
        con1.MailingCity = 'hollywood';
        con1.MailingState = 'fl';
        con1.MailingPostalCode = '88345';
        con1.MailingCountry = 'United States';
        con1.AccountId = acc1.Id;
        insert con1;
        
        Opportunity opp = createOpportunity(true, con1.AccountId);


        //Name: Chris Salgado Date: 2/11/20 Purpose: Failing Test Class cause User is no longer active
        User usr = OrgWideTestUtil.getUser();
        /*User usr = [SELECT Id FROM User
            WHERE Username LIKE '%aayusa@alteryx.com%' AND IsActive=true
            LIMIT 1];*/
            
        Account acc2 = new Account();
        acc2.Name = 'APC Partner Account';
        acc2.Partner_Type__c = 'Alliance';
        acc2.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc2.Business_Development_Owner__c = usr.Id;
        insert acc2;
        
        Partner p1 = new Partner();
        p1.OpportunityId = opp.Id;
        p1.AccountToId = acc2.Id;
        p1.Role = 'Deal Influencer';
        insert p1;
                
        Contact con2 = new Contact();
        con2.FirstName = 'APC Partner';
        con2.LastName = 'Contact';
        con2.Email = 'apc_partner@contact.com';
        con2.Phone = '010101';
        con2.MailingStreet = 'apc test street';
        con2.MailingCity = 'hollywood';
        con2.MailingState = 'fl';
        con2.MailingPostalCode = '88345';
        con2.MailingCountry = 'United States';
        con2.AccountId = acc2.Id;
        con2.Partner_Account__c = acc2.Id;
        insert con2;
        
        
        PageReference pageRef = Page.Attach_Partner_Page;
        pageRef.getParameters().put('oppId', opp.Id);
        Test.setCurrentPage(pageRef);
        AttachPartnerController apc = new AttachPartnerController();
        
        apc.wrapclassList[0].contac = con2;
        apc.wrapclassList[0].rol = 'Deal Influencer';
        apc.wrapclassList[0].isAccountPartnerType = true;
        apc.wrapclassList[0].isPartnerTypefilled = true;
        
        apc.doChangePartner();
    }
    
	static testMethod void testScenario21() {
        Account acc1 = new Account();
        acc1.Name = 'APC Account';
        insert acc1;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact';
        con1.Email = 'apc@contact.com';
        con1.Phone = '010101';
        con1.MailingStreet = 'apc test street';
        con1.MailingCity = 'hollywood';
        con1.MailingState = 'fl';
        con1.MailingPostalCode = '88345';
        con1.MailingCountry = 'United States';
        con1.AccountId = acc1.Id;
        insert con1;
        
        Opportunity opp = createOpportunity(true, con1.AccountId);


        //Name: Chris Salgado Date: 2/11/20 Purpose: Failing Test Class cause User is no longer active
        User usr = OrgWideTestUtil.getUser();
        /*User usr = [SELECT Id FROM User
            WHERE Username LIKE '%aayusa@alteryx.com%' AND IsActive=true
            LIMIT 1];*/
            
        Account acc2 = new Account();
        acc2.Name = 'APC Partner Account';
        acc2.Partner_Type__c = 'Alliance';
        acc2.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc2.Business_Development_Owner__c = usr.Id;
        insert acc2;
        
        Partner p1 = new Partner();
        p1.OpportunityId = opp.Id;
        p1.AccountToId = acc2.Id;
        p1.Role = 'Collaborative Sale';
        insert p1;
                
        Contact con2 = new Contact();
        con2.FirstName = 'APC Partner';
        con2.LastName = 'Contact';
        con2.Email = 'apc_partner@contact.com';
        con2.Phone = '010101';
        con2.MailingStreet = 'apc test street';
        con2.MailingCity = 'hollywood';
        con2.MailingState = 'fl';
        con2.MailingPostalCode = '88345';
        con2.MailingCountry = 'United States';
        con2.AccountId = acc2.Id;
        con2.Partner_Account__c = acc2.Id;
        insert con2;
        
        
        PageReference pageRef = Page.Attach_Partner_Page;
        pageRef.getParameters().put('oppId', opp.Id);
        Test.setCurrentPage(pageRef);
        AttachPartnerController apc = new AttachPartnerController();
        
        apc.wrapclassList[0].contac = con2;
        apc.wrapclassList[0].rol = 'Collaborative Sale';
        apc.wrapclassList[0].isAccountPartnerType = true;
        apc.wrapclassList[0].isPartnerTypefilled = true;
        
        apc.doChangePartner();
    }
    
	static testMethod void testScenario22() {
        Account acc1 = new Account();
        acc1.Name = 'APC Account';
        insert acc1;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact';
        con1.Email = 'apc@contact.com';
        con1.Phone = '010101';
        con1.MailingStreet = 'apc test street';
        con1.MailingCity = 'hollywood';
        con1.MailingState = 'fl';
        con1.MailingPostalCode = '88345';
        con1.MailingCountry = 'United States';
        con1.AccountId = acc1.Id;
        insert con1;
        
        Opportunity opp = createOpportunity(true, con1.AccountId);


        //Name: Chris Salgado Date: 2/11/20 Purpose: Failing Test Class cause User is no longer active
        User usr = OrgWideTestUtil.getUser();
        /*User usr = [SELECT Id FROM User
            WHERE Username LIKE '%aayusa@alteryx.com%' AND IsActive=true
            LIMIT 1];*/
            
        Account acc2 = new Account();
        acc2.Name = 'APC Partner Account';
        acc2.Partner_Type__c = 'Alliance';
        acc2.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc2.Business_Development_Owner__c = usr.Id;
        
        Account acc3 = new Account();
        acc3.Name = 'APC Partner Account';
        acc3.Partner_Type__c = 'Alliance';
        acc3.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc3.Business_Development_Owner__c = usr.Id;
        
        Account acc4 = new Account();
        acc4.Name = 'APC Partner Account';
        acc4.Partner_Type__c = 'Alliance';
        acc4.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc4.Business_Development_Owner__c = usr.Id;
        
        Account acc5 = new Account();
        acc5.Name = 'APC Partner Account';
        acc5.Partner_Type__c = 'Alliance';
        acc5.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc5.Business_Development_Owner__c = usr.Id;
        
        List<Account> accs = new List<Account>();
        accs.add(acc2);
        accs.add(acc3);
        accs.add(acc4);
        accs.add(acc5);
        insert accs;
        
        Partner p1 = new Partner();
        p1.OpportunityId = opp.Id;
        p1.AccountToId = acc2.Id;
        p1.Role = 'Deal Influencer';
        
        Partner p2 = new Partner();
        p2.OpportunityId = opp.Id;
        p2.AccountToId = acc3.Id;
        p2.Role = 'Deal Influencer';
        
        Partner p3 = new Partner();
        p3.OpportunityId = opp.Id;
        p3.AccountToId = acc4.Id;
        p3.Role = 'Deal Influencer';
        List<Partner> ps = new List<Partner>();
        ps.add(p1);
        ps.add(p2);
        ps.add(p3);
        insert ps;
                
        Contact con2 = new Contact();
        con2.FirstName = 'APC Partner';
        con2.LastName = 'Contact';
        con2.Email = 'apc_partner@contact.com';
        con2.Phone = '010101';
        con2.MailingStreet = 'apc test street';
        con2.MailingCity = 'hollywood';
        con2.MailingState = 'fl';
        con2.MailingPostalCode = '88345';
        con2.MailingCountry = 'United States';
        con2.AccountId = acc5.Id;
        con2.Partner_Account__c = acc5.Id;
        insert con2;
        
        
        PageReference pageRef = Page.Attach_Partner_Page;
        pageRef.getParameters().put('oppId', opp.Id);
        Test.setCurrentPage(pageRef);
        AttachPartnerController apc = new AttachPartnerController();
        
        apc.wrapclassList[0].contac = con2;
        apc.wrapclassList[0].rol = 'Deal Influencer';
        apc.wrapclassList[0].isAccountPartnerType = true;
        apc.wrapclassList[0].isPartnerTypefilled = true;
        apc.wrapclassList[0].partinfluence = 'Partner brought us the deal';
        
        apc.doChangePartner();
    }
    
    static testMethod void testScenario23() {
        Account acc1 = new Account();
        acc1.Name = 'APC Account';
        insert acc1;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact';
        con1.Email = 'apc@contact.com';
        con1.Phone = '010101';
        con1.MailingStreet = 'apc test street';
        con1.MailingCity = 'hollywood';
        con1.MailingState = 'fl';
        con1.MailingPostalCode = '88345';
        con1.MailingCountry = 'United States';
        con1.AccountId = acc1.Id;
        insert con1;
        
        Opportunity opp = createOpportunity(true, con1.AccountId);


        //Name: Chris Salgado Date: 2/11/20 Purpose: Failing Test Class cause User is no longer active
        User usr = OrgWideTestUtil.getUser();
        /*User usr = [SELECT Id FROM User
            WHERE Username LIKE '%aayusa@alteryx.com%' AND IsActive=true
            LIMIT 1];*/
            
        Account acc2 = new Account();
        acc2.Name = 'APC Partner Account';
        acc2.Partner_Type__c = 'Alliance';
        acc2.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc2.Business_Development_Owner__c = usr.Id;
        
        Account acc3 = new Account();
        acc3.Name = 'APC Partner Account';
        acc3.Partner_Type__c = 'Alliance';
        acc3.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc3.Business_Development_Owner__c = usr.Id;
        
        Account acc4 = new Account();
        acc4.Name = 'APC Partner Account';
        acc4.Partner_Type__c = 'Alliance';
        acc4.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc4.Business_Development_Owner__c = usr.Id;
        
        Account acc5 = new Account();
        acc5.Name = 'APC Partner Account';
        acc5.Partner_Type__c = 'Alliance';
        acc5.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc5.Business_Development_Owner__c = usr.Id;
        
        List<Account> accs = new List<Account>();
        accs.add(acc2);
        accs.add(acc3);
        accs.add(acc4);
        accs.add(acc5);
        insert accs;
        
        Partner p1 = new Partner();
        p1.OpportunityId = opp.Id;
        p1.AccountToId = acc2.Id;
        p1.Role = 'Referrer';
        
        Partner p2 = new Partner();
        p2.OpportunityId = opp.Id;
        p2.AccountToId = acc3.Id;
        p2.Role = 'Collaborative Sale';
        
        Partner p3 = new Partner();
        p3.OpportunityId = opp.Id;
        p3.AccountToId = acc4.Id;
        p3.Role = 'Deal Influencer';
        List<Partner> ps = new List<Partner>();
        ps.add(p1);
        ps.add(p2);
        ps.add(p3);
        insert ps;
           
        Contact con2 = new Contact();
        con2.FirstName = 'APC Partner';
        con2.LastName = 'Contact';
        con2.Email = 'apc_partner@contact.com';
        con2.Phone = '010101';
        con2.MailingStreet = 'apc test street';
        con2.MailingCity = 'hollywood';
        con2.MailingState = 'fl';
        con2.MailingPostalCode = '88345';
        con2.MailingCountry = 'United States';
        con2.AccountId = acc5.Id;
        con2.Partner_Account__c = acc5.Id;
        insert con2;
        
        
        PageReference pageRef = Page.Attach_Partner_Page;
        pageRef.getParameters().put('oppId', opp.Id);
        Test.setCurrentPage(pageRef);
        AttachPartnerController apc = new AttachPartnerController();
        
        apc.wrapclassList[0].contac = con2;
        apc.wrapclassList[0].rol = 'Deal Influencer';
        apc.wrapclassList[0].isAccountPartnerType = true;
        apc.wrapclassList[0].isPartnerTypefilled = true;
        apc.wrapclassList[0].partinfluence = 'Partner brought us the deal';
        
        apc.doChangePartner();
    }
     
    static testMethod void testScenario24() {
        Account acc1 = new Account();
        acc1.Name = 'APC Account';
        insert acc1;
        
        Contact con1 = new Contact();
        con1.FirstName = 'Test';
        con1.LastName = 'Contact';
        con1.Email = 'apc@contact.com';
        con1.Phone = '010101';
        con1.MailingStreet = 'apc test street';
        con1.MailingCity = 'hollywood';
        con1.MailingState = 'fl';
        con1.MailingPostalCode = '88345';
        con1.MailingCountry = 'United States';
        con1.AccountId = acc1.Id;
        insert con1;
        
        Opportunity opp = createOpportunity(true, con1.AccountId);

        //Name: Chris Salgado Date: 2/11/20 Purpose: Failing Test Class cause User is no longer active
        User usr = OrgWideTestUtil.getUser();
        /*User usr = [SELECT Id FROM User
            WHERE Username LIKE '%aayusa@alteryx.com%' AND IsActive=true
            LIMIT 1];*/
            
        Account acc2 = new Account();
        acc2.Name = 'APC Partner Account';
        acc2.Partner_Type__c = 'Alliance';
        acc2.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc2.Business_Development_Owner__c = usr.Id;
        acc2.Reseller_Hold__c = true;
        
        Account acc3 = new Account();
        acc3.Name = 'APC Partner Account';
        acc3.Partner_Type__c = 'Alliance';
        acc3.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc3.Business_Development_Owner__c = usr.Id;
        
        Account acc4 = new Account();
        acc4.Name = 'APC Partner Account';
        acc4.Partner_Type__c = 'Alliance';
        acc4.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc4.Business_Development_Owner__c = usr.Id;
        
        Account acc5 = new Account();
        acc5.Name = 'APC Partner Account';
        acc5.Partner_Type__c = 'Alliance';
        acc5.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc5.Business_Development_Owner__c = usr.Id;
        
        List<Account> accs = new List<Account>();
        accs.add(acc2);
        accs.add(acc3);
        accs.add(acc4);
        accs.add(acc5);
        insert accs;
        
        Partner p1 = new Partner();
        p1.OpportunityId = opp.Id;
        p1.AccountToId = acc2.Id; 
        p1.Role = 'Referrer';
        
        Partner p2 = new Partner();
        p2.OpportunityId = opp.Id;
        p2.AccountToId = acc2.Id;
        p2.Role = 'Value Added Reseller';
        
        Id ProfId = [SELECT Id, Name FROM Profile WHERE Name = 'Alteryx - Sales - Account Executives'].Id;
        
		User runUser = [SELECT Id FROM User WHERE IsActive=true AND ProfileId =: ProfId LIMIT 1];
        
        Partner p3 = new Partner();
        p3.OpportunityId = opp.Id;
        p3.AccountToId = acc4.Id;
        p3.Role = 'Deal Influencer';
        List<Partner> ps = new List<Partner>();
        ps.add(p1);
        ps.add(p2);
        ps.add(p3);   
	    insert ps;
                
        Contact con2 = new Contact();
        con2.FirstName = 'APC Partner';
        con2.LastName = 'Contact';
        con2.Email = 'apc_partner@contact.com';
        con2.Phone = '010101';
        con2.MailingStreet = 'apc test street';
        con2.MailingCity = 'hollywood';
        con2.MailingState = 'fl';
        con2.MailingPostalCode = '88345';
        con2.MailingCountry = 'United States';
        con2.AccountId = acc5.Id;
        con2.Partner_Account__c = acc5.Id;
        insert con2;
        
        
        PageReference pageRef = Page.Attach_Partner_Page;
        pageRef.getParameters().put('oppId', opp.Id);
        Test.setCurrentPage(pageRef);
        AttachPartnerController apc = new AttachPartnerController();
        
        apc.wrapclassList[0].contac = con2;
        apc.wrapclassList[0].rol = 'Deal Influencer';
        apc.wrapclassList[0].isAccountPartnerType = true;
        apc.wrapclassList[0].isPartnerTypefilled = true;
        apc.wrapclassList[0].partinfluence = 'Partner brought us the deal';
        
        apc.doChangePartner();
    }
     
    /************** Utility Classes *****************/
     private static Account createAccount(Boolean do_insert, String partner_type) {
         Account acc = new Account();
         acc.Name = 'Test Account';
         if(partner_type != null) {
             acc.Partner_Type__c = partner_type;
         }
         if(do_insert) {
             insert acc;
         }
         return acc;
     }
     
     private static Contact createContact(Boolean do_insert) {
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = createAccount(true, null).Id;
         if(do_insert) {
             insert con;
         }
         return con;
     }
     
     private Static Opportunity createOpportunity(boolean do_insert, Id accountId) {
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         opp.AccountId = accountId;
         if(do_insert) { 
             insert opp;
         }
         return opp;
     }
     
     private static Partner createPartner(boolean do_insert, Id opportunityId, Id accountToId, Id accountFromId, Boolean isPrimary, String role) {
         Partner p = new Partner();
         p.OpportunityId = opportunityId;
         p.AccountToId = accountToId;
         //p.AccountFromId = accountFromId;
         p.role = role;
         if(isPrimary) {
             p.IsPrimary = true;
         }
         if(do_insert) {
             insert p;
         }
         return p;
     }
     
     
     /** commented out tests **/
      /*
   static testMethod void AttachPartnerControllerTests () {
         Account ac = new Account();
         ac.Name = 'NewComp';
         ac.shippingcountry='america';
         ac.shippingstate='california';
         ac.shippingpostalcode='92801';
         ac.shippingcity='san fransisco';
         ac.billingcountry='america';
         ac.billingstate='california';
         ac.billingcity='san fransisco';
         ac.billingpostalcode='92801';
         insert ac;
         
         Opportunity op = new Opportunity();
         op.Name = 'Test Opportunity';
         op.CloseDate = system.today();
         op.ForecastCategoryName = 'Pipeline';
         op.StageName = '1 - Identification';
         op.ownerid=userinfo.getuserid();
         //op.AccountId = ac.Id;
         insert op;
         
         Partner p = new Partner();
         p.AccountToId = ac.Id;
         p.OpportunityId = op.Id;
         insert p;
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId' , op.Id);
         Test.setCurrentPage(pageRef); 

        AttachPartnerController atc = new AttachPartnerController();
        atc.doChangePartner();
         atc.doCancel();
         atc.getItems();
         atc.getRoleItems();
         atc.getpartnerInfluenceItems();
         
         // Added later
         Opportunity myOp = new Opportunity();
         myOp.Name = 'Test Opp';
         myOp.StageName = '1 - Identification';
         myOp.CloseDate = Date.today() + 3;
         insert myOp;
         String myOpId = myOp.Id;
         
         Partner prt = new Partner();
         prt.OpportunityId = myOpId;
         Contact cd = new Contact(firstname = 'test');
         String partnerRole = 'Deal Influencer';
         String partnerInfluence='';
         Account acc = new Account();
         acc.Name = 'NewComp';
         acc.Partner_Type__c = 'Alliance';
         insert acc;
         cd.accountid = acc.id;
         boolean booleanValue = false;
                     
         
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(booleanValue,cd,myOpId,prt,partnerRole,partnerInfluence);
         wc.isAccountPartnerType = false;
         atc.wrapclasslist.add(wc);
         atc.doChangePartner();
         
     }
     */
     
     /*
     @isTest
     private static void testscenario1() {
         
         Account ac = new Account();
         ac.Name = 'NewComp';
         ac.Partner_Type__c = 'Referral';
         ac.shippingcountry='america';
         ac.shippingstate='california';
         ac.shippingpostalcode='92801';
         ac.shippingcity='san fransisco';
         ac.billingcountry='america';
         ac.billingstate='california';
         ac.billingcity='san fransisco';
         ac.billingpostalcode='92801';
         insert ac;
         
         Opportunity op = new Opportunity();
         op.Name = 'Test Opportunity';
         op.CloseDate = system.today();
         op.ForecastCategoryName = 'Pipeline';
         op.StageName = '1 - Identification';
         op.ownerid=userinfo.getuserid();
         //op.AccountId = ac.Id;
         insert op;
         
         Partner p = new Partner();
         p.AccountToId = ac.Id;
         p.OpportunityId = op.Id;
         insert p;
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId' , op.Id);
         Test.setCurrentPage(pageRef); 

        AttachPartnerController atc = new AttachPartnerController();
        atc.doChangePartner();
         atc.doCancel();
         atc.getItems();
         atc.getRoleItems();
         atc.getpartnerInfluenceItems();
         
         // Added later
         Opportunity myOp = new Opportunity();
         myOp.Name = 'Test Opp';
         myOp.StageName = '1 - Identification';
         myOp.CloseDate = Date.today() + 3;
         insert myOp;
         String myOpId = myOp.Id;
         
         Partner prt = new Partner();
         prt.OpportunityId = myOpId;
         Contact cd = new Contact(firstname = 'test');
         String partnerRole = 'Deal Influencer';
         String partnerInfluence='';
         Account acc = new Account();
         acc.Name = 'NewComp';
         acc.Partner_Type__c = 'Alliance';
         insert acc;
         cd.accountid = acc.id;
         boolean booleanValue = false;
                     
         
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(booleanValue,cd,myOpId,prt,partnerRole,partnerInfluence);
         wc.getRoleItems();
         wc.isPartnerTypeFilled = false;
         atc.wrapclasslist.add(wc);
         atc.doChangePartner();
         
     }
     
     @isTest
     private static void testscenario2() {
         
         Account ac = new Account();
         ac.Name = 'NewComp';
         ac.Partner_Type__c = 'Referral';
         ac.shippingcountry='america';
         ac.shippingstate='california';
         ac.shippingpostalcode='92801';
         ac.shippingcity='san fransisco';
         ac.billingcountry='america';
         ac.billingstate='california';
         ac.billingcity='san fransisco';
         ac.billingpostalcode='92801';
         insert ac;
         
         Opportunity op = new Opportunity();
         op.Name = 'Test Opportunity';
         op.CloseDate = system.today();
         op.ForecastCategoryName = 'Pipeline';
         op.StageName = '1 - Identification';
         op.ownerid=userinfo.getuserid();
         //op.AccountId = ac.Id;
         insert op;
         
         Partner p = new Partner();
         p.AccountToId = ac.Id;
         p.OpportunityId = op.Id;
         insert p;
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId' , op.Id);
         Test.setCurrentPage(pageRef); 

        AttachPartnerController atc = new AttachPartnerController();
        atc.doChangePartner();
         atc.doCancel();
         atc.getItems();
         atc.getRoleItems();
         atc.getpartnerInfluenceItems();
         
         // Added later
         Opportunity myOp = new Opportunity();
         myOp.Name = 'Test Opp';
         myOp.StageName = '1 - Identification';
         myOp.CloseDate = Date.today() + 3;
         insert myOp;
         String myOpId = myOp.Id;
         
         Partner prt = new Partner();
         prt.OpportunityId = myOpId;
         Contact cd = new Contact(firstname = 'test');
         String partnerRole = 'Deal Influencer';
         String partnerInfluence='';
         Account acc = new Account();
         acc.Name = 'NewComp';
         acc.Partner_Type__c = 'Technology';
         acc.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         insert acc;
         cd.accountid = acc.id;
         boolean booleanValue = false;
                     
         
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(booleanValue,cd,myOpId,prt,partnerRole,partnerInfluence);
         wc.getRoleItems();
         //wc.isPartnerTypeFilled = false;
         //wc.rol = 'Deal Influencer';
         atc.wrapclasslist.add(wc);
         atc.wrapclasslist.get(0).isAccountPartnerType = true;
         atc.wrapclasslist.get(0).isPartnerTypeFilled = false;
         atc.wrapclasslist.get(0).rol = 'Deal Influencer';
         
         atc.doChangePartner();
         
     }
     
     
     @isTest
     private static void testscenario3() {
         
         Account ac = new Account();
         ac.Name = 'NewComp';
         ac.Partner_Type__c = 'Referral';
         ac.shippingcountry='america';
         ac.shippingstate='california';
         ac.shippingpostalcode='92801';
         ac.shippingcity='san fransisco';
         ac.billingcountry='america';
         ac.billingstate='california';
         ac.billingcity='san fransisco';
         ac.billingpostalcode='92801';
         insert ac;
         
         Opportunity op = new Opportunity();
         op.Name = 'Test Opportunity';
         op.CloseDate = system.today();
         op.ForecastCategoryName = 'Pipeline';
         op.StageName = '1 - Identification';
         op.ownerid=userinfo.getuserid();
         //op.AccountId = ac.Id;
         insert op;
         
         Partner p = new Partner();
         p.AccountToId = ac.Id;
         p.OpportunityId = op.Id;
         insert p;
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId' , op.Id);
         Test.setCurrentPage(pageRef); 

        AttachPartnerController atc = new AttachPartnerController();
        atc.doChangePartner();
         atc.doCancel();
         atc.getItems();
         atc.getRoleItems();
         atc.getpartnerInfluenceItems();
         
         // Added later
         Opportunity myOp = new Opportunity();
         myOp.Name = 'Test Opp';
         myOp.StageName = '1 - Identification';
         myOp.CloseDate = Date.today() + 3;
         insert myOp;
         String myOpId = myOp.Id;
         
         Partner prt = new Partner();
         prt.OpportunityId = myOpId;
         Contact cd = new Contact(firstname = 'test');
         String partnerRole = '';
         String partnerInfluence='';
         Account acc = new Account();
         acc.Name = 'NewComp';
         acc.Partner_Type__c = 'Master Reseller';
         acc.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         insert acc;
         cd.accountid = acc.id;
         boolean booleanValue = false;
        
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(booleanValue,cd,myOpId,prt,partnerRole,partnerInfluence);
         wc.getRoleItems();
         atc.wrapclasslist.add(wc);
         atc.doChangePartner();
         
     }
     
     @isTest
     private static void testscenario4() {
         Account ac = new Account();
         ac.Name = 'NewComp';
         ac.Partner_Type__c = 'Referral';
         ac.shippingcountry='america';
         ac.shippingstate='california';
         ac.shippingpostalcode='92801';
         ac.shippingcity='san fransisco';
         ac.billingcountry='america';
         ac.billingstate='california';
         ac.billingcity='san fransisco';
         ac.billingpostalcode='92801';
         insert ac;
         
         Opportunity op = new Opportunity();
         op.Name = 'Test Opportunity';
         op.CloseDate = system.today();
         op.ForecastCategoryName = 'Pipeline';
         op.StageName = '1 - Identification';
         op.ownerid=userinfo.getuserid();
         //op.AccountId = ac.Id;
         insert op;
         
         Partner p = new Partner();
         p.AccountToId = ac.Id;
         p.OpportunityId = op.Id;
         insert p;
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId' , op.Id);
         Test.setCurrentPage(pageRef); 

        AttachPartnerController atc = new AttachPartnerController();
        atc.doChangePartner();
         atc.doCancel();
         atc.getItems();
         atc.getRoleItems();
         atc.getpartnerInfluenceItems();
         
         // Added later
         Opportunity myOp = new Opportunity();
         myOp.Name = 'Test Opp';
         myOp.StageName = '1 - Identification';
         myOp.CloseDate = Date.today() + 3;
         insert myOp;
         String myOpId = myOp.Id;
         
         Partner prt = new Partner();
         prt.OpportunityId = myOpId;
         prt.Role='Deal Influencer';
         Contact cd = new Contact(firstname = 'test');
         String partnerRole = '';
         String partnerInfluence='';
         Account acc = new Account();
         acc.Name = 'NewComp';
         acc.Partner_Type__c = 'Technology';
         acc.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         insert acc;
         cd.accountid = acc.id;
         boolean booleanValue = false;
        
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(booleanValue,cd,myOpId,prt,'Deal Influencer',partnerInfluence);
         wc.getRoleItems();
         //wc.rol='Deal Influencer';
         atc.wrapclasslist.add(wc);
         atc.doChangePartner();
         
         //atc.doChangePartner();
         atc.doCancel();
         atc.getItems();
         atc.getRoleItems();
         atc.getpartnerInfluenceItems();
         
     }
     */
     
     /*
     @isTest
     private static void testscenarion5() {
         Opportunity opp = new Opportunity();
         opp.Name = 'Test Opportunity';
         opp.StageName = '1 - Identification';
         opp.CloseDate = Date.today();
         insert opp;
         
         Account acc = new Account();
         acc.Name = 'Test Account';
         acc.Partner_Type__c = 'Alliance';
         acc.RecordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Partner Account Record Type').getRecordTypeId();
         insert acc;
         
         Contact con = new Contact();
         con.FirstName = 'Test';
         con.LastName = 'Contact';
         con.AccountId = acc.Id;
         insert con;
         
         Custom_Partner__c custom_partnr = new Custom_Partner__c();
         custom_partnr.OpportunityId__c = opp.Id;
         custom_partnr.AccountToId__c = acc.Id;
         insert custom_partnr;
         
         Partner partnr1 = new Partner();
         partnr1.OpportunityId = opp.Id;
         partnr1.AccountToId = acc.Id;
         insert partnr1;
         
         PageReference pageRef = Page.Attach_Partner_Page;
         pageRef.getParameters().put('oppId', opp.Id);
         Test.setCurrentPage(pageRef);
         
         AttachPartnerController apc = new AttachPartnerController();
         AttachPartnerController.wrapclass wc = new AttachPartnerController.wrapclass(false, con, opp.Id, partnr1, 'Deal Influencer', 'Partner brought us the deal');
         wc.getRoleItems();
         apc.wrapclasslist.add(wc);
         apc.doChangePartner();
         apc.doCancel();
         apc.getItems();
         apc.getRoleItems();
         apc.getpartnerInfluenceItems();
     }
     */
}