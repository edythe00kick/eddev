@isTest
public class populateAttendeeTest {
    /** Test to check that if '2016 Referrer ID' field is filled,
      * 'Owner' field should be filled with id stored in 
      * '2016 Referrer ID' field
      */
  /* Commented out due to deprication of the Event__c field on the Event_Registration__c custom object - JPH - Cs 00175555 - 20171130

    @isTest
    private static void testScenari1() {
        Event__c evnt = new Event__c();
        evnt.Name = 'PAT_Event';
        insert evnt;
        
        // This code runs as the system user
        User usr;
        
        try {
            usr = [SELECT Id FROM User WHERE isActive = true 
                AND Profile.Name = 'System Administrator' LIMIT 1];
        } catch(QueryException qe) {
            List<User> users;
            users = [SELECT Id, Profile.PermissionsModifyAllData 
                FROM User WHERE IsActive = true LIMIT 1000];
            for(User u : users) {
                if(u.Profile.PermissionsModifyAllData = true){
                    usr = u;
                    break;
                }
            }
        }
        
        Event_Registration__c registration = new Event_Registration__c();
        registration.Event__c = evnt.Id;
        registration.X2016_Referrer_ID__c = usr.Id;
        insert registration;
    }
    
    @isTest
    private static void testScenari2() {
        Event__c evnt = new Event__c();
        evnt.Name = 'PAT_Event';
        insert evnt;
        
        Event_Registration__c registration = new Event_Registration__c();
        registration.Event__c = evnt.Id;
        insert registration;
    }
    
    @isTest
    private static void testScenari3() {
        Event__c evnt = new Event__c();
        evnt.Name = 'PAT_Event';
        insert evnt;
        
        // This code runs as the system user
        User usr;
        
        try {
            usr = [SELECT Id FROM User WHERE isActive = true 
                AND Profile.Name = 'System Administrator' LIMIT 1];
        } catch(QueryException qe) {
            List<User> users;
            users = [SELECT Id, Profile.PermissionsModifyAllData 
                FROM User WHERE IsActive = true LIMIT 1000];
            for(User u : users) {
                if(u.Profile.PermissionsModifyAllData = true){
                    usr = u;
                    break;
                }
            }
        }
        
        Event_Registration__c registration = new Event_Registration__c();
        registration.Event__c = evnt.Id;
        insert registration;
        
        registration.X2016_Referrer_ID__c = usr.Id;
        update registration;
    }
    
    // Test to fill fields named Name on Badge and Title on Badge
    @isTest
    private static void testScenari4() {
        Event__c evnt = new Event__c();
        evnt.Name = 'PAT_Event';
        insert evnt;
        
        Account acc = createAccount(true);
        Contact con = createContact(true, acc.Id);
        
        Event_Registration__c registration = new Event_Registration__c();
        registration.Event__c = evnt.Id;
        registration.Contact__c = con.Id;
        insert registration;
    }
    
    // Create Account
    public static Account createAccount(boolean do_insert) {
        Account acc = new Account();
        acc.Name = 'PAT_Account';
        if(do_insert) {
            insert acc;
        }
        return acc;
    }
    
    // Create Contact
    public static Contact createContact(boolean do_insert, id account_id) {
        Contact con = new Contact();
        con.FirstName = 'PAT';
        con.LastName = 'Contact';
        con.Email = 'contact@owtu.com';
        con.AccountId = account_id;
        if(do_insert) {
            insert con;
        }
        return con;
    }*/
}