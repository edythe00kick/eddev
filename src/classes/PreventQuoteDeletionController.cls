/* Author: Sharma Nemani | W-013136 & W-013397| Case: 00302811 & 00302812
   Date: 09/26/2019. Modified the code again on 10/16/2019 for W-013397
   Description: This Controller Class is used in "PreventQuoteDeletion" Visualforce Page.
*/
public class PreventQuoteDeletionController { 
    public string retUrl {get;set;} 
    public SBQQ__Quote__c quote {get;set;}
    public PreventQuoteDeletionController(ApexPages.StandardController controller){
		retUrl = ApexPages.currentPage().getParameters().get('retURL');
            //system.URL.getSalesforceBaseUrl().toExternalForm();
        if(!Test.isRunningTest()){quote = [select id, SBQQ__Opportunity2__c, Order_Group__c from SBQQ__Quote__c where Id=:((SBQQ__Quote__c)controller.getRecord()).Id];}
        
    }
}