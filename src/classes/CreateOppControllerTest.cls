@isTest
public class CreateOppControllerTest {
	@isTest
    public static void testScenario1() {
        Account acc = OrgWideTestUtil.createAccount(true);
        
        Contact cont = OrgWideTestUtil.createContact(true, acc.Id);
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp.Primary_Contact__c = cont.Id;
        insert opp;
        
        PageReference pg = Page.CreateOpportunity;
        Test.setCurrentPage(pg);
        pg.getParameters().put('accId', acc.Id);
        pg.getParameters().put('conId', cont.Id);
        CreateOppController ob = new CreateOppController(null);
        ob.getretURL();
    }
    
    @isTest
    public static void testScenario2() {
        Account acc = OrgWideTestUtil.createAccount(true);
        
        PageReference pg = Page.CreateOpportunity;
        Test.setCurrentPage(pg);
        pg.getParameters().put('accId', acc.Id);
        CreateOppController ob = new CreateOppController(null);
        ob.getretURL();
    }
    
    @isTest
    public static void testScenario3() {
        Account acc = OrgWideTestUtil.createAccount(true);
        
        Contact cont = OrgWideTestUtil.createContact(true, acc.Id);
        
        PageReference pg = Page.CreateOpportunity;
        Test.setCurrentPage(pg);
        pg.getParameters().put('conId', cont.Id);
        CreateOppController ob = new CreateOppController(null);
        ob.getretURL();
    }
    
    @isTest
    public static void testScenario4() {
        
        PageReference pg = Page.CreateOpportunity;
        Test.setCurrentPage(pg);
        CreateOppController ob = new CreateOppController(null);
        ob.getretURL();
    }
}