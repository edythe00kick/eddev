/**
 * Created by csalgado on 2/13/2020.
 */

trigger UploadExternalImageTrigger on External_Image_URL__c (before insert, before update, after insert, after update) {
    ExternalImageURLHandler eiuHandler = new ExternalImageURLHandler();
    if(Trigger.isBefore) {
        //if (Trigger.isInsert) {}
        //if (Trigger.isUpdate) {}
    }
    if(Trigger.isAfter){
        //if (Trigger.isInsert) {}
        if (Trigger.isUpdate) {
            eiuHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}