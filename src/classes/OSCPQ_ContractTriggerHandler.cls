/*------------------------------------------------------------------------+
ORIGINAL SHIFT CONFIDENTIAL
__________________
Copyright (C) 2019 Original Shift, Inc.
All Rights Reserved.
NOTICE: All information contained herein is, and remains the
property of Original Shift Inc.The intellectual and technical
concepts contained herein are proprietary to Original Shift, Inc.
and may be covered by U.S. and Foreign Patents, patents in process,
and are protected by trade secret or copyright law.

Original Shift(developer@originalshift.com)
Purpose: Handles the CPQ Contract Trigger
 
Details: - Deforecasts Orphaned Renewal Opportunities
		 - Twin maps from the Quote/Opp/Order as Appropriate
 
History:
Feb 12/19 - Original Shift - Initial Implementation
------------------------------------------------------------------------+*/
public class OSCPQ_ContractTriggerHandler {
    @testVisible private CPQ_Setting__mdt settings; //Testvisible so that test classes can inject special settings.
    private Id cpqContractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();
    Set<Id> accountidSet = new Set<Id>();
    Set<Id> accountidSetForPartners = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();
    List<Account> acctsToUpdate = new List<Account>();

    /*
     * Constructor - takes a metadata record API name, so that
     *  more scenarios can be accomodated as needed in an implemenation.
     *  For example, Partner quotes may not have the same level of automation
     */
    public OSCPQ_ContractTriggerHandler(String settingsAPIName){
        if(settingsAPIName != null && settingsAPIName != ''){
            CPQ_Setting__mdt tmpSettings = OSCPQ_Utils.getContractSettings(settingsAPIName);
            if(tmpSettings != null){
                settings = tmpSettings;
            }
        }
        else{
            settings = OSCPQ_Utils.getContractSettings('Default');
        }
    }

    /*
     * Primary method; identifies which renewal Opps are orphaned by the fact that the co-term + renewal process
     * 		will point re-point the renewal opps of any non-master contracts over to the master
     */
    public void deforecastOrphanedOpps (List<Contract> updatedContractList, Map<Id, Contract> oldContractMap){
        //Only execute the function's logic if the settings are enabled
        if(settings.RenewCoTerm_DeforecastOrphans__c != 'No'){
            //Isolate only contracts that should have opportunities zero'd out (have had their renewal opp lookup changed)
            List<Contract> childContractsCoTermList = new List<Contract>();
            for(Contract c : updatedContractList){
                if(c.RecordTypeId == cpqContractRecordType &&
                        c.SBQQ__RenewalOpportunity__c != null &&
                        c.SBQQ__RenewalOpportunity__c != oldContractMap.get(c.Id).SBQQ__RenewalOpportunity__c &&
                        oldContractMap.get(c.Id).SBQQ__RenewalOpportunity__c != null){

                    childContractsCoTermList.add(c);
                }
            }

            //If there are non-master contracts being co-termed, then call the  deforecastOpps or deforecastOpps_future method as appropriate
            if(!childContractsCoTermList.isEmpty()){
                Set<Id> childContractsCoTermIds = (new Map<Id, Contract>(childContractsCoTermList)).keySet();
                if(!settings.RenewalCoTerm_DeforecastAsync__c){ //Synchronous
                    deforecastOpps(childContractsCoTermIds, settings.RenewCoTerm_DeforecastOrphans__c);
                }
                else{ //Async
                    deforecastOrphanedOpps_future(childContractsCoTermIds, settings.RenewCoTerm_DeforecastOrphans__c);
                }
            }
        }
    }

    @future
    private static void deforecastOrphanedOpps_future(Set<ID> contractIds, String DeforecastSettings){
        //First clear any opportunities that are forecast-only (no primary quotes)
        List<Opportunity> forecastOnlyOpportunitiesCleared = deforecastOpps(contractIds, DeforecastSettings);
    }

    /*
     * Primary helper function that does all the heavy lifting & DML operations
     */
    private static List<Opportunity> deforecastOpps(Set<Id> childContractsCoTermList, String DeforecastSettings){
        List<Opportunity> oppsToDeforecast = new List<Opportunity>();

        //Deforecast-only block
        if(DeforecastSettings == 'Deforecast'){
            oppsToDeforecast = [SELECT Id FROM Opportunity WHERE SBQQ__RenewedContract__c IN :childContractsCoTermList];
            List<OpportunityLineItem> lineItemsToDelete = [SELECT Id FROM OpportunityLineItem WHERE Opportunity.Id IN :oppsToDeforecast];
            List<SBQQ__Quote__c> quotesToUnprimary = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Primary__c = true AND SBQQ__Opportunity2__c IN :oppsToDeforecast];

            System.debug(lineItemsToDelete.size() + ' Opp Lines will be deleted');
            if(!lineItemsToDelete.isEmpty()){
                System.debug('Deleteing Lines: ' + lineItemsToDelete);
                Database.DeleteResult[] deleteList = Database.delete(lineItemsToDelete, false);
                System.debug(deleteList);
            }

            System.debug(quotesToUnprimary.size() + ' quotes will be unmarked as primary');
            if(!quotesToUnprimary.isEmpty()){
                for(SBQQ__Quote__c quote : quotesToUnprimary){
                    quote.SBQQ__Primary__c = false;
                }
                System.debug('Un-Primarying Lines: ' + lineItemsToDelete);
                SBQQ.TriggerControl.disable();
                try{
                    Database.SaveResult[] updateList = Database.update(quotesToUnprimary, false);
                    System.debug(updateList);
                }
                finally{
                    SBQQ.TriggerControl.enable();
                }
            }
        }
        //Deforecast+Delete block
        else if(DeforecastSettings == 'DeforecastAndDelete'){
            oppsToDeforecast = [SELECT Id FROM Opportunity WHERE SBQQ__RenewedContract__c IN :childContractsCoTermList];


            System.debug(oppsToDeforecast.size() + ' Opps will be deleted');
            if(!oppsToDeforecast.isEmpty()){
                System.debug('Deleteing Opps: ' + oppsToDeforecast);
                Database.DeleteResult[] deleteList = Database.delete(oppsToDeforecast, false);
                System.debug(deleteList);
            }

            //Package should handle deletion of Quotes when the Opp was deleted, but we'll make sure it's done
            List<SBQQ__Quote__c> quotesToDelete = [SELECT Id, SBQQ__Primary__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN :oppsToDeforecast];
            System.debug(quotesToDelete.size() + ' quotes will be deleted on top of what the CPQ managed package already did');
            if(!quotesToDelete.isEmpty()){
                System.debug('Deleteing Quotes: ' + quotesToDelete);
                Database.DeleteResult[] deleteList = Database.delete(quotesToDelete, false);
                System.debug(deleteList);
            }
        }

        return oppsToDeforecast;
    }

    /*
     * onBeforeInsert method. Used to twin map from the appropriate object
     */
    public void onBeforeInsert(List<Contract> newContractList) {
        List<Contract> contractsToTwinMapList = new List<Contract>();
        Set<Id> gtmAccountIdSet = new Set<Id>(); //Eddie Wong || 2/8/2021 || W-007098

        //** Main Loop **
        if(settings.TwinMapping_MapToContract__c != 'NEVER') {
            for(Contract newContract : newContractList) {
                newContract.Original_End_Date__c = newContract.EndDate; //Added by: Sharma Nemani | W-013108 | Date: 10/18/2019
                if(settings.TwinMapping_MapToContract__c == 'FROM_QUOTE' && newContract.SBQQ__Quote__c != null){
                    contractsToTwinMapList.add(newContract);
                }
                else if(settings.TwinMapping_MapToContract__c == 'FROM_OPP' && newContract.SBQQ__Opportunity__c != null){
                    contractsToTwinMapList.add(newContract);
                }
                else if(settings.TwinMapping_MapToContract__c == 'FROM_ORDER' && newContract.SBQQ__Order__c != null){
                    contractsToTwinMapList.add(newContract);
                }
            }

            //** Main Bulk Logic **
            if(!contractsToTwinMapList.isEmpty()) {
                if(settings.TwinMapping_MapToContract__c == 'FROM_QUOTE'){
                    OSCPQ_Utils.twinMapFieldsPull(contractsToTwinMapList, 'SBQQ__Quote__c', 'SBQQ__Quote__c', false);
                }
                else if(settings.TwinMapping_MapToContract__c == 'FROM_OPP'){
                    OSCPQ_Utils.twinMapFieldsPull(contractsToTwinMapList, 'Opportunity', 'SBQQ__Opportunity__c', false);
                }
                else if(settings.TwinMapping_MapToContract__c == 'FROM_ORDER'){
                    OSCPQ_Utils.twinMapFieldsPull(contractsToTwinMapList, 'Order', 'SBQQ__Order__c', false);
                }
            }
        }

        /* @Name Eddie Wong
        ** @Work W-007098
        ** @Date 2/5/2021
         */
        for(Contract con : newContractList) {

            if(con.SubscriptionACV__c != null && con.SubscriptionACV__c != 0 && con.AccountId != null) {
                gtmAccountIdSet.add(con.AccountId);
            }
        }

        System.debug('ed check RecursionHandler.IsGTMAccUpdateRollUpExecuted 0 ' + RecursionHandler.IsGTMAccUpdateRollUpExecuted);

        if(gtmAccountIdSet != null && RecursionHandler.IsGTMAccUpdateRollUpExecuted == false) {
            System.debug('inside gtmAccountIdset gateway call 1');
            OSCPQ_ContractTriggerGateway.updateRollUpNeededFieldInGTMAccountForNewContract(gtmAccountIdSet);
        }
    }

    /* @Name Eddie Wong
    ** @Work W-007098
    ** @Date 2/5/2021
     */
    public void onBeforeUpdate(map<Id, Contract> mapOld, map<Id, Contract> mapNew) {
        System.debug('inside contract trigger handler onBeforeUpdate mapnew = ' + mapNew);
        System.debug('inside contract trigger handler onbeforeupdate mapold = ' + mapOld);

        Set<Id> gtmAccountIdSet = new Set<Id>();
        Set<Id> masterAccountIdSet = new Set<Id>();

        for(Contract con : mapNew.Values()) {

            //If subscriptionACV changes and subscriptionsACV not null OR GTM Account lookup changes and GTM Account Lookup is not null -> Add to set for update
            if((mapNew.get(con.Id).SubscriptionACV__c != mapOld.get(con.Id).SubscriptionACV__c && mapNew.get(con.Id).GTM_Account__c != null) ||
                    (mapNew.get(con.Id).GTM_Account__c != null && mapNew.get(con.Id).GTM_Account__c != mapOld.get(con.Id).GTM_Account__c)) {
                gtmAccountIdSet.add(mapNew.get(con.Id).GTM_Account__c);
            } else if(mapNew.get(con.Id).SubscriptionACV__c != mapOld.get(con.Id).SubscriptionACV__c && mapNew.get(con.Id).GTM_Account__c == null && mapOld.get(con.Id).GTM_Account__c == null) {
                masterAccountIdSet.add(mapNew.get(con.Id).AccountId);
            }

        }

        if(gtmAccountIdSet != null) {
            System.debug('inside gtmAccountIdset gateway call 2');
            OSCPQ_ContractTriggerGateway.updateRollUpNeededFieldInGTMAccountForSubACVChange(gtmAccountIdSet);
        }

        System.debug('ed check RecursionHandler.IsGTMAccUpdateRollUpExecuted 1' + RecursionHandler.IsGTMAccUpdateRollUpExecuted);

        if(masterAccountIdSet != null && RecursionHandler.IsGTMAccUpdateRollUpExecuted == false) {
            System.debug('inside masterAccountIdSet gateway call');
            OSCPQ_ContractTriggerGateway.updateRollUpNeededFieldInGTMAccountForNewContract(masterAccountIdSet);
        }

    }

    /*Sergio Flores
    Date: 04/24/2019*/
    //Name: Chris Salgado Date: 5/31/2019
    public void onAfterInsert(List<Contract> newContractList) {

        Set<Id> quoteIds = new Set<Id>();
        Map<Id, Id> quoteToContractmap = new Map<Id,Id>();

        //** Main Loop **
        for(Contract c : newContractList)
        {
            //Need to get the quote that relates to this contract
            if(c.SBQQ__Quote__c !=null)
            {
                quoteIds.add(c.SBQQ__Quote__c);
                quoteToContractmap.put(c.SBQQ__Quote__c, c.Id);
            }

        }

        //** Main Bulk Logic **
        if(!quoteIds.isEmpty())
        {

            //Update Quotes with related Contract
            OSCPQ_ContractTriggerGateway.updateQuotes(quoteIds, quoteToContractmap);


            //Get quote subscription schedules
            List < Quote_Subscription_Schedule__c > subscriptionScheduleFromQuote = [Select Id, Quote__c, Proposal_Currency_ISO_Code__c, Subscription_End_Date__c, Subscription_Start_Date__c, Year__c, Net_Total__c
            From Quote_Subscription_Schedule__c
            Where Quote__c IN : quoteIds];

            system.debug('subscriptionScheduleFromQuote ' + subscriptionScheduleFromQuote);

            if(!subscriptionScheduleFromQuote.isEmpty())
            {
                OSCPQ_ContractTriggerGateway.insertBillingSchedules(subscriptionScheduleFromQuote, quoteToContractmap);
            }
        }

    }

    /*Sergio Flores
    Date: 04/24/2019*/
    //Name: Chris Salgado Date: 5/31/2019
    public void onAfterUpdate(List<Contract> newContractList) {

        Set<Id> quoteIds = new Set<Id>();
        Map<Id, Id> quoteToContractmap = new Map<Id,Id>();
        Set<Id> customerAccountsIds = new Set<Id>(); //Sergio Flores 06/17/2019 W-012214
        Set<Id> accountIdsForActiveContracts = new Set<Id>(); //Name: Chris Salgado Date: 05/15/20 Purpose: W-004795
        //Sergio Flores
        //Date: 06/17/2019
        //W-012251
        Set<Id> originalOppIds = new Set<Id>();
        Map<Id, Id> originalOppIdToNewOppId = new Map<Id, Id>();
        Map<Id, Contract> oppIdToContractMap = new Map<Id, Contract>();
        String futureECURAutomation = System.Label.FutureECUR_Automation;

        //** Main Loop **
        for (Contract contract : newContractList) {

            //Need to get the quote that relates to this contract
            if(contract.SBQQ__Quote__c !=null)
            {
                quoteIds.add(contract.SBQQ__Quote__c);
                quoteToContractmap.put(contract.SBQQ__Quote__c, contract.Id);
            }

            //Old Contract
            Contract oldContract = (Contract) Trigger.oldMap.get(contract.Id);
            system.debug('Inside after update contract ' + contract);
            if (contract.RecordTypeId == Label.StandardAlteryxAgreementRTId) {
                //agreementId2AccountId.put(ag.id,ag.Apttus__Account__c);
                system.debug('Accountid========>' + contract.AccountId);
                accountidSet.add(contract.AccountId);
            }

            system.debug('AccountIdSet=======>' + accountidSet);
            // New Record type for Agreements --> Partner Agreement Record
            // 22-7-2015
            if (contract.RecordTypeId == Label.ResellerAgreementRTId) {

                accountidSetForPartners.add(contract.AccountId);

            }


            if(futureECURAutomation == 'True')
            {
                //Sergio Flores
                //This looks super confusing, but what it does is checks Three things
                //1. Did Software Contract Value change?
                //2. Did Status Category Change?
                //3. Did Status Change?
                // In effect and activated must be met in all conditions
                if ( ( (contract.SubscriptionACV__c != oldContract.SubscriptionACV__c || (contract.EndDate != oldContract.EndDate && !Test.isRunningTest()))

                        && contract.Status_Category__c == 'In Effect'
                        && contract.Status == 'Activated')

                        ||

                        ((contract.Status_Category__c != oldContract.Status_Category__c  || contract.Status != oldContract.Status)
                                && ((contract.Status_Category__c == 'In Effect' && contract.Status == 'Activated')
                                || (oldContract.Status_Category__c == 'In Effect'  && oldContract.Status == 'Activated'))))
                {

                    accountIds.add(contract.AccountId);
                }
            }

            //Sergio Flores
            //Date: 06/17/2019
            //W-012214
            system.debug('outside of updating customer account' + contract);
            if( (contract.AccountId !=null && contract.Status == 'Activated' && oldContract.Status !='Activated' && contract.SBQQ__RenewalOpportunity__c == null) || (contract.Create_Renewal_Opportunity__c && contract.Status == 'Activated' && contract.SBQQ__RenewalOpportunity__c == null) )
            {
                system.debug('inside of updating customer account' + contract.AccountId);
                customerAccountsIds.add(contract.AccountId);

                //need to create map of orignialOpp To Contract
                oppIdToContractMap.put(contract.SBQQ__Opportunity__c, contract);
            }

            //Sergio Flores
            //Date: 06/17/2019
            //W-012251

            //Eddie Wong
            //Date: 06/03/2020, 6/16/2020
            //W-005562, W-005401
            //To exclude terminated contract from the logic below  || Modify the if condition to only account for Activated status
            //SF 09/23/2020 W-006386 adding Create Renewal Opportunity condition in the end to trigger this when the checkbox is checked
            if(contract.SBQQ__RenewalOpportunity__c != null && contract.SBQQ__Opportunity__c !=null &&  ( (Contract.Status == 'Activated' && oldContract.Status != 'Activated') || oldContract.Create_Renewal_Opportunity__c ) )
            {
                originalOppIds.add(contract.SBQQ__Opportunity__c);
                originalOppIdToNewOppId.put( contract.SBQQ__Opportunity__c, contract.SBQQ__RenewalOpportunity__c);
                system.debug('inside contract ' + originalOppIdToNewOppId);
            }

            //Name: Chris Salgado
            //Date: 05/15/20
            //Purpose: W-004795
            if(contract.Status == 'Activated' && ((contract.Status != oldContract.Status)
                    || (contract.EndDate != oldContract.EndDate)
                    || (contract.AccountId != oldContract.AccountId))){

                accountIdsForActiveContracts.add(contract.AccountId);

                if((contract.AccountId != oldContract.AccountId)){

                    accountIdsForActiveContracts.add(oldContract.AccountId);

                }
            }
        }

        //** Main Bulk Logic **

        //Execute the Future ECUR queueable job
        //Sergio Flores
        //Date: 10/09/2019
        //W-012796
        if(!oppIdToContractMap.isEmpty() && RecursionHandler.IsFutureECURQueueableExecuted == false)
        {
            System.debug('inside IsFutureECURQueueableExecuted queuable ' +oppIdToContractMap);
            RecursionHandler.IsFutureECURQueueableExecuted = true;
            FutureECURQueueable executeContactSLQTaskAndEmail = new FutureECURQueueable(oppIdToContractMap);
            ID jobID = System.enqueueJob(executeContactSLQTaskAndEmail);

        }

        if(!originalOppIds.isEmpty())
        {
            OSCPQ_ContractTriggerGateway.populatePartnerOnNewOpportunity(originalOppIds, originalOppIdToNewOppId);
        }

        if(!customerAccountsIds.isEmpty())
        {
            OSCPQ_ContractTriggerGateway.updateAccountToCustomer(customerAccountsIds);
        }

        if(!quoteIds.isEmpty())
        {
            //Update Quotes with related Contract
            OSCPQ_ContractTriggerGateway.updateQuotes(quoteIds, quoteToContractmap);
        }
        if (!accountIds.isEmpty())
        {
            //Update Accounts
            acctsToUpdate = OSCPQ_ContractTriggerGateway.updateAccounts(accountIds);
        }

        //Name: Chris Salgado
        //Date: 05/15/20
        //Purpose: W-004795
        if(!accountIdsForActiveContracts.isEmpty()){
            OSCPQ_ContractTriggerGateway.calculateAccountMaxContractEndDate(accountIdsForActiveContracts);
        }
    }

    /*Sergio Flores
    Date: 04/24/2019*/
    public void onAfterDelete(List<Contract> oldContractList) {

        //** Main Loop **
        for (Contract contract: oldContractList) {
            system.debug('Inside after update contract ' + contract);
            if (contract.RecordTypeId == Label.StandardAlteryxAgreementRTId) {
                //agreementId2AccountId.put(ag.id,ag.Apttus__Account__c);
                accountidSet.add(contract.AccountId);
            }
            // #W-009793 Added by Hemendra Singh Rajawat on July 11, 2018
            if (contract.Status_Category__c == 'In Effect'
                    && contract.Status == 'Activated') {

                accountIds.add(contract.AccountId);
            }
        }

        //** Main Bulk Logic **
        if (!accountIds.isEmpty()) {
            acctsToUpdate = OSCPQ_ContractTriggerGateway.updateAccounts(accountIds);
        }
    }

    public void andFinally() {
        system.debug('AccountIdSet=======>' + accountidSet);
        try {
            if (!acctsToUpdate.isEmpty()) {
                system.debug('inside updating account TCV from Contract');
                update acctsToUpdate;
            }


            if (!accountidSetForPartners.isempty()) {
                List < Account > acclistforPartners = OSCPQ_ContractTriggerGateway.updateMosteffectiveAgreementonAccount(accountidSetForPartners);
                system.debug('Accountstobeupdated=======>' + acclistforPartners);
                if (acclistforPartners != NULL) {
                    update acclistforPartners;
                }
            }
        } catch(Exception ex) {
            List<Contract> contracts
                    = (List<Contract>) (Trigger.isDelete
                            ? Trigger.old
                            : Trigger.new);

            for(Contract c : contracts) {
                Exception cause = ex.getCause();
                String msg = (cause != null)
                        ? cause.getMessage() : ex.getMessage();

                c.addError(msg);
            }
        }
    }
}