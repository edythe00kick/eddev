@isTest
public class OpportunityTriggerTest{
    
    public static testMethod void Scenario1(){
        //Name: Chris Salgado Date: 2/11/20 Purpose: Failing Test Class cause User is no longer active
        /*User usr = [SELECT Id
                        FROM User 
                        WHERE Username LIKE '%aayusa@alteryx.com%' AND IsActive=true LIMIT 1];*/
        User usr = OrgWideTestUtil.getUser();
        
        Account acc = OrgWideTestUtil.createPartnerAccount(true);
        acc.Enterprise_Expand_Geo_Owner__c = usr.id;
        update acc;

        Contact con = OrgWideTestUtil.createContact(true, acc.Id);
        Opportunity opp = OrgWideTestUtil.createClosedOpportunity(true, acc.Id);
        
    }

    public static testMethod void Scenario2(){
        //Name: Chris Salgado Date: 2/11/20 Purpose: Failing Test Class cause User is no longer active
        /*User usr = [SELECT Id
                        FROM User 
                        WHERE Username LIKE '%aayusa@alteryx.com%' AND IsActive=true LIMIT 1];*/
        User usr = OrgWideTestUtil.getUser();
        
        Account acc = OrgWideTestUtil.createPartnerAccount(true);
        acc.Enterprise_Expand_Geo_Owner__c = usr.id;
        update acc;

        Contact con = OrgWideTestUtil.createContact(true, acc.Id);
        Opportunity opp = OrgWideTestUtil.createOpportunity(true, acc.Id);
        opp.type = 'NB';
        update opp;
        OpportunityContactRole ocr = new OpportunityContactRole(ContactId = con.Id,OpportunityId = opp.Id,IsPrimary = TRUE,Role = 'Gallery User');
        insert ocr;
        opp.StageName = System.label.StageName_F;
        opp.SAO_Contact__c = con.id;
        update opp;
        
    }

    public static testMethod void commissionFields()
    {
        //Name: Chris Salgado Date: 2/11/20 Purpose: Failing Test Class cause User is no longer active
        /*User usr = [SELECT Id
                        FROM User 
                        WHERE Username LIKE '%aayusa@alteryx.com%' AND IsActive=true LIMIT 1];*/
        User usr = OrgWideTestUtil.getUser();
        
        Account acc = OrgWideTestUtil.createPartnerAccount(true);
        acc.Enterprise_Expand_Geo_Owner__c = usr.id;
        update acc;

        Opportunity opp = OrgWideTestUtil.createOpportunity(true, acc.Id);

        test.startTest();

        opp.StageName = '5 - Closed Won';
        opp.Reason_For_Win__c = 'test';
        opp.Type = 'NB';

        update opp;

        Opportunity updatedOpp = [Select amount, iswon, Commission_Date__c, Commission_Amount__c,Date_Stage_Moved_to_7_Closed_Won__c,NB_Commission_Logo__c
                                  From Opportunity
                                  Where Id =: opp.Id];

        System.assertEquals(date.today(), updatedOpp.Commission_Date__c);
        System.assertEquals(date.today(), updatedOpp.Date_Stage_Moved_to_7_Closed_Won__c);
        System.assertEquals(true, updatedOpp.NB_Commission_Logo__c);
        System.assertEquals(updatedOpp.Commission_Amount__c, updatedOpp.amount);


        test.stopTest();
    }

    //Author: Sergio Flores
    //Date: 10/29/2018
    //W-010483 
    /*static testMethod void updateProposalToResellerMLA()
    {
        //Create Account

        //Create Contact

        //Create Opp

        //Create Proposal

        //Update Opp record type to Partner Opportunity

        //Check that the proposal license agreement is = to Reseller

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(true,acc.Id);
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(false,acc.Id);
        opp.Primary_Contact__c = cont.Id;
        insert opp;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp.Id, acc.Id);

        quote.SBQQ__Primary__c = true;
        quote.MLA_Option__c = 'EULA';
        insert quote;

        test.startTest();

        opp.RecordTypeId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Partner Opportunity').getRecordTypeId();

        update opp;

        SBQQ__Quote__c quote1 = [Select MLA_Option__c From SBQQ__Quote__c Where Id =: quote.Id];

        system.assertEquals('Reseller', quote1.MLA_Option__c); 

        test.stopTest();
    }*/

    //Author: JP Horton
    //Date: 01/24/2018
    //W-010988
    static testMethod void updateParentOppOnClose()
    {
        //Create Account

        //Create Contact

        //Create Parent ECUR Opp
        
        //Create NBEC Child Opp

        //Create User
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc; 

        Contact cont = OrgWideTestUtil.createContact(true,acc.Id);
        
        Opportunity oppParent = OrgWideTestUtil.createOpportunity(false,acc.Id);
        oppParent.Type = 'ECUR';
        insert oppParent;
        
        Opportunity oppChild  = OrgWideTestUtil.createOpportunity(false,acc.Id);
        oppChild.Type = 'NBEC';
        oppChild.Parent_Opportunity__c = oppParent.Id;
        insert oppChild;

        test.startTest();

        Opportunity oppParent2 = [Select StageName, Reason_For_Win__c, Type, Rep_Territory_Code__c, SAO_Date__C From Opportunity Where Id =: oppParent.id];
        
        //test to see that the rep territory code on the opportunity is equal to the Legacy Rep Territory Code
        system.assert(oppChild.StageName != '5 - Closed Won');
        oppParent2.StageName = '5 - Closed Won';
        oppParent2.Reason_For_Win__c = 'test';
        update oppParent2;

        Opportunity oppChild2 = [Select Id, StageName, Reason_For_Win__c, Type From Opportunity Where Id =: oppChild.id];
        //Check to see that the rep territory code on the opportunity is equal to the new Rep Territory Code
        system.assertEquals(oppChild2.StageName, '5 - Closed Won');
        system.assertEquals(oppChild2.Reason_For_Win__c, 'Ease of Use');

        test.stopTest();
        
    }

    //Author: Sergio Flores
    //Date: 12/18/2018
    //W-010722
    static testMethod void stampRepTerrCodeOnOppSplits()
    {
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

        system.runAs(u) {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Customer_Success_Manager__c = u2.id;
        insert acc; 

        Contact cont = OrgWideTestUtil.createContact(true,acc.Id);
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(false,acc.Id);
        opp.Primary_Contact__c = cont.Id;
        insert opp;

        Opportunity opportunity = [Select Id, StageName, Reason_For_Win__c, Type, Rep_Territory_Code__c, SAO_Date__C From Opportunity Where Id =: opp.id];
        opportunity.SAO_Date__C = Date.newInstance(2018,1,15);
        update opportunity;
        system.System.debug('opp1 ' + opp);

        test.startTest();

        List<Id> opportunityId = new List<Id>();
        opportunityId.add(opportunity.id);

        OpportunityUtilityClass.stampRepTerrCodeOnOpportunity(opportunityId);

        
        /*Opportunity opp3= [Select Id, StageName, Reason_For_Win__c, Type, Rep_Territory_Code__c, SAO_Date__C From Opportunity Where Id =: opp2.id];
        //Check to see that the rep territory code on the opportunity is equal to the new Rep Territory Code
        system.assertEquals(opp3.Rep_Territory_Code__c, 'APAC - ANZ - ANZ - ANZ 01');

        opp3.StageName = '5 - Closed Won';
        opp3.Reason_For_Win__c = 'test';
        opp3.Type = 'NB';

        update opp3;*/

        

        test.stopTest();

        Opportunity opp2 = [Select Id, StageName, Reason_For_Win__c, Type, Rep_Territory_Code__c, SAO_Date__C From Opportunity Where Id =: opportunity.id];

        system.System.debug('opp2 ' + opp2);
        //test to see that the rep territory code on the opportunity is equal to the Legacy Rep Territory Code
        system.assertEquals(opp2.Rep_Territory_Code__c, '1234567');
        //opp2.SAO_Date__C = Date.newInstance(2019,1, 01); 
        //update opp2;


        }

        
    }

    //Author: Sergio Flores
    //Date: 12/18/2018
    //W-010722
    //This part is to test that the the stamping occurs before 2019 and there 
    //is a CSM user on the Account
    static testMethod void stampRepTerrCodeOnOppSplitswithCSM()
    {
        //Create Account

        //Create Contact

        //Create Opp

        //Create User
         Profile p = [select id from profile where Name Like '%System Administrator' limit 1];
           
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
        u2.Rep_Territory_Code__c = '123456790';
        u2.CY_Sales_Group__c = 'ANZ';
        u2.CY_Sales_Region__c = 'APAC';
        u2.CY_Sales_Team__c = 'ANZ';
        u2.CY_Sales_Territory__c = '01';

        Opportunity opp = new Opportunity();
        
        insert u2;

        system.runAs(u) {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Customer_Success_Manager__c = u2.id;
        insert acc; 

        Contact cont = OrgWideTestUtil.createContact(true,acc.Id);
        
        opp = OrgWideTestUtil.createOpportunity(false,acc.Id);
        opp.Primary_Contact__c = cont.Id;
        insert opp;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp.Id, acc.Id);

        quote.SBQQ__Primary__c = true;
        insert quote;


        }

        /*Opportunity opportunity = [Select Id, StageName, Reason_For_Win__c, Type, Rep_Territory_Code__c, SAO_Date__C From Opportunity Where Id =: opp.id];
        opportunity.SAO_Date__C = Date.newInstance(2018,1,15);
        update opportunity;
        system.System.debug('opp1 ' + opp);*/

        test.startTest();

        Profile dealDeskProfile = [select id from profile where Name Like '%Deal Desk' limit 1];

        //CSM
        User dealDesk = new user();
        dealDesk.LastName = 'Interactive';
        dealDesk.Email = 'ctestx@gmail.com';
        dealDesk.Alias = 'Tcode';
        dealDesk.Username = 'testoppSPlit3@test.com';
        dealDesk.CommunityNickname = 'test14';
        dealDesk.LocaleSidKey = 'en_US';
        dealDesk.TimeZoneSidKey = 'GMT';
        dealDesk.ProfileID = dealDeskProfile.id;
        dealDesk.LanguageLocaleKey = 'en_US';
        dealDesk.EmailEncodingKey = 'UTF-8';
        dealDesk.isActive=True;
        dealDesk.Rep_Territory_Code__c = '123456790';
        dealDesk.CY_Sales_Group__c = 'ANZ';
        dealDesk.CY_Sales_Region__c = 'APAC';
        dealDesk.CY_Sales_Team__c = 'ANZ';
        dealDesk.CY_Sales_Territory__c = '00';

        //Need to run as a deal desk user since these users are the ones that are able
        //to close proposals/switch Opps to Closed - Won
        system.runAs(dealDesk)
        {
        Opportunity opp3= [Select Id, StageName, Reason_For_Win__c, Type, Rep_Territory_Code__c, SAO_Date__C From Opportunity Where Id =: opp.id];
        //Check to see that the rep territory code on the opportunity is equal to the new Rep Territory Code
        //system.assertEquals(opp3.Rep_Territory_Code__c, 'APAC - ANZ - ANZ - ANZ 01');

        opp3.StageName = '5 - Closed Won';
        opp3.Reason_For_Win__c = 'test'; 

        update opp3;
        


        List<Id> opportunityId = new List<Id>();
        opportunityId.add(opp3.id); 

        OpportunityUtilityClass.stampRepTerrCodeOnOpportunityClosedWon(opportunityId);

        test.stopTest();

        Opportunity opp4 = [Select Id, Customer_Success_Manager__c, StageName, Reason_For_Win__c, Type, Rep_Territory_Code__c, SAO_Date__C From Opportunity Where Id =: opp3.id];

        system.System.debug('opp4 ' + opp4);
        //test to see that the rep territory code on the opportunity is equal to the Rep Territory Code
        system.assertEquals(opp4.Rep_Territory_Code__c, 'APAC - ANZ - ANZ - 00');
        system.assertEquals(opp4.Customer_Success_Manager__c, 'APAC - ANZ - ANZ - 01');
        }
        

        
    }

    //Author: Sergio Flores
    //Date: 02/05/2019
    //W-010943
    //This part is to test that the populating of Term in Months and TCV 
    //This will also test for updating the Opp Term in Months
    static testMethod void stampTermInMonthsandTCVonOPPCreation()
    {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(true,acc.Id);
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(false,acc.Id);
        opp.Primary_Contact__c = cont.Id;
        opp.Term_In_Months__c = 24;
        opp.Forecast_Amount__c = 5000;
        insert opp;

        test.startTest();

        Opportunity insertedOpp = [Select Id, Term_In_Months__c, Total_Contract_Value_Amount__c From Opportunity Where Id =: opp.Id];

        system.assertEquals(insertedOpp.Total_Contract_Value_Amount__c, 10000);

        insertedOpp.Term_In_Months__c = 36;
        update insertedOpp;

        Opportunity updatedOpp = [Select Id, Term_In_Months__c, Total_Contract_Value_Amount__c From Opportunity Where Id =: insertedOpp.Id];
        system.assertEquals(updatedOpp.Total_Contract_Value_Amount__c, 15000);

        test.stopTest();


    }



}