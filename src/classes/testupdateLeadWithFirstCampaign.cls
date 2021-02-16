@isTest
 private class testupdateLeadWithFirstCampaign {

     static testMethod void testOppWith1strespondedCampaign() {
        Profile p = [Select Id from Profile where Name='System Administrator' limit 1];

         User u1 = new User(LastName = 'Mark O’Brien', Alias = 'alias', Email = 'test122@alteryx.com',
             Username = 'test122@alteryx.com', CommunityNickname = 'nick1', ProfileId = p.Id,
             TimeZoneSidKey = 'America/Los_Angeles', LocaleSidKey = 'en_US', EmailEncodingKey = 'ISO-8859-1', LanguageLocaleKey = 'en_US');
         insert u1;
         Lead l1= new Lead(LastName='Williams',LeadSource='Manual',Company='Alteryx');
         insert l1;
        
         Account a = Test_Data_Utility_Class.Accounts()[0];
         a.ownerID=u1.ID;
         insert a;
         Contact cnt= new contact(LastName='Raj Sharma',email='rajs@alteryx.com');
         cnt.accountid=a.id;
         insert cnt;
         system.debug('Inserted Account'+a.ID);
         Opportunity o = Test_Data_Utility_Class.Opportunity_Data()[0];
         o.AccountId = a.Id;
         o.ownerID = u1.ID;
         insert o;
         o.Type='NB';
         o.StageName=System.label.StageName_F;
         update o;
         system.debug('Inserted oppotunity'+o.ID);
         OpportunityContactRole ocr= new OpportunityContactRole();
         
         ocr.OpportunityID = o.ID;
         ocr.contactID=cnt.id;
         insert ocr;
         system.debug('Inserted oppotunityContactRole'+ocr.ID);
         campaign cpg= new campaign(Name='Test My Campaign');
         insert cpg;
         
         system.debug('Inserted campaign'+cpg.ID);
          campaignMember cm1= new campaignMember();
         cm1.CampaignID=cpg.ID;
         cm1.LeadID=l1.ID;
         cm1.status='Responded';
        insert cm1;
        UtilityClass.updateLeadWithFirstCampaignIsFirstRun=true;
        update cm1;
         system.debug('Inserted Campaign for lead'+cm1.ID);
        
         
        // insert cm; 
         campaignMember cm= new campaignMember();
         cm.CampaignID=cpg.ID;
         cm.ContactID=cnt.ID;
        
        
         cm.status='Responded';
         insert cm;        
         system.debug('Inserted campaignMember'+cm.ID);
         utilityClass.updateOppWith1strespondedCampaignIsFirstRun=true;
        update o;


     }


 }