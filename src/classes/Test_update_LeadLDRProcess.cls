@isTest
public class Test_update_LeadLDRProcess{

    static testmethod void Testtrig(){
        Profile p = [Select Id from Profile where Name='Standard User' limit 1];
     
        User u1 = new User(LastName = 'Marrk O’Brien',
        Alias = 'alias', Email='testt@alteryx.com',
        Username='test123@alteryx.com', CommunityNickname = 'nickk1', 
        ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        insert u1;
       Lead newLead1 = new Lead(
                        Company = 'Tessst Accounts', LastName= 'Test Leads',RLM_Status_Field__c='Responder',
                        LeadSource = 'Web',  
                        Status = '4 - Converted',CurrencyIsoCode = 'USD', recordTypeId = '012E0000000VRBaIAO',Pain_Point_Values__c='Data Blending');
        
        Insert newLead1;
        Task u = new Task();
        u.ownerId = u1.Id; // you've now successfully created your test user, time to use it on your new task
        u.whoId = newLead1.Id; // you've now successfully created your test contact, time to use it on your new task
        u.Subject = 'Run Test Trigger';
        u.Status = 'Not Started';
        u.Priority = 'Normal';
        insert u;
    }
    static testmethod void Testtrigg(){
        Profile p = [Select Id from Profile where Name='Standard User' limit 1];
     
        User u2 = new User(LastName = 'Marrk O’Brien',
        Alias = 'alias', Email='testt@alteryx.com',
        Username='test123@alteryx.com', CommunityNickname = 'nickk1', 
        ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', 
        EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        insert u2;
       Lead newLead2 = new Lead(
                        Company = 'Tessst Accounnts', LastName= 'Test Leadds',RLM_Status_Field__c='Responder',
                        LeadSource = 'Web',  
                        Status = '4 - Converted',CurrencyIsoCode = 'USD', recordTypeId = '012E0000000VRBaIAO',X1st_SAO_Submitted_Date__c = Date.today(),Pain_Point_Values__c='Data Blending');
        
        Insert newLead2;
        Task u1 = new Task();
        u1.ownerId = u2.Id; // you've now successfully created your test user, time to use it on your new task
        u1.whoId = newLead2.Id; // you've now successfully created your test contact, time to use it on your new task
        u1.Subject = 'Run Test Trigger';
        u1.Status = 'Not Started';
        u1.Priority = 'Normal';
        insert u1;
    }    
    
    @isTest
    private static void testScenario1() {
        Account acc = createAccount(true);
        Contact con = createContact(false, acc.Id);
        con.Pain_Point_Values__c = 'Data Blending';
        insert con;
        
        Task u1 = new Task();
        u1.whoId = con.Id;
        u1.whatid = acc.Id;
        u1.Subject = 'Run Test Trigger';
        u1.Status = 'Not Started';
        u1.Priority = 'Normal';
        insert u1;
    }
    
    @isTest
    private static void testScenario2() {
        Account acc = createAccount(true);
        Contact con = createContact(false, acc.Id);
        con.Pain_Point_Values__c = 'Data Blending';
        con.X1st_SAO_Submitted_Date__c = Date.today();
        insert con;
        
        Task u1 = new Task();
        u1.whoId = con.Id;
        u1.whatid = acc.Id;
        u1.Subject = 'Run Test Trigger';
        u1.Status = 'Not Started';
        u1.Priority = 'Normal';
        insert u1;
    }
    
    // Create Account
    public static Account createAccount(boolean do_insert) {
        Account acc = new Account();
        acc.Name = 'LLDRP Account';
        if(do_insert) {
            insert acc;
        }
        return acc;
    }
    
    // Create Contact
    public static Contact createContact(boolean do_insert, id account_id) {
        Contact con = new Contact();
        con.FirstName = 'LLDRP';
        con.LastName = 'Contact';
        con.Email = 'contact@lldrp.com';
        con.AccountId = account_id;
        if(do_insert) {
            insert con;
        }
        return con;
    }
}