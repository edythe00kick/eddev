@isTest
public class Test_reassignContact{

public static testmethod void TestreassignContact()
    {
        Account b = new Account(name='TesstB',phone='98765495201',CurrencyIsoCode='USD' );
        insert b;
        Contact c = new Contact(AccountId=b.id,lastname='testc',currencyisocode='USD',email='p@x.com');
        insert c;
        c.lastname='testcc';
        update c;
        
    }
}