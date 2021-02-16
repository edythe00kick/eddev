/* Author: Sharma Nemani | W-013090 | Case: 00293335 
 * Date: 09/11/2019
 * Description: This Test Class is for 'CustomCaseCloseComponent'
 */
@isTest 
private class CustomCaseCloseComponentTest {
    static testMethod void testCustomCaseCloseComponent() {
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        case cse = new case();
        cse.accountId = acc.Id;
        cse.Status = 'Submitted';
        cse.Products__c = 'Data';
        cse.Case_Category__c = 'Data';
        cse.Case_Detail__c = 'Address';
        cse.Origin = 'General Email';
        insert cse;
        Boolean isValidUser = CustomCaseCloseComponent.isValidUser();
        CustomCaseCloseComponent.caseInfoToShow(cse.Id);
        CustomCaseCloseComponent.searchAcc('tes');
        CustomCaseCloseComponent.saveCase(cse);
        
        //SpecialCaseComponentCtrl.retrunCase(cse.Id);
        system.assertEquals(true, isValidUser);
    }
}