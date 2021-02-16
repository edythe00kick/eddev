@isTest
 private class testOpportunityTeamMember {

     static testMethod void testOpportunityTeamMember_Insert() {
        Profile p = [Select Id from Profile where Name='System Administrator' limit 1];
        List<UserRole> roles = [Select Id FROM USERROLE WHERE Name='Manager Sales Engineer NA Enterprise Inside'];

         User u1 = new User(FirstName='Richard',LastName ='Snow', Alias = 'alias', Email = 'test121yy@alteryx.com',
             Username = 'test121yy@alteryx.com', CommunityNickname = 'nick1yy', ProfileId = p.Id,UserRoleId = roles[0].Id,
             TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
         insert u1;
         
         User u2 = new User(FirstName='Richard',LastName ='Snow', Alias = 'alias', Email = 'test121xx@alteryx.com',
             Username = 'test121xx@alteryx.com', CommunityNickname = 'nick1xx', ProfileId = p.Id,
             TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
         insert u2;
         
         Account a = Test_Data_Utility_Class.Accounts()[0];
         Opportunity o = Test_Data_Utility_Class.Opportunity_Data()[0];
         System.runAs(u2){
             
             a.ownerID=u1.ID;
             insert a;
             system.debug('Inserted Account'+a.ID);
             
             o.AccountId = a.Id;
             o.ownerID = u1.ID;
             insert o;
             system.debug('Inserted Account'+o.ID);
         }
         System.runAs(u1){
             OpportunityTeamMember otm = new OpportunityTeamMember();
             otm.TeamMemberRole = 'Sales Engineer';
             otm.UserID = u1.ID;
             otm.OpportunityID = o.ID;
             insert otm;
             
             system.debug('Inserted opportunityteamMember'+otm.ID);
             update otm;
        }

     }


 }