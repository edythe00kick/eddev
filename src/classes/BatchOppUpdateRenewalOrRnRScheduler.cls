/**
 * Created by ewong on 5/7/2020.
 */

global class BatchOppUpdateRenewalOrRnRScheduler implements Schedulable{
    global void execute(SchedulableContext SC){
        BatchOppUpdateRenewalOrRnR bRRR = new BatchOppUpdateRenewalOrRnR();
        database.executeBatch(bRRR, 100);
    }
}