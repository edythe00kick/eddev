/*------------------------------------------------------------------------+
Original Shift(developer@originalshift.com)
Purpose: Primary user trigger in the OSCPQ package. Logic handled in the OSPQ_UserTriggerHandler 
 
Details: - Primary function to provision/deprovision CPQ Licenses and Permission Set Assignments
 
History:
Mar 23/19 - Original Shift - Initial Implementation
------------------------------------------------------------------------+*/ 
trigger OSCPQ_UserTrigger on User (after insert, after update) {
	OSCPQ_UserTriggerHandler handler = new OSCPQ_UserTriggerHandler('Default');
    
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            handler.onAfterInsert(Trigger.New);
        }
        else if(Trigger.isUpdate) {
            handler.onAfterUpdate(Trigger.New, Trigger.OldMap);
        }
    }
}