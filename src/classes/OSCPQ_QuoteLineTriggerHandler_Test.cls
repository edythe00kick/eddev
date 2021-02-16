/*------------------------------------------------------------------------+
Original Shift(developer@originalshift.com)
Purpose: Tests the OSCPQ Quote Line Trigger & Handler
 
Details: - Tests a negative scenario, simple positive Amendment, and a renewal with a bundle
 
History:
Mar 20/19 - Original Shift - Initial Implementation
------------------------------------------------------------------------+*/ 
@isTest
public class OSCPQ_QuoteLineTriggerHandler_Test {

    @testSetup static void setup() {
        Product2 renewableProd = OSCPQ_TestFactory.createBasicRenewableProduct(1, true);
        Product2 renewableParent = OSCPQ_TestFactory.createBasicRenewableProduct(2, true);
        insert (new Quote_Trigger_Custom_Settings__c(Name = 'Test', QuoteHistoricImportActive__c = false));

        List<PricebookEntry> PBEList = OSCPQ_TestFactory.createPBEntries(new List<Product2>{renewableProd}, true);
        Account acct = OSCPQ_TestFactory.createSingleAccount(true);
        Opportunity opp = OSCPQ_TestFactory.createSingleOpp(acct, true);
        SBQQ.TriggerControl.disable();
        SBQQ__Quote__c quote = OSCPQ_TestFactory.createSingleQuote(acct, opp, true, false);
        quote.Allow_Stub_Periods__c = true;
        insert quote;
        SBQQ__QuoteLineGroup__c qlGroup = OSCPQ_TestFactory.createSingleQuoteLineGroup(acct, quote, true);


        SBQQ__QuoteLine__c ql1 = OSCPQ_TestFactory.createSingleQuoteLine(quote, renewableProd, false);
        ql1.SBQQ__Group__c = qlGroup.Id;
        SBQQ__QuoteLine__c ql2 = OSCPQ_TestFactory.createSingleQuoteLine(quote, renewableParent, false);
        ql2.SBQQ__Group__c = qlGroup.Id;
        insert new List<SBQQ__QuoteLine__c>{ql1, ql2};

        Contract contr = OSCPQ_TestFactory.createSingleContract(acct, false);
        contr.SBQQ__Quote__c = quote.Id;
        insert contr;

        SBQQ__Subscription__c sub = OSCPQ_TestFactory.createSingleSubscription(contr, renewableProd, false);
        sub.OSCPQ_Quote_Line_Group_Id__c = qlGroup.Id;
        sub.SBQQ__OriginalQuoteLine__c = ql1.Id;

        SBQQ__Subscription__c sub2 = OSCPQ_TestFactory.createSingleSubscription(contr, renewableParent, false);
        sub2.OSCPQ_Quote_Line_Group_Id__c = qlGroup.Id;
        sub2.SBQQ__OriginalQuoteLine__c = ql2.Id;
        insert new List<SBQQ__Subscription__c>{sub, sub2};
        SBQQ.TriggerControl.enable();
        
    }

    /*
     * Test that runs when settings are set to 'Never'
     */
    @isTest
    static void simpleNegativeTest() {
        OSCPQ_QuoteLineTriggerHandler handler = new OSCPQ_QuoteLineTriggerHandler(false, 0, 'Default');
        handler.settings.TwinMapping_CloneQuoteGroups__c = 'Never';
        

        //Fetch Data from Setup
        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        SBQQ__Subscription__c sub = [SELECT Id, OSCPQ_Quote_Line_Group_Id__c FROM SBQQ__Subscription__c LIMIT 1];
        Product2 renewableProd = [SELECT Id FROM Product2 LIMIT 1];
        List<SBQQ__QuoteLineGroup__c> origQLGList = [SELECT Id FROM SBQQ__QuoteLineGroup__c];
        system.assert(origQLGList.size() == 1, 'Original Quote Line Group Does not exist');

        //Create Amendment-type opp/quote
        Opportunity amendmentOpp = OSCPQ_TestFactory.createSingleOpp(acct, true);
        SBQQ__Quote__c amendmentQuote = OSCPQ_TestFactory.createSingleQuote(acct, amendmentOpp, true, false);
        amendmentQuote.SBQQ__Type__c = 'Amendment';
        insert amendmentQuote;
        
        //Instantiate Quote Line
        SBQQ__QuoteLine__c ql = OSCPQ_TestFactory.createSingleQuoteLine(amendmentQuote, renewableProd, false);
        ql.SBQQ__UpgradedSubscription__c = sub.Id;

        Test.startTest();
        OSCPQ_QuoteLineTriggerHandler.firstRun = true;
        handler.onAfterInsert(new List<SBQQ__QuoteLine__c>{ql});
        Test.stopTest();

        List<SBQQ__QuoteLineGroup__c> newQLGList = [SELECT Id FROM SBQQ__QuoteLineGroup__c];
        system.assert(newQLGList.size() == origQLGList.size(), 'New QLGs were created when they should not have been');
        
    }

    /*
     * Test that runs when settings are set to 'Amendment'
     */
    @isTest
    static void simpleAmendmentTest() {
        OSCPQ_QuoteLineTriggerHandler handler = new OSCPQ_QuoteLineTriggerHandler(false, 0, 'Default');
        handler.settings.TwinMapping_CloneQuoteGroups__c = 'On Amendment';

        //Fetch Data from Setup
        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        SBQQ.TriggerControl.disable();
        SBQQ__Subscription__c sub = [SELECT Id, OSCPQ_Quote_Line_Group_Id__c FROM SBQQ__Subscription__c LIMIT 1];
        
        Product2 renewableProd = [SELECT Id FROM Product2 LIMIT 1];
        List<SBQQ__QuoteLineGroup__c> origQLGList = [SELECT Id FROM SBQQ__QuoteLineGroup__c];
        system.assert(origQLGList.size() == 1, 'Original Quote Line Group Does not exist');

        Test.startTest();

        //Create Amendment-type opp/quote
        Opportunity amendmentOpp = OSCPQ_TestFactory.createSingleOpp(acct, true);
        SBQQ__Quote__c amendmentQuote = OSCPQ_TestFactory.createSingleQuote(acct, amendmentOpp, true, false);
        amendmentQuote.SBQQ__Type__c = 'Quote';
        insert amendmentQuote;

        //Instantiate Quote Line
        SBQQ__QuoteLine__c ql = OSCPQ_TestFactory.createSingleQuoteLine(amendmentQuote, renewableProd, false);
        ql.SBQQ__UpgradedSubscription__c = sub.Id;
        
        insert ql; //Insert first with a non-amendment/quote version
        ql = [SELECT Id, 
              Name, 
              SBQQ__Quote__r.Name, 
              SBQQ__QuoteLine__c.CurrencyIsoCode, 
              SBQQ__QuoteLine__c.SBQQ__NetTotal__c, 
              SBQQ__QuoteLine__c.SBQQ__ProductName__c, 
              SBQQ__UpgradedSubscription__c, 
              OSCPQ_Original_Quote_Line_Group_Id__c, 
              SBQQ__Quote__c, 
              SBQQ__Product__c, 
              SBQQ__Group__c, 
              SBQQ__RequiredBy__c, 
              SBQQ__EffectiveStartDate__c, 
              SBQQ__EffectiveEndDate__c, 
              SBQQ__SubscriptionPricing__c, 
              SBQQ__ProrateMultiplier__c,
              Recurring_Rev_Product__c,
              SBQQ__ProductFamily__c //Sergio 2/18/2019 W-001712
              FROM SBQQ__QuoteLine__c WHERE Id = :ql.Id];
        amendmentQuote.SBQQ__Type__c = 'Amendment';
        update amendmentQuote;
        
        OSCPQ_QuoteLineTriggerHandler.firstRun = true;
        handler.onAfterInsert(new List<SBQQ__QuoteLine__c>{ql});
        Test.stopTest();
        SBQQ.TriggerControl.enable();
        
        List<SBQQ__QuoteLineGroup__c> newQLGList = [SELECT Id FROM SBQQ__QuoteLineGroup__c];
        system.assert(newQLGList.size() > origQLGList.size(), 'No new QLGs were created when they should have been');
        
    }

    /*
     * Test that runs when settings are set to 'Renewal' and we have several options and a product hierarchy
     */
    @isTest
    static void simpleRenewalHierarchyTest() {
        OSCPQ_QuoteLineTriggerHandler handler = new OSCPQ_QuoteLineTriggerHandler(false, 0, 'Default');
        handler.settings.TwinMapping_CloneQuoteGroups__c = 'On Renewal';

        //Fetch Data from Setup
        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Contract contr = [SELECT Id FROM Contract LIMIT 1];
        List<SBQQ__Subscription__c> subList = [SELECT Id, OSCPQ_Quote_Line_Group_Id__c, SBQQ__ProductName__c FROM SBQQ__Subscription__c];
        
        Product2 childProd = [SELECT Id FROM Product2 WHERE Name = 'Simple Renewable Product 1'];
        Product2 parentProd = [SELECT Id FROM Product2 WHERE Name = 'Simple Renewable Product 2'];

        List<SBQQ__QuoteLineGroup__c> origQLGList = [SELECT Id FROM SBQQ__QuoteLineGroup__c];
        system.assert(origQLGList.size() == 1, 'Original Quote Line Group Does not exist');

        //Create Amendment-type opp/quote
        Opportunity amendmentOpp = OSCPQ_TestFactory.createSingleOpp(acct, true);
        SBQQ__Quote__c amendmentQuote = OSCPQ_TestFactory.createSingleQuote(acct, amendmentOpp, true, false);
        amendmentQuote.SBQQ__Type__c = 'Quote';
        SBQQ.TriggerControl.disable();
        Test.startTest();
        insert amendmentQuote;
        
        //Instantiate Quote Line
        SBQQ__QuoteLine__c childQL = OSCPQ_TestFactory.createSingleQuoteLine(amendmentQuote, childProd, false);
        SBQQ__QuoteLine__c parentQL = OSCPQ_TestFactory.createSingleQuoteLine(amendmentQuote, parentProd, false);
        for(SBQQ__Subscription__c sub : subList) {
            if(sub.SBQQ__ProductName__c == 'Simple Renewable Product 1') {
                childQL.SBQQ__UpgradedSubscription__c = sub.Id;
            }
            else {
                parentQL.SBQQ__UpgradedSubscription__c = sub.Id;
            }
        }

        parentQL.SBQQ__Number__c = 1;
        insert parentQL; //Insert first with a non-amendment/quote version
        childQL.SBQQ__Number__c = 2;
        childQL.SBQQ__RequiredBy__c = parentQL.Id;
        insert childQL;
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>{parentQL, childQL};

        amendmentQuote.SBQQ__Type__c = 'Renewal';
        update amendmentQuote;
        SBQQ.TriggerControl.enable();

 
        qlList = [SELECT Id, 
                  Name, 
                  SBQQ__Quote__r.Name, 
                  SBQQ__QuoteLine__c.CurrencyIsoCode, 
                  SBQQ__QuoteLine__c.SBQQ__NetTotal__c, 
                  SBQQ__QuoteLine__c.SBQQ__ProductName__c, 
                  SBQQ__Quote__r.SBQQ__Type__c, 
                  SBQQ__UpgradedSubscription__c, 
                  OSCPQ_Original_Quote_Line_Group_Id__c, 
                  SBQQ__Quote__c, 
                  SBQQ__Product__c, 
                  SBQQ__Group__c, 
                  SBQQ__RequiredBy__c, 
                  SBQQ__EffectiveStartDate__c, 
                  SBQQ__EffectiveEndDate__c, 
                  SBQQ__SubscriptionPricing__c, 
                  SBQQ__ProrateMultiplier__c,
                  Recurring_Rev_Product__c,
                  SBQQ__ProductFamily__c //Sergio 2/18/2019 W-001712
                  FROM SBQQ__QuoteLine__c WHERE Id IN :qlList];

        OSCPQ_QuoteLineTriggerHandler.firstRun = true;
        handler.onAfterInsert(qlList);
        Test.stopTest();

        List<SBQQ__QuoteLineGroup__c> newQLGList = [SELECT Id FROM SBQQ__QuoteLineGroup__c];
        system.assert(newQLGList.size() > origQLGList.size(), 'No new QLGs were created when they should have been');
        
    }

    /*
     * Tests a basic 3-year subscription schedule use case with no stub period and Annual Billing
     */
    @isTest
    static void simpleAnnualSubSchedule() {
        OSCPQ_QuoteLineTriggerHandler handler = new OSCPQ_QuoteLineTriggerHandler(false, 0, 'Default');
        handler.customSettings.Months_for_Stub_Sub_Schedule__c = 3.0;

        //Fetch Data from Setup
        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        List<SBQQ__Subscription__c> subList = [SELECT Id, OSCPQ_Quote_Line_Group_Id__c, SBQQ__ProductName__c FROM SBQQ__Subscription__c];
        
        Product2 testProd = [SELECT Id FROM Product2 WHERE Name = 'Simple Renewable Product 1'];
        Product2 explicitTermProd = [SELECT Id FROM Product2 WHERE Name = 'Simple Renewable Product 2'];

        List<SBQQ__QuoteLineGroup__c> origQLGList = [SELECT Id FROM SBQQ__QuoteLineGroup__c];
        system.assert(origQLGList.size() == 1, 'Original Quote Line Group Does not exist');

        //Create new opp/quote
        Opportunity testOpp = OSCPQ_TestFactory.createSingleOpp(acct, true);
        SBQQ__Quote__c testQuote = OSCPQ_TestFactory.createSingleQuote(acct, testOpp, true, false);
        testQuote.SBQQ__SubscriptionTerm__c = 36;
        testQuote.SBQQ__StartDate__c = Date.newInstance(2019, 1, 31);
        testQuote.SBQQ__Type__c = 'Quote';
        testQuote.SBQQ__BillingFrequency__c = 'Annual';
        SBQQ.TriggerControl.disable();
        insert testQuote;
        testQuote.SBQQ__SubscriptionTerm__c = 36;
        testQuote.SBQQ__StartDate__c = Date.newInstance(2019, 1, 31);
        update testQuote; //Need this b/c something is overwriting the term & date on creation
        
        Test.startTest();
        //Instantiate Quote Line
        SBQQ__QuoteLine__c QL = OSCPQ_TestFactory.createSingleQuoteLine(testQuote, testProd, false); //Same start/end as the quote
        QL.SBQQ__Number__c = 1; 
        QL.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        SBQQ__QuoteLine__c explicitQL = OSCPQ_TestFactory.createSingleQuoteLine(testQuote, explicitTermProd, false);
        explicitQL.SBQQ__Number__c = 2;
        explicitQL.SBQQ__StartDate__c = testQuote.SBQQ__StartDate__c;
        explicitQL.SBQQ__EndDate__c = Date.newInstance(2020, 1, 30); //1 year
        explicitQL.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        insert new List<SBQQ__QuoteLine__c>{QL, explicitQL};

        
        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>{QL, explicitQL};
 
        qlList = [SELECT Id, 
                  Name, 
                  SBQQ__QuoteLine__c.SBQQ__ProductName__c, 
                  SBQQ__QuoteLine__c.SBQQ__NetTotal__c, 
                  SBQQ__QuoteLine__c.CurrencyIsoCode, 
                  SBQQ__Quote__r.Name, 
                  SBQQ__Quote__r.SBQQ__Type__c, 
                  SBQQ__UpgradedSubscription__c, 
                  OSCPQ_Original_Quote_Line_Group_Id__c, 
                  SBQQ__Quote__c, 
                  SBQQ__Product__c, 
                  SBQQ__Group__c, 
                  SBQQ__RequiredBy__c, 
                  SBQQ__EffectiveStartDate__c, 
                  SBQQ__EffectiveEndDate__c, 
                  SBQQ__SubscriptionPricing__c, 
                  SBQQ__ProrateMultiplier__c,
                  Recurring_Rev_Product__c,
                  SBQQ__ProductFamily__c //Sergio 2/18/2019 W-001712
                  FROM SBQQ__QuoteLine__c WHERE Id IN :qlList];

        OSCPQ_QuoteLineTriggerHandler.firstRun = true;
        handler.customSettings.Months_for_Stub_Sub_Schedule__c = 3;
        handler.onAfterInsert(qlList);
        Test.stopTest();
        SBQQ.TriggerControl.enable();

        List<Quote_Subscription_Schedule__c> newQuoteBillSchList = [SELECT Id FROM Quote_Subscription_Schedule__c WHERE Quote__c = :testQuote.Id];
        system.assertEquals(3, newQuoteBillSchList.size(), 'Quote subscription schedules not created correctly');
        List<Line_Item_Subscription_Schedule__c> newQLSubSchList = [SELECT Id, External_Key__c FROM Line_Item_Subscription_Schedule__c WHERE Quote_Line__c IN :qlList];
        system.debug('line sub schs: ');
        system.debug(newQLSubSchList);
        system.assertEquals(4, newQLSubSchList.size(), 'Expecting 4 line-level schedules'); //Expecting 3 schedules for the first product, and 1 for the second
    }

    /*
     * Tests a basic 3-year subscription schedule use case with no stub period and Annual Billing
     */
    @isTest
    static void simpleUpfrontSubSchedule() {
        OSCPQ_QuoteLineTriggerHandler handler = new OSCPQ_QuoteLineTriggerHandler(false, 0, 'Default');
        handler.customSettings.Months_for_Stub_Sub_Schedule__c = 3.0;

        //Fetch Data from Setup
        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        List<SBQQ__Subscription__c> subList = [SELECT Id, OSCPQ_Quote_Line_Group_Id__c, SBQQ__ProductName__c FROM SBQQ__Subscription__c];
        
        Product2 testProd = [SELECT Id FROM Product2 WHERE Name = 'Simple Renewable Product 1'];
        Product2 explicitTermProd = [SELECT Id FROM Product2 WHERE Name = 'Simple Renewable Product 2'];

        List<SBQQ__QuoteLineGroup__c> origQLGList = [SELECT Id FROM SBQQ__QuoteLineGroup__c];
        system.assert(origQLGList.size() == 1, 'Original Quote Line Group Does not exist');

        //Create new opp/quote
        Opportunity testOpp = OSCPQ_TestFactory.createSingleOpp(acct, true);
        SBQQ__Quote__c testQuote = OSCPQ_TestFactory.createSingleQuote(acct, testOpp, true, false);
        testQuote.SBQQ__SubscriptionTerm__c = 36;
        testQuote.SBQQ__StartDate__c = Date.newInstance(2019, 1, 31);
        testQuote.SBQQ__Type__c = 'Quote';
        testQuote.SBQQ__BillingFrequency__c = 'Upfront';
        SBQQ.TriggerControl.disable();
        insert testQuote;
        testQuote.SBQQ__BillingFrequency__c = 'Upfront';
        update testQuote; //must do this b/c automation is overwriting this on insert.
        
        //Instantiate Quote Line
        SBQQ__QuoteLine__c QL = OSCPQ_TestFactory.createSingleQuoteLine(testQuote, testProd, false);
        QL.SBQQ__Number__c = 1;
        SBQQ__QuoteLine__c explicitQL = OSCPQ_TestFactory.createSingleQuoteLine(testQuote, explicitTermProd, false);
        explicitQL.SBQQ__Number__c = 2;
        explicitQL.SBQQ__StartDate__c = testQuote.SBQQ__StartDate__c;
        explicitQL.SBQQ__EndDate__c = Date.newInstance(2020, 1, 30);
        Test.startTest();
        insert new List<SBQQ__QuoteLine__c>{QL, explicitQL};

        List<SBQQ__QuoteLine__c> qlList = new List<SBQQ__QuoteLine__c>{QL, explicitQL};
 
        qlList = [SELECT Id, 
                  Name, 
                  SBQQ__QuoteLine__c.SBQQ__ProductName__c, 
                  SBQQ__QuoteLine__c.SBQQ__NetTotal__c, 
                  SBQQ__QuoteLine__c.CurrencyIsoCode, 
                  SBQQ__Quote__r.Name, 
                  SBQQ__Quote__r.SBQQ__Type__c, 
                  SBQQ__UpgradedSubscription__c, 
                  OSCPQ_Original_Quote_Line_Group_Id__c, 
                  SBQQ__Quote__c, SBQQ__Product__c, 
                  SBQQ__Group__c, 
                  SBQQ__RequiredBy__c, 
                  SBQQ__EffectiveStartDate__c, 
                  SBQQ__EffectiveEndDate__c,
                  SBQQ__SubscriptionPricing__c, 
                  SBQQ__ProrateMultiplier__c,
                  Recurring_Rev_Product__c,
                  SBQQ__ProductFamily__c //Sergio 2/18/2019 W-001712
                  FROM SBQQ__QuoteLine__c WHERE Id IN :qlList];
        SBQQ.TriggerControl.enable();
        
        OSCPQ_QuoteLineTriggerHandler.firstRun = true;
        handler.onAfterInsert(qlList);
        Test.stopTest();
        
        List<Quote_Subscription_Schedule__c> newQuoteBillSchList = [SELECT Id, External_Key__c  FROM Quote_Subscription_Schedule__c WHERE Quote__c = :testQuote.Id];
        system.assertEquals(1, newQuoteBillSchList.size(), 'Quote subscription schedules not created correctly');
        List<Line_Item_Subscription_Schedule__c> newQLSubSchList = [SELECT Id, External_Key__c FROM Line_Item_Subscription_Schedule__c WHERE Quote_Line__c IN :qlList];
        system.assertEquals(2, newQLSubSchList.size(), 'Expecting 2 line-level schedules'); //Expecting 1 schedule for each product

    }
}