/* Author: Sharma Nemani | W-013035 | Case: 00296706
 * Date: 09/12/2019
 * Description: This Test Class is for "SpecialCaseComponentCtrl" Class.
 */ 
@isTest 
private class SpecialCaseComponentCtrlTest {
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
        
        SpecialCaseComponentCtrl.retrunCase(cse.Id);
    }
}