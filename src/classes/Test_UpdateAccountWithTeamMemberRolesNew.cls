@isTest
public class Test_UpdateAccountWithTeamMemberRolesNew{
    static testmethod void AddAccountTeamMembers(){
        Account a = new Account(name='TestAccountt',phone='9876543201',CurrencyIsoCode='USD' );
        insert a;
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(alias = 'al', email='standarduser123@gmail.com', 
            emailencodingkey='UTF-8', lastname='lname', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
            username='standarduser11@testgmail.com');
        insert u;
        User u2 = new User(alias = 'alll', email='standarduserl123@gmail.com', 
            emailencodingkey='UTF-8', lastname='lllname', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
            username='standarduser1l1@testgmail.com');
        insert u2;        
        AccountTeamMember atm = new AccountTeamMember(accountId= a.id,TeamMemberRole='Client Services Representative',UserId=u.id  );
        insert atm; 
        AccountTeamMember atm2 = new AccountTeamMember(accountId= a.id,TeamMemberRole='Alteryx Executive Sponsor',UserId=u2.id  );
        insert atm2;        
                
        Account b = new Account(name='TestoldAccountt',Client_Services_Rep_Email__c = 'abc@xyz.com',Client_Services_Rep_Phone__c='9876543211',phone='9876543201',CurrencyIsoCode='USD' );
        insert b;
        User u1 = new User(alias = 'all', email='standarduser1233@gmail.com', 
            emailencodingkey='UTF-8', lastname='llname', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
            username='standarduser112@testgmail.com');
        insert u1;
        AccountTeamMember atm3 = new AccountTeamMember(accountId= b.id,TeamMemberRole='Lead Development Representative',UserId=u1.id);
        insert atm3;

        Account c = new Account(name='TestnewAccountt',phone='98786543201',CurrencyIsoCode='USD' );
        insert c;
        User u3 = new User(alias = 'akll', email='standarduser11233@gmail.com', 
            emailencodingkey='UTF-8', lastname='lklname', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
            username='standarduser1112@testgmail.com');
        insert u3;
        AccountTeamMember atm4 = new AccountTeamMember(accountId= c.id,TeamMemberRole='Client Services Representative',UserId=u1.id);
        insert atm4;
        AccountTeamMember atm5 = new AccountTeamMember(accountId= c.id,TeamMemberRole='Alteryx Executive Sponsor',UserId=u2.id);
        insert atm5;
        AccountTeamMember atm6 = new AccountTeamMember(accountId= c.id,TeamMemberRole='Solutions Engineer',UserId=u3.id);
        insert atm6;
        
        Account d = new Account(name='TestnewoneAccount1',phone='9878643201',Solutions_Engineer_Email__c='abc@xyz.com',Executive_Sponsor_Email__c='new@gmail.com',CurrencyIsoCode='USD' );
        insert d;
        AccountTeamMember atm7 = new AccountTeamMember(accountId= d.id,TeamMemberRole='Client Services Representative',UserId=u1.id);
        insert atm7;
        
        Account e = new Account(name='TestnewoneAccount2',Client_Services_Rep_Email__c='abc@xyz.com',phone='9886543201',CurrencyIsoCode='USD' );
        insert e;
        AccountTeamMember atm8 = new AccountTeamMember(accountId= e.id,TeamMemberRole='Alteryx Executive Sponsor',UserId=u2.id);
        insert atm8;
        
        Account f = new Account(name='TestnewoneAccount3',phone='987843201',CurrencyIsoCode='USD' );
        insert f;
        AccountTeamMember atm9 = new AccountTeamMember(accountId= f.id,TeamMemberRole='Solutions Engineer',UserId=u3.id);
        insert atm9;
            
        Account g = new Account(name='TestnewAccountt1',Solutions_Engineer_Email__c ='abc@xyz.com',Executive_Sponsor_Email__c='abc@xyz.com',Client_Services_Rep_Email__c='standarduser11112@testgmail.com',phone='98786543201',CurrencyIsoCode='USD' );
        insert g;
        User u4 = new User(alias = 'akllkk', email='standarduser121233@gmail.com', 
            emailencodingkey='UTF-8', lastname='lklname', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
            username='standarduser11112@testgmail.com');
        insert u4;
        AccountTeamMember atm10 = new AccountTeamMember(accountId= g.id,TeamMemberRole='Client Services Representative',UserId=u4.id);
        insert atm10;
        
        Account h = new Account(name='TestnewAccountt2',Client_Services_Rep_Email__c='abc@xyz.com',Executive_Sponsor_Email__c='standarduser121112@testgmail.com',phone='98786543201',CurrencyIsoCode='USD' );
        insert h;
        User u5 = new User(alias = 'aklli', email='standarduser131233@gmail.com', 
            emailencodingkey='UTF-8', lastname='lklname', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
            username='standarduser121112@testgmail.com');
        insert u5;
        AccountTeamMember atm11 = new AccountTeamMember(accountId= h.id,TeamMemberRole='Alteryx Executive Sponsor',UserId=u5.id);
        insert atm11;
        
        Account i = new Account(name='TestnewAccountt3', phone='98786543201',CurrencyIsoCode='USD' );
        insert i;
        User u6 = new User(alias = 'akllh', email='standarduser114233@gmail.com', 
            emailencodingkey='UTF-8', lastname='lklname', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
            username='standarduser1212112@testgmail.com');
        insert u6;
        User u7 = new User(alias = 'aklllh', email='standarduser1l14233@gmail.com', 
            emailencodingkey='UTF-8', lastname='lklname', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', 
            username='standarduser12l12112@testgmail.com');
        insert u7;
        AccountTeamMember atm12 = new AccountTeamMember(accountId= i.id,TeamMemberRole='Solutions Engineer',UserId=u6.id);
        insert atm12;  
        AccountTeamMember atm13 = new AccountTeamMember(accountId= i.id,TeamMemberRole='Client Services Representative',UserId=u7.id);
        insert atm13;      
        
       Test.startTest(); 
       UpdateAccountWithTeamMemberRolesNew obj = new UpdateAccountWithTeamMemberRolesNew();
       Database.ExecuteBatch(obj);
       Test.stopTest();
    }
}