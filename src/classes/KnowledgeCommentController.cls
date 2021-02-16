/**
 * Created by csalgado on 12/16/2019.
 */

public with sharing class KnowledgeCommentController {
    @AuraEnabled
    public static List<Knowledge_Comment__c> getKnowledgeComments(Id knowledgeArticleId){
        Knowledge__kav tempKA = [SELECT Id, ArticleNumber FROM Knowledge__kav WHERE Id = :knowledgeArticleId LIMIT 1];

        return [SELECT Id, /*Name,*/ Comment__c, Active__c, CreatedByName__c, CreatedDate
                FROM Knowledge_Comment__c
                WHERE Knowledge__r.ArticleNumber = :tempKA.ArticleNumber
                ORDER BY CreatedDate DESC];
    }

    @AuraEnabled
    public static boolean insertKnowledgeComment(Id knowledgeArticleId, String commentString, boolean active){
        Knowledge_Comment__c newKC = new Knowledge_Comment__c();
        newKC.Knowledge__c = knowledgeArticleId;
        newKC.Comment__c = commentString;
        newKC.Active__c = active;

        insert newKC;
        return true;
    }
}