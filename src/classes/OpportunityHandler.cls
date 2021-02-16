public with sharing class OpportunityHandler
{
    Set<String> accountIdSet = new Set<String>();
    Map<Id, Account> accounts_map = new Map<Id, Account>();
    // Added by Oshin on April 27, 2016
    Set<String> stage_close_vals = new Set<String>();
    Set<Id> sao_contact_ids = new Set<Id>();
    AYX_Org_Rules_Toggle__c alteryxToggle = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
    public static Map<String, Double> conversionRatesMap = UtilityClass.getConversionRates();  //EW 05/19/2020 W-005264

    // Constructor
    public OpportunityHandler()
    {
        // Added by Oshin on April 27, 2016
        //commented by Pulkit stage_close_vals.add('6.5 - Pending Review');
        stage_close_vals.add('5 - Closed Won');
        stage_close_vals.add('Closed Lost');
        stage_close_vals.add('Disqualified');
    }

    //****************************************************************************************
    //Sergio Flores
    //Modifying OpportunityHandler to align with Trigger methods

    public void onBeforeInsert(List<Opportunity> newRecords)
    {

        OpportunityGateway.allowOpportunityIfLoggedInUserExistInAccountTeam(newRecords[0]); // Added by: Sharma Nemani | W-010857 | Date: 08/08/2019
        Set<Id> account_ids = new Set<Id>();
        Set<Id> oppRenewedContractIds = new Set<Id>();
        //Set<Id> primaryContactIds = new Set<Id>(); //EW || 05/07/2020 || W-005264 || Comment out to move currency conversion from Before to After
        Set<Id> partnerContactIds = new Set<Id>();
        Set<Id> gtmPrimaryContactIds = new Set<Id>();

        system.debug('inside on before insert');
        //Author: Sergio Flores
        //Date 11-16-2018
        //W-010661
        System.debug('eddie inside newRecords' + newRecords);

        for(Opportunity opp : newRecords)
        {
            //Sergio Flores
            //Date: 1/15/2018
            //W-010928
            //When an opportunity is created, the TCV should be the same as amount
            //Due to new requirements W-010943, now the TCV should be calcualted
            //based on the Term In Months inputed
            system.debug('inside updating tcv before '+ opp.Forecast_Amount__C + ' ' + opp.Term_In_Months__c);
            if(opp.Forecast_Amount__C != null && opp.AdoptionBundle__c == null && opp.Term_In_Months__c!=null)
            {
                opp.Total_Contract_Value_Amount__c = opp.Forecast_Amount__C*(opp.Term_In_Months__c/12);
                if(opp.Term_In_Months__c >=12)
                    opp.Annual_Contract_Value_Amount__C = opp.Forecast_Amount__C; //SF 03/31/2020 W-004884 //EW 05/19/2020 W-005264
                else
                        opp.Annual_Contract_Value_Amount__C = opp.Total_Contract_Value_Amount__c; //SF 03/31/2020 W-004884
            }

            if(opp.Type != 'NB')
            {
                opp.NB_Commission_Logo__c = false;
            }
            if(opp.Type == 'NB')
            {
                opp.NB_Commission_Logo__c = true;
            }

            if((opp.Type == 'NB' || opp.Type == 'NBEC')
                    && opp.StageName == System.label.StageName_F
                    && opp.AccountId != null) {

                account_ids.add(opp.AccountId);

            }
            //Author: Eddie Wong
            //Date 08-16-2019
            //W-012826
            //Modified logic: If opp is NFR, Assign NFR Price Book to the Opp's Price Book; else assign Standard Price Book
            if(opp.PriceBook2Id == null && opp.NFR_Opportunity__c == false)
                opp.PriceBook2Id = System.Label.StandardPriceBookID;
            else if(opp.NFR_Opportunity__c)
                opp.PriceBook2Id = System.Label.NFRPriceBookID;

            //Sergio Flores
            //Date: 06/11/2019
            //W-012192
            //Standard Opp Creation
            if( (opp.Type == 'NB' || opp.Type == 'NBEC') && opp.SBQQ__RenewedContract__c ==null && opp.SBQQ__AmendedContract__c ==null)
            {
                system.debug('inside standard opp creation ' + opp);
                if(opp.CloseDate != null && opp.Term_In_Months__c !=null)
                {
                    opp.Contract_Start_Date__c = opp.CloseDate.addDays(1);
                    opp.Contract_End_Date__c = opp.Contract_Start_Date__c.addMonths(integer.valueOf(opp.Term_In_Months__c));
                    opp.Contract_End_Date__c = opp.Contract_End_Date__c.addDays(-1);
                }

            }

            //Sergio Flores
            //Date: 06/11/2019
            //W-012192
            //Renewed or Amended Opp
            if( /*(opp.Type == 'NBEC' || opp.Type == 'ECUR') && (opp.SBQQ__RenewedContract__c !=null ||*/  opp.SBQQ__AmendedContract__c !=null )
            {__
                /*if(opp.SBQQ__RenewedContract__c !=null)
                oppRenewedContractIds.add(opp.SBQQ__RenewedContract__c);
                else*/
                oppRenewedContractIds.add(opp.SBQQ__AmendedContract__c);
                system.debug('inside Renewed or Amended Opp ' + opp);
            }

            //Sergio Flores
            //Date: 06/15/2019
            //W-012281
            if(opp.Primary_Contact__c !=null)
            {
                // primaryContactIds.add(opp.Primary_Contact__c); //EW || 05/07/2020 || W-005264 || Comment out to move currency conversion from Before to After

                //Name: Chris Salgado
                //Date: 10/24/2019
                //Purpose: W-012834
                if(opp.Partner_Contact__c == null)
                {
                    partnerContactIds.add(opp.Primary_Contact__c);
                }
            }

            //Sergio Flores
            //Date 12/18/2019
            //W-013113
            if(opp.Opportunity_Owner_Role__c !=null)
                opp.Opportunity_Owner_Role_Stamp__c = opp.Opportunity_Owner_Role__c;

            /**
             * @Name Eddie Wong
             * @Work W-007075
             * @Date 1/20/2021
             * @Description Global Ranking field stamping on opp before insert
            */
            gtmPrimaryContactIds.add(opp.Primary_Contact__c);

        }

            /**
             * @Name Eddie Wong
             * @Work W-007075
             * @Date 1/20/2021
             * @Description Global Ranking field stamping on opp before insert
            */
        if(!gtmPrimaryContactIds.isEmpty()){
            OpportunityGateway.stampGTMGlobalRankingOnOpp(gtmPrimaryContactIds, newRecords);
        }

        //Name: Chris Salgado
        //Date: 10/24/2019
        //Purpose: W-012834
        if(!partnerContactIds.isEmpty())
        {
            OpportunityGateway.getPartnerContactFromPrimary(partnerContactIds, newRecords);
        }

        //Sergio Flores
        //Date: 06/15/2019
        //W-012281
        /* //EW || 05/07/2020 || W-005264 || Comment out to move currency conversion from Before to After
        if(!primaryContactIds.isEmpty())
        {
            OpportunityGateway.syncPrimaryContactCurrencytoOpp(primaryContactIds, newRecords);
        }
        */

        accounts_map = OpportunityGateway.getOppAccount(account_ids);

        if(!oppRenewedContractIds.isEmpty())
        {
            system.debug('inside oppRenewedContractIds ' + oppRenewedContractIds);
            Map<Id, Contract> renewedContractToOppMap = new Map<Id, Contract>([Select Id, StartDate, EndDate, ContractTerm, SBQQ__Opportunity__r.Primary_Contact__c,
                    SBQQ__Opportunity__r.Primary_Contact__r.Name,  ContractNumber, SBQQ__Opportunity__r.Type, SBQQ__Opportunity__r.Account.Name, SBQQ__Opportunity__r.Amount,
                    //SBQQ__Opportunity__r.Best_Case_Term__c, Sergio Flores 02/21/2020 W-004548
                    SBQQ__Opportunity__r.Forecast_Amount__C
            From Contract Where ID IN : oppRenewedContractIds]);

            //Sergio Flores
            //Date: 06/11/2019
            //W-012192
            if(!renewedContractToOppMap.isEmpty())
            {
                OpportunityGateway.stampContractStartDate(renewedContractToOppMap, newRecords);
            }
        }


        if(!accounts_map.isEmpty())
        {
            for(Opportunity opp : newRecords)
            {
                if(opp.AccountId != NULL && accounts_map.containsKey(opp.AccountId))
                {

                    Id umbrella_owner = accounts_map.get(opp.AccountId).Enterprise_Expand_Geo_Owner__c;
                    if(umbrella_owner != null) {

                        opp.Headquarter_Owner__c = umbrella_owner;
                        if(opp.Type == 'NB') {

                            opp.Headquarter_Percentage_Kicker__c = 2;

                        } else if(opp.Type == 'NBEC') {

                            opp.Headquarter_Percentage_Kicker__c = 4;

                        }

                    }

                }
            }
        }


    }

    public void onAfterInsert(List<Opportunity> newRecords)
    {
        system.debug('inside onafterinsert opphandler' + newRecords);
        Set<Id> conIds = new Set<Id>();

        List<Opportunity> oppRCWithRenewedContractList = new List<Opportunity>();
        Map<Id, Id> oppIdContractToRenewalId = new Map<Id, Id>();
        List<Opportunity> contactRolesToCreateList = new List<Opportunity>();
        Set<Id> adoptionBundleIds = new Set<Id>(); //SF 01/15/2020 W-013849
        Set<Id> contractIds = new Set<Id>(); //SF 01/15/2020 W-013849
        Set<Id> PrimaryContactIds = new Set<Id>(); //EW 05/07/2020 W-005264
        Map<String, Opportunity> contractAdoptionIdToOppMap = new Map<String, Opportunity>();


        for(Opportunity opp : newRecords)
        {
            if(opp.SBQQ__RenewedContract__c !=null)
            {
                oppRCWithRenewedContractList.add(opp);
                if(opp.AdoptionBundle__c == null)
                    oppIdContractToRenewalId.put(opp.Id, opp.SBQQ__RenewedContract__c);

                if(opp.Primary_Contact__c != null)
                    contactRolesToCreateList.add(opp);

                //Sergio Flores
                //Date: 01/15/2020
                //W-013849
                if(opp.AdoptionBundle__c != null)
                {
                    adoptionBundleIds.add(opp.AdoptionBundle__c);
                    contractIds.add(opp.SBQQ__RenewedContract__c);
                    contractAdoptionIdToOppMap.put((String)opp.SBQQ__RenewedContract__c + (String)opp.AdoptionBundle__c, opp);
                }
            }

            if(opp.Primary_Contact__c != null) //Checking if the Primary Contact is not Null.
                conIds.add(opp.Primary_Contact__c);
                PrimaryContactIds.add(opp.Primary_Contact__c); //EW 05/07/2020 W-005264
        }

        // Eddie Wong
        // 05/07/2020
        // W-005264
        if(!PrimaryContactIds.isEmpty())
        {
            OpportunityGateway.syncPrimaryContactCurrencytoOpp(primaryContactIds, newRecords);
        }

        if(!contractAdoptionIdToOppMap.isEmpty())
        {
            OpportunityUtilityClass.populateSubscriptionAdoptionRenewalOpp(adoptionBundleIds, contractAdoptionIdToOppMap, contractIds);
        }

        if(!oppRCWithRenewedContractList.isEmpty())
        {
            OpportunityUtilityClass.createRCWithRenewedContract(oppRCWithRenewedContractList);
            //Author: Sergio Flores * Date: 10/15/2019 * W-012796
            OpportunityUtilityClass.updateContractWithRenewalOpp(oppIdContractToRenewalId);
        }

        if(!contactRolesToCreateList.isEmpty())
        {
            //Author: Sergio Flores * Date: 10/15/2019 * W-012796
            OpportunityUtilityClass.createContactRoleForECUR(contactRolesToCreateList);
        }


        //Sharma Nemani | Date: 03/29/2019 | W - 011067 & W-011315 | Case: 00260714 & Case: 00260711
        if(!conIds.isEmpty())
            OpportunityGateway.updatePrimaryContact(conIds);

        OpportunityGateway.createOppTeamMember(Trigger.newMap.Keyset());

    }

    public void onBeforeUpdate(List<Opportunity> newRecords){
        Set<Id> account_ids = new Set<Id>();
        List<Id> saoUpdatedOppsIds = new List<Id>();
        List<Id> closedOppsIds = new List<Id>();
        //Set<Id> primaryContactIds = new Set<Id>(); //EW || 05/07/2020 || W-005264 || Comment out to move currency conversion from Before to After
        Set<Id> partnerContactIds = new Set<Id>();
        //Commented for 2019-12-05 Release
        Set<Id> forcastUpdateOpps = new Set<Id>(); // added by sharma || 19 NOV 2019
        Map<Id, Opportunity> oppIdToOppMap = new Map<Id, Opportunity>();//This is just for making a map for tcv when opp is closed
        Map<Id, Opportunity> oppIdToOppNotWonMap = new Map<Id, Opportunity>();//This is just for making a map for tcv when opp is open

        String usrProfileName;
        if( StaticVariables.usrProfileName == null)
        {
            usrProfileName = [SELECT u.Profile.Name FROM User u WHERE u.Id = :UserInfo.getUserId()].Profile.Name;
            StaticVariables.usrProfileName = usrProfileName;
        }
        else
        {
            usrProfileName = StaticVariables.usrProfileName;
        }

        if (usrProfileName != null) {
            OpportunityGateway.validateOpportunity();
        }

        String adminProfiles = System.Label.QuoteAdminProfiles;

        Boolean updateAllowed = false;
        //if(usrProfileName != null && usrProfileName != '') { //EW || W-005162 || 07/15/2020 || To exclude automated process user through the co-term process
        if (usrProfileName != null && adminProfiles.contains(usrProfileName)) { // EW || W-005162 || 09/09/2020 || Added null check on usrProfileName to bypass amendment api process
            updateAllowed = true;
        }
        //}

        Map<Id,opportunity> mapOpp = new Map<Id,opportunity>([select id, CurrencyIsoCode  from opportunity where Id IN:newRecords]);  //EW 05/19/2020 W-005264

        for(Opportunity opp : newRecords){

            Opportunity opp_old = (Opportunity) Trigger.oldMap.get(opp.id);

            //Commented for 2019-12-05 Release
            // Added by: Sharma Nemani | W-013367 | Date: 11/12/2019 --> START
            // If Forecast Update is changed, then stamp it on Forecast Category.
            if(opp.Forecast_Update__c !=  opp_old.Forecast_Update__c){
                opp.ForecastCategoryName = opp.Forecast_Update__c;
                // added by sharma || 19 NOV 2019 || send email to owner if forcast update is changed
                forcastUpdateOpps.add(opp.Id);
            }
            // Sharma Nemani | W-013367 | Date: 11/12/2019 --> END

            if((opp.Type == 'NB' || opp.Type == 'NBEC')
                    && opp.StageName == System.label.StageName_F
                    && opp.StageName != opp_old.StageName
                    && opp.AccountId != null) {

                account_ids.add(opp.AccountId);

            }

            if(opp.PriceBook2Id == null){
                opp.PriceBook2Id = System.Label.StandardPriceBookID;
            }

            //Sergio Flores
            //Date: 06/18/2019
            //W-012297
            if((opp.Forecast_Amount__C != opp_old.Forecast_Amount__C) || (opp.Term_In_Months__c != opp_old.Term_In_Months__c) && !opp.iswon && opp.Sync_Quote_TCV__c != true)
            {
                system.debug('inside tcv update ' + opp);
                if(opp.Term_In_Months__c !=null && opp.Forecast_Amount__C!=null)
                {
                    opp.Total_Contract_Value_Amount__c = (opp.Forecast_Amount__C*(opp.Term_In_Months__c/12))*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode); //EW 05/19/2020 W-005264
                    if(opp.Term_In_Months__c >=12)
                        opp.Annual_Contract_Value_Amount__C = opp.Forecast_Amount__C*conversionRatesMap.get(mapOpp.get(opp.Id).CurrencyIsoCode); //SF 03/31/2020 W-004884 //EW 05/19/2020 W-005264
                    else
                            opp.Annual_Contract_Value_Amount__C = opp.Total_Contract_Value_Amount__c; //SF 03/31/2020 W-004884
                }

            }


            if(opp.SAO_Date__c != opp_old.SAO_Date__c && opp.SAO_Date__c !=null)
            {
                system.debug('Inside SAO Date');
                saoUpdatedOppsIds.add(opp.Id);
                //saoUpdatedUserIds.add(opp.CreatedById);
                //oppToCreatedByIdMap.put(opp.Id, opp.CreatedById);
            }
            if(opp.iswon && opp_old.isClosed == false)
            {
                closedOppsIds.add(opp.Id);
                oppIdToOppMap.put(opp.Id, opp);
                //Below is needed to grab the CSM User
                /*oppIdToAccountIdMap.put(opp.Id, opp.AccountId);
                accountIds.add(opp.AccountId);*/
                system.debug('Inside opp is closed');
                //Author: Sergio Flores
                //Date: 12/14/2018
                //W-010614
                if(opp.Type == 'ECUR')
                {
                    if(opp.Original_Close_Date__c !=null)
                    {
                        //Author: Sergio Flores
                        //Date: 12/14/2018
                        //W-011237
                        //Readjusting to accomadate if the Close date is greater than original close date scenario
                        /*if(opp.CloseDate <= opp.Original_Close_Date__c )
                        opp.Commission_Date__c = opp.Original_Close_Date__c;
                        else if (opp.CloseDate.month() == opp.Original_Close_Date__c.month() && opp.CloseDate.year() == opp.Original_Close_Date__c.year())
                        opp.Commission_Date__c = opp.Original_Close_Date__c;
                        else if(opp.CloseDate > opp.Original_Close_Date__c && (opp.CloseDate.day() > 7) )
                        opp.Commission_Date__c = opp.CloseDate;
                        else if( opp.CloseDate > opp.Original_Close_Date__c && (opp.CloseDate.day() < 7) && (opp.CloseDate.month() - 1 ==  opp.Original_Close_Date__c.month()))
                        opp.Commission_Date__c = opp.Original_Close_Date__c;
                        else
                        opp.Commission_Date__c = opp.Original_Close_Date__c;*/

                        //Author: Sergio Flores
                        //Date: 06/12/2019
                        //W-012246
                        if(opp.CloseDate <= opp.Original_Close_Date__c )
                            opp.Commission_Date__c = opp.Original_Close_Date__c;
                        else if(opp.CloseDate > opp.Original_Close_Date__c)
                            opp.Commission_Date__c = opp.CloseDate;
                    }
                    else
                    {
                        opp.Commission_Date__c = opp.CloseDate;
                    }

                }
            }
            //Author: Sergio Flores
            //Date: 10-8-2018
            //W-010408
            if(opp.iswon && (!opp_old.iswon))
            {
                system.debug('Inside closed won');
                //ECUR commission dates are being handled on the OpportunityHandler
                if(opp.Type != 'ECUR')
                {
                    opp.Commission_Date__c = opp.CloseDate;
                }
                opp.Commission_Amount__c = opp.Amount;
                opp.Date_Stage_Moved_to_7_Closed_Won__c  = date.today();
            }
            if(opp.Amount != opp_old.Amount)
            {
                opp.Commission_Amount__c = opp.Amount;
            }
            //ECUR commission dates are being handled on the OpportunityHandler
            if(opp.CloseDate != opp_old.CloseDate && opp.Type != 'ECUR')
            {
                opp.Commission_Date__c = opp.CloseDate;
            }
            //Author: Sergio Flores
            //Date 11-16-2018
            //W-010661
            if(opp.Type != 'NB' && opp_old.Type == 'NB')
            {
                opp.NB_Commission_Logo__c = false;
            }
            if(opp.Type == 'NB' && opp_old.Type != 'NB')
            {
                opp.NB_Commission_Logo__c = true;
            }

            //Sergio Flores
            //Date: 06/15/2019
            //W-012281
            /* EW || 05/07/2020 || W-005264 || Comment out to move currency conversion from Before to After
            if(opp.Primary_Contact__c !=null && opp.Primary_Contact__c != opp_old.Primary_Contact__c && opp.SBQQ__PrimaryQuote__c == null)
            {
                primaryContactIds.add(opp.Primary_Contact__c);
            }
            */

            //Sergio Flores
            //Date: 06/18/2019
            //W-012297
            //Here we only want to update the tcv from the quote if the opp isn't closed and there is primary quote
            if(  (opp.Sync_Quote_TCV__c != opp_old.Sync_Quote_TCV__c && opp.Sync_Quote_TCV__c && opp.SBQQ__PrimaryQuote__c !=null && !opp.iswon)
                    ||
                    (opp.Sync_Quote_TCV__c && RecursionHandler.IsquoteUpdatedTCV) ) //SF 02/21/2020 W-004548
            {
                system.debug('inside updating opp tcv ' + opp);
                oppIdToOppNotWonMap.put(opp.Id, opp);
            }
            //Sergio Flores
            //Date:02/21/2020
            //W-004548
            ///Here we need to check if the opportunity got updated by a rep and the sync quote tcv is true and quoteUpdatedTcv = false
            //If the above conditions are met, then display an error the the user that they can't update the TCV, ACV, ForecastACV, or Term
            else if (opp.Sync_Quote_TCV__c && !RecursionHandler.IsquoteUpdatedTCV && opp.SBQQ__PrimaryQuote__c !=null && updateAllowed == false
                    && (opp.Total_Contract_Value_Amount__c != opp_old.Total_Contract_Value_Amount__c
                    || opp.Annual_Contract_Value_Amount__C != opp_old.Annual_Contract_Value_Amount__C
                    || opp.Forecast_Amount__C != opp_old.Forecast_Amount__C
                    || opp.Term_In_Months__c != opp_old.Term_In_Months__c)
                    )
            {
                opp.addError('The following fields are locked when Sync Quote is checked: TCV/ACV, Forecast Amount, Term in Months. Uncheck Sync Quote to proceed or update the primary quote.');
            }


            //Name: Chris Salgado
            //Date: 10/24/2019
            //Purpose: W-012834
            if(!opp.iswon && opp.Primary_Contact__c !=null && opp.Primary_Contact__c != opp_old.Primary_Contact__c)
            {
                partnerContactIds.add(opp.Primary_Contact__c);
            }

            //Sergio Flores
            //Date 12/18/2019
            //W-013113
            if(opp.Opportunity_Owner_Role__c !=null && ( (opp.OwnerId != opp_old.OwnerId && !opp.isClosed) || (opp.iswon && !opp_old.iswon) || (opp.isClosed && !opp.iswon && !opp_old.isclosed) || (opp.isClosed && !opp.iswon && opp_old.iswon)   ) )
                opp.Opportunity_Owner_Role_Stamp__c = opp.Opportunity_Owner_Role__c;

            //Sergio Flores
            //Date: 05/05/2020
            //W-005325
            if(opp.CloseDate != opp_old.CloseDate && opp.Term_In_Months__c !=null && opp.SBQQ__PrimaryQuote__c == null)
            {
                opp.Contract_Start_Date__c = opp.CloseDate.addDays(1);
                opp.Contract_End_Date__c = opp.Contract_Start_Date__c.addMonths(integer.valueOf(opp.Term_In_Months__c));
                opp.Contract_End_Date__c = opp.Contract_End_Date__c.addDays(-1);
            }
        }

        //Commented for 2019-12-05 Release
        // added by sharma || 19 NOV 2019 || send email to opp owner when forcast update occurs .
        // added by sharma  || 17 DEC || Avoid Recursion.
        if(forcastUpdateOpps.size() > 0 && !Recursionhandler.IsOppSendEmailExecutedInBeforeUpdate){
            Recursionhandler.IsOppSendEmailExecutedInBeforeUpdate = true;
            List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
            allmsg = sendEmail(forcastUpdateOpps,'OpportunityForecastCategoryChange');
            try {

                //SF Comment due to limit exception Too Many Email Invocations when creating quote
                /*Messaging.SendEmailResult [] r = Messaging.sendEmail(allmsg,false);
                if(r[0].IsSuccess()){
                    System.debug('sent forcast update :: '+'');
                }else{
                    System.debug('error in sent forcast update :: '+r[0].getErrors()[0].getMessage());
                }*/

            } catch (Exception e) {
                System.debug('email sending error forcast update '+e.getMessage());
            }
        }

        //Name: Chris Salgado
        //Date: 10/24/2019
        //Purpose: W-012834
        if(!partnerContactIds.isEmpty())
        {
            OpportunityGateway.getPartnerContactFromPrimary(partnerContactIds, newRecords);
        }

        //Sergio Flores
        //Date: 06/18/2019
        //W-012297
        if(!oppIdToOppNotWonMap.isEmpty())
        {
            OpportunityUtilityClass.updateOpportunityTCV(oppIdToOppNotWonMap);
        }

        /* EW || 05/07/2020 || W-005264 || Comment out to move currency conversion from Before to After
        if(!primaryContactIds.isEmpty())
        {
            OpportunityGateway.syncPrimaryContactCurrencytoOpp(primaryContactIds, newRecords);
        }
         */

        //system.debug('Inside opp before');
        //OpportunityGateway.updateCommissionFields();
        //Author: Sergio Flores
        //Date: 12/05/2018
        //W-010723
        if(Recursionhandler.IsContractAmendExecuted == false) {
            if (!saoUpdatedOppsIds.isEmpty()) {
                //Converting the stamping to a future class since there are too many events firing when a proposal is accepted
                OpportunityUtilityClass.stampRepTerrCodeOnOpportunity(saoUpdatedOppsIds);
            }
        }
        //Author: Sergio Flores
        //Date: 12/10/2018
        //W-010723
        if(!closedOppsIds.isEmpty())
        {
            OpportunityUtilityClass.updateOpportunityTCV(oppIdToOppMap);
            //Sergio Flores : 2019-01-30
            //Converting the stamping to a future class since there are too many events firing when a proposal is accepted
            if(Recursionhandler.IsOppStampOnClosedWonExecuted == false)
            {
                Recursionhandler.IsOppStampOnClosedWonExecuted = true;
                OpportunityUtilityClass.stampRepTerrCodeOnOpportunityClosedWon(closedOppsIds);
            }
        }
    }



    public void onAfterUpdate(List<Opportunity> newRecords){



        //Author: Sergio Flores
        //Date: 10/29/2018
        //W-010483
        //If record type changes on an opportunity to "Partner Opportunity", then all open purchased resellers will need to be
        //updated to "Reseller" MLA

        //Set<ID> partnerOpportunitySet = new Set<ID>(); Sergio Flores 07/07/2019 Commenting out
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Opportunity.getRecordTypeInfosById();
        Set<Id> ecurOppsToUpdate = new Set<Id>();
        Set<Id> oppIdsForOppSplitUpdate = new Set<Id>(); //This is used for adding the opp ids to update opp split forecast modified date
        Set<Id> primaryContactIds = new Set<Id>(); // EW || 05/07/2020 || W-005264
        // Map<Id, Opportunity> ripAndReplaceOppsMap = new Map<Id, Opportunity>();  //Eddie Wong || W-002539 || 05-07-2020 || Comment out due to no longer needing queueable class for ECUR R&R and Renewed process
        List<Opportunity> oppRCWithRenewedContractList = new List<Opportunity>();
        Map<Id, Opportunity> oppIdToOppClosedMap = new Map<Id, Opportunity>();
        Map<Id, String> oppIdToOppOwnerRoleMap = new Map<Id, String>();

        //Commented for 2019-12-05 Release
        // Added by: Sharma Nemani | PRM Opp. Emails | 11/01/2019 --> START
        Map<id, opportunity> oldmap =  (Map<Id,opportunity>)Trigger.oldMap;

        // added by sharma  || 17 DEC 2020 || Avoid Recursion.
        if(!Recursionhandler.IsOppSendEmailExecutedInAfterUpdate){
            Recursionhandler.IsOppSendEmailExecutedInAfterUpdate = true;
            sendEmail(newRecords,oldMap);
        }


        // added by sharma || 12 Nov 2019
        Set<Id> setOppIdWhereOwnerIsChanged = new Set<Id>();

        // Sharma Nemani | PRM Opp. Emails | 11/01/2019 --> END
        for(Opportunity opp : newRecords)
        {
            Opportunity oldOpportunity = (Opportunity)Trigger.oldMap.get(opp.ID);

            if(opp.ownerId != oldOpportunity.ownerId){
                setOppIdWhereOwnerIsChanged.add(opp.Id);
            }

            String recordTypeName = rtMap.get(opp.RecordTypeId).getName();
            system.debug('Opp RecordType Name' + recordTypeName);

            /*if(recordTypeName == 'Partner Opportunity' && (opp.RecordTypeId != oldOpportunity.RecordTypeId)) Sergio Flores 07/07/2019 Commenting out
            {
                partnerOpportunitySet.add(opp.Id);
            }*/
            //Need to check if Opportunity is updated to Closed and If it is ECUR, if so we need to update the related Opps
            //that are also NBEC and update them to Closed Won and Reason to win = Ease of Use
            system.debug('Opp ECUR IS WON '+ opp.iswon + ' Old Opp ' + oldOpportunity.isWon + ' Type ' + opp.Type + ' Opp Stage Name ' + opp.StageName);
            if(opp.iswon && !oldOpportunity.isWon && opp.Type == 'ECUR')
            {
                system.debug('Inside ECUR Updating');
                ecurOppsToUpdate.add(opp.Id);
            }
            system.debug('Is Closed '+ opp.isClosed + ' Old Opp ' + oldOpportunity.isClosed);

            // Added by Oshin on April 26, 2016
            if(stage_close_vals.contains(opp.StageName)
                    && !stage_close_vals.contains(oldOpportunity.StageName)) {

                if(opp.SAO_Contact__c != null) {

                    sao_contact_ids.add(opp.SAO_Contact__c);

                }

            }

            //Sergio Flores
            //Date: 06/20/2019
            //Stamp Forecast Modified Date on Opp Split when forecast fields on Opp are changed
            if( (opp.Forecast_Amount__C != oldOpportunity.Forecast_Amount__C)
                    //|| (opp.Best_Case_Term__c != oldOpportunity.Best_Case_Term__c) Sergio Flores 02/21/2020 W-004548
                    )
            {
                oppIdsForOppSplitUpdate.add(opp.Id);
            }

            //Sergio Flores + Sharma
            //Date: 08/30/2019
            //Updating when to execute rip and replace queueable
            /* Eddie Wong || W-002539 || 05-07-2020 || Comment out due to no longer needing queueable class for ECUR R&R and Renewed process
            if(opp.iswon && !oldOpportunity.iswon && opp.Type == 'ECUR')
            {
                ripAndReplaceOppsMap.put(opp.Id, opp);
            }*/

            if(opp.Type == 'ECUR' && opp.SBQQ__RenewedContract__c != null && oldOpportunity.SBQQ__RenewedContract__c == null)
            {
                oppRCWithRenewedContractList.add(opp);
            }

            //Author: Sergio Flores
            //Date: 10/16/2019
            //W-013143
            if(opp.iswon && !oldOpportunity.iswon)
            {
                oppIdToOppClosedMap.put(opp.Id, opp);
            }

            //Sergio Flores
            //Date 12/18/2019
            //W-013113
            if((opp.iswon && !oldOpportunity.iswon) || (opp.isClosed && !opp.iswon && !oldOpportunity.isclosed) || (opp.isClosed && !opp.iswon && oldOpportunity.iswon))
            {
                oppIdToOppOwnerRoleMap.put(opp.Id, opp.Opportunity_Owner_Role_Stamp__c);
            }

            //Eddie Wong
            //Date: 05/07/2020
            //W-005264
            if(alteryxToggle.Opportunity_Currency_Admin_Bypass__c == true && Recursionhandler.IsSyncPrimaryContactCurrencytoOppExecuted == false){
                Recursionhandler.IsSyncPrimaryContactCurrencytoOppExecuted = true;
                primaryContactIds.add(opp.Primary_Contact__c);
            }
            Else if(opp.Primary_Contact__c !=null && opp.Primary_Contact__c != oldOpportunity.Primary_Contact__c && opp.SBQQ__PrimaryQuote__c == null)
            {
                primaryContactIds.add(opp.Primary_Contact__c);
            }

        }

        //Eddie Wong
        //Date 05/07/2020
        //W-005264
        if(!primaryContactIds.isEmpty())
        {
            OpportunityGateway.syncPrimaryContactCurrencytoOpp(primaryContactIds, newRecords);
        }

        //Sergio Flores
        //Date 12/18/2019
        //W-013113
        if(!oppIdToOppOwnerRoleMap.isEmpty())
        {
            OpportunityUtilityClass.updateOppSplitOnOppClosed(oppIdToOppOwnerRoleMap);
        }

        //Commented for 2019-12-05 Release
        // added by sharma || 12 Nov 2019
        if(setOppIdWhereOwnerIsChanged.size() > 0){
            OpportunitySplitTriggerHandler.onOppOwnerChange(setOppIdWhereOwnerIsChanged);
        }

        //Commenting now for 10/22/2019 Release
        /*if(!oppIdToOppClosedMap.isEmpty() && RecursionHandler.checkOverlaySplitOnClosedWon == false)
        {
            RecursionHandler.checkOverlaySplitOnClosedWon = true;
            OpportunityUtilityClass.checkOverlaySplitOnClosedWon(oppIdToOppClosedMap);
        }*/

        if(!oppRCWithRenewedContractList.isEmpty())
        {
            OpportunityUtilityClass.createRCWithRenewedContract(oppRCWithRenewedContractList); // Sharma Nemani | Date: 06/10/2019 | W-011617
        }

        /* Eddie Wong || W-002539 || 05-07-2020 || Comment out due to no longer needing queueable class for ECUR R&R and Renewed process
        if(!ripAndReplaceOppsMap.isEmpty())
        {
            system.debug('handler@@ ::'+Recursionhandler.IsOpportunityQueuableExecuted);
            string labelForOppQueueable = System.Label.Opportunity_Queueable;
            if(labelForOppQueueable == 'True' && RecursionHandler.IsOpportunityQueuableExecuted == false)
            {
                system.debug('labelForQueueableActive ::' + labelForOppQueueable);
                OpportunityQueueable oppQueueable = new OpportunityQueueable(ripAndReplaceOppsMap);//Added By: Sharma Nemani  | W- 012827 | Date: 08/09/2019
                ID jobID = System.enqueueJob(oppQueueable);
            }
        }*/

        //Sergio Flores
        //Date: 06/20/2019
        //Stamp Forecast Modified Date on Opp Split when forecast fields on Opp are changed
        if(!oppIdsForOppSplitUpdate.isEmpty())
        {
            OpportunityUtilityClass.stampRepForecastModifiedDate(oppIdsForOppSplitUpdate);
        }
        //Author: Sergio Flores
        //Date: 01/24/2019
        //W-010988
        if(!ecurOppsToUpdate.isEmpty())
        {
            Map<Id, Opportunity> oppIdToOppMap = new Map<Id, Opportunity>([Select Id, Reason_for_Win__c, StageName From Opportunity Where Parent_Opportunity__c IN : ecurOppsToUpdate AND Type = 'NBEC' Limit 50000]);
            if(!oppIdToOppMap.isEmpty())
            {
                system.debug('Inside ECUR Updating 2');
                List<Opportunity> ecurOppssList = oppIdToOppMap.values();
                List<Opportunity> ecurOppsToUpdateList = new List<Opportunity>();
                for(Opportunity opp : ecurOppssList)
                {
                    opp.Reason_for_Win__c = 'Ease of Use';
                    opp.StageName = '5 - Closed Won';
                    ecurOppsToUpdateList.add(opp);
                }
                try {
                    Database.Update(ecurOppsToUpdateList,false);
                }
                catch(Exception ex) {
                    system.debug('inside catch exception');
                    trigger.new[0].addError(ex.getMessage());
                }
            }

        }
        /*CPQ Refactor SF 03/25/2019 OpportunityHandler Partner
        If record type changes on an opportunity to "Partner Opportunity", then all open purchased resellers will need to be updated to "Reseller" MLA*/
        /*Sergio Flores 07/07/2019 Commenting out
        if(!partnerOpportunitySet.isEmpty())
        {
            List<SBQQ__Quote__c> purchasedPropToList = [Select Id, Name, MLA_Option__c
                                                                        From SBQQ__Quote__c
                                                                        Where SBQQ__Opportunity2__c IN : partnerOpportunitySet
                                                                        AND SBQQ__Status__c != 'Accepted'
                                                                        AND Quote_Type__c = 'Purchase'];
            List<SBQQ__Quote__c> proposalsToUpdate = new List<SBQQ__Quote__c>();
            system.debug('ProposalsToUpdate ' + proposalsToUpdate);
            if(!purchasedPropToList.isEmpty())
            {
                for(SBQQ__Quote__c prop : purchasedPropToList)
                {
                    prop.MLA_Option__c = 'Reseller';
                    proposalsToUpdate.add(prop);
                }
            }
            try {
                Database.Update(purchasedPropToList,false);
            }
            catch(Exception ex) {
            system.debug('inside catch exception');
            trigger.new[0].addError(ex.getMessage());
            }
        }*/



    }

    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
        /*Commented by Paramvir on 27January,2016 as we don't need this anymore
        if(accountIdSet != NULL && !accountIdSet.isEmpty()){
            OpportunityGateway.createAccountTeamMembers(accountIdSet);
        }*/

        if(!sao_contact_ids.isEmpty()) {
            System.debug('>>>> sao_contact_ids in handler:' + sao_contact_ids);
            OpportunityGateway.uncheckLDRProcessButtonVisibility(
                    sao_contact_ids);
        }

    }

    //Commented for 2019-12-05 Release
    // Created by: Sharma Nemani | W- | Date: 11/1/2019 --> START
    // Description: PRM Opportunity Emails
    public static void sendEmail(List<Opportunity> newOpps,Map<Id,Opportunity> oldOppMap){

        Set<Id> mapOppsCase1 = new Set<Id>();
        Set<Id> mapOppsCase2 = new Set<Id>();
        Set<Id> mapOppsCase3 = new Set<Id>();

        for(Opportunity opp : newOpps){
            // case 1 W-012970
            if((opp.Partner_Stage__c == '5 - Closed Won' || opp.Partner_Stage__c == 'Closed Lost') && oldOppMap != null && (opp.Partner_Close_Date__c != oldOppMap.get(opp.Id).Partner_Close_Date__c
                    || opp.Partner_Stage__c != oldOppMap.get(opp.Id).Partner_Stage__c)){
                mapOppsCase1.add(opp.Id);
            }
            //case 2 W-012963
            else if(opp.wi__Share_to_WI__c && String.isNotBlank(opp.wi__Associated_Partner__c) &&
                    (opp.wi__Workflow_Status__c == 'Converted' || opp.wi__Workflow_Status__c == 'Working')){
                mapOppsCase2.add(opp.Id);
            }
            // Case 3 W-012964
            else if(opp.Partner_Stage__c != '5 - Closed Won' && opp.Partner_Stage__c != 'Closed Lost' && oldOppMap != null && (opp.Partner_Close_Date__c != oldOppMap.get(opp.Id).Partner_Close_Date__c ||
                    opp.Partner_Stage__c != oldOppMap.get(opp.Id).Partner_Stage__c)){
                mapOppsCase3.add(opp.Id);
            }

        }
        // list of single email messaging to send .
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        system.debug('mapOppsCase1 :: '+mapOppsCase1);
        if(mapOppsCase1.size() > 0){
            allmsg = sendEmail(mapOppsCase1,'Template_O4');
        }

        if(mapOppsCase2.size() > 0){
            allmsg = sendEmail(mapOppsCase2,'Template_O3');
        }

        if(mapOppsCase3.size() > 0){
            allmsg = sendEmail(mapOppsCase3,'Template_06');
        }

        try {

            //SF Comment due to limit exception Too Many Email Invocations when creating quote
            /*Messaging.SendEmailResult [] r = Messaging.sendEmail(allmsg,false);
            if(r[0].IsSuccess()){
                System.debug('sent :: '+'');
            }else{
                System.debug('error in sent :: '+r[0].getErrors()[0].getMessage());
            }*/

            //Messaging.sendEmail(allmsg,false);
            return;
        } catch (Exception e) {
            System.debug('email sending error'+e.getMessage());
        }
    }

    public static List<Messaging.SingleEmailMessage> sendEmail(Set<Id> serOppIds,String tempName){// Template_O1
        // as per conditions meeting querying email template.
        EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE DeveloperName =:tempName];

        // this soql query required because trigger.new will not offer value of "wi__Associated_Partner__r.Business_Development_Owner_Email__c".
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([select id,Account.Owner.Id,Account.Owner.Email,Owner.Email,wi__Associated_Partner__r.Business_Development_Owner_Email__c,Forecast_Update__c ,LastModifiedById ,Type from Opportunity where Id IN : serOppIds]);

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();


        system.debug('tempName :: '+tempName);
        system.debug('oppMap :: '+oppMap);
        Contact con = [select id from contact limit 1];
        // map of leads along with their email after meeting either case 1 or case 2 conditons .
        for(Id idOpp :  oppMap.keySet()){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTemplateId(et.Id);
            if(tempName == 'Template_O4'){
                // task 3
                mail.setToAddresses(new List<String>{oppMap.get(idOpp).Owner.Email,oppMap.get(idOpp).wi__Associated_Partner__r.Business_Development_Owner_Email__c});
            }else if(tempName == 'Template_O3'){
                // task 4
                mail.setToAddresses(new List<String>{oppMap.get(idOpp).Account.Owner.Email});
                mail.setccAddresses(new List<String>{oppMap.get(idOpp).wi__Associated_Partner__r.Business_Development_Owner_Email__c,'salesoperations@alteryx.com'});
            }
            else if(tempName == 'Template_06'){
                // task 4
                mail.setToAddresses(new List<String>{oppMap.get(idOpp).Owner.Email,oppMap.get(idOpp).wi__Associated_Partner__r.Business_Development_Owner_Email__c});
            }else{
                // added by sharma || 19 NOV 2019
                // only when If opp's forcast update takes place
                mail.setToAddresses(new List<String>{oppMap.get(idOpp).Owner.Email});
            }

            //mail.setSubject(et.subject);
            //mail.setHTMLBody(et.Body);
            // target Object id to provide values in merge fields  .
            mail.setTargetObjectId(con.Id);//oppMap.get(idOpp).Account.Owner.Id
            mail.setTreatTargetObjectAsRecipient(false);
            // because in setTargetObjectId we can pass only lead,contact or user object id .
            // but our template contains merge fields from Opportunity .
            mail.setwhatId(idOpp); // idOpp is opp Id
            system.debug('idOpp :: '+idOpp+' : '+oppMap.get(idOpp).Account.Owner.Id);
            mail.setSaveAsActivity(false);
            mail.setUseSignature(false);
            allmsg.add(mail);
        }
        return allmsg;
    }
    // Sharma Nemani | W- | Date: 11/1/2019 --> END

}