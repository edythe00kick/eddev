@isTest public class CustomPartnerTest {
    
    //Added by: Sharma Nemani | W-011380 | Date: 07/31/2019 --> START
    @testSetup static void setup() {
        User u = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
            //UserRoleId = r.Id
        );
        insert u;
    }
   // Sharma Nemani | W-011380 | Date: 07/31/2019 --> END
    
    public static testMethod void testcustomerpartner(){
        /*Commented by Sergio Flores since we no longer use this structure
        in the handler
        SObject so;
        CustomPartnerHandler cph = new CustomPartnerHandler();
        cph.beforeDelete(so);
        cph.beforeInsert(so);
        cph.beforeUpdate(so, so);
        cph.bulkBefore();*/

        Id userId = [select id from User where Email = 'puser000@amamama.com'].Id;

        Account_BD_Owners_and_States__c  bdOwner = new Account_BD_Owners_and_States__c();
        bdOwner.Name = 'AK';
        
        
        bdOwner.BD_Owner_ID__c = userId;
        insert bdOwner;
        
        List<Account> accList = TestDataRepository.createAccountList();
        for(Account acc : accList)
        {
            acc.Business_Development_Owner__c = userId;
        }

        update accList;

        List<Contact> conList = TestDataRepository.createContactList(accList);
        List<Opportunity> oppoList 
            = TestDataRepository.createOpportunityList(accList);
            
        List<Account> accList1 = TestDataRepository.createAccountList();

        List<Custom_Partner__c> cusPartnerList 
            = TestDataRepository.createCustomPartner(accList1, oppoList);

        List<Custom_Partner__c> updateCusPartnerList 
            = new List<Custom_Partner__c>();
        
        Test.startTest(); 
        for(Custom_Partner__c cusUpdate : cusPartnerList){
            cusUpdate.AccountToId__c=accList[1].Id;
            updateCusPartnerList.add(cusUpdate);
            
        }       
        update updateCusPartnerList;
        //delete cusPartnerList;
        Test.stopTest();
        
    }
    
    /** W-007052 : JPH : 20180131 : Test the case where a Distributor is set, 
     *  then deleted*/
     
    public static testMethod void testDistributorDeal(){
        List<Account> accList = TestDataRepository.createAccountList();
        List<Contact> conList = TestDataRepository.createContactList(accList);
        List<Opportunity> oppoList 
            = TestDataRepository.createOpportunityList(accList);

        Custom_Partner__c cp = new Custom_Partner__c(); 
        cp.AccountToId__c=accList[1].Id;
        cp.OpportunityId__c=oppoList[1].Id;
        cp.IsPrimary__c=true;
        cp.Role__c = 'Software Distributor';
        
        
        
        Test.startTest();
        //Added by: Sharma Nemani | W-011380 | Date: 07/31/2019 --> START
        Id userId = [select id from User where Email = 'puser000@amamama.com'].Id;

        Account_BD_Owners_and_States__c  bdOwner = new Account_BD_Owners_and_States__c();
        bdOwner.Name = 'AK';
        
        
        bdOwner.BD_Owner_ID__c = userId;
        insert bdOwner;

        for(Account acc : accList)
        {
            acc.Business_Development_Owner__c = userId;
        }

        update accList;
        // Sharma Nemani | W-011380 | Date: 07/31/2019 --> END
        insert cp;        
        
        Opportunity opCheck = [SELECT Id, Distributor_Deal__c 
                               FROM Opportunity 
                               WHERE Id =: oppoList[1].Id];

        system.assertEquals(opCheck.Distributor_Deal__c,TRUE);
        
        delete cp;
        
        Opportunity opCheck2 = [SELECT Id, Distributor_Deal__c 
                                FROM Opportunity 
                                WHERE Id =: oppoList[0].Id];

        system.assertEquals(opCheck2.Distributor_Deal__c,FALSE);
        Test.stopTest();
    }
    
    /** W-007052 : JPH : 20180131 : Test the case where multiple Distributors 
     *  are set, then only 1 gets removed*/
     
    
    public static testMethod void testDistributorDealMultiple(){
        List<Account> accList = TestDataRepository.createAccountList();       
        List<Contact> conList = TestDataRepository.createContactList(accList);
        List<Opportunity> oppoList 
            = TestDataRepository.createOpportunityList(accList);

        Custom_Partner__c cp1 = new Custom_Partner__c(); 
        cp1.AccountToId__c=accList[1].Id;
        cp1.OpportunityId__c=oppoList[2].Id;
        cp1.IsPrimary__c=true;
        cp1.Role__c = 'Software Distributor';
    
        Custom_Partner__c cp2 = new Custom_Partner__c(); 
        cp2.AccountToId__c=accList[2].Id;
        cp2.OpportunityId__c=oppoList[3].Id;
        cp2.IsPrimary__c=true;
        cp2.Role__c = 'Software Distributor';
    	
        //Added by: Sharma Nemani | W-011380 | Date: 07/31/2019 --> START
        Id userId = [select id from User where Email = 'puser000@amamama.com'].Id;

        Account_BD_Owners_and_States__c  bdOwner = new Account_BD_Owners_and_States__c();
        bdOwner.Name = 'AK';
        
        
        bdOwner.BD_Owner_ID__c = userId;
        insert bdOwner;
        
        for(Account acc : accList)
        {
            acc.Business_Development_Owner__c = userId;
        }

        update accList;
        
        Test.startTest();
        insert cp1;
        insert cp2;
        
        Opportunity opCheck = [SELECT Id, Distributor_Deal__c 
                               FROM Opportunity 
                               WHERE Id =: oppoList[2].Id];

        system.assertEquals(opCheck.Distributor_Deal__c,TRUE);
        
        delete cp1;
        Opportunity opCheck2 = [SELECT Id, Distributor_Deal__c 
                                FROM Opportunity 
                                WHERE Id =: oppoList[0].Id];
       // Sharma Nemani | W-011380 | Date: 07/31/2019 --> END

        system.assertEquals(opCheck2.Distributor_Deal__c,false); //sergio updating 2019-02-25
        Test.stopTest();
    }
    
    /**
     * Test when role of the partner is changed, to cover the OpportunitySplit 
     * functionality.*/
    @isTest 
    public static void testScenario4() {
        Account acc = OrgWideTestUtil.createAccount(true);

        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];

        User u = new User(Alias = 'standt', Email='custompartner01test@test.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', 
                          LanguageLocaleKey='en_US', LocaleSidKey='en_US', 
                          TimeZoneSidKey='America/Los_Angeles', 
                          ProfileId = p.Id, UserName='custompartner01test@test.com');

        insert u;
        
        User u2 = (User)SmartFactory.createSObject('User');
        insert u2;

        Account parAcc = OrgWideTestUtil.createPartnerAccount(false);
        parAcc.Partner_Type__c = 'Master Reseller';
        parAcc.Business_Development_Owner__c = u2.Id;
        insert parAcc;
    
        Test.startTest();
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(true, acc.Id);
        
        OpportunityTeamMember otm = new OpportunityTeammember();
        otm.OpportunityId=opp.Id;
        otm.TeamMemberRole='Business Development Representative';
        otm.userId = u.Id;
        insert otm;
        
        OpportunitySplit oppSplit = new OpportunitySplit();
        oppSplit.OpportunityId = opp.Id;
        oppSplit.SplitOwnerId = u.Id;
        oppSplit.SplitTypeId = Label.OverlayOpportunitySplitId;
        oppSplit.SplitPercentage = 100;
        insert OppSplit;

        Custom_Partner__c cp 
            = OrgWideTestUtil.createCustomPartner(false, opp.Id, parAcc.Id);

        cp.Role__c = 'Value Added Reseller';
        insert cp;

        cp.Role__c = 'Software Distributor';
        update cp;
        
        cp.Role__c = 'Referrer';
        update cp;

        Test.stopTest();
    }
    //Added by: Sharma Nemani | W-011380 | Date: 07/31/2019 --> START
    public static testMethod void testDistributorDeal1(){
        List<Account> accList = TestDataRepository.createAccountList();
        List<Contact> conList = TestDataRepository.createContactList(accList);
        List<Opportunity> oppoList 
            = TestDataRepository.createOpportunityList(accList);

        Account acc = [select id,Managed_Partner__c from Account where Id =:accList[1].Id];
        acc.Managed_Partner__c = false;
        acc.Business_Development_Owner__c = [select id from User where Email = 'puser000@amamama.com'].Id;
        update acc;
        
        Custom_Partner__c cp = new Custom_Partner__c(); 
        cp.AccountToId__c=acc.Id;
        cp.OpportunityId__c=oppoList[1].Id;
        cp.IsPrimary__c=true;
        cp.Role__c = 'Software Distributor';
        
        
        
        Test.startTest();
        Account_BD_Owners_and_States__c  bdOwner = new Account_BD_Owners_and_States__c();
        bdOwner.Name = 'AK';
        
        bdOwner.BD_Owner_ID__c = [select id from User where Email = 'puser000@amamama.com'].Id;
        insert bdOwner;
        
        insert cp;        
        
        Opportunity opCheck = [SELECT Id, Distributor_Deal__c 
                               FROM Opportunity 
                               WHERE Id =: oppoList[1].Id];

        system.assertEquals(opCheck.Distributor_Deal__c,TRUE);
        
        delete cp;
        
        Opportunity opCheck2 = [SELECT Id, Distributor_Deal__c 
                                FROM Opportunity 
                                WHERE Id =: oppoList[0].Id];

        system.assertEquals(opCheck2.Distributor_Deal__c,FALSE);
        Test.stopTest();
    }
    // Sharma Nemani | W-011380 | Date: 07/31/2019 --> END
}