//Sergio Flores
//Date: 01/22/2020
//W-013849
public without sharing class CoTermSubscriptionQueueable implements Queueable {

    public Map<Id, SBQQ__Subscription__c> subscriptionIdToSubMap;

    public CoTermSubscriptionQueueable(Map<Id, SBQQ__Subscription__c> subscriptionIdToSubMap) {
        this.subscriptionIdToSubMap = subscriptionIdToSubMap;

    }

    public void execute(QueueableContext context) {
        RecursionHandler.IsCoTermSubscriptionQueueableExecuted = true;
        System.debug('inside CoTermSubscriptionQueueable ' + subscriptionIdToSubMap.keySet());

        Set<Id> oppIds = new Set<Id>();

        //Step 1: Query subscriptions
        Map<Id, SBQQ__Subscription__c> subIdToSubscriptionMap = new Map<Id, SBQQ__Subscription__c>
                ([Select Adoption_TCV__c, SBQQ__QuoteLine__r.SBQQ__EffectiveSubscriptionTerm__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__c,
                        SBQQ__RequiredByProduct__c, SBQQ__RequiredByProduct__r.Family, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,
                        SBQQ__QuoteLine__r.CustomEndDate__c,SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c, SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,
                        SBQQ__QuoteLine__r.SBQQ__NetTotal__c, SBQQ__QuoteLine__r.OSCPQ_Net_ARR__c,
                        SBQQ__QuoteLine__r.OSCPQ_Net_NRR__c,
                        SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Total_Contract_Value_Amount__c,
                        SBQQ__Contract__c, SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Annual_Contract_Value_Amount__c,
                        SBQQ__Contract__r.ContractNumber,  SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.IsClosed
                From SBQQ__Subscription__c
                Where Id IN : subscriptionIdToSubMap.keySet()]);

        System.debug('subscriptions returned ' + subscriptionIdToSubMap);

        for(SBQQ__Subscription__c sub : subIdToSubscriptionMap.values())
        {
            oppIds.add(sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c);
        }

        if(!subIdToSubscriptionMap.isEmpty())
        {
            Map<Id, Opportunity> oppIdToOpportunityMap = new Map<Id, Opportunity>
                    ([Select Agreement_Number__c, Partner_License_Fee__c, OEM__c, CurrencyIsoCode, AccountId, Primary_Contact__c, Term_in_Months__c,
                            Account.Name, Primary_Contact__r.Name, OwnerId
                    From Opportunity Where Id IN : oppIds]);

            Set<Id> renewalOppTOUpdate = new Set<Id>();
            List<Opportunity> oppsToInsert = new List<Opportunity>();
            Map<Id, Opportunity> oppIdToOppsToUpdate = new Map<Id, Opportunity>();
            Map<Id, Id> adoptionIdToContractIdMap = new Map<Id, Id>(); //This will be used to group the adoption to contract
            Map<Id, SBQQ__Subscription__c> oppIdToSubscription = new Map<Id, SBQQ__Subscription__c>();

            //Need to group subscriptions to the contract and out of those figure out which are adoption and which are not
            //Once I have the list of the ones that are not adoption we can loop through those subscriptions and store the total
            //separately so that we can deduct from the original renewal opportunity
            for(SBQQ__Subscription__c sub : subIdToSubscriptionMap.values())
            {
                if(sub.SBQQ__RequiredByProduct__r.Family == 'Adoption')
                {
                    //If we are in here then this subscription does have an adoption product so we will need to create
                    //a new adoption opportunity, check to see that this is not already in the list of adoptions to create
                    if(!adoptionIdToContractIdMap.keySet().contains(sub.SBQQ__RequiredByProduct__c))
                    {
                        System.debug('inside adoption scenario ' + adoptionIdToContractIdMap + oppsToInsert);
                        //If we are inside this means that the adoption is being calculated for the first time for this contract
                        //lets add store the subscription information by opportunity -> subscription map
                        //so we can update the opp TCV and ACV

                        //This is the newly closed opp
                        Opportunity o = oppIdToOpportunityMap.get(sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c);

                        oppIdToSubscription.put(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c, sub);
                        Opportunity adoptionOpp = new Opportunity();

                        //We will use this relationship to see that an opportunity is a renewal adoption
                        adoptionOpp.AdoptionBundle__c = sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c;

                        adoptionOpp.Type = 'ECUR';

                        Double amountTCV = sub.Adoption_TCV__c;

                        //*** do we need this in this scenario? adoptionOpp.Renewed_Contract_Adoption_TCV__c = o.Renewed_Contract_Adoption_TCV__c;
                        //adoptionOpp.Annual_Contract_Value__c = o.Annual_Contract_Value__c; this is a formula field
                        adoptionOpp.Amount = amountTCV;
                        adoptionOpp.Original_Amount__c = amountTCV;
                        adoptionOpp.Original_Plan_Amount__c = amountTCV;
                        adoptionOpp.Partner_License_Fee__c = o.Partner_License_Fee__c;
                        adoptionOpp.OEM__c = o.OEM__c;


                        adoptionOpp.Agreement_Number__c = o.Agreement_Number__c;
                        adoptionOpp.AccountId = o.AccountId;

                        //having the fields match the solution overview/acceptance criteria requirements
                        adoptionOpp.CloseDate = sub.SBQQ__QuoteLine__r.CustomEndDate__c != null ? sub.SBQQ__QuoteLine__r.CustomEndDate__c : sub.SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c;
                        adoptionOpp.Name = o.Account.Name + ' - ECUR Adoption - ' + o.Primary_Contact__r.Name + ' - ' + sub.SBQQ__Contract__r.ContractNumber;
                        adoptionOpp.StageName = '3 - Negotiate';
                        adoptionOpp.Original_Close_Date__c = sub.SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c;
                        adoptionOpp.Primary_Contact__c = o.Primary_Contact__c;
                        adoptionOpp.OwnerId = o.OwnerId;
                        adoptionOpp.SBQQ__RenewedContract__c = sub.SBQQ__Contract__c;
                        adoptionOpp.CurrencyIsoCode = o.CurrencyIsoCode;
                        //adoptionOpp.ForecastCategory = 'BestCase'; this is a formula field
                        adoptionOpp.Total_Contract_Value_Amount__c = amountTCV;
                        adoptionOpp.Forecast_Amount__c = amountTCV;
                        //adoptionOpp.Upside_Forecast_Amount_ACV__c = amountTCV; Sergio Flores 02/21/2020 W-004548
                        adoptionOpp.Original_Total_Contract_Value_Amount__c = amountTCV;
                        adoptionOpp.Original_Term_Length_in_Months__c = 12;
                        adoptionOpp.Original_Term_Length_in_Years__c = 1;

                        //also make sure new opp has contract dates populated
                        adoptionOpp.Contract_Start_Date__c = sub.SBQQ__QuoteLine__r.CustomEndDate__c != null ? sub.SBQQ__QuoteLine__r.CustomEndDate__c.addDays(1) : sub.SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c.addDays(1) ;
                        adoptionOpp.Contract_End_Date__c = adoptionOpp.Contract_Start_Date__c.addMonths(12);
                        adoptionOpp.Contract_End_Date__c = adoptionOpp.Contract_End_Date__c.addDays(-1);
                        adoptionOpp.Term_in_Months__c = 12;
                        //adoptionOpp.Best_Case_Term__c = 12; Sergio Flores 02/21/2020 W-004548

                        //Populating the ACV
                        adoptionOpp.Annual_Contract_Value_Amount__c = amountTCV;

                        //Populating the ECUR Buckets for adoption
                        adoptionOpp.Renewed_Contract_Adoption_ACV__c = amountTCV;
                        adoptionOpp.Max_Term_of_Renewed_Contracts__c = 12;
                        oppsToInsert.add(adoptionOpp);

                        adoptionIdToContractIdMap.put(sub.SBQQ__RequiredByProduct__c, sub.SBQQ__Contract__c);

                    }
                }
                else
                {
                    //Only update renewal opps that are open
                    if(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.IsClosed == false)
                    {
                        System.debug('inside non adoption scenario ' + oppIdToOppsToUpdate);
                        //Need to add TCV and ACV of the opp here, so if oppId is already in the list,
                        //Grab the Opp info and update TCV/ACV
                        if(!oppIdToOppsToUpdate.keyset().contains(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c))
                        {
                            Opportunity oppToupdate = new Opportunity();
                            oppToupdate.Id = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c;
                            oppToupdate.Total_Contract_Value_Amount__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Total_Contract_Value_Amount__c + sub.SBQQ__QuoteLine__r.SBQQ__NetTotal__c;
                            oppToupdate.Annual_Contract_Value_Amount__c = sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__r.Annual_Contract_Value_Amount__c + sub.SBQQ__QuoteLine__r.OSCPQ_Net_ARR__c;
                            //Most likely need to update all other ACV/TCV fields on renewal opps (Amount, Forecast Amount, Upside)
                            oppIdToOppsToUpdate.put(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c, oppToupdate);
                        }
                        else
                        {
                            Opportunity oppToupdate = oppIdToOppsToUpdate.get(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c);
                            //This means that the amounts have been added already to the map to update, need to add to the amounts
                            oppToupdate.Total_Contract_Value_Amount__c = oppToupdate.Total_Contract_Value_Amount__c + sub.SBQQ__QuoteLine__r.SBQQ__NetTotal__c;
                            oppToupdate.Annual_Contract_Value_Amount__c = oppToupdate.Annual_Contract_Value_Amount__c + sub.SBQQ__QuoteLine__r.OSCPQ_Net_ARR__c;
                            //Most likely need to update all other ACV/TCV fields on renewal opps (Amount, Forecast Amount, Upside)
                            oppIdToOppsToUpdate.put(sub.SBQQ__Contract__r.SBQQ__RenewalOpportunity__c, oppToupdate);
                        }
                    }

                }
            }

            if(!oppsToInsert.isEmpty())
            {
                try {
                    System.debug('inside updating renewal opp due to coterm ' + oppsToInsert);
                    insert oppsToInsert;
                }
                catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }

            if(!oppIdToOppsToUpdate.isEmpty())
            {
                try {
                    System.debug('inside updating renewal opp due to coterm ' + oppIdToOppsToUpdate);
                    update oppIdToOppsToUpdate.values();
                }
                catch (Exception e) {
                    System.debug(e.getMessage());
                }
            }
        }

    }

}