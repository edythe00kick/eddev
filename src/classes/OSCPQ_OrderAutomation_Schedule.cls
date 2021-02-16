/*
 * Simple schedule class that calls the order automation batch
 */
global class OSCPQ_OrderAutomation_Schedule implements Schedulable{
    global void execute(SchedulableContext context) {
        OSCPQ_OrderAutomation_Batch batchObject = new OSCPQ_OrderAutomation_Batch('Default');
        
		Id batchId = Database.executeBatch(batchObject, 200); 
    }
}