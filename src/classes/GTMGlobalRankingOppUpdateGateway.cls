/**
 * Created by ewong on 1/21/2021.
 */

public with sharing class GTMGlobalRankingOppUpdateGateway {

    public static void updateGTMGlobalRankingOnOpp(Set<Id> gtmAccountIds) {
        Recursionhandler.IsGTMOppGlobalRankingUpdateExecuted = true;

        System.debug('ed check gtmAccountIds = ' + gtmAccountIds);

        List<Opportunity> oppList = new List<Opportunity>([SELECT Id,Global_Ranking__c,Account.Global_Ranking__c
                                                            FROM Opportunity
                                                            WHERE AccountId IN :gtmAccountIds
                                                            AND IsClosed = FALSE]);
        List<Opportunity> oppUpdateList = new List<Opportunity>();

        System.debug('ed check oppList = ' + oppList);

        if(!oppList.isEmpty()) {
            for(Opportunity opp : oppList) {
                if(opp.Global_Ranking__c != opp.Account.Global_Ranking__c){
                    opp.Global_Ranking__c = opp.Account.Global_Ranking__c;
                    oppUpdateList.add(opp);
                }
            }
        }

        if(!oppUpdateList.isEmpty()) {
            update oppUpdateList;
        }
    }

}