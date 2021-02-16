/* Author: Sharma Nemani | W-012607 | Case: 00289401
   Date: 07/25/2019
   Description: This is a Test Class for "QuoteLineNotAllowedToDelete" Controller Class.
*/
@isTest
private class QuoteLineNotAllowedToDeleteTest {
    static testMethod void testQuoteLineNotAllowedToDelete() {
        /*Account acc = new Account();
        Acc.name = 'testAcc';
        insert acc;
        
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        cont.StartDate = system.today();
        insert cont;
        
        Opportunity opp1 = new opportunity();
        opp1.AccountId = acc.Id;
        opp1.name = 'test1';
        opp1.CloseDate = system.today().addDays(5);
        opp1.StageName = '1 - Identification';
        opp1.type ='NB';
        insert opp1;
		
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c  = opp1.Id;
        quote.SBQQ__Account__c  = acc.Id;
        insert quote;
        
        Product2 renewableProd = OSCPQ_TestFactory.createBasicRenewableProduct(1, true);
		SBQQ__QuoteLineGroup__c qlGroup = OSCPQ_TestFactory.createSingleQuoteLineGroup(acc, quote, true);

        SBQQ__QuoteLine__c qLine= OSCPQ_TestFactory.createSingleQuoteLine(quote, renewableProd, false);
        qLine.SBQQ__Group__c = qlGroup.Id;
        insert qLine;*/
        
		ApexPages.StandardController controller = new ApexPages.StandardController(new SBQQ__QuoteLine__c());
        new QuoteLineNotAllowedToDelete(controller);
    }
}