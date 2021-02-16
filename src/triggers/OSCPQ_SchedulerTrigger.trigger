trigger OSCPQ_SchedulerTrigger on OSCPQ_Scheduler__c (before insert, before update, before delete) {
    if(Trigger.isBefore){
        if(Trigger.isInsert){
            OSCPQ_SchedulerTriggerHandler.beforeInsert(Trigger.new);
        }
        else if(Trigger.isUpdate){
            OSCPQ_SchedulerTriggerHandler.beforeUpdate(Trigger.new);
        }
        else if(Trigger.isDelete){
            OSCPQ_SchedulerTriggerHandler.beforeDelete(Trigger.Old);
        }
    }
}