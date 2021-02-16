@isTest(seeAllData=true)
public class UnitTests_CreateUpdateTasks {

static testmethod void insertTask() {

     Profile p = [Select Id from Profile where Name='System Administrator' limit 1];
     
        User u1 = new User(LastName = 'Mark O’Brien',
         Alias = 'alias', Email='test@alteryx.com',
          Username='test123@alteryx.com', CommunityNickname = 'nick1', 
          ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', 
          EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        insert u1;

    Account acc = new Account();
        acc.Name = 'Test Account';
        // add whatever other fields are required for account creation here
    insert acc;

    
    Contact con = new Contact();
        con.FirstName = 'Test'; // this assumes firstname is a required field on your contact records
        con.LastName = 'Contact'; // this assumes lastname is a required field on your contact records
        con.AccountId = acc.Id; // this assumes account is a required field on your contact records
        con.Title = 'Test Title'; // this is to validate your trigger
        //con.MobilePhone = '1111111111'; // this is to validate your trigger
        // add whatever other fields are required for contact creation here
    insert con;

    Task u = new Task();
        u.ownerId = u1.Id; // you've now successfully created your test user, time to use it on your new task
        u.whoId = con.Id; // you've now successfully created your test contact, time to use it on your new task
        u.Subject = 'Run Test Trigger';
        u.Status = 'Not Started';
        u.Priority = 'Normal';
    insert u;


    
    }

}