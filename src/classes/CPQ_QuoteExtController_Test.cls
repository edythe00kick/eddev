@isTest
private class CPQ_QuoteExtController_Test{
    
    testMethod static void testSubmit() {
        //Name: Chris Salgado Date: 10/22/19 Purpose: W-013442
        Contact billContact = new Contact
                (
                FirstName = 'Bill',
                LastName = 'Test',
                Email = 'bill@test.com',
                Phone = '123-456-7890'
                );
        insert billContact;

        SBQQ__Quote__c quote = new SBQQ__Quote__c
                (
                MLA_Option__c = 'MLA',
                MLA_Effective_Date__c = Date.today(),
                PaymentMethod__c = 'Credit Card',
                Billing_Contact__c = billContact.Id
                );
        insert quote;

        Product2 prod = OSCPQ_TestFactory.createBasicRenewableProduct(1, true);
        SBQQ__QuoteLine__c qLine = OSCPQ_TestFactory.createSingleQuoteLine(quote, prod, true);
        
        Test.startTest();
        CPQ_QuoteExtController con = new CPQ_QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmit();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Approved', quote.ApprovalStatus__c);
    }
    
    testMethod static void testRecall() {
        //Name: Chris Salgado Date: 10/22/19 Purpose: W-013442
        //User u = OSCPQ_TestFactory.createSingleUser('Tester', 'Mc', true);
        Account acct = OSCPQ_TestFactory.createSingleAccount(true);
        Opportunity opp = OSCPQ_TestFactory.createSingleOpp(acct, true);
        SBQQ__Quote__c quote = OSCPQ_TestFactory.createSingleQuote(acct, opp, true, false);
        //SBQQ__Quote__c quote = new SBQQ__Quote__c();
        //quote.ownerId = u.Id;
        //quote.SBQQ__SalesRep__c = u.Id;
        quote.Quote_Type__c = 'Purchase';
        quote.Quote_Has_Had_Approvals__c = false;
        SBQQ.TriggerControl.disable();
        insert quote;
        
        Test.startTest();
        CPQ_QuoteExtController con = new CPQ_QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecall();
        SBQQ.TriggerControl.enable();
        Test.stopTest();
        quote = [SELECT ApprovalStatus__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        System.assertEquals('Recalled', quote.ApprovalStatus__c);
    }
    
    testMethod static void testOnSubmitToDD() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        
        insert quote;
        
        Test.startTest();
        CPQ_QuoteExtController con = new CPQ_QuoteExtController(new ApexPages.StandardController(quote));
        con.onSubmitToDD();
        quote = [SELECT SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Deal Desk Review', quote.SBQQ__Status__c);
    }
    
    testMethod static void testOnRecallFromDD() {
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        insert quote;
        
        Test.startTest();
        CPQ_QuoteExtController con = new CPQ_QuoteExtController(new ApexPages.StandardController(quote));
        con.onRecallFromDD();
        quote = [SELECT SBQQ__Status__c FROM SBQQ__Quote__c WHERE Id = :quote.Id LIMIT 1];
        Test.stopTest();
        
        System.assertEquals('Draft', quote.SBQQ__Status__c);
    }
}