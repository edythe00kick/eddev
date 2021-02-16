/**
 * Created by ewong on 7/8/2020.
 */

public with sharing class AmendContractHandler {
    public static void onAfterInsert(List<Amendment_API_Event__e> newTriggerAC) {
        System.debug('In AmendContractHandler');
        Set<Id> oppIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        Map<Id, Id> oppIdToContIdMap = new Map<Id, Id>();

        //** Main Loop **
        for(Amendment_API_Event__e ac : newTriggerAC) {
            System.debug('eddie inside ac.Opportunity_Id__c = ' + ac.Opportunity_Id__c);
            System.debug('eddie inside ac.Contract_Id__c = ' + ac.Contract_Id__c);

            if(ac.Opportunity_Id__c != null && ac.Contract_Id__c != null) {
                oppIdToContIdMap.put(ac.Opportunity_Id__c, ac.Contract_Id__c);
            }
            else {
                System.debug('Eddie - AmendContract Platform Event is empty!');
            }
        }

        System.debug('eddie inside oppIdToContIdMap = ' + oppIdToContIdMap );

        if(!oppIdToContIdMap.isEmpty()) {
            System.debug('eddie inside oppIdToContIdMap isemptycheck' + oppIdToContIdMap);
            AmendContractGateway.amendContractAPICall(oppIdToContIdMap);
        }
    }

}