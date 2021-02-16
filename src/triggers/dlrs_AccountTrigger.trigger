/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_AccountTrigger on Account
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    //Sergio Flores
    //Date: 12/17/2019
    //W-013755
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.DLRS_Account_Trigger_Admin_Bypass__c == false)
    {
        dlrs.RollupService.triggerHandler();
    }
}