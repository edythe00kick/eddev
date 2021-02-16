/* Author: Sharma Nemani | W-012560 | Case: 00288352
 * Date: 07/11/2019
 * Description: Test Class for the "SubmitToDealDesk" Class.
*/
@isTest
private class SubmitToDealDeskTest {
	static testMethod void testSubmitToDealDesk() {
    	Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc;

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = 'ECUR';
        insert opp1;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(true, opp1.Id, acc.Id);

        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        SubmitToDealDesk controller = new SubmitToDealDesk(sc);
        controller.submitToDD();
    }
}