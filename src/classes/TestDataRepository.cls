@isTest
public class TestDataRepository {
    
    public static List<Account> createAccountList(){
        List<Account> accList = new List<Account>();
        for(integer i=0; i<=5;i++){
            //Added by sharma || 31st July 2019
            Account acc = new Account(Name = 'TestAccount'+i,BillingState='AK', Managed_Partner__c = true);
            accList.add(acc);
        }
        insert accList;
        return accList;
    }
    public static List<Contact> createContactList(List<Account> accList){
        List<Contact> conList = new List<Contact>();
        for(integer i=0; i<=5;i++){
            Contact con = new Contact(
                FirstName = 'Test'+i,
                Lastname = 'McTesty'+i,
                AccountId = accList[0].Id
            );
            conList.add(con); 
        }
        insert conList;
        return conList;
    }
    public static List<Opportunity> createOpportunityList(List<Account> accList){
        List<Opportunity> oppoList = new List<Opportunity>();
        for(integer i=0; i<=5;i++){
            Opportunity oppo = new Opportunity(
                Name='test oppo'+i,
                AccountId=accList[0].Id,
                StageName='1 - Identification',
                CloseDate=system.today()
            );
            oppoList.add(oppo); 
        }
        insert oppoList;
        return oppoList;
    }
    public static User createPortalUser(List<Contact> conList){
        Profile portalProfile = [SELECT Id FROM Profile where Name='Partner Community User custom'];
        User user = new User(
            Username = System.now().millisecond() + 'test12345@test.com',
            ContactId = conList[0].Id,
            ProfileId = portalProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user);
        return user;
    }
    public static List<Custom_Partner__c> createCustomPartner(List<Account> accList, List<Opportunity> oppoList){
        List<Custom_Partner__c> cusPartnerList = new List<Custom_Partner__c>();
         for(integer i=0; i<=5; i++){
            Custom_Partner__c cusPart = new Custom_Partner__c();
            cusPart.AccountToId__c=accList[i].Id;
            cusPart.OpportunityId__c=oppoList[i].Id;
            cusPart.IsPrimary__c=true;
            cusPart.Role__c='Referrer';
            cusPartnerList.add(cusPart);
        }
        
        insert cusPartnerList;
        return cusPartnerList;
    }
    public static List<Lead> createLeadList(List<Contact> conList){
        List<Lead> leadList = new List<Lead>();
        for(integer i=0 ; i<=5; i++){
            Lead ld = new Lead();
            ld.LastName='test Lead'+i;
            ld.Company='test company'+i;
            ld.Partner_Representative__c=conList[0].id;
            leadList.add(ld);
        }
        insert leadList;
        return leadList;
    }
}