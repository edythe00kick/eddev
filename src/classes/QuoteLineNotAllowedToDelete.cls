/* Author: Sharma Nemani | W-012607 | Case: 00289401
   Date: 07/24/2019
   Description: This Controller Class is used in "QuoteLinesNotAllowedToDelete" Visualforce Page.
*/
public class QuoteLineNotAllowedToDelete { 
    public string parentQuoteId {get;set;} 
    public QuoteLineNotAllowedToDelete(ApexPages.StandardController controller){
        parentQuoteId = '';
        if(!Test.isRunningTest()){parentQuoteId = [select id,SBQQ__Quote__c from SBQQ__QuoteLine__c where Id=:((SBQQ__QuoteLine__c)controller.getRecord()).Id].SBQQ__Quote__c;}
        
    }
}