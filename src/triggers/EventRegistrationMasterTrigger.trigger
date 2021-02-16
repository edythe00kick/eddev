/**
***    @description:    Master Trigger for sObject.
***    @author:         JP Horton (jhorton@alteryx.com)
***    @createdDate     December 1, 2017
**/
trigger EventRegistrationMasterTrigger on Event_Registration__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
//
// If you are choosing to handle the triggers on a given object, then you need to setup a trigger handler on that object
// and then call the methods that you want to handle the trigger.
//
    EventRegistrationTriggerHandler handler = new EventRegistrationTriggerHandler(trigger.isExecuting, trigger.size); 
//
// Determine the type of trigger received and call the trigger handler
//
    if(trigger.isInsert && trigger.isBefore) {
        handler.OnBeforeInsert(trigger.new); 
    } else if(trigger.isInsert && trigger.isAfter) {
        handler.OnAfterInsert(trigger.newMap);
    } /*else if(trigger.isUpdate && trigger.isBefore) {
        handler.OnBeforeUpdate(trigger.oldMap, trigger.newMap);
    } else if(trigger.isUpdate && trigger.isAfter) {
        handler.OnAfterUpdate(trigger.oldMap, trigger.newMap);
    } else if(trigger.isDelete && trigger.isBefore) {
        handler.OnBeforeDelete(trigger.oldMap);
    } else if(trigger.isDelete && trigger.isAfter) {
        handler.OnAfterDelete(trigger.oldMap);
    } else if(trigger.isUnDelete) {
        handler.OnUndelete(trigger.new);
    }*/
}