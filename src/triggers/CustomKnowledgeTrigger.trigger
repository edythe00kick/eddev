/**
 * Created by csalgado on 12/19/2019.
 */

trigger CustomKnowledgeTrigger on Custom_Knowledge_Article__c (after insert, after update, after delete, after undelete) {
    CustomKnowledgeHandler ckaHandler = new CustomKnowledgeHandler();
    if(Trigger.isBefore) {
        if (Trigger.isInsert) {
            //ckaHandler.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            //ckaHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            //ckaHandler.onBeforeDelete(Trigger.old);
        }
    }

    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
           ckaHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            ckaHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            //ckaHandler.onAfterDelete(Trigger.old);
        }
        if (Trigger.isUndelete) {
            //ckaHandler.onAfterUnDelete(Trigger.new);
        }
    }
}