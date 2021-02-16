public class LicenseKeyHandler {
    
    public LicenseKeyHandler(Boolean isExecuting, List<License_Key__c> newRecords) {
        
        //Add/set any contstructor variables     
        Recursionhandler.IsLicenseKeyTriggerExecuted = isExecuting;
    }

    public void onAfterInsert(List<License_Key__c> newRecords)
    {
        //Author: Sergio Flores
        //Date: 11/19/2018
        //W-010666

        //Need to find the support level on the asset line item associated with this License key 
        //and update the associated Contact with the support level
        
        List<Contact> contactSupportLevelUpdateList = new List<Contact>();
		List<Lead> updatingLeads = new List<Lead>(); // List of Leads Added by: Sharma Nemani | W - 011561 | Case: 00267086 & Case: 00317164
        Map<Id,Lead> mapLead = new Map<Id,Lead>();
        
        for(License_Key__c lk : newRecords)
        {
            //check to see if support level or contact ID is blank
            if(lk.Support_Level__c != '' && lk.Contact__c !=null)
            {
                Contact c = new Contact();
                c.Support_Level__c = lk.Support_Level__c;
                c.Id = lk.Contact__c;
                contactSupportLevelUpdateList.add(c);
            }
            /* Sharma Nemani | W - 011561 | Case: 00267086 & Case: 00317164 --> START --> Placed this code back on 01/23/2020
             * Date: 03/20/2019
             */ //Description: Update the Licensed_Alteryx_User__c checkbox field on Lead after the License Key is inserted  
            Set<Id> uniqueLeadId = new Set<Id>();
            if(lk.Lead__c != null){
                if(uniqueLeadId.contains(lk.Lead__c)){
                    continue;
                }else{
                    uniqueLeadId.add(lk.Lead__c);
                }
                Lead ld = new Lead();
                ld.Id = lk.Lead__c;
                ld.Licensed_Alteryx_User__c = true; // Updating the Lead's Licensed_Alteryx_User__c checkbox field
                //updatingLeads.add(ld);
                // updated by sharma 27 JAN 2020.
                mapLead.put(lk.Lead__c,ld);
            }
            
       		// Sharma Nemani | W - 011561 | Case: 00267086 & Case: 00317164 --> END
        }
        try{
            update contactSupportLevelUpdateList;
            if(updatingLeads.size()>0){
                update mapLead.values();//updatingLeads; // Updating the Lead records   
            }
        }catch(Exception ex){
            system.debug('Unable to Update the parent Lead: '+ String.valueOf(ex));
            trigger.new[0].addError(ex.getMessage());
        }
        
        /*try
        {
            //Update the Contact Support Level
            update contactSupportLevelUpdateList;
        }
        catch(Exception ex) 
        {
            system.debug('inside catch exception');
            trigger.new[0].addError(ex.getMessage());
        }*/
        
    }
    
    // Sharma Nemani | W - 011561 | Case: 00267086 --> START --> Placed this code back on 01/23/2020
    // Date: 03/20/2019
    // Description: Update the Licensed_Alteryx_User__c checkbox field on Lead after the License Key is inserted
   /* public void updateLeadRecord(List<License_Key__c> newRecords){
      List<Lead> updatingLeads = new List<Lead>(); // List of Leads

        for(License_Key__c lk : newRecords){
         if(lk.Lead__c != null){
                Lead ld = new Lead();
                ld.Id = lk.Lead__c;
                ld.Licensed_Alteryx_User__c = true; // Updating the Lead's Licensed_Alteryx_User__c checkbox field
                updatingLeads.add(ld);
            }
             if(updatingLeads.size()>0){
            try{
                update updatingLeads; // Updating the Lead records
            }catch(Exception ex){
                system.debug('Unable to Update the parent Lead: '+ String.valueOf(ex));
            	trigger.new[0].addError(ex.getMessage());
            }
        }   
        }
       
    } */
    // Sharma Nemani | W - 011561 | Case: 00267086 --> END --> Placed this code back on 01/23/2020
}