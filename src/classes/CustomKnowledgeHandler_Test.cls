/**
 * Created by csalgado on 12/19/2019.
 */
@isTest
public with sharing class CustomKnowledgeHandler_Test {
    @testSetup static void setup() {
        system.debug('**CSALGADO** - Start CKAHandler Test Setup');

        Knowledge__kav newKA = new Knowledge__kav();
        newKA.RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Break Fix').getRecordTypeId();
        newKA.Title = 'Test New Article Title';
        newKA.UrlName = 'TestArticleURLName';
        newKA.Summary = 'Test Article Summary';
        newKA.Environment_Details__c = 'Test ED';
        newKA.Cause__c = 'Test Cause';
        newKA.Resolution__c = 'Test Resolution';
        insert newKA;
        system.debug('**CSALGADO** - After KA Insert');
    }

    @isTest static void insertKA_populateCKA() {
        system.debug('**CSALGADO** - Start CKAHandler Test - insertKA_populateCKA');

        Test.startTest();
        //Get Test Knowledge Article
        Knowledge__kav newKA = [SELECT Id, ArticleNumber, Custom_Knowledge_Article__c, PublishStatus, ValidationStatus
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Query : ' + newKA);

        //Query for Custom Knowledge Article
        Custom_Knowledge_Article__c newCKA = [SELECT Id, Article_Number__c
                                            FROM Custom_Knowledge_Article__c
                                            WHERE Id = :newKA.Custom_Knowledge_Article__c LIMIT 1];
        Test.stopTest();

        system.debug('**CSALGADO** - Before Assert');
        system.assertEquals(newCKA.Article_Number__c, newKA.ArticleNumber);
        system.assertEquals(newCKA.Id, newKA.Custom_Knowledge_Article__c);
    }
}