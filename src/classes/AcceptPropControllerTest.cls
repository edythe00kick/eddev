/* Created By: Sharma Nemani
 * Date: 06/24/2019
 * Description: This Test Class is for AcceptPropController Class.
*/

@isTest
private class AcceptPropControllerTest {
    
    private static testMethod void testAcceptPropController() {
        Account acc = new Account();
        Acc.name = 'testAcc';
        Acc.ShippingCountry = 'Germany';
        Acc.ShippingCity = 'Frankfurt';
        Acc.ShippingState = 'Hamburg';
        Acc.ShippingPostalCode = '60306';
        insert Acc;
        
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        cont.StartDate = system.today();
        insert cont;
        
        Opportunity opp1 = new opportunity();
        opp1.AccountId = acc.Id;
        opp1.name = 'test1';
        opp1.CloseDate = system.today().addDays(5);
        opp1.StageName = '3 - Negotiate';//1 - Identification
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
        quote.Quote_Type__c = 'Purchase';
        insert quote;
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = acc.Id;
        insert con;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opp1.Id;
        ocr.ContactId = con.Id;
        ocr.IsPrimary = true;
        insert ocr;

        test.startTest();
        
        ApexPages.StandardController controller = new ApexPages.StandardController(quote);
        ApexPages.currentPage().getParameters().put('id',quote.Id);
        AcceptPropController acp = new AcceptPropController(controller);
        
        acp.nextButton();
        acp.acceptProposal();
        acp.returnToProposal();
        test.stopTest();
    }
    private static testMethod void testAcceptPropController1() {
        Account acc = new Account();
        Acc.name = 'testAcc';
        insert Acc;
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        cont.StartDate = system.today();
        insert cont;
        
        Opportunity opp1 = new opportunity();
        opp1.AccountId = acc.Id;
        opp1.name = 'test1';
        opp1.CloseDate = system.today().addDays(5);
        opp1.StageName = '3 - Negotiate';//1 - Identification
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
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = acc.Id;
        insert con;
        
        test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(quote);
            ApexPages.currentPage().getParameters().put('id',quote.Id);
            AcceptPropController acp = new AcceptPropController(controller);
            
            acp.nextButton();
            acp.acceptProposal();
            acp.errorFinish();
            acp.returnToProposal();
        test.stopTest();
        
    }
    private static testMethod void testAcceptPropController2() {
        Account acc = new Account();
        Acc.name = 'testAcc';
        insert Acc;
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        cont.StartDate = system.today();
        insert cont;
        
        Opportunity opp1 = new opportunity();
        opp1.AccountId = acc.Id;
        opp1.name = 'test1';
        opp1.CloseDate = system.today().addDays(5);
        opp1.StageName = '3 - Negotiate';//1 - Identification
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
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = acc.Id;
        insert con;
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opp1.Id;
        ocr.ContactId = con.Id;
        ocr.IsPrimary = true;
        insert ocr;
        
        test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(quote);
            ApexPages.currentPage().getParameters().put('id',quote.Id);
            AcceptPropController acp = new AcceptPropController(controller);
            acp.nextButton();
            acp.acceptProposal();
            acp.errorFinish();
            acp.returnToProposal();
        test.stopTest();
        
    }
    private static testMethod void testAcceptPropController3() {
        Account acc = new Account();
        Acc.name = 'testAcc';
        insert Acc;
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
        
        Contact con = new Contact();
        con.LastName = 'test';
        con.AccountId = acc.Id;
        insert con;
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = opp1.Id;
        ocr.ContactId = con.Id;
        ocr.IsPrimary = true;
        insert ocr;
        
        test.startTest();
            ApexPages.StandardController controller = new ApexPages.StandardController(quote);
            ApexPages.currentPage().getParameters().put('id',quote.Id);
            AcceptPropController acp = new AcceptPropController(controller);
            acp.nextButton();
            acp.acceptProposal();
            acp.errorFinish();
            acp.returnToProposal();
        test.stopTest();
    }

    private static testMethod void testUtilityPropSettings() {
        Proposal_Settings__mdt propSetting = new Proposal_Settings__mdt();
        propSetting = UtilityClass.getProposalSettings('Settings');
    }
}