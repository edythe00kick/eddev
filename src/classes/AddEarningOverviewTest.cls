@isTest
public class AddEarningOverviewTest {

    static testMethod void createEarningOverview () {
        Account acc = OrgWideTestUtil.createAccount(false);
     acc.Industry = 'Computers & Software';
        acc.Name = 'Test';
        acc.ShippingCountry = 'CA';
        //acc.Customer_Success_Manager__r = 'Test';
        insert acc;
        
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(false,acc.Id);
        opp.CloseDate = System.today();
        //opp.Owner.CY_Sales_Region__c = 'Test';
        //opp.Owner.Name = 'Test';
        //opp.Sales_Engineer_LookUp__r.name = 'Test'
        //opp.Products_to_be_added_to_email_alert__c = 'Test';
        //opp.Services_to_be_added_to_email_alert__c = 'Test';
        opp.Total_Contract_Value_Amount__c = 10000.0;
        opp.Type = 'NB';
        opp.Term_in_Months__c = 12.03;
        opp.Department__c = 'Sales';
        opp.StageName = '5 - Closed Won';
        opp.Reason_for_Win__c = 'Price';
        opp.Describe_the_customer_s_business_problem__c = 'Test';
        opp.Use_Case__c = 'Test';
        opp.Primary_Competition__c = 'SAP';
        //opp.Competitor_Product__c = 'Cognos';
        opp.Partner_Role__c = 'Test';
        opp.Partner_Account_Name__c = 'Test';
        opp.How_will_they_fix_this_with_Alteryx__c = 'Test';
        opp.Quantifiable_impact_to_business__c = 'Test';
        opp.Most_important_feature_or_capability__c = 'Test';
        insert opp;
        
        /* JPH - Review for CPQ PRoject
        Apttus_Proposal__Proposal__c prop = OrgWideTestUtil.createProposal(false, opp.Id, acc.Id);
        prop.Apttus_Proposal__Primary__c = TRUE;
        prop.Products_to_be_added_to_email_alert__c = 'Test';
        prop.Services_to_be_added_to_email_alert__c = 'Test';*/
        //insert prop;
        
        Test.startTest();
        AddEarningOverView.createEarningOverView(opp.Id);
        List<Earnings_Overview__c> earningOverviewList = [Select id from Earnings_Overview__c];
        System.assertEquals(earningOverviewList.size(), 1);
        Test.stopTest();
        
    }
}