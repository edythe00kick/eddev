/**
 * Created by ewong on 6/30/2020.
 * W-005163
 * Test Class: BatchLPStampOnSubscriptionsTest
 * To stamp License Product on Subscriptions
 */

global without sharing class BatchLPStampOnSubscriptions implements Database.Batchable<sObject>, Database.Stateful {

    global BatchLPStampOnSubscriptions(){

    }

    global Database.queryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id, SBQQ__RevisedSubscription__c,createddate,License_Product__c,SBQQ__QuoteLine__c,SBQQ__RequiredByProduct__c,SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c,SBQQ__OriginalQuoteLine__c' +
                ' FROM SBQQ__Subscription__c' +
                ' WHERE createddate = last_n_days:7 AND License_Product__c = null AND SBQQ__QuoteLine__c != null AND SBQQ__RequiredByProduct__c != null ';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SBQQ__Subscription__c> subsList){

        System.debug('eddie inside BatchLPStampOnSubscriptions subsList = ' + subsList);

        Map<Id, SBQQ__Subscription__c> subscriptionIdToSubMap = new Map<Id, SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> subscriptionIdToSubMapForExistingQL = new Map<Id, SBQQ__Subscription__c>();
        Set<Id> qLineSet = new Set<Id>();
        Map<Id, SBQQ__Subscription__c> qLineToOriginalQLineMap = new Map<Id, SBQQ__Subscription__c>();
        List<SBQQ__Subscription__c> subsToUpdate = new List<SBQQ__Subscription__c>();

        for(SBQQ__Subscription__c sub : subsList) {

            System.debug('eddie inside BatchLPStampOnSubscriptions forloop' + sub.Id + '' + sub.License_Product__c);
            System.debug('eddie inside sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c' + sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c);


            if (sub.License_Product__c == NULL && sub.SBQQ__QuoteLine__c != NULL && sub.SBQQ__RequiredByProduct__c != null && sub.SBQQ__RevisedSubscription__c == null){  //New product

                System.debug('eddie inside BatchLPStampOnSubscriptions SBQQ__QuoteLine__c new product' + sub.SBQQ__QuoteLine__c);
                System.debug('eddie inside BatchLPStampOnSubscriptions SBQQ__QuoteLine__c new product' + sub);

                qLineSet.add(sub.SBQQ__QuoteLine__c);
                subscriptionIdToSubMap.put(sub.Id, sub);

            }

            else if (sub.License_Product__c == NULL && sub.SBQQ__QuoteLine__c != NULL && sub.SBQQ__RequiredByProduct__c != null && sub.SBQQ__RevisedSubscription__c != null){  //Existing product new quantity

                System.debug('eddie inside SubscriptionHandler SBQQ__QuoteLine__c existing product' + sub.SBQQ__QuoteLine__c);
                System.debug('eddie inside SubscriptionHandler SBQQ__QuoteLine__c existing product' + sub);

                qLineToOriginalQLineMap.put(sub.SBQQ__OriginalQuoteLine__c, sub);


            }

        }

        if (!qLineSet.isEmpty() && !subscriptionIdToSubMap.isEmpty()){

            Map<Id, License_Product__c> licProdIdToLPMap = new Map<Id, License_Product__c>([SELECT Id, Quote_Line__c FROM License_Product__c WHERE Quote_Line__c IN : qLineSet]);
            Map<Id, License_Product__c> quoteLineIdToLicenseProductMap =  new Map<Id, License_Product__c>();


            for(License_Product__c lp : licProdIdToLPMap.values())
            {
                quoteLineIdToLicenseProductMap.put(lp.Quote_Line__c, lp);
            }


            for (SBQQ__Subscription__c sub : subscriptionIdToSubMap.values()){

                SBQQ__Subscription__c subsToAdd = new SBQQ__Subscription__c();

                License_Product__c lp = quoteLineIdToLicenseProductMap.get(sub.SBQQ__QuoteLine__c);

                if(lp !=null)
                {
                    subsToAdd.Id = sub.Id;
                    subsToAdd.License_Product__c = lp.Id;
                    subsToUpdate.add(subsToAdd);
                }

            }

        }

        if (!qLineToOriginalQLineMap.isEmpty()){

            Map<Id, License_Product__c> originalQLLicProdIdToLPMap = new Map<Id, License_Product__c>([SELECT Id,Quote_Line__c FROM License_Product__c WHERE Quote_Line__c IN : qLineToOriginalQLineMap.keySet()]);

            System.debug('eddie inside originalQLLicProdIdToLPMap' + originalQLLicProdIdToLPMap);
            System.debug('eddie inside originalQLLicProdIdToLPMap' + originalQLLicProdIdToLPMap.values());

            Map<Id, License_Product__c> originalQuoteLineIdToLicenseProductMap =  new Map<Id, License_Product__c>();


            for (License_Product__c lp : originalQLLicProdIdToLPMap.values())
            {
                originalQuoteLineIdToLicenseProductMap.put(lp.Quote_Line__c, lp);
            }

            System.debug('eddie inside originalQuoteLineIdToLicenseProductMap' + originalQuoteLineIdToLicenseProductMap);


            for (SBQQ__Subscription__c sub : qLineToOriginalQLineMap.values()){

                SBQQ__Subscription__c subsToAdd = new SBQQ__Subscription__c();

                System.debug('eddie inside originalQuoteLineIdToLicenseProductMap.get(sub)' + originalQuoteLineIdToLicenseProductMap.get(sub.SBQQ__OriginalQuoteLine__c));

                License_Product__c lp = originalQuoteLineIdToLicenseProductMap.get(sub.SBQQ__OriginalQuoteLine__c);

                System.debug('eddie inside lp check' + lp);

                if(lp !=null)
                {
                    subsToAdd.Id = sub.Id;
                    subsToAdd.License_Product__c = lp.Id;
                    subsToUpdate.add(subsToAdd);
                }


            }
        }



        if (!subsToUpdate.isEmpty()){
            try{
                System.debug('eddie inside subsToUpdate update = ' + subsToUpdate);
                update subsToUpdate;
            } catch (Exception e) {
                System.debug('eddie inside subsToUpdate catch exception');
                trigger.new[0].addError(e.getMessage());
            }
        }
    }



    global void finish(Database.BatchableContext bc){

    }

}