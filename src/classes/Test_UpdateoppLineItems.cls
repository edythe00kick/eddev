@isTest(SeeAllData=true)
public class Test_UpdateoppLineItems{

public static testmethod void TestOpportunityline()
    {
        Account act = new Account(name='Testac',phone='98765495201',CurrencyIsoCode='USD' );
        insert act;
        Opportunity rec = new Opportunity(AccountId=act.id,Name='Goppp', CloseDate=system.today(), StageName= System.label.StageName_B,currencyisocode='USD'  );
        insert rec;
        
        // Create a new product
        Product2 product = new Product2();
        product.Name='Alteryx Designer';
        product.IsActive=true;
        product.Family='Alteryx Software';
        insert product ;   

        Pricebook2 pb= [select Id,IsActive,Name from PriceBook2 where name = 'Standard Price Book' AND IsActive = true limit 1];        
        
        // Create a pricebook entry for custom pricebook
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.UseStandardPrice = false;
        pbe.Pricebook2Id=pb.id;
        pbe.Product2Id=product.id;
        pbe.IsActive=true;
        pbe.UnitPrice=100.0;        
        //pbe.UseStandardPrice =true;
        insert pbe;
        OpportunityLineItem rec1=new OpportunityLineItem(OpportunityId=rec.id,PricebookEntryId=pbe.id, Quantity=1,  TotalPrice=100.0, Product_Type__c='New' );
        insert rec1;
        
        UpdateoppLineItems obj = new UpdateoppLineItems();
        Database.executeBatch(obj,1);
    }
}