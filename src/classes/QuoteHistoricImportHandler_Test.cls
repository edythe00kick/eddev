/*
 * Class Name - QuoteHistoricImportHandler_Test.
 * 
 * @author - Eddie Wong
 * Date - 6/11/2019
 * Purpose - This is the test class for "QuoteHistoricImportTrigger" trigger and the "QuoteHistoricImportHandler" handler.
 */

@isTest//(SeeAllData=true)
public class QuoteHistoricImportHandler_Test {

    @testSetup static void setup(){

    }
    
    /*static testMethod void testQuoteHistoricImportHandler(){
                //Insert AYX Org Toggle Record
        AYX_Org_Rules_Toggle__c ayxToggle = new AYX_Org_Rules_Toggle__c();
        ayxToggle.SetupOwnerId = userinfo.getProfileId();
        ayxToggle.QuoteHistoricImportTrigger_Active__c = true;
        insert ayxToggle;
        system.debug('**test** ayxToggle : ' + ayxToggle );
        
        Account account = (Account)SmartFactory.createSObject('Account');
        insert account;
        
        Contact contact = (Contact)SmartFactory.createSObject('Contact');
        contact.AccountId = account.Id;
        insert contact;
        
        Opportunity opp = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.AccountId = account.Id;
        insert opp;
        
        Apttus_Proposal__Proposal__c proposal = (Apttus_Proposal__Proposal__c)SmartFactory.createSObject('Apttus_Proposal__Proposal__c');
        proposal.Apttus_Proposal__Account__c = account.Id;
        proposal.Apttus_Proposal__Opportunity__c = opp.Id;
        insert proposal;
                
        Attachment attach = (Attachment)SmartFactory.createSObject('Attachment');
        attach.parentId = proposal.Id;
        insert attach;
        
        system.debug('**attach : '+ attach);
        
        SBQQ__Quote__c quote = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opp.Id;
        quote.OSCPQ_External_Id__c = proposal.Id;
        quote.Attachment_Migration__c = false;
        insert quote;

        integer totalCount = [Select Count() from Attachment where parentid =: proposal.Id];
        system.debug('**total for proposal count ' + totalCount);

        SBQQ__Quote__c q = [SELECT Id FROM SBQQ__Quote__c WHERE Id =: quote.Id];
        q.Attachment_Migration__c = True;

        //QuoteHistoricImportHandler handler = new QuoteHistoricImportHandler(True,1);
        
        Test.startTest();
        system.debug('**test** ayxToggle preupdate : ' + ayxToggle );

        update q;
        system.debug('**quote ' + quote);
        integer aCount = [Select Count() from Attachment where ParentId =: quote.Id];
        integer c = 1;
        system.assertequals(c,aCount);  
        Test.stopTest();
    }*/
}