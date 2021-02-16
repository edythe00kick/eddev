public class OrderGroupHandler {
    
    public OrderGroupHandler(Boolean isExecuting, List<Order_Group__c> newRecords) {
        
        Recursionhandler.IsOrderGroupTriggerExecuted = true;
    }

    @future 
    public static void updateOrderGroupContacts(List<Id> recordIds)
    {
        //Author: Sergio Flores
        //Date: 11/26/2018
        //W-010667

        //After the Order Group Support Level is updated, the Contact associated to this order group should also have its Support Level Updated 

        Date today = date.today(); 
        
        //Missing  AND EndDate >= today from the bottom query since EndDate Doesnt exist in License Product
        //Query all the License Keys with this orderGroup to grab the Contact
        List<License_Key__c> contactsToUpdate = [Select Id, Contact__r.Id, Support_Level__c
                                         From License_Key__c 
                                         Where License_Product__c IN 
                                         (Select Id From License_Product__c Where License_Group__c IN : recordIds)];

        List<Contact> contactSupportLevelUpdateList = new List<Contact>();
        Set<Id> contactIds = new Set<Id>();
        system.debug('ContactSupport list ' + contactsToUpdate);
        
        if(!contactsToUpdate.IsEmpty())
        {
            for(License_Key__c lk : contactsToUpdate)
            {
                Contact c = new Contact();
                c.Support_Level__c = lk.Support_Level__c;
                c.Id = lk.Contact__c;
                if(!contactIds.Contains(c.Id))
                {
                    contactIds.add(c.Id);
                    contactSupportLevelUpdateList.add(c);
                }
                

            }
        }
        

        try
        {
            //Update the Contact Support Level
            update contactSupportLevelUpdateList;
        }
        catch(Exception ex) 
        {
            system.debug('inside catch exception');
            trigger.new[0].addError(ex.getMessage());
        }


    }


}