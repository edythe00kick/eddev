/**
 * Created by chris on 12/29/2019.
 */

trigger AQITrigger on aqi_ltng_mng__Article_Quality__c (after insert, after update) {
    AQIHandler triggerHandler = new AQIHandler();
    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
            triggerHandler.afterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            triggerHandler.afterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}