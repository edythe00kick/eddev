/**
 * Created by csalgado on 3/3/2020.
 */
@IsTest
public with sharing class DellBoomiKnowledgeTest {
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
        system.debug('**CSALGADO** - After KA Insert');
    }

    @isTest static void publishKA_sendToCommunity() {
        //Get Test Knowledge Article
        Knowledge__kav newKA = [SELECT Id, KnowledgeArticleId, ArticleNumber, Custom_Knowledge_Article__c, PublishStatus, ValidationStatus
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Query : ' + newKA);

        Test.startTest();
        KbManagement.PublishingService.publishArticle(newKA.KnowledgeArticleId, true);
        Test.stopTest();

        //Query for Custom Knowledge Article
        Custom_Knowledge_Article__c newCKA = [SELECT Id, Article_Number__c, Send_to_Community__c
                                            FROM Custom_Knowledge_Article__c
                                            WHERE Id = :newKA.Custom_Knowledge_Article__c LIMIT 1];
        system.debug('**CSALGADO** - Post Update - After Custom Knowledge Query : ' + newCKA);

        system.debug('**CSALGADO** - Before Assert');
        //Test Assertions
        system.assertEquals(newCKA.Send_to_Community__c, false);
    }
}