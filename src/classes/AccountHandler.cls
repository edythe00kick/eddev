/*
 * Class Name - AccountHandler.
 * Test Class Name - AccountTriggerTest.
 * 
 * %W% %E% Grazitti Team
 * This is the helper class for "AccountTrigger" trigger and handle the 
 * trigger functionality.
 */

/**
 * #W-009840
 * Update CY fields on Account and Lead Object.
 * @version 1.0 July 17, 2018
 * 
 * @author Hemendra Singh Rajawat <hemendras@grazitti.com>
 * @since July 17, 2018
 */

public with sharing class AccountHandler {
    // Stores the value of Trigger.isExecuting
    private Boolean myIsExecuting = false;
    // Stores the value of Trigger.size
    private integer batchSize = 0;
    // Stores the field to be used in mapping
    private List<Territory_Mapping__mdt> fields;
    // Stores the map of the user
    private Map<Id,User> userMap = new Map<Id,User>();

    /**
     * Constructor of this class.
     */
    public AccountHandler(Boolean isExecuting, Integer size, List<Account> newMap) {
        system.debug('Inside Account Handler Class');
        myIsExecuting = isExecuting;
        batchSize = size;
        String userFields = '';
        String userQuery = '';
        List<User> userList = new List<User>();
        Set<Id> userIds = New Set<Id>();
        
        for (Account acc : newMap) {
            userIds.add(acc.OwnerId);
        }

        if (!userIds.isEmpty()) {
            fields = [SELECT Id, Account_Field__c, User_Field__c 
                      FROM Territory_Mapping__mdt 
                      WHERE Account_Field__c != null];

            for (Territory_Mapping__mdt field : fields) { 
                userFields += field.User_Field__c + ',';
            }

            userFields = userFields.removeEnd(',');

            if (userFields != '') {
                userQuery = 'SELECT Id,' + userFields  
                    + ' FROM USER WHERE IsActive=True AND Id IN :userIds';
                system.debug('User Fields' + ' ' + userFields );
                userList = Database.query(userQuery);
                if (!userList.isEmpty()) {
                    userMap = new Map<Id,User>(userList);
                }
            }
        }
    }

    /**
     * On Before Insert.
     */
    public void onBeforeInsert(List<Account> newList) {
        for (Account acc : newList) {
            if (!userMap.isEmpty() && userMap.containsKey(acc.OwnerId) && !fields.isEmpty()) {
                for (Territory_Mapping__mdt field : fields) {
                    if (acc.get(field.Account_Field__c) != userMap.get(acc.OwnerId).get(field.User_Field__c)) {
                        acc.put(field.Account_Field__c , userMap.get(acc.OwnerId).get(field.User_Field__c));
                        system.debug('Updated Account' + ' ' + acc);
                    }
                }
            }

            //Author: Sergio Flores
            //Date: 10/24/2018
            //W-010384
            //Need to check if the partner tier is not empty
            if(acc.Partner_Tier__c != null && Partner_Tier__c.getValues(acc.Partner_Tier__c) != null)
            {
                system.debug('Inside Partner Tier insert');
                //Grab the values label of the custom setting and compare it to the partner tier, then grab all the values of the record
                //and then populate the account discount fields with the values from the custom setting
                Partner_Tier__c ptCustomSetting = Partner_Tier__c.getValues(acc.Partner_Tier__c);
                system.debug('Partner Tier Custom Setting ' + ptCustomSetting);

                acc.Resale_Discount__c = ptCustomSetting.Current_Reseller_Discount__c;
                acc.Referral_Discount__c = ptCustomSetting.Current_Referral_Discount__c;
                acc.Referral_Discount_Cap__c = ptCustomSetting.Referral_Discount_Cap__c;
                acc.Renewal_Margin__c = ptCustomSetting.Current_Renewal_Discount__c;


            }
        }
    }

    /**
     * On After Insert.
     */
    //public void onAfterInsert(Map<Id, Account> newMap) {}

    /**
     * On Before Update.
     */
    public void onBeforeUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        String renewalMargin;
        String resaleDiscount;
        String referralDiscount;

        List<GTM_Global_Ranking_Opp_Update_Event__e> gtmGlobalRankingOppUpdateEventList = new List<GTM_Global_Ranking_Opp_Update_Event__e>();

        for (Id accId : newMap.KeySet()) {
            Account acc = newMap.get(accId);
            Account accOld = (Account) Trigger.oldMap.get(acc.Id);

            if (!userMap.isEmpty() && userMap.containsKey(acc.OwnerId) 
                && !fields.isEmpty() && acc.OwnerId != accOld.OwnerId) {

                for (Territory_Mapping__mdt field : fields) {
                    if (acc.get(field.Account_Field__c) != userMap.get(acc.OwnerId).get(field.User_Field__c)) {
                        acc.put(field.Account_Field__c , userMap.get(acc.OwnerId).get(field.User_Field__c));
                    }
                }
            }


            //Author: Sergio Flores
            //Date: 10/24/2018
            //W-010384
            //Need to check if the partner tier got updated, if so we need to autopopulate the discount values on Account
            if(acc.Partner_Tier__c != accOld.Partner_Tier__c 
               && (acc.Resale_Discount__c == accOld.Resale_Discount__c 
                   && acc.Referral_Discount__c == accOld.Referral_Discount__c 
                   && acc.Referral_Discount_Cap__c == accOld.Referral_Discount_Cap__c
                   && acc.Renewal_Margin__c == accOld.Renewal_Margin__c)
                && acc.Partner_Tier__c != null)
            {
                system.debug('Inside Partner Tier update');
                //Grab the values label of the custom setting and compare it to the partner tier, then grab all the values of the record
                //and then populate the account discount fields with the values from the custom setting
                Partner_Tier__c ptCustomSetting = Partner_Tier__c.getValues(acc.Partner_Tier__c);
                system.debug('Partner Tier Custom Setting ' + ptCustomSetting);

                acc.Resale_Discount__c = ptCustomSetting.Current_Reseller_Discount__c;
                acc.Referral_Discount__c = ptCustomSetting.Current_Referral_Discount__c;
                acc.Referral_Discount_Cap__c = ptCustomSetting.Referral_Discount_Cap__c;
                acc.Renewal_Margin__c = ptCustomSetting.Current_Renewal_Discount__c;

                //Sergio Flores
                //Date: 07/09/2019
                //W-012530
                referralDiscount = acc.Referral_Discount__c.removeEnd('%');
                acc.Referral_Commission_Pct__c = Decimal.ValueOf(referralDiscount);
                resaleDiscount = acc.Resale_Discount__c.removeEnd('%');
                acc.Resale_Discount_Pct__c = Decimal.ValueOf(resaleDiscount);
                renewalMargin = acc.Renewal_Margin__c.removeEnd('%');
                acc.Renewal_Discount_Pct__c = Decimal.ValueOf(renewalMargin);


            }
            //Sergio Flores
            //Date: 07/09/2019
            //W-012530
            else if(acc.Partner_Tier__c == accOld.Partner_Tier__c)
            {
                if(acc.Resale_Discount__c != accOld.Resale_Discount__c )
                {
                    resaleDiscount = acc.Resale_Discount__c.removeEnd('%');
                    acc.Resale_Discount_Pct__c = Decimal.ValueOf(resaleDiscount);
                }
                

                if(acc.Referral_Discount__c != accOld.Referral_Discount__c)
                {
                    referralDiscount = acc.Referral_Discount__c.removeEnd('%');
                    acc.Referral_Commission_Pct__c = Decimal.ValueOf(referralDiscount);
                }
                

                if(acc.Renewal_Margin__c != accOld.Renewal_Margin__c)
                {
                    renewalMargin = acc.Renewal_Margin__c.removeEnd('%');
                    acc.Renewal_Discount_Pct__c = Decimal.ValueOf(renewalMargin);
                }
                

            }

            //Author: Sergio Flores
            //Date: 11/13/2018
            //W-010642
            if(acc.Referral_Discount__c != accOld.Referral_Discount__c && acc.Partner_Tier__c == accOld.Partner_Tier__c && acc.Partner_Tier__c != null)
            {
                system.debug('Inside referral discount change');

                List<Partner_Tier__c> ptCustomSetting = Partner_Tier__c.getall().values();

                for(Partner_Tier__c pc : ptCustomSetting)
                {
                    if(acc.Referral_Discount__c == pc.Current_Referral_Discount__c)
                    acc.Referral_Discount_Cap__c = pc.Referral_Discount_Cap__c;
                }
                
                if(acc.Referral_Discount__c == '5%')
                {
                    acc.Referral_Discount_Cap__c = 5000.00;
                }

                if(acc.Referral_Discount__c == '17.5%')
                {
                    acc.Referral_Discount_Cap__c = 17500.00;
                }

                if(acc.Referral_Discount__c == '20%')
                {
                    acc.Referral_Discount_Cap__c = 20000.00;
                }
                
            }

            /**
         * @author Eddie Wong
         * @date 01/21/2021
         * @testclass gtmPlatformEventUpdateTest
         * @description
         * @WorkItem W-007069
         * @description Fire Platform event to handle account's global ranking update on related open opps
         */

            if(acc.Global_Ranking__c != accOld.Global_Ranking__c && Recursionhandler.IsGTMOppGlobalRankingUpdateExecuted == false) {

                System.debug('ed check acc.Global_Ranking__c = ' + acc.Global_Ranking__c);
                System.debug('ed check accOld.Global_Ranking__c = ' + accOld.Global_Ranking__c);
                System.debug('ed check Recursionhandler.IsGTMOppGlobalRankingUpdateExecuted = ' + Recursionhandler.IsGTMOppGlobalRankingUpdateExecuted);

                GTM_Global_Ranking_Opp_Update_Event__e gtmGlobalRankingUpdateEvent = new GTM_Global_Ranking_Opp_Update_Event__e(GTM_Account__c = acc.Id);
                gtmGlobalRankingOppUpdateEventList.add(gtmGlobalRankingUpdateEvent);
            }

        }

        if(!gtmGlobalRankingOppUpdateEventList.isEmpty()) {
            System.debug('ed check gtmGlobalRankingOppUpdateEventList = ' + gtmGlobalRankingOppUpdateEventList);

            EventBus.publish(gtmGlobalRankingOppUpdateEventList);
        }
    }

    /**
     * On After Update.
     */
     
    public void onAfterUpdate(Map<Id, Account> oldMap, Map<Id, Account> newMap) {
        system.debug('Inside After Update');
        
        Set<Id> accsToUpdateOppReferralSet = new Set<Id>();
        //Author: Chris Salgado
        //Date: 08/14/2019
        //W-012807
        //Stamp the Tax Reg Number on all open Quotes
        List<Account> acctsToUpdate = new List<Account>();
        Map<Id, Account> accountIdToAccountMap = new Map<Id, Account>();

        for (Id accId : newMap.KeySet()) {
            Account acc = newMap.get(accId);
            Account accOld = (Account) Trigger.oldMap.get(acc.Id);

            if(acc.Partner_Tier__c != accOld.Partner_Tier__c)
            {
                accsToUpdateOppReferralSet.add(acc.Id); 
            }

            if(acc.Tax_Reg_Number__c != accOld.Tax_Reg_Number__c){
                //Add to List
                acctsToUpdate.add(acc);
            }

            //Sergio Flores
            //Date: 11/27/2019
            //W-013601
            if(    (acc.BillingStreet != accOld.BillingStreet) 
                || (acc.BillingCity != accOld.BillingCity)
                || (acc.BillingState != accOld.BillingState)
                || (acc.BillingCountry != accOld.BillingCountry)
                || (acc.BillingPostalCode != accOld.BillingPostalCode)
                )
            {
                system.debug('account address changed');
                accountIdToAccountMap.put(acc.Id, acc);
            }
        }

        if(!accountIdToAccountMap.isEmpty())
        {
            AccountGateway.syncQuoteAddress(accountIdToAccountMap);
        }

        //Author: Sergio Flores
            //Date: 10/24/2018
            //W-010475
            //Need to check all the opportunities related to the accounts that were updated and update the referral fee %
        if(!accsToUpdateOppReferralSet.IsEmpty())
        {
            List<Opportunity> oppToUpdateList = new List<Opportunity>();
            List<Opportunity> oppsReferralList = [Select Id, Referral_Discount__c,  Partner_Account_Lookup__r.Referral_Discount__c 
                                              From Opportunity 
                                              Where isclosed = false AND Partner_Account_Lookup__c IN : accsToUpdateOppReferralSet];
            system.debug('oppsReferralList ' + oppsReferralList);

            for(Opportunity opp : oppsReferralList)
            {
                system.debug('Referral Discount '+ opp.Partner_Account_Lookup__r.Referral_Discount__c);
                String referral = opp.Partner_Account_Lookup__r.Referral_Discount__c.removeEnd('%');
                Decimal accountReferralDiscount = Decimal.valueOf(referral);
                opp.Referral_Discount__c = accountReferralDiscount;
                oppToUpdateList.add(opp);

                system.debug('Adding to OppList' + opp);
            }

            try {
               Database.update(oppToUpdateList, false);
            } catch (Exception ex) {
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
            }
        }

        //If List is not empty
        if(!acctsToUpdate.isEmpty()){
            //Send List to Gateway method
            AccountGateway.updateTaxRegNumOnQuotes(acctsToUpdate);
        }
    }

    /**
     * On Before Delete.
     */
    //public void onBeforeDelete(Map<Id, Account> oldMap) {}

    /**
     * On After Delete.
     */
    //public void onAfterDelete(Map<Id, Account> oldMap) {}

    /**
     * On After Undelete.
     */
    //public void onAfterUndelete(List<Account> newList) {}
}