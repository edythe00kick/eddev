public without sharing class OpportunityUtilityClass {

    //Sergio Flores
    //Date: 06/18/2019
    //W-012297
    public static void updateOpportunityTCV(Map<Id, Opportunity> oppIdToOppMap)
    {
        system.debug('inside updateOpportunityTCV ' + oppIdToOppMap);
        //Need Quotes related to the oppIds
        Map<Id, SBQQ__Quote__c> quoteIdToQuoteMap = new Map<Id, SBQQ__Quote__c>([Select Id, SBQQ__NetAmount__c, Effective_Subscription_Term__c, SBQQ__StartDate__c, SBQQ__EndDate__c,
                SBQQ__Opportunity2__c, CustomEndDate__c, OSCPQ_Net_ARR__c, Net_Adoption_Amount__c
        From SBQQ__Quote__c
        Where SBQQ__Opportunity2__c IN : oppIdToOppMap.keySet()
        AND SBQQ__Primary__c = true
        AND Quote_Type__c = 'Purchase']);

        Map<Id, SBQQ__Quote__c> oppIdToPrimaryQuoteMap = new Map<Id, SBQQ__Quote__c>();

        List<SBQQ__Quote__c> quoteList = quoteIdToQuoteMap.values();

        if(!quoteIdToQuoteMap.isEmpty())
        {
            for(SBQQ__Quote__c quote : quoteList)
            {
                oppIdToPrimaryQuoteMap.put(quote.SBQQ__Opportunity2__c, quote);
            }
        }

        List<Opportunity> oppListToUpdate = oppIdToOppMap.values();

        for(Opportunity opp : oppListToUpdate)
        {
            SBQQ__Quote__c primaryQuote = oppIdToPrimaryQuoteMap.get(opp.Id);

            if(primaryQuote !=null)
            {
                system.debug('inside updateOpportunityTCV primary quote not null ' + primaryQuote);
                opp.Total_Contract_Value_Amount__c = primaryQuote.SBQQ__NetAmount__c;
                //if(opp.Best_Case_Term__c < primaryQuote.Effective_Subscription_Term__c) no longer needed due to W-013412
                //opp.Best_Case_Term__c = primaryQuote.Effective_Subscription_Term__c; Sergio Flores 02/21/2020 W-004548
                opp.Term_in_Months__c = primaryQuote.Effective_Subscription_Term__c;
                opp.Contract_Start_Date__c = primaryQuote.SBQQ__StartDate__c;
                if(primaryQuote.SBQQ__EndDate__c !=null)
                    opp.Contract_End_Date__c = primaryQuote.SBQQ__EndDate__c;
                else
                        opp.Contract_End_Date__c = primaryQuote.CustomEndDate__c;
                //opp.Forecast_Amount__c = primaryQuote.SBQQ__NetAmount__c/(primaryQuote.Effective_Subscription_Term__c/12);
                opp.Forecast_Amount__c = primaryQuote.OSCPQ_Net_ARR__c + primaryQuote.Net_Adoption_Amount__c; //Sergio Flores 02/21/2020 W-004548

                //Sergio Flores
                //Date: 10/16/2019
                //W-013412
                //opp.Upside_Forecast_Amount_ACV__c = opp.Forecast_Amount__c; Sergio Flores 02/21/2020 W-004548

                //Sergio Flores
                //Date 01/03/2020
                //W-013733
                opp.Annual_Contract_Value_Amount__c = primaryQuote.OSCPQ_Net_ARR__c + primaryQuote.Net_Adoption_Amount__c; //Sergio Flores 02/21/2020 W-004548

                if(primaryQuote.Effective_Subscription_Term__c < 12 || opp.Total_Contract_Value_Amount__c < opp.Annual_Contract_Value_Amount__c)
                    opp.Annual_Contract_Value_Amount__c = opp.Total_Contract_Value_Amount__c;
            }


        }

    }

    /* Author: Sharma Nemani | W-011617 --> Start
    * Date: 06/10/2019
     * Description: Creating Related Contract on ECUR Opportunity if Renewed Contract exists.
    */
    public static void createRCWithRenewedContract(List<Opportunity> newRecords){
        List<Related_Contract__c> lstRC = new List<Related_Contract__c>();
        for(Opportunity opp : newRecords)
        {
            Related_Contract__c rc = new Related_Contract__c();
            rc.Opportunity__c = opp.Id;
            rc.Contract__c = opp.SBQQ__RenewedContract__c;
            rc.ExternalId__c = (String) opp.SBQQ__RenewedContract__c+(String) opp.Id;
            lstRC.add(rc);
        }
        upsert lstRC ExternalId__c;
    }

    @future
    public static void stampRepTerrCodeOnOpportunity(List<Id> recordIds)
    {
        system.debug('inside stamping rep terr code');
        Set<Id> saoUpdatedUserIds = new Set<Id>(); //this set contains the user ids of opps that got an SAO date updated
        Map<Id,Id> oppToCreatedByIdMap = new Map<Id,Id>();//this will be used to grab the user's field of the user that created the opp
        List<Opportunity> opps2UpdateList = new List<Opportunity>();

        Map<Id,Opportunity> oppIdToOpp = new Map<Id, Opportunity>([Select Id, Rep_Territory_Code__c, CreatedById, SAO_Date__c From Opportunity Where Id IN : recordIds]);

        List<Opportunity> oppList = oppIdToOpp.values();

        for(Opportunity opp : oppList)
        {
            saoUpdatedUserIds.add(opp.CreatedById);
            oppToCreatedByIdMap.put(opp.Id, opp.CreatedById);
        }


        //Find out if the Opp Created By is an LDR, if so then add the LDR's rep terr code to the opp rep terr code

        Map<Id, User> userIdToUserMap = new Map<Id, User>([Select Id, Rep_Territory_Code__c, CY_Sales_Territory_Code__c
        From User
        Where Id IN : saoUpdatedUserIds]);



        system.debug('Inside SAO Update ' + userIdToUserMap);
        if(!userIdToUserMap.isEmpty())
        {
            system.debug('Inside map not empty');
            for(Opportunity opp : oppList)
            {
                Date closeDate = opp.SAO_Date__c;
                User u = userIdToUserMap.get(oppToCreatedByIdMap.get(opp.Id));
                //if the opp closes in 2018 or before, then we need to grab the legacy rep territory code field
                //else use the new sales terr code field
                if(closeDate.year() <= 2018)
                {
                    if(u.Rep_Territory_Code__c != '')
                    {
                        system.debug('Inside Opp Update');
                        opp.Rep_Territory_Code__c = u.Rep_Territory_Code__c;
                        opps2UpdateList.add(opp);
                    }
                }
                else
                {
                    if(u.CY_Sales_Territory_Code__c != '')
                    {
                        opp.Rep_Territory_Code__c = u.CY_Sales_Territory_Code__c;
                        opps2UpdateList.add(opp);
                    }
                }
            }

            try
            {
                //Update opps with Rep Terr Code
                update opps2UpdateList;
            }
            catch(Exception ex)
            {
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }
    }

    @future
    public static void stampRepTerrCodeOnOpportunityClosedWon(List<Id> recordIds)
    {
        //Sergio Flores
        //Date 12/24/2019
        //W-013733
        //Refactor stampRepTerrCodeOnOpportunityClosedWon method along with new requirements
        Map<Id,Id> oppIdToAccountIdMap = new Map<Id, Id>();//needed to see if the opp has a CSM manager in the account and if so we will grab the CSM name
        Set<Id> accountIds = new Set<Id>();
        List<Opportunity> opps2UpdateList = new List<Opportunity>();

        List<Opportunity> closedOppsList = [Select Id, AccountId, Customer_Success_Manager__c, Account_Owner_Rep_Territory_Code__c, CloseDate From Opportunity Where Id IN : recordIds];

        for(Opportunity opp : closedOppsList)
        {
            oppIdToAccountIdMap.put(opp.Id, opp.AccountId);
            accountIds.add(opp.AccountId);
        }



        //Grab the CSA, CSM, and Owner of the Account
        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>([
                Select Id, Customer_Success_Manager__r.CY_Sales_Territory_Code__c, Customer_Success_Advocate__r.CY_Sales_Territory_Code__c, Owner.CY_Sales_Territory_Code__c,
                        Customer_Success_Manager__r.CY_Sales_Team__c, Customer_Success_Advocate__r.CY_Sales_Team__c
                From Account Where Id IN : accountIds]);

        system.debug('Inside userOwnerIdToUserMap '+ accountIdToAccountMap);


        //Sergio Flores
        //Date: 12/31/2019
        //W-013733
        //Check to see if Opportunity contains NFR Bundles, if so then check Partner Fee on all Opp Splits
        //For that opportunity

        string nfrBundles = System.Label.NFRBundles;

        Set<String> nfrBundleSet = new Set<String>();

        for(String s : nfrBundles.Split(',') )
        {
            nfrBundleSet.add(s);
        }

        Map<Id, OpportunityLineItem> oliIdToOpportunityLineItemMap = new Map<Id, OpportunityLineItem>(
        [Select OpportunityId
        From OpportunityLineItem
        Where OpportunityId IN : recordIds
        AND ProductCode IN : nfrBundleSet]
        );

        Map<Id, boolean> oppIdToPartnerFeeMap = new Map<Id, boolean>();

        for(OpportunityLineItem oli : oliIdToOpportunityLineItemMap.values())
        {
            oppIdToPartnerFeeMap.put(oli.OpportunityId, true);
        }

        //Author: Sergio Flores
        //Date: 12/05/2018
        //W-010722
        //Need to stamp Opp Splits related to the Opp that just closed with the Rep Terr Code of the Team Memembers associated to the Split
        //If the Opp is closed in 2018 year, then use legacy Rep Terr Code, if the Opp is closed after 2018, then use new Rep Terr Cod
        //List of Opp Splits that need to be updated
        List<OpportunitySplit> oppSplitList = [
                Select Opportunity.Id, SplitOwner.Rep_Territory_Code__c,
                        SplitOwner.CY_Sales_Territory_Code__c, Rep_Territory_Code__c, SplitOwner.CY_Sales_Team__c, SplitType.DeveloperName, //SF W-004696 03/12/2020
                        Customer_Success_Manager_Team__c, Customer_Success_Advocate_Team__c, Customer_Success_Manager_RTC__c, Customer_Success_Advocate_RTC__c
                From OpportunitySplit Where OpportunityId IN : recordIds ];

        system.debug('OppSplitList ' + oppSplitList);
        List<OpportunitySplit> oppSplitToUpdateList = new List<OpportunitySplit>();

        if(!oppSplitList.isEmpty())
        {
            for(OpportunitySplit oppSplit : oppSplitList)
            {
                //Return the account related to the closed opp and now you have all the fields you need
                Account acc = accountIdToAccountMap.get(oppIdToAccountIdMap.get(oppSplit.Opportunity.Id));

                //Return true if the opportunity has a NFR Bundle, if null then do nothing
                Boolean hasNFRBundle = oppIdToPartnerFeeMap.get(oppsplit.Opportunity.Id);
                system.debug('hasNFRBundle ' + hasNFRBundle);

                if(hasNFRBundle!= null && hasNFRBundle)
                    oppSplit.Partner_Fee__c = true;

                //Stamp Rep Territory Code
                if(oppSplit.SplitOwner.CY_Sales_Territory_Code__c != '')
                {
                    oppSplit.Rep_Territory_Code__c = oppSplit.SplitOwner.CY_Sales_Territory_Code__c;
                }

                //Stamp Sales Team
                if(oppSplit.SplitType.DeveloperName == 'Overlay')
                    oppSplit.Sales_Team__c = oppSplit.SplitOwner.CY_Sales_Team__c;

                //CSA Team, CSM Team, CSA RTC, CSM RTC
                if(acc !=null)
                {
                    //Sergio Flores
                    //Date: 04/17/2020
                    //W-004676
                    if(oppSplit.SplitType.DeveloperName == 'Revenue')
                    {
                        oppSplit.Customer_Success_Manager_Team__c = acc.Customer_Success_Manager__r.CY_Sales_Team__c;
                        oppSplit.Customer_Success_Advocate_Team__c = acc.Customer_Success_Advocate__r.CY_Sales_Team__c;
                    }
                    oppSplit.Customer_Success_Manager_RTC__c = acc.Customer_Success_Manager__r.CY_Sales_Territory_Code__c;
                    oppSplit.Customer_Success_Advocate_RTC__c = acc.Customer_Success_Advocate__r.CY_Sales_Territory_Code__c;
                }

                oppSplitToUpdateList.add(oppSplit);

                try {
                    Database.Update(oppSplitToUpdateList,false);
                }
                catch(Exception ex) {
                    system.debug('inside catch exception');
                    trigger.new[0].addError(ex.getMessage());
                }
            }

        }

        //********************Logic to Update Opp Account Owner Rep Territory Code */
        if(!accountIdToAccountMap.isEmpty())
        {
            for(Opportunity opp : closedOppsList)
            {
                //Return the account related to the closed opp and now you have all the fields you need
                Account acc = accountIdToAccountMap.get(oppIdToAccountIdMap.get(opp.Id));

                if(acc != null)
                {
                    if(acc.Owner.CY_Sales_Territory_Code__c != '')
                    {
                        system.debug('Inside Opp Owner Update');
                        opp.Account_Owner_Rep_Territory_Code__c = acc.Owner.CY_Sales_Territory_Code__c;
                    }

                    if(acc.Customer_Success_Manager__r.CY_Sales_Territory_Code__c != '')
                    {
                        opp.Customer_Success_Manager__c = acc.Customer_Success_Manager__r.CY_Sales_Territory_Code__c;
                    }
                }

                opps2UpdateList.add(opp);
            }

            try
            {
                //Update opps with Rep Terr Code
                update opps2UpdateList;
            }
            catch(Exception ex)
            {
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }
        /*End of logic to update Account Owner Rep Territory Code */

    }

    //Sergio Flores
    //Date: 06/20/2019
    //Stamp Forecast Modified Date on Opp Split when forecast fields on Opp are changed
    public static void stampRepForecastModifiedDate(Set<Id> recordIds)
    {
        system.debug('inside stampRepForecastModifiedDate ' + recordIds);

        List<OpportunitySplit> oppSplitList = [Select Id, Split_Number__c, Forecast_Modified_Date__c, Opportunity.LastModifiedDate
        From OpportunitySplit Where OpportunityId IN : recordIds ];

        if(!oppSplitList.isEmpty())
        {
            List<OpportunitySplit> oppSplitToUpdate = new List<OpportunitySplit>();

            for(OpportunitySplit os : oppSplitList)
            {
                system.debug('inside stampRepForecastModifiedDate for loop' + os);
                os.Forecast_Modified_Date__c = os.Opportunity.LastModifiedDate;
                oppSplitToUpdate.add(os);
            }

            try {
                if(!oppSplitToUpdate.isEmpty())
                    Database.Update(oppSplitToUpdate,false);
            }
            catch(Exception ex) {
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }
    }

    /* Author: Sergio Flores
    * Date: 10/15/2019
     * W-012796
    */

    public static void updateContractWithRenewalOpp(Map<Id, Id> oppIdContractToRenewalId){
        List<Contract> contractsToUpdateList = new List<Contract>();

        for(Id oppId : oppIdContractToRenewalId.keySet())
        {
            Id contractId = oppIdContractToRenewalId.get(oppId);
            Contract c = new Contract();
            c.Id = contractId;
            c.SBQQ__RenewalOpportunity__c = oppId;
            c.Create_Renewal_Opportunity__c = false;
            contractsToUpdateList.add(c);
        }

        if(!contractsToUpdateList.isEmpty())
        {
            update contractsToUpdateList;
        }
    }


    //Sergio Flores
    //Date: 01/15/2020
    //W-013849
    public static void populateSubscriptionAdoptionRenewalOpp(Set<Id> adoptionBundleIds, Map<String, Opportunity> contractAdoptionIdToOppMap, Set<Id> contractIds){
        //Look for all subscriptions with the adoption name and the contract related
        List<SBQQ__Subscription__c> subscriptions =
        [Select Id, Adoption_Renewal_Opportunity__c, SBQQ__Contract__c, SBQQ__QuoteLine__r.SBQQ__RequiredBy__c, SBQQ__QuoteLine__r.Id
        From SBQQ__Subscription__c
        Where SBQQ__Contract__c IN : contractIds
        AND (SBQQ__QuoteLine__r.SBQQ__RequiredBy__c IN : adoptionBundleIds OR SBQQ__QuoteLine__r.Id IN : adoptionBundleIds)
        ];

        system.debug('inside populateSubscriptionAdoptionRenewalOpp' + subscriptions + contractAdoptionIdToOppMap + adoptionBundleIds + contractIds);

        List<SBQQ__Subscription__c> subscriptionsToUpdate = new List<SBQQ__Subscription__c>();

        //Loop through all the subscriptions found and populate the Adoption Renewal Opportunity
        //with newly created Opp
        for(SBQQ__Subscription__c sub : subscriptions)
        {
            Opportunity opp = contractAdoptionIdToOppMap.get((String)sub.SBQQ__Contract__c + (String)sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);

            if(opp != null)
            {
                sub.Adoption_Renewal_Opportunity__c = opp.Id;
                subscriptionsToUpdate.add(sub);
            }
            else
            {
                opp = contractAdoptionIdToOppMap.get((String)sub.SBQQ__Contract__c + (String)sub.SBQQ__QuoteLine__r.Id);

                if(opp !=null)
                {
                    sub.Adoption_Renewal_Opportunity__c = opp.Id;
                    subscriptionsToUpdate.add(sub);
                }
            }

        }

        if(!subscriptionsToUpdate.isEmpty())
        {
            update subscriptionsToUpdate;
        }

    }

    /* Author: Sergio Flores
    * Date: 10/15/2019
     * W-012796
    */
    public static void createContactRoleForECUR(List<Opportunity> contactRolesToCreateList){
        List<OpportunityContactRole> oppContactRolesList = new List<OpportunityContactRole>();

        for(Opportunity opp : contactRolesToCreateList )
        {
            System.debug('eddie inside createContactRoleForECUR' + opp.Id);
            System.debug('eddie inside createContactRoleForECUR' + opp.Primary_Contact__c);

            OpportunityContactRole ocr = new OpportunityContactRole();
            ocr.OpportunityId = opp.Id;
            ocr.ContactId = opp.Primary_Contact__c;
            ocr.IsPrimary = true;
            oppContactRolesList.add(ocr);
        }

        if(!oppContactRolesList.isEmpty())
        {
            insert oppContactRolesList;
        }
    }

    //Author: Sergio Flores
    //Date: 10/16/2019
    //W-013143
    //Commenting now for 10/22/2019 Release
    /*public static void checkOverlaySplitOnClosedWon(Map<Id, Opportunity> oppIdToOppMap)
    {
        Map<Id, OpportunitySplit> oppSplitIdToOppSplit = new Map<Id, OpportunitySplit>([Select SplitTypeId
        From OpportunitySplit
        Where Opportunity.Id IN :  oppIdToOppMap.keySet()]);

        boolean needsOverlaySplitCheck = false;

        for(OpportunitySplit os : oppSplitIdToOppSplit.values())
        {
            //check to see if there's is no overlay split 
            if(os.SplitTypeId != Label.OverlayOpportunitySplitId)
            needsOverlaySplitCheck = true;
        }

        
        if(!oppSplitIdToOppSplit.isEmpty() && needsOverlaySplitCheck)
        {
            //Check if there is a var/collaborative sale as a partner
            Map<Id, Custom_Partner__c> customPartnerIdToCPMap = new Map<Id, Custom_Partner__c>([Select IsPrimary__c, OpportunityId__c, Role__c, OpportunityId__r.Account.Business_Development_Owner__c
            From Custom_Partner__c
            Where OpportunityId__c IN : oppIdToOppMap.keySet()]);

            system.debug('inside checkOverlaySplitOnClosedWon ' + customPartnerIdToCPMap);

            if(!customPartnerIdToCPMap.isEmpty())
            {
                List<OpportunitySplit> oppSplitToInsert =  new List<OpportunitySplit>();
                List<OpportunityTeamMember> oppTeamMembersList = new List<OpportunityTeamMember>();

                boolean needToCreateOverlaySplit = false;

                for(Custom_Partner__c cp : customPartnerIdToCPMap.values())
                {
                    if(cp.Role__c == 'Value Added Reseller' || cp.Role__c == 'Collaborative Sale')
                    {
                        Opportunity opp = oppIdToOppMap.get(cp.OpportunityId__c);

                        OpportunitySplit oppSplit = new OpportunitySplit();
                        oppSplit.OpportunityId = opp.Id;
                        oppSplit.SplitOwnerId = cp.OpportunityId__r.Account.Business_Development_Owner__c;
                        oppSplit.SplitTypeId = Label.OverlayOpportunitySplitId;
                        oppSplit.SplitPercentage = 100;
                        oppSplitToInsert.add(oppSplit);

                        needToCreateOverlaySplit = true; 
                    }
                }

                if(needToCreateOverlaySplit)
                {
                    //Need to check if opp already has a related opp team member
                    Map<Id, OpportunityTeamMember> oppTeamMemberIdToOTM = new Map<Id, OpportunityTeamMember>([Select TeamMemberRole, OpportunityId, Opportunity.Account.Business_Development_Owner__c
                    From OpportunityTeamMember
                    Where OpportunityId IN : oppIdToOppMap.keySet()
                    AND Opportunity.Account.Business_Development_Owner__c != null]);                    

                    for(OpportunityTeamMember oppTeamMember : oppTeamMemberIdToOTM.values())
                    {
                        if(oppTeamMember.TeamMemberRole != 'Business Development Representative')
                        {
                            Opportunity opp = oppIdToOppMap.get(oppTeamMember.OpportunityId);

                            //Need to create Opp Team Members before creating splits
                            OpportunityTeamMember otm = new OpportunityTeammember();
                            otm.OpportunityId= opp.Id;
                            otm.TeamMemberRole='Business Development Representative';
                            otm.userId = oppTeamMember.Opportunity.Account.Business_Development_Owner__c;
                            oppTeamMembersList.add(otm);
                        }
                    }

                    
                }

                //Insert the lists if they are not empty
                if(!oppTeamMembersList.isEmpty() && !oppSplitToInsert.isEmpty())
                {
                    insert oppTeamMembersList;
                    insert oppSplitToInsert;
                }
                    
            }
        }
    }*/


    //Sergio Flores
    //Date 12/18/2019
    //W-013113
    public static void updateOppSplitOnOppClosed(Map<Id, String> oppIdToOppOwnerRoleMap){
        system.debug('inside updateOppSplitOnOppClosed ' + oppIdToOppOwnerRoleMap);
        //Query the oppsplit to stamp
        Map<Id, OpportunitySplit> oppSplitIdToOppSplitMap = new Map<Id, OpportunitySplit>([
                Select OpportunityId, Opportunity_Split_User_Role__c, Split_Owner_Role__c, Opportunity_Owner_Role__c
                From OpportunitySplit
                Where OpportunityId IN : oppIdToOppOwnerRoleMap.keySet()
        ]);

        List<OpportunitySplit> oppSplitsToUpdateList = new List<OpportunitySplit>();

        if(!oppSplitIdToOppSplitMap.isEmpty())
        {
            for(OpportunitySplit os : oppSplitIdToOppSplitMap.values())
            {
                String oppOwnerRole = oppIdToOppOwnerRoleMap.get(os.OpportunityId);

                if(oppOwnerRole !=null)
                    os.Opportunity_Owner_Role__c = oppOwnerRole;

                os.Split_Owner_Role__c = os.Opportunity_Split_User_Role__c;

                oppSplitsToUpdateList.add(os);
            }
        }

        if(!oppSplitsToUpdateList.isEmpty())
        {
            update oppSplitsToUpdateList;
        }

    }
}