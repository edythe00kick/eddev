// Changes made by Sharma Nemani
// Date: 06/26/2019
// Changes made are : Class need to Implement Schedulable Interface

global class ScheduleBatchContractExpiration implements Schedulable{
    global void execute(SchedulableContext sc){
        BatchContractExpiration bce = new BatchContractExpiration();
        database.executeBatch(bce);
    }
}