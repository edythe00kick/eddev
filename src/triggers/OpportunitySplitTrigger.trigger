/* Author: Sharma Nemani | W-013113 | Case: 00302043
   Date:11/12/2019
   Description: Trigger for Opportunity Split object.
*/ 
trigger OpportunitySplitTrigger on OpportunitySplit (before insert){
	
    //Sergio Flores
    //Date: 12/16/2019
    //W-013733
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.Opportunity_Split_Trigger_Admin_Bypass__c == false)
    {
        system.debug('inside opportunity split trigger');
        OpportunitySplitTriggerHandler oppSplitHandler = new OpportunitySplitTriggerHandler();

        if (Trigger.isBefore) 
        {
            if (Trigger.isInsert) 
            {
                oppSplitHandler.onBeforeInsert(trigger.new);
            }
        }       
    }
}