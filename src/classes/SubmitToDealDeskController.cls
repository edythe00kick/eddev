/**
 * Created by ewong on 4/1/2020.
 */

public with sharing class SubmitToDealDeskController {
@AuraEnabled
public static boolean updateQuoteOwnerToDD(String recordId){
    System.debug('inside updateQuoteOwnerToDD' + recordId);
    SBQQ__Quote__c quote = [Select Id,OwnerId from SBQQ__Quote__c where Id = :recordId];
    quote.OwnerId = '00GE0000003ZbIQ';

    update quote;
    System.debug('inside updateQuoteOwnerToDD' + quote);
    return true;
    }

}