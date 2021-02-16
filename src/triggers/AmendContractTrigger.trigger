/**
* @author Eddie Wong
* @description CPQ contract amendment platform event trigger
* @date 07/08/2020
 */


trigger AmendContractTrigger on Amendment_API_Event__e (after insert) {

    System.debug('In AmendContractTrigger');

    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            AmendContractHandler.onAfterInsert(Trigger.new);
        }
    }
}