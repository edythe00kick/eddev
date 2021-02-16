trigger OwnershipValidationonEvent on Event (before insert, before update) {
 
   //create a set of all unique WhatIDs and WhoIDs
    set<id> WhoIDs = new Set<id>();
    Set<id> ContactIds= new Set<id>();
    Map<Id,Id> tasktoOwnerMap = new Map<Id,Id>();
    Map<Id,Id> taskRelatedtoWhoMap = new Map<Id,Id>();
            
                
    for (Event evnt : trigger.new){        
        taskRelatedtoWhoMap.put(evnt.id,evnt.WhoId);
        WhoIDs.Add(evnt.WhoId);
        tasktoOwnerMap.put(evnt.Id,evnt.OwnerId); 
    }
    
    if(WhoIDs.isEmpty() == FAlSE) {
        Map<id, Contact> contacts = new Map<id, Contact>([SELECT Id, OwnerID from Contact WHERE ID in :WhoIDs]);
        Map<id, Lead> leads = new Map<id, Lead>([SELECT Id, OwnerId FROM Lead WHERE ID in :WhoIDs]);     
       
        for (Event evnt : trigger.new){        
            evnt.Ownership_Validation__c = false;
            if(contacts.isEmpty() == FALSE && contacts.containsKey(taskRelatedtoWhoMap.get(evnt.Id))) {
                if(contacts.get(taskRelatedtoWhoMap.get(evnt.Id)).OwnerId != null && contacts.get(taskRelatedtoWhoMap.get(evnt.Id)).OwnerId == evnt.OwnerId) {
                    evnt.Ownership_Validation__c = true;
                } else {
                   evnt.Ownership_Validation__c = false;    
                }                    
            } else if(leads.isEmpty() == FALSE && leads.containsKey(taskRelatedtoWhoMap.get(evnt.Id))) {
                if(leads.get(taskRelatedtoWhoMap.get(evnt.Id)).OwnerId != null && leads.get(taskRelatedtoWhoMap.get(evnt.Id)).OwnerId == evnt.OwnerId) {
                    evnt.Ownership_Validation__c = true;
                } else {
                    evnt.Ownership_Validation__c = false;    
                }                    
            }                        
         }    
    }       
}