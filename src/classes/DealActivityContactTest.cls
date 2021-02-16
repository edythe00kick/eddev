@isTest
public class DealActivityContactTest {

    //Author: Sergio Flores
    //Date: 12/27/2018
    //W-010723
    static testMethod void stampRepTerrCodeOnOppSplits(){
        //Create Account

        //Create Contact

        //Create Opp

        //Create User
        Profile p = [select id from profile limit 1];
           
        User u = new user();
        u.LastName = 'Interactive';
        u.Email = 'ctestx@gmail.com';
        u.Alias = 'Tcode';
        u.Username = 'testoppSPlit@test.com';
        u.CommunityNickname = 'test12';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        u.Rep_Territory_Code__c = '1234567';
        u.CY_Sales_Group__c = 'ANZ';
        u.CY_Sales_Region__c = 'APAC';
        u.CY_Sales_Team__c = 'ANZ';
        u.CY_Sales_Territory__c = '00';
        insert u;
        
        //CSM
        User u2 = new user();
        u2.LastName = 'Interactive';
        u2.Email = 'ctestx@gmail.com';
        u2.Alias = 'Tcode';
        u2.Username = 'testoppSPlit2@test.com';
        u2.CommunityNickname = 'test13';
        u2.LocaleSidKey = 'en_US';
        u2.TimeZoneSidKey = 'GMT';
        u2.ProfileID = p.id;
        u2.LanguageLocaleKey = 'en_US';
        u2.EmailEncodingKey = 'UTF-8';
        u2.isActive=True;
        u2.Rep_Territory_Code__c = '1234567';
        u2.CY_Sales_Group__c = 'ANZ';
        u2.CY_Sales_Region__c = 'APAC';
        u2.CY_Sales_Team__c = 'ANZ';
        u2.CY_Sales_Territory__c = '00';
        
        insert u2;

        System.runAs(u) {
            Account acc = OrgWideTestUtil.createAccount(false);
            acc.Customer_Success_Manager__c = u2.id;
            insert acc; 

            Contact cont = OrgWideTestUtil.createContact(true,acc.Id);
            
            Opportunity opp = OrgWideTestUtil.createOpportunity(false,acc.Id);
            opp.Primary_Contact__c = cont.Id;
            opp.SAO_Date__c = Date.today();
            opp.SQO_Date__c = Date.today();
            insert opp;

            //Create Deal Activity and relate it to Opportunity
            Deal_Activity__c da = new Deal_Activity__c();
            da.Activity_Date__c = date.today();
            da.Activity_Type__c = 'Sales Demo';
            da.Related_Opportunity__c = opp.Id;
            insert da;

            //Now we need a Deal Activity Contact to make sure that the Rep Territory Code is Stamped
            Deal_Activity_Contact__c dac = new Deal_Activity_Contact__c();
            dac.Contact__c = cont.Id;
            dac.Deal_Activity__c = da.Id;
            dac.Qualification_Notes__c = 'Testing';
            dac.Qualification_Method__c = 'Phone';
            insert dac;

            Test.startTest();
            
            dac.Qualification_Status__c = 'Approved';
            update dac;
            
            Test.stopTest();

            Deal_Activity_Contact__c updatedDAC = [Select Rep_Territory_Code__c From Deal_Activity_Contact__c Where Id =: dac.Id];

            if (da.Activity_Date__c.year() <=2018) {
                system.assertEquals(updatedDAC.Rep_Territory_Code__c, '1234567'); 
            } else {
                system.assertEquals(updatedDAC.Rep_Territory_Code__c, 'APAC - ANZ - ANZ - 00');
            }
        }
    }
}