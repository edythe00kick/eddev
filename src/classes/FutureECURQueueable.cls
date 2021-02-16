public without sharing class FutureECURQueueable implements Queueable {

    public Map<Id, Contract> oppIdToContractMap;

    public FutureECURQueueable(Map<Id, Contract> oppIdToContractMap) {
        this.oppIdToContractMap = oppIdToContractMap;

    }

    //EW || W-005252 || 05/27/2020 || Added Account.Customer_Success_Advocate__c to the query below
    public void execute(QueueableContext context) {
        RecursionHandler.IsFutureECURQueueableExecuted = true;
        System.debug('inside FutureECURQueueable ' + oppIdToContractMap.keySet());
        Map<Id, Opportunity> originalOppsMap = new Map<Id, Opportunity>([Select Id, Name, OwnerId, Type, CloseDate, Original_Close_Date__c, Annual_Contract_Value_Amount__c,
                CurrencyIsoCode, Renewed_Contract_Adoption_TCV__c, Annual_Contract_Value__c, Amount,
                Original_Amount__c, Original_Plan_Amount__c, Partner_License_Fee__c, OEM__c, StageName, ForecastCategory,
                Agreement_Number__c, AccountId, Primary_Contact__c, SBQQ__PrimaryQuote__r.OSCPQ_Net_ARR__c,
                Account.Name, Primary_Contact__r.Name, Term_In_Months__c, Total_Contract_Value_Amount__c, Account.Customer_Success_Advocate__c, AFG_Opportunity__c
        From Opportunity
        Where Id IN : oppIdToContractMap.keySet()
        ]);
        Set<Id> contractids = new Set<Id>();

        for(Contract c : oppIdToContractMap.values())
        {
            contractids.add(c.Id);
        }

        //Find out if there are adoption bundles
        //Sergio Flores
        //Date: 01/15/2020
        //W-013849

        string adoptionBundles = System.Label.adoptionBundles;

        Set<String> adoptionBundleSet = new Set<String>();

        for(String s : adoptionBundles.Split(',') )
        {
            adoptionBundleSet.add(s);
        }

        Map<Id, OpportunityLineItem> oliIdToOpportunityLineItemMap = new Map<Id, OpportunityLineItem>(
        [Select OpportunityId, Opportunity.Term_in_Months__c, SBQQ__QuoteLine__c,
                SBQQ__QuoteLine__r.SBQQ__EffectiveSubscriptionTerm__c, SBQQ__QuoteLine__r.Extended_Price__c, SBQQ__QuoteLine__r.CustomEndDate__c, SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c
        From OpportunityLineItem
        Where OpportunityId IN : oppIdToContractMap.keySet()
        AND ProductCode IN : adoptionBundleSet]
        );

        System.debug('checking to see if adoptions exist' + oliIdToOpportunityLineItemMap + adoptionBundleSet);

        Map<Id, OpportunityLineItem> oppIdToAdoptionBundleMap = new Map<Id, OpportunityLineItem>();
        Set<Id> quoteLinesSet = new Set<Id>();

        for(OpportunityLineItem oli : oliIdToOpportunityLineItemMap.values())
        {
            //Loop through the adoption bundles and find out if the term is less than the quote term
            //If the adoption bundle is less than then we need to create its own adoption bundle
            if(oli.SBQQ__QuoteLine__r.SBQQ__EffectiveSubscriptionTerm__c < oli.Opportunity.Term_in_Months__c)
            {
                //Now we essentially have the opportunity line item to the bundle that we want so we can create our adoption opps
                oppIdToAdoptionBundleMap.put(oli.Id, oli);
            }

        }

        List<Opportunity> oppsToInsert = new List<Opportunity>();

        if(!oppIdToAdoptionBundleMap.isEmpty())
        {
            System.debug('inside adoption Opp Creation ' + oppIdToAdoptionBundleMap);

            //Loop through all the opportunity line items to create adoption opps
            for(OpportunityLineItem oli : oppIdToAdoptionBundleMap.values())
            {
                Contract c  = oppIdToContractMap.get(oli.OpportunityId);
                Opportunity o = originalOppsMap.get(oli.OpportunityId);
                System.debug('inside found contract ' + c);
                Opportunity adoptionOpp = new Opportunity();

                //We will use this relationship to see that an opportunity is a renewal adoption
                //adoptionOpp.Subscription__c = quoteLineIdToSubscriptionIdMap.get(oli.SBQQ__QuoteLine__c);
                adoptionOpp.AdoptionBundle__c = oli.SBQQ__QuoteLine__c;

                adoptionOpp.Type = 'ECUR';

                Double amountTCV = oli.SBQQ__QuoteLine__r.Extended_Price__c*(12.0/oli.SBQQ__QuoteLine__r.SBQQ__EffectiveSubscriptionTerm__c);

                adoptionOpp.Renewed_Contract_Adoption_TCV__c = amountTCV;
                //adoptionOpp.Annual_Contract_Value__c = o.Annual_Contract_Value__c; this is a formula field
                adoptionOpp.Amount = amountTCV;
                adoptionOpp.Original_Amount__c = amountTCV;
                adoptionOpp.Original_Plan_Amount__c = amountTCV;
                adoptionOpp.Partner_License_Fee__c = o.Partner_License_Fee__c;
                adoptionOpp.OEM__c = o.OEM__c;


                adoptionOpp.Agreement_Number__c = o.Agreement_Number__c;
                adoptionOpp.AccountId = o.AccountId;

                //having the fields match the solution overview/acceptance criteria requirements
                adoptionOpp.CloseDate = oli.SBQQ__QuoteLine__r.CustomEndDate__c != null ? oli.SBQQ__QuoteLine__r.CustomEndDate__c : oli.SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c;
                adoptionOpp.Name = o.Account.Name + ' - ECUR Adoption - ' + o.Primary_Contact__r.Name + ' - ' + c.ContractNumber;
                adoptionOpp.StageName = '3 - Negotiate';
                adoptionOpp.Original_Close_Date__c = oli.SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c;
                adoptionOpp.Primary_Contact__c = o.Primary_Contact__c;
                adoptionOpp.OwnerId = o.OwnerId;
                adoptionOpp.SBQQ__RenewedContract__c = c.Id;
                adoptionOpp.CurrencyIsoCode = o.CurrencyIsoCode;
                //adoptionOpp.ForecastCategory = 'BestCase'; this is a formula field
                adoptionOpp.Total_Contract_Value_Amount__c = amountTCV;
                adoptionOpp.Forecast_Amount__c = amountTCV;
                //adoptionOpp.Upside_Forecast_Amount_ACV__c = amountTCV; Sergio Flores 02/21/2020 W-004548
                adoptionOpp.Original_Total_Contract_Value_Amount1__c = amountTCV; //Eddie Wong W-004990 04/07/2020
                adoptionOpp.Original_Term_Length_in_Months__c = 12;
                adoptionOpp.Original_Term_Length_in_Years__c = 1;

                //also make sure new opp has contract dates populated
                adoptionOpp.Contract_Start_Date__c = oli.SBQQ__QuoteLine__r.CustomEndDate__c != null ? oli.SBQQ__QuoteLine__r.CustomEndDate__c.addDays(1) : oli.SBQQ__QuoteLine__r.SBQQ__EffectiveEndDate__c.addDays(1) ;
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


            }


        }


        if(!originalOppsMap.isEmpty())
        {
            System.debug('inside originalOppsMap ' + originalOppsMap);


            for(Opportunity o : originalOppsMap.values())
            {
                Contract c = oppIdToContractMap.get(o.Id);
                System.debug('inside found contract ' + c);
                //SF W-004497 02/18/2020 *updated 4/27/2020
                //If both adoption and subscription are at 0 then there should not be any ECUR created
                if(c.SubscriptionACV__c > 0 || c.Adoption_ACV__c > 0)
                {
                    Opportunity newOpp = new Opportunity();
                    //matching fields to the excel sheet provided

                    //this means there is only adoption
                    if(c.Adoption_TCV__c > 0 && o.SBQQ__PrimaryQuote__r.OSCPQ_Net_ARR__c <= 0 )
                    {
                        o.Amount = c.Adoption_TCV__c;
                        o.Total_Contract_Value_Amount__c = c.Adoption_TCV__c;
                    }
                    //this means there is adoption and regular
                    else if(c.Adoption_ACV__c > 0 && o.SBQQ__PrimaryQuote__r.OSCPQ_Net_ARR__c >= 0)
                        o.Total_Contract_Value_Amount__c = c.SubscriptionTCV__c;

                    //this means there is only adoption
                    if(c.Adoption_ACV__c > 0 && o.SBQQ__PrimaryQuote__r.OSCPQ_Net_ARR__c <= 0)
                        newOpp.Annual_Contract_Value_Amount__c = c.Adoption_ACV__c;
                    //this means there is adoption and regular
                    else if(c.Adoption_ACV__c > 0 && o.SBQQ__PrimaryQuote__r.OSCPQ_Net_ARR__c >= 0)
                        newOpp.Annual_Contract_Value_Amount__c = c.SubscriptionACV__c;
                    //this means there is no adoption
                    else if(c.Adoption_ACV__c <=0 || c.Adoption_ACV__c == null)  //EW || W-005408 || 05/27/2020 || ECUR created with BLANK ACV
                        newOpp.Annual_Contract_Value_Amount__c = o.Annual_Contract_Value_Amount__c;

                    newOpp.Type = 'ECUR';


                    //newOpp.Renewed_Contract_Adoption_TCV__c = o.Renewed_Contract_Adoption_TCV__c;
                    //newOpp.Annual_Contract_Value__c = o.Annual_Contract_Value__c; this is a formula field
                    newOpp.Amount = o.Amount;
                    newOpp.Original_Amount__c = o.Amount;
                    newOpp.Original_Plan_Amount__c = o.Original_Plan_Amount__c;
                    newOpp.Partner_License_Fee__c = o.Partner_License_Fee__c;
                    newOpp.OEM__c = o.OEM__c;


                    newOpp.Agreement_Number__c = o.Agreement_Number__c;
                    newOpp.AccountId = o.AccountId;
                    newOpp.AFG_Opportunity__c = o.AFG_Opportunity__c; // EW || W-005711 || 06/29/2020

                    //having the fields match the solution overview/acceptance criteria requirements
                    newOpp.CloseDate = c.EndDate;
                    newOpp.Name = o.Account.Name + ' - ECUR - ' + o.Primary_Contact__r.Name + ' - ' + c.ContractNumber;
                    newOpp.StageName = '3 - Negotiate';
                    newOpp.Original_Close_Date__c = c.EndDate;
                    newOpp.Primary_Contact__c = o.Primary_Contact__c;
                    newOpp.OwnerId = o.Account.Customer_Success_Advocate__c != null ? o.Account.Customer_Success_Advocate__c : o.OwnerId;  //EW || W-005252 || 05/27/2020 || Owner mapping changes
                    newOpp.SBQQ__RenewedContract__c = c.Id;
                    newOpp.CurrencyIsoCode = o.CurrencyIsoCode;
                    //newOpp.ForecastCategory = 'BestCase'; this is a formula field
                    newOpp.Total_Contract_Value_Amount__c = o.Total_Contract_Value_Amount__c;
                    newOpp.Forecast_Amount__c = newOpp.Annual_Contract_Value_Amount__c;
                    //newOpp.Upside_Forecast_Amount_ACV__c = newOpp.Annual_Contract_Value_Amount__c; Sergio Flores 02/21/2020 W-004548
                    newOpp.Original_Total_Contract_Value_Amount1__c = o.Total_Contract_Value_Amount__c; //Eddie Wong W-004990 04/07/2020

                    //Sergio Flores
                    //Date: 02/25/2020
                    //W-004498
                    integer term = 0;

                    if( c.ContractTerm < 12)
                        term = 12;
                    else
                            term = c.ContractTerm;

                    newOpp.Original_Term_Length_in_Months__c = term;
                    newOpp.Original_Term_Length_in_Years__c = term/12;

                    //also make sure new opp has contract dates populated
                    newOpp.Contract_Start_Date__c = c.EndDate.addDays(1);
                    newOpp.Contract_End_Date__c = newOpp.Contract_Start_Date__c.addMonths(term);
                    newOpp.Contract_End_Date__c = newOpp.Contract_End_Date__c.addDays(-1);
                    newOpp.Term_in_Months__c = term;
                    //newOpp.Best_Case_Term__c = c.ContractTerm; Sergio Flores 02/21/2020 W-004548

                    //Stamp Related Contract SUmmary
                    //this means there is only adoption
                    if(c.Adoption_TCV__c > 0 && o.SBQQ__PrimaryQuote__r.OSCPQ_Net_ARR__c <= 0 )
                    {
                        term = 12;
                        newOpp.Renewed_Contract_Adoption_ACV__c = c.Adoption_TCV__c;
                        newOpp.Renewed_Contract_Adoption_TCV__c = c.Adoption_TCV__c;
                    }
                    else
                            newOpp.Renewed_Contract_Subscription_ACV__c = c.SubscriptionACV__c;

                    newOpp.Max_Term_of_Renewed_Contracts__c = term;

                    oppsToInsert.add(newOpp);
                }

            }

            try
            {
                System.debug('inside inserting renewal opps');
                insert oppsToInsert;
            }
            catch (Exception e) {
                System.debug(e.getMessage());
            }

        }
    }

}