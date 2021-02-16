/*
 * Class Name - ContractHistoricImportHandler_Test.
 *
 * @author - Eddie Wong
 * Date - 6/19/2019
 * Purpose - This is the test class for "ContractHistoricImportTrigger" trigger and the "ContractHistoricImportHandler" handler.
 */

@isTest //(SeeAllData=true)
public class ContractHistoricImportHandler_Test {

    static testMethod void testContractHistoricImportHandler(){
        //Insert AYX Org Toggle Record
        AYX_Org_Rules_Toggle__c ayxToggle = new AYX_Org_Rules_Toggle__c();
        ayxToggle.SetupOwnerId = userinfo.getProfileId();
        ayxToggle.ContractHistoricImportTrigger_Active__c = true;
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

        Apttus__APTS_Agreement__c agreement = (Apttus__APTS_Agreement__c)SmartFactory.createSObject('Apttus__APTS_Agreement__c');
        agreement.Apttus__Related_Opportunity__c = opp.Id;
        agreement.Apttus__Account__c = account.Id;
        insert agreement;


        Attachment attach = (Attachment)SmartFactory.createSObject('Attachment');
        attach.parentId = agreement.Id;
        insert attach;

        Contract contract = (Contract)SmartFactory.createSObject('Contract');
        contract.AccountId = account.Id;
        contract.SBQQ__Opportunity__c = opp.Id;
        contract.OSCPQ_External_Id__c = agreement.Id;
        contract.Attachment_Migration__c = false;
        contract.Status = 'Draft';
        insert contract;


        contract lContract = [Select Id, Attachment_Migration__c from contract where Id = :contract.Id];
        lContract.Attachment_Migration__c = True;

        system.debug('Eddie ' + lContract);
        //QuoteHistoricImportHandler handler = new QuoteHistoricImportHandler(True,1);

        Test.startTest();
        update lContract;
        integer aCount = [Select Count() from Attachment where ParentId = :contract.Id];
        integer c = 1;
        system.assertequals(c,aCount);
        Test.stopTest();
    }
}