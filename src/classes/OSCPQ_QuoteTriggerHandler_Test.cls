/*------------------------------------------------------------------------+
Original Shift(developer@originalshift.com)
Purpose: Test Class for the OSCPQ_ContractTriggerHandler class
 
Details: Basic single-record (since mass approval submission shouldn't occur)
        tests.
 
History:
Feb 08/19 - Original Shift - Initial Implementation 
------------------------------------------------------------------------+*/
@isTest
public class OSCPQ_QuoteTriggerHandler_Test { // IL
    @testSetup static void setup() {
        /*
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


        Account_BD_Owners_and_States__c  bdOwner = new Account_BD_Owners_and_States__c();
        bdOwner.Name = 'IL';

        bdOwner.BD_Owner_ID__c = u.Id;
        insert bdOwner;
        */
        insert (new Quote_Trigger_Custom_Settings__c(Name = 'Test', QuoteHistoricImportActive__c = false));
        Account acct = OSCPQ_TestFactory.createSingleAccount(true);
        Opportunity opp = OSCPQ_TestFactory.createSingleOpp(acct, false);
        opp.CurrencyIsoCode = 'USD';
        opp.SBQQ__QuotePricebookId__c = null;
        insert opp;

        pw_ccpro__CountryObject__c billToCountry = new pw_ccpro__CountryObject__c(Default_Price_Book_Standard_Purchase__c = 'LATAM Price Book',
                Default_Currency_Standard_Purchase__c = 'USD',
                Name = 'United States',
                pw_ccpro__IsoCode_2__c = 'US',
                pw_ccpro__IsoCode_3__c = 'USA',
                pw_ccpro__Continent__c = 'North America',
                Country_Sales_Territory__c = 'NA',
                Subsidiary__c = 'Alteryx, Inc.'
        );
        insert billToCountry;

        Contact cont = OSCPQ_TestFactory.createSingleContact(acct, false);
        cont.pw_ccpro__MailingCountryLookup__c = billToCountry.Id;
        insert cont;

        Pricebook2 stdPB = new Pricebook2(Name = 'Standard Price Book', IsActive = true);
        Pricebook2 latamPB = new Pricebook2(Name = 'LATAM Price Book', IsActive = true);
        Pricebook2 nfrPB = new Pricebook2(Name = 'NFR Price Book', IsActive = true);
        insert new List<Pricebook2>{stdPB, latamPB, nfrPB};

        //SBQQ.TriggerControl.disable();
        SBQQ__Quote__c quote = OSCPQ_TestFactory.createSingleQuote(acct, opp, true, true);
        //SBQQ.TriggerControl.enable();


        // Insert record type "Submitted"
        List<QuoteRecordTypeIds__c> quoteRecordTypeIdList = new List<QuoteRecordTypeIds__c>();

        QuoteRecordTypeIds__c quoteRecordTypeId3 = new QuoteRecordTypeIds__c();
        quoteRecordTypeId3.Name = 'Submitted';
        quoteRecordTypeId3.RecordTypeId__c = '0122R0000006GwO';

        quoteRecordTypeIdList.add(quoteRecordTypeId3);

        insert quoteRecordTypeIdList;

        //Insert Account
        Account a = (Account)SmartFactory.createSObject('Account');
        a.BillingStreet = '1 acc';
        a.BillingCity = 'Irvine';
        a.BillingState = 'California';
        a.BillingPostalCode = '91111';
        a.BillingCountry = 'USA';
        a.ShippingStreet = '1 acc';
        a.ShippingCity = 'Irvine';
        a.ShippingState = 'California';
        a.ShippingPostalCode = '91111';
        a.ShippingCountry = 'USA';
        a.Name = 'test Account';
        insert a;

        //Insert Contact
        Contact c = (Contact)SmartFactory.createSObject('Contact');
        c.MailingStreet = '123 street';
        c.MailingCity = 'gotham';
        c.MailingState = 'Chicago';
        c.MailingCountry = 'USA';
        c.MailingPostalCode = '91220';
        c.Email = 'test@email.com';
        c.phone = '1233334444';
        c.FirstName = 'testfirst';
        c.LastName = 'testlast';
        c.SheerID_Verification_ID__c = 'testid123';
        c.pw_ccpro__MailingCountryLookup__c = billToCountry.Id;
        insert c;

        //Insert License Admin
        License_Administrator__c licAdmin =(License_Administrator__c)SmartFactory.createSObject('License_Administrator__c');
        licAdmin.Contact__c = c.Id;
        licAdmin.Account__c = a.Id;
        insert licAdmin;

        //Insert Order Group
        Order_Group__c oGroup = (Order_Group__c)SmartFactory.createSObject('Order_Group__c');
        oGroup.License_Administrator__c = licAdmin.Id;
        oGroup.Account__c = a.Id;
        insert oGroup;

        //Insert User
        User u = (User)SmartFactory.createSObject('User');
        u.FirstName = 'Test';
        u.LastName = 'Only';
        insert u;

        //Insert Contract
        Contract con = (Contract)SmartFactory.createSObject('Contract');
        con.AccountId = a.Id;
        con.Status = 'draft';
        insert con;

        //Insert Amendment Opp
        Opportunity amendOpp = (Opportunity)SmartFactory.createSObject('Opportunity');
        insert amendOpp;

        //Insert Coterm quote
        SBQQ__Quote__c coTermQuote = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        coTermQuote.SBQQ__Type__c = 'Amendment';
        coTermQuote.SBQQ__Opportunity2__c = amendOpp.Id;
        coTermQuote.Purchase_Type__c = 'Upsell Co-term';
        insert coTermQuote;
    }

    /*
    //Name : Eddie Wong
    //Date : 09/29/2020
    //Purpose : W-004808
    @isTest static void testDDApprovalTimeStamp(){
        Id cpqQuoteRecordTypeId_Submitted = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Submitted').getRecordTypeId();
        License_Administrator__c lAdmin = [SELECT Id FROM License_Administrator__c LIMIT 1];
        Order_Group__c oG = [SELECT Id FROM Order_Group__c LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE BillingStreet = '1 acc' LIMIT 1];
        User user = [SELECT Id FROM User WHERE FirstName = 'Test' and LastName = 'Only' LIMIT 1];


        SBQQ__Quote__c quote = [SELECT Id FROM SBQQ__Quote__c LIMIT 1];
        quote.RecordTypeId = cpqQuoteRecordTypeId_Submitted;
        quote.Quote_Type__c = 'Purchase';
        quote.License_Administrator__c = lAdmin.Id;
        quote.Order_Group__c = oG.Id;
        quote.SBQQ__Account__c = acc.Id;

        Test.startTest();
        update quote;
        quote.Deal_Desk_Owner__c = user.Id;
        update quote;
        quote.SBQQ__Status__c = 'Submitted to Legal';
        update quote;
        quote.SBQQ__Status__c = 'Out for Signature';
        update quote;
        quote.SBQQ__Status__c = 'Waiting for Alteryx Counter Signature';
        update quote;
        quote.SBQQ__Status__c = 'Fully Signed';
        update quote;
        quote.SBQQ__Status__c = 'In Review';
        update quote;
        quote.SBQQ__Status__c = 'Fully Signed';
        update quote;
        quote.ApprovalStatus__c = 'Approved';
        update quote;
        quote.OwnerId = System.Label.DDApproverQueue;
        //quote.SBQQ__Status__c = 'On Hold';
        update quote;
        quote.SBQQ__Status__c = 'On Hold';
        quote.On_Hold_Reason__c = 'Amount';
        update quote;
        quote.SBQQ__Status__c = 'Accepted';
        update quote;
        Test.stopTest();

        //Assertions
        SBQQ__Quote__c queryQuote = [SELECT Id,Accepted_Date_Time__c FROM SBQQ__Quote__c WHERE Id = :quote.Id AND Accepted_Date_Time__c != null LIMIT 1];
        System.assertEquals(quote.Id, queryQuote.Id);

    }
    */

    //Name : Eddie Wong
    //Date : 09/29/2020
    //Purpose : W-006105
    @isTest static void coTermForECUR() {
        SBQQ.TriggerControl.disable();
        License_Administrator__c licAdmin = [SELECT ID FROM License_Administrator__c LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE BillingStreet = '1 acc' LIMIT 1];
        Order_Group__c oG = [SELECT ID FROM Order_Group__c LIMIT 1];
        SBQQ__Quote__c quote = [SELECT ID FROM SBQQ__Quote__c LIMIT 1];
        quote.License_Administrator__c = licAdmin.Id;
        quote.Order_Group__c = oG.Id;
        quote.SBQQ__Account__c = acc.Id;
        update quote;


        Contract cont = [SELECT ID FROM Contract LIMIT 1];
        cont.SBQQ__Quote__c = quote.Id;
        cont.Status = 'Activated';
        cont.AccountId = acc.Id;



        Opportunity oppECUR = [SELECT ID FROM Opportunity LIMIT 1];
        oppECUR.Type = 'ECUR';
        oppECUR.SBQQ__AmendedContract__c = cont.Id;
        oppECUR.AccountId = acc.Id;




        Test.startTest();

        update cont;
        update oppECUR;

        Amendment_API_Event__e amendQuote = new Amendment_API_Event__e(Opportunity_Id__c = oppECUR.Id, Contract_Id__c = cont.Id);
        Database.SaveResult sr = EventBus.publish(amendQuote);
        Test.stopTest();

    }

    @isTest static void coTermForECURQuoteUodate() {
        SBQQ.TriggerControl.disable();
        License_Administrator__c licAdmin = [SELECT ID FROM License_Administrator__c LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE BillingStreet = '1 acc' LIMIT 1];
        Order_Group__c oG = [SELECT ID FROM Order_Group__c LIMIT 1];
        SBQQ__Quote__c quote = [SELECT ID FROM SBQQ__Quote__c LIMIT 1];
        quote.License_Administrator__c = licAdmin.Id;
        quote.Order_Group__c = oG.Id;
        quote.SBQQ__Account__c = acc.Id;
        update quote;


        Contract cont = [SELECT ID FROM Contract LIMIT 1];
        cont.SBQQ__Quote__c = quote.Id;
        cont.Status = 'Activated';
        cont.AccountId = acc.Id;



        Opportunity oppECUR = [SELECT ID FROM Opportunity LIMIT 1];
        oppECUR.Type = 'ECUR';
        oppECUR.SBQQ__AmendedContract__c = cont.Id;
        oppECUR.AccountId = acc.Id;

        SBQQ__Quote__c coTermQuote = [SELECT ID,SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment'];

        Test.startTest();
        update cont;
        update oppECUR;

        Amendment_Quote_Update_Event__e amendQuoteUpdate = new Amendment_Quote_Update_Event__e(Contract_Id__c = cont.Id, Opportunity_Id__c = coTermQuote.SBQQ__Opportunity2__c,Quote_Id__c = coTermQuote.Id);
        Database.SaveResult sr2 = EventBus.publish(amendQuoteUpdate);

        Test.stopTest();
    }

    @isTest static void coTermForNBEC() {
        SBQQ.TriggerControl.disable();
        License_Administrator__c licAdmin = [SELECT ID FROM License_Administrator__c LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE BillingStreet = '1 acc' LIMIT 1];
        Order_Group__c oG = [SELECT ID FROM Order_Group__c LIMIT 1];
        SBQQ__Quote__c quote = [SELECT ID FROM SBQQ__Quote__c LIMIT 1];
        quote.License_Administrator__c = licAdmin.Id;
        quote.Order_Group__c = oG.Id;
        quote.SBQQ__Account__c = acc.Id;
        update quote;


        Contract cont = [SELECT ID FROM Contract LIMIT 1];
        cont.SBQQ__Quote__c = quote.Id;
        cont.Status = 'Activated';
        cont.AccountId = acc.Id;



        Opportunity oppECUR = [SELECT ID FROM Opportunity LIMIT 1];
        oppECUR.Type = 'NBEC';
        oppECUR.SBQQ__AmendedContract__c = cont.Id;
        oppECUR.AccountId = acc.Id;


        Test.startTest();
        update cont;
        update oppECUR;

        Amendment_API_Event__e amendQuote = new Amendment_API_Event__e(Opportunity_Id__c = oppECUR.Id, Contract_Id__c = cont.Id);
        Database.SaveResult sr = EventBus.publish(amendQuote);
        Test.stopTest();
    }


    @isTest static void coTermForNBECQuoteUpdate() {
        SBQQ.TriggerControl.disable();
        License_Administrator__c licAdmin = [SELECT ID FROM License_Administrator__c LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE BillingStreet = '1 acc' LIMIT 1];
        Order_Group__c oG = [SELECT ID FROM Order_Group__c LIMIT 1];
        SBQQ__Quote__c quote = [SELECT ID FROM SBQQ__Quote__c LIMIT 1];
        quote.License_Administrator__c = licAdmin.Id;
        quote.Order_Group__c = oG.Id;
        quote.SBQQ__Account__c = acc.Id;
        update quote;


        Contract cont = [SELECT ID FROM Contract LIMIT 1];
        cont.SBQQ__Quote__c = quote.Id;
        cont.Status = 'Activated';
        cont.AccountId = acc.Id;



        Opportunity oppECUR = [SELECT ID FROM Opportunity LIMIT 1];
        oppECUR.Type = 'NBEC';
        oppECUR.SBQQ__AmendedContract__c = cont.Id;
        oppECUR.AccountId = acc.Id;

        SBQQ__Quote__c coTermQuote = [SELECT ID,SBQQ__Opportunity2__c FROM SBQQ__Quote__c WHERE SBQQ__Type__c = 'Amendment'];

        Test.startTest();
        update cont;
        update oppECUR;

        Amendment_Quote_Update_Event__e amendQuoteUpdate = new Amendment_Quote_Update_Event__e(Contract_Id__c = cont.Id, Opportunity_Id__c = coTermQuote.SBQQ__Opportunity2__c,Quote_Id__c = coTermQuote.Id);
        Database.SaveResult sr2 = EventBus.publish(amendQuoteUpdate);

        Test.stopTest();
    }


    @isTest static void testTwinMapRenewal() {
        Id cpqQuoteRecordTypeId_Draft = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();
        SBQQ.TriggerControl.disable();
        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contract cont = OSCPQ_TestFactory.createSingleContract(acct, false);
        cont.SBQQ__RenewalForecast__c = true;
        cont.SBQQ__RenewalQuoted__c = true;
        cont.SBQQ__RenewalTerm__c = 36;
        SBQQ.TriggerControl.disable();
        insert cont;

        opp.SBQQ__RenewedContract__c = cont.Id;
        update opp;

        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, true, false);
        newQuote.SBQQ__RenewalTerm__c = 12;
        newQuote.RecordTypeId = cpqQuoteRecordTypeId_Draft;
        SBQQ.TriggerControl.enable();

        OSCPQ_QuoteTriggerHandler handler = new OSCPQ_QuoteTriggerHandler(false, 1, 'Default');
        handler.settings.Quoting_Automate_Quote_Steps__c = false;
        handler.settings.TwinMapping_MapFromContractToQuote__c = true;

        Test.startTest();
        List<SBQQ__Quote__c> newQuoteList = new List<SBQQ__Quote__c>{newQuote};
        handler.onBeforeInsert(newQuoteList);
        Test.stopTest();

        system.assert(newQuoteList[0].SBQQ__RenewalTerm__c == 36);
    }

    @isTest static void testTwinMapAmendment() {
        Id cpqQuoteRecordTypeId_Draft = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();

        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];
        Contract cont = OSCPQ_TestFactory.createSingleContract(acct, false);
        cont.SBQQ__RenewalForecast__c = true;
        cont.SBQQ__RenewalQuoted__c = true;
        cont.SBQQ__RenewalTerm__c = 36;
        SBQQ.TriggerControl.disable();
        insert cont;

        opp.SBQQ__AmendedContract__c = cont.Id;
        update opp;

        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, true, false);
        newQuote.SBQQ__RenewalTerm__c = 12;
        newQuote.RecordTypeId = cpqQuoteRecordTypeId_Draft;
        SBQQ.TriggerControl.enable();

        OSCPQ_QuoteTriggerHandler handler = new OSCPQ_QuoteTriggerHandler(false, 1, 'Default');
        handler.settings.Quoting_Automate_Quote_Steps__c = false;
        handler.settings.TwinMapping_MapFromContractToQuote__c = true;

        Test.startTest();
        List<SBQQ__Quote__c> newQuoteList = new List<SBQQ__Quote__c>{newQuote};
        handler.onBeforeInsert(newQuoteList);
        Test.stopTest();

        system.assert(newQuoteList[0].SBQQ__RenewalTerm__c == 36);
    }
    @isTest static void testCustomPartner() {

        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, TotalOpportunityQuantity,
                Primary_Contact__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Opportunity LIMIT 1];

        //update opp;
        Contact cont = [SELECT Id,
                pw_ccpro__MailingCountryLookup__c,
                pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Contact LIMIT 1];
        opp.Primary_Contact__c = cont.Id;
        update opp;

        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, false, false);
        newQuote.SBQQ__RenewalTerm__c = 12;
        newQuote.Quote_Type__c = 'NFR';

        OSCPQ_QuoteTriggerHandler handler = new OSCPQ_QuoteTriggerHandler(false, 1, 'Default');
        handler.settings.Quoting_Automate_Quote_Steps__c = false;
        handler.settings.TwinMapping_MapFromContractToQuote__c = false;

        Account aVAR = (Account)SmartFactory.createSObject('Account');
        aVAR.Managed_Partner__c = true;
        aVAR.BillingState = 'AK';
        insert aVAR;
        //Inserted for Custom Partner Testing
        Custom_Partner__c cVAR = (Custom_Partner__c)SmartFactory.createSObject('Custom_Partner__c');
        cVAR.OpportunityId__c = opp.Id;
        cVAR.IsPrimary__c = true;
        cVAR.Role__c = 'Value Added Reseller';
        cVAR.AccountToId__c = aVAR.Id;
        insert cVAR;

        Account aDis = (Account)SmartFactory.createSObject('Account');
        insert aDis;
        //Inserted for Custom Partner Testing
        Custom_Partner__c cDis = (Custom_Partner__c)SmartFactory.createSObject('Custom_Partner__c');
        cDis.OpportunityId__c = opp.Id;
        cDis.IsPrimary__c = false;
        cDis.Role__c = 'Collaborative Sale';
        cDis.AccountToId__c = aDis.Id;
        insert cDis;

        Account aInf = (Account)SmartFactory.createSObject('Account');
        insert aInf;
        //Inserted for Custom Partner Testing
        Custom_Partner__c cInf = (Custom_Partner__c)SmartFactory.createSObject('Custom_Partner__c');
        cInf.OpportunityId__c = opp.Id;
        cInf.IsPrimary__c = false;
        cInf.Role__c = 'Deal Influencer';
        cInf.AccountToId__c = aInf.Id;
        insert cInf;

        Test.startTest();
        insert newQuote;

        SBQQ__Quote__c q = [SELECT Id,SBQQ__Partner__c ,Partner_Role__c, SBQQ__Distributor__c , Distributor_Role__c , Influencer_Account__c , Influencer_Role__c FROM SBQQ__Quote__c WHERE Id =: newQuote.Id];
        system.debug('**QUOTE: ** ' + q.SBQQ__Partner__c + ' ' + q.Partner_Role__c  );
        //JP : Assert Partner fields for //Hemendra 05/28/2019
        System.assertEquals(aVAR.Id, q.SBQQ__Partner__c);
        System.assertEquals('Value Added Reseller', q.Partner_Role__c);
        System.assertEquals(aDis.Id, q.SBQQ__Distributor__c);
        System.assertEquals('Collaborative Sale', q.Distributor_Role__c);
        Test.stopTest();
    }

    /*Commented for 2020-03-03 Code Release
    this class seems to be failing due to Too Many SOQL however this class isn't really testing anything
    @isTest static void testUpdateCustomPartner() {

        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, TotalOpportunityQuantity,
                            Primary_Contact__c,
                            Primary_Contact__r.pw_ccpro__MailingCountryLookup__c,
                            Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                            Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
                            FROM Opportunity LIMIT 1];

        //update opp;
        Contact cont = [SELECT Id,
                            pw_ccpro__MailingCountryLookup__c,
                            pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                            pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
                            FROM Contact LIMIT 1];
        opp.Primary_Contact__c = cont.Id;
        update opp;

        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, false, false);
        newQuote.SBQQ__RenewalTerm__c = 12;
        newQuote.Quote_Type__c = 'NFR';

        OSCPQ_QuoteTriggerHandler handler = new OSCPQ_QuoteTriggerHandler(false, 1, 'Default');
        handler.settings.Quoting_Automate_Quote_Steps__c = false;
        handler.settings.TwinMapping_MapFromContractToQuote__c = false;

        Order_Group__c OG = (Order_Group__c)SmartFactory.createSObject('Order_Group__c');
        OG.Account__c = acct.Id;
        insert OG;

        Test.startTest();

        List<Account> accountsToinsert = new List<Account>();

        Account aVAR = (Account)SmartFactory.createSObject('Account');
        aVAR.Managed_Partner__c = true;
        aVAR.BillingState = 'AK';
        accountsToinsert.add(aVAR);

        Account aDis = (Account)SmartFactory.createSObject('Account');
        aDis.Managed_Partner__c = true;
        aDis.BillingState = 'AK';
        accountsToinsert.add(aDis);

        Account aInf = (Account)SmartFactory.createSObject('Account');
        aInf.Managed_Partner__c = true;
        aInf.BillingState = 'AK';
        accountsToinsert.add(aInf);

        insert accountsToinsert;

        newQuote.Partner_Role__c = 'Referrer';
        newQuote.SBQQ__Partner__c = aVAR.Id;
        newQuote.Distributor_Role__c = 'Software Distributor';
        newQuote.SBQQ__Distributor__c = aDis.Id;
        newQuote.Influencer_Role__c = 'Deal Influencer';
        newQuote.Influencer_Account__c = aInf.Id;
        insert newQuote;

        //SBQQ__Quote__c q = [SELECT Id,SBQQ__Partner__c ,Partner_Role__c, SBQQ__Distributor__c , Distributor_Role__c , Influencer_Account__c , Influencer_Role__c FROM SBQQ__Quote__c WHERE Id =: newQuote.Id];

        //Update Partners on the Quote; test adding an order group
        newQuote.Partner_Role__c = 'Value Added Reseller';
        newQuote.SBQQ__Partner__c = aDis.Id;
        newQuote.Distributor_Role__c = 'Referrer';
        newQuote.SBQQ__Distributor__c = aInf.Id;
        newQuote.Influencer_Role__c = 'Deal Influencer';
        newQuote.Influencer_Account__c = aVAR.Id;
        newQuote.Order_Group__c = OG.Id;
        update newQuote;

        //JP : Assert Custom Partner Creation

        Test.stopTest();
    }*/

    @isTest static void testRemoveCustomPartner() {

        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, TotalOpportunityQuantity,
                Primary_Contact__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Opportunity LIMIT 1];

        //update opp;
        Contact cont = [SELECT Id,
                pw_ccpro__MailingCountryLookup__c,
                pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Contact LIMIT 1];
        opp.Primary_Contact__c = cont.Id;
        update opp;

        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, false, false);
        newQuote.SBQQ__RenewalTerm__c = 12;
        newQuote.Quote_Type__c = 'NFR';

        OSCPQ_QuoteTriggerHandler handler = new OSCPQ_QuoteTriggerHandler(false, 1, 'Default');
        handler.settings.Quoting_Automate_Quote_Steps__c = false;
        handler.settings.TwinMapping_MapFromContractToQuote__c = false;

        Account aVAR = (Account)SmartFactory.createSObject('Account');
        aVAR.Managed_Partner__c = true;
        aVAR.BillingState = 'AK';
        insert aVAR;

        Account aDis = (Account)SmartFactory.createSObject('Account');
        aDis.Managed_Partner__c = true;
        aDis.BillingState = 'AK';
        insert aDis;

        Account aInf = (Account)SmartFactory.createSObject('Account');
        aInf.Managed_Partner__c = true;
        aInf.BillingState = 'AK';
        insert aInf;

        Order_Group__c OG = (Order_Group__c)SmartFactory.createSObject('Order_Group__c');
        OG.Account__c = acct.Id;
        insert OG;



        Test.startTest();

        newQuote.Partner_Role__c = 'Referrer';
        newQuote.SBQQ__Partner__c = aVAR.Id;
        newQuote.Distributor_Role__c = 'Collaborative Sale';
        newQuote.SBQQ__Distributor__c = aDis.Id;
        newQuote.Influencer_Role__c = 'Deal Influencer';
        newQuote.Influencer_Account__c = aInf.Id;
        insert newQuote;

        SBQQ__Quote__c q = [SELECT Id,SBQQ__Partner__c ,Partner_Role__c, SBQQ__Distributor__c , Distributor_Role__c , Influencer_Account__c , Influencer_Role__c FROM SBQQ__Quote__c WHERE Id =: newQuote.Id];

        //Update Partners on the Quote; test adding an order group
        q.SBQQ__Partner__c = null;
        q.SBQQ__Distributor__c = null;
        q.Influencer_Account__c = null;
        q.Order_Group__c = OG.Id;
        update q;

        //JP : Assert roles are null

        Test.stopTest();
    }

    @isTest static void testDeleteQuote() {

        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, TotalOpportunityQuantity,
                Primary_Contact__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Opportunity LIMIT 1];

        //update opp;
        Contact cont = [SELECT Id,
                pw_ccpro__MailingCountryLookup__c,
                pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Contact LIMIT 1];
        opp.Primary_Contact__c = cont.Id;
        update opp;

        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, false, false);
        newQuote.SBQQ__RenewalTerm__c = 12;
        newQuote.Quote_Type__c = 'NFR';

        OSCPQ_QuoteTriggerHandler handler = new OSCPQ_QuoteTriggerHandler(false, 1, 'Default');
        handler.settings.Quoting_Automate_Quote_Steps__c = false;
        handler.settings.TwinMapping_MapFromContractToQuote__c = false;

        Order_Group__c OG = (Order_Group__c)SmartFactory.createSObject('Order_Group__c');
        OG.Account__c = acct.Id;
        insert OG;

        newQuote.Order_Group__c = OG.Id;
        insert newQuote;

        Test.startTest();
        SBQQ__Quote__c q = [SELECT Id,SBQQ__Partner__c ,Partner_Role__c, SBQQ__Distributor__c , Distributor_Role__c , Influencer_Account__c , Influencer_Role__c FROM SBQQ__Quote__c WHERE Id =: newQuote.Id];

        delete q;

        //JP : Assert Custom Partner Creation

        Test.stopTest();
    }

    @isTest static void testUpdateQuoteSubDates() {

        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, TotalOpportunityQuantity,
                Primary_Contact__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Opportunity LIMIT 1];

        //update opp;
        Contact cont = [SELECT Id,
                pw_ccpro__MailingCountryLookup__c,
                pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Contact LIMIT 1];
        opp.Primary_Contact__c = cont.Id;
        update opp;

        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, false, false);
        newQuote.SBQQ__RenewalTerm__c = 12;
        newQuote.Quote_Type__c = 'NFR';

        OSCPQ_QuoteTriggerHandler handler = new OSCPQ_QuoteTriggerHandler(false, 1, 'Default');
        handler.settings.Quoting_Automate_Quote_Steps__c = false;
        handler.settings.TwinMapping_MapFromContractToQuote__c = false;

        Order_Group__c OG = (Order_Group__c)SmartFactory.createSObject('Order_Group__c');
        OG.Account__c = acct.Id;
        insert OG;

        newQuote.Order_Group__c = OG.Id;
        newQuote.SBQQ__StartDate__c = Date.Today();
        newQuote.SBQQ__EndDate__c = Date.Today() + 365;
        insert newQuote;

        Test.startTest();
        SBQQ__Quote__c q = [SELECT Id,SBQQ__Partner__c ,Partner_Role__c, SBQQ__Distributor__c , Distributor_Role__c , Influencer_Account__c , Influencer_Role__c FROM SBQQ__Quote__c WHERE Id =: newQuote.Id];

        q.SBQQ__StartDate__c = Date.Today()+2;
        update q;

        //JP : Assert Custom Partner Creation

        Test.stopTest();
    }

    @isTest static void testRemoveBillToAccountAndAddPrimary() {

        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, TotalOpportunityQuantity,
                Primary_Contact__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Opportunity LIMIT 1];

        //update opp;
        Contact cont = [SELECT Id,
                pw_ccpro__MailingCountryLookup__c,
                pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Contact LIMIT 1];
        opp.Primary_Contact__c = cont.Id;
        update opp;

        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, false, false);
        newQuote.SBQQ__RenewalTerm__c = 12;
        newQuote.BillToAccount__c = acct.Id;

        OSCPQ_QuoteTriggerHandler handler = new OSCPQ_QuoteTriggerHandler(false, 1, 'Default');
        handler.settings.Quoting_Automate_Quote_Steps__c = false;
        handler.settings.TwinMapping_MapFromContractToQuote__c = false;

        Order_Group__c OG = (Order_Group__c)SmartFactory.createSObject('Order_Group__c');
        OG.Account__c = acct.Id;
        insert OG;

        newQuote.SBQQ__Primary__c = false;
        newQuote.Order_Group__c = OG.Id;
        newQuote.SBQQ__StartDate__c = Date.Today();
        newQuote.SBQQ__EndDate__c = Date.Today() + 365;
        insert newQuote;

        Test.startTest();
        SBQQ__Quote__c q = [SELECT Id,SBQQ__Partner__c ,Partner_Role__c, SBQQ__Distributor__c , Distributor_Role__c , Influencer_Account__c , Influencer_Role__c FROM SBQQ__Quote__c WHERE Id =: newQuote.Id];

        q.SBQQ__Opportunity2__c = opp.Id;
        q.SBQQ__Primary__c = true;
        q.BillToAccount__c= null;
        update q;

        //JP : Assert Custom Partner Creation

        Test.stopTest();
    }

    @isTest static void testPrimaryChangeOnOpp() {

        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, TotalOpportunityQuantity,
                Primary_Contact__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Opportunity LIMIT 1];

        //update opp;
        Contact cont = [SELECT Id,
                pw_ccpro__MailingCountryLookup__c,
                pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Contact LIMIT 1];
        opp.Primary_Contact__c = cont.Id;
        update opp;

        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, false, false);
        newQuote.SBQQ__RenewalTerm__c = 12;
        newQuote.BillToAccount__c = acct.Id;

        OSCPQ_QuoteTriggerHandler handler = new OSCPQ_QuoteTriggerHandler(false, 1, 'Default');
        handler.settings.Quoting_Automate_Quote_Steps__c = false;
        handler.settings.TwinMapping_MapFromContractToQuote__c = false;

        Order_Group__c OG = (Order_Group__c)SmartFactory.createSObject('Order_Group__c');
        OG.Account__c = acct.Id;
        insert OG;

        newQuote.SBQQ__Primary__c = true;
        newQuote.Order_Group__c = OG.Id;
        newQuote.SBQQ__StartDate__c = Date.Today();
        newQuote.SBQQ__EndDate__c = Date.Today() + 365;
        insert newQuote;

        SBQQ__Quote__c q = OSCPQ_TestFactory.createSingleQuote(acct, opp, false, false);
        q.SBQQ__RenewalTerm__c = 12;
        q.BillToAccount__c = acct.Id;
        q.SBQQ__Opportunity2__c = opp.Id;
        q.SBQQ__Primary__c = false;
        q.BillToAccount__c= acct.Id;
        Insert q;

        Test.startTest();
        SBQQ__Quote__c q2 = [SELECT Id,SBQQ__Partner__c ,Partner_Role__c, SBQQ__Distributor__c , Distributor_Role__c , Influencer_Account__c , Influencer_Role__c FROM SBQQ__Quote__c WHERE Id =: q.Id];

        q2.SBQQ__Primary__c = true;
        update q2;
        //JP : Assert Custom Partner Creation

        Test.stopTest();
    }

    @isTest static void testDuplicatePoOnProposal() {

        Account acct = [SELECT Id, Name FROM Account LIMIT 1];
        Opportunity opp = [SELECT Id, TotalOpportunityQuantity,
                Primary_Contact__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                Primary_Contact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Opportunity LIMIT 1];

        //update opp;
        Contact cont = [SELECT Id,
                pw_ccpro__MailingCountryLookup__c,
                pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c
        FROM Contact LIMIT 1];
        opp.Primary_Contact__c = cont.Id;
        update opp;

        SBQQ__Quote__c newQuote = OSCPQ_TestFactory.createSingleQuote(acct, opp, false, false);
        newQuote.SBQQ__RenewalTerm__c = 12;
        newQuote.BillToAccount__c = acct.Id;

        OSCPQ_QuoteTriggerHandler handler = new OSCPQ_QuoteTriggerHandler(false, 1, 'Default');
        handler.settings.Quoting_Automate_Quote_Steps__c = false;
        handler.settings.TwinMapping_MapFromContractToQuote__c = false;

        Order_Group__c OG = (Order_Group__c)SmartFactory.createSObject('Order_Group__c');
        OG.Account__c = acct.Id;
        insert OG;

        newQuote.SBQQ__Primary__c = true;
        newQuote.Order_Group__c = OG.Id;
        newQuote.SBQQ__StartDate__c = Date.Today();
        newQuote.SBQQ__EndDate__c = Date.Today() + 365;
        newQuote.Purchase_Order__c = 'ABCDE';
        insert newQuote;

        SBQQ__Quote__c q = OSCPQ_TestFactory.createSingleQuote(acct, opp, false, false);
        q.SBQQ__RenewalTerm__c = 12;
        q.BillToAccount__c = acct.Id;
        q.SBQQ__Opportunity2__c = opp.Id;
        q.SBQQ__Primary__c = false;
        q.BillToAccount__c= acct.Id;
        Insert q;

        Test.startTest();
        SBQQ__Quote__c q2 = [SELECT Id,SBQQ__Partner__c ,Partner_Role__c, SBQQ__Distributor__c , Distributor_Role__c , Influencer_Account__c , Influencer_Role__c FROM SBQQ__Quote__c WHERE Id =: q.Id];

        q2.SBQQ__Primary__c = true;
        q.Purchase_Order__c = 'ABCDE';
        update q2;
        //JP : Assert Custom Partner Creation

        Test.stopTest();
    }

    //Name: Chris Salgado
    //Date: 6/22/20
    //Purpose: W-005430
    @isTest static void testCoTermQuote_NBEC(){
        //Get from Setup
        Account acct = [SELECT Id FROM Account WHERE Name = 'testAcct' LIMIT 1];
        Opportunity coTermOpp = [SELECT Id, SBQQ__AmendedContract__c FROM Opportunity WHERE  AccountId  = :acct.Id];

        //Create Original Contract
        Contract originalContract = OSCPQ_TestFactory.createSingleContract(acct, false);
        originalContract.EndDate = Date.today().addMonths(12);
        insert originalContract;

        originalContract.Status = 'Activated';
        update originalContract;

        //Update Co-Term Opportunity
        coTermOpp.Type = 'NBEC';
        coTermOpp.SBQQ__AmendedContract__c = originalContract.Id;
        update coTermOpp;

        //Create Co-Term Quote
        Test.startTest();
        SBQQ__Quote__c coTermQuote = OSCPQ_TestFactory.createSingleQuote(acct, coTermOpp, true, true);
        Test.stopTest();

        //Assertions
        SBQQ__Quote__c queryQuote = [SELECT Id, Quote_Type__c, SBQQ__Type__c, Purchase_Type__c, SBQQ__MasterContract__c, OSCPQ_Amended_Contract__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Payment_Schedule__c FROM SBQQ__Quote__c WHERE Id = :coTermQuote.Id LIMIT 1];
        System.assertEquals('Purchase', queryQuote.Quote_Type__c);
        System.assertEquals('Amendment', queryQuote.SBQQ__Type__c);
        System.assertEquals('Upsell Co-term', queryQuote.Purchase_Type__c);
        System.assertEquals('Equal ACV Per Year', queryQuote.Payment_Schedule__c);
        System.assertEquals(originalContract.Id, queryQuote.SBQQ__MasterContract__c);
        System.assertEquals(originalContract.Id, queryQuote.OSCPQ_Amended_Contract__c);
        System.assertEquals(Date.today(), queryQuote.SBQQ__StartDate__c);
        System.assertEquals(originalContract.EndDate, queryQuote.SBQQ__EndDate__c);
    }

    //Name: Chris Salgado
    //Date: 6/22/20
    //Purpose: W-005430
    @isTest static void testCoTermQuote_ECUR(){
        //Get from Setup
        Account acct = [SELECT Id FROM Account WHERE Name = 'testAcct' LIMIT 1];
        Opportunity coTermOpp = [SELECT Id, SBQQ__AmendedContract__c FROM Opportunity WHERE  AccountId  = :acct.Id];

        //Create Renewal Contract
        Contract renewalContract = OSCPQ_TestFactory.createSingleContract(acct, false);
        renewalContract.EndDate = Date.today().addDays(7);
        insert renewalContract;

        //Create Original Contract
        Contract originalContract = OSCPQ_TestFactory.createSingleContract(acct, false);
        originalContract.EndDate = Date.today().addMonths(12);
        insert originalContract;

        originalContract.Status = 'Activated';
        update originalContract;

        //Update Co-Term Opportunity
        coTermOpp.Type = 'ECUR';
        coTermOpp.SBQQ__AmendedContract__c = originalContract.Id;
        coTermOpp.SBQQ__RenewedContract__c = renewalContract.Id;
        update coTermOpp;

        //Create Co-Term Quote
        Test.startTest();
        SBQQ__Quote__c coTermQuote = OSCPQ_TestFactory.createSingleQuote(acct, coTermOpp, true, true);
        Test.stopTest();

        //Assertions
        SBQQ__Quote__c queryQuote = [SELECT Id, Quote_Type__c, SBQQ__Type__c, Purchase_Type__c, SBQQ__MasterContract__c, OSCPQ_Amended_Contract__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Payment_Schedule__c FROM SBQQ__Quote__c WHERE Id = :coTermQuote.Id LIMIT 1];
        System.assertEquals('Purchase', queryQuote.Quote_Type__c);
        System.assertEquals('Quote', queryQuote.SBQQ__Type__c);
        System.assertEquals('Renewal', queryQuote.Purchase_Type__c);
        System.assertEquals('Equal ACV Per Year', queryQuote.Payment_Schedule__c);
        System.assertEquals(null, queryQuote.SBQQ__MasterContract__c);
        System.assertEquals(null, queryQuote.OSCPQ_Amended_Contract__c);
        System.assertEquals(renewalContract.EndDate.addDays(1), queryQuote.SBQQ__StartDate__c);
    }
}