/**
 * Created by ewong on 5/6/2020.
 */

global without sharing class BatchOppUpdateRenewalOrRnR implements Database.Batchable<sObject>, Database.Stateful{

    global BatchOppUpdateRenewalOrRnR() {

    }

    global Database.queryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id' +
                ' FROM Opportunity' +
                ' WHERE IsWon = true AND StageName = \'5 - Closed Won\' AND type = \'ECUR\' AND CloseDate = last_n_days:365' + //EW || W-005401 || 05/29/2020 || Change the query to pull in 1 year worth of closed won ECUR
                ' AND AdoptionBundle__c = null';  //EWONG || W-006500  || 10/2/2020 || To exclued Adoption ECUR
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> oppList){

        Recursionhandler.IsBatchOppUpdateRenewalOrRnRExecuted = true;

        Map<Id,Opportunity> ripAndReplaceOppsMap = new Map<Id, Opportunity>();
        Map<String,SBQQ__Quote__c> mapOppIdAndQuote = new Map<String,SBQQ__Quote__c>(); //EW || W-005401 || 05/29/2020
        Map<String,SBQQ__Quote__c> mapContractIdAndQuote = new Map<String,SBQQ__Quote__c>(); // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
        List<Related_Contract__c> lstRC = new List<Related_Contract__c>();
        List<SBQQ__Subscription__c> subsToUpdate = new List<SBQQ__Subscription__c>();
        //List<Opportunity> lstOpp = new List<Opportunity>();
        Map<Id, Opportunity> OppsToUpdate = new Map<Id, Opportunity>(); //EW || W-006888 || 12/18/2020
        Map<Id,Contract> mapContract = new Map<Id,Contract>();
        //Map<Id, Related_Contract__c> conIdToRCMap = new Map<Id, Related_Contract__c>();
        Set<Id> contractSet = new Set<Id>(); //EWONG || W-006463 || 10/2/2020
        Set<Id> oppIdSet = new Set<Id>(); //EWONG || W-006463  || 10/2/2020

        if(!oppList.isEmpty()){
            for(opportunity opp : oppList){
                ripAndReplaceOppsMap.put(opp.Id,opp);
            }
        }

        //query all primary quotes that are renewal or R&R related to the closed opp
        List<SBQQ__Quote__c> sbqqQuote = [select id,SBQQ__Opportunity2__c,Purchase_Type__c,SBQQ__StartDate__c,Proposal_Accepted_Date__c  //EW || W-005401 || 05/29/2020 || Change the query to pull in quote start date
        from SBQQ__Quote__c
        where SBQQ__Opportunity2__c IN :ripAndReplaceOppsMap.keySet()
        AND SBQQ__Primary__c = true
        AND (Purchase_Type__c = 'Upsell Rip & Replace'
        OR Purchase_Type__c = 'Renewal' // "OR Purchase_Type__c = 'Renewal'" Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
        OR Purchase_Type__c = 'Upsell Co-term')];  //EWONG || W-006723 || 10/2/2020 || To include Upsell Co-term

        for(SBQQ__Quote__c quot : sbqqQuote){
            mapOppIdAndQuote.put(quot.SBQQ__Opportunity2__c,quot);
        }



        //query all contracts related to the closed opp
        if(sbqqQuote != null && sbqqQuote.size() > 0)
        {
            lstRC = [SELECT Contract__c,Contract__r.SBQQ__RenewalOpportunity__c,Contract__r.SBQQ__RenewalOpportunity__r.type,       // EW || W-005401 || 05/29/2020 || Change the query to pull in contract end date
                    Opportunity__c,Contract__r.SBQQ__RenewalOpportunity__r.IsWon,Contract__r.SBQQ__RenewalOpportunity__r.StageName,
                    Contract__r.EndDate
            FROM Related_Contract__c
            WHERE Opportunity__c IN: mapOppIdAndQuote.keySet()
            AND Contract__r.Status_Category__c != 'Renewed'              //EW || W-005679 || 06/18/2020 || Update status category criteria
            AND Contract__r.Status_Category__c != 'Contract Extended'    //EW || W-005679 || 06/18/2020 || Update status category criteria
            ORDER BY CreatedDate ASC]; // 'ORDER BY CreatedDate ASC' Modified By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/18/2019
        }

        //EWONG || W-006463 || 10/2/2020
        for(Related_Contract__c rCon : lstRC){
            contractSet.add(rCon.Contract__c);

        }

        System.debug('eddie check contractSet = ' + contractSet);

        //EWONG || W-006463 || 10/2/2020 || To return the second ECUR (Adoption) in the contract that needs to be flipped to "Closed-Consolidated". Closed Won and Closed Lost ECUR are excluded
        Map<Id, Opportunity> oppIdToOppMap = new Map<Id, Opportunity>([SELECT Id,SBQQ__RenewedContract__c
        FROM Opportunity
        WHERE SBQQ__RenewedContract__c IN :contractSet
        AND Id NOT IN :mapOppIdAndQuote.keySet()
        AND StageName NOT IN ('5 - Closed Won','Closed Lost')]);

        System.debug('eddie check oppIdToOppMap = ' + oppIdToOppMap);

        //Related Contract
        if(lstRC != null && lstRC.size() > 0){

            //Main Loop
            for(Related_Contract__c rc : lstRC)
            {
                Contract cont = new Contract();
                cont.Id = rc.Contract__c;

                // EW || W-005401 || 05/29/2020 || contract update logic for R&R and Renewal
                if(mapOppIdAndQuote.containskey(rc.Opportunity__c) && (mapOppIdAndQuote.get(rc.Opportunity__c).Purchase_Type__c == 'Renewal' || mapOppIdAndQuote.get(rc.Opportunity__c).Purchase_Type__c == 'Upsell Co-term')  //EWONG || W-006723 || 10/2/2020 || To include Upsell Co-term
                        && (rc.Contract__r.EndDate < System.today() || rc.Contract__r.EndDate > mapOppIdAndQuote.get(rc.Opportunity__c).SBQQ__StartDate__c && mapOppIdAndQuote.get(rc.Opportunity__c).SBQQ__StartDate__c <= System.today())){
                    cont.Status = 'Terminated';
                    cont.Status_Category__c = 'Renewed'; // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
                    System.debug('eddie inside Status_Category__c 1');
                }else if (mapOppIdAndQuote.containskey(rc.Opportunity__c) && mapOppIdAndQuote.get(rc.Opportunity__c).Purchase_Type__c == 'Upsell Rip & Replace' && mapOppIdAndQuote.get(rc.Opportunity__c).SBQQ__StartDate__c <= System.today()){
                    cont.Status = 'Terminated';
                    cont.Status_Category__c = 'Contract Extended';
                    cont.EndDate = mapOppIdAndQuote.get(rc.Opportunity__c).SBQQ__StartDate__c - 1;
                    System.debug('eddie inside Status_Category__c 2');
                }

                System.debug('eddie inside mapContract.put(cont.Id,cont)');
                mapContract.put(cont.Id,cont); // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/15/2019
                mapContractIdAndQuote.put(rc.Contract__c,mapOppIdAndQuote.get(rc.Opportunity__c));
                System.debug('eddie inside mapContract.put(cont.Id,cont)' + mapContractIdAndQuote);

                // EW || W-005401 || 05/29/2020 || Only process logic below if the related ECUR haven't been flipped to Closed - Consolidated or Closed - Rip & Replace
                if (rc.Contract__r.SBQQ__RenewalOpportunity__r.type == 'ECUR' && rc.Contract__r.SBQQ__RenewalOpportunity__r.StageName != 'Closed - Consolidated' && rc.Contract__r.SBQQ__RenewalOpportunity__r.StageName != 'Closed - Rip & Replace'){
                    opportunity opps = new opportunity();
                    opps.Id = rc.Contract__r.SBQQ__RenewalOpportunity__c;

                    System.debug('eddie inside ecur check' + rc.Contract__r.SBQQ__RenewalOpportunity__r.StageName);

                    if (mapOppIdAndQuote.containsKey(rc.Opportunity__c) && (mapOppIdAndQuote.get(rc.Opportunity__c).Purchase_Type__c == 'Renewal'  // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
                            || mapOppIdAndQuote.get(rc.Opportunity__c).Purchase_Type__c == 'Upsell Co-term')) { //EWONG || W-006723 || 10/2/2020 || To include Upsell Co-term
                        if(rc.Contract__r.SBQQ__RenewalOpportunity__c != rc.Opportunity__c){
                            System.debug('eddie inside ecur check 3');
                            opps.stageName = 'Closed - Consolidated'; // Modified By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/18/2019
                            opps.CloseDate = System.today(); //Sharma Nemani | W- 012827 | Date: 08/09/2019
                        }
                    } else if (mapOppIdAndQuote.containsKey(rc.Opportunity__c) && mapOppIdAndQuote.get(rc.Opportunity__c).Purchase_Type__c == 'Upsell Rip & Replace') {
                        if(rc.Contract__r.SBQQ__RenewalOpportunity__c != rc.Opportunity__c){
                            opps.stageName = 'Closed - Rip & Replace'; // Modified By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/18/2019
                            opps.CloseDate = System.today(); //Sharma Nemani | W- 012827 | Date: 08/09/2019
                        }
                    }

                    //lstOpp.add(opps);
                    oppIdSet.add(opps.Id);

                    /*
                    * @Name Eddie Wong
                    * @Work W-006888
                    * @Date 12/18/2020
                    * @Description Changing from list to map for opp update to avoid duplicate Ids from being updated
                    */
                    if(!OppsToUpdate.containsKey(opps.Id)){
                        OppsToUpdate.put(opps.Id, opps);
                    }
                }
            }

            System.debug('eddie check OppsToUpdate = ' + OppsToUpdate);

            // Name: Eddie Wong
            // Date: 10/2/2020
            // Purpose : W-006463
            // Desc: To close consolidate the second ECUR in the same contract. This is needed for a scenario where a contract has both regular ECUR and adoption ECUR.
            if (!oppIdToOppMap.isEmpty()){
                System.debug('eddie check oppIdToOppMap = ' + oppIdToOppMap);
                for(Opportunity o : oppIdToOppMap.values()) {
                    if (!oppIdSet.contains(o.Id) ) {
                        System.debug('eddie inside oppIdToOppMap for loop ');
                        Opportunity op = new Opportunity();
                        op.Id = o.Id;
                        op.stageName = 'Closed - Consolidated';
                        op.CloseDate = System.today();
                        //lstOpp.add(op);

                        /*
                        * @Name Eddie Wong
                        * @Work W-006888
                        * @Date 12/18/2020
                        * @Description Changing from list to map for opp update to avoid duplicate Ids from being updated
                        */
                        if(!OppsToUpdate.containsKey(op.Id)){
                            OppsToUpdate.put(op.Id, op);
                        }

                        System.debug('eddie check OppsToUpdate 2 = ' + OppsToUpdate);
                    }
                }
            }
        }


        //Subscriptions
        if(mapContract.size() > 0 && mapContract != null) {
            List<SBQQ__Subscription__c> lstSubscription = [SELECT id, SBQQ__TerminatedDate__c,SBQQ__Contract__c,SBQQ__RenewedDate__c
            FROM SBQQ__Subscription__c
            WHERE SBQQ__Contract__c IN :mapContract.keySet()
            AND (SBQQ__TerminatedDate__c = null OR SBQQ__RenewedDate__c = null)];  //EW || W-005401 || 05/29/2020 || Only pull in subscriptions that need to be processed

            System.debug('eddie inside lstSubscription' + lstSubscription);

            if (!lstSubscription.isEmpty() && lstSubscription != null){
                for (SBQQ__Subscription__c subs : lstSubscription) {

                    SBQQ__Subscription__c subsToAdd = new SBQQ__Subscription__c();

                    System.debug('eddie inside mapContractIdAndQuote.containskey(subs.SBQQ__Contract__c)' + mapContractIdAndQuote.containskey(subs.SBQQ__Contract__c));
                    //System.debug('eddie inside mapContractIdAndQuote.get(subs.SBQQ__Contract__c)' + mapContractIdAndQuote.get(subs.SBQQ__Contract__c).Purchase_Type__c);

                    if (mapContractIdAndQuote.containskey(subs.SBQQ__Contract__c) && (mapContractIdAndQuote.get(subs.SBQQ__Contract__c).Purchase_Type__c == 'Renewal'  // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
                            || mapContractIdAndQuote.get(subs.SBQQ__Contract__c).Purchase_Type__c == 'Upsell Co-term')) {  //EWONG || W-006723 || 10/2/2020 || To include Upsell Co-term
                        System.debug('eddie inside subsToAdd.Id' + subs.Id);
                        System.debug('subsToAdd.SBQQ__RenewedDate__c' + system.today());
                        subsToAdd.Id = subs.Id;
                        subsToAdd.SBQQ__RenewedDate__c = mapContractIdAndQuote.get(subs.SBQQ__Contract__c).Proposal_Accepted_Date__c;     // EW || W-005401 || 05/29/2020 || Stamp Subscription's Renewed Date with Quote's accepted date
                    } else {
                        System.debug('eddie inside SBQQ__TerminatedDate__c');
                        subsToAdd.Id = subs.Id;
                        subsToAdd.SBQQ__TerminatedDate__c = mapContractIdAndQuote.get(subs.SBQQ__Contract__c).Proposal_Accepted_Date__c;  // EW || W-005401 || 05/29/2020 || Stamp Subscription's Terminated Date with Quote's accepted date
                    }
                    subsToUpdate.add(subsToAdd);
                }
            }
        }

        if(!mapContract.isEmpty() && mapContract != null){
            try {
                System.debug('eddie inside mapContract 2' + mapContract.values());
                update mapContract.values();
            } catch (Exception e) {
                System.debug('eddie inside mapContract catch exception');
                trigger.new[0].addError(e.getMessage());
            }
        }

        /*
        * @Name Eddie Wong
        * @Work W-006888
        * @Date 12/18/2020
        * @Description Changing from list to map for opp update to avoid duplicate Ids from being updated
        */
        if(!OppsToUpdate.isEmpty()){
            try {
                System.debug('eddie inside OppsToUpdate = ' + OppsToUpdate);
                update OppsToUpdate.values();
            } catch (Exception e) {
                System.debug('eddie inside OppsToUpdate catch exception');
                trigger.new[0].addError(e.getMessage());
            }
        }

        if(!subsToUpdate.isEmpty()){
            try {
                System.debug('eddie inside subsToUpdate');
                update subsToUpdate;
            } catch (Exception e) {
                System.debug('inside subsToUpdate catch exception');
                trigger.new[0].addError(e.getMessage());
            }
        }


    }

    global void finish(Database.BatchableContext bc){

    }

}