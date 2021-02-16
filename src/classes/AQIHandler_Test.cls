/**
 * Created by csalgado on 3/3/2020.
 */
@isTest
public with sharing class AQIHandler_Test {
    @testSetup static void setup() {
        system.debug('**CSALGADO** - Start DellBoomiKnowledge Test Setup');

        //Create Knowledge
        Knowledge__kav newKA = new Knowledge__kav();
        newKA.RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Break Fix').getRecordTypeId();
        newKA.Title = 'Test New Article Title';
        newKA.UrlName = 'TestArticleURLName';
        newKA.Summary = 'Test Article Summary';
        newKA.Environment_Details__c = 'Test ED';
        newKA.Cause__c = 'Test Cause';
        newKA.Resolution__c = 'Test Resolution';
        insert newKA;

        //Create AQI Record
        aqi_ltng_mng__Article_Quality__c newAQI = new aqi_ltng_mng__Article_Quality__c();
        newAQI.aqi_ltng_mng__Agent__c=OrgWideTestUtil.getUser().Id;
        newAQI.Name = 'AQI for article TEST – 0';
        newAQI.aqi_ltng_mng__AQ_Score__c = 50;
        newAQI.aqi_ltng_mng__Content_Complete__c = true;
        newAQI.aqi_ltng_mng__Internal_Notes__c='<p>test</p>';
        newAQI.aqi_ltng_mng__Knowledge_Article_Version_Id__c = /*(String)*/ newKA.Id;
        newAQI.aqi_ltng_mng__Article_Type__c='01219000000dDZ5AAM';
        newAQI.aqi_ltng_mng__Article_Link__c='https://alteryx--UAT.cs24.my.salesforce.com/' + newKA.Id;
        newAQI.aqi_ltng_mng__Article_Number__c='000000001';
        newAQI.aqi_ltng_mng__Article_Title__c='Testing';
        newAQI.aqi_ltng_mng__Article_Version__c=0.0;

        insert newAQI;
    }

    @isTest static void insertAQI() {
        Test.startTest();
        Knowledge__kav newKAV = [SELECT Id
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];


        aqi_ltng_mng__Article_Quality__c newAQI = [SELECT Id
                                                    FROM aqi_ltng_mng__Article_Quality__c
                                                    WHERE aqi_ltng_mng__Knowledge_Article_Version_Id__c = :newKAV.Id LIMIT 1];
        Test.stopTest();

        System.assert(newAQI != null);
    }
}