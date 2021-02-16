/* Created by: Sharma Nemani | W-011617
 * Date: 06/10/2019
 * Description: Handler Class for the RelatedContractTrigger.
*/

/* Author: Sharma Nemani | W-011617 --> Start
 * Date: 06/10/2019
 * Description: This method is to Sum all the Forecasting related fields from Related Contracts' Contracts
 * 				and stamp on Opportunity.
*/
/*Author: Eddie Wong | W-004473
  Date: 2/14/2020
  Description: To re-design relate contract roll-up in opportunity to reflex the correct Adoption TCV, Subscription ACV, and ECUR Bucket, when ECUR is renewed or related contract is deleted
 */

public class RelatedContractHandler {
    public static Map<String, Double> conversionRatesMap = UtilityClass.getConversionRates();
    public static Boolean runOnce = true;
    public static void runOnce(){
        runOnce = false;
    }

    public static void afterInsertUpdateRC(Map<Id,Related_Contract__c> mapRC){
        List<Id> lsrOpp = new List<Id>();

        List<Related_Contract__c> lstRc = [SELECT Contract__c, Opportunity__c, Opportunity__r.Type, Opportunity__r.StageName FROM Related_Contract__c WHERE Id IN: mapRC.keySet()]; //list of related contract
        for(Related_Contract__c rc : lstRc){
            if(rc.Opportunity__r.Type == 'ECUR' && rc.Opportunity__r.StageName != '5 - Closed Won' && rc.Opportunity__r.StageName != '7 - Closed Won' && rc.Opportunity__r.StageName != 'Closed Lost'){
                lsrOpp.add(rc.Opportunity__c);   //add Open ECUR opp to lsrOpp
            }
        }

        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>([SELECT Id, CurrencyIsoCode  FROM Opportunity WHERE Id IN:lsrOpp]);
        List<AggregateResult> lstRcAggr = [SELECT MAX(Contract__r.ContractTerm) maxContractTerm,SUM(Contract__r.Original_Subscription_ARR__c) sumSubscription_ARR,
                SUM(Contract__r.Adoption_TCV__c) sumAdoption_TCV,SUM(Contract__r.Co_Term_TRR__c) sumCo_Term_TRR,
                Opportunity__c,SUM(Contract__r.SubscriptionACV__c) sumSubscription_ACV,SUM(Contract__r.Adoption_ACV__c) sumAdoption_ACV
        FROM Related_Contract__c
        WHERE Opportunity__c IN: lsrOpp
        GROUP BY Opportunity__c];

        //Map opportunity Id to values (Adoption TCV and Subscription ACV from contract, and Adoption and Adoption Bundle from opportunity)
        Map<Id, Opportunity> mapOppToContract = new Map<Id, Opportunity>([SELECT Id,opportunity.SBQQ__RenewedContract__r.Adoption_TCV__c,
                opportunity.SBQQ__RenewedContract__r.SubscriptionACV__c,Adoption__c,AdoptionBundle__c,
                opportunity.SBQQ__RenewedContract__r.Adoption_ACV__c
        FROM Opportunity
        WHERE Id IN :lsrOpp ]);

        System.debug('eddie inside relatedcontracthandler' + mapOppToContract.values());

        List<Opportunity> lstOPP = new List<Opportunity>();
        for(AggregateResult aggrRes : lstRcAggr){
            System.debug('Renewed_Contract_Original_Sub_ARR__c :: '+((Double) (aggrRes.get('sumSubscription_ARR')!=null?aggrRes.get('sumSubscription_ARR'):0)));
            Opportunity opp = new Opportunity();
            opp.Id = (Id) aggrRes.get('Opportunity__c');
            //opp.Renewed_Contract_Original_Sub_ARR__c = ((Double) (aggrRes.get('sumSubscription_ARR')!=null?aggrRes.get('sumSubscription_ARR'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode); // *
            opp.Renewed_Contract_Adoption_TCV__c  = ((Double) (aggrRes.get('sumAdoption_TCV')!=null?aggrRes.get('sumAdoption_TCV'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode);
            //opp.Renewed_Contract_Co_Term_TRR__c  = ((Double) (aggrRes.get('sumCo_Term_TRR')!=null?aggrRes.get('sumCo_Term_TRR'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode);
            opp.Max_Term_of_Renewed_Contracts__c  = ((Integer) (aggrRes.get('maxContractTerm')!=null?aggrRes.get('maxContractTerm'):0));
            //opp.Renewed_Contract_Adoption_TCV__c  = ((Double) (aggrRes.get('sumAdoption_TCV')!=null?aggrRes.get('sumAdoption_TCV'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode);
            opp.Renewed_Contract_Subscription_ACV__c = ((Double) (aggrRes.get('sumSubscription_ACV')!=null?aggrRes.get('sumSubscription_ACV'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode) ;
            opp.Renewed_Contract_Adoption_ACV__c = ((Double) (aggrRes.get('sumAdoption_ACV')!=null?aggrRes.get('sumAdoption_ACV'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode) ;
            opp.Renewed_Contract_Adoption_TCV__c = opp.Renewed_Contract_Adoption_TCV__c.setScale(2, RoundingMode.HALF_UP);
            opp.Renewed_Contract_Subscription_ACV__c = opp.Renewed_Contract_Subscription_ACV__c.setScale(2, RoundingMode.HALF_UP);
            opp.Renewed_Contract_Adoption_ACV__c = opp.Renewed_Contract_Adoption_ACV__c.setScale(2, RoundingMode.HALF_UP);
            //Name: Chris Salgado Date: 7/27/20 Purpose: W-005431
            //Sergio Flores 09/16/2020 W-006376 Changing condition below to only occur if there is Supscription ACV
            //Eddie WOng || 10/13/2020 || W-006514 || To fix forecast amount for adoption ECUR during creation
            if(mapOppToContract.get(opp.Id).Adoption__c == false && mapOppToContract.get(opp.Id).AdoptionBundle__c == null && aggrRes.get('sumSubscription_ACV')!=null && (aggrRes.get('sumSubscription_ACV') != 0) ){
                System.debug('eddie inside adoption check');
                //opp.Forecast_Amount__c = ((Double) (aggrRes.get('sumSubscription_ACV')!=null?aggrRes.get('sumSubscription_ACV'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode) ;
                opp.Forecast_Amount__c = (Double) aggrRes.get('sumSubscription_ACV');
            }
            lstOPP.add(opp);
        }

        //If opp is adoption, subtract original contract's Subscription ACV from the total aggregated Subscription ACV
        //If opp is adoption, assign Opp's Max Term of Renewed Contracts to 12
        //If opp is non-adoption, substract original contract's Adoption TCV from the total aggregated Adoption TCV
        //If opp is renewed as regular ECUR (with only adoption bundle in contract), no Subscription ACV adjustment is needed
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        if(!mapOppToContract.isEmpty()){
            System.debug('inside mapOppToContractIsEmpty1' + mapOppToContract.size() + ' ' + lstOPP.size() + '' + lstOPP);
            for(Opportunity opp : lstOPP){
                System.debug('inside lstoppadoptionTCV' + +mapOppToContract.get(opp.Id) + '' + mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.Adoption_TCV__c + ' ' + mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.SubscriptionACV__c);
                //Sergio Flores 09/16/2020 W-006376 including extra condition to check for if Adoption only
                if( (mapOppToContract.get(opp.Id).Adoption__c == true || mapOppToContract.get(opp.Id).AdoptionBundle__c != null) || (mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.SubscriptionACV__c == 0 && mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.Adoption_ACV__c > 0)){
                    opp.Renewed_Contract_Subscription_ACV__c =  opp.Renewed_Contract_Subscription_ACV__c - mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.SubscriptionACV__c;
                    opp.Max_Term_of_Renewed_Contracts__c  = 12.00;
                    System.debug('Eddie inside mapOppToContract1' + opp.Renewed_Contract_Adoption_TCV__c);
                    lstOppToUpdate.add(opp);
                }
                else if(mapOppToContract.get(opp.Id).Adoption__c == false && mapOppToContract.get(opp.Id).AdoptionBundle__c == null){
                    System.debug('inside mapOppToContractIsEmpty2' + mapOppToContract.size());
                    if(mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.SubscriptionACV__c > 0 && mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.Adoption_TCV__c > 0){
                        opp.Renewed_Contract_Adoption_TCV__c =  opp.Renewed_Contract_Adoption_TCV__c - mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.Adoption_TCV__c;
                        opp.Renewed_Contract_Adoption_ACV__c =  opp.Renewed_Contract_Adoption_ACV__c - mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.Adoption_ACV__c;
                    }
                    System.debug('Eddie inside mapOppToContract2' + opp.Renewed_Contract_Subscription_ACV__c);
                    lstOppToUpdate.add(opp);

                }
            }
        }

        update lstOppToUpdate;
    }
    //Sharma Nemani | Date: 06/10/2019 | W-011617  --> End


    /* Author: Sharma Nemani | W-011617 --> Start
     * Date: 06/11/2019
     * Description: This method will re-calculate Forecasting related fields on opportunity if any of the Related
     * 				Contracts are deleted.
    */
    public static void afterDeleteRC(Map<Id,Related_Contract__c> mapRC){
        System.debug('tt :: '+[SELECT COUNT() FROM Related_Contract__c WHERE Opportunity__c =:(mapRC.values())[0].Opportunity__c]);
        List<Id> lsrOpp = new List<Id>();
        List<Id> lsrContract = new List<Id>();
        List<Opportunity> lstOPP = new List<Opportunity>();

        for(Id rcId : mapRC.keySet()){
            lsrOpp.add(mapRC.get(rcId).Opportunity__c);
            lsrContract.add(mapRC.get(rcId).Contract__c);
        }

        Map<Id,Opportunity> mapOpp = new Map<Id,Opportunity>([SELECT Id, CurrencyIsoCode  FROM Opportunity WHERE Id IN:lsrOpp]);
        List<AggregateResult> lstRcAggr = [SELECT MAX(Contract__r.ContractTerm) maxContractTerm,SUM(Contract__r.Original_Subscription_ARR__c) sumSubscription_ARR,SUM(Contract__r.Adoption_TCV__c) sumAdoption_TCV,
                SUM(Contract__r.Co_Term_TRR__c) sumCo_Term_TRR,Opportunity__c,SUM(Contract__r.SubscriptionACV__c) sumSubscription_ACV,
                SUM(Contract__r.Adoption_ACV__c) sumAdoption_ACV
        FROM Related_Contract__c
        WHERE Opportunity__c IN: lsrOpp
        AND Contract__c NOT IN :lsrContract
        GROUP BY Opportunity__c];

        //Map opportunity Id to values (Adoption TCV and Subscription ACV from contract, and Adoption and Adoption Bundle from opportunity)
        Map<Id, Opportunity> mapOppToContract = new Map<Id, Opportunity>([SELECT Id,opportunity.SBQQ__RenewedContract__r.Adoption_TCV__c,opportunity.SBQQ__RenewedContract__r.SubscriptionACV__c,Adoption__c,AdoptionBundle__c,
                opportunity.SBQQ__RenewedContract__r.Adoption_ACV__c
        FROM Opportunity
        WHERE Id IN :lsrOpp
        AND SBQQ__RenewedContract__c NOT IN :lsrContract ]);

        System.debug('eddie inside relatedcontracthandler' + mapOppToContract.values());


        if(lstRcAggr.size() == 0){
            for(Id oppId : lsrOpp){
                Opportunity opp = new Opportunity();
                opp.Id = oppId;
                opp.Renewed_Contract_Original_Sub_ARR__c =0;
                opp.Renewed_Contract_Adoption_TCV__c = 0;
                opp.Renewed_Contract_Co_Term_TRR__c  = 0;
                opp.Max_Term_of_Renewed_Contracts__c = 0;
                opp.Renewed_Contract_Subscription_ACV__c = 0;
                lstOPP.add(opp);
            }
            update lstOPP;
            lstOPP.clear();
        }


        for(AggregateResult aggrRes : lstRcAggr){
            System.debug('Renewed_Contract_Original_Sub_ARR__c :: '+((Double) (aggrRes.get('sumSubscription_ARR')!=null?aggrRes.get('sumSubscription_ARR'):0)));
            Opportunity opp = new Opportunity();
            opp.Id = (Id) aggrRes.get('Opportunity__c');
            //opp.Renewed_Contract_Original_Sub_ARR__c = ((Double) (aggrRes.get('sumSubscription_ARR')!=null?aggrRes.get('sumSubscription_ARR'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode); // *
            opp.Renewed_Contract_Adoption_TCV__c  = ((Double) (aggrRes.get('sumAdoption_TCV')!=null?aggrRes.get('sumAdoption_TCV'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode);
            //opp.Renewed_Contract_Co_Term_TRR__c  = ((Double) (aggrRes.get('sumCo_Term_TRR')!=null?aggrRes.get('sumCo_Term_TRR'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode);
            opp.Max_Term_of_Renewed_Contracts__c  = ((Integer) (aggrRes.get('maxContractTerm')!=null?aggrRes.get('maxContractTerm'):0));
            //opp.Renewed_Contract_Adoption_TCV__c  = ((Double) (aggrRes.get('sumAdoption_TCV')!=null?aggrRes.get('sumAdoption_TCV'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode);
            opp.Renewed_Contract_Subscription_ACV__c = ((Double) (aggrRes.get('sumSubscription_ACV')!=null?aggrRes.get('sumSubscription_ACV'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode) ;
            opp.Renewed_Contract_Adoption_ACV__c = ((Double) (aggrRes.get('sumAdoption_ACV')!=null?aggrRes.get('sumAdoption_ACV'):0))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode) ;
            opp.Renewed_Contract_Adoption_TCV__c = opp.Renewed_Contract_Adoption_TCV__c.setScale(2, RoundingMode.HALF_UP);
            opp.Renewed_Contract_Subscription_ACV__c = opp.Renewed_Contract_Subscription_ACV__c.setScale(2, RoundingMode.HALF_UP);
            opp.Renewed_Contract_Adoption_ACV__c = opp.Renewed_Contract_Adoption_ACV__c.setScale(2, RoundingMode.HALF_UP);
            lstOPP.add(opp);
        }

        //If opp is adoption, subtract original contract's Subscription ACV from the total aggregated Subscription ACV
        //If opp is adoption, assign Opp's Max Term of Renewed Contracts to 12
        //If opp is non-adoption, substract original contract's Adoption TCV from the total aggregated Adoption TCV
        //If opp is renewed as regular ECUR (with only adoption bundle in contract), no Subscription ACV adjustment is needed
        List<Opportunity> lstOppToUpdate = new List<Opportunity>();
        if(!mapOppToContract.isEmpty()){
            System.debug('inside mapOppToContractIsEmpty1' + mapOppToContract.size() + ' ' + lstOPP.size() + '' + lstOPP);
            for(Opportunity opp : lstOPP){
                System.debug('inside lstoppadoptionTCV' + +mapOppToContract.get(opp.Id) + '' + mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.Adoption_TCV__c + ' ' + mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.SubscriptionACV__c);
                //Sergio Flores 09/16/2020 W-006376 including extra condition to check for if Adoption only
                if( (mapOppToContract.get(opp.Id).Adoption__c == true || mapOppToContract.get(opp.Id).AdoptionBundle__c != null) || (mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.SubscriptionACV__c == 0 && mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.Adoption_ACV__c > 0)){
                    opp.Renewed_Contract_Subscription_ACV__c =  opp.Renewed_Contract_Subscription_ACV__c - mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.SubscriptionACV__c;
                    opp.Max_Term_of_Renewed_Contracts__c  = 12.00;
                    System.debug('Eddie inside mapOppToContract1' + opp.Renewed_Contract_Adoption_TCV__c);
                    lstOppToUpdate.add(opp);
                }
                else if(mapOppToContract.get(opp.Id).Adoption__c == false && mapOppToContract.get(opp.Id).AdoptionBundle__c == null){
                    System.debug('inside mapOppToContractIsEmpty2' + mapOppToContract.size());
                    if(mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.SubscriptionACV__c > 0 && mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.Adoption_TCV__c > 0){
                        opp.Renewed_Contract_Adoption_TCV__c =  opp.Renewed_Contract_Adoption_TCV__c - mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.Adoption_TCV__c;
                        opp.Renewed_Contract_Adoption_ACV__c =  opp.Renewed_Contract_Adoption_ACV__c - mapOppToContract.get(opp.Id).SBQQ__RenewedContract__r.Adoption_ACV__c;
                    }
                    System.debug('Eddie inside mapOppToContract2' + opp.Renewed_Contract_Subscription_ACV__c);
                    lstOppToUpdate.add(opp);

                }
            }
        }

        if(lstOppToUpdate.size() > 0){
            update lstOppToUpdate;
        }
    }
    // Sharma Nemani | Date: 06/11/2019 | W-011617 --> End
}