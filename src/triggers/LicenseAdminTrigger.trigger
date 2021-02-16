/**
 * Created by ewong on 9/17/2020.
 */

trigger LicenseAdminTrigger on License_Administrator__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    List<License_Administrator__c> trigger_value = !trigger.IsDelete ? trigger.new : trigger.old;
    LicenseAdminHandler handler = new LicenseAdminHandler(trigger.isExecuting, trigger.size, trigger_value);
    System.debug('**Eddie**: In License Admin Trigger ' + trigger.size);
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            System.debug('**Eddie**: Before Insert Trigger ');
            //handler.onBeforeInsert(trigger.new);
        } else if (Trigger.isUpdate) {
            System.debug('**Eddie**: Before Update Trigger ');
            //handler.onBeforeUpdate(trigger.oldMap, trigger.newMap, trigger.new);
        } /*else if (Trigger.isDelete) {
            System.debug('**Eddie**: Before Delete Trigger ');
            //handler.beforeDelete();
        } */
        else {
            system.debug('Error!-triggerfail');
        }

    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            System.debug('**Eddie**: After Insert Trigger ');
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