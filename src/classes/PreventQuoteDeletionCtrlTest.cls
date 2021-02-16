/* Author: Sharma Nemani | W-013136 | Case: 00302811
   Date: 09/26/2019
   Description: This is a Test Class for "PreventQuoteDeletionController" Class.
*/
@isTest
private class PreventQuoteDeletionCtrlTest {
    static testMethod void testPreventQuoteDeletion() {
		ApexPages.StandardController controller = new ApexPages.StandardController(new SBQQ__Quote__c());
        new PreventQuoteDeletionController(controller);
    }
}