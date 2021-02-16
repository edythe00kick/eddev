/**
 * @author Eddie Wong
 * @date 01/21/2021
 * @testclass gtmPlatformEventUpdateTest
 * @description
 * @WorkItem W-007069
 * @description Platform event handler to handle account's global ranking update on related open opps
 */

public with sharing class GTMGlobalRankingOppUpdateHandler {

    public static void onAfterInsert(List<GTM_Global_Ranking_Opp_Update_Event__e> newTriggerAC) {

        System.debug('inside GTMGlobalRankingOppUpdateHandler = ' + newTriggerAC);
        Set<Id> accIds = new Set<Id>();

        for(GTM_Global_Ranking_Opp_Update_Event__e gtmOppEvent : newTriggerAC) {
            System.debug('ed check gtmOppEvent.GTM_Account__c = ' + gtmOppEvent.GTM_Account__c);
            accIds.add(Id.valueOf(gtmOppEvent.GTM_Account__c));
        }

        System.debug('ed check accIds = ' + accIds);

        if(!accIds.isEmpty()) {
            GTMGlobalRankingOppUpdateGateway.updateGTMGlobalRankingOnOpp(accIds);
        }

    }

}