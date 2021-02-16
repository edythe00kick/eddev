@isTest
public class GeneralTest {
    /*public static testMethod void testCustomPartnerBatch(){
        List<Account> accList = new List<Account>();
        for(integer i=0; i<=5;i++){
            Account acc = new Account(Name = 'TestAccount'+i);
            accList.add(acc);
        }
        insert accList;
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
        Profile portalProfile = [SELECT Id FROM Profile where Name='Partner Community User custom'];
        User user = new User(
            Username = 'owtu' + System.now().millisecond() + '@owtu' + System.now().millisecond() + '.com',
            ContactId = conList[0].Id,
            ProfileId = portalProfile.Id,
            Alias = 'cPar' + System.now().millisecond(),
            Email = 'teststomPartner@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345xx',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        insert user;
        
        List<Custom_Partner__c> cusPartnerList = TestDataRepository.createCustomPartner(accList, oppoList);
        Test.startTest();
        CustomPartnerHandlerCreateBatchClass cpcbc = new CustomPartnerHandlerCreateBatchClass();
        database.executeBatch(cpcbc);
        
        Test.stopTest();
    }*/
    
    /*public static testMethod void testcustomerpartner(){
        SObject so;
        CustomPartnerHandler cph = new CustomPartnerHandler();
        /*cph.beforeDelete(so);
        cph.beforeInsert(so);
        cph.beforeUpdate(so, so);
        cph.bulkBefore();*/
        /*List<Account> accList = TestDataRepository.createAccountList();
        List<Contact> conList = TestDataRepository.createContactList(accList);
        List<Opportunity> oppoList 
            = TestDataRepository.createOpportunityList(accList);

        //User user = TestDataRepository.createPortalUser(conList,'TCP');
        User user = OrgWideTestUtil.createPortalUser(true, conList[0].Id);

        List<Custom_Partner__c> cusPartnerList 
            = TestDataRepository.createCustomPartner(accList, oppoList);

        List<Custom_Partner__c> updateCusPartnerList 
            = new List<Custom_Partner__c>();
        
        for(Custom_Partner__c cusUpdate : cusPartnerList){
            cusUpdate.AccountToId__c=accList[1].Id;
            updateCusPartnerList.add(cusUpdate);
            
        }

        update updateCusPartnerList;
        Test.startTest();        
        List<Opportunity> updateoppList = new List<Opportunity>();
        for(Opportunity opp : oppoList){
            opp.ownerId = user.id;
            updateoppList.add(opp);
        }
        update updateoppList;
        Test.stopTest();
        delete cusPartnerList;
    }*/
    
    /** W-007052 : JPH : 20180131 : Test the case where a Distributor is set, 
     *  then deleted
     */
    /*public static testMethod void testDistributorDeal(){
        List<Account> accList = TestDataRepository.createAccountList();
        List<Contact> conList = TestDataRepository.createContactList(accList);
        List<Opportunity> oppoList 
            = TestDataRepository.createOpportunityList(accList);

        //User user = TestDataRepository.createPortalUser(conList,'TDBD');
        User user = OrgWideTestUtil.createPortalUser(true, conList[0].Id);

        Custom_Partner__c cp = new Custom_Partner__c(); 
        cp.AccountToId__c=accList[0].Id;
        cp.OpportunityId__c=oppoList[0].Id;
        cp.IsPrimary__c=true;
        cp.Role__c = 'Software Distributor';
        
        Test.startTest();
        insert cp;        
        
        Opportunity opCheck = [SELECT Id, Distributor_Deal__c 
                               FROM Opportunity 
                               WHERE Id =: oppoList[0].Id];

        system.assertEquals(opCheck.Distributor_Deal__c,TRUE);
        
        delete cp;
        
        Opportunity opCheck2 = [SELECT Id, Distributor_Deal__c 
                                FROM Opportunity 
                                WHERE Id =: oppoList[0].Id];

        system.assertEquals(opCheck2.Distributor_Deal__c,FALSE);
        Test.stopTest();
    }
    
    /** W-007052 : JPH : 20180131 : Test the case where multiple Distributors 
     *  are set, then only 1 gets removed
     */
    
    /*public static testMethod void testDistributorDealMultiple(){
        List<Account> accList = TestDataRepository.createAccountList();       
        List<Contact> conList = TestDataRepository.createContactList(accList);
        List<Opportunity> oppoList 
            = TestDataRepository.createOpportunityList(accList);

        //User user = TestDataRepository.createPortalUser(conList,'CPTD');
        User user = OrgWideTestUtil.createPortalUser(true, conList[0].Id);

        Custom_Partner__c cp1 = new Custom_Partner__c(); 
        cp1.AccountToId__c=accList[0].Id;
        cp1.OpportunityId__c=oppoList[0].Id;
        cp1.IsPrimary__c=true;
        cp1.Role__c = 'Software Distributor';
    
        Custom_Partner__c cp2 = new Custom_Partner__c(); 
        cp2.AccountToId__c=accList[0].Id;
        cp2.OpportunityId__c=oppoList[0].Id;
        cp2.IsPrimary__c=true;
        cp2.Role__c = 'Software Distributor';
    
        
        Test.startTest();
        insert cp1;
        insert cp2;
        
        Opportunity opCheck = [SELECT Id, Distributor_Deal__c 
                               FROM Opportunity 
                               WHERE Id =: oppoList[0].Id];

        system.assertEquals(opCheck.Distributor_Deal__c,TRUE);
        
        delete cp1;
        Opportunity opCheck2 = [SELECT Id, Distributor_Deal__c 
                                FROM Opportunity 
                                WHERE Id =: oppoList[0].Id];

        system.assertEquals(opCheck2.Distributor_Deal__c,false); //sergio updating 2019-02-25
        Test.stopTest();
    }
    
    // Added by Hemendra Singh Rajawat on May 15, 2018

    /**
     * Test when a new custom partner record is inserted and new proposal record
     * is inserted after inserting the custom partner record.
     */
    @isTest 
    public static void testScenario1() {
        Account acc = OrgWideTestUtil.createAccount(true);

        Account parAcc = OrgWideTestUtil.createPartnerAccount(false);
        parAcc.Partner_Type__c = 'DMR';
        insert parAcc;

        Opportunity opp = OrgWideTestUtil.createOpportunity(true, acc.Id);

        // Create Portal User
        //Sergio Flores
        //Date: 06/25/2019
        //CPQ Refactoring
        SBQQ__Quote__c quote = OSCPQ_TestFactory.createSingleQuote(acc,opp,true, true);

        Test.startTest();

        Custom_Partner__c cp 
            = OrgWideTestUtil.createCustomPartner(false, opp.Id, parAcc.Id);

        cp.Role__c = 'Software Distributor';
        insert cp;

        // Create Portal User
        //Sergio Flores
        //Date: 06/25/2019
        //CPQ Refactoring
        SBQQ__Quote__c quote2 = OSCPQ_TestFactory.createSingleQuote(acc,opp,true, true);

        Test.stopTest();
    }

    /**
     * Test when an existing custom partner record id deleted.
     */
    @isTest 
    public static void testScenario2() {
        Account acc = OrgWideTestUtil.createAccount(true);

        Account parAcc = OrgWideTestUtil.createPartnerAccount(false);
        parAcc.Partner_Type__c = 'Master Reseller';
        insert parAcc;

        Opportunity opp = OrgWideTestUtil.createOpportunity(true, acc.Id);
        // Create Portal User
        //Sergio Flores
        //Date: 06/25/2019
        //CPQ Refactoring
        SBQQ__Quote__c quote = OSCPQ_TestFactory.createSingleQuote(acc,opp,true, true);

        Test.startTest();

        Custom_Partner__c cp 
            = OrgWideTestUtil.createCustomPartner(false, opp.Id, parAcc.Id);

        cp.Role__c = 'Value Added Reseller';
        insert cp;

        delete cp;

        Test.stopTest();
    }

    /**
     * Test when an existing custom partner record id updated.
     */
    @isTest 
    public static void testScenario3() {
        List<Account> accList = new List<Account>();

        Account acc = OrgWideTestUtil.createAccount(false);
        accList.add(acc);

        Account parAcc1 = OrgWideTestUtil.createPartnerAccount(false);
        parAcc1.Partner_Type__c = 'Master Reseller';
        accList.add(parAcc1);

        Account parAcc2 = OrgWideTestUtil.createPartnerAccount(false);
        parAcc2.Partner_Type__c = 'DMR';
        accList.add(parAcc2);

        insert accList;

        Opportunity opp = OrgWideTestUtil.createOpportunity(true, acc.Id);
        // Create Portal User
        //Sergio Flores
        //Date: 06/25/2019
        //CPQ Refactoring
        SBQQ__Quote__c quote = OSCPQ_TestFactory.createSingleQuote(acc,opp,true, true);

        Test.startTest();

        Custom_Partner__c cp 
            = OrgWideTestUtil.createCustomPartner(false, opp.Id, parAcc1.Id);

        cp.Role__c = 'Value Added Reseller';
        insert cp;

        cp.AccountToId__c = parAcc2.Id;
        cp.Role__c = 'Software Distributor';
        update cp;

        Test.stopTest();
    }

    /**
     * Test when role of the partner is changed, to cover the OpportunitySplit 
     * functionality.
     */
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

        Account parAcc = OrgWideTestUtil.createPartnerAccount(false);
        parAcc.Partner_Type__c = 'Master Reseller';
        parAcc.Business_Development_Owner__c = u.Id;
        insert parAcc;
    
        Test.startTest();
        
        Opportunity opp = OrgWideTestUtil.createOpportunity(true, acc.Id);
        
        /*OpportunityTeamMember otm = new OpportunityTeammember();
        otm.OpportunityId=opp.Id;
        otm.TeamMemberRole='Business Development Representative';
        otm.userId = u.Id;
        insert otm;
        
        OpportunitySplit oppSplit = new OpportunitySplit();
        oppSplit.OpportunityId = opp.Id;
        oppSplit.SplitOwnerId = u.Id;
        oppSplit.SplitTypeId = Label.OverlayOpportunitySplitId;
        oppSplit.SplitPercentage = 100;
        insert OppSplit;*/

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
    
    public static testMethod void myUnitTest() {
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
        Profile portalProfile = [SELECT Id FROM Profile where Name='Partner Community User custom'];
        User user = new User(
            Username = 'owtu123' + System.now().millisecond() + '@owtu' + System.now().millisecond() + '.com',
            ContactId = conList[0].Id,
            ProfileId = portalProfile.Id,
            Alias = 'LSBT',
            Email = 'test12345LSBT@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345LSBT',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user);
        List<Lead> leadList = new List<Lead>();
        List<Lead> updatedLeadList = new List<Lead>();
        Lead ld = new Lead(Company = 'Test Account', LastName= 'Test Lead',LeadSource = 'Web',CurrencyIsoCode = 'USD',
                           Lead_Assignment_Stream__c = Label.LeadAssignmentStream_Event_Attendee,
                           Reporting_Matched_Account__c =accList[0].id, LD_Matched_Account_Owner__c ='test',
                           OwnerId=System.Label.MQLStagingQueueId_Original,RecordTypeId=System.Label.Altx_Partner_Lead_Record_Type_Id,
                           Partner_Representative__c=con.Id);
        leadList.add(ld);
        Set<Id> leadIdSet = new Set<Id>();
        RunLeadAssignmentRules.reassignLeadWithDefaultAssignmentRule(leadIdSet);
        insert leadList;
        
        LeadShareCreateBatchClass lsbc = new LeadShareCreateBatchClass();
        Database.executeBatch(lsbc);
        Test.StopTest();
        
    }
    
    @isTest
    public static void test1(){
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact con = OrgWideTestUtil.createContact(true, acc.Id);
        List<Profile> profiles = [SELECT Id FROM Profile 
                     WHERE Name = 'Partner Community User Custom'];
        if(profiles.isEmpty())
            return;
            
        User usr = new User(Alias = 'owtu123', Email='owtu123@owtu.com',
                             EmailEncodingKey = 'UTF-8', LastName = 'Testing',
                             LanguageLocaleKey = 'en_US', 
                             LocaleSidKey = 'en_US', 
                             ProfileId = profiles[0].Id, Country = 'United States',
                             IsActive = true, ContactId = con.Id,
                             TimeZoneSidKey='America/Los_Angeles', 
                             UserName = 'owtu123' + System.now().millisecond() + '@owtu' + System.now().millisecond() + '.com');
        insert usr;
        
        System.runAs(usr) {
            Lead l = OrgWideTestUtil.createLead(true);
            UpdateLeadWithPartnerRep.Updatelead(new List<Id>{l.Id});
        }
    }
    
    /*public static testMethod void createNewSharingRuleTest(){
        List<Account> accList = TestDataRepository.createAccountList();
        List<Contact> conList = TestDataRepository.createContactList(accList);
        //User user = TestDataRepository.createPortalUser(conList,'uhtt');
        User user = OrgWideTestUtil.createPortalUser(true, conList[0].Id);
        List<Opportunity> oppoList = TestDataRepository.createOpportunityList(accList);
        List<Lead> leadList = TestDataRepository.createLeadList(conList);
        //Test.startTest();
        List<Custom_Partner__c> cusPartnerList = TestDataRepository.createCustomPartner(accList, oppoList);
        UserHandler uh = new UserHandler();
        SObject so;
        uh.beforeInsert(so);
        uh.beforeDelete(so);
        uh.beforeUpdate(so, so);
        uh.afterDelete(so);
        uh.afterUpdate(so, so);
        //Test.stopTest();
    }*/
    
    /*static testMethod void passwordresettest(){
        List<Account> accList = TestDataRepository.createAccountList();       
        List<Contact> conList = TestDataRepository.createContactList(accList);
        //User user = TestDataRepository.createPortalUser(conList.Id,'AURL');
        User user = OrgWideTestUtil.createPortalUser(true, conList[0].Id);
        
        System.runAs(user) {
            user.Alias = 'AURL';
            update user;
        }
        System.runAs(user) {
            Altx_URLBuilderController.getPartnerId();
        }
    }*/
    /*
    public static testMethod void testFeedItemMethod(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community User custom'];
        
        Account Acc = new Account(Name = 'Test Account');
        insert Acc;
        
        Contact Con = new Contact( AccountID = Acc.id, FirstName = 'Test', LastName = 'User', 
                                  email = 'test-user@fakeemail.com' );
        insert Con; 
        User u = new User(Alias = 'FITest', Email='test@example.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, contactid = con.id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='owtu123' + System.now().millisecond() + '@owtu' + System.now().millisecond() + '.com');
        insert u;
        
        System.runAs(u) {
            Lead ld = OrgWideTestUtil.createLead(true);
            ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
            ConnectApi.MentionSegmentInput mentionSegmentInput1 = new ConnectApi.MentionSegmentInput();
            ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
            
            messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
            
            mentionSegmentInput.id = u.id;
            messageBodyInput.messageSegments.add(mentionSegmentInput);
            
            mentionSegmentInput1.id = u.id;
            messageBodyInput.messageSegments.add(mentionSegmentInput1);
            
            textSegmentInput.text = 'Could you take a look?';
            messageBodyInput.messageSegments.add(textSegmentInput);
            
            feedItemInput.body = messageBodyInput;
            feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
            feedItemInput.subjectId = ld.id;
            ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Null, feedItemInput);
        }
    }
    public static testMethod void testFeedItemMethod1(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Partner Community User custom']; 
        
        Account Acc = new Account(Name = 'Test Account');
        insert Acc;
        
        Contact Con = new Contact( AccountID = Acc.id, FirstName = 'Test', LastName = 'User', 
                                  email = 'test-user@fakeemail.com' );
        insert Con; 
        User u = new User(Alias = 'standt', Email='test@example.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, contactid = con.id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='standt@fakemail.com');
        insert u;
        Opportunity op=new Opportunity();
        op.AccountId=Acc.id;
        op.Name='test opp';
        op.StageName='Closed Lost';
        op.CloseDate=date.today();
        insert op;
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput1 = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        
        mentionSegmentInput.id = u.id;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        mentionSegmentInput1.id = u.id;
        messageBodyInput.messageSegments.add(mentionSegmentInput1);
        
        textSegmentInput.text = 'Could you take a look?';
        messageBodyInput.messageSegments.add(textSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = op.id;
        ConnectApi.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Null, feedItemInput);
    }
    
    public static testMethod void testFeedItemMethod2(){            
        Account Acc = new Account(Name = 'Test Account');
        insert Acc;
        
        Contact Con = new Contact( AccountID = Acc.id, FirstName = 'Test', LastName = 'User', 
                                  email = 'test-user@fakeemail.com' );
        insert Con; 
        Lead ld=new lead();
        ld.FirstName='test';
        ld.LastName='test2';
        ld.Company='test';
        ld.phone='1231231231';
        insert ld;
        
        FeedItem post = new FeedItem();
        post.body = '[Welcome to test Knowledge]';
        Post.parentid = ld.Id;
        insert post;
        
        post.body = '[Test]';
        update post;
        
        delete post;
    }*/
    
    public static testMethod void myUnitTest13() {
        //LeadHandler lh = new LeadHandler();
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
    }
}