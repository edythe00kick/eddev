/**
    Author: Sergio Flores
    Date: 08/28/2019
    W-012864

    Testing the following scenarios in this knowledge article Individual Object Functionality
    https://alteryx.my.salesforce.com/kAG2R000000KyuE 
*/

@isTest
public class ContactQueueableTest {


    //Testing Scenario #1
    static testMethod void testNoIndividualFound()
    { 
        Account acc = OrgWideTestUtil.createAccount(true);
        List<Contact> bulkContactListToInsert = new List<Contact>();
        Map<String, Contact> contactEmailToContact = new Map<String, Contact>();

        //Create Bulk Contacts
        for(integer i=0; i < 100; i++)
        {
            Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
            cont.Email = 'testindividual' + i + '@gmail.com';
            cont.HasOptedOutOfEmail = true;
            contactEmailToContact.put(cont.Email, cont);
            bulkContactListToInsert.add(cont); 
        } 

        if(!bulkContactListToInsert.isEmpty()) 
        {
            insert bulkContactListToInsert; 
        }

        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert);
        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert.size());

        
        test.StartTest();
        test.StopTest();
        //Query for newly created individuals
        System.debug('contactEmailToContact ' + contactEmailToContact.keySet());
        List<Individual> individualList = [Select Id, Email__c, HasOptedOutOfEmail__c, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
        From Individual Where Email__c IN : contactEmailToContact.keySet()];

        System.assertEquals(100, individualList.size());

        

        
    }

    //Testing Scenario #2
    static testMethod void testIndividualFound()
    {
        //Create Individual
        Individual individual = new Individual();
        individual.Email__c = 'testindividual123@gmail.com';
        individual.Communication_Opt_In__c = false;
        individual.Double_Email_Opt_In__c = false;
        individual.Email_Opt_In__c = true;
        individual.Safe_to_Send__c = 'Yes';
        individual.LastName = 'TestLastName';
        individual.FirstName = 'TestFirstName';

        insert individual;

        Account acc = OrgWideTestUtil.createAccount(true);
        List<Contact> bulkContactListToInsert = new List<Contact>();
        Map<String, Contact> contactEmailToContact = new Map<String, Contact>();

        //Create contact matching invidiual email
        Contact con = new Contact();
        con.FirstName = 'OWTU';
        con.LastName = 'Contact';
        con.Email = 'testindividual123@gmail.com';
        con.AccountId = acc.Id;
        con.MailingCity = 'Los Angeles';
        con.MailingCountry = 'United States';
        con.MailingState = 'California';
        con.MailingStreet = 'test';
        con.MailingPostalCode = '90001';

        bulkContactListToInsert.add(con);


        //Create Bulk Contacts
        for(integer i=0; i < 100; i++)
        {
            Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
            cont.Email = 'testindividual5' + i + '@gmail.com';
            cont.HasOptedOutOfEmail = true;
            contactEmailToContact.put(cont.Email, cont);
            bulkContactListToInsert.add(cont); 
        } 

        if(!bulkContactListToInsert.isEmpty()) 
        {
            insert bulkContactListToInsert; 
        }

        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert);
        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert.size());

        test.StartTest();
        test.StopTest();
        
        //Query for newly created individuals
        System.debug('contactEmailToContact ' + contactEmailToContact.keySet());
        List<Individual> individualList = [Select Id, Email__c, HasOptedOutOfEmail__c, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
        From Individual Where Email__c IN : contactEmailToContact.keySet() OR Email__c =: con.Email];

        System.assertEquals(101, individualList.size());

        




    }
    
    //Testing Scenario #3
    static testMethod void testEmailChangeNoIndividualFound()
    {
        List<Contact> bulkContactListToInsert = new List<Contact>();

        Account acc = OrgWideTestUtil.createAccount(true);

        //Create contact matching invidiual email 
        Contact con = new Contact();
        con.FirstName = 'OWTU';
        con.LastName = 'Contact';
        con.Email = 'testindividual123@gmail.com';
        con.AccountId = acc.Id;
        con.MailingCity = 'Los Angeles';
        con.MailingCountry = 'United States';
        con.MailingState = 'California';
        con.MailingStreet = 'test';
        con.MailingPostalCode = '90001';

        bulkContactListToInsert.add(con);

        //Create Bulk Contacts
        for(integer i=0; i < 100; i++)
        {
            Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
            cont.Email = 'testindividual5' + i + '@gmail.com';
            cont.HasOptedOutOfEmail = true;
            bulkContactListToInsert.add(cont); 
        } 

        if(!bulkContactListToInsert.isEmpty()) 
        {
            insert bulkContactListToInsert; 
        }

        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert);
        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert.size());
        
        test.StartTest();
        RecursionHandler.IsContactTriggerExecuted = false;
        RecursionHandler.IsContactTriggerInserted = false;
        Contact c = [Select Id, Email From Contact Where Email = 'testindividual123@gmail.com'];
        System.debug('contactToUpdate ' + c);
        c.Email = 'newEmail@gmail.com';
        update c;
        

        test.StopTest();

        
        
        //Query for newly created individuals
        List<Individual> individualList = [Select Id, Email__c, HasOptedOutOfEmail__c, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
        From Individual];

        System.assertEquals(102, individualList.size());
        
    }

    //Testing Scenario #4
    static testMethod void testEmailChangedIndividualFound()
    {
        //Create Individual
        Individual individual = new Individual();
        individual.Email__c = 'testindividual777@gmail.com';
        individual.Communication_Opt_In__c = false;
        individual.Double_Email_Opt_In__c = false;
        individual.Email_Opt_In__c = true;
        individual.Safe_to_Send__c = 'Yes';
        individual.LastName = 'TestLastName';
        individual.FirstName = 'TestFirstName';

        insert individual;

        List<Contact> bulkContactListToInsert = new List<Contact>();

        Account acc = OrgWideTestUtil.createAccount(true);

        //Create contact matching invidiual email
        Contact con = new Contact();
        con.FirstName = 'OWTU';
        con.LastName = 'Contact';
        con.Email = 'testindividual123@gmail.com';
        con.AccountId = acc.Id;
        con.MailingCity = 'Los Angeles';
        con.MailingCountry = 'United States';
        con.MailingState = 'California';
        con.MailingStreet = 'test';
        con.MailingPostalCode = '90001';

        bulkContactListToInsert.add(con); 


        //Create Bulk Contacts
        for(integer i=0; i < 1; i++)
        {
            Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
            cont.Email = 'testindividual5' + i + '@gmail.com';
            cont.HasOptedOutOfEmail = true;
            bulkContactListToInsert.add(cont); 
        } 

        if(!bulkContactListToInsert.isEmpty()) 
        {
            insert bulkContactListToInsert; 
        }

        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert);
        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert.size());
        
        test.StartTest();
        RecursionHandler.IsContactTriggerExecuted = false;
        RecursionHandler.IsContactTriggerInserted = false;
        Contact c = [Select Id, Email From Contact Where Email = 'testindividual123@gmail.com'];
        System.debug('contactToUpdate ' + c);
        c.Email = 'testindividual777@gmail.com';
        update c;
        

        test.StopTest();

        
        
        //Query for newly created individuals
        List<Individual> individualList = [Select Id, Email__c, HasOptedOutOfEmail__c, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
        From Individual];

        System.assertEquals(3, individualList.size());
    }

    //Testing Scenario #5
    static testMethod void testOptFieldsUpdatedNoIndividualFound()
    {

        //This scenario is a little bit tricky, we will need to create contact
        //find individual and delete it, then update the contact again so new individual is created

        List<Contact> bulkContactListToInsert = new List<Contact>();

        Account acc = OrgWideTestUtil.createAccount(true);

        //Create contact matching invidiual email
        Contact con = new Contact();
        con.FirstName = 'OWTU';
        con.LastName = 'Contact';
        con.Email = 'testindividual123@gmail.com';
        con.AccountId = acc.Id;
        con.MailingCity = 'Los Angeles';
        con.MailingCountry = 'United States';
        con.MailingState = 'California';
        con.MailingStreet = 'test';
        con.MailingPostalCode = '90001';

        bulkContactListToInsert.add(con); 


        //Create Bulk Contacts
        for(integer i=0; i < 100; i++)
        {
            Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
            cont.Email = 'testindividual5' + i + '@gmail.com';
            cont.HasOptedOutOfEmail = true;
            bulkContactListToInsert.add(cont); 
        } 

        if(!bulkContactListToInsert.isEmpty()) 
        {
            insert bulkContactListToInsert; 
        }

        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert);
        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert.size());

        List<Individual> individualToDelete = [Select Id From Individual Where Email__c =: 'testindividual123@gmail.com'];
        if(!individualToDelete.isEmpty())
        delete individualToDelete;

        test.StartTest();

        RecursionHandler.IsContactTriggerExecuted = false;
        RecursionHandler.IsContactTriggerInserted = false;
        Contact c = [Select Id, Email From Contact Where Email = 'testindividual123@gmail.com'];
        System.debug('contactToUpdate ' + c);
        c.HasOptedOutOfEmail = false;
        update c;
        

        test.StopTest();

        //Query for newly created individuals
        List<Individual> individualList = [Select Id, Email__c, HasOptedOutOfEmail__c, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
        From Individual];

        System.assertEquals(101, individualList.size());
    }

    //Testing Scenario #6
    static testMethod void testOptFieldsUpdatedIndividualFound()
    {
        List<Contact> bulkContactListToInsert = new List<Contact>();

        Account acc = OrgWideTestUtil.createAccount(true);

        //Create contact matching invidiual email
        Contact con = new Contact();
        con.FirstName = 'OWTU';
        con.LastName = 'Contact';
        con.Email = 'testindividual123@gmail.com';
        con.AccountId = acc.Id;
        con.MailingCity = 'Los Angeles';
        con.MailingCountry = 'United States';
        con.MailingState = 'California';
        con.MailingStreet = 'test';
        con.MailingPostalCode = '90001';

        bulkContactListToInsert.add(con); 


        //Create Bulk Contacts
        for(integer i=0; i < 1; i++)
        {
            Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
            cont.Email = 'testindividual5' + i + '@gmail.com';
            cont.HasOptedOutOfEmail = true;
            bulkContactListToInsert.add(cont); 
        } 

        if(!bulkContactListToInsert.isEmpty()) 
        {
            insert bulkContactListToInsert; 
        }

        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert);
        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert.size());

        

        test.StartTest();

        List<AsyncApexJob> jobInfo1 = [SELECT Id, Status, MethodName, ApexClass.Name FROM AsyncApexJob Where ApexClass.Name = 'ContactQueueable'];
        System.debug('jobInfo1 ' + jobInfo1);

        RecursionHandler.IsContactTriggerExecuted = false;
        RecursionHandler.IsContactTriggerInserted = false;
        Contact c = [Select Id, Email From Contact Where Email = 'testindividual123@gmail.com'];
        System.debug('contactToUpdate ' + c);
        c.HasOptedOutOfEmail = true;
        c.Safe_to_Send__c = 'No';
        update c;
        

        test.StopTest();

        List<AsyncApexJob> jobInfo2 = [SELECT Id, Status, MethodName, ApexClass.Name FROM AsyncApexJob Where ApexClass.Name = 'ContactQueueable'];
        System.debug('jobInfo2 ' + jobInfo2);

        //Query for newly created individuals
        List<Individual> individualList = [Select Id, Email__c, HasOptedOutOfEmail__c, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
        From Individual];

        System.assertEquals(2, individualList.size());
        System.debug('total individuals ' + individualList);

        List<Contact> contacts = [Select Id, Email, Safe_to_Send__c From Contact];

        System.debug('total contacts ' + contacts);
        System.assertEquals(2, contacts.size());

        Contact optedInContact = [Select Safe_to_Send__c From Contact Where Email =: 'testindividual123@gmail.com'];
        System.assertEquals('No', optedInContact.Safe_to_Send__c);

        
    }

    //Testing Scenario #7
    static testMethod void testUpdateDuplicates()
    {
        List<Contact> bulkContactListToInsert = new List<Contact>();

        Account acc = OrgWideTestUtil.createAccount(true);

        //Create contact matching invidiual email
        Contact con = new Contact();
        con.FirstName = 'OWTU';
        con.LastName = 'Contact';
        con.Email = 'testindividual123@gmail.com';
        con.AccountId = acc.Id;
        con.MailingCity = 'Los Angeles';
        con.MailingCountry = 'United States';
        con.MailingState = 'California';
        con.MailingStreet = 'test';
        con.MailingPostalCode = '90001';

        Contact con2 = new Contact();
        con2.FirstName = 'OWTU';
        con2.LastName = 'Contact';
        con2.Email = 'testindividual123@gmail.com';
        con2.AccountId = acc.Id;
        con2.MailingCity = 'Los Angeles';
        con2.MailingCountry = 'United States';
        con2.MailingState = 'California';
        con2.MailingStreet = 'test';
        con2.MailingPostalCode = '90001';

        bulkContactListToInsert.add(con);
        bulkContactListToInsert.add(con2); 


        //Create Bulk Contacts
        for(integer i=0; i < 100; i++)
        {
            Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
            cont.Email = 'testindividual5' + i + '@gmail.com';
            cont.HasOptedOutOfEmail = true;
            bulkContactListToInsert.add(cont); 
        } 

        if(!bulkContactListToInsert.isEmpty()) 
        {
            insert bulkContactListToInsert; 
        }

        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert);
        System.debug('testNoIndividualFound bulkContactListToInsert' + bulkContactListToInsert.size());



        test.StartTest();

        List<AsyncApexJob> jobInfo1 = [SELECT Id, Status, MethodName, ApexClass.Name FROM AsyncApexJob Where ApexClass.Name = 'ContactQueueable'];
        System.debug('jobInfo1 ' + jobInfo1);

        RecursionHandler.IsContactTriggerExecuted = false;
        RecursionHandler.IsContactTriggerInserted = false;
        Contact c = [Select Id, Email From Contact Where Email = 'testindividual123@gmail.com' limit 1];
        System.debug('contactToUpdate ' + c);
        c.HasOptedOutOfEmail = true;
        update c;
        

        test.StopTest();

        List<AsyncApexJob> jobInfo2 = [SELECT Id, Status, MethodName, ApexClass.Name FROM AsyncApexJob Where ApexClass.Name = 'ContactQueueable'];
        System.debug('jobInfo2 ' + jobInfo2);

        //Query for newly created individuals
        List<Individual> individualList = [Select Id, Email__c, HasOptedOutOfEmail__c, Communication_Opt_In__c, Double_Email_Opt_In__c, Email_Opt_In__c, Safe_to_Send__c
        From Individual];

        System.assertEquals(101, individualList.size());
        System.debug('total individuals ' + individualList);

        List<Contact> contacts = [Select Id, Email, Safe_to_Send__c From Contact];

        System.debug('total contacts ' + contacts);
        System.assertEquals(102, contacts.size());

        List<Contact> optedInContact = [Select Safe_to_Send__c From Contact Where Email =: 'testindividual123@gmail.com'];
        for(Contact contact : optedInContact)
        {
            System.assertEquals('No', contact.Safe_to_Send__c);
        }
        
        
    }

}