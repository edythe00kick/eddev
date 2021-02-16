@isTest
public class QuoteQueueableTest {

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
    //Date: 06/28/2019
    static testMethod void testLicenseProductCreation()
    {
        Id pricebookId = Test.getStandardPricebookId();
        pw_ccpro__CountryObject__c billToCountry = OrgWideTestUtil.createCountryCurrency(true, pricebookId);

        //Create standard product
        Product2 prod = OrgWideTestUtil.createProduct(false);
        prod.ProductCode = '0101';
        prod.Family = 'Alteryx Software';
        prod.Licensing_System__c = 'Flexera';
        prod.Type_of_Revenue__c = 'Recurring';
        insert prod;
        
        //Need to insert product option in order for LP creation
        SBQQ__ProductOption__c prodOption = new SBQQ__ProductOption__c();
        prodOption.SBQQ__Quantity__c = 1;
        prodOption.SBQQ__OptionalSKU__c = prod.Id;
        prodOption.SBQQ__Number__c = 10;
        insert prodOption;

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
        qli.SBQQ__ProductOption__c = prodOption.Id;
        insert qli;

        
        //the support level of standard
        
        quote.SBQQ__Status__c = 'Accepted';
        update quote;

        test.stopTest();

        
    }

    //Author: Sergio Flores
    //Date: 06/28/2019
    static testMethod void testBundlewithOption()
    {
        Id pricebookId = Test.getStandardPricebookId();
        pw_ccpro__CountryObject__c billToCountry = OrgWideTestUtil.createCountryCurrency(true, pricebookId);

        //Create Bundle Product
        Product2 bundleProd = OrgWideTestUtil.createProduct(false);
        bundleProd.ProductCode = '01234';
        bundleProd.Family = 'Alteryx Software';
        bundleProd.Licensing_System__c = 'Flexera';
        bundleProd.Type_of_Revenue__c = 'Recurring';
        insert bundleProd;
        
        //Create standard product
        Product2 prod = OrgWideTestUtil.createProduct(false);
        prod.ProductCode = '0101';
        prod.Family = 'Alteryx Software';
        prod.Licensing_System__c = 'Flexera';
        prod.Type_of_Revenue__c = 'Recurring';
        insert prod;

        //Create Advanced Support product
        Product2 advancedProd = OrgWideTestUtil.createProduct(false);
        advancedProd.ProductCode = 'CS-183291';
        advancedProd.Family = 'Customer Support';
        advancedProd.Licensing_System__c = 'Flexera';
        advancedProd.Type_of_Revenue__c = 'Recurring';
        insert advancedProd;
        
        //Need to insert product option in order for LP creation
        SBQQ__ProductOption__c prodOption = new SBQQ__ProductOption__c();
        prodOption.SBQQ__Quantity__c = 1;
        prodOption.SBQQ__OptionalSKU__c = prod.Id;
        prodOption.SBQQ__Number__c = 10;
        insert prodOption;

        PricebookEntry pbeBundle = OrgWideTestUtil.createPricebookEntry(true, bundleProd.Id, pricebookId);
        PricebookEntry pbe = OrgWideTestUtil.createPricebookEntry(true, prod.Id, pricebookId);
        PricebookEntry pbeAdvanced = OrgWideTestUtil.createPricebookEntry(true, advancedProd.Id, pricebookId);

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

        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();

        SBQQ__QuoteLine__c qliBundleHeader = OrgWideTestUtil.createQuoteLineItem(false , bundleProd.Id, quote.Id);
        String strId = Id.valueOf(pbe.Id);
        qliBundleHeader.SBQQ__PricebookEntryId__c = strId;
        qliBundleHeader.Has_Options__c = true;
        qliBundleHeader.Line_Number__c = 1;
        quoteLinesToInsert.add(qliBundleHeader);
        
        SBQQ__QuoteLine__c qli = OrgWideTestUtil.createQuoteLineItem(false , prod.Id, quote.Id);
        qli.SBQQ__PricebookEntryId__c = strId;
        qli.SBQQ__ProductOption__c = prodOption.Id;
        qli.Line_Number__c = 1;
        quoteLinesToInsert.add(qli);

        //Add Advanced Support
        SBQQ__QuoteLine__c qliAdvanced = OrgWideTestUtil.createQuoteLineItem(false , advancedProd.Id, quote.Id);
        qliAdvanced.SBQQ__PricebookEntryId__c = strId;
        qliAdvanced.Line_Number__c = 2;
        quoteLinesToInsert.add(qliAdvanced);

        insert quoteLinesToInsert;
        
        quote.SBQQ__Status__c = 'Accepted';
        update quote;

        test.stopTest();

        
    }

    //Author: Sergio Flores
    //Date: 06/28/2019
    static testMethod void testAdoptionBundlewithOption()
    {
        Id pricebookId = Test.getStandardPricebookId();
        pw_ccpro__CountryObject__c billToCountry = OrgWideTestUtil.createCountryCurrency(true, pricebookId);

        //Create Bundle Product
        Product2 bundleProd = OrgWideTestUtil.createProduct(false);
        bundleProd.ProductCode = 'AX-146987';
        bundleProd.Family = 'Adoption';
        bundleProd.Licensing_System__c = 'Flexera';
        bundleProd.Type_of_Revenue__c = 'Non-Recurring';
        insert bundleProd;
        
        //Create standard product
        Product2 prod = OrgWideTestUtil.createProduct(false);
        prod.ProductCode = '0101';
        prod.Family = 'Alteryx Software';
        prod.Licensing_System__c = 'Flexera';
        prod.Type_of_Revenue__c = 'Recurring';
        insert prod;
        
        //Need to insert product option in order for LP creation
        SBQQ__ProductOption__c prodOption = new SBQQ__ProductOption__c();
        prodOption.SBQQ__Quantity__c = 1;
        prodOption.SBQQ__OptionalSKU__c = prod.Id;
        prodOption.SBQQ__Number__c = 10;
        insert prodOption;

        PricebookEntry pbeBundle = OrgWideTestUtil.createPricebookEntry(true, bundleProd.Id, pricebookId);
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

        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();

        SBQQ__QuoteLine__c qliBundleHeader = OrgWideTestUtil.createQuoteLineItem(false , bundleProd.Id, quote.Id);
        String strId = Id.valueOf(pbe.Id);
        qliBundleHeader.SBQQ__PricebookEntryId__c = strId;
        qliBundleHeader.Has_Options__c = true;
        qliBundleHeader.Line_Number__c = 1;
        qliBundleHeader.Adoption__c = true;
        quoteLinesToInsert.add(qliBundleHeader);
        
        SBQQ__QuoteLine__c qli = OrgWideTestUtil.createQuoteLineItem(false , prod.Id, quote.Id);
        qli.SBQQ__PricebookEntryId__c = strId;
        qli.SBQQ__ProductOption__c = prodOption.Id;
        qli.Line_Number__c = 1;
        qli.Adoption__c = true;
        quoteLinesToInsert.add(qli);

        insert quoteLinesToInsert;
        
        quote.SBQQ__Status__c = 'Accepted';
        update quote;

        test.stopTest();

        
    }

}