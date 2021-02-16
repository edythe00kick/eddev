@isTest(SeeAllData=True)
public class TestSpecialCampaignType{
    @isTest
    public static void scenario1() {
        List<Lead> lds = new List<Lead> {
            OrgWideTestUtil.createLead(false),
            OrgWideTestUtil.createLead(false)
        };
        Lead lp = OrgWideTestUtil.createLead(false);
        lp.Partner_Id__c='123';
        lds.add(lp);
        insert lds;
        
        Campaign c = OrgWideTestUtil.createCampaign(false);
        c.Total_number_of_Seats__c = 2;
        c.Event_Cap_Qualified__c = true;
        insert c;
        
        //OrgWideTestUtil.setCampaignMemberStatus(c.Id);
        
        List<CampaignMember> cml = new List<CampaignMember> {
            OrgWideTestUtil.createCampaignMember(false, 'lead', lds[0].Id, c.Id, 'Workshop Queue'),
            OrgWideTestUtil.createCampaignMember(false, 'lead', lds[2].Id, c.Id, 'Workshop Queue'),
            OrgWideTestUtil.createCampaignMember(false, 'lead', lds[1].Id, c.Id, 'Workshop Queue')
        };
        insert cml;
        
        Test.startTest();
            List<CampaignMember> cml_del = new List<CampaignMember> { cml[0], cml[1]};
            delete cml_del;
        Test.stopTest();
    }
    
    @isTest
    public static void scenario2() {
        Account acc= new Account();
        acc.Name='testaccount';
        insert acc;
        
        List<Contact> cons =new List<Contact>{
            OrgWideTestUtil.createContact(false, acc.Id),
            OrgWideTestUtil.createContact(false, acc.Id)
        };
        Contact con = OrgWideTestUtil.createContact(false, acc.Id);
        con.Partner_Id__c = '123';
        cons.add(con);
        insert cons;
        
        Campaign c = OrgWideTestUtil.createCampaign(false);
        c.Total_number_of_Seats__c = 2;
        c.Event_Cap_Qualified__c = true;
        insert c;
        
        //OrgWideTestUtil.setCampaignMemberStatus(c.Id);
        
        List<CampaignMember> cml = new List<CampaignMember> {
            OrgWideTestUtil.createCampaignMember(false, 'contact', cons[0].Id, c.Id, 'Workshop Queue'),
            OrgWideTestUtil.createCampaignMember(false, 'contact', cons[2].Id, c.Id, 'Workshop Queue'),
            OrgWideTestUtil.createCampaignMember(false, 'contact', cons[1].Id, c.Id, 'Workshop Queue')
        };
        insert cml;
    }
    
    @isTest
    public static void scenario3() {
        List<Lead> lds = new List<Lead> {
            OrgWideTestUtil.createLead(false),
            OrgWideTestUtil.createLead(false)
        };
        insert lds;
        
        Campaign c = OrgWideTestUtil.createCampaign(false);
        c.Total_number_of_Seats__c = 2;
        c.Event_Cap_Qualified__c = true;
        insert c;
        
        //OrgWideTestUtil.setCampaignMemberStatus(c.Id);
        
        List<CampaignMember> cml = new List<CampaignMember> {
            OrgWideTestUtil.createCampaignMember(false, 'lead', lds[0].Id, c.Id, 'Workshop Queue'),
            OrgWideTestUtil.createCampaignMember(false, 'lead', lds[1].Id, c.Id, 'Workshop Queue')
        };
        insert cml;
        
        Test.startTest();
            cml[0].Status = 'Waitlisted';
            cml[1].Status = 'Waitlisted';
            update cml;
        Test.stopTest();
    }
    
    @isTest
    public static void scenario4() {
        List<Lead> lds = new List<Lead> {
            OrgWideTestUtil.createLead(false)
        };
        Lead lp = OrgWideTestUtil.createLead(false);
        lp.Partner_Id__c='123';
        lds.add(lp);
        lds.add(OrgWideTestUtil.createLead(false));
        insert lds;
        
        Campaign c = OrgWideTestUtil.createCampaign(false);
        c.Total_number_of_Seats__c = 2;
        c.Event_Cap_Qualified__c = true;
        insert c;
        
        //OrgWideTestUtil.setCampaignMemberStatus(c.Id);
        
        List<CampaignMember> cml = new List<CampaignMember> {
            OrgWideTestUtil.createCampaignMember(false, 'lead', lds[0].Id, c.Id, 'Waitlisted'),
            OrgWideTestUtil.createCampaignMember(false, 'lead', lds[1].Id, c.Id, 'Waitlisted'),
            OrgWideTestUtil.createCampaignMember(false, 'lead', lds[2].Id, c.Id, 'Waitlisted')
        };
        insert cml;
        
        Test.startTest();
            cml[0].Status = 'Registered';
            cml[1].Status = 'Registered';
            cml[2].Status = 'Registered';
            update cml;
        Test.stopTest();
    }
    
    @isTest
    public static void scenario5() {
        Account acc= new Account();
        acc.Name='testaccount';
        insert acc;
        
        List<Contact> cons =new List<Contact>{
            OrgWideTestUtil.createContact(false, acc.Id)
        };
        Contact con = OrgWideTestUtil.createContact(false, acc.Id);
        con.Partner_Id__c = '123';
        cons.add(con);
        cons.add(OrgWideTestUtil.createContact(false, acc.Id));
        insert cons;
        
        Campaign c = OrgWideTestUtil.createCampaign(false);
        c.Total_number_of_Seats__c = 2;
        c.Event_Cap_Qualified__c = true;
        insert c;
        
        //OrgWideTestUtil.setCampaignMemberStatus(c.Id);
        
        List<CampaignMember> cml = new List<CampaignMember> {
            OrgWideTestUtil.createCampaignMember(false, 'contact', cons[0].Id, c.Id, 'Waitlisted'),
            OrgWideTestUtil.createCampaignMember(false, 'contact', cons[1].Id, c.Id, 'Waitlisted'),
            OrgWideTestUtil.createCampaignMember(false, 'contact', cons[2].Id, c.Id, 'Waitlisted')
        };
        insert cml;
        
        Test.startTest();
            cml[0].Status = 'Registered';
            cml[1].Status = 'Registered';
            cml[2].Status = 'Registered';
            update cml;
        Test.stopTest();
    }
    
    @isTest
    public static void scenario6() {
        Lead l = OrgWideTestUtil.createLead(false);
        l.Campaign_Referred_Partner_ID__c = 'xyz';
        insert l;
        
        Campaign c = OrgWideTestUtil.createCampaign(true);
        CampaignMember cm = OrgWideTestUtil.createCampaignMember(false, 'lead', l.Id, c.Id, 'Sent');
        cm.Campaign_Referred_Partner_ID__c = 'xyz';
        cm.Campaign_Referred_Partner_Id_Update_Time__c = System.now();
        insert cm;
        
        cm.Campaign_Referred_Partner_Id_Update_Time__c = System.now();
        update cm;
    }
    
    @isTest
    public static void scenario7() {
        Account acc= new Account();
        acc.Name='testaccount';
        insert acc;
        
        Contact con = OrgWideTestUtil.createContact(false, acc.Id);
        con.Campaign_Referred_Partner_ID__c = 'xyz';
        insert con;
        
        Campaign c = OrgWideTestUtil.createCampaign(true);
        CampaignMember cm = OrgWideTestUtil.createCampaignMember(false, 'contact', con.Id, c.Id, 'Sent');
        cm.Campaign_Referred_Partner_ID__c = 'xyz';
        cm.Campaign_Referred_Partner_Id_Update_Time__c = System.now();
        insert cm;
        
        cm.Campaign_Referred_Partner_Id_Update_Time__c = System.now();
        update cm;
        
        Test.startTest();
            delete cm;
        Test.stopTest();
    }
}