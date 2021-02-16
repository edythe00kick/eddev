/*
 * Class Name - ScheduleStampValueTest
 * 
 * %W% %E% Grazitti Team
 * This is the test class for "ScheduleStampValue" schedule class and 
 * "StampValueFromLeadContact" batch class.
 */

/**
 * This class contains different methods to cover the code.
 * 
 * @author Hemendra Singh Rajawat
 * @version 1.0 July 06, 2018
 */

@isTest
public class ScheduleStampValueTest {

    /**
     * Test when the batch is executed for the first time and campaign members 
     * status is "Responded".
     */

    @isTest
    public static void testScenario1() {
        Lead ld = OrgWideTestUtil.createLead(false);
        ld.UTM_Source__c = 'Test Source';
        ld.UTM_Medium__c = 'Test Medium';
        ld.UTM_Campaign_Name__c = 'Test Campaign Name';
        ld.Latticeforleads_Score__c = 10;
        ld.CPC_Keyword__c = 'Test Keyword';
        ld.CPC_Ad_Group__c = 'Test Ad Group';
        ld.Lattice_Inbound_NBEC_Lead_Score__c = 10;
        ld.Lattice_Inbound_NB_Lead_Score__c = 10;
        ld.Bounce_Exchange_Source__c = 'https://www.testdata.com';
        ld.Bounce_Exchange_Form__c = 'Test Exchange Form';
        insert ld;

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.UTM_Source__c = 'Test Source1';
        cont.UTM_Medium__c = 'Test Medium1';
        cont.UTM_Campaign_Name__c = 'Test Campaign Name1';
        cont.Latticeforcontacts_Score__c = 20;
        cont.CPC_Keyword__c = 'Test Keyword1';
        cont.CPC_Ad_Group__c = 'Test Ad Group1';
        cont.Lattice_Inbound_NBEC_Lead_Score__c = 20;
        cont.Lattice_Inbound_NB_Lead_Score__c = 20;
        cont.Bounce_Exchange_Source__c = 'https://www.testdata1.com';
        cont.Bounce_Exchange_Form__c = 'Test Exchange Form1';
        insert cont;

        Campaign camp = OrgWideTestUtil.createCampaign(true);
        Campaign camp1 = OrgWideTestUtil.createCampaign(true);

        CampaignMember cm1 
            = OrgWideTestUtil.createCampaignMember(true, 'lead', ld.Id, camp.Id,
                                                   'Responded');

        CampaignMember cm2 
            = OrgWideTestUtil.createCampaignMember(true, 'lead', ld.Id, camp1.Id,
                                                   'Responded');

        CampaignMember cm3 
            = OrgWideTestUtil.createCampaignMember(true, 'contact', cont.Id, 
                                                   camp.Id, 'Responded');

        CampaignMember cm4 
            = OrgWideTestUtil.createCampaignMember(true, 'contact', cont.Id, 
                                                   camp1.Id, 'Responded');

        insert new UTM_Source_Date__c(Name = 'LastDate', 
                                      Last_Executed_Date__c 
                                        = System.now().addDays(-1));

        Test.startTest();

        ScheduleStampValue ssv = new ScheduleStampValue();
        ssv.execute(null);

        Test.stopTest();
    }

    /**
     * Test when the batch is executed for the first time and campaign members 
     * status is "Sent".
     */

    @isTest
    public static void testScenario2() {
        Lead ld = OrgWideTestUtil.createLead(false);
        ld.UTM_Source__c = 'Test Source';
        ld.UTM_Medium__c = 'Test Medium';
        ld.UTM_Campaign_Name__c = 'Test Campaign Name';
        ld.Latticeforleads_Score__c = 10;
        ld.CPC_Keyword__c = 'Test Keyword';
        ld.CPC_Ad_Group__c = 'Test Ad Group';
        ld.Lattice_Inbound_NBEC_Lead_Score__c = 10;
        ld.Lattice_Inbound_NB_Lead_Score__c = 10;
        ld.Bounce_Exchange_Source__c = 'https://www.testdata.com';
        ld.Bounce_Exchange_Form__c = 'Test Exchange Form';
        insert ld;

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.UTM_Source__c = 'Test Source1';
        cont.UTM_Medium__c = 'Test Medium1';
        cont.UTM_Campaign_Name__c = 'Test Campaign Name1';
        cont.Latticeforcontacts_Score__c = 20;
        cont.CPC_Keyword__c = 'Test Keyword1';
        cont.CPC_Ad_Group__c = 'Test Ad Group1';
        cont.Lattice_Inbound_NBEC_Lead_Score__c = 20;
        cont.Lattice_Inbound_NB_Lead_Score__c = 20;
        cont.Bounce_Exchange_Source__c = 'https://www.testdata1.com';
        cont.Bounce_Exchange_Form__c = 'Test Exchange Form1';
        insert cont;

        Campaign camp = OrgWideTestUtil.createCampaign(true);
        Campaign camp1 = OrgWideTestUtil.createCampaign(true);

        CampaignMember cm1 
            = OrgWideTestUtil.createCampaignMember(true, 'lead', ld.Id, camp.Id,
                                                   'Sent');

        CampaignMember cm2 
            = OrgWideTestUtil.createCampaignMember(true, 'lead', ld.Id, camp1.Id,
                                                   'Sent');

        CampaignMember cm3 
            = OrgWideTestUtil.createCampaignMember(true, 'contact', cont.Id, 
                                                   camp.Id, 'Sent');

        CampaignMember cm4 
            = OrgWideTestUtil.createCampaignMember(true, 'contact', cont.Id, 
                                                   camp1.Id, 'Sent');

        insert new UTM_Source_Date__c(Name = 'LastDate', 
                                      Last_Executed_Date__c 
                                        = System.now().addDays(-1));

        Test.startTest();

        ScheduleStampValue ssv = new ScheduleStampValue();
        ssv.execute(null);

        Test.stopTest();
    }

    /**
     * Test when the batch is executed twice and campaign members status is 
     * changed from "Responded" to "Sent" after first execute and changed back 
     * to "Responded" before second execute.
     */

    @isTest
    public static void testScenario3() {
        Lead ld = OrgWideTestUtil.createLead(false);
        ld.UTM_Source__c = 'Test Source';
        ld.UTM_Medium__c = 'Test Medium';
        ld.UTM_Campaign_Name__c = 'Test Campaign Name';
        ld.Latticeforleads_Score__c = 10;
        ld.CPC_Keyword__c = 'Test Keyword';
        ld.CPC_Ad_Group__c = 'Test Ad Group';
        ld.Lattice_Inbound_NBEC_Lead_Score__c = 10;
        ld.Lattice_Inbound_NB_Lead_Score__c = 10;
        ld.Bounce_Exchange_Source__c = 'https://www.testdata.com';
        ld.Bounce_Exchange_Form__c = 'Test Exchange Form';
        insert ld;

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.UTM_Source__c = 'Test Source1';
        cont.UTM_Medium__c = 'Test Medium1';
        cont.UTM_Campaign_Name__c = 'Test Campaign Name1';
        cont.Latticeforcontacts_Score__c = 20;
        cont.CPC_Keyword__c = 'Test Keyword1';
        cont.CPC_Ad_Group__c = 'Test Ad Group1';
        cont.Lattice_Inbound_NBEC_Lead_Score__c = 20;
        cont.Lattice_Inbound_NB_Lead_Score__c = 20;
        cont.Bounce_Exchange_Source__c = 'https://www.testdata1.com';
        cont.Bounce_Exchange_Form__c = 'Test Exchange Form1';
        insert cont;

        Campaign camp = OrgWideTestUtil.createCampaign(true);
        Campaign camp1 = OrgWideTestUtil.createCampaign(true);

        CampaignMember cm1 
            = OrgWideTestUtil.createCampaignMember(true, 'lead', ld.Id, camp.Id,
                                                   'Responded');

        CampaignMember cm2 
            = OrgWideTestUtil.createCampaignMember(true, 'lead', ld.Id, camp1.Id,
                                                   'Responded');

        CampaignMember cm3 
            = OrgWideTestUtil.createCampaignMember(true, 'contact', cont.Id, 
                                                   camp.Id, 'Responded');

        CampaignMember cm4 
            = OrgWideTestUtil.createCampaignMember(true, 'contact', cont.Id, 
                                                   camp1.Id, 'Responded');

        insert new UTM_Source_Date__c(Name = 'LastDate', 
                                      Last_Executed_Date__c 
                                        = System.now().addDays(-1));

        Test.startTest();

        ScheduleStampValue ssv1 = new ScheduleStampValue();
        ssv1.execute(null);

        List<CampaignMember> cms = new List<CampaignMember>();

        cm1.Status = 'Sent';
        cms.add(cm1);
        cm2.Status = 'Sent';
        cms.add(cm2);
        cm3.Status = 'Sent';
        cms.add(cm3);
        cm4.Status = 'Sent';
        cms.add(cm4);

        update cms;

        cms.clear();
        
        cm1.Status = 'Responded';
        cms.add(cm1);
        cm2.Status = 'Responded';
        cms.add(cm2);
        cm3.Status = 'Responded';
        cms.add(cm3);
        cm4.Status = 'Responded';
        cms.add(cm4);

        update cms;

        ScheduleStampValue ssv2 = new ScheduleStampValue();
        ssv2.execute(null);

        Test.stopTest();
    }
}