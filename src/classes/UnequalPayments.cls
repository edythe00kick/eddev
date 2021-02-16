public without sharing class UnequalPayments {
    
    
    @AuraEnabled
    public static SBQQ__Quote__c getQuote (string recordId) {
        
        SBQQ__Quote__c mainquote = new SBQQ__Quote__c();
        system.debug('***inside recordId***' + recordId);
        
        if(recordId !=null)
        {
            List<SBQQ__Quote__c> getMainQuote =  [Select Id, CurrencyIsoCode, Purchase_Type__c, SubscriptionTCV__c, SBQQ__NetAmount__c From SBQQ__QUote__c Where Id =: recordId limit 1];
            mainquote = getMainQuote[0];
            system.debug('***inside mainquote***' + mainquote);
        }

         
        
            
            
            return mainquote;
    }
    
    @AuraEnabled
    public static List<Quote_Subscription_Schedule__c> getSubscriptionSchedules(string recordId) {
        
        
        system.debug('***inside recordId***' + recordId);
        List<Quote_Subscription_Schedule__c> getSubscriptionSchedules =  [Select Id, Quote__c, Year__c, Subscription_Start_Date__c, Subscription_End_Date__c, Net_Total__c, Net_Total_Final__c, Non_Recurring_Total__c, Recurring_Total__c
            					From Quote_Subscription_Schedule__c
            					Where Quote__c =: recordId];
        
            system.debug('***inside getSubscriptionSchedules***' + getSubscriptionSchedules);
            
            return getSubscriptionSchedules;
    }

    
    @AuraEnabled
    public static Boolean updateLineItemSubSchedule(Double[] amountList, List<Quote_Subscription_Schedule__c> subSchedules)
    {
        //We need to create a map of the amount the user put in and the quote subscription schedule
        Map<Id, Double> subScheduleIdToTargetAmountMap = new Map<Id, Double>();
        Boolean updated = false;
        Map<Id, Double> subScheduleIdToPercentMap = new Map<Id, Double>();
        
        List<Id> subScheduleIds = new List<Id>();

        for(Quote_Subscription_Schedule__c qss : subSchedules)
        {
            subScheduleIds.add(qss.Id);

        }
        
        //Only way to create the map is go by index/position of the lists
        for( integer i=0; i < subScheduleIds.size(); i++)
        {
            for( integer j=0; j < amountList.size(); j++)
            {
                if(i == j)
                {
                    subScheduleIdToTargetAmountMap.put(subScheduleIds[i], amountList[j]);
                }
            }
        }

        system.debug('subScheduleIdToTargetAmountMap ' + subScheduleIdToTargetAmountMap);

        for(Quote_Subscription_Schedule__c qss : subSchedules)
        {
            if(qss.Recurring_Total__c > 0)
            {
                Double targetAmount = subScheduleIdToTargetAmountMap.get(qss.Id);

                system.debug('targetAmount ' + targetAmount);
                system.debug('qss.Non_Recurring_Total__c ' + qss.Non_Recurring_Total__c);
                system.debug('qss.Recurring_Total__c ' + qss.Recurring_Total__c);

                Double percent = (targetAmount - qss.Non_Recurring_Total__c)/qss.Recurring_Total__c;

                subScheduleIdToPercentMap.put(qss.Id, percent);
                system.debug('subScheduleIdToPercentMap ' + subScheduleIdToPercentMap);
            }
            

        }

        //Now that we have our map we need to find all the Line Item Subscription schedules that are recurring so we can update those
        List<Line_Item_Subscription_Schedule__c> lssList = [Select Id, Net_Total__c, Recurring_Rev_Product__c, Bundle_Option__c, Quote_Subscription_Schedule__c, Quote_Subscription_Schedule__r.Quote__c
                                                            From Line_Item_Subscription_Schedule__c 
                                                            Where Quote_Subscription_Schedule__c IN : subScheduleIds
                                                            AND Recurring_Rev_Product__c = true
                                                            AND Bundle_Option__c = true];

        system.debug('lssList ' + lssList);

        List<Line_Item_Subscription_Schedule__c> updatedLineItemSubSchedulesList = new List<Line_Item_Subscription_Schedule__c>();
        Set<Id> quotesToUpdateSet = new Set<Id>();

        for(Line_Item_Subscription_Schedule__c lss : lssList)
        {
            Double percent = subScheduleIdToPercentMap.get(lss.Quote_Subscription_Schedule__c);
            system.debug('inside lss loop percent ' + percent);
            system.debug('inside lss loop net total  ' + lss.Net_Total__c);

            Decimal netTotal = lss.Net_Total__c * percent;

            lss.Net_Total__c = netTotal.setScale(2, RoundingMode.HALF_UP);

            updatedLineItemSubSchedulesList.add(lss);

            //Need to update the quote's Unequal Payments Override checkbox so that we can use it
            //in validation so that updates on quote would require to uncheck the checkbox
            if(!quotesToUpdateSet.contains(lss.Quote_Subscription_Schedule__r.Quote__c))
            quotesToUpdateSet.add(lss.Quote_Subscription_Schedule__r.Quote__c);
            
        }

        if(!quotesToUpdateSet.isEmpty())
        {
            List<SBQQ__Quote__c> quotesToUpdateList = [Select Id, Payment_Schedule__c 
            From SBQQ__Quote__c Where Id IN : quotesToUpdateSet];

            if(!quotesToUpdateList.isEmpty())
            {
                for(SBQQ__Quote__c quote : quotesToUpdateList)
                {
                    quote.Payment_Schedule__c = 'Unequal ACV Per Year';
                }

                try{
                    update quotesToUpdateList;
                }
 
                catch (Exception ex) {
                    system.debug('inside catch exception');
                    trigger.new[0].addError(ex.getMessage());   
                } 
            }
        }
        

        system.debug('updatedLineItemSubSchedulesList ' + updatedLineItemSubSchedulesList);
        

        if(!updatedLineItemSubSchedulesList.isEmpty())
        {
            try{
                update updatedLineItemSubSchedulesList;
                updated = true;
                }
 
            catch (Exception ex) {
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());   
            } 
        }



        system.debug('subScheduleIdToTargetAmountMap ' + subScheduleIdToTargetAmountMap);

        return updated;
    }
    
    
    
}