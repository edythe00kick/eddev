/**
 * Created by ewong on 12/23/2019.
 */

public with sharing class ReviewDateController {
    @AuraEnabled
    public static boolean insertReviewDate(String recordId, Date reviewDate){
        System.debug('inside insertReviewDate' + recordId + reviewDate);
        knowledge__kav kKav = [Select Id, custom_Knowledge_article__c from knowledge__kav where Id = :recordId];
        custom_knowledge_article__c cKA = new custom_knowledge_article__c();
        cKA.Id = kKav.custom_Knowledge_article__c;
        cKA.Review_Date__c = reviewDate;
        update cKA;
        System.debug('inside cKA' + cKA);
        return true;
    }

    @AuraEnabled
    public static List<custom_knowledge_article__c> getCustomKnowledgeArticleId(String recordId){
        Knowledge__kav getCKAId = [Select Id, custom_Knowledge_article__c from knowledge__kav where Id = :recordId];

        return [SELECT Id, Review_Date__c
        FROM custom_knowledge_article__c
        WHERE Id = :getCKAId.custom_Knowledge_article__c];

    }

    @AuraEnabled
    public static boolean removeReviewDateDB(String recordId){
        Knowledge__kav kKav = [Select Id, custom_Knowledge_article__c from knowledge__kav where Id = :recordId];
        custom_Knowledge_article__c cKA = new custom_Knowledge_article__c();
        cKA.Id = kKav.custom_Knowledge_article__c;
        cKA.Review_Date__c = null;
        update cKA;
        return true;
    }

    @AuraEnabled
    public static Date getCurrentReviewDate(String recordId){
        Date returnDate = [Select Id, KCS_Review_Date__c from knowledge__kav where Id = :recordId].KCS_Review_Date__c;
        return returnDate;
    }
}