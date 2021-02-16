@isTest
public class Test_CreateAccountTeamMembersTrigger{
/*    static testmethod void AddAccountTeamMembers(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(alias = 'al', email='standarduser123@gmail.com', 
        emailencodingkey='UTF-8', lastname='lname', 
        languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', Do_Not_Assign_Accounts__c = FALSE,
        username='standarduser11@testgmail.com',Sales_Region__c='Eastt', Sales_Territory__c='Expand 77',Sales_Team__c = 'Commercial Expand Representative' );
        insert u;
        User u2 = new User(alias = 'alll', email='standarduserl123@gmail.com', 
            emailencodingkey='UTF-8', lastname='lllname', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', Do_Not_Assign_Accounts__c = FALSE,
            username='standarduser1l1@testgmail.com',Sales_Region__c='Eastt', Sales_Territory__c='Expand 77',Sales_Team__c = 'Commercial Expand Representative' );
        insert u2;
        
        
        
        pw_ccpro__ZipCode__c zc = new pw_ccpro__ZipCode__c(pw_ccpro__State__c='a4dE0000000GoJlIAK',Name = '12301',pw_ccpro__City__c='Ny City', Zip_Code_Sales_Territory__c ='Eastt', Zip_Code_Sales_Region__c='Expand 77');
        insert zc; 
        Account a;
        system.runas(u){
            a = new Account(annualrevenue=12345,name='TestAccountt',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
            insert a;
            Account b= new Account(annualrevenue=12345,name='TestAcct',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
            insert b;
        }
        Opportunity rec = new Opportunity(type='NB',AccountId=a.id,Name='Goppp', CloseDate=system.today(), StageName= System.label.StageName_B,currencyisocode='USD'  );
        insert rec;
        rec.stagename = System.label.StageName_D;
        update rec;
        Test.stopTest();
    }
    static testmethod void AddAccountTeamMembers1(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(alias = 'al', email='standarduser123@gmail.com', 
        emailencodingkey='UTF-8', lastname='lname', 
        languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', Do_Not_Assign_Accounts__c = FALSE,
        username='standarduser11@testgmail.com',Sales_Region__c='Eastt', Sales_Territory__c='Expand 77',Sales_Team__c = 'Commercial Expand Representative' );
        insert u;       

        pw_ccpro__ZipCode__c zc = new pw_ccpro__ZipCode__c(pw_ccpro__State__c='a4dE0000000GoJlIAK',Name = '12301',pw_ccpro__City__c='Ny City', Zip_Code_Sales_Territory__c ='Eastt', Zip_Code_Sales_Region__c='Expand 77');
        insert zc; 
        Account a;
        system.runas(u){
            a = new Account(annualrevenue=12345,name='TestAccountt',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
            insert a;
            Account b= new Account(annualrevenue=12345,name='TestAcct',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
            insert b;
        }
        Opportunity rec = new Opportunity(type='NB',AccountId=a.id,Name='Goppp', CloseDate=system.today(), StageName='System.label.StageName_B',currencyisocode='USD'  );
        insert rec;
        rec.stagename = System.label.StageName_D;
        update rec;
        Test.stopTest();
    }
    static testmethod void AddAccountTeamMembers2(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(alias = 'al', email='standarduser123@gmail.com', 
        emailencodingkey='UTF-8', lastname='lname', 
        languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', Do_Not_Assign_Accounts__c = FALSE,
        username='standarduser11@testgmail.com',Sales_Region__c='Eastt', Sales_Territory__c='Expand 77',Sales_Team__c = 'Commercial Expand Representative' );
        insert u;       

        //pw_ccpro__ZipCode__c zc = new pw_ccpro__ZipCode__c(pw_ccpro__State__c='a4dE0000000GoJlIAK',Name = '12301',pw_ccpro__City__c='Ny City', Zip_Code_Sales_Territory__c ='Eastt', Zip_Code_Sales_Region__c='Expand 77');
        //insert zc; 
        Account a;
        system.runas(u){
            a = new Account(annualrevenue=12345,name='TestAccountt',billingcity='Ny City',billingpostalcode='123801',phone='9876543201',CurrencyIsoCode='USD' );
            insert a;
        }
        Opportunity rec = new Opportunity(type='NB',AccountId=a.id,Name='Goppp', CloseDate=system.today(), StageName='System.label.StageName_B',currencyisocode='USD'  );
        insert rec;
        rec.stagename = System.label.StageName_D;
        update rec;
        OpportunityHandler ah = new OpportunityHandler();
        Sobject s =(Sobject)rec;
        ah.beforeDelete(s);
        ah.afterinsert(s);
        ah.afterdelete(s);
        Test.stopTest();
    }
    
    static testmethod void AddAccountTeamMembers3(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(alias = 'al', email='standarduser1236@gmail.com', 
        emailencodingkey='UTF-8', lastname='lnname', 
        languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', Do_Not_Assign_Accounts__c = FALSE,
        username='standarduser141@testgmail.com',Sales_Region__c='Eastt', Sales_Territory__c='Expand 777',Sales_Team__c = 'Commercial Expand Representative' );
        insert u;
        User u2 = new User(alias = 'alll', email='standarduserl1273@gmail.com', 
            emailencodingkey='UTF-8', lastname='lllname', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', Do_Not_Assign_Accounts__c = FALSE,
            username='standarduser17l1@testgmail.com',Sales_Region__c='Eastt', Sales_Territory__c='Expand 77',Sales_Team__c = 'Commercial Expand Representative' );
        insert u2;
        pw_ccpro__ZipCode__c zc = new pw_ccpro__ZipCode__c(pw_ccpro__State__c='a4dE0000000GoJlIAK',Name = '12301',pw_ccpro__City__c='Ny City', Zip_Code_Sales_Territory__c ='Eastt', Zip_Code_Sales_Region__c='Expand 77');
        insert zc; 
        Account a;
        system.runas(u){
            a = new Account(annualrevenue=12345,name='TestAccountt',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
            insert a;
            Account b= new Account(annualrevenue=12345,name='TestAcct',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
            insert b;
        }
        Opportunity rec = new Opportunity(type='NB',AccountId=a.id,Name='Goppp', CloseDate=system.today(), StageName='System.label.StageName_B',currencyisocode='USD'  );
        insert rec;
        rec.stagename = System.label.StageName_D;
        update rec;
        Test.stopTest();
    }
    
    static testmethod void AddAccountTeamMembers4(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(alias = 'al', email='standarduser1236@gmail.com', 
        emailencodingkey='UTF-8', lastname='lnname', 
        languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', Do_Not_Assign_Accounts__c = FALSE,
        username='standarduser141@testgmail.com',Sales_Region__c='Eastt', Sales_Territory__c='Expand 77',Sales_Team__c = 'Commercial Expand Representative' );
        insert u;
        User u2 = new User(alias = 'alll', email='standarduserl1273@gmail.com', 
            emailencodingkey='UTF-8', lastname='lllname', 
            languagelocalekey='en_US', 
            localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', Do_Not_Assign_Accounts__c = FALSE,
            username='standarduser17l1@testgmail.com',Sales_Region__c='Eastt', Sales_Territory__c='Expand 77',Sales_Team__c = 'Commercial Expand Representative' );
        insert u2;
        pw_ccpro__ZipCode__c zc = new pw_ccpro__ZipCode__c(pw_ccpro__State__c='a4dE0000000GoJlIAK',Name = '12301',pw_ccpro__City__c='Ny City', Zip_Code_Sales_Territory__c ='Eastt', Zip_Code_Sales_Region__c='Expand 77');
        insert zc; 
        Account a;
        system.runas(u){
            a = new Account(annualrevenue=12345,name='TestAccountt',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
            insert a;  
        }
        //Account b= new Account(annualrevenue=12345,name='TestAcct',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
        //insert b;
        system.runas(u2){
            Account b= new Account(annualrevenue=12345,name='TestAcct',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
            insert b;
            Account c= new Account(annualrevenue=12345,name='TestAcctt',billingcity='Ny City',billingpostalcode='123701',phone='98765043201',CurrencyIsoCode='USD' );
            insert c;
        }
        Opportunity rec = new Opportunity(type='NB',AccountId=a.id,Name='Goppp', CloseDate=system.today(), StageName='System.label.StageName_B',currencyisocode='USD'  );
        insert rec;
        rec.stagename = System.label.StageName_D;
        update rec;
        Test.stopTest();
    }*/
    
    
    //Date: 9-10 Sergio Flores
    // * Commenting out AddAccountTeamMembers 1-3 since the code to test is in OpportunityGateway
    // * has been commented out and is no longer being used.  
     static testmethod void AddAccountTeamMembers1(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        //Date 9-10 Sergio Flores
        //Updating code coverage by making territory metadata fields dynamic to User object
        //Grab the metadata fields here
        Territory_Mapping__mdt[] territoryMappingMetaData = [SELECT DeveloperName, MasterLabel, NamespacePrefix, Account_Field__c, Lead_Field__c, User_Field__c 
                                                             From Territory_Mapping__mdt]; 
         
        User u = new User(alias = 'al', email='standarduser123@gmail.com', 
        emailencodingkey='UTF-8', lastname='lname', 
        languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', Do_Not_Assign_Accounts__c = FALSE,
        username='standarduser11@testgmail.com');
         
        //Check to see the developername and assign the field to correct variable
        for(Territory_Mapping__mdt territoryMapping : territoryMappingMetaData)
        {
            /*if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'Public Sector');*/
            if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'ANZ');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u.put(territoryMapping.User_Field__c, 'APAC');
        }
         
        insert u;        
        Account a;
        system.runas(u){
            a = new Account(annualrevenue=12345,name='TestAccountt',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
            insert a;
            Opportunity rec = new Opportunity(type='NB',AccountId=a.id,Name='Goppp', CloseDate=system.today(), StageName= System.label.StageName_B,currencyisocode='USD'  );
            
            //rec.stagename = '1 - Business Case/Proposal';
            //update rec;
            insert rec;
            OpportunityHandler ah = new OpportunityHandler();
            Sobject s =(Sobject)rec;
            /*ah.beforeDelete(s);
            ah.afterdelete(s);*/
        }
        Test.stopTest();
    }
    
    //This test method covers validateOpportunity method
    static testmethod void AddAccountTeamMembers2(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        //Updating code coverage by making territory metadata fields dynamic to User object
        //Grab the metadata fields here
        Territory_Mapping__mdt[] territoryMappingMetaData = [SELECT DeveloperName, MasterLabel, NamespacePrefix, Account_Field__c, Lead_Field__c, User_Field__c 
                                                             From Territory_Mapping__mdt]; 
        
        User u = new User(alias = 'al', email='standarduser123@gmail.com', 
        emailencodingkey='UTF-8', lastname='lname', 
        languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', Do_Not_Assign_Accounts__c = FALSE,
        username='standarduser11@testgmail.com');
        
        //Check to see the developername and assign the field to correct variable
        for(Territory_Mapping__mdt territoryMapping : territoryMappingMetaData)
        {
            /*if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'Public Sector');*/
            if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'ANZ');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u.put(territoryMapping.User_Field__c, 'APAC');
        }
        
        insert u;        
        Account a;
        system.runas(u){
            a = new Account(annualrevenue=12345,name='TestAccountt',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
            insert a;
            Contact c = new Contact(FirstName='Rock',LastName='Rsajj Sharma',email='ragjjs@alteryx.com', phone='9999999999',CurrencyIsoCode='USD', AccountId=a.id);
            insert c;
            Opportunity rec = new Opportunity(Partner_Account_Name__c ='test',type='NB',AccountId=a.id,Name='Goppp', CloseDate=system.today(),currencyisocode='USD'  );
            rec.stagename = System.label.StageName_D;
            insert rec;
            OpportunityContactRole ocr = new OpportunityContactRole(isprimary=true,opportunityid=rec.id,contactid=c.id,Role='Partner Technical Reprsentative');
            insert ocr;
            update rec;
        }
        Test.stopTest();
    }
    
    //This test method covers createOppTeamMember and validateOpportunity methods
    static testmethod void AddAccountTeamMembers3(){
        Test.startTest();
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        //Updating code coverage by making territory metadata fields dynamic to User object
        //Grab the metadata fields here
        Territory_Mapping__mdt[] territoryMappingMetaData = [SELECT DeveloperName, MasterLabel, NamespacePrefix, Account_Field__c, Lead_Field__c, User_Field__c 
                                                             From Territory_Mapping__mdt]; 
        
        User u = new User(alias = 'al', email='standarduser123@gmail.com', 
        emailencodingkey='UTF-8', lastname='lname', 
        languagelocalekey='en_US', 
        localesidkey='en_US', profileid = p.Id, timezonesidkey='America/Los_Angeles', Do_Not_Assign_Accounts__c = FALSE,
        username='standarduser11@testgmail.com');
        
        //Check to see the developername and assign the field to correct variable
        for(Territory_Mapping__mdt territoryMapping : territoryMappingMetaData)
        {
            /*if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'Public Sector');*/
            if(territoryMapping.DeveloperName == 'Sales_Team')
                u.put(territoryMapping.User_Field__c, 'ANZ');
            if(territoryMapping.DeveloperName == 'Sales_Region')
                u.put(territoryMapping.User_Field__c, 'APAC');
        }
        
        insert u;        
        Account a;
        system.runas(u){
            a = new Account(annualrevenue=12345,name='TestAccountt',billingcity='Ny City',billingpostalcode='12301',phone='9876543201',CurrencyIsoCode='USD' );
            insert a;
            Contact c = new Contact(FirstName='Rock',LastName='Rsajj Sharma',email='ragjjs@alteryx.com', phone='8888888888',CurrencyIsoCode='USD', AccountId=a.id);
            insert c;
            Opportunity rec = new Opportunity(Partner_Account_Name__c ='test',type='NB',AccountId=a.id,Name='Goppp', CloseDate=system.today(),currencyisocode='USD'  );
            rec.stagename = System.label.StageName_D;
            insert rec;
            rec.pricebook2id=null;
            OpportunityContactRole ocr = new OpportunityContactRole(isprimary=true,opportunityid=rec.id,contactid=c.id,Role='Partner Technical Representative');
            insert ocr;
            update rec;
        }
        Test.stopTest();
        
    }
    
    // Create Account
    public static Account createAccount(boolean do_insert) {
        Account acc = new Account();
        acc.Name = 'OTFT Account';
        if(do_insert) {
            insert acc;
        }
        return acc;
    }
    
    // Create Contact
    public static Contact createContact(boolean do_insert, id account_id) {
        Contact con = new Contact();
        con.FirstName = 'OTFT';
        con.LastName = 'Contact';
        con.Email = 'contact@otft.com';
        con.AccountId = account_id;
        if(do_insert) {
            insert con;
        }
        return con;
    }
    
    /**
      * If Class of Business of Opportunity is either NB or NBEC,
      * fill 'Headquarter Owner' with Account's 'Business Development Owner'
      * field.
      * If Class of Business is NB, 'Headquarter Percentage Kicker' is 2%.
      * If Class of Business is NBEC, 'Headquarter Percentage Kicker' is 4%
      */
    @isTest
    public static void testScenario1() {
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
    
        Account acc = createAccount(true);
        acc.Enterprise_Expand_Geo_Owner__c = usr.Id;
        update acc;
        
        Contact con = createContact(true, acc.Id);
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'OTFT Opportunity';
        opp1.AccountId = acc.id;
        opp1.StageName = System.label.StageName_F;
        opp1.Type = 'NB';
        opp1.CloseDate = Date.today() + 2;
        insert opp1;
        
        opp1 = [SELECT Id, Headquarter_Owner__c
            , Headquarter_Percentage_Kicker__c
            FROM Opportunity WHERE Id = :opp1.Id];
        System.assert(opp1.Headquarter_Owner__c == usr.Id
            , 'Headquarter Owner should be equal to user');
        System.assert(opp1.Headquarter_Percentage_Kicker__c == 2
            , 'Headquarter Percentage should be 2');
    }
    
    @isTest
    public static void testScenario2() {
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
    
        Account acc = createAccount(true);
        acc.Type = 'Customer';
        acc.Customer_Since_Date__c = Date.today();
        acc.Enterprise_Expand_Geo_Owner__c = usr.Id;
        update acc;
        
        Contact con = createContact(true, acc.Id);
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'OTFT Opportunity';
        opp1.AccountId = acc.id;
        opp1.StageName = System.label.StageName_F;
        opp1.Type = 'NBEC';
        opp1.CloseDate = Date.today() + 2;
        insert opp1;
        
        opp1 = [SELECT Id, Headquarter_Owner__c
            , Headquarter_Percentage_Kicker__c
            FROM Opportunity WHERE Id = :opp1.Id];
        System.assert(opp1.Headquarter_Owner__c == usr.Id
            , 'Headquarter Owner should be equal to user');
        System.assert(opp1.Headquarter_Percentage_Kicker__c == 4
            , 'Headquarter Percentage should be 2');
    }
    
    @isTest
    public static void testScenario5() {
        Account acc = createAccount(true);
        acc.Type = 'Customer';
        acc.Customer_Since_Date__c = Date.today();
        update acc;
        
        Contact con = createContact(true, acc.Id);
        
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'OTFT Opportunity';
        opp1.AccountId = acc.id;
        opp1.StageName = System.label.StageName_B;
        opp1.Type = 'NBEC';
        opp1.CloseDate = Date.today() + 2;
        opp1.SAO_Contact__c = con.Id;
        insert opp1;
        
        opp1.StageName = System.label.StageName_F;
        update opp1;
        
        con = [SELECT Id, LDR_Process_Button_Visibility__c FROM Contact WHERE Id = :con.Id];
        System.assert(con.LDR_Process_Button_Visibility__c == false, '\'LDR Process Button Visibility\' field on Contact should be false');
    }
}