/* Created By: Sharma Nemani | W-012241
 * Date: 06/13/2019
 * Description: This trigger uses EchoSignAgreementHandler Class. 
 * This trigger is created to update parent Quote's status as per Child Object 
 * echosign_dev1__SIGN_Agreement__c's status.
*/ 
trigger EchoSignAgreementTrigger on echosign_dev1__SIGN_Agreement__c (after insert,after update) {
    EchoSignAgreementHandler.afterUpdateInsert(trigger.newMap,trigger.oldMap,trigger.isInsert);
}