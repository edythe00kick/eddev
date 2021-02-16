/*
*Author:Chris Salgado
*Date:04/30/19
*Description:License Product Trigger
*/
trigger LicenseProductTrigger on License_Product__c(before insert, before update, after insert) {

    List<License_Product__c> trigger_value = !trigger.IsDelete ? trigger.new : trigger.old;
    LicenseProductHandler handler = new LicenseProductHandler(trigger.isExecuting, trigger.size, trigger_value);
    System.debug('**CSALGADO**: In License Product Trigger ' + trigger.size);
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            System.debug('**CSALGADO**: Before Insert Trigger ');
            handler.onBeforeInsert(trigger.new);
        } else if (Trigger.isUpdate) {
            System.debug('**CSALGADO**: Before Update Trigger ');
            handler.onBeforeUpdate(trigger.oldMap, trigger.newMap, trigger.new);
        } /*else if (Trigger.isDelete) {
            handler.beforeDelete();
        }*/ else {
            system.debug('Error!-triggerfail');
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            System.debug('**CSALGADO**: After Insert Trigger ');
            handler.onAfterInsert(trigger.newMap);
        } /*else if (Trigger.isUpdate) {
            handler.afterUpdate();
        } else if (Trigger.isDelete) {
            handler.afterDelete();
        } else if (Trigger.isUnDelete) {
            handler.afterUnDelete();
        }*/ else {
            system.debug('Error!-triggerfail');
        }
    } else {
        system.debug('Error!-triggerfail');
    }
}