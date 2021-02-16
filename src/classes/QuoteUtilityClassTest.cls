/*Sergio Flores
Date: 06/26/2019 Creation
This is used for covering the QuoteUtilityClass Mainly used for testing
the stamping of order group with support level.
*/
@isTest
public with sharing class QuoteUtilityClassTest {

    @testSetup static void setup(){
        //Insert Support Level Records
        List<Support_Level__c> supportLevelCSList = new List<Support_Level__c>();

        Support_Level__c sl = new Support_Level__c();
        sl.Name = 'Advanced Support';
        sl.Product_Code__c = 'CS-183291, CS-183295';

        Support_Level__c sl2 = new Support_Level__c();
        sl2.Name = 'Premium Support';
        sl2.Product_Code__c = 'CS-183203';

        supportLevelCSList.add(sl);
        supportLevelCSList.add(sl2);

        insert supportLevelCSList;

    }


    //Author: Sergio Flores
    //Date: 06/26/2019
    static testMethod void testSupportLevelUpdateOrderGroup()
    {
        Id pricebookId = Test.getStandardPricebookId();
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

        Order_Group__c og = OrgWideTestUtil.insertOrderGroup(true, acc.Id);

        License_Administrator__c la = OrgWideTestUtil.insertlicAdm(true, acc.Id, cont.Id, og.Id );

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp.Id, acc.Id); 
        quote.Order_Group__c = og.Id;
        quote.License_Administrator__c = la.Id;
        quote.SBQQ__PriceBook__c = pricebookId;
        insert quote;

        test.startTest();

        SBQQ__QuoteLine__c qli = OrgWideTestUtil.createQuoteLineItem(false , prod.Id, quote.Id);
        String strId = Id.valueOf(pbe.Id);
        qli.SBQQ__PricebookEntryId__c = strId;
        insert qli;

        License_Product__c lp = (License_Product__c)SmartFactory.createSObject('License_Product__c');
        lp.Product__c = prod.Id;
        lp.Quote__c = quote.Id;
        insert lp;

        //Insert License Key
        License_Key__c lk = new License_Key__c();
        lk.Contact__c = cont.Id;
        lk.License_Product__c = lp.Id;
        insert lk;

        License_Key__c licenseKey = [Select Id, Support_Level__c, Contact__r.Support_Level__c From License_Key__c Where Id =: lk.Id]; 

        system.assertEquals(licenseKey.Support_Level__c,licenseKey.Contact__r.Support_Level__c);

        //Need to update the proposal to have the  OG related above and have the proposal be accepted so that the order group will be updated with
        //the support level of standard
        
        quote.SBQQ__Status__c = 'Accepted';
        update quote;

        Order_Group__c updatedOG = [Select Support_Level__c From Order_Group__c Where Id =: og.Id];
        system.assertEquals(updatedOG.Support_Level__c, 'Standard Support');

        test.stopTest();

        
    }

    //Author: Sergio Flores
    //Date: 06/26/2019
    static testMethod void testSupportLevelUpdateOrderGroupAdvancedSupport()
    {
        Id pricebookId = Test.getStandardPricebookId();
        pw_ccpro__CountryObject__c billToCountry = OrgWideTestUtil.createCountryCurrency(true, pricebookId);

        //Create standard product
        Product2 prod = OrgWideTestUtil.createProduct(false);
        prod.ProductCode = 'CS-183291';
        insert prod;
        

        PricebookEntry pbe = OrgWideTestUtil.createPricebookEntry(true, prod.Id, pricebookId);

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.pw_ccpro__MailingCountryLookup__c = billToCountry.Id;
        insert cont;

        Opportunity opp = OrgWideTestUtil.createOpportunity(false, acc.Id); 
        opp.Primary_Contact__c = cont.Id;
        insert opp;

        Order_Group__c og = OrgWideTestUtil.insertOrderGroup(true, acc.Id);

        License_Administrator__c la = OrgWideTestUtil.insertlicAdm(true, acc.Id, cont.Id, og.Id );

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp.Id, acc.Id); 
        quote.Order_Group__c = og.Id;
        quote.License_Administrator__c = la.Id;
        quote.SBQQ__PriceBook__c = pricebookId;
        insert quote;

        test.startTest();

        SBQQ__QuoteLine__c qli = OrgWideTestUtil.createQuoteLineItem(false , prod.Id, quote.Id);
        String strId = Id.valueOf(pbe.Id);
        qli.SBQQ__PricebookEntryId__c = strId;
        insert qli;

        License_Product__c lp = (License_Product__c)SmartFactory.createSObject('License_Product__c');
        lp.Product__c = prod.Id;
        lp.Quote__c = quote.Id;
        insert lp;

        //Insert License Key
        License_Key__c lk = new License_Key__c();
        lk.Contact__c = cont.Id;
        lk.License_Product__c = lp.Id;
        insert lk;

        License_Key__c licenseKey = [Select Id, Support_Level__c, Contact__r.Support_Level__c From License_Key__c Where Id =: lk.Id]; 

        system.assertEquals(licenseKey.Support_Level__c,licenseKey.Contact__r.Support_Level__c);

        //Need to update the proposal to have the  OG related above and have the proposal be accepted so that the order group will be updated with
        //the support level of standard
        
        quote.SBQQ__Status__c = 'Accepted';
        update quote;

        Order_Group__c updatedOG = [Select Support_Level__c From Order_Group__c Where Id =: og.Id];
        system.assertEquals(updatedOG.Support_Level__c, 'Advanced Support');

        test.stopTest();

        
    }

    //Author: Sergio Flores
    //Date: 06/26/2019
    static testMethod void testSupportLevelUpdateOrderGroupPremiumSupport()
    {
        Id pricebookId = Test.getStandardPricebookId();
        pw_ccpro__CountryObject__c billToCountry = OrgWideTestUtil.createCountryCurrency(true, pricebookId);

        //Create standard product
        Product2 prod = OrgWideTestUtil.createProduct(false);
        prod.ProductCode = 'CS-183203';
        insert prod;
        

        PricebookEntry pbe = OrgWideTestUtil.createPricebookEntry(true, prod.Id, pricebookId);

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.pw_ccpro__MailingCountryLookup__c = billToCountry.Id;
        insert cont;

        Opportunity opp = OrgWideTestUtil.createOpportunity(false, acc.Id); 
        opp.Primary_Contact__c = cont.Id;
        insert opp;

        Order_Group__c og = OrgWideTestUtil.insertOrderGroup(true, acc.Id);

        License_Administrator__c la = OrgWideTestUtil.insertlicAdm(true, acc.Id, cont.Id, og.Id );

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp.Id, acc.Id); 
        quote.Order_Group__c = og.Id;
        quote.License_Administrator__c = la.Id;
        quote.SBQQ__PriceBook__c = pricebookId;
        insert quote;

        test.startTest();

        SBQQ__QuoteLine__c qli = OrgWideTestUtil.createQuoteLineItem(false , prod.Id, quote.Id);
        String strId = Id.valueOf(pbe.Id);
        qli.SBQQ__PricebookEntryId__c = strId;
        insert qli;

        License_Product__c lp = (License_Product__c)SmartFactory.createSObject('License_Product__c');
        lp.Product__c = prod.Id;
        lp.Quote__c = quote.Id;
        insert lp;

        //Insert License Key
        License_Key__c lk = new License_Key__c();
        lk.Contact__c = cont.Id;
        lk.License_Product__c = lp.Id;
        insert lk;

        License_Key__c licenseKey = [Select Id, Support_Level__c, Contact__r.Support_Level__c From License_Key__c Where Id =: lk.Id]; 

        system.assertEquals(licenseKey.Support_Level__c,licenseKey.Contact__r.Support_Level__c);

        //Need to update the proposal to have the  OG related above and have the proposal be accepted so that the order group will be updated with
        //the support level of standard
        
        quote.SBQQ__Status__c = 'Accepted';
        update quote;

        Order_Group__c updatedOG = [Select Support_Level__c From Order_Group__c Where Id =: og.Id];
        system.assertEquals(updatedOG.Support_Level__c, 'Premium Support');

        test.stopTest();

        
    }

    //Author: Sergio Flores
    //Date: 06/26/2019
    static testMethod void testSupportLevelUpdateOrderGroupExpDate()
    {
        Id pricebookId = Test.getStandardPricebookId();
        pw_ccpro__CountryObject__c billToCountry = OrgWideTestUtil.createCountryCurrency(true, pricebookId);

        //Create standard product
        Product2 prod = OrgWideTestUtil.createProduct(false);
        prod.ProductCode = 'CS-183203';
        insert prod;
        

        PricebookEntry pbe = OrgWideTestUtil.createPricebookEntry(true, prod.Id, pricebookId);

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.pw_ccpro__MailingCountryLookup__c = billToCountry.Id;
        insert cont;

        Opportunity opp = OrgWideTestUtil.createOpportunity(false, acc.Id); 
        opp.Primary_Contact__c = cont.Id;
        insert opp;

        Date expirationDate = date.today();
        Order_Group__c og = OrgWideTestUtil.insertOrderGroup(false, acc.Id);
        og.Support_Expiration_Date__c = expirationDate.AddDays(-1);
        insert og;

        License_Administrator__c la = OrgWideTestUtil.insertlicAdm(true, acc.Id, cont.Id, og.Id );

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp.Id, acc.Id); 
        quote.Order_Group__c = og.Id;
        quote.License_Administrator__c = la.Id;
        quote.SBQQ__PriceBook__c = pricebookId;
        insert quote;

        test.startTest();

        SBQQ__QuoteLine__c qli = OrgWideTestUtil.createQuoteLineItem(false , prod.Id, quote.Id);
        String strId = Id.valueOf(pbe.Id);
        qli.SBQQ__PricebookEntryId__c = strId;
        insert qli;

        License_Product__c lp = (License_Product__c)SmartFactory.createSObject('License_Product__c');
        lp.Product__c = prod.Id;
        lp.Quote__c = quote.Id;
        insert lp;

        //Insert License Key
        License_Key__c lk = new License_Key__c();
        lk.Contact__c = cont.Id;
        lk.License_Product__c = lp.Id;
        insert lk;

        License_Key__c licenseKey = [Select Id, Support_Level__c, Contact__r.Support_Level__c From License_Key__c Where Id =: lk.Id]; 

        system.assertEquals(licenseKey.Support_Level__c,licenseKey.Contact__r.Support_Level__c);

        //Need to update the proposal to have the  OG related above and have the proposal be accepted so that the order group will be updated with
        //the support level of standard
        
        quote.SBQQ__Status__c = 'Accepted';
        update quote;

        Order_Group__c updatedOG = [Select Support_Level__c From Order_Group__c Where Id =: og.Id];
        system.assertEquals(updatedOG.Support_Level__c, 'Premium Support');

        test.stopTest();

        
    }

    //Author: Sergio Flores
    //Date: 06/26/2019
    static testMethod void testSupportLevelUpdateOrderGroupStandardToAdvancedSupport()
    {
        Id pricebookId = Test.getStandardPricebookId();
        pw_ccpro__CountryObject__c billToCountry = OrgWideTestUtil.createCountryCurrency(true, pricebookId);

        //Create standard product
        Product2 prod = OrgWideTestUtil.createProduct(false);
        prod.ProductCode = 'CS-183291';
        insert prod;
        

        PricebookEntry pbe = OrgWideTestUtil.createPricebookEntry(true, prod.Id, pricebookId);

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.pw_ccpro__MailingCountryLookup__c = billToCountry.Id;
        insert cont;

        Opportunity opp = OrgWideTestUtil.createOpportunity(false, acc.Id); 
        opp.Primary_Contact__c = cont.Id;
        insert opp;

        Order_Group__c og = OrgWideTestUtil.insertOrderGroup(false, acc.Id);
        og.Support_Level__c = 'Standard Support'; 
        insert og;

        License_Administrator__c la = OrgWideTestUtil.insertlicAdm(true, acc.Id, cont.Id, og.Id );

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp.Id, acc.Id); 
        quote.Order_Group__c = og.Id;
        quote.License_Administrator__c = la.Id;
        quote.SBQQ__PriceBook__c = pricebookId;
        insert quote;

        test.startTest();

        SBQQ__QuoteLine__c qli = OrgWideTestUtil.createQuoteLineItem(false , prod.Id, quote.Id);
        String strId = Id.valueOf(pbe.Id);
        qli.SBQQ__PricebookEntryId__c = strId;
        insert qli;

        License_Product__c lp = (License_Product__c)SmartFactory.createSObject('License_Product__c');
        lp.Product__c = prod.Id;
        lp.Quote__c = quote.Id;
        insert lp;

        //Insert License Key
        License_Key__c lk = new License_Key__c();
        lk.Contact__c = cont.Id;
        lk.License_Product__c = lp.Id;
        insert lk;

        License_Key__c licenseKey = [Select Id, Support_Level__c, Contact__r.Support_Level__c From License_Key__c Where Id =: lk.Id]; 

        system.assertEquals(licenseKey.Support_Level__c,licenseKey.Contact__r.Support_Level__c);

        //Need to update the proposal to have the  OG related above and have the proposal be accepted so that the order group will be updated with
        //the support level of standard
        
        quote.SBQQ__Status__c = 'Accepted';
        update quote;

        Order_Group__c updatedOG = [Select Support_Level__c From Order_Group__c Where Id =: og.Id];
        system.assertEquals(updatedOG.Support_Level__c, 'Advanced Support');

        test.stopTest();

        
    }

}