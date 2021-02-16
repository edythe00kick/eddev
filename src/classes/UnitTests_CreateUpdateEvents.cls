@isTest(seeAllData=true)
public class UnitTests_CreateUpdateEvents {

static testmethod void insertTask() {

     Profile p = [Select Id from Profile where Name='System Administrator' limit 1];
     
        User u1 = new User(LastName = 'Mark O’Brien',
         Alias = 'alias', Email='test@alteryx.com',
          Username='test90@alteryx.com', CommunityNickname = 'nick1', 
          ProfileId = p.Id, TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', 
          EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
        insert u1;
        
        Contact con=[SELECT ID FROM CONTACT LIMIT 1];


    

    Event e = new Event ();
        e.ownerId = u1.Id; // you've now successfully created your test user, time to use it on your new task
        e.whoId = con.Id; // you've now successfully created your test contact, time to use it on your new task
        e.Subject = 'Run Test Trigger';
       e.DurationInMinutes= 60;
      e.ActivityDateTime=datetime.now();
        //e.Priority = 'Normal';
    insert e;


    
    }

}