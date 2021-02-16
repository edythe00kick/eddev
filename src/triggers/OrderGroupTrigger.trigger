trigger OrderGroupTrigger on Order_Group__c (before insert, before update, after insert, after update) {
    
    system.debug('Inside OrderGroup Trigger');
    
    OrderGroupHandler handler = new OrderGroupHandler(Trigger.isExecuting,Trigger.new);
    
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
        } 
        if (Trigger.isUpdate) 
        {
            List<Id> orderGroupIds = new List<Id>();

            // Call class logic here!
            for(Order_Group__c og : Trigger.new)
            {
                Order_Group__c oldOrderGroup = (Order_Group__c)Trigger.oldMap.get(og.ID);

                if(og.Support_Level__c != oldOrderGroup.Support_Level__c)
                {
                    orderGroupIds.add(og.Id);
                }
            }

            OrderGroupHandler.updateOrderGroupContacts(orderGroupIds);
            system.debug('Inside OrderGroup Trigger After Update' + orderGroupIds); 

        } 
        if (Trigger.isDelete) 
        {
            // Call class logic here!
        }
    }

}