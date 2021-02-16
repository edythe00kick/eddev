@isTest
public class Test_LeadOperationsTrigger {

//Test Methods for Covering Insert Opeartions of LeadOperationsTrigger Start Here
   //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS True
    */

    /**
     * Test when a new lead record is created.
     */
    @isTest
    public static void testScenario1() {
        Lead ld = OrgWideTestUtil.createLead(false);
        
        //Date 9-10 Sergio Flores
        //Updating code coverage by making territory metadata fields dynamic to User object
        //Grab the metadata fields here
        Territory_Mapping__mdt[] territoryMappingMetaData = [SELECT DeveloperName, MasterLabel, NamespacePrefix, Account_Field__c, Lead_Field__c, User_Field__c 
                                                             From Territory_Mapping__mdt];

        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User u = new User(Alias = 'test123', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test123test@grazitti.com');
        
        //Check to see the developername and assign the field to correct variable
        for(Territory_Mapping__mdt territoryMapping : territoryMappingMetaData)
        {
            /*if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'ANZ');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u.put(territoryMapping.User_Field__c, 'APAC');
            if(territoryMapping.DeveloperName == 'Sales_Territory')
                u.put(territoryMapping.User_Field__c, 'Strategic 1 01');
            if(territoryMapping.DeveloperName == 'Sales_Group')
                u.put(territoryMapping.User_Field__c, 'NA Enterprise Select');*/
            if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'ANZ');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u.put(territoryMapping.User_Field__c, 'APAC');
            if(territoryMapping.DeveloperName == 'Sales_Territory')
                u.put(territoryMapping.User_Field__c, '00');
            if(territoryMapping.DeveloperName == 'Sales_Group')
                u.put(territoryMapping.User_Field__c, 'ANZ');
        }
        

        insert u;

        System.runAs(u) {
            insert ld;
        }
    }

     /**
     * Test when an existing lead record is updated.
     */
    @isTest
    public static void testScenario2() {
        Lead ld = OrgWideTestUtil.createLead(false);
        
        //Date 9-10 Sergio Flores
        //Updating code coverage by making territory metadata fields dynamic to User object
        //Grab the metadata fields here
        Territory_Mapping__mdt[] territoryMappingMetaData = [SELECT DeveloperName, MasterLabel, NamespacePrefix, Account_Field__c, Lead_Field__c, User_Field__c 
                                                             From Territory_Mapping__mdt];

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User u = new User(Alias = 'test123', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test123test@grazitti.com');
        
        //Check to see the developername and assign the field to correct variable
        for(Territory_Mapping__mdt territoryMapping : territoryMappingMetaData)
        {
           /* if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'ANZ');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u.put(territoryMapping.User_Field__c, 'APAC');
            if(territoryMapping.DeveloperName == 'Sales_Territory')
                u.put(territoryMapping.User_Field__c, 'Strategic 1 01');
            if(territoryMapping.DeveloperName == 'Sales_Group')
                u.put(territoryMapping.User_Field__c, 'NA Enterprise Select');*/
            if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'ANZ');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u.put(territoryMapping.User_Field__c, 'APAC');
            if(territoryMapping.DeveloperName == 'Sales_Territory')
                u.put(territoryMapping.User_Field__c, '00');
            if(territoryMapping.DeveloperName == 'Sales_Group')
                u.put(territoryMapping.User_Field__c, 'ANZ');
        }

        insert u;

         User u1 = new User(Alias = 'test124', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test124test@grazitti.com');
        
        for(Territory_Mapping__mdt territoryMapping : territoryMappingMetaData)
        {
             /*if(territoryMapping.DeveloperName == 'Sales_Team')
                u1.put(territoryMapping.User_Field__c, 'Public Sector');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u1.put(territoryMapping.User_Field__c, 'APAC');
            if(territoryMapping.DeveloperName == 'Sales_Territory')
                u1.put(territoryMapping.User_Field__c, 'Strategic 1 02');
            if(territoryMapping.DeveloperName == 'Sales_Group')
                u1.put(territoryMapping.User_Field__c, 'NA Enterprise Select');*/
            if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'ANZ');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u.put(territoryMapping.User_Field__c, 'APAC');
            if(territoryMapping.DeveloperName == 'Sales_Territory')
                u.put(territoryMapping.User_Field__c, '00');
            if(territoryMapping.DeveloperName == 'Sales_Group')
                u.put(territoryMapping.User_Field__c, 'ANZ');
        }

        insert u1;

        System.runAs(u) {
            insert ld;
            ld.OwnerId = u1.Id;
            update ld;
        }
    }

    public static testMethod void myUnitTest() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true,LD_Matched_Strategic_Named_Account__c =true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS True
    */  
     public static testMethod void myUnitTest1() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true,LD_Matched_Strategic_Named_Account__c =true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS False
    */
     public static testMethod void myUnitTest2() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS False
    */
     public static testMethod void myUnitTest3() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Enterprise Exp Named Account EQUALS True
    */     
     public static testMethod void myUnitTest4() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Exp_Named_Account__c =true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Enterprise Exp Named Account EQUALS True
    */  
     public static testMethod void myUnitTest5() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Exp_Named_Account__c =true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Entreprise Umbrella EQUALS True
        LD Matched Enterprise Exp Named Account EQUALS False
    */  
     public static testMethod void myUnitTest6() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid(),
                                        Enterprise_Expand_Geo_Owner__c = userinfo.getuserid() );
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Exp_Named_Account__c =false,LD_Matched_Enterprise_Umbrella__c = true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Entreprise Umbrella EQUALS True
        LD Matched Enterprise Exp Named Account EQUALS False
    */  
     public static testMethod void myUnitTest7() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid(),
                                         Enterprise_Expand_Geo_Owner__c = userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Exp_Named_Account__c =false,LD_Matched_Enterprise_Umbrella__c = true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Enterprise Land Named Account EQUALS True
    */  
     public static testMethod void myUnitTest8() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                       LD_Matched_Enterprise_Land_Named_Account__c  = true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Enterprise Land Named Account EQUALS False
    */  
     public static testMethod void myUnitTest9() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Land_Named_Account__c  = true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Account Owner is NOT SMB Accounts
        LD Matched Strategic Umbrella EQUALS False
        LD Matched Enterprise Umbrella EQUALS False
        LD Matched Enterprise Land Named Account EQUALS False
    */  
     public static testMethod void myUnitTest10() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Account_Owner__c ='test');
        Insert newLead;
        Test.stopTest();
     }
     
      //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Account Owner is NOT SMB Accounts
        LD Matched Strategic Umbrella EQUALS False
        LD Matched Enterprise Umbrella EQUALS False
        LD Matched Enterprise Land Named Account EQUALS False
    */ 
     public static testMethod void myUnitTest11() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Account_Owner__c ='test');
        Insert newLead;
        Test.stopTest();
     }
     
      //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Account Owner is NOT SMB Accounts
        LD Matched Strategic Umbrella EQUALS False
        LD Matched Enterprise Umbrella EQUALS False
        LD Matched Enterprise Land Named Account EQUALS False + No Lead Deveelopment Rep is Assigned on the Account
    */     
     public static testMethod void myUnitTest12() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account');
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Account_Owner__c ='test');
        Insert newLead;
        Test.stopTest();
     }
    /*public static testMethod void myUnitTest13() {
        LeadHandler lh = new LeadHandler();
        Test.startTest();
        List<Account> accList = new List<Account>();
        List<Contact> conList = new List<Contact>();
        Account acc = new Account(Name = 'TestAccount');
        Account acc1 = new Account(Name = 'TestAccount');
        accList.add(acc);
        accList.add(acc1);
        insert accList;
         Contact con = new Contact(
             FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = acc.Id
            );
         Contact con1 = new Contact(
                FirstName = 'Test',
                Lastname = 'McTesty',
                AccountId = acc1.Id
            );
        conList.add(con);
        conList.add(con1);
        insert conList;
        //List<Account> accList = TestDataRepository.createAccountList();       
        //List<Contact> conList = TestDataRepository.createContactList(accList);
        //User user = TestDataRepository.createPortalUser(conList,'TLOPT');
        User user = OrgWideTestUtil.createPortalUser(true, conList[0].Id);
        
        List<Lead> leadList = new List<Lead>();
        List<Lead> updatedLeadList = new List<Lead>();
        //for(integer i=0 ; i<=5; i++){
            Lead ld = new Lead(Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
            Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
            Reporting_Matched_Account__c =accList[0].id, LD_Matched_Account_Owner__c ='test',
            OwnerId=System.Label.MQLStagingQueueId_Original,RecordTypeId=System.Label.Altx_Partner_Lead_Record_Type_Id,
            Partner_Representative__c=con.Id);
            leadList.add(ld);
        //}
        insert leadList;
        for(Lead lead : leadList){
            system.debug('abc');
            lead.Partner_Representative__c=con1.Id;
            updatedLeadList.add(lead);
        }
        Recursionhandler.IsleadTriggerExecuted=false;
        update updatedLeadList;
        //delete leadList;
        Test.stopTest();
        
        
    }*/
//Test Methods for Covering Insert Opeartions of LeadOperationsTrigger End Here     

//Test Methods for Covering Update Opeartions of LeadOperationsTrigger Start Here 

    //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS True
    */
    public static testMethod void myUnitTestforUpdate() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true,LD_Matched_Strategic_Named_Account__c =true);
        Insert newLead;
        
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }


    //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendde
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS True
    */
    public static testMethod void myUnitTestforUpdate1() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true,LD_Matched_Strategic_Named_Account__c =true);
        Insert newLead;
        
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS False
    */
     public static testMethod void myUnitTestforUpdate2() {
       Test.startTest();
        
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
        
        
        Account newAccount = new Account(name = 'Test Account');
        newAccount.Lead_Development_Rep__c = usr.Id;
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=false,Account_Lead_Development_Rep__c=userinfo.getuserid());
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        newLead.LD_Matched_Strategic_Umbrella__c= True;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS False
    */
     public static testMethod void myUnitTestforUpdate3() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true);
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Enterprise Exp Named Account EQUALS True
    */     
     public static testMethod void myUnitTestforupdate4() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Exp_Named_Account__c =false);
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        newLead.LD_Matched_Enterprise_Exp_Named_Account__c = True;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Enterprise Exp Named Account EQUALS True
    */  
     public static testMethod void myUnitTestforupdate5() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Exp_Named_Account__c =true);
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Entreprise Umbrella EQUALS True
        LD Matched Enterprise Exp Named Account EQUALS False
    */  
     public static testMethod void myUnitTestforupdate6() {
       Test.startTest();
       
       
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
       
        Account newAccount = new Account(name = 'Test Account' );
        newAccount.Lead_Development_Rep__c = usr.Id;
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Exp_Named_Account__c =false,LD_Matched_Enterprise_Umbrella__c = true,Account_Enterprise_Umbrella_Owner__c=userinfo.getuserid());
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Entreprise Umbrella EQUALS True
        LD Matched Enterprise Exp Named Account EQUALS False
    */  
     public static testMethod void myUnitTestforupdate7() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid(),
                                         Enterprise_Expand_Geo_Owner__c = userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Exp_Named_Account__c =false,LD_Matched_Enterprise_Umbrella__c = true);
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Enterprise Land Named Account EQUALS False
    */  
     public static testMethod void myUnitTestforupdate8() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                       LD_Matched_Enterprise_Land_Named_Account__c  = true);
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Enterprise Land Named Account EQUALS False
    */  
     public static testMethod void myUnitTestforupdate9() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account');
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Land_Named_Account__c  = true,Account_Lead_Development_Rep__c=userinfo.getuserid());
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Trial / Contact Us
        LD Matched Account Owner is NOT SMB Accounts
        LD Matched Strategic Umbrella EQUALS False
        LD Matched Enterprise Umbrella EQUALS False
        LD Matched Enterprise Land Named Account EQUALS False
    */  
     public static testMethod void myUnitTestforupdate10() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Account_Owner__c ='test');
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
      //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Event Attendee
        LD Matched Account Owner is NOT SMB Accounts
        LD Matched Strategic Umbrella EQUALS False
        LD Matched Enterprise Umbrella EQUALS False
        LD Matched Enterprise Land Named Account EQUALS False
    */ 
     public static testMethod void myUnitTestforupdate11() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account');
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Account_Owner__c ='test',Account_Lead_Development_Rep__c =userinfo.getuserid());
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
     
//Test Methods for Covering Update Opeartions of LeadOperationsTrigger End Here 
     
     //Test method for Covering Lead Handler Class
     /*Sergio Flores 
     Date: 09/05/2019
     Commenting out since we are no longer using trigger factory methods
     public static testMethod void myUnitTestforupdate12() {
       LeadHandler lh = new LeadHandler();
       //lh.bulkAfter();
       Lead newLead = new Lead(Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD');                         
       Insert newLead;
       lh.beforeInsert(newLead);
       lh.beforeUpdate(newLead,newLead);
       lh.beforeDelete(newLead);
       lh.afterInsert(newLead);
       lh.afterUpdate(newLead,newLead);
       lh.afterDelete(newLead);

     }*/
     
/*Code Coverage for New requirements (Assign Lead to JJ Phillips if Reporting Matched Acount is not NULL AND Owner is 
    MQL Staging Queue AND Country Equals Australia or New Zealand) Feb 17,2016   */
    
    
     public static testMethod void myUnitTestforInsert13() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,Country = 'Australia',
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true,LD_Matched_Strategic_Named_Account__c =true);
        Insert newLead;
        Test.stopTest();

     }
     
     public static testMethod void myUnitTestforInsert14() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,Country = 'Australia',
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true,LD_Matched_Strategic_Named_Account__c =false);
        Insert newLead;
        Test.stopTest();

     } 
     
     public static testMethod void myUnitTestforInsert15() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,Country = 'Australia',
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Umbrella__c = true,LD_Matched_Enterprise_Exp_Named_Account__c=false);
        Insert newLead;
        Test.stopTest();

     }
     
     public static testMethod void myUnitTestforupdate13() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,Country = 'Australia',
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true,LD_Matched_Strategic_Named_Account__c =true);
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();

     }
     
     public static testMethod void myUnitTestforupdate14() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,Country = 'Australia',
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true,LD_Matched_Strategic_Named_Account__c =false);
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();

     } 
     
     public static testMethod void myUnitTestforupdate15() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,Country = 'Australia',
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Umbrella__c = true,LD_Matched_Enterprise_Exp_Named_Account__c=false);
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();

     }
     
     public static testMethod void myUnitTestforupdate16() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account');
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,Country = 'Australia',
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Umbrella__c = true,LD_Matched_Enterprise_Exp_Named_Account__c=false,Account_Lead_Development_Rep__c=userinfo.getuserid());
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();

     }
     
     public static testMethod void myUnitTestforupdate17() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Trial_Contact_Contact_Us,Country = 'Australia',
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true,LD_Matched_Strategic_Named_Account__c =true);
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();

     }
     
/*Code Coverage for New requirements (Lead Assignment Stream eqauls Lead Grade A) Feb 19,2016   */     
     
     // Code for Insert Operations
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS True
    */
    public static testMethod void myUnitTestLeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true,LD_Matched_Strategic_Named_Account__c =true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS False
    */
     public static testMethod void myUnitTest2LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true);
        Insert newLead;
        Test.stopTest();
     }
     
      //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Enterprise Exp Named Account EQUALS True
    */     
     public static testMethod void myUnitTest4LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Exp_Named_Account__c =true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Entreprise Umbrella EQUALS True
        LD Matched Enterprise Exp Named Account EQUALS False
    */  
     public static testMethod void myUnitTest6LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid(),
                                        Enterprise_Expand_Geo_Owner__c = userinfo.getuserid() );
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Exp_Named_Account__c =false,LD_Matched_Enterprise_Umbrella__c = true);
        Insert newLead;
        Test.stopTest();
     }
     
      //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Enterprise Land Named Account EQUALS True
    */  
     public static testMethod void myUnitTest8LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                       LD_Matched_Enterprise_Land_Named_Account__c  = true);
        Insert newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Account Owner is NOT SMB Accounts
        LD Matched Strategic Umbrella EQUALS False
        LD Matched Enterprise Umbrella EQUALS False
        LD Matched Enterprise Land Named Account EQUALS False
    */  
     public static testMethod void myUnitTest10LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Account_Owner__c ='test');
        Insert newLead;
        Test.stopTest();
     }
     
     
     public static testMethod void myUnitTest11LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,country = 'Australia',
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Account_Owner__c ='test');
        Insert newLead;
        Test.stopTest();
     }
     
     // Code for Update Operations
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS True
    */
    public static testMethod void myUnitTestforUpdateLeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web', CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=true,LD_Matched_Strategic_Named_Account__c =true);
        Insert newLead;
        
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Strategic Umbrella EQUALS True
        LD Matched Strategic Named Account EQUALS False
    */
     public static testMethod void myUnitTestforUpdate2LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account');
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                        Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Strategic_Umbrella__c=false,Account_Lead_Development_Rep__c=userinfo.getuserid());
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        newLead.LD_Matched_Strategic_Umbrella__c= True;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Enterprise Exp Named Account EQUALS True
    */     
     public static testMethod void myUnitTestforupdate4LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Exp_Named_Account__c =false);
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        newLead.LD_Matched_Enterprise_Exp_Named_Account__c = True;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Entreprise Umbrella EQUALS True
        LD Matched Enterprise Exp Named Account EQUALS False
    */  
     public static testMethod void myUnitTestforupdate6LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid() );
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Enterprise_Umbrella__c = true,Account_Enterprise_Umbrella_Owner__c=userinfo.getuserid());
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Enterprise Land Named Account EQUALS False
    */  
     public static testMethod void myUnitTestforupdate8LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account');
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                       LD_Matched_Enterprise_Land_Named_Account__c  = true);
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
 
     //Scenario - Lead is owned by MQL Staging Queue
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Account Owner is NOT SMB Accounts
        LD Matched Strategic Umbrella EQUALS False
        LD Matched Enterprise Umbrella EQUALS False
        LD Matched Enterprise Land Named Account EQUALS False
    */  
     public static testMethod void myUnitTestforupdate10LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Account_Owner__c ='test');
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
    
    //Scenario - Lead is owned by MQL Staging Queue 
    /* Reporting Matched Account is NOT EQUAL to Blank
        Lead Assignment Stream EQUALS Lead Grade A
        LD Matched Account Owner is NOT SMB Accounts
        Country is Australia
        LD Matched Strategic Umbrella EQUALS False
        LD Matched Enterprise Umbrella EQUALS False
        LD Matched Enterprise Land Named Account EQUALS False
    */  
     public static testMethod void myUnitTestforupdate11LeadGradeA() {
       Test.startTest();
        Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c=userinfo.getuserid());
        Insert newAccount;
        
        Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,country = 'Australia',
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Account_Owner__c ='test');
        Insert newLead;
        newLead.ownerid = Label.MQL_Staging_QueueId;
        update newLead;
        Test.stopTest();
     }
     
     Public Static testMethod void CampaignChannelAttributionUpdateTest1(){
         Test.startTest();
         Account newAccount = new Account(name = 'Test Account',Lead_Development_Rep__c = userinfo.getuserid());
         Insert newAccount;
         Lead newLead = new Lead(
                        Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                         Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Lead_Grade_A,country = 'Australia',
                        OwnerId = Label.MQL_Staging_QueueId ,Reporting_Matched_Account__c =newAccount.id,
                        LD_Matched_Account_Owner__c ='test',Campaign_Channel_Attribution__c='701290000001ZOS;8/29/2016;Facebook');
        Insert newLead;
        newLead.Campaign_Channel_Attribution__c='701290000001ZOS;8/29/2016;Twitter';
        Update newLead;    
     }
     
     @isTest
     public static void CampaignChannelAttributionUpdateTest2() {
        Test.startTest();
        Campaign camp = new Campaign();
        camp.name='campaignTest';
        camp.Program_Name__c='test program';
        camp.status='in progress';
        camp.Region__c='test region';
        camp.Fiscal_Year__c='2016';
        camp.Quarter__c='Q1';
        camp.Campaign_Tactic__c='Events';
        camp.Campaign_Offer__c='Analyst Report';
        camp.Vendor_Sponsored__c='yes';
        camp.StartDate=Date.today();
        camp.EndDate=Date.today().addDays(4);
        camp.Total_number_of_Seats__c=2;
        insert camp;
        
        Lead newLead1 = new Lead(
            Company = 'Test Account', 
            LastName= 'Test Lead1',
            Lead_Source_Most_Recent__c = 'Facebook'
        );
        
        Lead newLead2 = new Lead(
            Company = 'Test Account', 
            LastName= 'Test Lead2',
            Campaign_Channel_Attribution__c= camp.Id + ';8/29/2016;Facebook'
        );
        
        insert new List<Lead>{newLead1, newLead2};
        
        CampaignMember cm1 = new CampaignMember(
            LeadId = newLead1.Id,
            CampaignId = camp.Id,
            Status = 'Responded'
        );
        
        CampaignMember cm2 = new CampaignMember(
            LeadId = newLead2.Id,
            CampaignId = camp.Id,
            Status = 'Responded'
        );
        
        insert new List<CampaignMember>{cm1, cm2};
        
        cm1.Lead_Source_Most_Recent__c = null;
        cm2.Lead_Source_Most_Recent__c = null;
        update new List<CampaignMember>{cm1, cm2};
        
        newLead1.Lead_Source_Most_Recent__c = 'Event';
        newLead2.Campaign_Channel_Attribution__c = camp.Id + ';8/29/2016;Jigsaw';
        update new List<Lead> { newLead1, newLead2 };
        Test.stopTest();
     }

     //Author: Sergio Flores
     //Date 9-19
     //Functionality: Adding SafeToSend and notSafeToSend test code coverage here
     public static testMethod void SafeToSendAndNotSafeToSend()
     {
         //Need to add Lead that will flow through the safeToSend method in LeadGateWay on beforeTrigger
         Lead l = new Lead();
         l.Lastname = 'Test Last Name';
         l.Company = 'Test Company';
         l.Status = '1 - Not Contaced';
         l.CurrencyIsoCode = 'USD';
         l.Street = 'Test Street';
         l.City = 'Test City';
         l.State = 'CA';
         l.PostalCode = '55555';
         l.Country = 'US';

         test.startTest();
        
         
         insert l;

         //Updating Country so that the formula fields kick in and Safe to Send Bucket = Opt Out Bucket
         //and SafeToSend logic will execute
         l.Country = 'United States';

         update l;
         
         Lead updatedLead1 = [Select Id, Safe_to_Send__c, Safe_to_Send_as_of_Date__c, Email_Implied_Consent_Eligibility_Date__c
                             From Lead
                             Where Lead.id =: l.id];

         system.assertEquals('Yes', updatedLead1.Safe_to_Send__c);
         system.assertEquals(date.Today(),updatedLead1.Email_Implied_Consent_Eligibility_Date__c);
         system.assertEquals(date.Today(), updatedLead1.Safe_to_Send_as_of_Date__c);
         
         //Updating country to a GDPR country so GDPR field will be false and it will execute NotSafeToSend logic
         l.Country = 'Germany';

         update l;

         Lead updatedLead2 = [Select Id, Safe_to_Send__c, Safe_to_Send_as_of_Date__c, Email_Implied_Consent_Eligibility_Date__c
                             From Lead
                             Where Lead.id =: l.id];

         system.assertEquals('No', updatedLead2.Safe_to_Send__c);
         system.assertEquals(null, updatedLead2.Email_Implied_Consent_Eligibility_Date__c);
         system.assertEquals(null, updatedLead2.Safe_to_Send_as_of_Date__c);

         test.stopTest();   
    }
}