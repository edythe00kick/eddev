/**
 * Created by ewong on 7/7/2020.
 * W-005163
 */

@IsTest
public class BatchLPStampOnSubscriptionsTest {

    @testSetup static void setup(){

        //Create Test Data

        //original deal data set
        Account acct = (Account)SmartFactory.createSObject('Account');
        insert acct;

        Contact cont = (Contact)SmartFactory.createSObject('Contact');
        cont.AccountId = acct.Id;
        insert cont;

        SBQQ.TriggerControl.disable();

        SBQQ__Quote__c originalQuote = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        originalQuote.SBQQ__PrimaryContact__c = cont.Id; //original quote
        originalQuote.Billing_Contact__c = cont.Id;
        originalQuote.SBQQ__Account__c = acct.Id;
        insert originalQuote;

        SBQQ__QuoteLine__c originalQL = (SBQQ__QuoteLine__c)SmartFactory.createSObject('SBQQ__QuoteLine__c');
        originalQL.SBQQ__Quote__c = originalQuote.Id;
        insert originalQL;

        Product2 product = (Product2)SmartFactory.createSObject('Product2');
        product.Family = 'Alteryx Software';
        insert product;

        License_Product__c originalLicProduct = (License_Product__c)SmartFactory.createSObject('License_Product__c');
        originalLicProduct.Quote__c = originalQuote.Id;
        originalLicProduct.Quote_Line__c = originalQL.Id;
        originalLicProduct.Activation_Id__c = 'TestLicenseKey123';
        insert originalLicProduct;

        Contract con = (Contract)SmartFactory.createSObject('Contract');
        con.SBQQ__Quote__c =  originalQuote.Id;
        con.AccountId = acct.Id;
        con.Status = 'draft';
        insert con;

        SBQQ__Subscription__c sub = (SBQQ__Subscription__c)SmartFactory.createSObject('SBQQ__Subscription__c');
        sub.SBQQ__Contract__c = con.Id;
        sub.License_Product__c = originalLicProduct.Id;
        sub.SBQQ__QuoteLine__c = originalQL.Id;
        sub.SBQQ__RequiredByProduct__c = product.Id;
        insert sub;



        //Co-Term Data Set

        SBQQ__Quote__c newQuote = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        newQuote.SBQQ__PrimaryContact__c = cont.Id; //original quote
        newQuote.Billing_Contact__c = cont.Id;
        newQuote.SBQQ__Account__c = acct.Id;
        insert newQuote;

        List<SBQQ__QuoteLine__c> qLineList = (List<SBQQ__QuoteLine__c>)SmartFactory.createSObjectList('SBQQ__QuoteLine__c',false,2);
        qLineList[0].SBQQ__Quote__c = newQuote.Id;
        qLineList[1].SBQQ__Quote__c = newQuote.Id;
        insert qLineList;

        License_Product__c newLicProduct = (License_Product__c)SmartFactory.createSObject('License_Product__c');
        newLicProduct.Quote__c = newQuote.Id;
        newLicProduct.Quote_Line__c = qLineList[0].Id;
        newLicProduct.Activation_Id__c = 'TestLicenseKey456';
        insert newLicProduct;

        List<SBQQ__Subscription__c> subsList = (List<SBQQ__Subscription__c>)SmartFactory.createSObjectList('SBQQ__Subscription__c',false,2);
        subsList[0].SBQQ__Contract__c = con.Id;
        subsList[0].SBQQ__QuoteLine__c = qLineList[0].Id;
        subsList[0].SBQQ__RequiredByProduct__c = product.Id;
        subsList[1].SBQQ__Contract__c = con.Id;
        subsList[1].SBQQ__QuoteLine__c = qLineList[1].Id;
        subsList[1].SBQQ__RequiredByProduct__c = product.Id;
        subsList[1].SBQQ__RevisedSubscription__c = sub.Id;
        subsList[1].SBQQ__OriginalQuoteLine__c = originalQL.Id;
        insert subsList;

    }

    testMethod static void testNewProductLPStamping(){

        Test.startTest();

        BatchLPStampOnSubscriptions bLP = new BatchLPStampOnSubscriptions();
        Id batchId = Database.executeBatch(bLP);
        Test.stopTest();

        System.assertEquals(3,[SELECT COUNT() FROM SBQQ__Subscription__c WHERE License_Product__c != null]);
        System.assertEquals(2,[SELECT COUNT() FROM SBQQ__Subscription__c WHERE License_Key__c = 'TestLicenseKey123']);
        System.assertEquals(1,[SELECT COUNT() FROM SBQQ__Subscription__c WHERE License_Key__c = 'TestLicenseKey456']);
    }

}