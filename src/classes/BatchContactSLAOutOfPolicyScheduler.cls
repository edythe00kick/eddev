//Sergio Flores
//Date: 10/07/2019
//W-012954
global class BatchContactSLAOutOfPolicyScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC){
        BatchContactSLAOutOfPolicy batch = new BatchContactSLAOutOfPolicy();
        database.executeBatch(batch, 100); 
    }

}