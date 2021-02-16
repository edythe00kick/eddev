/**
 * Created by csalgado on 6/7/2020.
 */

public with sharing class CoTermOppController {

    @AuraEnabled
    public static List<Contract> getContractList(Id oppId){
        System.debug('**CSALGADO** oppId: ' + oppId);
        List<Contract> returnContracts = new List<Contract>();
        Opportunity opp = [SELECT AccountId FROM Opportunity WHERE Id = :oppId LIMIT 1];
        System.debug('**CSALGADO** acctId: ' + opp.AccountId);

        if(opp != null && opp.AccountId != null){
            returnContracts = [SELECT Id, Name, Account_Name__c, ContractNumber, StartDate, EndDate FROM Contract WHERE AccountId = :opp.AccountId AND Status = 'Activated'];
        }

        return returnContracts;
    }

    @AuraEnabled
    public static List<Contract> searchContractList(String contractNumber){
        System.debug('**CSALGADO** contractNumber: ' + contractNumber);
        contractNumber = '%' + contractNumber + '%';
        List<Contract> returnContracts = [SELECT Id, Name, Account_Name__c, ContractNumber, StartDate, EndDate FROM Contract WHERE ContractNumber Like :contractNumber AND Status = 'Activated'];
        return returnContracts;
    }

    @AuraEnabled
    public static Boolean coTermOpp(Id oppId, Id contractId){
        System.debug('eddie inside coTermOpp' + oppId + '' + contractId);
        List<Amendment_API_Event__e> contAmendEvents = new List<Amendment_API_Event__e>();
        Boolean success = false;
        System.debug('eddie inside coTermOpp contAmendEvents' + contAmendEvents);

        Amendment_API_Event__e singleAmendEvent = new Amendment_API_Event__e(Opportunity_Id__c = oppId,Contract_Id__c = contractId);
        System.debug('eddie inside singleAmendEvent' + singleAmendEvent);
        contAmendEvents.add(singleAmendEvent);
        System.debug('eddie inside coTermOpp contAmendEvents' + contAmendEvents);

        Opportunity opp = new Opportunity(Id = oppId);
        opp.SBQQ__AmendedContract__c = contractId;
        //opp.SBQQ__Type__c = 'Amendment';
        //opp.Purchase_Type__c = 'Upsell Co-term';

        try{
            System.debug('eddie inside cotermopp update');
            update opp;
            success = true;
            System.debug('eddie inside cotermopp update contAmendEvents' + contAmendEvents);
            EventBus.publish(contAmendEvents); //EW || W-005162 || 07/14/2020 || Calling Platform Event for amendment

            //CPQ_ApiWrapper.amendContract(contractId);


        }
        catch(Exception e){
            system.debug('Error: ' + e);
        }
        return true;
    }
}