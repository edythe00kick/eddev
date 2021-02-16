@isTest
public Class TestCampaignTrigger{

    @isTest(seeAllData=true)
    public static void scenario1() {
       
       Lead led = OrgWideTestUtil.createLead(true);
       Account acc = OrgWideTestUtil.createAccount(true);
       Contact con = OrgWideTestUtil.createContact(true, acc.Id);
       
       Campaign c = OrgWideTestUtil.createCampaign(false);
       c.Total_number_of_Seats__c = 2;
       c.Event_Cap_Qualified__c = true;
       insert c;
       
       List<CampaignMember> cml = new List<CampaignMember> {
           OrgWideTestUtil.createCampaignMember(false, 'lead', led.Id, c.Id,'Workshop Queue'),
           OrgWideTestUtil.createCampaignMember(false, 'contact', con.Id, c.Id, 'Workshop Queue')
       };
       insert cml;
       
   } 
   
   @isTest
    public static void scenario2() {
       
       Test.startTest();
       Campaign c = OrgWideTestUtil.createCampaign(false);
       c.Event_Cap_Qualified__c = true;
       insert c;
       
       c.Total_number_of_Seats__c = 2;
       update c;
       
       c.Total_number_of_Seats__c = 3;
       update c;
       
       c.Total_number_of_Seats__c = 1;
       update c;
       Test.stopTest();
        
    }
}