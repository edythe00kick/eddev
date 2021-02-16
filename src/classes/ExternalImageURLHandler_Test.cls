/**
 * Created by csalgado on 3/6/2020.
 */
@isTest
public with sharing class ExternalImageURLHandler_Test {
    @testSetup static void setup() {
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

        System.debug('**CSALGADO** KA.Resolution.length : ' + newKA.Resolution__c.stripHtmlTags().length());

        Knowledge__kav newKAV = [SELECT Id, Custom_Knowledge_Article__c
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];

        External_Image_URL__c newEIU = new External_Image_URL__c();
        newEIU.Custom_Knowledge_Article__c = newKAV.Custom_Knowledge_Article__c;
        insert newEIU;
    }

    @isTest static void insertEIU() {

        Knowledge__kav newKA = [SELECT Id, Custom_Knowledge_Article__c
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];

        External_Image_URL__c updateEIU = [SELECT Id, External_URL__c
                                            FROM External_Image_URL__c
                                            WHERE Custom_Knowledge_Article__c = :newKA.Custom_Knowledge_Article__c LIMIT 1];

        Test.startTest();
            updateEIU.External_URL__c = 'test ' + '<img src=https://www.test.com />' + ' test2 ';
            update updateEIU;
        Test.stopTest();

        Knowledge__kav newKAV = [SELECT Id, Resolution__c
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];

        System.debug('**CSALGADO** KAV.Resolution.length : ' + newKAV.Resolution__c.stripHtmlTags().length());
        System.assert(newKAV.Resolution__c.stripHtmlTags().length() > 15);
    }
}