/*------------------------------------------------------------------------+
Original Shift(developer@originalshift.com)
Purpose: Trigger on the CPQ Quote Line Group

Details: - Performs Quote Line Group Cloning
 
History:
Mar 06/19 - Original Shift - Initial Implementation
------------------------------------------------------------------------+*/ 
trigger OSCPQ_QuoteLineTrigger on SBQQ__QuoteLine__c (after insert, after update,before delete, after delete) { 

    //Sergio Flores
    //Date: 11/18/2019
    //W-013609
    AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    system.System.debug('inside alteryxToggleCS ' + alteryxToggleCS);

    if(alteryxToggleCS.Quote_Line_Trigger_Admin_Bypass__c == false)
    {
        OSCPQ_QuoteLineTriggerHandler handler = new OSCPQ_QuoteLineTriggerHandler(Trigger.isExecuting, Trigger.size, 'Default');

        if(Trigger.isAfter) {
            if(Trigger.isInsert) {
                handler.onAfterInsert(Trigger.new); 
            }
            else if(Trigger.isUpdate) {
                handler.onAfterUpdate(Trigger.new); 
            }
            else if(Trigger.isDelete)
            {
                handler.onAfterDelete(Trigger.old);
            }
        }
        // created by Sharma || Date 16 June 2019 .
        // Update ELADLACheckBox checkbox on quote to false If No QL have product code  'AX-100076','AX-100077' .
        if(Trigger.isDelete && Trigger.isBefore){
            //OSCPQ_QuoteLineTriggerHandler.updateQuotesELADLACheckBoxFalse(Trigger.new);
            handler.onBeforeDelete(Trigger.oldMap);
        }
    }

    OSCPQ_QuoteLineTriggerHandler.firstRun = false;
}