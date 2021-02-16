trigger LicenseKeyTrigger on License_Key__c (before insert, before update, after insert, after update) {

    //Sergio Flores
    //Date: 07/04/2019
    //W-012144 
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.LicenseKey_Trigger_Admin_Bypass__c == false)
    {
        system.debug('Inside LicenseKey Trigger');
        
        LicenseKeyHandler handler = new LicenseKeyHandler(Trigger.isExecuting,Trigger.new);
        
        /*if (Trigger.isBefore) 
        {
            if (Trigger.isInsert) 
            {
                // Call class logic here!
            } 
            if (Trigger.isUpdate) 
            {
                // Call class logic here!
            }
            if (Trigger.isDelete) 
            {
                // Call class logic here!
            }
        }*/
        
        if (Trigger.IsAfter) 
        {
            if (Trigger.isInsert) 
            {
                // Call class logic here!
                handler.onAfterInsert(Trigger.new);
                system.debug('Inside after licensekey trigger');
            } 
            if (Trigger.isUpdate) 
            {
                // Call class logic here!
            }
            if (Trigger.isDelete) 
            {
                // Call class logic here!
            }
        }
    }

    

}