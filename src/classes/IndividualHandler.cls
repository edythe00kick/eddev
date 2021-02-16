//Sergio Flores
//Date: 09/05/2019
//W-011320
public without sharing class IndividualHandler {
    
    // Stores the value of Trigger.isExecuting
    private Boolean myIsExecuting = false;

    public IndividualHandler(Boolean isExecuting) {
        this.myIsExecuting = isExecuting;
    }
    
    public void onBeforeInsert(List<Individual> newRecords) { 
        for(Individual i : newRecords)
        {
            system.debug('inside before insert individual handler ' + i);
            if(i.Safe_to_Send__c == 'No')
            i.HasOptedOutOfEmail__c = true;
            else {
                i.HasOptedOutOfEmail__c = false;
            }
        }
    }
    
    public void onBeforeUpdate(List<Individual> newRecords) { 

        for(Individual i : newRecords)
        {
            system.debug('inside before update individual handler ' + i);
            Individual oldIndividual = (Individual)Trigger.oldMap.get(i.ID);

            if(i.Safe_to_Send__c == 'No')
            i.HasOptedOutOfEmail__c = true;
            else {
                i.HasOptedOutOfEmail__c = false;
            }
            
        }
    }
    

}