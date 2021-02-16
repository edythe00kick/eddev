@isTest
public class ContactTriggersTest {

     @testSetup static void setup(){
        //Insert Partner Tier Records
        List<Lead_Contact_DG_Status_Update__c> leadContactStatusCSList = new List<Lead_Contact_DG_Status_Update__c>();

        Lead_Contact_DG_Status_Update__c attemptingContact = new Lead_Contact_DG_Status_Update__c();
        attemptingContact.Name = '2 - Attempting Contact';
        attemptingContact.DG_Lead_Status__c = 'Attempting Contact';

        Lead_Contact_DG_Status_Update__c inConversation = new Lead_Contact_DG_Status_Update__c();
        inConversation.Name = '3 - In Conversation';
        inConversation.DG_Lead_Status__c = 'In Conversation';

        Lead_Contact_DG_Status_Update__c existingLicensedUser = new Lead_Contact_DG_Status_Update__c();
        existingLicensedUser.Name = 'Existing Licensed User';
        existingLicensedUser.DG_Lead_Status__c = 'Recycle - Existing Licensed User';
        
        Lead_Contact_DG_Status_Update__c noLongerWithCompany = new Lead_Contact_DG_Status_Update__c();
        noLongerWithCompany.Name = 'No Longer with Company';
        noLongerWithCompany.DG_Lead_Status__c = 'Rejected - No Longer with Company';

        leadContactStatusCSList.add(attemptingContact);
        leadContactStatusCSList.add(inConversation);
        leadContactStatusCSList.add(existingLicensedUser);
        leadContactStatusCSList.add(noLongerWithCompany);
        insert leadContactStatusCSList;
     }


    @isTest
    private static void checkCampaignChannelAttribution() {
        Test.startTest();
        Campaign c1 = new Campaign();
        c1.Name = 'UCMTFT_Test';
        c1.IsActive = true;
        c1.Status = 'Planned';
        c1.Program_Name__c = 'UCMTFT_Test';
        c1.Region__c = 'Global';
        c1.Fiscal_Year__c = '2014';
        c1.Quarter__c = 'Q1';
        c1.Campaign_Tactic__c = '3rd Party Email';
        c1.Campaign_Offer__c = 'Analyst Report';
        c1.Vendor_Sponsored__c = 'Yes';
        c1.StartDate = Date.today();
        c1.EndDate = Date.today() + 2;
        insert c1;
        
        Account acc = new Account();
        acc.Name = 'UCMTFT Account';
        insert acc;
        
        Contact con1 = new Contact(
            FirstName = 'UCMTFT',
            LastName = 'Contact1',
            Contact_Source_Most_Recent__c = 'Facebook',
            AccountId = acc.Id
        );
        
        Contact con2 = new Contact(
            FirstName = 'UCMTFT',
            LastName = 'Contact2',
            Campaign_Channel_Attribution__c = c1.Id + ';;Event',
            AccountId = acc.Id
        );
        
        insert new List<Contact> { con1, con2 };
        
        CampaignMember cm1 = new CampaignMember(
            CampaignId = c1.Id,
            ContactId = con1.Id,
            Status = 'Responded'
        );
        
        CampaignMember cm2 = new CampaignMember(
            CampaignId = c1.Id,
            ContactId = con2.Id,
            Status = 'Responded'
        );
        
        insert new List<CampaignMember> { cm1, cm2 };
        
        cm1.Lead_Source_Most_Recent__c = null;
        cm2.Lead_Source_Most_Recent__c = null;
        update new List<CampaignMember> { cm1, cm2 };
        
        con1.Contact_Source_Most_Recent__c = 'Event';
        con2.Campaign_Channel_Attribution__c = c1.Id + ';;Facebook';
        update new List<Contact> { con1, con2 };
        Test.stopTest();
    }

    //Sergio Flores
    //Date 03/04/2019
    //W-011205
    static testMethod void updateContactLeadStatus()
    {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.BillingCountry = 'United States';
        acc.BillingCity = 'Irvine';
        acc.BillingPostalCode = '92780';
        acc.BillingState = 'CA';
        insert acc;
        
        Contact cont = OrgWideTestUtil.createContact(false,acc.Id);
        cont.Contact_Status__c = '1 - Not Contacted';
        insert cont;

        Contact insertedContact = [Select Id, Contact_Status__c, DG_Lead_Status__c From Contact Where Id =: cont.id];
        insertedContact.Contact_Status__c = '2 - Attempting Contact';
        update insertedContact;

        test.startTest();

        Contact updatedContact = [Select Id, Contact_Status__c, DG_Lead_Status__c From Contact Where Id =: cont.id];

        Lead_Contact_DG_Status_Update__c dgLeadStatus = Lead_Contact_DG_Status_Update__c.getValues(updatedContact.Contact_Status__c);

        system.assertEquals(updatedContact.DG_Lead_Status__c, dgLeadStatus.DG_Lead_Status__c);
    }

    /* Author: Sharma Nemani
     * PDG Workflow Rules
     * Date: 03/27/2019
     * Description: Added this Method for the changes made in the ContactTriggers.apxt for PDG Workflow Rules.
     */
        
    @isTest
    private static void contactSLAWorkflowTest(){
         Profile marketingProfile = [SELECT Id FROM Profile where Name='System Admin w/Marketo'];
        User user = new User(
            Username = System.now().millisecond() + 'test12345@test.com',
            ProfileId = marketingProfile.Id,
            Alias = 'test123',
            Email = 'test12345@test.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test12345',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US'
        );
        Database.insert(user);
        Account acc = new Account();
        acc.Name = 'UCMTFT Account';
        insert acc;
        
        Contact con1 = new Contact(
            FirstName = 'UCMTFT',
            LastName = 'Contact1',
            Contact_Source_Most_Recent__c = 'Facebook',
            AccountId = acc.Id,
            DG_Lead_Status__c = 'Recycle - No Budget', 
            Dispensation_SLA_QL__c = 'Warm SLA Out-of-policy',
            Phone = '123456789', 
            Email = 'Reest@test.com', 
            Hot_SLA_Date__c = System.Today().addDays(-1));
        insert con1;
        
        Contact con2 = new Contact(
            FirstName = 'UCMTFT2',
            LastName = 'Contact12',
            Contact_Source_Most_Recent__c = 'Facebook2',
            AccountId = acc.Id,
            DG_Lead_Status__c = 'Recycle - No Budget', 
            Dispensation_SLA_QL__c = 'Warm SLA Out-of-policy',
            Phone = '123456389', 
            Email = 'Reest11@test11.com', 
            Hot_SLA_Date__c = System.Today().addDays(-1));
        insert con2;
		system.runAs(user){
            con1.DG_Lead_Status__c = 'Recycle - Student';
            con1.Dispensation_SLA_QL__c = 'Hot SLA In-policy';
            update con1;
            
            con1.DG_Lead_Status__c = 'Recycle - No Budget';
            con1.Dispensation_SLA_QL__c = 'Warm SLA In-policy';
            update con1;
            
            con1.DG_Lead_Status__c = 'Recycle - Student';
            con1.Dispensation_SLA_QL__c = 'Hot SLA Out-of-policy';
            update con1;
            
            con1.DG_Lead_Status__c = 'Recycle - No Budget';
            con1.Dispensation_SLA_QL__c = 'Warm SLA Out-of-policy';
            update con1;
            
            con1.DG_Lead_Status__c = 'Recycle - Student';
            con1.Conversion_SLA_QL__c = 'Hot SLA In-policy';
            update con1;
            
            con1.DG_Lead_Status__c = 'Recycle - No Budget';
            con1.Conversion_SLA_QL__c = 'Warm SLA In-policy';
            update con1;
            
            con1.DG_Lead_Status__c = 'Recycle - Student';
            con1.Conversion_SLA_QL__c = 'Hot SLA Out-of-policy';
            update con1;
            
            con1.DG_Lead_Status__c = 'Recycle - No Budget';
            con1.Conversion_SLA_QL__c = 'Warm SLA Out-of-policy';
            update con1;
            
            con1.DG_Lead_Status__c = 'Open';
            con1.Dispensation_SLA_QL__c = 'Warm SLA In-policy';
            con1.Warm_SLA_Date__c = System.Today().addDays(-3);
            update con1;
			
			con1.DG_Lead_Status__c = 'Engaged';
            con1.Dispensation_SLA_QL__c = 'Hot SLA In-policy';
            con1.Hot_SLA_Date__c = System.Today().addDays(-3);
            update con1;
            
            con1.DG_Lead_Status__c = 'Open';
            con1.Conversion_SLA_QL__c = 'Warm SLA In-policy';
            con1.Warm_SLA_Date__c = System.Today().addDays(-25);
            update con1;
            
            con1.DG_Lead_Status__c = 'Engaged';
            con1.Conversion_SLA_QL__c = 'Hot SLA In-policy';
            con1.Hot_SLA_Date__c = System.Today().addDays(-25);
            update con1;
            
            con1.Hot_SLA_Date__c = System.Today();
            update con1;
            
            con2.Warm_SLA_Date__c = System.Today();
            update con2;
        }
    }
    
}