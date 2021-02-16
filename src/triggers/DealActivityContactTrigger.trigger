trigger DealActivityContactTrigger on Deal_Activity_Contact__c (before insert, before update, after insert, after update) {

    system.debug('Inside DealActivityContactTrigger');
    
    DealActivityContactHandler handler = new DealActivityContactHandler(Trigger.isExecuting,Trigger.new);
    
    if (Trigger.isBefore) 
    {
        if (Trigger.isInsert) 
        {
            // Call class logic here!
        } 
        if (Trigger.isUpdate) 
        {
            // Call class logic here!
            handler.onBeforeUpdate(Trigger.New);
            system.debug('Inside OrderGroup Trigger After Update');
        }
        if (Trigger.isDelete) 
        {
            // Call class logic here!
        }
    }
    
    /* Author: Sharma Nemani | W-010093 --> START
     * Date: 06/20/2019
     * Description: This condition is to call the onAfterUpdate method from DealActivityContactHandler to
     * create a Contact Role in Opportunity when the "Qualification Status" of a Deal Activity Contact is flipped
     * to 'Approved'.
     */
    if(trigger.isAfter && trigger.isUpdate){
        handler.onAfterUpdate(trigger.newmap,trigger.oldmap);
    }
// Sharma Nemani | W-010093 | Date: 06/20/2019 --> END

    /*
    if (Trigger.IsAfter) 
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

}