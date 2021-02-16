@isTest (SeeAllData=true)
public class FeedItemTriggerTest {
    
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
    }
    
    public static testMethod void testFeedItemMethod3(){
        Case cs = new Case();
        cs.RecordTypeId = label.SFDC_Internal_Support_Ticket_RecordTypeId;
        cs.Status = 'Submitted';
        cs.OwnerId = UserInfo.getUserId();
        insert cs;
        
        cs.Status = 'Assigned';
        update cs;
        
        Test.startTest();
        
        FeedItem post = new FeedItem();
        post.body = '[Welcome to test Knowledge]';
        Post.parentid = cs.Id;
        insert post;
        
        Test.stopTest();
    }
}