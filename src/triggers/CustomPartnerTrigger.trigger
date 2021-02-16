/*Author: Sergio Flores
*Date: 04/16/2019
*Description:Trigger to handle all custom partner events
*/
trigger CustomPartnerTrigger on Custom_Partner__c (after insert,after update,after delete) {
    
    CustomPartnerHandler customPartnerHandler = new CustomPartnerHandler();

    if (Trigger.isBefore) 
    {
        /*if (Trigger.isInsert) 
        {
            customPartnerHandler.onBeforeInsert(Trigger.new);
        } 
        else if (Trigger.isUpdate) 
        {
            customPartnerHandler.onBeforeUpdate(Trigger.new);
        } 
        else if (Trigger.isDelete) 
        {
            customPartnerHandler.onBeforeDelete();
        } 
        else 
        {
            system.debug('Error!- trigger fail');
        }*/
    } 
    else if (Trigger.isAfter) 
    {
        if (Trigger.isInsert) 
        {
            system.debug('inside after insert');
            customPartnerHandler.onAfterInsert(Trigger.new);
        } 
        else if (Trigger.isUpdate) 
        {
            customPartnerHandler.onAfterUpdate(Trigger.new);
        } 
        else if (Trigger.isDelete) 
        {
            customPartnerHandler.onAfterDelete(Trigger.old);
        } 
        /*else if (Trigger.isUnDelete) 
        {
            customPartnerHandler.onAfterUnDelete();
        } */
        else 
        {
            system.debug('Error!- trigger fail');
        }
    } 
    else 
    {
        system.debug('Error!- trigger fail');
    }

    //handle and Finally Operations
    customPartnerHandler.andFinally();

}