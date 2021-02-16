/**
 * Created by ewong on 6/25/2020.
 * Eddie Wong
 * 07/07/2020
 * W-004987
 * Test Class - DellBoomiTest
 */

trigger LicenseProductUpdateTrigger on License_Product_Update__c (before insert, before update, after insert) {

    List<License_Product_Update__c> trigger_value = !trigger.IsDelete ? trigger.new : trigger.old;
    LicenseProductUpdateHandler handler = new LicenseProductUpdateHandler(trigger.isExecuting, trigger.size, trigger_value);
    System.debug('**Eddie**: In License Product Update Trigger ' + trigger.size);
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            System.debug('**Eddie**: Before Insert Trigger ');
            //handler.onBeforeInsert(trigger.new);
        } else if (Trigger.isUpdate) {
            System.debug('**Eddie**: Before Update Trigger ');
            handler.onBeforeUpdate(trigger.oldMap, trigger.newMap, trigger.new);
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