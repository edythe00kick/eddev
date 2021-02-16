/**
 * Created by ewong on 1/21/2021.
 */

@IsTest
public class gtmPlatformEventUpdateTest {
    @TestSetup static void setup() {

        Account acc = (Account)SmartFactory.createSObject('Account');
        acc.Global_Ranking__c = null;
        insert acc;

        Contact con = (Contact)SmartFactory.createSObject('Contact');
        con.AccountId = acc.Id;
        insert con;

        Opportunity oppOne = (Opportunity)SmartFactory.createSObject('Opportunity');
        oppOne.AccountId = acc.Id;
        oppOne.Primary_Contact__c = con.Id;
        insert oppOne;

        Opportunity oppTwo = (Opportunity)SmartFactory.createSObject('Opportunity');
        oppTwo.AccountId = acc.Id;
        oppTwo.Primary_Contact__c = con.Id;
        insert oppTwo;


    }

    @IsTest static void gtmOppGlobalRankingUpdateTest(){

        //To get picklist value "Contributor"
        String objectName = 'Account';
        String fieldName ='Global_Ranking__c';
        String gtmAccGlobalRanking;

        Schema.SObjectType s = Schema.getGlobalDescribe().get(objectName) ;
        Schema.DescribeSObjectResult r = s.getDescribe() ;
        Map<String,Schema.SObjectField> fields = r.fields.getMap() ;
        Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            System.debug('ed test ' + pickListVal.getLabel() +' '+pickListVal.getValue());
            gtmAccGlobalRanking =  pickListVal.getValue();
        }


        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.Global_Ranking__c = gtmAccGlobalRanking;

        Test.startTest();

        update acc;
        Test.stopTest();

        System.assertEquals(2,[SELECT COUNT() FROM Opportunity WHERE AccountId = :acc.Id AND Global_Ranking__c = :gtmAccGlobalRanking]);

    }

    @IsTest static void gtmAccountUpdateOnOppTest(){

    }

}