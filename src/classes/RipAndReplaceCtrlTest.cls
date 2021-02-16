@isTest
private class RipAndReplaceCtrlTest {
    
    private static testMethod void validateRipAndReplace() {
        Opportunity opp1 = new opportunity();
        opp1.name = 'test1';
        opp1.CloseDate = system.today().addDays(5);
        opp1.StageName = '1 - Identification';
        opp1.type ='ECUR';
        insert opp1;
        
        Account acc = new Account();
        acc.Name = 'testAcc';
        insert acc;
        
        Opportunity opp = new opportunity();
        opp.name = 'test';
        opp.CloseDate = system.today().addDays(5);
        opp.StageName = '1 - Identification';
        insert opp;
        
        Contract cont = new Contract();
        cont.Name = 'testCon';
        cont.SBQQ__Opportunity__c  = opp.Id;
        cont.AccountId = acc.Id;
        //cont.enddate = system.today().addDays(8);
        cont.SBQQ__RenewalOpportunity__c = opp1.Id;
        
        insert cont;
            
		RipAndReplaceCtrl.createNewOpportunity(cont.Id,opp.Id);
    }
}