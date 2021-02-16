@isTest
public class FutureECURQueueableTest {


    //Author: Sergio Flores
    //Date: 06/28/2019
    //Testing creation of opp , quote, order, contract -> contract activation
    static testMethod void testFutureECURCreation()
    {
        Id pricebookId = Test.getStandardPricebookId();
        pw_ccpro__CountryObject__c billToCountry = OrgWideTestUtil.createCountryCurrency(true, pricebookId);

        //Create standard product
        Product2 prod = OrgWideTestUtil.createProduct(false);
        prod.ProductCode = '0101';
        prod.Family = 'Alteryx Software';
        prod.Licensing_System__c = 'Flexera';
        prod.Type_of_Revenue__c = 'Recurring';
        prod.SBQQ__SubscriptionPricing__c = 'Fixed Price';
        prod.SBQQ__SubscriptionTerm__c = 12;
        prod.SBQQ__SubscriptionType__c = 'Renewable';
        insert prod;

        //Insert basic product
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

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp.Id, acc.Id);
        quote.SBQQ__PriceBook__c = pricebookId;
        insert quote;

        SBQQ__QuoteLine__c qli = OrgWideTestUtil.createQuoteLineItem(false , prod.Id, quote.Id);
        String strId = Id.valueOf(pbe.Id);
        qli.SBQQ__PricebookEntryId__c = strId;
        qli.SBQQ__ProductOption__c = prodOption.Id;
        insert qli;

        test.startTest();

        quote.SBQQ__Status__c = 'Accepted';
        update quote;

        //Find the order of the opp recently closed won and activate it
        Id orderId = [Select Id From Order Where OpportunityId =: opp.Id].Id;
        Order order = new Order();
        order.Id = orderId;
        order.Status = 'Activated';
        order.ActivatedDate = system.today();
        order.ActivatedById = '00544000009EgNb';
        order.StatusCode = 'Activated';
        update order;

        List<OrderItem> orderItems = [Select Id, SBQQ__Activated__c, SBQQ__Status__c, SBQQ__Contracted__c From OrderItem Where OrderId =: orderId];

        for(OrderItem oi : orderItems)
        {
            oi.SBQQ__Activated__c = true;
            oi.SBQQ__Status__c = 'Activated';
        }

        update orderItems;

        Order order2 = [Select Id From Order Where Id =: order.Id];
        order2.SBQQ__Contracted__c = true;
        update order2;

        test.stopTest();

        Id contactId = [Select Id From Contract limit 1].Id;


    }


}