@isTest
public class Test_ClearPartnerInfluencedDeal{

public static testmethod void TestClearPartnerInfluencedDeal()
    {
        Account a = new Account(name='TestA',phone='98765435201',CurrencyIsoCode='USD' );
        insert a; 
        Account b = new Account(name='TestB',phone='98765495201',CurrencyIsoCode='USD' );
        insert b;
        Opportunity rec = new Opportunity(AccountId=b.id,Name='Got',Partner_Account_Name__c=a.name, CloseDate=system.today(), StageName=System.label.StageName_B,currencyisocode='USD'  );
        insert rec;
        Partner p = new Partner(opportunityId =rec.id,accounttoid=a.id,role='Software Distributor');
        insert p;
        rec.Partner_Influenced_Deal__c = false;
        rec.Partner_Account_Name__c = NULL;
        update rec;
    }
}