@isTest
public class MilestoneUtilsTest {

    @isTest(seeAllData=true)
    public static void scenario1() {

        Account acc = OrgWideTestUtil.createAccount(true);

        SlaProcess sp = [SELECT Id FROM SlaProcess WHERE isActive = true
                         AND Name = 'Support Levels'];
        if(sp == null)
            return;

        Entitlement ent = new Entitlement(Name = 'Test Entitlement',
                                          AccountId = acc.Id,
                                          StartDate = Date.today(),
                                          EndDate = Date.today() + 1,
                                          SlaProcessId = sp.Id);
        insert ent;

        Case cas = OrgWideTestUtil.createCase(true, ent.Id);

        List<Id> ids = new List<Id> { cas.Id };

        MilestoneUtils.completeMilestone(ids, 'Response Time', System.now());
        
    }
    
}