trigger ContactTriggers on Contact (before insert, before update, after insert, after update) {
    //TriggerFactory.createHandler(Contact.sObjectType);

    //Sergio Flores
    //Date: 12/17/2019
    //W-012144 
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.Contact_Trigger_Admin_Bypass__c == false)
    {
        system.debug('Inside Contact Trigger');
        
        ContactHandler handler = new ContactHandler(Trigger.isExecuting, Trigger.size,Trigger.new, Trigger.isInsert);
        
        if (Trigger.isBefore) 
        {
            if (Trigger.isInsert) 
            {
                // Call class logic here!
                handler.onBeforeInsert(Trigger.new, Trigger.oldMap); //Sharma Nemani | PDG Workflow Rules | Date: 03/27/2019 | Added "Trigger.oldMap"
            } 
            if (Trigger.isUpdate) 
            {
                // Call class logic here!
                handler.onBeforeUpdate(Trigger.new, Trigger.oldMap); //Sharma Nemani | PDG Workflow Rules | Date: 03/27/2019 | Added "Trigger.oldMap"
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
                handler.onAfterInsert(Trigger.new, Trigger.oldMap);
            } 
            if (Trigger.isUpdate) 
            {
                // Call class logic here!
                handler.onAfterUpdate(Trigger.new, Trigger.oldMap);
            }
            if (Trigger.isDelete) 
            {
                // Call class logic here!
            }
        }

        handler.andFinally();
    }

}