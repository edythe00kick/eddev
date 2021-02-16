trigger OSCPQ_ContractTrigger on Contract (before insert, after insert, after update, after delete, before update) {

    //Sergio Flores
    //Date: 07/04/2019
    //W-012144 
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.Contract_Trigger_Admin_Bypass__c == false)
    {
        OSCPQ_ContractTriggerHandler contractHandler = new OSCPQ_ContractTriggerHandler('');

        if(Trigger.isBefore) {
            if(Trigger.isInsert) {
                (new OSCPQ_ContractTriggerHandler('Default')).onBeforeInsert(Trigger.New);
            }
            else if(Trigger.isUpdate) {
                System.debug('Inside before update contract trigger');
                contractHandler.onBeforeUpdate(Trigger.oldMap, Trigger.newMap);
            }
        }
        else if(Trigger.isAfter) {
            if(Trigger.isInsert)
            {
                system.debug('Inside after insert contract trigger');
                contractHandler.onAfterInsert(Trigger.New);
            }
            else if(Trigger.isUpdate) { 
                system.debug('Inside after update contract trigger');
                (new OSCPQ_ContractTriggerHandler('Default')).deforecastOrphanedOpps(Trigger.New, Trigger.OldMap);
                contractHandler.onAfterUpdate(Trigger.New);
                
                // Added by: Sharma Nemani | W-011617
                // Date: 07/01/2019
                List<Related_Contract__c> lstRC = [select id from Related_Contract__c where Contract__c IN: trigger.NewMap.keyset()];
                update lstRC;
            }
            else if (Trigger.isDelete) 
            {
                system.debug('Inside after delete contract trigger');
                contractHandler.onAfterDelete(Trigger.Old);
            } 
        }

        contractHandler.andFinally();
    }

    
}