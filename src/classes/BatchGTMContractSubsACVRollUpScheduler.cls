/**
 * Created by ewong on 2/9/2021.
 */

global class BatchGTMContractSubsACVRollUpScheduler implements Schedulable{

    global void execute(SchedulableContext SC) {
        BatchGTMContractSubsACVRollUp blps = new BatchGTMContractSubsACVRollUp();
        database.executeBatch(blps, 200);
    }
}