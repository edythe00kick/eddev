/**
 * Created by ewong on 2/9/2021.
 */

global with sharing class BatchGTMContractSubsACVRollUp implements Database.Batchable<sObject>, Database.Stateful {

    global BatchGTMContractSubsACVRollUp() {

    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        String query = ' SELECT Id,CurrencyIsoCode' +
                ' FROM Account' +
                ' WHERE Roll_Up_Update_Needed__c = true' +
                ' AND Account.LastModifiedDate = LAST_N_DAYS:7' +
                ' LIMIT 50000';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Account> accList) {

        //List<Account> acctsUpdateList = AccountUtilityClass.updateAccountActiveSubsACV(accList);

        List<Account> acctsUpdateList = new List<Account>();
        Map<Id, Account> acctIdToCurrencyMap = new Map<Id, Account>();
        Set<Id> acctIdSet = new Set<Id>();

        System.debug('check BatchGTMContractSubsACVRollUp accList = ' + accList);

        if(!accList.isEmpty()) {
            for(Account acc : accList) {
                acctIdToCurrencyMap.put(acc.Id, acc);
                acctIdSet.add(acc.Id);
            }
        }


        Map<Id, AggregateResult> accIdToContractSubACVTotalMap = new Map<Id, AggregateResult>([SELECT GTM_Account__c Id, SUM(SubscriptionACV__c) newSumSubsACVTotal,MAX(GTM_Account__r.GTM_Active_Subscription_ACV_Total__c) originalGTMActiveSubsACVTotal
                                                                                                FROM Contract
                                                                                                WHERE SubscriptionACV__c > 0
                                                                                                AND GTM_Account__c IN :acctIdSet
                                                                                                GROUP BY GTM_Account__c]);
                                                                                                //OR (GTM_Account__c = null AND Contract.Account.Go_To_Market_Account__c IN :acctIdSet)])

        System.debug('ed check accIdToContractSubACVTotalMap = ' + accIdToContractSubACVTotalMap);

        Map<Id, Decimal> accIdToConvertedActiveSubsACVMap = new Map<Id, Decimal>();
        Map<Id, Decimal> accIdToOriginalActiveSubsACVMap = new Map<Id, Decimal>();

        if(!accIdToContractSubACVTotalMap.isEmpty()) {
            for (Id id : accIdToContractSubACVTotalMap.keySet()) {
                System.debug('eddie inside accIdToContractSubACVTotalMap for loop');

                Decimal i = (Decimal)accIdToContractSubACVTotalMap.get(id).get('newSumSubsACVTotal')*UtilityClass.getConversionRates().get(acctIdToCurrencyMap.get(id).CurrencyIsoCode);
                Decimal j = (Decimal)accIdToContractSubACVTotalMap.get(id).get('originalGTMActiveSubsACVTotal');
                accIdToConvertedActiveSubsACVMap.put(id, i);
                accIdToOriginalActiveSubsACVMap.put(id, j);

                if(accIdToConvertedActiveSubsACVMap.get(id) != accIdToOriginalActiveSubsACVMap.get(id)) {
                    Account a = new Account();
                    a.Id = id;
                    a.GTM_Active_Subscription_ACV_Total__c = accIdToConvertedActiveSubsACVMap.get(id);
                    a.Roll_Up_Update_Needed__c = false;
                    acctsUpdateList.add(a);
                }

            }
        }

        if(!acctsUpdateList.isEmpty()) {
            try {
                System.debug('inside acctsUpdateList check = ' + acctsUpdateList);
                update acctsUpdateList;
            } catch (Exception e) {
                System.debug('inside acctsUpdateList catch exception = ');
                trigger.new[0].addError(e.getMessage());
            }
        }

    }

    global void finish(Database.BatchableContext bc) {

    }

}