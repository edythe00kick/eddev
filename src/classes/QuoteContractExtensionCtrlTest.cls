@isTest 
private class QuoteContractExtensionCtrlTest {
    static testMethod void validateHelloWorld() {
        Account acc = new Account();
        Acc.name = 'testAcc';
        
        insert acc;
        
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        cont.StartDate = system.today();
        //cont.EndDate = system.today().addDays(5);
        //
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
        
        Related_Contract__c  rc = new Related_Contract__c();
        rc.Contract__c  = cont.Id;
        rc.Opportunity__c  = quote.SBQQ__Opportunity2__c;
        rc.ExternalId__c = String.valueof(cont.Id)+String.valueof(quote.SBQQ__Opportunity2__c);
        insert rc;
        
        ApexPages.StandardController standardCTRL = new ApexPages.StandardController(quote);
        QuoteContractExtensionCtrl quoteCtrl = new QuoteContractExtensionCtrl(standardCTRL);
        QuoteContractExtensionCtrl.showContracts(quote.Id);
        QuoteContractExtensionCtrl.getContracts(quote.Name,new List<String>(),'');
        QuoteContractExtensionCtrl.getAccounts(acc.Name);
        QuoteContractExtensionCtrl.createJunctionObjectRecords(new List<String>{cont.Id},quote.Id);
        
        system.assertEquals(quote.SBQQ__Opportunity2__c, rc.Opportunity__c);
    }
}