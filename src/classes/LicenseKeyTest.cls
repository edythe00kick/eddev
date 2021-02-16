@isTest
public class LicenseKeyTest {
    private static Id priceBookEntryId = Test.getStandardPricebookId();

    //Author: Sergio Flores
    //Date: 12/03/2018
    //W-010666
    static testMethod void testContactSupportLevelUpdate()
    {
        //Need Account, Contact, Opp, Proposal, OG, LA, and License Key

        Account acc = OrgWideTestUtil.createAccount(false);
        acc.BillingCountry = 'United States';
        acc.BillingCity = 'Irvine';
        acc.BillingPostalCode = '92780';
        acc.BillingState = 'CA';
        insert acc;
        
        Contact cont = OrgWideTestUtil.createContact(true,acc.Id);
 /*       
        Opportunity opp = OrgWideTestUtil.createOpportunity(false,acc.Id);
        opp.Primary_Contact__c = cont.Id;
        insert opp;

        Apttus_Proposal__Proposal__c prop = OrgWideTestUtil.createProposal(false, opp.Id, acc.Id);

        prop.Apttus_Proposal__Primary__c = true;
        insert prop;
        
        //Create standard product
        Product2 prod = OrgWideTestUtil.createProduct(true);

        PricebookEntry pbe = OrgWideTestUtil.createPricebookEntry(false, prod.Id, priceBookEntryId);
        insert pbe;

        Apttus_Proposal__Proposal_Line_Item__c pli = OrgWideTestUtil.createProposalLineItem(true, prod.Id, prop.Id);
*/
        test.startTest();

        //Create OG
        Order_Group__c og = new  Order_Group__c();
        og.Account__c = acc.Id;
        insert og;

        //Insert ALI
       /* Apttus_Config2__AssetLineItem__c ali = new Apttus_Config2__AssetLineItem__c();
        ali.Apttus_Config2__ProductId__c = prod.Id;
        ali.Name = 'Test';
        ali.Apttus_Config2__Quantity__c = 1;
        ali.Proposal_Id__c = prop.Id;
        insert ali; */

        //Insert License Key
        License_Key__c lk = new License_Key__c();
        lk.Contact__c = cont.Id;
       // lk.Asset_Line_Item__c = ali.Id;
        insert lk; 

        License_Key__c licenseKey = [Select Id, Support_Level__c, Contact__r.Support_Level__c From License_Key__c Where Id =: lk.Id]; 

        system.assertEquals(licenseKey.Support_Level__c,licenseKey.Contact__r.Support_Level__c);

        test.stopTest();


    }


}