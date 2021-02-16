/*
*Author: Sergio Flores
*Date: 01/22/2020
*/
trigger SubscriptionsTrigger on SBQQ__Subscription__c (before insert, before update, after insert, after update) {


    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.Subscription_Trigger_Admin_Bypass__c == false)
    {
        system.debug('inside Subscription trigger');
        SubscriptionHandler subHandler = new SubscriptionHandler();

        if (Trigger.isBefore)
        {
            if (Trigger.isInsert)
            {
                system.debug('inside before insert');
                subHandler.onBeforeInsert(Trigger.new);
            }/*
            else if (Trigger.isUpdate)
            {
                system.debug('inside before update');
                subHandler.onBeforeUpdate(Trigger.new);
            }
            else if (Trigger.isDelete)
            {
                subHandler.onBeforeDelete();
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
                subHandler.onAfterInsert(Trigger.new);
            }
            /*else if (Trigger.isUpdate)
            {
                subHandler.onAfterUpdate(Trigger.new);
            }
            else if (Trigger.isDelete)
            {
                subHandler.onAfterDelete();
            }
            else if (Trigger.isUnDelete)
            {
                subHandler.onAfterUnDelete();
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
        subHandler.andFinally();
    }


}