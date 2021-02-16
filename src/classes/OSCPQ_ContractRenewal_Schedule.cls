/*
 * Simple schedule class that calls the renewal automation batch
 */
global class OSCPQ_ContractRenewal_Schedule implements Schedulable{
    global void execute(SchedulableContext context) {
        OSCPQ_ContractRenewal_Batch batchObject = new OSCPQ_ContractRenewal_Batch('Default');
        
        //Best practice for renewals is to have a batch size of 1
		Id batchId = Database.executeBatch(batchObject, 1); 
    }
}