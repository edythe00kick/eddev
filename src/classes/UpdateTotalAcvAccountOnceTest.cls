/*
 * Class Name - UpdateTotalAcvAccountOnceTest
 * 
 * %W% %E% Grazitti Team
 * This is the test class for "UpdateTotalAcvAccountOnce" batch class.
 */

/**
 * This class contains different methods to cover the code.
 * 
 * @author Hemendra Singh Rajawat
 * @version 1.0 July 28, 2018
 */

@isTest
public class UpdateTotalAcvAccountOnceTest {
    // Standard price book entry ID
    private static Id priceBookEntryId = Test.getStandardPricebookId();

    /**
     * Test when agreement is expired and status category is "In Effect" and 
     * status is Activated"
     */

    @isTest
    public static void testScenario1() {
        /*Account acc = OrgWideTestUtil.createAccount(true); //Commented By: Sharma Nemani | Date: 06/26/2019

        List<Apttus__APTS_Agreement__c> ags 
            = new List<Apttus__APTS_Agreement__c>();

        Apttus__APTS_Agreement__c ag1 
            = OrgWideTestUtil.createApttusAgreement(false, acc.Id);
        ag1.Apttus__Status_Category__c = 'In Effect';
        ag1.Apttus__Status__c = 'Activated';
        ag1.Contract_Start_Date__c = System.today() - 10;
        ag1.Contract_End_Date__c = System.today() + 10;
        ag1.Terms_InMonths__c = 1;
        ag1.Terms_InYears__c = 0;
        ags.add(ag1);

        Apttus__APTS_Agreement__c ag2 
            = OrgWideTestUtil.createApttusAgreement(false, acc.Id);
        ag2.Apttus__Status_Category__c = 'In Effect';
        ag2.Apttus__Status__c = 'Activated';
        ag2.Contract_Start_Date__c = System.today() - 10;
        ag2.Contract_End_Date__c = System.today() + 10;
        ag2.Terms_InMonths__c = 1;
        ag2.Terms_InYears__c = 0;
        ags.add(ag2);

        insert ags;

        Product2 prod = OrgWideTestUtil.createProduct(false);
        prod.family = 'Alteryx Software';
        insert prod;

        PricebookEntry pbe 
            = OrgWideTestUtil.createPricebookEntry(true, prod.Id, 
                                                   priceBookEntryId);

        List<Apttus__AgreementLineItem__c> aglis 
            = new List<Apttus__AgreementLineItem__c>();

        Apttus__AgreementLineItem__c agli1 = new Apttus__AgreementLineItem__c();
        agli1.Apttus__AgreementId__c = ag1.Id;
        agli1.Apttus__ProductId__c = prod.Id;
        agli1.Apttus__Quantity__c = 1;
        agli1.Apttus__NetPrice__c = 100;
        aglis.add(agli1);

        Apttus__AgreementLineItem__c agli2 = new Apttus__AgreementLineItem__c();
        agli2.Apttus__AgreementId__c = ag1.Id;
        agli2.Apttus__ProductId__c = prod.Id;
        agli2.Apttus__Quantity__c = 1;
        agli2.Apttus__NetPrice__c = 500;
        aglis.add(agli2);

        Apttus__AgreementLineItem__c agli3 = new Apttus__AgreementLineItem__c();
        agli3.Apttus__AgreementId__c = ag2.Id;
        agli3.Apttus__ProductId__c = prod.Id;
        agli3.Apttus__Quantity__c = 1;
        agli3.Apttus__NetPrice__c = 300;
        aglis.add(agli3);
        
        insert aglis;

        ag1.Contract_End_Date__c = System.today() - 1;
        update ag1;

        Test.startTest();

        UpdateTotalAcvAccountOnce utaaot = new UpdateTotalAcvAccountOnce();
        Database.executeBatch(utaaot);

        Test.stopTest();*/
    }
    // Author: Sharma Nemani | Date: 06/26/2019
    static testMethod void testUpdateTotalAcvAccountOnce1() {
        Account acc = new Account();
        Acc.name = 'testAcc';
        Acc.ShippingCountry = 'Germany';
        Acc.ShippingCity = 'Frankfurt';
        Acc.ShippingState = 'Hamburg';
        Acc.ShippingPostalCode = '60306';
        insert Acc;
        
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        cont.StartDate = system.today().addDays(-40);
        cont.CurrencyIsoCode = 'USD';
        cont.Status_Category__c = 'In Effect';
        //cont.Status = 'Activated';
        cont.Annual_Software_Contract_Value__c = 1;
        //cont.Annual_Software_Contract_Value__c = 1;
        cont.ContractTerm  = 1;
        insert cont;
        
        List<Contract> lstContract = [select id,AccountId,StartDate,CurrencyIsoCode,Annual_Software_Contract_Value__c,ContractTerm from contract limit 1];
        lstContract[0].Status = 'Activated';
        update lstContract;
        
        Test.startTest();
        	database.executeBatch(new UpdateTotalAcvAccountOnce(),10);
        	
        Test.stopTest();
        
    }
}