/**
 * Created by ewong on 4/14/2020.
 */

public with sharing class RecallApprovalController {
@AuraEnabled
    public static boolean updateRecallQuoteApproval(String recordId){
        System.debug('eddie inside updateRecallQuoteApproval');
        SBAA.ApprovalAPI.recall(recordId, SBAA__Approval__c.Quote__c);
        update new SBQQ__Quote__c(Id = recordId, Locked_For_Reps__c = false);

        return true;
    }

}