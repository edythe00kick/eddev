trigger GTMGlobalRankingOppUpdateTrigger on GTM_Global_Ranking_Opp_Update_Event__e (after insert) {

    System.debug('In GTMGlobalRankingOppUpdateTrigger');
    
    if(Trigger.isAfter){
        if(Trigger.isInsert){
            System.debug('In AfterInsert trigger');
            GTMGlobalRankingOppUpdateHandler.onAfterInsert(Trigger.new);
        }
    }
}