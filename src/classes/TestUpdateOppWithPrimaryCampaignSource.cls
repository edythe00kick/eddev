@isTest
public class TestUpdateOppWithPrimaryCampaignSource{
    static testmethod void AddCampaignMembers(){
        Account acct = new Account(name='accc',phone='98765495201',CurrencyIsoCode='USD' );
        insert acct;
        Opportunity recc = new Opportunity(AccountId=acct.id,type='NB',Name='Gopcp', CloseDate=system.today(), StageName=System.label.StageName_B,currencyisocode='USD'  );
        insert recc;
        recc.stagename=System.label.StageName_F;
        update recc;
        Contact c = new Contact(lastname='newcon',currencyisocode='USD',phone='9876543215',email='p@x.com');
        insert c;
        Campaign cc = new Campaign(name='test',IsActive=true,type='Partner Demand Generation',status='In Progress');
        insert cc;
        CampaignMember camp = new CampaignMember(contactid=c.id,CampaignId=cc.id,CurrencyIsoCode='USD',Status='Responded');
        insert camp;
        OpportunityContactRole ocr = new OpportunityContactRole(opportunityid = recc.id,contactid=c.id,isprimary=true);
        insert ocr;

        UpdateOppWithPrimaryCampaignSource  a = new UpdateOppWithPrimaryCampaignSource();
        Date dt = system.today();
        Date datetm = system.today();
        a.callexec(dt,datetm);
        ID batchprocessid = Database.executeBatch(a,200); 
    }
}