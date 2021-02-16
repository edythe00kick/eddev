@isTest
public class OSCPQ_QuoteTriggerTest {
  
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
        
        bdOwner.BD_Owner_ID__c = u.Id;
        insert bdOwner;
        
        List<Account> accountList = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        List<opportunity> opportunityList = new List<Opportunity>();
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Managed_Partner__c = true;
        acc.BillingState = 'AK';
        accountList.add(acc);
        
        Account acc1 = OrgWideTestUtil.createAccount(false);
        acc1.Managed_Partner__c = true;
        acc1.BillingState = 'AK';
        accountList.add(acc1);
        
        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Managed_Partner__c = true;
        acc2.BillingState = 'AK';
        acc2.Partner_Type__c = 'DMR';
        accountList.add(acc2);
        
        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Partner_Type__c = 'Technology';
        acc3.Managed_Partner__c = true;
        acc3.BillingState = 'AK';
        accountList.add(acc3);
        
        Account acc4 = OrgWideTestUtil.createPartnerAccount(false);
        acc4.Referral_Discount__c = '10%';
        acc4.Partner_Type__c = 'Referral';
        acc4.Managed_Partner__c = true;
        acc4.BillingState = 'AK';
        accountList.add(acc4);
        
        Account acc5 = OrgWideTestUtil.createPartnerAccount(false);
        acc5.Referral_Discount__c = '20%';
        acc5.Partner_Type__c = 'Master Reseller';
        acc5.Managed_Partner__c = true;
        acc5.BillingState = 'AK';
        accountList.add(acc5);
        
        Insert accountList;
        
        Contact con = OrgWideTestUtil.createContact(false, accountList[0].Id);
        contactList.add(con);
        
        Contact con1 = OrgWideTestUtil.createContact(false, accountList[1].Id);
        contactList.add(con1);
        
        insert contactList;
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(false, accountList[0].Id);
        opportunityList.add(opp);
        
        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, accountList[0].Id);
        opportunityList.add(opp1);
        
        Opportunity opp2 = OrgWideTestUtil.createOpportunity(false, accountList[1].Id);
        opportunityList.add(opp2);
        
        Opportunity opp3 = OrgWideTestUtil.createOpportunity(false, accountList[1].Id);
        opportunityList.add(opp3);
        
        insert opportunityList;
        
        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opportunityList[0].Id, accountList[0].Id);
        quoteList.add(quote);
        
        SBQQ__Quote__c quote1 = OrgWideTestUtil.createProposal(false, opportunityList[1].Id, accountList[0].Id);
        quoteList.add(quote1);
        
        SBQQ__Quote__c quote2 = OrgWideTestUtil.createProposal(false, opportunityList[2].Id, accountList[1].Id);
        quoteList.add(quote2);
        
        SBQQ__Quote__c quote3 = OrgWideTestUtil.createProposal(false, opportunityList[3].Id, accountList[1].Id);
        //quoteList.add(quote3);
        
        insert quoteList;
    }
    
  /*  public static testMethod void testTwinMapRenewal() {
        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contract cont = OSCPQ_TestFactory.createSingleContract(acct, false);
        cont.SBQQ__RenewalForecast__c = true;
        cont.SBQQ__RenewalQuoted__c = true;
        cont.SBQQ__RenewalTerm__c = 36;
        insert cont;

        opp.SBQQ__RenewedContract__c = cont.Id;
        Opp.Type = 'NB';
        update opp;

        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, true, false);
        newQuote.SBQQ__RenewalTerm__c = 12;

        Test.startTest();

        insert newQuote;

        Test.stopTest();

        List<SBQQ__Quote__c> newQuoteList =[SELECT Id, SBQQ__RenewalTerm__c FROM SBQQ__Quote__c];

        system.assertEquals(36, newQuoteList[4].SBQQ__RenewalTerm__c);

    }*/

    /*public static testMethod void testTwinMapAmendment() {
        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contract cont = OSCPQ_TestFactory.createSingleContract(acct, false);
        cont.SBQQ__RenewalForecast__c = true;
        cont.SBQQ__RenewalQuoted__c = true;
        cont.SBQQ__RenewalTerm__c = 36;
        insert cont;
        
        opp.SBQQ__AmendedContract__c = cont.Id;
        opp.Type = 'NB';
        update opp;
        
        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, true, false);
        newQuote.SBQQ__RenewalTerm__c = 12;

        Test.startTest();

        insert newQuote;

        Test.stopTest();

        List<SBQQ__Quote__c> newQuoteList =[SELECT Id, SBQQ__RenewalTerm__c FROM SBQQ__Quote__c];

        system.assertEquals(36, newQuoteList[4].SBQQ__RenewalTerm__c);
    }
*/
    /*A Quote having Partners updated from Non-Primary to Primary*/
    public static testMethod void testUpdateQuoteToPrimary() {
        List<Account> accounts = [SELECT Id, Partner_Type__c FROM Account];
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c];
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        
        quoteList[0].SBQQ__Partner__c = accounts[2].Id;
        quoteList[0].Partner_Role__c = 'Software Distributor';
        quoteList[0].SBQQ__Distributor__c = accounts[3].Id;
        quoteList[0].Distributor_Role__c = 'Deal Influencer';
        
        quoteList[1].SBQQ__Partner__c = accounts[3].Id;
        quoteList[1].Partner_Role__c = 'Deal Influencer';
        quoteList[1].SBQQ__Distributor__c = accounts[4].Id;
        quoteList[1].Distributor_Role__c = 'Referrer';
        
        update quoteList;
        //system.debug('scenario 1 Before'+ [Select Id, OpportunityId__c, AccountToId__c, IsPrimary__c,Role__c FROM Custom_Partner__c] );
        
        Test.startTest();
        quoteList[0].SBQQ__Primary__c = true;
        quoteList[1].SBQQ__Primary__c = true;
        quotelist[0].Purchase_Order__c = 'PS-1100';
        update quoteList;
        Test.stopTest();
        //system.debug('scenario 1 After'+ [Select Id, OpportunityId__c, AccountToId__c, IsPrimary__c,Role__c FROM Custom_Partner__c] );
    }
    
    /*Added Partners to a Primary Quote*/
    public static testMethod void AddPartnerToPrimaryQuote() {
        List<Account> accounts = [SELECT Id, Partner_Type__c FROM Account];
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c];
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();        
        
        quoteList[0].SBQQ__Primary__c = true;
        quoteList[1].SBQQ__Primary__c = true;
        update quoteList;
        
        //system.debug('scenario 2 Before '+ [Select Id, OpportunityId__c, AccountToId__c, IsPrimary__c,Role__c FROM Custom_Partner__c] );
        Test.startTest();        
        quoteList[0].SBQQ__Partner__c = accounts[3].Id;
        quoteList[0].Partner_Role__c = 'Deal Influencer';
        quoteList[0].SBQQ__Distributor__c = accounts[4].Id;
        quoteList[0].Distributor_Role__c = 'Referrer';
        
        quoteList[1].SBQQ__Partner__c = accounts[4].Id;
        quoteList[1].Partner_Role__c = 'Referrer';
        quoteList[1].SBQQ__Distributor__c = accounts[5].Id;
        quoteList[1].Distributor_Role__c = 'Value Added Reseller';
        
        update quoteList;
        Test.stopTest();
        //system.debug('scenario 2 After'+ [Select Id, OpportunityId__c, AccountToId__c, IsPrimary__c,Role__c FROM Custom_Partner__c] );
    }
    
    /*Added Partners moved out of primary*/
    public static testMethod void updatePrimarytoNonPrimary() {
        List<Account> accounts = [SELECT Id, Partner_Type__c FROM Account];
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c];
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();        
        
               
        quoteList[0].SBQQ__Primary__c = true;
        quoteList[1].SBQQ__Primary__c = true;
        
        quoteList[0].SBQQ__Partner__c = accounts[3].Id;
        quoteList[0].Partner_Role__c = 'Deal Influencer';
        quoteList[0].SBQQ__Distributor__c = accounts[4].Id;
        quoteList[0].Distributor_Role__c = 'Referrer';
        
        quoteList[1].SBQQ__Partner__c = accounts[4].Id;
        quoteList[1].Partner_Role__c = 'Referrer';
        quoteList[1].SBQQ__Distributor__c = accounts[5].Id;
        quoteList[1].Distributor_Role__c = 'Value Added Reseller';
        update quoteList;
        
        Test.startTest(); 
        
        //system.debug('scenario 3 Before '+ [Select Id, OpportunityId__c, AccountToId__c, IsPrimary__c,Role__c FROM Custom_Partner__c] );
       
        
        quoteList[0].SBQQ__Primary__c = false;
        quoteList[1].SBQQ__Primary__c = false;
        
        update quoteList;
        Test.stopTest();
        //system.debug('scenario 3 After '+ [Select Id, OpportunityId__c, AccountToId__c, IsPrimary__c,Role__c FROM Custom_Partner__c] );
        
    }
    
    
    
    /*Changed the partners of a primary quote*/
    /*public static testMethod void updatePrimaryQuotePartners() {
        List<Account> accounts = [SELECT Id, Partner_Type__c FROM Account];
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c];
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        
        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opps[3].Id, accounts[0].Id);
        quote.SBQQ__Primary__c = true;
        quote.Partner_Role__c = 'Software Distributor';
        quote.SBQQ__Partner__c = accounts[4].Id;
        insert quote;
        
        quoteList[0].SBQQ__Partner__c = accounts[2].Id;
        quoteList[0].Partner_Role__c = 'Software Distributor';        
        quoteList[0].SBQQ__Primary__c = true;
        
        quoteList[1].SBQQ__Distributor__c = accounts[4].Id;
        quoteList[1].Distributor_Role__c = 'Referrer';
        quoteList[1].SBQQ__Primary__c = true;
        
        Test.startTest();
        update quoteList;
        
        //system.debug('scenario 4 Before '+ [Select Id, OpportunityId__c, AccountToId__c, IsPrimary__c,Role__c FROM Custom_Partner__c] );
        quoteList[0].SBQQ__Distributor__c = accounts[3].Id;
        quoteList[0].Distributor_Role__c = 'Deal Influencer';
        
        quoteList[1].SBQQ__Partner__c = accounts[2].Id;
        quoteList[1].Partner_Role__c = 'Deal Influencer';
        update quoteList;
        Test.stopTest();
        //system.debug('scenario 4 After '+ [Select Id, OpportunityId__c, AccountToId__c, IsPrimary__c,Role__c FROM Custom_Partner__c] );
}*/
    
     /*Delete LA/LG test*/
    public static testMethod void testRemoveOrderGroup() {
        Account acc = OrgWideTestUtil.createAccount(true);
        
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;
        
        Order_Group__c og1 = OrgWideTestUtil.insertOrderGroup(true, acc.Id);
        License_Administrator__c la1 = OrgWideTestUtil.insertlicAdm(true, acc.Id, cont.Id, og1.Id);
        
        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        insert opp1;
        
        
        
        Test.startTest();

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp1.Id, acc.Id);
        quote.Order_Group__c = og1.Id;
        quote.License_Administrator__c = la1.Id;
        insert quote;
        
        quote.Order_Group__c = null;
        update quote;
        
        Test.stopTest();
        
        System.assertEquals(0, [SELECT Id FROM Order_Group__c].size());
        System.assertEquals(0, [SELECT Id FROM License_Administrator__c].size());
        
    }
  
    /*Deletetion of Quote having Order Group*/
    /*public static testMethod void deleteOrderGroupQuote() {
        Account acc = OrgWideTestUtil.createAccount(true);
        
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;
        
        Order_Group__c og1 = OrgWideTestUtil.insertOrderGroup(true, acc.Id);
        License_Administrator__c la1 = OrgWideTestUtil.insertlicAdm(true, acc.Id, cont.Id, og1.Id);
        
        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        insert opp1;
        
        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp1.Id, acc.Id);
        quote.Order_Group__c = og1.Id;
        quote.License_Administrator__c = la1.Id;
        insert quote;
        
        Test.startTest();
        
        delete quote;
        
        Test.stopTest();
                
    }*/
    
    /* Insert Partners during creation of quote*/
    public static testMethod void testPartnerOnQuoteCreation() {
        List<Account> accounts = [SELECT Id, Partner_Type__c FROM Account];
        List<Opportunity> opps = [SELECT Id FROM Opportunity];        
        List<Contact> contacts = [SELECT Id FROM Contact];
        
        opps[1].Primary_Contact__c = contacts[0].Id;
        update opps;
        
        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opps[1].Id, accounts[1].Id);
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__Partner__c = accounts[4].Id;
        quote.Partner_Role__c = 'Referrer';
        quote.SBQQ__Distributor__c = accounts[3].Id;
        quote.Distributor_Role__c = 'Deal Influencer';   
        
        Test.startTest();
        
        insert quote;
        
        Test.stopTest();
        
    }

    //Sergio Flores
    //Date: 07/08/2019
    //W-012477
    /*public static testMethod void amendQuoteCreationTest() {
    //When a quote is created through the amend process, it should go through the before update
    //and check to see if there is amend contract on the quote and if the quote has primary contact blank
    //if the above is true, the the quote should be automatically stamped with the following fields from the
    //original quote:
    /*
    MLA Option 
    Payment Method 
    Tax Reg NUmber  
    Billing Frequency 
    Is PO Required? 
    Primary Contact (From original Opp/Quote)
    Payment Terms 
    Payment Schedule (default to Equal)
     */

       /* Id pricebookId = Test.getStandardPricebookId();
        pw_ccpro__CountryObject__c billToCountry = OrgWideTestUtil.createCountryCurrency(true, pricebookId);

        //Create standard product
        Product2 prod = OrgWideTestUtil.createProduct(true);
        

        PricebookEntry pbe = OrgWideTestUtil.createPricebookEntry(true, prod.Id, pricebookId);

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.pw_ccpro__MailingCountryLookup__c = billToCountry.Id;
        insert cont;

        Opportunity opp = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp.Primary_Contact__c = cont.Id;
        insert opp;

        Opportunity amendedOpp = OrgWideTestUtil.createOpportunity(false, acc.Id);
        amendedOpp.Primary_Contact__c = cont.Id;
        insert amendedOpp;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp.Id, acc.Id);
        quote.SBQQ__PriceBook__c = pricebookId;
        quote.MLA_Option__c = 'Reseller';
        quote.SBQQ__PrimaryContact__c = cont.Id;
        insert quote;

        

       test.startTest();

        Contract contract = OSCPQ_TestFactory.createSingleContract(acc, false);
        contract.SBQQ__Opportunity__c = opp.Id;
        contract.SBQQ__Quote__c = quote.Id; 
        insert contract;

        //Create Amended Quote
        SBQQ__Quote__c amendedQuote = new SBQQ__Quote__c();
        amendedQuote.SBQQ__Account__c = acc.Id;
        amendedQuote.SBQQ__Opportunity2__c = amendedOpp.Id;
        amendedQuote.SBQQ__Type__c = 'Amendment';
        amendedQuote.SBQQ__Status__c = 'Draft';
        amendedQuote.Quote_Type__c = 'Purchase';
        amendedQuote.Purchase_Type__c = 'New Business';
        amendedQuote.SBQQ__PriceBook__c = pricebookId;
        insert amendedQuote;

        //Here we update to mimic the amend process
        amendedQuote.SBQQ__PrimaryContact__c = null;
        amendedQuote.OSCPQ_Amended_Contract__c = contract.Id;
        update amendedQuote;

        SBQQ__Quote__c updatedAmendedQUote = [Select Id, SBQQ__PrimaryContact__c, MLA_Option__c
                                              From SBQQ__Quote__c
                                              Where Id =: amendedQuote.Id];

        SBQQ__Quote__c originalQUote = [Select Id, SBQQ__PrimaryContact__c, MLA_Option__c
                                              From SBQQ__Quote__c
                                              Where Id =: quote.Id];

        system.assertEquals(updatedAmendedQUote.SBQQ__PrimaryContact__c, originalQUote.SBQQ__PrimaryContact__c);
        system.assertEquals(updatedAmendedQUote.MLA_Option__c, originalQUote.MLA_Option__c);
        test.stopTest();

     

    }*/


/*
    public static testMethod void testPartnerAutoPopulate() {
        List<Account> accountList = new List<Account>();
        List<SBQQ__Quote__c> newQuotes = new List<SBQQ__Quote__c>();

        Account acc1 = OrgWideTestUtil.createAccount(false);
        accountList.add(acc1);

        Account acc2 = OrgWideTestUtil.createPartnerAccount(false);
        acc2.Partner_Type__c = 'DMR';
        accountList.add(acc2);

        Account acc3 = OrgWideTestUtil.createPartnerAccount(false);
        acc3.Partner_Type__c = 'Master Reseller';
        accountList.add(acc3);

        insert accountList;

        Contact con = OrgWideTestUtil.createContact(true, acc1.Id);

        Opportunity opp = OrgWideTestUtil.createOpportunity(false, acc1.Id);
        opp.Primary_Contact__c = con.Id;
        insert opp;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp.Id, acc1.Id);
        quote.SBQQ__Primary__c = true;
        insert quote;

        quote.SBQQ__Partner__c = acc2.Id;
        quote.Partner_Role__c = 'Software Distributor';
        quote.SBQQ__Distributor__c = acc3.Id;
        quote.Distributor_Role__c = 'Value Added Reseller';

        update quote;

        SBQQ__Quote__c newQuote1 = OrgWideTestUtil.createProposal(false, opp.Id, acc1.Id);
        newQuotes.add(newQuote1);

        SBQQ__Quote__c newQuote2 = OrgWideTestUtil.createProposal(false, opp.Id, acc1.Id);
        newQuotes.add(newQuote2);

        SBQQ__Quote__c newQuote3 = OrgWideTestUtil.createProposal(false, opp.Id, acc1.Id);
        newQuotes.add(newQuote3);

        SBQQ__Quote__c newQuote4 = OrgWideTestUtil.createProposal(false, opp.Id, acc1.Id);
        newQuotes.add(newQuote4);

        SBQQ__Quote__c newQuote5 = OrgWideTestUtil.createProposal(false, opp.Id, acc1.Id);
        newQuotes.add(newQuote5);

        Test.startTest();

        insert newQuotes;

        Test.stopTest();

        newQuotes = [SELECT Id, SBQQ__Partner__c, Partner_Role__c, SBQQ__Distributor__c, 
                     Distributor_Role__c 
                     FROM SBQQ__Quote__c WHERE Id = :newQuotes];

        for (SBQQ__Quote__c newQuote : newQuotes) {
            System.assertEquals(acc2.Id, newQuote.SBQQ__Partner__c);
            System.assertEquals('Software Distributor', newQuote.Partner_Role__c);
            System.assertEquals(acc3.Id, newQuote.SBQQ__Distributor__c);
            System.assertEquals('Value Added Reseller', newQuote.Distributor_Role__c);
        }
    }*/

   /* public static testMethod void testUpdateOpportunityTCV() {
        List<Account> accounts = [SELECT Id, Partner_Type__c FROM Account];
        List<Opportunity> opps = [SELECT Id FROM Opportunity];
        List<SBQQ__Quote__c> quoteList = [SELECT Id FROM SBQQ__Quote__c];
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();
        
        Product2 prod = OrgWideTestUtil.createProduct(true);

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opps[3].Id, accounts[0].Id);
        quote.SBQQ__Primary__c = false;
        quote.Partner_Role__c = 'Software Distributor';
        quote.SBQQ__Partner__c = accounts[4].Id;
        quote.SBQQ__StartDate__c = System.Today();
        quote.SBQQ__EndDate__c = System.Today() + 2;
        insert quote;
        
        SBQQ__QuoteLine__c qouteLineItem = OSCPQ_TestFactory.createSingleQuoteLine(quote, prod, false);
        qouteLineItem.SBQQ__Bundled__c = false;
        qouteLineItem.SBQQ__Renewal__c = false;
        qouteLineItem.SBQQ__Existing__c = false;
        qouteLineItem.SBQQ__CarryoverLine__c = false;
        qouteLineItem.SBQQ__PriorQuantity__c = null;
        qouteLineItem.SBQQ__Quantity__c = 1;
        qouteLineItem.SBQQ__ProratedListPrice__c = 5000;
        qouteLineItem.SBQQ__SubscriptionPricing__c = 'Percent Of Total';

        insert qouteLineItem; 

        Test.startTest();
        
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__StartDate__c = System.Today();
        quote.SBQQ__EndDate__c = System.Today() + 365;

        update quoteList;
        
        Test.stopTest();
    }*/
}