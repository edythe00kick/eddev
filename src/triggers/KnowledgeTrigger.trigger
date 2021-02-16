/**
 * Created by csalgado on 12/18/2019.
 */

trigger KnowledgeTrigger on Knowledge__kav (before insert, before update, after insert, after update) {
    KnowledgeHandler kavHandler = new KnowledgeHandler();
    if(Trigger.isBefore) {
        if (Trigger.isInsert) {
            kavHandler.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            kavHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            //kavHandler.onBeforeDelete(Trigger.old);
        }
    }

    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
            kavHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            kavHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            //kavHandler.onAfterDelete(Trigger.old);
        }
        if (Trigger.isUndelete) {
            //kavHandler.onAfterUnDelete(Trigger.new);
        }
    }
}