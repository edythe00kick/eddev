/*
 	* Name: Sharma Nemani | W-010323 | Case: 00234328
 	* Description: This is the Test Class for the ClsCloneECURtoNBEC Class.
	* Date: 03/11/2019
*/

@isTest
public class ClsCloneECURtoNBECTest {
	// Standard price book entry ID
    private static Id priceBookEntryId = Test.getStandardPricebookId();
	
	 static testMethod void testproposalAcceptanceNotifiaction() {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
         insert acc;
        Contact cont = OrgWideTestUtil.createContact(true,acc.Id);
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(false,acc.Id);
        opp.Amount = 100.00;
        opp.Primary_Contact__c = cont.Id;
        opp.StageName = System.label.StageName_D;
        opp.ForecastCategoryName = 'SF Commit';
        opp.Type = 'ECUR';
        insert opp;
         
        Custom_Partner__c partner = new Custom_Partner__c();
         partner.Role__c = 'Referrer';
         partner.OpportunityId__c  = opp.Id;
         partner.AccountFromId__c   = acc.Id;
		insert partner;
         
        Test.startTest();
         	 ClsCloneECURtoNBEC.cloneECURtoNBEC(opp.Id);
         	 List<Opportunity> oppList = [Select id from Opportunity];
         	System.assertEquals(oppList.size(), 2);
        Test.stopTest();
    }	
}