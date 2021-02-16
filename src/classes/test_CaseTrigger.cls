@isTest
public class test_CaseTrigger{

  static testMethod void CaseHandler(){
    Pager_Duty_Integration_Settings__c pdConfig = new Pager_Duty_Integration_Settings__c(Name = 'PagerDuty_Config');
    insert pdConfig;
        
      list<Case> updateCaseList = new list<Case>();
      list<Case> InsertCase = new list<Case>();
      
      CaseHandler csehandl = new CaseHandler();
      
      Account a = new Account();
      a.name = 'Test Acct';
      insert a;
      
      Contact c =  new Contact();
      c.lastname = 'Interactive';
      c.accountid = a.id;
      c.email = 'c@gmail.com';
      insert c;
      
      Case oldCase = new Case();
      oldCase.RecordTypeId = Label.QuickstartCaseId;
      oldCase.Track_Quick_Start_Email__c = System.today() + 15;
      oldcase.accountid = a.id;
      oldcase.contactid = c.id;
      oldcase.status = 'Onsite Quick Start';      
      InsertCase.add(oldCase);
      
      Case oldCase1 = new Case();
      oldCase1.RecordTypeId = Label.QuickstartCaseId;
      oldCase1.Track_Quick_Start_Email__c = System.today() + 15;
      oldcase1.accountid = a.id;
      oldcase1.contactid = c.id;
      oldcase1.status = 'Onsite Quick Start';
      InsertCase.add(oldCase1);
      
      Case oldCase2 = new Case();
      oldCase2.RecordTypeId = Label.QuickstartCaseId;
      oldCase2.Track_Quick_Start_Email__c = System.today() + 15;
      oldcase2.accountid = a.id;
      oldcase2.contactid = c.id;
      oldcase2.status = 'Onsite Quick Start';
      InsertCase.add(oldCase2);
      
      Case oldCase3 = new Case();
      oldCase3.RecordTypeId = Label.QuickstartCaseId;
      oldCase3.Track_Quick_Start_Email__c = System.today() + 15;
      oldcase3.accountid = a.id;
      oldcase3.contactid = c.id;
      oldcase3.status = 'Onsite Quick Start';
      InsertCase.add(oldCase3);
      
      insert InsertCase;
      
      csehandl.beforeUpdate(oldCase3,oldCase2);
      csehandl.afterInsert(oldCase3);
      csehandl.beforeDelete(oldCase3);
      csehandl.beforeInsert(oldCase3);
      csehandl.afterDelete(oldCase3);
     
      Case case2bupdated = new Case();
      case2bupdated.id = InsertCase[0].id;
      case2bupdated.status = 'Submitted';
      case2bupdated.track_Quick_Start_Email__c  = System.today() + 30; 
      case2bupdated.Session_1_Scheduled__c = Date.today();
      case2bupdated.Session_2_Scheduled__c  = Date.today() + 5;
      case2bupdated.Software_Version__c = '11.8';
      case2bupdated.Reason = 'Bug';
      case2bupdated.Case_Attribute__c = 'Tableau';
      case2bupdated.New_Release_Feature__c = 'Bug';
      case2bupdated.Case_Escalation_Summary__c  = 'Test Summary';
      case2bupdated.Community_Post__c = 'https://alteryx.com';
      case2bupdated.Products__c = 'Data';
      case2bupdated.Severity__c = '4 - Low';
      case2bupdated.Case_Category__c = 'Bug';
      updateCaseList.add(case2bupdated);
      
      Case case2bupdated1 = new Case();
      case2bupdated1.id = InsertCase[1].id;
      case2bupdated1.status = 'Submitted';
      case2bupdated1.track_Quick_Start_Email__c  = System.today() + 30; 
      case2bupdated1.Session_1_Scheduled__c = Date.today();
      case2bupdated1.Session_2_Scheduled__c  = null;
      case2bupdated1.Software_Version__c = '11.8';
      case2bupdated1.Reason = 'Bug';
      case2bupdated1.Case_Attribute__c = 'Tableau';
      case2bupdated1.New_Release_Feature__c = 'Bug';
      case2bupdated1.Case_Escalation_Summary__c  = 'Test Summary';
      case2bupdated1.Community_Post__c = 'https://alteryx.com';
      case2bupdated1.Products__c = 'Data';
      case2bupdated1.Severity__c = '4 - Low';
      case2bupdated1.Case_Category__c = 'Bug';
      updateCaseList.add(case2bupdated1);
      
      Case case2bupdated3 = new Case();
      case2bupdated3.id = InsertCase[3].id;
      case2bupdated3.status = 'Submitted';
      case2bupdated3.track_Quick_Start_Email__c  = System.today() + 30; 
      case2bupdated3.Session_1_Scheduled__c = null;
      case2bupdated3.Session_2_Scheduled__c  = null;
      case2bupdated3.Software_Version__c = '11.8';
      case2bupdated3.Reason = 'Bug';
      case2bupdated3.Case_Attribute__c = 'Tableau';
      case2bupdated3.New_Release_Feature__c = 'Bug';
      case2bupdated3.Case_Escalation_Summary__c  = 'Test Summary';
      case2bupdated3.Community_Post__c = 'https://alteryx.com';
      case2bupdated3.Products__c = 'Data';
      case2bupdated3.Severity__c = '4 - Low';
      case2bupdated3.Case_Category__c = 'Bug';
      updateCaseList.add(case2bupdated3);
      
      update updateCaseList;
      
  }
  
  static testMethod void CaseHandlerforElseConditions(){
  Pager_Duty_Integration_Settings__c pdConfig = new Pager_Duty_Integration_Settings__c(Name = 'PagerDuty_Config');
    insert pdConfig;
    
      list<Case> updateCaseList = new list<Case>();
      list<Case> InsertCase = new list<Case>();
      
      CaseHandler csehandl = new CaseHandler();
      
      Account a = new Account();
      a.name = 'Test Acct';
      insert a;
      
      Contact c =  new Contact();
      c.lastname = 'Interactive';
      c.accountid = a.id;
      c.email = 'c@gmail.com';
      insert c;
      
      Case oldCase = new Case();
      oldCase.RecordTypeId = Label.QuickstartCaseId;
      oldCase.Track_Quick_Start_Email__c = System.today() + 15;
      oldcase.accountid = a.id;
      oldcase.contactid = c.id;
      oldcase.status = 'Onsite Quick Start';
      InsertCase.add(oldCase);
      
      Case oldCase1 = new Case();
      oldCase1.RecordTypeId = Label.QuickstartCaseId;
      oldCase1.Track_Quick_Start_Email__c = System.today() + 15;
      oldcase1.accountid = a.id;
      oldcase1.contactid = c.id;
      oldcase1.status = 'Onsite Quick Start';
      InsertCase.add(oldCase1);
      
      Case oldCase2 = new Case();
      oldCase2.RecordTypeId = Label.QuickstartCaseId;
      oldCase2.Track_Quick_Start_Email__c = System.today() + 15;
      oldcase2.accountid = a.id;
      oldcase2.contactid = c.id;
      oldcase2.status = 'Onsite Quick Start';
      InsertCase.add(oldCase2);
      
      Case oldCase3 = new Case();
      oldCase3.RecordTypeId = Label.QuickstartCaseId;
      oldCase3.Track_Quick_Start_Email__c = System.today() + 15;
      oldcase3.accountid = a.id;
      oldcase3.contactid = c.id;
      oldcase3.status = 'Onsite Quick Start';
      InsertCase.add(oldCase3);
     
      Case oldCase4 = new Case();
      oldCase4.RecordTypeId = Label.QuickstartCaseId;
      oldCase4.Track_Quick_Start_Email__c = System.today() + 15;
      oldcase4.accountid = a.id;
      oldcase4.contactid = c.id;
      oldcase4.status = 'Onsite Quick Start';
      InsertCase.add(oldCase4);
     
      Case oldCase5 = new Case();
      oldCase5.RecordTypeId = Label.QuickstartCaseId;
      oldCase5.Track_Quick_Start_Email__c = System.today() + 15;
      oldcase5.accountid = a.id;
      oldcase5.contactid = c.id;
      oldcase5.status = 'Onsite Quick Start';
      InsertCase.add(oldCase5);
     
      Case oldCase6 = new Case();
      oldCase6.RecordTypeId = Label.QuickstartCaseId;
      oldCase6.Track_Quick_Start_Email__c = System.today() + 15;
      oldcase6.accountid = a.id;
      oldcase6.contactid = c.id;
      oldcase6.status = 'Onsite Quick Start';
      InsertCase.add(oldCase6);
      
      insert InsertCase;
      
      //csehandl.bulkBefore();
      csehandl.beforeUpdate(oldCase3,oldCase2);
      csehandl.afterInsert(oldCase3);
      csehandl.beforeDelete(oldCase3);
      csehandl.beforeInsert(oldCase3);
     
      Case case2bupdated = new Case();
      case2bupdated.id = InsertCase[0].id;
      case2bupdated.status = 'Submitted';
      case2bupdated.track_Quick_Start_Email__c  = System.today() + 30; 
      case2bupdated.Session_1_Scheduled__c = Date.today();
      case2bupdated.Session_2_Scheduled__c  = Date.today() + 5;
      case2bupdated.Severity__c = '4 - Low';
      case2bupdated.Software_Version__c = '11.8';
      case2bupdated.Case_Category__c = 'Bug';
      case2bupdated.Reason = 'Bug';
      case2bupdated.Case_Attribute__c = 'Tableau';
      case2bupdated.New_Release_Feature__c = 'Bug';
      case2bupdated.Case_Escalation_Summary__c  = 'Test Summary';
      case2bupdated.Community_Post__c = 'https://alteryx.com';
      updateCaseList.add(case2bupdated);
      
      Case case2bupdated1 = new Case();
      case2bupdated1.id = InsertCase[1].id;
      case2bupdated1.status = 'Submitted';
      case2bupdated1.track_Quick_Start_Email__c  = System.today() + 30; 
      case2bupdated1.Session_1_Scheduled__c = Date.today();
      case2bupdated1.Session_2_Scheduled__c  = Date.today() + 5;
      case2bupdated1.Severity__c = '4 - Low';
      case2bupdated1.Software_Version__c = '11.8';
      case2bupdated1.Case_Category__c = 'Bug';
      case2bupdated1.Reason = 'Bug';
      case2bupdated1.Case_Attribute__c = 'Tableau';
      case2bupdated1.New_Release_Feature__c = 'Bug';
      case2bupdated1.Case_Escalation_Summary__c  = 'Test Summary';
      case2bupdated1.Community_Post__c = 'https://alteryx.com';
      updateCaseList.add(case2bupdated1);
      
      Case case2bupdated2 = new Case();
      case2bupdated2.id = InsertCase[2].id;
      case2bupdated2.status = 'Submitted';
      case2bupdated2.track_Quick_Start_Email__c  = System.today() + 30; 
      case2bupdated2.Session_1_Scheduled__c = Date.Today();
      case2bupdated2.Session_2_Scheduled__c  = null;
      case2bupdated2.Severity__c = '4 - Low';
      case2bupdated2.Software_Version__c = '11.8';
      case2bupdated2.Case_Category__c = 'Bug';
      case2bupdated2.Reason = 'Bug';
      case2bupdated2.Case_Attribute__c = 'Tableau';
      case2bupdated2.New_Release_Feature__c = 'Bug';
      case2bupdated2.Case_Escalation_Summary__c  = 'Test Summary';
      case2bupdated2.Community_Post__c = 'https://alteryx.com';
      updateCaseList.add(case2bupdated2);
      
      Case case2bupdated3 = new Case();
      case2bupdated3.id = InsertCase[3].id;
      case2bupdated3.status = 'Submitted';
      case2bupdated3.track_Quick_Start_Email__c  = System.today() + 30; 
      case2bupdated3.Session_1_Scheduled__c = Date.Today();
      case2bupdated3.Session_2_Scheduled__c  = null;
      case2bupdated3.Severity__c = '4 - Low';
      case2bupdated3.Software_Version__c = '11.8';
      case2bupdated3.Case_Category__c = 'Bug';
      case2bupdated3.Reason = 'Bug';
      case2bupdated3.Case_Attribute__c = 'Tableau';
      case2bupdated3.New_Release_Feature__c = 'Bug';
      case2bupdated3.Case_Escalation_Summary__c  = 'Test Summary';
      case2bupdated3.Community_Post__c = 'https://alteryx.com';
      updateCaseList.add(case2bupdated3);
      
      Case case2bupdated4 = new Case();
      case2bupdated4.id = InsertCase[4].id;
      case2bupdated4.status = 'Submitted';
      case2bupdated4.track_Quick_Start_Email__c  = System.today() + 30; 
      case2bupdated4.Session_1_Scheduled__c = null;
      case2bupdated4.Session_2_Scheduled__c  = null;
      case2bupdated4.Quote_Proposal_Primary_Contact_Email__c = 'test123@123test.com';
      case2bupdated4.Opportunity_Owner_Email__c = 'test123@123test.com';
      case2bupdated4.Severity__c = '4 - Low';
      case2bupdated4.Software_Version__c = '11.8';
      case2bupdated4.Case_Category__c = 'Bug';
      case2bupdated4.Reason = 'Bug';
      case2bupdated4.Case_Attribute__c = 'Tableau';
      case2bupdated4.New_Release_Feature__c = 'Bug';
      case2bupdated4.Case_Escalation_Summary__c  = 'Test Summary';
      case2bupdated4.Community_Post__c = 'https://alteryx.com';
      updateCaseList.add(case2bupdated4);
      
      Case case2bupdated5 = new Case();
      case2bupdated5.id = InsertCase[5].id;
      case2bupdated5.status = 'Submitted';
      case2bupdated5.track_Quick_Start_Email__c  = System.today() + 30; 
      case2bupdated5.Session_1_Scheduled__c = null;
      case2bupdated5.Session_2_Scheduled__c  = null;
      case2bupdated5.Severity__c = '4 - Low';
      case2bupdated5.Software_Version__c = '11.8';
      case2bupdated5.Case_Category__c = 'Bug';
      case2bupdated5.Reason = 'Bug';
      case2bupdated5.Case_Attribute__c = 'Tableau';
      case2bupdated5.New_Release_Feature__c = 'Bug';
      case2bupdated5.Case_Escalation_Summary__c  = 'Test Summary';
      case2bupdated5.Community_Post__c = 'https://alteryx.com';
      updateCaseList.add(case2bupdated5);
      
      update updateCaseList;
      
      Case this_Case = new Case();
      this_Case.RecordTypeId = Label.SFDC_Internal_Support_Ticket_RecordTypeId;
      this_Case.accountid = a.id;
      this_Case.contactid = c.id;
      this_Case.status = 'Submitted';
      insert this_Case;
  }
  
  static testMethod void UpdateContactIdOnCase(){
    Pager_Duty_Integration_Settings__c pdConfig = new Pager_Duty_Integration_Settings__c(Name = 'PagerDuty_Config');
    insert pdConfig;
    
      Profile p = [select id from profile limit 1];
           
      User u = new user();
        u.LastName = 'Interactive';
        u.Email = 'ctestx@gmail.com';
        u.Alias = 'Tcode';
        u.Username = 'testCaseContactUpdate@test.com';
        u.CommunityNickname = 'test12';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
      insert u;

      
      
      system.runas(u){
          Account a = new Account();
          a.name = 'Test Acct';
          insert a;
      
          Contact c =  new Contact();
          c.FirstName = 'Grazitti';
          c.lastname = 'Interactive';
          c.accountid = a.id;
          c.email = 'ctestx@gmail.com';
          c.phone = '9999999999';
          insert c;
          
          Asset ass = new Asset();
          ass.name = 'Test ass';
          ass.accountId = a.id;
          ass.contactId = c.id;
          insert ass;
          
          entitlement ec = new entitlement();
          ec.name='Test Entitlement';
          ec.accountId=a.id;
          ec.startDate= date.today().addDays(-3);
          ec.endDate = date.today().addDays(4);
          ec.assetId = ass.id;
          insert ec;
          
          EntitlementContact econ = New EntitlementContact();
          econ.contactId = c.id;
          econ.entitlementId = ec.id;
          insert econ;
          
          Case newCase= new Case();
          newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Alteryx Standard Case').getRecordTypeId();
          newCase.accountid = a.id;
          newCase.contactid = c.id;
          newCase.status = 'Submitted';
          newCase.Products__c = 'Data';
          newCase.Severity__c = 'SEV 1';
          newCase.Case_Category__c = 'General Promote Questions';
          insert newCase;
          
      }
  }
  
  @isTest
  public static void DefaultEntitlementTest() {
    Pager_Duty_Integration_Settings__c pdConfig = new Pager_Duty_Integration_Settings__c(Name = 'PagerDuty_Config');
    insert pdConfig;
    
      Account Acc = new Account(name = 'Test Account');
      Insert Acc;
      
      Contact con = new Contact(AccountId=acc.id,Firstname='Contact',LastName='Test contact',email='testcontact@alteryx.com',Phone='9878158495');
      Insert con;
      
      System.debug('@@@Contact' + con);
            
      Asset ass = new Asset();
      ass.name = 'Test ass';
      ass.accountId = acc.id;
      ass.contactId = con.id;
      insert ass;
      
      entitlement ec = new entitlement();
      ec.name='Test Entitlement';
      ec.accountId=acc.id;
      ec.startDate= date.today().addDays(-3);
      ec.endDate = date.today().addDays(4);
      ec.assetId = ass.id;
      insert ec;
      
      Case newCase= new Case();
      newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Alteryx Standard Case').getRecordTypeId();
      //newCase.accountid = acc.id;
      newCase.contactid = con.id;
      newCase.status = 'Submitted';
      newCase.WebToCasePage__c = True;
      newCase.Web_Name__c = 'Test';
      newCase.Web_phone__c = '1010101010';
      newCase.Web_email__c = 'test@test.com';
      newCase.Web_Company__c = 'test';
      newCase.suppliedEmail='test@test.com';
      newCase.suppliedname='test name';
      newCase.Products__c = 'Data';
      newCase.Severity__c = 'SEV 1';
      newCase.Case_Category__c = 'SDK';
      insert newCase;
      
    }
    
    @isTest
    public static void DefaultEntitlementTest1() {
        Pager_Duty_Integration_Settings__c pdConfig = new Pager_Duty_Integration_Settings__c(Name = 'PagerDuty_Config');
    insert pdConfig;
    
        Account Acc = new Account(name = 'Test Account');
        Insert Acc;
          
        Contact con = new Contact(AccountId=acc.id,Firstname='Contact',LastName='Test contact',email='testcontact@alteryx.com',Phone='9878158495');
        Insert con;
          
        System.debug('@@@Contact' + con);
                  
        Asset ass = new Asset();
        ass.name = 'Test ass';
        ass.accountId = acc.id;
        ass.contactId = con.id;
        insert ass;
          
        entitlement ec = new entitlement();
        ec.name='Test Entitlement';
        ec.accountId=acc.id;
        ec.startDate= date.today().addDays(-3);
        ec.endDate = date.today().addDays(4);
        ec.assetId = ass.id;
        insert ec;
          
        Case newCase= new Case();
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Alteryx Standard Case').getRecordTypeId();
        newCase.accountid = acc.id;
        newCase.contactid = con.id;
        newCase.status = 'Submitted';
        newCase.WebToCasePage__c = True;
        newCase.Web_Name__c = 'Test';
        newCase.Web_phone__c = '1010101010';
        newCase.Web_email__c = 'test@test.com';
        newCase.Web_Company__c = 'test';
        newCase.suppliedEmail='test@test.com';
        newCase.suppliedname='test name';
        newCase.Products__c = 'Data';
        newCase.Severity__c = 'SEV 1';
        newCase.Case_Category__c = 'General Promote Questions';
        insert newCase;
          
        newCase.Status = 'Closed';
        newCase.Products__c = 'Data';
        newCase.Case_Category__c = 'Data';
        newCase.Reason = 'Data Investigation';
        newCase.Case_Detail__c  = 'Data';
        newCase.Origin = 'Alteryx.com';
        newCase.SlaStartDate = System.now();
        newCase.Severity__c = 'SEV 1';
        newCase.Software_Version__c = '11.8';
        newCase.Case_Category__c = 'Bug';
        newCase.Reason = 'Bug';
        newCase.Case_Attribute__c = 'Tableau';
        newCase.New_Release_Feature__c = 'Bug';
        newCase.Case_Escalation_Summary__c  = 'Test Summary';
        newCase.Community_Post__c = 'https://alteryx.com';
        update newCase;
      
    } 
    
    static testMethod void SetCaseToResolved() {
        Pager_Duty_Integration_Settings__c pdConfig = new Pager_Duty_Integration_Settings__c(Name = 'PagerDuty_Config');
    insert pdConfig;
    
        Profile p = [select id from profile where Name = 'System Administrator' limit 1];
           
        User u = new user();
            u.LastName = 'TESTABLE';
            u.Email = 'testcontact@alteryx.com';
            u.Alias = 'Tcode';
            u.Username = 'testCaseContactUpdate@test.com';
            u.CommunityNickname = 'test12';
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'GMT';
            u.ProfileID = p.id;
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.isActive=True;
        insert u;

        Account Acc = new Account(name = 'Test Account');
        Insert Acc;
          
        Contact con = new Contact(AccountId=acc.id,Firstname='Contact',LastName='TESTABLE',email='testcontact@alteryx.com',Phone='9878158495');
        Insert con;
          
        System.debug('@@@Contact' + con);
                  
        Asset ass = new Asset();
        ass.name = 'Test ass';
        ass.accountId = acc.id;
        ass.contactId = con.id;
        insert ass;
          
        entitlement ec = new entitlement();
        ec.name='Test Entitlement';
        ec.accountId=acc.id;
        ec.startDate= date.today().addDays(-3);
        ec.endDate = date.today().addDays(4);
        ec.assetId = ass.id;
        insert ec;
      
        Test.startTest();

        system.debug('**** IN TEST : RUNAS : ' + u.LastName);   
        Case newCase= new Case();
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Alteryx Standard Case').getRecordTypeId();
        newCase.accountid = acc.id;
        newCase.contactid = con.id;
        newCase.status = 'Submitted';
        newCase.WebToCasePage__c = True;
        newCase.Web_Name__c = 'Test';
        newCase.Web_phone__c = '1010101010';
        newCase.Web_email__c = 'test@test.com';
        newCase.Web_Company__c = 'test';
        newCase.suppliedEmail='test@test.com';
        newCase.suppliedname='test name';
        newCase.Products__c = 'Data';
        newCase.Severity__c = 'SEV 1';
        newCase.Case_Category__c = 'General Promote Questions';
        insert newCase;        
        
        newCase.Status = 'Resolved';
        newCase.Products__c = 'Data';
        newCase.Case_Category__c = 'Data';
        newCase.Reason = 'Data Investigation';
        newCase.Case_Detail__c  = 'Data';
        newCase.Origin = 'test@alteryx.com';
        newCase.SlaStartDate = System.now();
        newCase.Severity__c = 'SEV 1';
        newCase.Software_Version__c = '11.8';
        newCase.Case_Category__c = 'Bug';
        newCase.Reason = 'Bug';
        newCase.Case_Attribute__c = 'Tableau';
        newCase.New_Release_Feature__c = 'Bug';
        newCase.Case_Escalation_Summary__c  = 'Test Summary';
        newCase.Community_Post__c = 'https://alteryx.com';
        update newCase;
        
        Test.stopTest();
    } 
    
     static testMethod void checkPDSettings1() {
        Pager_Duty_Integration_Settings__c pdConfig = new Pager_Duty_Integration_Settings__c(Name = 'PagerDuty_Config', PD_Email_to_Case_Override__c = true, PD_Origin__c = 'test@alteryx.com');
        insert pdConfig;
        
        Profile p = [select id from profile where Name = 'System Administrator' limit 1];
           
        User u = new user();
            u.LastName = 'TESTABLE';
            u.Email = 'testcontact@alteryx.com';
            u.Alias = 'Tcode';
            u.Username = 'testCaseContactUpdate@test.com';
            u.CommunityNickname = 'test12';
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'GMT';
            u.ProfileID = p.id;
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.isActive=True;
        insert u;

        Account Acc = new Account(name = 'Test Account');
        Insert Acc;
          
        Contact con = new Contact(AccountId=acc.id,Firstname='Contact',LastName='TESTABLE',email='testcontact@alteryx.com',Phone='9878158495');
        Insert con;
          
        System.debug('@@@Contact' + con);
                  
        Asset ass = new Asset();
        ass.name = 'Test ass';
        ass.accountId = acc.id;
        ass.contactId = con.id;
        insert ass;
          
        entitlement ec = new entitlement();
        ec.name='Test Entitlement';
        ec.accountId=acc.id;
        ec.startDate= date.today().addDays(-3);
        ec.endDate = date.today().addDays(4);
        ec.assetId = ass.id;
        insert ec;
      
        Test.startTest();

        system.debug('**** IN TEST : RUNAS : ' + u.LastName);   
        Case newCase= new Case();
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Alteryx Standard Case').getRecordTypeId();
        newCase.accountid = acc.id;
        newCase.contactid = con.id;
        newCase.status = 'Submitted';
        newCase.Products__c = 'Promote';
        newCase.Case_Category__c = 'General Promote Questions';
        newCase.Priority = 'High';
        newCase.Origin = 'test@alteryx.com';
        insert newCase;   
        
        Test.stopTest();
    } 
    
    static testMethod void checkPDSettings2() {
        Pager_Duty_Integration_Settings__c pdConfig = new Pager_Duty_Integration_Settings__c(Name = 'PagerDuty_Config', PD_Priority__c = '', PD_Products__c = '', PD_Email_to_Case_Override__c = false, PD_Severity__c = 'SEV 1');
        insert pdConfig;
        
        Profile p = [select id from profile where Name = 'System Administrator' limit 1];
           
        User u = new user();
            u.LastName = 'TESTABLE';
            u.Email = 'testcontact@alteryx.com';
            u.Alias = 'Tcode';
            u.Username = 'testCaseContactUpdate@test.com';
            u.CommunityNickname = 'test12';
            u.LocaleSidKey = 'en_US';
            u.TimeZoneSidKey = 'GMT';
            u.ProfileID = p.id;
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.isActive=True;
        insert u;

        Account Acc = new Account(name = 'Test Account');
        Insert Acc;
          
        Contact con = new Contact(AccountId=acc.id,Firstname='Contact',LastName='TESTABLE',email='testcontact@alteryx.com',Phone='9878158495');
        Insert con;
          
        System.debug('@@@Contact' + con);
                  
        Asset ass = new Asset();
        ass.name = 'Test ass';
        ass.accountId = acc.id;
        ass.contactId = con.id;
        insert ass;
          
        entitlement ec = new entitlement();
        ec.name='Test Entitlement';
        ec.accountId=acc.id;
        ec.startDate= date.today().addDays(-3);
        ec.endDate = date.today().addDays(4);
        ec.assetId = ass.id;
        insert ec;
      
        system.debug('**** IN TEST : RUNAS : ' + u.LastName);   
        Case newCase= new Case();
        newCase.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Alteryx Standard Case').getRecordTypeId();
        newCase.accountid = acc.id;
        newCase.contactid = con.id;
        newCase.status = 'Submitted';
        newCase.Products__c = 'Promote';
        newCase.Case_Category__c = 'General Promote Questions';
        newCase.Priority = 'Low';
        newCase.Origin = 'test@alteryx.com';
        newCase.Severity__c = 'SEV 4';
        insert newCase;
        
        Test.startTest();
        
        newCase.Severity__c = 'SEV 1';
        update newCase;
        
        Test.stopTest();
    } 
     
}