/*
*Author: Sergio Flores
*Date: 04/16/2019
*Description:Trigger to handle all opportunity events
*/
trigger OpportunityTrigger on Opportunity (before insert, before update, after insert, after update) {

    //Sergio Flores
    //Date: 07/04/2019
    //W-012144 
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    System.debug('eddie check recursion handler in opptrigger' + Recursionhandler.IsContractAmendExecuted);
    
    if(alteryxToggleCS.Opportunity_Trigger_Admin_Bypass__c == false) {
        if (Recursionhandler.IsContractAmendExecuted == false) { // EW || W-005162 || 07/16/2020 || Added to bypass for the amendment api process
            system.debug('inside opportunity trigger');
            OpportunityHandler oppHandler = new OpportunityHandler();

            if (Trigger.isBefore) {
                if (Trigger.isInsert) {
                    system.debug('inside before insert');
                    oppHandler.onBeforeInsert(Trigger.new);
                } else if (Trigger.isUpdate) {
                    system.debug('inside before update');
                    oppHandler.onBeforeUpdate(Trigger.new);
                }
                /*else if (Trigger.isDelete)
            {
                oppHandler.onBeforeDelete();
            } */ else {
                    system.debug('Error!- trigger fail');
                }
            } else if (Trigger.isAfter) {
                if (Trigger.isInsert) {
                    system.debug('inside after insert');
                    oppHandler.onAfterInsert(Trigger.new);
                } else if (Trigger.isUpdate) {
                    oppHandler.onAfterUpdate(Trigger.new);
                }
                /*else if (Trigger.isDelete)
            {
                oppHandler.onAfterDelete();
            } 
            else if (Trigger.isUnDelete) 
            {
                oppHandler.onAfterUnDelete();
            } */ else {
                    system.debug('Error!- trigger fail');
                }
            } else {
                system.debug('Error!- trigger fail');
            }

            //handle and Finally Operations
            oppHandler.andFinally();
        }
    }
    

}