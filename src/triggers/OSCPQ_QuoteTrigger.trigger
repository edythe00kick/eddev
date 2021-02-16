trigger OSCPQ_QuoteTrigger on SBQQ__Quote__c (before insert, before update, after insert, after update, after delete) {

    //Sergio Flores
    //Date: 07/04/2019
    //W-012144 
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.Quote_Trigger_Admin_Bypass__c == false)
    {
        OSCPQ_QuoteTriggerHandler handler = new OSCPQ_QuoteTriggerHandler(Trigger.isExecuting, Trigger.size, 'Default');
        
        if(Trigger.isBefore) {
            if(trigger.isInsert) {
                handler.onBeforeInsert(Trigger.new);
            }
            else if(trigger.isUpdate) {
                handler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
            }
        }
        else if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                //if(OSCPQ_QuoteTriggerHandler.firstRun == true) {
                    handler.onAfterInsert(Trigger.new);
                //}
            }
            else if(Trigger.isUpdate) {
            // if(OSCPQ_QuoteTriggerHandler.firstRun == true) {
                    handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
            // }
            }
        }
        
        handler.andFinally();
        OSCPQ_QuoteTriggerHandler.firstRun = false;
    }
     
}