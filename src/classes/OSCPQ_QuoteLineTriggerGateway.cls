public with sharing class OSCPQ_QuoteLineTriggerGateway {

    //Need to check if the Quoteline have only adoptions, if so then we need to update the quote term
        //Sergio Flores
        //Date 11/12/2019
        //W-012918
    public static void checkForAdoptionQls(Set<Id> adoptionQuoteIds, Set<Id> adoptionQuoteLineIds)
    {
        Map<Id, SBQQ__Quote__c> quoteIDToQuoteAdoptionMap = new Map<Id, SBQQ__Quote__c>();
        Map<Id, SBQQ__Quote__c> quoteIDToQuoteNonAdoptionMap = new Map<Id, SBQQ__Quote__c>();

        Map<Id, SBQQ__QuoteLine__c> existingQuoteLines;

        //Need to find existing quote lines
        if(adoptionQuoteLineIds.isEmpty())
        {
            existingQuoteLines = new Map<Id, SBQQ__QuoteLine__c>(
            [Select Id, SBQQ__Quote__c, SBQQ__EffectiveSubscriptionTerm__c, SBQQ__ProductFamily__c, SBQQ__RequiredBy__c
            From SBQQ__QuoteLine__c 
            Where SBQQ__Quote__c IN : adoptionQuoteIds]);
            system.debug('inside existing Quote Lines ' + existingQuoteLines);
        }
        else if(!adoptionQuoteLineIds.isEmpty())
        {
            existingQuoteLines = new Map<Id, SBQQ__QuoteLine__c>(
            [Select Id, SBQQ__Quote__c, SBQQ__EffectiveSubscriptionTerm__c, SBQQ__ProductFamily__c, SBQQ__RequiredBy__c
            From SBQQ__QuoteLine__c 
            Where SBQQ__Quote__c IN : adoptionQuoteIds
            AND Id NOT IN : adoptionQuoteLineIds]);
            system.debug('inside existing Quote Lines after delete' + existingQuoteLines);
        }

        if(existingQuoteLines != null) 
        {
            for(SBQQ__QuoteLine__c ql : existingQuoteLines.values())
            {
                system.debug('inside adoption check loop ' + ql);
                if(ql.SBQQ__ProductFamily__c == 'Adoption' && ql.SBQQ__RequiredBy__c == null)
                {
                    //Need to override map if the term is greater
                    //get quoteIdToQuote Map and check terms                  
                    if(quoteIDToQuoteAdoptionMap.containskey(ql.SBQQ__Quote__c))
                    {
                        SBQQ__Quote__c quote = quoteIDToQuoteAdoptionMap.get(ql.SBQQ__Quote__c);
                        if(ql.SBQQ__EffectiveSubscriptionTerm__c > quote.SBQQ__SubscriptionTerm__c)
                        quote.SBQQ__SubscriptionTerm__c = ql.SBQQ__EffectiveSubscriptionTerm__c;
                    }
                    else
                    {
                        SBQQ__Quote__c quote = new SBQQ__Quote__c();
                        quote.Id = ql.SBQQ__Quote__c;   
                        quote.SBQQ__SubscriptionTerm__c = ql.SBQQ__EffectiveSubscriptionTerm__c;
                        quoteIDToQuoteAdoptionMap.put(quote.Id, quote);
                    }
                    
                }
                //If quote line is non adoption need to new map to show that the quote has non adoption
                else if(ql.SBQQ__ProductFamily__c != 'Adoption' && ql.SBQQ__RequiredBy__c == null)
                {
                    SBQQ__Quote__c quote = new SBQQ__Quote__c();
                    quote.Id = ql.SBQQ__Quote__c;   
                    quote.SBQQ__SubscriptionTerm__c = ql.SBQQ__EffectiveSubscriptionTerm__c;
                    quoteIDToQuoteNonAdoptionMap.put(quote.Id, quote);
                }
            }
        }
            
        system.debug(' quoteAdoption Map ' + quoteIDToQuoteAdoptionMap);
        system.debug(' quoteNonAdoption Map ' + quoteIDToQuoteNonAdoptionMap);
        List<SBQQ__Quote__c> adoptionQuotesToUpdateList = new List<SBQQ__Quote__c>();
        //Here we check the maps of the quotes and see whether we need to update the quote term
        //or not
        if(!quoteIDToQuoteAdoptionMap.isEmpty())
        {
            for(SBQQ__Quote__c quote : quoteIDToQuoteAdoptionMap.values())
            {
                SBQQ__Quote__c nonAdoptionQuote = quoteIDToQuoteNonAdoptionMap.get(quote.Id);
                
                system.debug('inside nonAdoptionQuote' + nonAdoptionQuote);
                if(nonAdoptionQuote == null)
                {
                    adoptionQuotesToUpdateList.add(quote);
                }
            }
        }
        if(!adoptionQuotesToUpdateList.isEmpty())
        {
            update adoptionQuotesToUpdateList;
        }
    }

}