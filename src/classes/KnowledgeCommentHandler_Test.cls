/**
 * Created by csalgado on 12/19/2019.
 */
@isTest
public with sharing class KnowledgeCommentHandler_Test {
    //Test Setup Description: Create new Knowledge Article and new Knowledge Comment
    @testSetup static void setup(){
        system.debug('**CSALGADO** - Start KCHandler Test Setup');

        Knowledge__kav newKA = new Knowledge__kav();
        newKA.RecordTypeId = Schema.SObjectType.Knowledge__kav.getRecordTypeInfosByName().get('Break Fix').getRecordTypeId();
        newKA.Title = 'Test Article Title';
        newKA.UrlName = 'TestArticleURLName';
        newKA.Summary = 'Test Article Summary';
        newKA.Environment_Details__c = 'Test ED';
        newKA.Cause__c = 'Test Cause';
        newKA.Resolution__c = 'Test Resolution';
        insert newKA;
        system.debug('**CSALGADO** - After KA Insert');

        Knowledge_Comment__c newKC = new Knowledge_Comment__c();
        newKC.Knowledge__c = newKA.Id;
        newKC.Comment__c = 'Test Comment';
        newKC.Active__c = true;
        insert newKC;
        system.debug('**CSALGADO** - After KC Insert');

    }

    //Test Script Description: Test new active KC created
    //Acceptance Criteria: CKA is updated to flagged
    @isTest static void insertKC(){
        system.debug('**CSALGADO** - Start KCHandler Test - insertKC');

        Test.startTest();
        Knowledge__kav newKA = [SELECT Id, Flagged__c, Custom_Knowledge_Article__c FROM Knowledge__kav LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Query : ' + newKA);

        Custom_Knowledge_Article__c newCKA = [SELECT Id, Flagged__c FROM Custom_Knowledge_Article__c WHERE Id = :newKa.Custom_Knowledge_Article__c LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Comment Query : ' + newCKA);
        Test.stopTest();

        system.debug('**CSALGADO** - Before Assert');
        system.assert(newKA.Id != null);
        system.assertEquals(true, newCKA.Flagged__c);
        system.assertEquals(true, newKA.Flagged__c);
    }

    //Test Script Description: Test change KC to inactive
    //Acceptance Criteria: CKA is updated to not flagged
    @isTest static void updateKC(){
        system.debug('**CSALGADO** - Start KCHandler Test - updateKC');

        Knowledge_Comment__c newKC = [SELECT Id, Active__c FROM Knowledge_Comment__c LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Comment Query : ' + newKC);

        Test.startTest();
        //Update the Knowledge Comment to inactive
        newKC.Active__c = false;
        update newKC;
        Test.stopTest();

        Knowledge__kav newKA = [SELECT Id, Flagged__c, Custom_Knowledge_Article__c FROM Knowledge__kav LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Query : ' + newKA);

        Custom_Knowledge_Article__c newCKA = [SELECT Id, Flagged__c FROM Custom_Knowledge_Article__c WHERE Id = :newKa.Custom_Knowledge_Article__c LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Comment Query : ' + newCKA);

        system.debug('**CSALGADO** - Before Assert');
        system.assert(newKA.Id != null);
        system.assertEquals(false, newCKA.Flagged__c);
        system.assertEquals(false, newKA.Flagged__c);
    }

}