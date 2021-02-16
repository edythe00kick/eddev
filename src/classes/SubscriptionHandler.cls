public class SubscriptionHandler {

    public void onAfterInsert(List<SBQQ__Subscription__c> newRecords) {
        Map<Id, SBQQ__Subscription__c> subscriptionIdToSubMap = new Map<Id, SBQQ__Subscription__c>();

        for (SBQQ__Subscription__c sub : newRecords) {
            //Sergio Flores
            //Date: 01/22/2020
            //W-013849
            /**Here we need to find the subscriptions that are coming in as part of a co-term
            once we have these we will pass these into a queueable class so that the queue can
            see if addition adoptions need to be created, if so we need to update the Original Renewal
            Opportunity on the contract so the TCV and ACV is correct */
            if (sub.Co_Term__c)
                subscriptionIdToSubMap.put(sub.Id, sub);
        }


        if (!subscriptionIdToSubMap.isEmpty() && RecursionHandler.IsCoTermSubscriptionQueueableExecuted == false) {
            System.debug('inside executeCoTermSubscriptionQueuable ' + subscriptionIdToSubMap);
            RecursionHandler.IsCoTermSubscriptionQueueableExecuted = true;
            CoTermSubscriptionQueueable executeCoTermSubscriptionQueueable = new CoTermSubscriptionQueueable(subscriptionIdToSubMap);
            ID jobID = System.enqueueJob(executeCoTermSubscriptionQueueable);
        }

    }

    // Eddie Wong
    // 06/22/2020
    // W-005163
    // To Stamp subscriptions with LP
    public void onBeforeInsert(List<SBQQ__Subscription__c> newRecords){

        System.debug('eddie inside SubscriptionHandler beforeinsert' + newRecords);

        Map<Id, SBQQ__Subscription__c> subscriptionIdToSubMap = new Map<Id, SBQQ__Subscription__c>();
        Map<Id, SBQQ__Subscription__c> subscriptionIdToSubMapForExistingQL = new Map<Id, SBQQ__Subscription__c>();
        Set<Id> qLineSet = new Set<Id>();
        Map<Id, SBQQ__Subscription__c> qLineToOriginalQLineMap = new Map<Id, SBQQ__Subscription__c>();



        for(SBQQ__Subscription__c sub : newRecords) {

            System.debug('eddie inside SubscriptionHandler forloop' + sub.Id + '' + sub.License_Product__c);
            System.debug('eddie inside sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c' + sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c);


            if (sub.License_Product__c == NULL && sub.SBQQ__QuoteLine__c != NULL && sub.SBQQ__RequiredByProduct__c != null && sub.SBQQ__RevisedSubscription__c == null){  //New product

                System.debug('eddie inside SubscriptionHandler SBQQ__QuoteLine__c new product' + sub.SBQQ__QuoteLine__c);
                System.debug('eddie inside SubscriptionHandler SBQQ__QuoteLine__c new product' + sub);

                qLineSet.add(sub.SBQQ__QuoteLine__c);
                subscriptionIdToSubMap.put(sub.Id, sub);

            }

            else if (sub.License_Product__c == NULL && sub.SBQQ__QuoteLine__c != NULL && sub.SBQQ__RequiredByProduct__c != null && sub.SBQQ__RevisedSubscription__c != null){  //Existing product new quantity

                System.debug('eddie inside SubscriptionHandler SBQQ__QuoteLine__c existing product' + sub.SBQQ__QuoteLine__c);
                System.debug('eddie inside SubscriptionHandler SBQQ__QuoteLine__c existing product' + sub);

                qLineToOriginalQLineMap.put(sub.SBQQ__OriginalQuoteLine__c, sub);


            }

        }

        if(!qLineSet.isEmpty()) {
            System.debug('Eddie inside qLineSet ' + qLineSet);
            System.debug('eddie inside subscriptionIdToSubMap' + subscriptionIdToSubMap);
            //SubscriptionGateway.updateSubscriptionWithLicProd(qLineSet, subscriptionIdToSubMap);

        }

        if(!qLineToOriginalQLineMap.isEmpty()) {
            System.debug('Eddie inside qLineNewQuantitySet ' + qLineToOriginalQLineMap);
            //SubscriptionGateway.updateSubscriptionWithLicProdWithOriginalQL(qLineToOriginalQLineMap);

        }


    }







    public void andFinally(){
    }

}