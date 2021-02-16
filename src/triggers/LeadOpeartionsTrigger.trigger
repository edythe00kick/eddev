trigger LeadOpeartionsTrigger on Lead (before insert, after insert, before update, after update) { //Sharma Nemani | PDG Workflow Rules | Added 'after insert' | 03/27/2019
    //TriggerFactory.createHandler(Lead.sObjectType);

    //Sergio Flores
    //Date: 07/04/2019
    //W-012144 
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.Lead_Trigger_Admin_Bypass__c == false)
    {
        system.debug('Inside Lead Trigger');
        
        LeadHandler handler = new LeadHandler(Trigger.isExecuting,Trigger.new);
        
        if (Trigger.isBefore) 
        {
            if (Trigger.isInsert) 
            {
                // Call class logic here!
                handler.onBeforeInsert(Trigger.new);
                system.debug('Inside before insert lead trigger');
            } 
            if (Trigger.isUpdate) 
            {
                // Call class logic here!
                handler.onBeforeUpdate(Trigger.new);
                system.debug('Inside before update lead trigger');
            }
            if (Trigger.isDelete) 
            {
                // Call class logic here!
            }
        }
        
        if (Trigger.IsAfter) 
        {
            if (Trigger.isInsert) 
            {
                // Call class logic here!
                handler.onAfterInsert(Trigger.new);
                system.debug('Inside after lead trigger');
            } 
            if (Trigger.isUpdate) 
            {
                // Call class logic here!
                handler.onAfterUpdate(Trigger.new);
                system.debug('Inside after update lead trigger');
            }
            if (Trigger.isDelete) 
            {
                // Call class logic here!
                handler.onAfterDelete(Trigger.old);
            }
        }

        handler.andFinally();
    }
}