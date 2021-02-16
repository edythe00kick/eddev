public class returnQuoteLines {
    //capture the quote id
    public ID quoteID {get; set;}
    
    public List<SBQQ__QuoteLine__c> quoteLinesList = new List<SBQQ__QuoteLine__c>();

    public List<SBQQ__QuoteLine__c> getQuoteLinesList() {
        List<SBQQ__QuoteLine__c> quoteLinesList = [Select SBQQ__ProductFamily__c,  SBQQ__ProductName__c, SBQQ__EffectiveStartDate__c,
                                                  SBQQ__EffectiveEndDate__c, SBQQ__ListPrice__c, SBQQ__NetPrice__c, 
                                                  SBQQ__EffectiveQuantity__c,SBQQ__Discount__c, SBQQ__TotalDiscountRate__c                                               
                                                  From SBQQ__QuoteLine__c Where SBQQ__Quote__c =: quoteID AND SBQQ__EffectiveQuantity__c >= 1]; 
        system.debug('quoteLinesList ' + quoteLinesList);
        
        
        return quoteLinesList;
    }

}