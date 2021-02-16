/* Created By: Sharma Nemani | W-012241
 * Date: 06/14/2019
 * Description: This Test Class is for EchoSignAgreementHandler Class.
*/
@isTest
private class EchoSignAgreementHandlerTest {
    private static testMethod void TestEchoSignAgreementHandler() {
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
        opp1.Contract_Start_Date__c = system.today();
        opp1.Contract_End_Date__c = system.today().addDays(5);
        opp1.Term_In_Months__c = 4;
        insert opp1;
		
        Quote_Trigger_Custom_Settings__c cs = new Quote_Trigger_Custom_Settings__c();
        cs.QuoteHistoricImportActive__c = false;
        cs.Name ='QuoteHistoricImport';
        insert cs;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Opportunity2__c  = opp1.Id;
        quote.SBQQ__Account__c  = acc.Id;
        insert quote;
        
        echosign_dev1__SIGN_Agreement__c  agr = new echosign_dev1__SIGN_Agreement__c();
        agr.Name = 'test';
        agr.CPQ_Quote__c = quote.Id;
        agr.echosign_dev1__Status__c  = 'Out for Signature';
        
        insert agr;
        
        echosign_dev1__SIGN_Agreement__c agr1 = [select id,echosign_dev1__Status__c from echosign_dev1__SIGN_Agreement__c limit 1];
        agr1.echosign_dev1__Status__c = 'Signed';
        update agr1;
        
        system.assertEquals(true,[select Signed_Date_Time__c from SBQQ__Quote__c limit 1].Signed_Date_Time__c !=null);
        
        echosign_dev1__SIGN_Agreement__c agr2 = [select id,echosign_dev1__Status__c from echosign_dev1__SIGN_Agreement__c limit 1];
        agr2.echosign_dev1__Status__c = 'Waiting for Counter-Signature';
        update agr2;
        
    }
}