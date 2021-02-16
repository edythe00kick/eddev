public class Test_Data_Utility_Class{
    
    /*public static Apttus__APTS_Agreement__c CreateApttusAgreement(String RecordTypeName){
        map<String, RecordType> RecordTypeNamemap = UtilityClass.RecordTypeNamemap();
        Apttus__APTS_Agreement__c imp = new Apttus__APTS_Agreement__c();
        imp.RecordTypeId = RecordTypeNamemap.get(RecordTypeName).Id;
        return imp;
    }
     public static Apttus_Proposal__Proposal__c CreateApttusProposal(String RecordTypeName){
        map<String, RecordType> RecordTypeNamemap = UtilityClass.RecordTypeNamemap();
        Apttus_Proposal__Proposal__c  imp = new Apttus_Proposal__Proposal__c ();
        imp.RecordTypeId = RecordTypeNamemap.get(RecordTypeName).Id;
        return imp;
    }*/
    public static list<Opportunity> Opportunity_Data(){
        list<Opportunity> oppData = new list<Opportunity>();
        Opportunity opp = new Opportunity();
        opp.Name = 'Test-Opportunity';
        opp.StageName = System.label.StageName_B;
        opp.CloseDate = system.today();
        opp.Amount = 20;
        oppData.add(opp);
        return oppData;
    }
   
    
    /*public static void User(){
        Profile p = [Select Id from Profile where Name='System Administrator' limit 1];
        list<User> User_List = new list<User>();
        User u1 = new User(LastName = 'Verma', Alias = 'alias', Email='test@grazitti.com', Username='test@grazitti.com',
        CommunityNickname = 'nick1', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', 
        LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        User_List.add(u1);
        User u2 = new User(LastName = 'Jeff Kenney', Alias = 'alias', Email='test1@grazitti.com', Username='test1@grazitti.com', CommunityNickname = 'nick2', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        User_List.add(u2);
        User u3 = new User(LastName = 'Edward Addvensky', Alias = 'alias', Email='test2@grazitti.com', Username='test2@grazitti.com', CommunityNickname = 'nick3', ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        User_List.add(u3);
        insert User_List;
    }*/
   
    public static list<Account> Accounts(){
        list<Account> accList = new list<Account>();
        Account acc = new Account(Name = 'Test');
        accList.add(acc);
        return accList;
    }
   
 /*   public static list<Product2> Products(){
        list<Product2> prod = new list<Product2>();
        list < Schema.PicklistEntry > Product_Family_Values = new list < Schema.PicklistEntry >();
        Product_Family_Values = Product2.Family.getDescribe().getPicklistValues();
        for(Schema.PicklistEntry s : Product_Family_Values){
            Product2 p = new Product2(Name = String.valueOf(s.value), Family = String.valueOf(s.value));
            prod.add(p);
        }
        return prod;
    }
   
    public static list<Pricebook2> PriceBook(Integer Number_Of_Records){
        list<Pricebook2> PriceBook = new list<Pricebook2>();
        for(Integer i = 0; i < Number_Of_Records; i++){
            Pricebook2 p = new Pricebook2(Name = 'PriceBook'+i, IsActive = true);
            PriceBook.add(p);
        }
        return PriceBook;
    }
    
    public static list<PricebookEntry> Price_Book_Entry(list<Product2> prod, list<Pricebook2> PriceBook){
        list<PricebookEntry> Price_Book_Entry = new list<PricebookEntry>();
        Integer Number_Of_Records;
        if(prod.size() > PriceBook.size())
            Number_Of_Records = PriceBook.size();
        else
            Number_Of_Records = prod.size();
        for(Integer i = 0; i < Number_Of_Records; i++){
            PricebookEntry p = new PricebookEntry(Pricebook2Id = PriceBook[0].Id, Product2Id = prod[0].Id, UnitPrice = 20, UseStandardPrice = false, IsActive = true);
            Price_Book_Entry.add(p);
        }
        return Price_Book_Entry;
    }
    
    public static list<OpportunityLineItem> Opportunity_Line_Item(list<Opportunity> oppList, list<PricebookEntry> Price_Book_Entry, list<Product2> prod){
        list<OpportunityLineItem> OLI = new list<OpportunityLineItem>();
        for(Integer i = 0; i<oppList.size(); i++){
            if(Price_Book_Entry.size() > i && prod.size() > i){
                OpportunityLineItem o = new OpportunityLineItem(OpportunityId = oppList[i].Id, PricebookEntryId = Price_Book_Entry[i].Id, UnitPrice = 20, Quantity = 10);
                OLI.add(o);
            }
        }
        return OLI;
    }*/
    
}