@isTest
public with sharing class PDGTest {

    /**For futher details of these test classes refer to the SLA Workbook 1-13-20
    attchment on the Epic: PDG SLA Enhancement */

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadDispensationSLAWarmSLAinPolicy()
    {
        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = Label.MQL_Staging_QueueId;
        lead.Warm_SLA_Date__c = date.today();

        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        insert lead;

        test.startTest();

        //Update the owner to a rep
        lead.OwnerId = u.id;
        update lead;

        test.stopTest();

        Lead updatedLead = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Lead
        Where ID =: lead.Id];

        // Task t = [Select WhoId, Subject From Task Where WhoId =: lead.Id];  //eddie commented out

        // system.debug(' updated lead ' + updatedLead + ' task '+ t);  //eddie commented out

        /**We expect the following to happen:
        Confirm that the following is true
a.       Warm SLA - Date = today
b.       Rep Owned Warm SLA Date = today
c.       Business Days Since Warm SLA = 0
d.       Dispensation SLA – QL = ‘Warm SLA In-policy’
e.       Conversion SLA – QL = ‘Warm SLA In-policy’
3.       Confirm that a task is created with the subject QL Warm Assigned: 48-hour outreach SLA in effect
4.       Confirm email was sent to you if you were the lead owner with the subject QL Warm Assigned: 48-hour outreach SLA in effect
*/

        system.assertEquals(date.today(), updatedLead.Warm_SLA_Date__c);
        system.assertEquals(date.today(), updatedLead.Rep_Owned_Warm_SLA_Date__c);
        system.assertEquals(0, updatedLead.Business_Days_Since_Warm_SLA__c);
        system.assertEquals('Warm SLA In-policy', updatedLead.Dispensation_SLA_QL__c);
        system.assertEquals('Warm SLA In-policy', updatedLead.Conversion_SLA_QL__c);
        // system.assertEquals('QL Warm Assigned: 48-hour outreach SLA in effect', t.Subject); //eddie commented out
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadDispensationSLAWarmSLAInPolicyCompleted()
    {


        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Warm_SLA_Date__c = date.today();

        insert lead;

        test.startTest();

        //Update the DG Lead Status
        lead.DG_Lead_Status__c = 'In Conversation';
        update lead;

        Lead updatedLead = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead );


        system.assertEquals('Warm SLA In-policy Completed', updatedLead.Dispensation_SLA_QL__c);

        test.stopTest();
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadDispensationSLAWarmSLAOutOfPolicy48HourTimeBased()
    {
        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Warm_SLA_Date__c = date.today();

        insert lead;

        test.startTest();

        Datetime d = DateTime.now();
        Datetime dt = (DateTime)d;
        String dayOfWeek = dt.format('EEEE');

        lead.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-2);
        system.debug(' day of the week  ' + dayOfWeek + lead.Rep_Owned_Warm_SLA_Date__c);

        //Name: Chris Salgado Date: 3/3/20 Purpose: Failing test class due to missing Tuesday
        if(dayOfWeek == 'Monday'|| dayOfWeek == 'Tuesday'){
            lead.Rep_Owned_Warm_SLA_Date__c = lead.Rep_Owned_Warm_SLA_Date__c.addDays(-2);
        }
        update lead;

        BatchLeadSLAOutOfPolicy bci = new BatchLeadSLAOutOfPolicy();
        Id batchId = Database.executeBatch(bci);

        test.stopTest();

        Lead updatedLead = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead);

        system.assertEquals('Warm SLA Out-of-policy', updatedLead.Dispensation_SLA_QL__c);

    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadDispensationSLAWarmSLAOutOfPolicyCompleted()
    {
        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Warm_SLA_Date__c = date.today();
        lead.Dispensation_SLA_QL__c = 'Warm SLA Out-of-policy';

        insert lead;

        test.startTest();

        //Update the DG Lead Status
        lead.DG_Lead_Status__c = 'In Conversation';
        update lead;

        test.stopTest();

        Lead updatedLead = [Select Dispensation_SLA_QL__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead);

        system.assertEquals('Warm SLA Out-of-policy Completed', updatedLead.Dispensation_SLA_QL__c);
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadDispensationSLAHOTSLAinPolicy()
    {
        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = Label.MQL_Staging_QueueId;
        lead.Hot_SLA_Date__c = date.today();

        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        insert lead;

        test.startTest();

        //Update the owner to a rep
        lead.OwnerId = u.id;
        update lead;

        test.stopTest();

        Lead updatedLead = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Lead
        Where ID =: lead.Id];

        // Task t = [Select WhoId, Subject From Task Where WhoId =: lead.Id]; //eddie commented out

        // system.debug(' updated lead ' + updatedLead + ' task '+ t); //eddie commented out

        /**We expect the following to happen:
        2.       Confirm that the following is true
a.       Hot SLA - Date = today
b.       Rep Owned Hot SLA Date = today
c.       Business Days Since Hot SLA = 0
d.       Dispensation SLA – QL = ‘Hot SLA In-policy’
e.       Conversion SLA – QL = ‘Hot SLA In-policy’
3.       Confirm that a task is created with the subject QL Hot Assigned: 24-hour outreach SLA in effect
4.       Confirm email was sent to you if you were the lead owner with the subject QL Hot Assigned: 24-hour outreach SLA in effect
*/

        system.assertEquals(date.today(), updatedLead.Hot_SLA_Date__c);
        system.assertEquals(date.today(), updatedLead.Rep_Owned_Hot_SLA_Date__c);
        system.assertEquals(0, updatedLead.Business_Days_Since_Hot_SLA__c);
        system.assertEquals('Hot SLA In-policy', updatedLead.Dispensation_SLA_QL__c);
        system.assertEquals('Hot SLA In-policy', updatedLead.Conversion_SLA_QL__c);
        // system.assertEquals('QL Hot Assigned: 24-hour outreach SLA in effect', t.Subject); //eddie commented out
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadDispensationSLAHOTSLAInPolicyCompleted()
    {


        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Hot_SLA_Date__c = date.today();

        insert lead;

        test.startTest();

        //Update the DG Lead Status
        lead.DG_Lead_Status__c = 'In Conversation';
        update lead;

        Lead updatedLead = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead );


        system.assertEquals('Hot SLA In-policy Completed', updatedLead.Dispensation_SLA_QL__c);

        test.stopTest();
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadDispensationSLAHOTSLAOutOfPolicy24HourTimeBased()
    {
        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Hot_SLA_Date__c = date.today();

        insert lead;

        test.startTest();

        DateTime now = DateTime.now();
        String dayOfWeek = now.format('EEEE');

        system.debug('day of week 1 day ' + dayOfWeek);

        lead.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-1);

        if(dayOfWeek == 'Monday')
            lead.Rep_Owned_Hot_SLA_Date__c = lead.Rep_Owned_Hot_SLA_Date__c.addDays(-3);

        update lead;

        BatchLeadSLAOutOfPolicy bci = new BatchLeadSLAOutOfPolicy();
        Id batchId = Database.executeBatch(bci);

        test.stopTest();

        Lead updatedLead = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead);

        system.assertEquals('Hot SLA Out-of-policy', updatedLead.Dispensation_SLA_QL__c);

    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadDispensationSLAHOTSLAOutOfPolicyCompleted()
    {
        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Hot_SLA_Date__c = date.today();
        lead.Dispensation_SLA_QL__c = 'Hot SLA Out-of-policy';

        insert lead;

        test.startTest();

        //Update the DG Lead Status
        lead.DG_Lead_Status__c = 'In Conversation';
        update lead;

        test.stopTest();

        Lead updatedLead = [Select Dispensation_SLA_QL__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead);

        system.assertEquals('Hot SLA Out-of-policy Completed', updatedLead.Dispensation_SLA_QL__c);
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadConversionSLAWarmSLAInPolicyCompleted()
    {
        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Hot_SLA_Date__c = date.today();
        lead.Conversion_SLA_QL__c = 'Warm SLA In-policy';

        insert lead;

        test.startTest();

        //Update the DG Lead Status
        lead.DG_Lead_Status__c = 'Converted to Opportunity';
        update lead;

        test.stopTest();

        Lead updatedLead = [Select Conversion_SLA_QL__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead);

        system.assertEquals('Warm SLA In-policy Completed', updatedLead.Conversion_SLA_QL__c);
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadConversionSLAWarmSLAOutOfPolicy21DayTimeBased()
    {
        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Warm_SLA_Date__c = date.today();

        insert lead;

        test.startTest();

        DateTime now = DateTime.now();
        String dayOfWeek = now.format('EEEE');

        system.debug('day of week ' + dayOfWeek);

        lead.Dispensation_SLA_QL__c  = '';
        if(dayOfWeek == 'Monday')
            lead.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-32);
        else if(dayOfWeek == 'Tuesday')
            lead.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Wednesday')
            lead.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Thursday')
            lead.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Friday')
            lead.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-29);

        update lead;

        BatchLeadSLAOutOfPolicy bci = new BatchLeadSLAOutOfPolicy();
        Id batchId = Database.executeBatch(bci);

        test.stopTest();

        Lead updatedLead = [Select Conversion_SLA_QL__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead);

        system.assertEquals('Warm SLA Out-of-policy', updatedLead.Conversion_SLA_QL__c);

    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadConversionSLAWarmSLAoutofPolicyCompleted()
    {
        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Hot_SLA_Date__c = date.today();
        lead.Conversion_SLA_QL__c = 'Warm SLA Out-of-policy';

        insert lead;

        test.startTest();

        //Update the DG Lead Status
        lead.DG_Lead_Status__c = 'Converted to Opportunity';
        update lead;

        test.stopTest();

        Lead updatedLead = [Select Conversion_SLA_QL__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead);

        system.assertEquals('Warm SLA Out-of-policy Completed', updatedLead.Conversion_SLA_QL__c);
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadConversionSLAHotSLAInPolicyCompleted()
    {
        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Hot_SLA_Date__c = date.today();
        lead.Conversion_SLA_QL__c = 'Hot SLA In-policy';

        insert lead;

        test.startTest();

        //Update the DG Lead Status
        lead.DG_Lead_Status__c = 'Converted to Opportunity';
        update lead;

        test.stopTest();

        Lead updatedLead = [Select Conversion_SLA_QL__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead);

        system.assertEquals('Hot SLA In-policy Completed', updatedLead.Conversion_SLA_QL__c);
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadConversionSLAHotSLAOutOfPolicy14DayTimeBased()
    {
        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Hot_SLA_Date__c = date.today();

        insert lead;

        test.startTest();

        DateTime now = DateTime.now();
        String dayOfWeek = now.format('EEEE');

        system.debug('day of week 14' + dayOfWeek);

        lead.Dispensation_SLA_QL__c  = '';
        /*if(dayOfWeek == 'Monday')
        lead.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-23);
        else if(dayOfWeek == 'Tuesday')
        lead.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-20);
        else if(dayOfWeek == 'Wednesday')
        lead.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-20);
        else if(dayOfWeek == 'Thursday')
        lead.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-20);
        else if(dayOfWeek == 'Friday')
        lead.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-20);*/

        //Updating this test scenario from 14 to 21 business days
        if(dayOfWeek == 'Monday')
            lead.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-32);
        else if(dayOfWeek == 'Tuesday')
            lead.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Wednesday')
            lead.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Thursday')
            lead.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Friday')
            lead.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-29);

        update lead;

        BatchLeadSLAOutOfPolicy bci = new BatchLeadSLAOutOfPolicy();
        Id batchId = Database.executeBatch(bci);

        test.stopTest();

        Lead updatedLead = [Select Conversion_SLA_QL__c, Business_Days_Since_Hot_SLA__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead);

        system.assertEquals('Hot SLA Out-of-policy', updatedLead.Conversion_SLA_QL__c);

    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void LeadConversionSLAHOTSLAOutOfPolicyCompleted()
    {
        Profile p = [select id from profile where name = 'Alteryx - Sales - Inside Sales AEs' limit 1];

        User u = new user();
        u.LastName = 'randomSalesUserTest';
        u.Email = 'randomSalesUserTest@gmail.com';
        u.Alias = 'randomSa';
        u.Username = 'randomSalesUserTest@gmail.com';
        u.CommunityNickname = 'randomSalesUserTesty';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = p.id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        u.isActive=True;
        insert u;

        Lead lead = new Lead();
        lead.Lastname = 'Test Last Name';
        lead.Company = 'Test Company';
        lead.Status = '1 - Not Contaced';
        lead.CurrencyIsoCode = 'USD';
        lead.Street = 'Test Street';
        lead.City = 'Test City';
        lead.State = 'CA';
        lead.PostalCode = '55555';
        lead.Country = 'US';
        lead.OwnerId = u.Id;
        lead.Hot_SLA_Date__c = date.today();
        lead.Conversion_SLA_QL__c = 'Hot SLA Out-of-policy';

        insert lead;

        test.startTest();

        //Update the DG Lead Status
        lead.DG_Lead_Status__c = 'Converted to Opportunity';
        update lead;

        test.stopTest();

        Lead updatedLead = [Select Conversion_SLA_QL__c
        From Lead
        Where ID =: lead.Id];

        system.debug(' updated lead ' + updatedLead);

        system.assertEquals('Hot SLA Out-of-policy Completed', updatedLead.Conversion_SLA_QL__c);
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactDispensationSLAWarmSLAinPolicy()
    {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        test.startTest();

        contact.Warm_SLA_Date__c = date.today();
        update contact;

        test.stopTest();

        Contact updatedContact = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Contact
        Where ID =: contact.Id];

        // Task t = [Select WhoId, Subject From Task Where WhoId =: contact.Id]; //eddie commented out

        // system.debug(' updated contact ' + updatedContact + ' task '+ t); //eddie commented out

        /**We expect the following to happen:
        Confirm that the following is true
a.       Warm SLA - Date = today
b.       Rep Owned Warm SLA Date = today
c.       Business Days Since Warm SLA = 0
d.       Dispensation SLA – QL = ‘Warm SLA In-policy’
e.       Conversion SLA – QL = ‘Warm SLA In-policy’
3.       Confirm that a task is created with the subject QL Warm Assigned: 48-hour outreach SLA in effect
4.       Confirm email was sent to you if you were the contact owner with the subject QL Warm Assigned: 48-hour outreach SLA in effect
*/

        system.assertEquals(date.today(), updatedContact.Warm_SLA_Date__c);
        system.assertEquals(date.today(), updatedContact.Rep_Owned_Warm_SLA_Date__c);
        system.assertEquals(0, updatedContact.Business_Days_Since_Warm_SLA__c);
        system.assertEquals('Warm SLA In-policy', updatedContact.Dispensation_SLA_QL__c);
        system.assertEquals('Warm SLA In-policy', updatedContact.Conversion_SLA_QL__c);
        // system.assertEquals('QL Warm Assigned: 48-hour outreach SLA in effect', t.Subject); //eddie commented out
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactDispensationSLAWarmSLAInPolicyCompleted()
    {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        contact.Warm_SLA_Date__c = date.today();
        update contact;

        test.startTest();

        //Update the DG contact Status
        contact.DG_Lead_Status__c = 'In Conversation';
        update contact;

        Contact updatedContact = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated contact ' + updatedContact );


        system.assertEquals('Warm SLA In-policy Completed', updatedContact.Dispensation_SLA_QL__c);

        test.stopTest();
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactDispensationSLAWarmSLAOutOfPolicy48HourTimeBased()
    {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        contact.Warm_SLA_Date__c = date.today();
        update contact;

        test.startTest();

        Datetime d = DateTime.now();
        Datetime dt = (DateTime)d;
        String dayOfWeek = dt.format('EEEE');

        contact.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-2);

        //Name: Chris Salgado Date: 3/3/20 Purpose: Failing test class due to missing Tuesday
        if(dayOfWeek == 'Monday' || dayOfWeek == 'Tuesday') {
            contact.Rep_Owned_Warm_SLA_Date__c = contact.Rep_Owned_Warm_SLA_Date__c.addDays(-2);
        }
        update contact;

        BatchContactSLAOutOfPolicy bci = new BatchContactSLAOutOfPolicy();
        Id batchId = Database.executeBatch(bci);

        test.stopTest();

        Contact updatedContact = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated contact ' + updatedContact);

        system.assertEquals('Warm SLA Out-of-policy', updatedContact.Dispensation_SLA_QL__c);

    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactDispensationSLAWarmSLAOutOfPolicyCompleted()
    {

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        contact.Warm_SLA_Date__c = date.today();
        contact.Dispensation_SLA_QL__c = 'Warm SLA Out-of-policy';

        update contact;

        test.startTest();

        //Update the DG Lead Status
        contact.DG_Lead_Status__c = 'In Conversation';
        update contact;

        test.stopTest();

        Contact updatedContact = [Select Dispensation_SLA_QL__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated contact ' + updatedContact);

        system.assertEquals('Warm SLA Out-of-policy Completed', updatedContact.Dispensation_SLA_QL__c);
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactDispensationSLAHOTSLAinPolicy()
    {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        test.startTest();

        contact.Hot_SLA_Date__c = date.today();
        update contact;

        test.stopTest();

        Contact updatedContact = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Contact
        Where ID =: contact.Id];

        //  Task t = [Select WhoId, Subject From Task Where WhoId =: contact.Id]; //eddie commented out

        // system.debug(' updated contact ' + updatedContact + ' task '+ t); //eddie commented out

        /**We expect the following to happen:
        2.       Confirm that the following is true
a.       Hot SLA - Date = today
b.       Rep Owned Hot SLA Date = today
c.       Business Days Since Hot SLA = 0
d.       Dispensation SLA – QL = ‘Hot SLA In-policy’
e.       Conversion SLA – QL = ‘Hot SLA In-policy’
3.       Confirm that a task is created with the subject QL Hot Assigned: 24-hour outreach SLA in effect
4.       Confirm email was sent to you if you were the Contact owner with the subject QL Hot Assigned: 24-hour outreach SLA in effect
*/

        system.assertEquals(date.today(), updatedContact.Hot_SLA_Date__c);
        system.assertEquals(date.today(), updatedContact.Rep_Owned_Hot_SLA_Date__c);
        system.assertEquals(0, updatedContact.Business_Days_Since_Hot_SLA__c);
        system.assertEquals('Hot SLA In-policy', updatedContact.Dispensation_SLA_QL__c);
        system.assertEquals('Hot SLA In-policy', updatedContact.Conversion_SLA_QL__c);
        //  system.assertEquals('QL Hot Assigned: 24-hour outreach SLA in effect', t.Subject); //eddie commented out
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactDispensationSLAHOTSLAInPolicyCompleted()
    {


        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        contact.Hot_SLA_Date__c = date.today();

        update contact;

        test.startTest();

        //Update the DG Lead Status
        contact.DG_Lead_Status__c = 'In Conversation';
        update contact;

        Contact updatedContact = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated contact ' + updatedContact );


        system.assertEquals('Hot SLA In-policy Completed', updatedContact.Dispensation_SLA_QL__c);

        test.stopTest();
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactDispensationSLAHOTSLAOutOfPolicy24HourTimeBased()
    {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);
        contact.Hot_SLA_Date__c = date.today();

        update contact;

        test.startTest();

        DateTime now = DateTime.now();
        String dayOfWeek = now.format('EEEE');

        system.debug('day of week 1 day ' + dayOfWeek);

        contact.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-1);

        if(dayOfWeek == 'Monday')
            contact.Rep_Owned_Hot_SLA_Date__c = contact.Rep_Owned_Hot_SLA_Date__c.addDays(-3);

        update contact;

        BatchContactSLAOutOfPolicy bci = new BatchContactSLAOutOfPolicy();
        Id batchId = Database.executeBatch(bci);

        test.stopTest();

        Contact updatedContact = [Select Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c, Warm_SLA_Date__c, Hot_SLA_Date__c,
                Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Rep_Owned_Warm_SLA_Date__c, Rep_Owned_Hot_SLA_Date__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated contact ' + updatedContact);

        system.assertEquals('Hot SLA Out-of-policy', updatedContact.Dispensation_SLA_QL__c);

    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactDispensationSLAHOTSLAOutOfPolicyCompleted()
    {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        contact.Dispensation_SLA_QL__c = 'Hot SLA Out-of-policy';

        update contact;

        test.startTest();

        //Update the DG Lead Status
        contact.DG_Lead_Status__c = 'In Conversation';
        update contact;

        test.stopTest();

        Contact updatedContact = [Select Dispensation_SLA_QL__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated contact ' + updatedContact);

        system.assertEquals('Hot SLA Out-of-policy Completed', updatedContact.Dispensation_SLA_QL__c);
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactConversionSLAWarmSLAInPolicyCompleted()
    {

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        contact.Hot_SLA_Date__c = date.today();
        contact.Conversion_SLA_QL__c = 'Warm SLA In-policy';

        update contact;

        test.startTest();

        //Update the DG Lead Status
        contact.DG_Lead_Status__c = 'Converted to Opportunity';
        update contact;

        test.stopTest();

        Contact updatedContact = [Select Conversion_SLA_QL__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated contact ' + updatedContact);

        system.assertEquals('Warm SLA In-policy Completed', updatedContact.Conversion_SLA_QL__c);
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactConversionSLAWarmSLAOutOfPolicy21DayTimeBased()
    {

        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        contact.Warm_SLA_Date__c = date.today();

        update contact;

        test.startTest();

        DateTime now = DateTime.now();
        String dayOfWeek = now.format('EEEE');

        system.debug('day of week ' + dayOfWeek);

        contact.Dispensation_SLA_QL__c  = '';
        if(dayOfWeek == 'Monday')
            contact.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-32);
        else if(dayOfWeek == 'Tuesday')
            contact.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Wednesday')
            contact.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Thursday')
            contact.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Friday')
            contact.Rep_Owned_Warm_SLA_Date__c = date.today().addDays(-29);

        update contact;

        BatchContactSLAOutOfPolicy bci = new BatchContactSLAOutOfPolicy();
        Id batchId = Database.executeBatch(bci);

        test.stopTest();

        Contact updatedContact = [Select Conversion_SLA_QL__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated contact ' + updatedContact);

        system.assertEquals('Warm SLA Out-of-policy', updatedContact.Conversion_SLA_QL__c);

    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactConversionSLAWarmSLAoutofPolicyCompleted()
    {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        contact.Hot_SLA_Date__c = date.today();
        contact.Conversion_SLA_QL__c = 'Warm SLA Out-of-policy';

        update contact;

        test.startTest();

        //Update the DG Lead Status
        contact.DG_Lead_Status__c = 'Converted to Opportunity';
        update contact;

        test.stopTest();

        Contact updatedContact = [Select Conversion_SLA_QL__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated contact ' + updatedContact);

        system.assertEquals('Warm SLA Out-of-policy Completed', updatedContact.Conversion_SLA_QL__c);
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactConversionSLAHotSLAInPolicyCompleted()
    {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        contact.Hot_SLA_Date__c = date.today();
        contact.Conversion_SLA_QL__c = 'Hot SLA In-policy';

        update contact;

        test.startTest();

        //Update the DG Lead Status
        contact.DG_Lead_Status__c = 'Converted to Opportunity';
        update contact;

        test.stopTest();

        Contact updatedContact = [Select Conversion_SLA_QL__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated contact ' + updatedContact);

        system.assertEquals('Hot SLA In-policy Completed', updatedContact.Conversion_SLA_QL__c);
    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactConversionSLAHotSLAOutOfPolicy14DayTimeBased()
    {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        contact.Hot_SLA_Date__c = date.today();

        update contact;

        test.startTest();

        DateTime now = DateTime.now();
        String dayOfWeek = now.format('EEEE');

        system.debug('day of week 14' + dayOfWeek);

        contact.Dispensation_SLA_QL__c  = '';
        /*if(dayOfWeek == 'Monday')
        contact.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-23);
        else if(dayOfWeek == 'Tuesday')
        contact.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-20);
        else if(dayOfWeek == 'Wednesday')
        contact.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-20);
        else if(dayOfWeek == 'Thursday')
        contact.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-20);
        else if(dayOfWeek == 'Friday')
        contact.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-20);*/

        //Updating this test scenario from 14 to 21 business days
        if(dayOfWeek == 'Monday')
            contact.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-32);
        else if(dayOfWeek == 'Tuesday')
            contact.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Wednesday')
            contact.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Thursday')
            contact.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-29);
        else if(dayOfWeek == 'Friday')
            contact.Rep_Owned_Hot_SLA_Date__c = date.today().addDays(-29);

        update contact;

        BatchContactSLAOutOfPolicy bci = new BatchContactSLAOutOfPolicy();
        Id batchId = Database.executeBatch(bci);

        test.stopTest();

        Contact updatedContact = [Select Conversion_SLA_QL__c, Business_Days_Since_Hot_SLA__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated Contact ' + updatedContact);

        system.assertEquals('Hot SLA Out-of-policy', updatedContact.Conversion_SLA_QL__c);

    }

    //Author: Sergio Flores
    //Date 01/29/2020
    //W-013774
    public static testMethod void ContactConversionSLAHOTSLAOutOfPolicyCompleted()
    {
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact contact = OrgWideTestUtil.createContact(true, acc.Id);

        contact.Hot_SLA_Date__c = date.today();
        contact.Conversion_SLA_QL__c = 'Hot SLA Out-of-policy';

        update contact;

        test.startTest();

        //Update the DG Lead Status
        contact.DG_Lead_Status__c = 'Converted to Opportunity';
        update contact;

        test.stopTest();

        Contact updatedContact = [Select Conversion_SLA_QL__c
        From Contact
        Where ID =: contact.Id];

        system.debug(' updated contact ' + updatedContact);

        system.assertEquals('Hot SLA Out-of-policy Completed', updatedContact.Conversion_SLA_QL__c);
    }

}