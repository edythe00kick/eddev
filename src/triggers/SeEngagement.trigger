/*Author: Sergio Flores
 * Date: 10-11-2018
*/

trigger SeEngagement on SE_Engagement__c (before insert, before update, after insert, after update) {
    
    system.debug('Inside SE Engagment Trigger');
    
    SeEngagementHandler handler = new SeEngagementHandler(Trigger.isExecuting, Trigger.size,Trigger.new);
    
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
            system.debug('Inside After insert');
            // Call class logic here!
            handler.onAfterInsert(Trigger.new);
        } 
        if (Trigger.isUpdate) 
        {
            // Call class logic here!
            handler.onAfterUpdate(Trigger.new);
        }
        if (Trigger.isDelete) 
        {
            // Call class logic here!
        }
    }


}