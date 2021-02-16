trigger MDFTrigger on MDF__c (after insert, after update, after delete, after undelete) {
    if(Trigger.isAfter && (wi.WiExternalUtility.isObjectIntegrationActive('MDF__c') || Test.isRunningTest())) {
        if(Trigger.isInsert) {
            WiCustomObjectTriggerHelper.onAfterInsert();
        } else if(Trigger.isUpdate) {
            WiCustomObjectTriggerHelper.onAfterUpdate();
        } else if(Trigger.isDelete) {
            WiCustomObjectTriggerHelper.onAfterDelete();
        } else if(Trigger.isUndelete) {
            WiCustomObjectTriggerHelper.onAfterUndelete();
        }
    }
}