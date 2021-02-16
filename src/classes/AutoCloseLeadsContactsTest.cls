/*
 * Class Name - AutoCloseLeadsContactsTest
 * 
 * %W% %E% Grazitti Team
 * This is the test class for "AutoCloseLeads" && "AutoCloseContacts" batch class.
 */

/**
 * This class contains different methods to cover the code.
 * 
 * @author Grazitti Team
 * @version 1.0 September 19, 2018
 */

@isTest
public class AutoCloseLeadsContactsTest{
    
    @testSetup
    public static void testData(){
        Auto_Close_Limits__c limits = new Auto_Close_Limits__c();
        limits.Name = 'System Settings';
        limits.Final_Status__c = 'Recycled - Timed Out/Autoclose';
        limits.Status_Criteria__c = '2 - Attempting Contact,3 - In Conversation';
        limits.Recipient__c = 'alteryxsfdc@grazitti.com';
        limits.Non_Marketing_Limit__c = 90;
        limits.marketing_Limit__c = 365;
        limits.Lead_Record_Type_Name__c = 'Alteryx Lead Record Type'; //Name: Chris Salgado Date: 9/12/2019 Update: W-010954
        limits.Lead_OwnerID_Exclude__c = '00GE0000003oalP'; //Name: Chris Salgado Date: 9/12/2019 Update: W-010954
        Insert limits;
        
        Account Acc = OrgWideTestUtil.createAccount(true);
        List<Lead> leadList = new List<Lead>();
        List<Contact> contactList = new List<Contact>();

        Lead ld = OrgWideTestUtil.createLead(false);
        ld.Last_Task_Completed_Date__c = System.Today().addDays(-91);
        ld.Marketing_Generated__c = false;
        ld.Status = '2 - Attempting Contact';

        Lead ld1 = OrgWideTestUtil.createLead(false);
        ld1.Last_Task_Completed_Date__c = System.Today().addDays(-366);
        ld1.Marketing_Generated__c = false;
        ld1.Status = '2 - Attempting Contact';

        Lead ld2 = OrgWideTestUtil.createLead(false);
        ld2.Last_Task_Completed_Date__c = System.Today().addDays(-91);
        ld2.Marketing_Generated__c = false;
        ld2.Status = '2 - Attempting Contact';
        leadList.add(ld);
        leadList.add(ld1);
        

        Contact con = OrgWideTestUtil.createContact(false, Acc.Id);
        con.Last_Task_Completed_Date__c = System.Today().addDays(-91);
        con.Marketing_Generated__c = false;
        con.Contact_Status__C = '2 - Attempting Contact';

        Contact con1 = OrgWideTestUtil.createContact(false, Acc.Id);
        con1.Last_Task_Completed_Date__c = System.Today().addDays(-366);
        con1.Marketing_Generated__c = false;
        con1.Contact_Status__C = '2 - Attempting Contact';
        contactList.add(con);
        contactList.add(con1);

        Insert leadList;
        Insert contactList;

    }


    @isTest
    public static void testScenario1(){

        String CRON_EXP = '0 0 0 15 3 ? *';

        Test.startTest();
        String jobIdLeads = System.schedule('ScheduleApexClassTestLeads',  CRON_EXP, new AutoCloseLeadsScheduler());
        String jobIdContacts = System.schedule('ScheduleApexClassTestContacts',  CRON_EXP, new AutoCloseContactsScheduler());
        Test.stopTest();
    }

}