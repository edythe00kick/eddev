/* Author: Sharma Nemani | W- 012827 
 * Date: 08/09/2019
 * Description: This Queuebale Class is for terminating the Rip & Replace and Renewal Quotes. 
*/
public class OpportunityQueueable implements Queueable {
    public Map<Id, Opportunity> ripAndReplaceOppsMap;

    public OpportunityQueueable(Map<Id, Opportunity> ripAndReplaceOppsMap){
        this.ripAndReplaceOppsMap = ripAndReplaceOppsMap;
    }
    public void execute(QueueableContext context) {

        Recursionhandler.IsOpportunityQueuableExecuted = true;

        /* Added By : Sharma Nemani  | W-011959 --> Start
     * Date 	: 06/03/2019
     * Description: Method will update the Contract (from the Related Contracts in Opportunity that's on the Primary 
     * Proposal) as Terminated and the Contract's Subscription as Terminated. Also, checks if there's any 
     * Renewal Opportunity of Type ECUR in Contracts and updates the Stage to 'Closed - Rip & Replace' on the Renewal 
     * Opportunity.
    */
        List<Id> contractId = new List<Id>();
        List<Related_Contract__c> lstRC;

        Map<String,String> mapOppIdAndPurchaseType = new Map<String,String>(); // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
        Map<String,String> mapContractIdAndPurchaseType = new Map<String,String>(); // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019



        List<SBQQ__Quote__c> sbqqQuote = [select id,SBQQ__Opportunity2__c,Purchase_Type__c from SBQQ__Quote__c where SBQQ__Opportunity2__c IN : ripAndReplaceOppsMap.keySet() AND SBQQ__Primary__c = true AND (Purchase_Type__c = 'Upsell Rip & Replace' OR Purchase_Type__c = 'Renewal')]; // "OR Purchase_Type__c = 'Renewal'" Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019

        for(SBQQ__Quote__c quot : sbqqQuote){
            mapOppIdAndPurchaseType.put(quot.SBQQ__Opportunity2__c,quot.Purchase_Type__c);
        }

        if(sbqqQuote!=null && sbqqQuote.size()>0)
        {
            lstRC = [select Contract__c,Contract__r.SBQQ__RenewalOpportunity__c,Contract__r.SBQQ__RenewalOpportunity__r.type,Opportunity__c from Related_Contract__c where Opportunity__c IN: ripAndReplaceOppsMap.keySet() ORDER BY CreatedDate ASC]; // 'ORDER BY CreatedDate ASC' Modified By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/18/2019
        }

        if(lstRC!=null && lstRC.size()>0){
            //List<Contract> lstContract = new List<Contract>();
            Map<Id,Contract> mapContract = new Map<Id,Contract>(); // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/15/2019
            List<Opportunity> lstOpp = new List<Opportunity>();

            Integer i=0; // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/18/2019
            for(Related_Contract__c rc:lstRC)
            {
                Contract  cont = new Contract();
                cont.Id = rc.Contract__c;
                cont.Status = 'Terminated';
                cont.EndDate = System.today(); //Added by: Sharma Nemani | W-013108 | Date: 10/18/2019


                if(mapOppIdAndPurchaseType.containskey(rc.Opportunity__c) && mapOppIdAndPurchaseType.get(rc.Opportunity__c) == 'Renewal'){ // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
                    cont.Status_Category__c = 'Renewed'; // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
                }else{
                    cont.Status_Category__c = 'Contract Extended';
                }
                //lstContract.add(cont); Commented By: Sharma Nemani | W-012584 & W-012585 | Date: 07/18/2019
                mapContract.put(cont.Id,cont); // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/15/2019


                if (rc.Contract__r.SBQQ__RenewalOpportunity__r.type == 'ECUR'){
                    i++; // Added By: Sharma Nemani | W-012584 & W-012585 | Date: 07/18/2019
                    opportunity opps = new opportunity();
                    opps.Id = rc.Contract__r.SBQQ__RenewalOpportunity__c;

                    if(mapOppIdAndPurchaseType.containskey(rc.Opportunity__c) && mapOppIdAndPurchaseType.get(rc.Opportunity__c) == 'Renewal'){ // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
                        if(i==1){ // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/18/2019
                            opps.stageName = '5 - Closed Won'; // Modified By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/18/2019
                        } else {
                            opps.stageName = 'Closed - Consolidated'; // Modified By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/18/2019
                            opps.CloseDate = System.today(); //Sharma Nemani | W- 012827 | Date: 08/09/2019
                        }
                    }else if (mapOppIdAndPurchaseType.containskey(rc.Opportunity__c) && mapOppIdAndPurchaseType.get(rc.Opportunity__c) == 'Upsell Rip & Replace'){
                        opps.stageName = 'Closed - Rip & Replace'; // 'else if' condition Modified By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/18/2019
                        opps.CloseDate = System.today(); //Sharma Nemani | W- 012827 | Date: 08/09/2019
                    }

                    lstOpp.add(opps);
                }

                contractId.add(rc.Contract__c);
                mapContractIdAndPurchaseType.put(rc.Contract__c,mapOppIdAndPurchaseType.get(rc.Opportunity__c)); // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
            }
            //Commented RunOnceTrigger below in this method. Sharma Nemani  | W-012738 | Date: 07/29/2019
            //RunOnceTrigger.setRunOnceFalse(); // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/16/2019
            update mapContract.values(); // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/15/2019

            update lstOpp;
        }

        if(contractId.size() > 0){
            List<SBQQ__Subscription__c> lstSubscription = [select id, SBQQ__TerminatedDate__c,SBQQ__Contract__c  from SBQQ__Subscription__c where SBQQ__Contract__c IN:contractId];
            for(SBQQ__Subscription__c subs:lstSubscription){
                if(mapContractIdAndPurchaseType.containskey(subs.SBQQ__Contract__c) && mapContractIdAndPurchaseType.get(subs.SBQQ__Contract__c) == 'Renewal'){ // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
                    subs.SBQQ__RenewedDate__c = system.today(); // Added By: Sharma Nemani  | W-012584 & W-012585 | Date: 07/12/2019
                }else{
                    subs.SBQQ__TerminatedDate__c = system.today();
                }
            }
            update lstSubscription;
        }
    }

    // Sharma Nemani | Date: 06/03/2019 | W-011959 --> End


}