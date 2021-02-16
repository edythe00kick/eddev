@isTest
public class CompleteFirstResponseEmailTest {

    @isTest(seeAllData=true)
    public static void scenario1() {

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact con = OrgWideTestUtil.createContact(false, acc.Id);
        con.firstname='testxyz@textabc.com';
        insert con;

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

        Case cas = OrgWideTestUtil.createCase(false, ent.Id);
        cas.ContactId = con.Id;
        cas.status = 'Submitted';
        insert cas;

        insert new EmailMessage(FromAddress = 'testmail@example.com',
                                Incoming = false,
                                ToAddress = con.Email,
                                Subject = 'Test Email',
                                TextBody = 'Test Email',
                                ParentId = cas.Id);
        
    }
    
}