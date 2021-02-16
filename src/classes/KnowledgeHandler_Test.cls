/**
 * Created by csalgado on 12/19/2019.
 */
@isTest
public with sharing class KnowledgeHandler_Test {
    //Test Setup Description: Create new Knowledge Article
    @testSetup static void setup(){
        system.debug('**CSALGADO** - Start KAVHandler Test Setup');

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

    //Test Script Description: Test new KAV created with no prior CKA
    //Acceptance Criteria: CKA is created and KAV is updated with CKA
    @isTest static void insertKA_missingCKA(){
        system.debug('**CSALGADO** - Start KAVHandler Test - insertKA_missingCKA');

        Test.startTest();
        //Query for Knowledge Article
        Knowledge__kav newKA = [SELECT Id, ArticleNumber, Custom_Knowledge_Article__c, PublishStatus, ValidationStatus
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Query : ' + newKA);

        //Query for Custom Knowledge Article
        Custom_Knowledge_Article__c newCKA = [SELECT Id, Article_Number__c
                                            FROM Custom_Knowledge_Article__c
                                            WHERE Id = :newKA.Custom_Knowledge_Article__c LIMIT 1];
        system.debug('**CSALGADO** - After Custom Knowledge Query : ' + newCKA);
        Test.stopTest();

        system.debug('**CSALGADO** - Before Assert');
        //Test Assertions

        //KA Assertions
        //system.assert(newKA.ArticleNumber != null);
        //system.assert(newKA.Custom_Knowledge_Article__c != null);
        //system.assertEquals('Draft', newKA.PublishStatus);

        //CKA Assertions
        //system.assert(newCKA != null);
        //system.assert(newCKA.Article_Number__c != null);
        system.assertEquals(newCKA.Article_Number__c, newKA.ArticleNumber);
        system.assertEquals(newCKA.Id, newKA.Custom_Knowledge_Article__c);

    }

    //ISSUE: Article Number & Version Number is not writeable
    //Test Script Description: Test new KAV created with a prior existing CKA
    //Acceptance Criteria: KAV is updated with CKA and CKA is updated
    @isTest static void insertKA_existingCKA(){
        system.debug('**CSALGADO** - Start KAVHandler Test - insertKA_existingCKA');

        //Query for Knowledge Article
        Knowledge__kav newKA = [SELECT Id, ArticleNumber
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Query : ' + newKA);

        //Query for the abstract Knowledge Article
        KnowledgeArticle newKA_abstract = [SELECT Id
                                        FROM KnowledgeArticle
                                        WHERE ArticleNumber = :newKA.ArticleNumber LIMIT 1];
        system.debug('**CSALGADO** - After KnowledgeArticle Query : ' + newKA_abstract);

        Test.startTest();
        //Publish abstract Article
        KbManagement.PublishingService.publishArticle(newKA_abstract.Id, true);
        //Edit abstract Article as Draft
        Id draftArticleId = KbManagement.PublishingService.editOnlineArticle(newKA_abstract.Id, false);
        Test.stopTest();

        //Query for number of Knowledge Articles
        Integer countOfKAs = [SELECT Id, ArticleNumber, Custom_Knowledge_Article__c, PublishStatus, ValidationStatus, VersionNumber
        FROM Knowledge__kav].size();
        system.debug('**CSALGADO** - After All Knowledge Count Query : ' + countOfKAs);

        //Query for Knowledge Article
        Knowledge__kav newKAV = [SELECT Id, ArticleNumber, Custom_Knowledge_Article__c, PublishStatus, ValidationStatus, VersionNumber
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' AND PublishStatus = 'Draft' LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Query : ' + newKAV);

        //Query for Custom Knowledge Article
        Custom_Knowledge_Article__c newCKA = [SELECT Id, Article_Number__c
                                            FROM Custom_Knowledge_Article__c
                                            WHERE Id = :newKAV.Custom_Knowledge_Article__c LIMIT 1];
        system.debug('**CSALGADO** - After Custom Knowledge Query : ' + newCKA);


        system.debug('**CSALGADO** - Before Assert');
        //Test Assertions
        system.assertEquals(0, newKAV.VersionNumber);
        system.assertEquals(newCKA.Article_Number__c, newKAV.ArticleNumber);
        system.assertEquals(newCKA.Id, newKAV.Custom_Knowledge_Article__c);
    }

    //Test Script Description: Test update KAV with missing CKA
    //Acceptance Criteria: CKA is created and KAV is updated with the CKA
    @isTest static void updateKA_missingCKA(){
        system.debug('**CSALGADO** - Start KAVHandler Test - updateKA_missingCKA');

        //Get Test Knowledge Article
        Knowledge__kav newKA = [SELECT Id, ArticleNumber, Custom_Knowledge_Article__c, PublishStatus, ValidationStatus
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Query : ' + newKA);

        //Query for Custom Knowledge Article
        Custom_Knowledge_Article__c newCKA = [SELECT Id, Article_Number__c
                                             FROM Custom_Knowledge_Article__c
                                             WHERE Id = :newKA.Custom_Knowledge_Article__c LIMIT 1];
        system.debug('**CSALGADO** - After Custom Knowledge Query : ' + newCKA);

        Test.startTest();
        //Delete the existing Custom Knowledge Article
        delete newCKA;
        //Update the Knowledge Article
        newKA.ValidationStatus = 'In Review';
        newKA.Custom_Knowledge_Article__c = null;
        update newKA;
        Test.stopTest();

        //Query for Knowledge Article
        Knowledge__kav newKAV = [SELECT Id, ArticleNumber, Custom_Knowledge_Article__c, PublishStatus, ValidationStatus
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Query : ' + newKAV);

        //Query for Custom Knowledge Article
        Custom_Knowledge_Article__c newCKA_query = [SELECT Id, Article_Number__c
                                                    FROM Custom_Knowledge_Article__c
                                                    WHERE Id = :newKAV.Custom_Knowledge_Article__c LIMIT 1];
        system.debug('**CSALGADO** - After Custom Knowledge Query : ' + newCKA_query);

        system.debug('**CSALGADO** - Before Assert');
        //KA Assertions
        system.assert(newKAV.Custom_Knowledge_Article__c != null);
        system.assertEquals(newKAV.Custom_Knowledge_Article__c, newCKA_query.Id);
        system.assertEquals('In Review', newKAV.ValidationStatus);

    }

    //NOTE: Test missing CKA from Knowledge but need another one for both missing from KAV and missing from database
    //Test Script Description: Test update KAV with existing CKA but missing from the KAV
    //Acceptance Criteria: KAV is updated with the KAV and CKA is updated
    @isTest static void updateKA_missingCKA_2(){
        system.debug('**CSALGADO** - Start KAVHandler Test - updateKA_missingCKA2');

        //Get Test Knowledge Article
        Knowledge__kav newKA = [SELECT Id, ArticleNumber, Custom_Knowledge_Article__c, PublishStatus, ValidationStatus
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Query : ' + newKA);

        Test.startTest();
        //Update Test Knowledge Article by blanking the Custom Knowledge Article field
        newKA.ValidationStatus = 'In Review';
        newKA.Custom_Knowledge_Article__c = null;
        update newKA;
        Test.stopTest();

        //Query for Knowledge Article
        Knowledge__kav newKAV = [SELECT Id, ArticleNumber, Custom_Knowledge_Article__c, PublishStatus, ValidationStatus
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];
        system.debug('**CSALGADO** - After Knowledge Query : ' + newKA);

        //Query for Custom Knowledge Article
        Custom_Knowledge_Article__c newCKA = [SELECT Id, Article_Number__c
                                            FROM Custom_Knowledge_Article__c
                                            WHERE Id = :newKAV.Custom_Knowledge_Article__c LIMIT 1];
        system.debug('**CSALGADO** - After Custom Knowledge Query : ' + newCKA);

        system.debug('**CSALGADO** - Before Assert');
        //KA Assertions
        system.assert(newKAV.Custom_Knowledge_Article__c != null);
        system.assertEquals(newKAV.Custom_Knowledge_Article__c, newCKA.Id);
        system.assertEquals('In Review', newKAV.ValidationStatus);

        //CKA Assertions
        //system.assertEquals('In Review', newCKA.Status__c);
        //system.assertEquals(1, newCKA.Version__c);
    }

    //ToDo - need to finish
    //NOTE: validation and publishing KAV with existing CKA
    //Test Script Description: Test update KAV with existing CKA
    //Acceptance Criteria: CKA is updated
    @isTest static void updateKA_existingCKA(){
        system.debug('**CSALGADO** - Start KAVHandler Test - updateKA_existingCKA');

        //Get Test Knowledge Article
        Knowledge__kav newKA = [SELECT Id, ArticleNumber
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];
        system.debug('**CSALGADO** - Pre Update - After Knowledge Query : ' + newKA);

        //Query for the abstract Knowledge Article
        KnowledgeArticle newKA_abstract = [SELECT Id
        FROM KnowledgeArticle
        WHERE ArticleNumber = :newKA.ArticleNumber LIMIT 1];
        system.debug('**CSALGADO** - Pre Update - After KnowledgeArticle Query : ' + newKA_abstract);

        Test.startTest();
        //Validate Test Knowledge Article
        newKA.ValidationStatus = 'Validated';
        //update newKA;

        //Publish Test Knowledge Article
        KbManagement.PublishingService.publishArticle(newKA_abstract.Id, true);
        Test.stopTest();

        //Query for Knowledge Article
        Knowledge__kav newKAV = [SELECT Id, ArticleNumber, Custom_Knowledge_Article__c, PublishStatus, ValidationStatus
                                FROM Knowledge__kav
                                WHERE UrlName = 'TestArticleURLName' LIMIT 1];
        system.debug('**CSALGADO** - Post Update - After Knowledge Query : ' + newKAV);

        //Query for Custom Knowledge Article
        Custom_Knowledge_Article__c newCKA = [SELECT Id, Article_Number__c
                                            FROM Custom_Knowledge_Article__c
                                            WHERE Id = :newKAV.Custom_Knowledge_Article__c LIMIT 1];
        system.debug('**CSALGADO** - Post Update - After Custom Knowledge Query : ' + newCKA);

        system.debug('**CSALGADO** - Before Assert');
        //Test Assertions
        system.assertEquals(newCKA.Article_Number__c, newKAV.ArticleNumber);
        system.assertEquals(newCKA.Id, newKAV.Custom_Knowledge_Article__c);
    }

}