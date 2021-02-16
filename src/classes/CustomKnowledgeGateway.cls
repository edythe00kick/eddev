/**
 * Created by csalgado on 12/19/2019.
 */

public with sharing class CustomKnowledgeGateway {
    //Update KA
    public static void updateKnowledgeArticleVersion(List<Custom_Knowledge_Article__c> ckaList, Set<String> ckaArticleNumbers) {
        System.debug('In CustomKnowledgeGateway ' + 'onAfterUpdate');

        //Create a Map from a Query of Knowledge Article Versions that match the Set of ArticleNumbers
        Map<String, Knowledge__kav> articleNumToKAVMap = new Map<String, Knowledge__kav>();
        for (Knowledge__kav kav : [SELECT Id, PublishStatus, ArticleNumber FROM Knowledge__kav WHERE ArticleNumber IN :ckaArticleNumbers]) {
            articleNumToKAVMap.put(kav.ArticleNumber, kav);
        }

        //Update Knowledge Article Version with the related Custom Knowledge Article
        List<Knowledge__kav> updateKAVList = new List<Knowledge__kav>();
        for (Custom_Knowledge_Article__c cka : ckaList) {
            if (articleNumToKAVMap.containsKey(cka.Article_Number__c) && articleNumToKAVMap.get(cka.Article_Number__c).PublishStatus == 'Draft') {
                Knowledge__kav updateKAV = new Knowledge__kav(Id = articleNumToKAVMap.get(cka.Article_Number__c).Id);
                updateKAV.Custom_Knowledge_Article__c = cka.Id;
                updateKAVList.add(updateKAV);
            }
        }

        //Update Custom Knowledge Article with new Knowledge Article Status and Version
        if(!updateKAVList.isEmpty()){
            update updateKAVList;
        }
    }
}