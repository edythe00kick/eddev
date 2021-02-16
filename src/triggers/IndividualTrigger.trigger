trigger IndividualTrigger on Individual (before insert, before update, after insert, after update, after delete) {

    //Sergio Flores
    //Date: 09/05/2019
    //W-011320
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.Individual_Trigger_Admin_Bypass__c == false)
    {
        IndividualHandler handler = new IndividualHandler(Trigger.isExecuting); 
        
        if(Trigger.isBefore) {
            if(trigger.isInsert) {
                system.debug('inside before insert individual trigger');
                handler.onBeforeInsert(Trigger.new);
            }
            else if(trigger.isUpdate) {
                system.debug('inside before update individual trigger');
                handler.onBeforeUpdate(Trigger.new);
            }
        }
        /*else if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                  	handler.onAfterInsert(Trigger.new);
            }
            else if(Trigger.isUpdate) {
                	handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
             }
            }
        }*/
    }
     
}