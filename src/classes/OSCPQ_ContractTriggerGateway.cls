public with sharing class OSCPQ_ContractTriggerGateway {


    public static list < Account > updateMosteffectiveAgreementonAccount(Set < ID > accountidSetForPartners) {
        /*List < Account > updatedAccountPartnerList = new List < Account > ();
         Map < Id, Apttus__APTS_Agreement__c > accidPartnerAgreement = new Map < Id, Apttus__APTS_Agreement__c > ();
       if (!accountidSetForPartners.isEmpty()) {

           for (Apttus__APTS_Agreement__c agree: [select id, Apttus__Account__c, Apttus__Account__r.Partner_Contract_Terms__c, Apttus__Account__r.Partner_Contract_Early_Termination_Date__c, Apttus__Account__r.Partner_Contract_Start__c,
                   Apttus__Account__r.Partner_Contract_Type__c, Contract_End_Date__c,
                   Contract_Start_Date__c, Territory__c, Apttus__Account__r.Geographic_Focus__c, Contract_Term__c, Contract_Type__c, Early_Termination_Date__c, Order_Effective_Date__c,
                   Apttus__Status_Category__c from Apttus__APTS_Agreement__c where Apttus__Account__c in : accountidSetForPartners
                   AND recordtypeID = : Label.ResellerAgreementRTId ORDER BY Order_Effective_Date__c DESC LIMIT 50000
               ]) {
               if (!accidPartnerAgreement.containsKey(agree.Apttus__Account__c)) {

                   accidPartnerAgreement.put(agree.Apttus__Account__c, agree);

               } /*else {

                   Apttus__APTS_Agreement__c ag = accidPartnerAgreement.get(agree.Apttus__Account__c);
                   if (agree.Order_Effective_Date__c > ag.Order_Effective_Date__c) {
                       accidPartnerAgreement.put(agree.Apttus__Account__c, agree);
                   }

               }*/
        /*
            }
            system.debug('AccId2Agreements Map======>' + accidPartnerAgreement);
            if (!accidPartnerAgreement.isEmpty()) {
                for (Id accId: accidPartnerAgreement.keyset()) {
                    Apttus__APTS_Agreement__c agUpdates = accidPartnerAgreement.get(accId);
                    Account acc = new Account(id = accId, Partner_Contract_Terms__c = agUpdates.Contract_Term__c, Partner_Contract_Type__c = agUpdates.Contract_Type__c, Geographic_Focus__c = agUpdates.Territory__c,
                                              Partner_Contract_Early_Termination_Date__c=agUpdates.Early_Termination_Date__c!=null?agUpdates.Early_Termination_Date__c:Null,Partner_Contract_Start__c=agUpdates.Order_Effective_Date__c);
                    updatedAccountPartnerList.add(Acc);
                }
            }

            if (!updatedAccountPartnerList.isEmpty()) {
                return updatedAccountPartnerList;
            }
        }*/
        return null;
    }
    /**
     * #W-009793
     * Add ACV rollup field to Account Page
     *
     * @param {Set<Id>} accountIds - Account Ids
     * @return acctsToUpdate - Accounts to update.
     * @description Update the Account's Total_ACV__c field.
     *      (R00N50000001Xl0UEAS - Apttus__APTS_Agreement__c)
     * @author Hemendra Singh Rajawat
     * @since July 11, 2018
     */
    //Sergio Flores
    //Date: 04/24/2019
    //New CPQ:
    public static List<Account> updateAccounts(Set<Id> accountIds) {
        Map<String, Double> conversionRatesMap = UtilityClass.getConversionRates();
        List<Account> acctsToUpdate = new List<Account>();
        Decimal totalACV;
        Decimal currentACV;
        Decimal conversionValue;
        Map<Id, String> accountIdByCurrencyMap = new Map<Id, String>();

        for (Account acc : [SELECT Id, Total_ACV__c,CurrencyIsoCode,
        (SELECT SubscriptionACV__c,
                AccountId,CurrencyIsoCode
        FROM Contracts
        WHERE (EndDate >= TODAY
        AND Status_Category__c = 'In Effect'
        AND Status = 'Activated'))
        FROM Account
        WHERE Id IN :accountIds]) {

            totalACV = 0;
            system.debug('inside update accounts ' + acc);

            for (Contract contract : acc.Contracts) {
                system.debug('inside update accounts contract loop ' + contract);
                currentACV = contract.SubscriptionACV__c;
                if (contract.CurrencyIsoCode != 'USD') {
                    currentACV /= conversionRatesMap.get(contract.CurrencyIsoCode);
                }
                totalACV += currentACV;
            }

            if (acc.CurrencyIsoCode != 'USD') {
                totalACV *= conversionRatesMap.get(acc.CurrencyIsoCode);
            }
            acc.Total_ACV__c = totalACV;
            acctsToUpdate.add(acc);
            system.debug('inside update accounts contract loop ' + acc);
        }
        return acctsToUpdate;
    }


    //Sergio Flores
    //Date: 06/17/2019
    //W-012214
    public static void updateAccountToCustomer(Set<Id> customerAccountsIds) {

        List<Account> accountList = [Select Id, Type From Account Where Id IN : customerAccountsIds];
        system.debug('inside updateAccountToCustomer ' + accountList);

        if(!accountList.isEmpty())
        {
            List<Account> accountListToUpdate = new List<Account>();

            for(Account acc : accountList)
            {
                acc.Type = 'Customer';
                accountListToUpdate.add(acc);
            }

            try
            {
                if(!accountListToUpdate.isEmpty())
                {
                    update accountListToUpdate;
                }
            }
            catch (Exception ex) {
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }


    }

    //Sergio Flores
    //Date: 05/14/2019
    //W-011737
    //We need to populate the quote subscription schedules on the contract for deal desk to view
    //from a contract point
    public static void insertBillingSchedules(List < Quote_Subscription_Schedule__c > subscriptionScheduleFromQuote, Map<Id, Id> quoteToContractmap) {

        system.debug('inside insertBillingSchedules ' + subscriptionScheduleFromQuote + ' ' + quoteToContractmap);
        List < Billing_Schedule__c > billingScheduleToInsert = new List <Billing_Schedule__c > ();

        for(Quote_Subscription_Schedule__c qss : subscriptionScheduleFromQuote)
        {
            //Get the contract related to this quote
            Id contractId = quoteToContractmap.get(qss.Quote__c);

            Billing_Schedule__c bs = new Billing_Schedule__c();

            if(contractId !=null)
                bs.Contract__c = contractId;

            bs.Proposal_Currency_ISO_Code__c =qss.Proposal_Currency_ISO_Code__c;
            bs.Subscription_start_date__c =qss.Subscription_Start_Date__c ;
            bs.Subscription_end_date__c =qss.Subscription_End_Date__c ;
            bs.Year__c= qss.Year__c;
            bs.currencyISOCode = qss.Proposal_Currency_ISO_Code__c;
            bs.Quote__c = qss.Quote__c;
            bs.Amount__c = qss.Net_Total__c;

            billingScheduleToInsert.add(bs);
        }

        try
        {
            if(!billingScheduleToInsert.isEmpty())
            {
                insert billingScheduleToInsert;
            }
        }
        catch (Exception ex) {
            system.debug('inside catch exception');
            trigger.new[0].addError(ex.getMessage());
        }
    }

    //Chris Salgado
    //Date: 05/31/2019
    //W-012137
    //We need to populate the Quote with the related Contract once it is created or updated.
    public static void updateQuotes(Set<Id> quoteIds, Map<Id, Id> quoteToContractmap){
        List<SBQQ__Quote__c> quotesToUpdate = new List<SBQQ__Quote__c>();

        //Query for Quotes with missing Related Contract
        for(SBQQ__Quote__c q2Update : [SELECT Id, Related_Contract__c
        FROM SBQQ__Quote__c
        WHERE Id IN :quoteIds
        AND Related_Contract__c = null]){

            if(quoteToContractmap.containsKey(q2Update.Id)){
                q2Update.Related_Contract__c = quoteToContractmap.get(q2Update.Id);
                quotesToUpdate.add(q2Update);
            }

        }
        if(!quotesToUpdate.isEmpty()){
            try{
                update quotesToUpdate;
            }
            catch(Exception ex){
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }

    }

    //Sergio Flores
    //Date: 06/17/2019
    //W-012251
    public static void populatePartnerOnNewOpportunity(Set<Id> originalOppIds, Map<Id, Id> originalOppIdToNewOppId){
        system.debug('inside populatePartnerOnNewOpportunity ' + originalOppIdToNewOppId);

        //Here we query the custom partners for the new renewal opportunity tied to the contract
        //We will use this to check if there are already partners on the renewal opp
        Map<Id, Custom_Partner__c> cpOnNewOppMap = new Map<Id, Custom_Partner__c>([Select Id, IsPrimary__c, Role__c, OpportunityId__c, AccountToId__c, Name
        From Custom_Partner__c
        Where OpportunityId__c IN :  originalOppIdToNewOppId.values()]);

        system.debug('inside cpOnNewOppMap not null ' + cpOnNewOppMap);

        Set<Id> newOppIds = new Set<Id>();

        for(Custom_Partner__c cp : cpOnNewOppMap.values())
        {
            newOppIds.add(cp.OpportunityId__c);
        }

        //Here we query the custom partners for the original opportunities tied to the contract
        List<Custom_Partner__c> cpList = [Select Id, IsPrimary__c, Role__c, OpportunityId__c, AccountToId__c, Name
        From Custom_Partner__c
        Where OpportunityId__c IN :  originalOppIds
        AND Role__c != 'Collaborative Sale'];//SF 09/23/2020 W-006386 Don't count Collaborative Sale



        if(!cpList.isEmpty())
        {
            List<Custom_Partner__c> customPartnersToInserList = new List<Custom_Partner__c>();

            for(Custom_Partner__c cp : cpList)
            {
                system.debug('inside cpList ' + cp);
                Id newOppId = originalOppIdToNewOppId.get(cp.OpportunityId__c);
                system.debug('inside newOppId ' + newOppId);

                if(newOppId !=null && !newOppIds.contains(newOppId))
                {
                    system.debug('inside newOppId not null ' + newOppId);
                    cp.Id = null;
                    cp.OpportunityId__c = newOppId;
                    customPartnersToInserList.add(cp);
                }

            }

            if(!customPartnersToInserList.isEmpty()){
                try{
                    insert customPartnersToInserList;
                }
                catch(Exception ex){
                    system.debug('inside catch exception');
                    trigger.new[0].addError(ex.getMessage());
                }
            }
        }
    }

    //Name: Chris Salgado
    //Date: 05/15/20
    //Purpose: W-004795
    public static void calculateAccountMaxContractEndDate(Set<Id> accountIds){
        List<Account> updateAccounts = new List<Account>();
        List<Account> accountWithMaxActiveContract = [SELECT Id, Max_Contract_End_Date__c, (SELECT Id, EndDate FROM Contracts WHERE Status = 'Activated' ORDER BY EndDate DESC LIMIT 1) FROM Account WHERE Id IN :accountIds];

        if(!accountWithMaxActiveContract.isEmpty()){
            for(Account acct : accountWithMaxActiveContract){
                if(!acct.Contracts.isEmpty()){
                    if(acct.Max_Contract_End_Date__c != null){
                        if(acct.Contracts[0].EndDate > acct.Max_Contract_End_Date__c){
                            Account tempAcct = new Account();
                            tempAcct.Id = acct.Id;
                            tempAcct.Max_Contract_End_Date__c = acct.Contracts[0].EndDate;
                            updateAccounts.add(tempAcct);
                        }
                    }
                    else{
                        Account tempAcct = new Account();
                        tempAcct.Id = acct.Id;
                        tempAcct.Max_Contract_End_Date__c = acct.Contracts[0].EndDate;
                        updateAccounts.add(tempAcct);
                    }
                }
            }
        }

        if(!updateAccounts.isEmpty()){
            update updateAccounts;
        }
    }

    /* @Name Eddie Wong
    ** @Work W-007098
    ** @Date 2/5/2021
    ** @Desc Flagging Roll Up Update Needed in GTM Accounts
     */
    public static void updateRollUpNeededFieldInGTMAccountForSubACVChange(Set<Id> gtmAccountIds) {

        System.debug('inside updateRollUpNeededFieldInGTMAccount');

        List<Account> updateAccountsList = new List<Account>();
        Map<Id, Account> accIdToAccMap = new Map<Id, Account>([SELECT Id FROM Account WHERE Id IN :gtmAccountIds AND Roll_Up_Update_Needed__c = false]);

        System.debug('checking accIdToAccMap = ' + accIdToAccMap);

        if(accIdToAccMap != null) {
            for (Account a : accIdToAccMap.values()) {
                Account acc = new Account();
                acc.Id = a.Id;
                acc.Roll_Up_Update_Needed__c = true;
                updateAccountsList.add(acc);
            }
        }

        System.debug('checking updateAccountsList = ' + updateAccountsList);

        if(!updateAccountsList.isEmpty()) {
            update updateAccountsList;
        }
    }

    /* @Name Eddie Wong
    ** @Work W-007098
    ** @Date 2/5/2021
    ** @Desc Flagging Roll Up Update Needed in GTM Accounts during new contract creation
     */
    public static void updateRollUpNeededFieldInGTMAccountForNewContract(Set<Id> masterAcctIds) {
        System.debug('ed check RecursionHandler.IsGTMAccUpdateRollUpExecuted ' + RecursionHandler.IsGTMAccUpdateRollUpExecuted);

        RecursionHandler.IsGTMAccUpdateRollUpExecuted = true;

        System.debug('inside updateRollUpNeededFieldInGTMAccountForNewContract = ' + masterAcctIds);

        List<Account> updateAccountsList = new List<Account>();
        Map<Id, Account> accIdToAccMap = new Map<Id, Account>([SELECT Id,Go_To_Market_Account__c,Ultimate_Parent_Account__c FROM Account WHERE Id IN :masterAcctIds
                                                                AND (Go_To_Market_Account__c != null OR Ultimate_Parent_Account__c != null)
                                                                AND Go_To_Market_Account__r.Roll_Up_Update_Needed__c = false]);

        if(accIdToAccMap != null) {
            for (Account acc : accIdToAccMap.values()) {
                Account a = new Account();
                if(acc.Go_To_Market_Account__c != null) {  //Scenario where account has GTM lookup
                    a.Id = accIdToAccMap.get(acc.Id).Go_To_Market_Account__c;
                }
                else if(acc.Go_To_Market_Account__c == null && acc.Ultimate_Parent_Account__c != null) { //Scenario where account doesn't have GTM lookup
                    a.Id = accIdToAccMap.get(acc.Id).Ultimate_Parent_Account__c;
                }
                a.Roll_Up_Update_Needed__c = true;
                updateAccountsList.add(a);

            }
        }

        if(!updateAccountsList.isEmpty()) {
            try {
                System.debug('inside try updateAccountsList');
                update updateAccountsList;
            } catch (Exception e) {
                System.debug('inside updateAccountsList catch exception');
                trigger.new[0].addError(e.getMessage());
            }
        }

    }
}