/* Author: Sharma Nemani | W-011973 | Case: 00267748
 * Date: 05/16/2019
 * Description: To create Earning Overview record from Opportunity.
*/
global class AddEarningOverView {
@AuraEnabled
    webservice static String createEarningOverView(Id oppId) {
        Opportunity opp = [select id,stagename,CloseDate,Owner.CY_Sales_Region__c,AccountId,Account.Name,Account.Industry,Account.ShippingCountry,Owner.Name,Sales_Engineer_LookUp__r.name,Account.Customer_Success_Manager__r.Name, Products_to_be_added_to_email_alert__c,
                           Services_to_be_added_to_email_alert__c,Total_Contract_Value_Amount__c,Type, Term_in_Months__c,Department__c,Generating_Department__c,
                           Reason_for_Win__c,Describe_the_customer_s_business_problem__c,How_will_they_fix_this_with_Alteryx__c,Quantifiable_impact_to_business__c,Most_important_feature_or_capability__c,
                           Recognition__c,Use_Case__c,Primary_Competition__c,Competitor_Product__c,Partner_Role__c,Partner_Account_Name__c,Account.Logo_Name_Use_Allowed__c,Account.Opt_Out_Req__c,
                           Account.Logo_Usage_Review_Date__c,Account.Logo_Usage_Reviewed_By__c      from opportunity where Id =:oppId];
        
        
        if(opp!=null && opp.stagename != '5 - Closed Won'){
            return 'Earning Overview  can be created only from Closed Won Opportunity';
        }    
        system.debug('oppId :: '+oppId);
        //Checking if Earning Overview already exists on an Opportunity to restrict the button to create only 
        //one Earning Overview record on any Opportunity.
        List<Earnings_Overview__c> eo = [select id,Opportunity_ID__c from Earnings_Overview__c where Opportunity_ID__c =:oppId];
        if(eo.size() != 0){
            //return 'Earning Overview already exists ';  Commented by: Sharma Nemani | Date: 06/13/2019 | W-012261 | Case: 00282029
            return eo[0].Id; //Added by: Sharma Nemani | Date: 06/13/2019 | W-012261 | Case: 00282029
        }
        
        return createEarningOverViewRecord(opp);
    }
    public static string createEarningOverViewRecord(Opportunity opp){
        Earnings_Overview__c eo = new Earnings_Overview__c();
        eo.Opportunity_ID__c = opp.Id;
       // eo.OpportunityLink__c = System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+opp.Id;
        eo.Close_Date__c = opp.CloseDate;
        eo.Sales_Region__c = opp.Owner.CY_Sales_Region__c;
        eo.Account_Name__c = opp.Account.Name;
        eo.Industry__c  = opp.Account.Industry;
        eo.Country__c  = opp.Account.ShippingCountry;
        eo.Account_Executive__c  = opp.Owner.Name;
        eo.Sales_Engineer__c  = opp.Sales_Engineer_LookUp__r.name;
        eo.CSM__c  = opp.Account.Customer_Success_Manager__r.Name;
        eo.Product_Categories__c  = opp.Products_to_be_added_to_email_alert__c;
        eo.Customer_Support_Packages__c   = opp.Services_to_be_added_to_email_alert__c;
        eo.Total_Contract_Value__c   = opp.Total_Contract_Value_Amount__c;
        eo.Class_of_Business__c   = opp.Type;
        eo.Contract_Term__c   = opp.Term_in_Months__c;
        eo.Department__c    = opp.Department__c;
        eo.Generating_Department__c    = opp.Generating_Department__c ;
        eo.Reason_for_Win__c    = opp.Reason_for_Win__c;
        eo.Describe_the_customer_s_problem__c    = opp.Describe_the_customer_s_business_problem__c;
        eo.Additional_Information__c    = opp.Use_Case__c;
        eo.Primary_Competition__c    = opp.Primary_Competition__c ;
        eo.Competitor_Product__c    = opp.Competitor_Product__c ;
        eo.Partner_Role__c    = opp.Partner_Role__c ;
        eo.Partner_Account_Name__c    = opp.Partner_Account_Name__c ;
        eo.How_will_they_fix_this_business_problem__c = opp.How_will_they_fix_this_with_Alteryx__c;
        eo.Quantifiable_impact_to_business__c    = opp.Quantifiable_impact_to_business__c;
        eo.Most_important_feature_or_capability__c    = opp.Most_important_feature_or_capability__c;
        eo.Logo_Name_Use_Allowed__c = opp.Account.Logo_Name_Use_Allowed__c;
        eo.Opt_Out_Reason__c = opp.Account.Opt_Out_Req__c;
        eo.Logo_Usage_Review_Date__c = opp.Account.Logo_Usage_Review_Date__c;
        eo.Logo_Usage_Reviewed_By__c = opp.Account.Logo_Usage_Reviewed_By__c;

        
        try{
            insert eo; 
            return eo.Id;
        }catch(Exception ee){
            return ee.getMessage();
        }
    }
}