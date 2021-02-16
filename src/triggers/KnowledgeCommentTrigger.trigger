/**
 * Created by csalgado on 12/19/2019.
 */

trigger KnowledgeCommentTrigger on Knowledge_Comment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    KnowledgeCommentHandler kcHandler = new KnowledgeCommentHandler();
    if(Trigger.isBefore) {
        if (Trigger.isInsert) {
            //kcHandler.onBeforeInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            //kcHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            //kcHandler.onBeforeDelete(Trigger.old);
        }
    }

    if(Trigger.isAfter) {
        if (Trigger.isInsert) {
            kcHandler.onAfterInsert(Trigger.new);
        }
        if (Trigger.isUpdate) {
            kcHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
        if (Trigger.isDelete) {
            //kcHandler.onAfterDelete(Trigger.old);
        }
        if (Trigger.isUndelete) {
            //kcHandler.onAfterUnDelete(Trigger.new);
        }
    }
}