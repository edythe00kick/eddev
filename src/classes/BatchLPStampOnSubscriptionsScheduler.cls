/**
 * Created by ewong on 7/7/2020.
 * Eddie Wong
 * 07/07/2020
 * W-005163
 */

global class BatchLPStampOnSubscriptionsScheduler implements Schedulable{

    global void execute(SchedulableContext SC) {
        BatchLPStampOnSubscriptions blps = new BatchLPStampOnSubscriptions();
        database.executeBatch(blps, 100);
    }
}