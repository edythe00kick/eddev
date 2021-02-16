/* Author: Sharma Nemani | W-012560 | Case: 00288352
 * Date: 07/11/2019
 * Description: This is the controller for the "Submit to Deal Desk" Visualforce Page.
*/
public class SubmitToDealDesk {
    Public SBQQ__Quote__c sbq{get;set;}
    public String baseUrl{get;set;}
    Public String error{get;set;}
    public SubmitToDealDesk(ApexPages.StandardController controller){
         sbq = (SBQQ__Quote__c) controller.getRecord();
        if(!Test.isRunningTest()){
            sbq.OwnerId = '00GE0000003ZbIQ';
            sbq.Locked_For_Reps__c = true; //SF 07/23/2019 W-012635
        }
        error = '';
		baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();        
    }
    public void submitToDD(){
        try{
            update sbq;
        }catch(Exception ee){error = ee.getMessage();}
    }
}