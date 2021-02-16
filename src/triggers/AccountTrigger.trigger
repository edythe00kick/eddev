/*
 * Trigger Name - AccountTrigger.
 * Test Class Name - AccountTriggerTest.
 * 
 * %W% %E% Grazitti Team
 * Trigger for the Account object.
 */

/**
 * Trigger for the Account object.
 * 
 * @author Hemendra Singh Rajawat <hemendras@grazitti.com>
 * @since July 17, 2018
 */

trigger AccountTrigger on Account (before insert, before update, after update) {

    //Sergio Flores
    //Date: 12/17/2019
    //W-013755
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.Account_Trigger_Admin_Bypass__c == false)
    {
        system.debug('inside account trigger');
        AccountHandler handler 
            = new AccountHandler(Trigger.isExecuting, Trigger.size,Trigger.new);

        if (Trigger.isInsert && Trigger.isBefore) {
        handler.onBeforeInsert(Trigger.new); 
    
        } /*else if (Trigger.isInsert && Trigger.isAfter) {
        //handler.onAfterInsert(Trigger.newMap);

        }*/ else if (Trigger.isUpdate && Trigger.isBefore) {
            handler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);

        } else if (Trigger.isUpdate && Trigger.isAfter) {
            system.System.debug('Inside After update Trigger');
            handler.onAfterUpdate(Trigger.oldMap, Trigger.newMap);
            
        } /*else if (Trigger.isDelete && Trigger.isBefore) {
            //handler.onBeforeDelete(Trigger.oldMap);

        } else if (Trigger.isDelete && Trigger.isAfter) {
            //handler.onAfterDelete(Trigger.oldMap);

        } else if (Trigger.isUnDelete) {
            //handler.onUndelete(Trigger.new);
        }*/
    }
}