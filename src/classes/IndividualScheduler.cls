//Sergio Flores
//Date: 09/05/2019
//W-011320
global class IndividualScheduler implements Schedulable {
    
    global void execute(SchedulableContext SC){
        BatchCreateIndividual bci = new BatchCreateIndividual();
        database.executeBatch(bci, 50);
    }

}