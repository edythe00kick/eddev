@isTest
public class TestCampaignMemberType{
    static testmethod void AddcampaignMembers(){
    List<campaignMember> camList = new List<campaignMember>();
        Account acc = new Account(Name='Test Account 1',Phone='123456789',CurrencyIsoCode='USD');
        insert acc;
        //Contact con = new Contact(LastName= 'Test Contact 1',Accountid= acc.ID,CurrencyIsoCode='USD',Campaign_Member_Type__c='TCC',Campaign_Referred_Partner_ID__c = '001001001001001');
        Contact con = new Contact(LastName= 'Test Contact 1',Accountid= acc.ID,CurrencyIsoCode='USD',Campaign_Member_Type__c='TCC');
        insert con;
        //Lead ld = new Lead(LastName='Test Lead 1',Company='Test Company 1',CurrencyIsoCode='USD',Status='3 - In Conversation',Campaign_Member_Type__c='TCC',Campaign_Referred_Partner_ID__c = '001001001001001');
        Lead ld = new Lead(LastName='Test Lead 1',Company='Test Company 1',CurrencyIsoCode='USD',Status='3 - In Conversation',Campaign_Member_Type__c='TCC');
        insert ld;
        Campaign cam1= new Campaign (Name='TCC Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam1;
        Campaign cam2= new Campaign (Name='Qlik Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam2;
        
        Test.StartTest();
            CampaignMember camMem1 = new CampaignMember(Campaignid=cam1.id,Contactid=con.id,Status='Responded',CurrencyIsoCode='USD');
            camList.add(camMem1);
            CampaignMember camMem2 = new CampaignMember(Campaignid=cam2.id,Contactid=con.id,Status='Responded',CurrencyIsoCode='USD');
            camList.add(camMem2);
            CampaignMember camMem3 = new CampaignMember(Campaignid=cam1.id,Leadid=ld.id,Status='Responded',CurrencyIsoCode='USD');
            camList.add(camMem3);
            CampaignMember camMem4 = new CampaignMember(Campaignid=cam2.id,Leadid=ld.id,Status='Responded',CurrencyIsoCode='USD');
            camList.add(camMem4);
            insert camList;
        Test.StopTest();
    }
    static testmethod void AddcampaignMembers123(){
        List<campaignMember> camList2 = new List<campaignMember>();
        Account acc1 = new Account(Name='Test Account 1',Phone='123456789',CurrencyIsoCode='USD');
        insert acc1;
        Contact con1 = new Contact(LastName= 'Test Contact 1',Accountid= acc1.ID,CurrencyIsoCode='USD');
        insert con1;
        Lead ld1 = new Lead(LastName='Test Lead 1',Company='Test Company 1',CurrencyIsoCode='USD',Status='3 - In Conversation');
        insert ld1;
        Campaign cam11= new Campaign (Name='TCC Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam11;
        Campaign cam21= new Campaign (Name='Qlik Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam21;
        
        Test.StartTest();
        CampaignMember camMem11 = new CampaignMember(Campaignid=cam11.id,Contactid=con1.id,Status='Responded',CurrencyIsoCode='USD');
        camList2.add(camMem11);
        CampaignMember camMem21 = new CampaignMember(Campaignid=cam21.id,Contactid=con1.id,Status='Responded',CurrencyIsoCode='USD');
        camList2.add(camMem21);
        CampaignMember camMem31 = new CampaignMember(Campaignid=cam11.id,Leadid=ld1.id,Status='Responded',CurrencyIsoCode='USD');
        camList2.add(camMem31);
        CampaignMember camMem41 = new CampaignMember(Campaignid=cam21.id,Leadid=ld1.id,Status='Responded',CurrencyIsoCode='USD');
        camList2.add(camMem41);
        insert camList2;
        Test.StopTest();
    }
    
    static testmethod void AddcampaignMembers2(){
        List<campaignMember> camList3 = new List<campaignMember>();
        Account acca = new Account(Name='Test Account 1',Phone='123456789',CurrencyIsoCode='USD');
        insert acca;
        Contact cona = new Contact(LastName= 'Test Contact 1',Accountid= acca.ID,CurrencyIsoCode='USD',Campaign_Member_Type__c='TCC');
        insert cona;
        Lead lda = new Lead(LastName='Test Lead 1',Company='Test Company 1',CurrencyIsoCode='USD',Status='3 - In Conversation',Campaign_Member_Type__c='TCC');
        insert lda;
        Campaign cam1a= new Campaign (Name='TCC Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam1a;
        Campaign cam2a= new Campaign (Name='Qlik Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam2a;
        CampaignMember camMem1a = new CampaignMember(Campaignid=cam1a.id,Contactid=cona.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem1a;
        CampaignMember camMem2a = new CampaignMember(Campaignid=cam2a.id,Contactid=cona.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem2a;
        CampaignMember camMem3a = new CampaignMember(Campaignid=cam1a.id,Leadid=lda.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem3a;
        CampaignMember camMem4a = new CampaignMember(Campaignid=cam2a.id,Leadid=lda.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem4a;
        
        Test.startTest();
            CampaignMember camMem5a = new CampaignMember(ID =camMem1a.id );
            camMem5a.Status='Sent';
            camList3.add(camMem5a);
            CampaignMember camMem6a = new CampaignMember(ID =camMem2a.id );
                camMem6a.Status='Sent';
            camList3.add(camMem6a);
            CampaignMember camMem7a = new CampaignMember(ID =camMem3a.id );
                camMem7a.Status='Sent';
            camList3.add(camMem7a);
            CampaignMember camMem8a = new CampaignMember(ID =camMem4a.id );
            camMem8a.Status='Sent';
            camList3.add(camMem8a);
            update camList3;
        Test.stopTest();
   
    }
    
    
    static testmethod void AddcampaignMembers4(){
        List<campaignMember> camList4 = new List<campaignMember>();
        Account acca1 = new Account(Name='Test Account 1',Phone='123456789',CurrencyIsoCode='USD');
        insert acca1;
        Contact cona1 = new Contact(LastName= 'Test Contact 1',Accountid= acca1.ID,CurrencyIsoCode='USD',Campaign_Member_Type__c='TCC');
        insert cona1;

        Lead lda1 = new Lead(LastName='Test Lead 1',Company='Test Company 1',CurrencyIsoCode='USD',Status='3 - In Conversation',Campaign_Member_Type__c='TCC');
        insert lda1;

        Campaign cam1a1= new Campaign (Name='Qlik Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam1a1;
        Campaign cam2a1= new Campaign (Name='TCC Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam2a1;
        CampaignMember camMem1a1 = new CampaignMember(Campaignid=cam1a1.id,Contactid=cona1.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem1a1;
        CampaignMember camMem2a1 = new CampaignMember(Campaignid=cam2a1.id,Contactid=cona1.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem2a1;
        CampaignMember camMem3a1 = new CampaignMember(Campaignid=cam1a1.id,Leadid=lda1.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem3a1;
        CampaignMember camMem4a1 = new CampaignMember(Campaignid=cam2a1.id,Leadid=lda1.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem4a1;

        Test.StartTest();
            CampaignMember camMem5a1 = new CampaignMember(ID =camMem1a1.id );
            camList4.add(camMem5a1);
            CampaignMember camMem6a1 = new CampaignMember(ID =camMem2a1.id );
            camList4.add(camMem6a1);
            CampaignMember camMem7a1 = new CampaignMember(ID =camMem3a1.id );
            camList4.add(camMem7a1);
            CampaignMember camMem8a1 = new CampaignMember(ID =camMem4a1.id );
            camList4.add(camMem8a1);
    
            update camList4;
        Test.StopTest();
   
    }
        static testmethod void AddcampaignMembers45(){
        List<campaignMember> camList4 = new List<campaignMember>();
        Account acca1 = new Account(Name='Test Account 1',Phone='123456789',CurrencyIsoCode='USD');
        insert acca1;
        Contact cona1 = new Contact(LastName= 'Test Contact 1',Accountid= acca1.ID,CurrencyIsoCode='USD',Campaign_Member_Type__c='Qlik');
        insert cona1;
        Lead lda1 = new Lead(LastName='Test Lead 1',Company='Test Company 1',CurrencyIsoCode='USD',Status='3 - In Conversation',Campaign_Member_Type__c='Qlik');
        insert lda1;
        Campaign cam1a1= new Campaign (Name='Tableau Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam1a1;
        Campaign cam2a1= new Campaign (Name='TCC Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam2a1;
        CampaignMember camMem1a1 = new CampaignMember(Campaignid=cam1a1.id,Contactid=cona1.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem1a1;
        CampaignMember camMem2a1 = new CampaignMember(Campaignid=cam2a1.id,Contactid=cona1.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem2a1;
        CampaignMember camMem3a1 = new CampaignMember(Campaignid=cam1a1.id,Leadid=lda1.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem3a1;
        CampaignMember camMem4a1 = new CampaignMember(Campaignid=cam2a1.id,Leadid=lda1.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem4a1;

        Test.StartTest();
            CampaignMember camMem5a1 = new CampaignMember(ID =camMem1a1.id );
            camList4.add(camMem5a1);
            CampaignMember camMem6a1 = new CampaignMember(ID =camMem2a1.id );
            camList4.add(camMem6a1);
            CampaignMember camMem7a1 = new CampaignMember(ID =camMem3a1.id );
            camList4.add(camMem7a1);
            CampaignMember camMem8a1 = new CampaignMember(ID =camMem4a1.id );
            camList4.add(camMem8a1);
            update camList4;
        Test.StopTest();
   
    }
    


    static testmethod void AddcampaignMembers3(){
        List<campaignMember> camList5 = new List<campaignMember>();
        Account acc = new Account(Name='Test Account 1',Phone='123456789',CurrencyIsoCode='USD');
        insert acc;
        Contact con = new Contact(LastName= 'Test Contact 1',Accountid= acc.ID,CurrencyIsoCode='USD');
        insert con;
        Lead ld = new Lead(LastName='Test Lead 1',Company='Test Company 1',CurrencyIsoCode='USD',Status='3 - In Conversation');
        insert ld;
        Campaign cam1= new Campaign (Name='TCC Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam1;
        Campaign cam2= new Campaign (Name='Qlik Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam2;
        CampaignMember camMem1 = new CampaignMember(Campaignid=cam1.id,Contactid=con.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem1;
        CampaignMember camMem2 = new CampaignMember(Campaignid=cam2.id,Contactid=con.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem2;
        CampaignMember camMem3 = new CampaignMember(Campaignid=cam1.id,Leadid=ld.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem3;
        CampaignMember camMem4 = new CampaignMember(Campaignid=cam2.id,Leadid=ld.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem4;
        Test.StartTest();
            CampaignMember camMem9 = new CampaignMember(ID =camMem1.id );
            camList5.add(camMem9);
            CampaignMember camMem10 = new CampaignMember(ID =camMem2.id );
            camList5.add(camMem10);
            CampaignMember camMem11 = new CampaignMember(ID =camMem3.id );
            camList5.add(camMem11);
            CampaignMember camMem12 = new CampaignMember(ID =camMem4.id );
            camList5.add(camMem12);
            Delete camList5;
        Test.StopTest();
    }

    static testmethod void AddcampaignMembersc4(){
        List<campaignMember> camList5 = new List<campaignMember>();
        Account acc = new Account(Name='Test Account 1',Phone='123456789',CurrencyIsoCode='USD');
        insert acc;
        Contact con = new Contact(LastName= 'Test Contact 1',Accountid= acc.ID,CurrencyIsoCode='USD');
        insert con;
        Lead ld = new Lead(LastName='Test Lead 1',Company='Test Company 1',CurrencyIsoCode='USD',Status='3 - In Conversation');
        insert ld;
        Campaign cam1= new Campaign (Name='Test Campaign Amazon',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam1;
        Campaign cam2= new Campaign (Name='Test Campaign Power Bi',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam2;
        CampaignMember camMem1 = new CampaignMember(Campaignid=cam1.id,Contactid=con.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem1;
        CampaignMember camMem2 = new CampaignMember(Campaignid=cam2.id,Contactid=con.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem2;
        CampaignMember camMem3 = new CampaignMember(Campaignid=cam1.id,Leadid=ld.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem3;
        CampaignMember camMem4 = new CampaignMember(Campaignid=cam2.id,Leadid=ld.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem4;
        Test.StartTest();
            CampaignMember camMem9 = new CampaignMember(ID =camMem1.id );
            camList5.add(camMem9);
            CampaignMember camMem10 = new CampaignMember(ID =camMem2.id );
            camList5.add(camMem10);
            CampaignMember camMem11 = new CampaignMember(ID =camMem3.id );
            camList5.add(camMem11);
            CampaignMember camMem12 = new CampaignMember(ID =camMem4.id );
            camList5.add(camMem12);
            Delete camList5;
        Test.StopTest();
    }
    
    static testmethod void AddcampaignMembersc5(){
        List<campaignMember> camList5 = new List<campaignMember>();
        Account acc = new Account(Name='Test Account 1',Phone='123456789',CurrencyIsoCode='USD');
        insert acc;
        Contact con = new Contact(LastName= 'Test Contact 1',Accountid= acc.ID,CurrencyIsoCode='USD');
        insert con;
        Lead ld = new Lead(LastName='Test Lead 1',Company='Test Company 1',CurrencyIsoCode='USD',Status='3 - In Conversation');
        insert ld;
        Campaign cam1= new Campaign (Name='Test Campaign Amazon',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam1;
        Campaign cam2= new Campaign (Name='Test Campaign Captora',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam2;
        CampaignMember camMem1 = new CampaignMember(Campaignid=cam1.id,Contactid=con.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem1;
        CampaignMember camMem2 = new CampaignMember(Campaignid=cam2.id,Contactid=con.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem2;
        CampaignMember camMem3 = new CampaignMember(Campaignid=cam1.id,Leadid=ld.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem3;
        CampaignMember camMem4 = new CampaignMember(Campaignid=cam2.id,Leadid=ld.id,Status='Responded',CurrencyIsoCode='USD');
        insert camMem4;
        Test.StartTest();
            CampaignMember camMem9 = new CampaignMember(ID =camMem1.id );
            camList5.add(camMem9);
            CampaignMember camMem10 = new CampaignMember(ID =camMem2.id );
            camList5.add(camMem10);
            CampaignMember camMem11 = new CampaignMember(ID =camMem3.id );
            camList5.add(camMem11);
            CampaignMember camMem12 = new CampaignMember(ID =camMem4.id );
            camList5.add(camMem12);
            Delete camList5;
        Test.StopTest();
    }
    
    static testmethod void AddcampaignMembers6(){
        
        Lead ld = new Lead(LastName='Test Lead 1',Company='Test Company 1',Status='3 - In Conversation',Campaign_Referred_Partner_ID__c='1234');
        insert ld;
        Campaign cam1= new Campaign (Name='Test Campaign Amazon',Type='Other',Status='In Progress',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam1;
        CampaignMember camMem1 = new CampaignMember(Campaignid=cam1.id,LeadId=ld.id,Status='Responded');
        insert camMem1;
        Test.StartTest();
            camMem1.Campaign_Referred_Partner_ID__c = '1234';
            camMem1.Campaign_Referred_Partner_Id_Update_Time__c = DateTime.Now();
            update camMem1; 
        Test.StopTest();
        
    }

    static testmethod void AddcampaignMembers7(){
        
        Account acc = new Account(Name='Test Account 1',Phone='123456789');
        insert acc;
        Contact con = new Contact(LastName= 'Test Contact 1',Accountid= acc.ID,Campaign_Referred_Partner_ID__c='1234');
        insert con;
        Campaign cam1= new Campaign (Name='Test Campaign Amazon',Type='Other',Status='In Progress',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam1;
        CampaignMember camMem1 = new CampaignMember(Campaignid=cam1.id,ContactId=con.id,Status='Responded');
        insert camMem1;
        Test.StartTest();
        camMem1.Campaign_Referred_Partner_ID__c = '1234';
        camMem1.Campaign_Referred_Partner_Id_Update_Time__c = DateTime.Now();
        update camMem1;
                
        Test.StopTest();
        
    }
    static testmethod void AddcampaignMembers8(){
        
        List<campaignMember> camList = new List<campaignMember>();
        Account acc = new Account(Name='Test Account 1',Phone='123456789',CurrencyIsoCode='USD');
        insert acc;
        Contact con = new Contact(LastName= 'Test Contact 1',Accountid= acc.ID,CurrencyIsoCode='USD');
        insert con;
        Lead ld = new Lead(LastName='Test Lead 1',Company='Test Company 1',CurrencyIsoCode='USD',Status='3 - In Conversation');
        insert ld;
        
        Campaign cam1= new Campaign (Name='XYZ Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam1;
        Campaign cam2= new Campaign (Name='XYZ Test',Type='Other',Status='In Progress',CurrencyIsoCode='USD',StartDate=date.Today()+1,EndDate=date.Today()+5);
        insert cam2;
        
        Test.StartTest();
            CampaignMember camMem1 = new CampaignMember(Campaignid=cam1.id,Contactid=con.id,Status='Responded',CurrencyIsoCode='USD');
            camList.add(camMem1);
            CampaignMember camMem2 = new CampaignMember(Campaignid=cam1.id,Leadid=ld.id,Status='Responded',CurrencyIsoCode='USD');
            camList.add(camMem2);
            
            CampaignMember camMem3 = new CampaignMember(Campaignid=cam2.id,Contactid=con.id,Status='Responded',CurrencyIsoCode='USD');
            camList.add(camMem3);
            CampaignMember camMem4 = new CampaignMember(Campaignid=cam2.id,Leadid=ld.id,Status='Responded',CurrencyIsoCode='USD');
            camList.add(camMem4);
        insert camList;
        Test.StopTest();
        
    }
    
    static testmethod void AddcampaignMembers9(){
        Account ac = new Account(Name='test',BillingCountry='US');
        insert ac;
        Campaign camp = new Campaign(Name='testcampaign',Program_Name__c='test',Status='Planned',Region__c='Global',Fiscal_Year__c='2016',Quarter__c='Q3',StartDate=date.today(),EndDate=date.today()+1,CurrencyIsoCode='USD');                                                                    
        insert camp;
        Contact con = new Contact(AccountId=ac.Id,LastName='test');
        con.Campaign_Channel_Attribution__c=camp.Id+';27/10/2016;Facebook';
        con.Most_Recent_Campaign_ID__c=camp.id;
        insert con;
        Lead ld=new Lead(LastName ='test',Company='testcom',Status='Closed',CurrencyIsoCode='USD');
        ld.Campaign_Channel_Attribution__c=camp.Id+';27/10/2016;Facebook';
        ld.Most_Recent_Campaign_ID__c=camp.Id;
        insert ld;
        
        Test.StartTest();
        CampaignMember cm=new CampaignMember(ContactId=con.Id,CampaignId=camp.Id,Status='Responded');
        insert cm;
        CampaignMember cm1=new CampaignMember(LeadId=ld.Id,CampaignId=camp.Id,Status='Responded');
        insert cm1;
        Test.StopTest();
    }
    
    static testmethod void AddcampaignMembers10(){
        Account ac = new Account(Name='test',BillingCountry='US');
        insert ac;
        Campaign camp = new Campaign(Name='testcampaign',Program_Name__c='test',Status='Planned',Region__c='Global',Fiscal_Year__c='2016',Quarter__c='Q3',StartDate=date.today(),EndDate=date.today()+1,CurrencyIsoCode='USD');                                                                    
        insert camp;
        Contact con = new Contact(AccountId=ac.Id,LastName='test');
        con.Campaign_Channel_Attribution__c=camp.Id+';27/10/2016;Facebook';
        con.Most_Recent_Campaign_ID__c=camp.id;
        insert con;
        Lead ld=new Lead(LastName ='test',Company='testcom',Status='Closed',CurrencyIsoCode='USD');
        ld.Campaign_Channel_Attribution__c=camp.Id+';27/10/2016;Facebook';
        ld.Most_Recent_Campaign_ID__c=camp.Id;
        insert ld;
        CampaignMember cm=new CampaignMember(ContactId=con.Id,CampaignId=camp.Id,Status='Sent');
        insert cm;
        CampaignMember cm1=new CampaignMember(LeadId=ld.Id,CampaignId=camp.Id,Status='Sent');
        insert cm1;
        
        Test.StartTest();
        cm.Status = 'Responded';
        cm1.Status = 'Responded';
        
        List<CampaignMember> cms = new List<CampaignMember>();
        cms.add(cm);
        cms.add(cm1);
        
        update cms;
        Test.StopTest();
    }
    
    static testmethod void AddcampaignMembers11(){
        
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
        camp.Event_Cap_Qualified__c = true;
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
        
        Account ac = new Account(Name='test',BillingCountry='US');
        insert ac;
        
        Contact con1 = new Contact(
            AccountId=ac.Id,
            LastName='test1',
            Contact_Source_Most_Recent__c = 'Facebook',
            Most_Recent_Campaign_ID__c=camp.id
        );
        
        Contact con2 = new Contact(
            AccountId=ac.Id,
            LastName='test2',
            Campaign_Channel_Attribution__c = camp.Id+';27/10/2016;Facebook',
            Most_Recent_Campaign_ID__c=camp.id
        );
        
        insert new List<Contact> { con1, con2 };
        
        CampaignMember cm3 = new CampaignMember(
            ContactId = con1.Id,
            CampaignId = camp.Id,
            Status = 'Responded'
        );
        
        CampaignMember cm4 = new CampaignMember(
            ContactId = con2.Id,
            CampaignId = camp.Id,
            Status = 'Responded'
        );
        Test.startTest();
        insert new List<CampaignMember>{cm1, cm2, cm3, cm4};
        Test.stopTest();
    }


}