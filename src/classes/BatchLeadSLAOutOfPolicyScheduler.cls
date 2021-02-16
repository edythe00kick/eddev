//Sergio Flores
//Date: 10/07/2019
//W-012945
global class BatchLeadSLAOutOfPolicyScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC){
        BatchLeadSLAOutOfPolicy batch = new BatchLeadSLAOutOfPolicy();  
        database.executeBatch(batch, 50);
    }

}