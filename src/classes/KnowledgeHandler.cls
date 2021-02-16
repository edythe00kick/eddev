/**
 * Created by csalgado on 12/18/2019.
 */

public with sharing class KnowledgeHandler {
    public void onBeforeInsert(List<Knowledge__kav> newTriggerKAV){
        System.debug('**CSALGADO** In onBeforeInsert');

        //Create Set of ArticleNumbers from Knowledge Article Versions
        Set<String> kavArticleNumbers = new Set<String>();
        //Create Set of Knowledge Article Versions with Author but need Community Author
        Set<Id> kavUpdateAuthor = new Set<Id>();
        for (Knowledge__kav kav : newTriggerKAV) {
            System.debug('**CSALGADO** Article Number = ' + kav.ArticleNumber);
            if(kav.ArticleNumber != null) {
                kavArticleNumbers.add(kav.ArticleNumber);
            }
            if(kav.Author__c != null && kav.Community_Author__c == null){
                kavUpdateAuthor.add(kav.Author__c);
            }
        }
        if(!kavArticleNumbers.isEmpty()){
            KnowledgeGateway.updateKnowledgeArticleVersion(newTriggerKAV, kavArticleNumbers);
        }
        if(!kavUpdateAuthor.isEmpty()){
            KnowledgeGateway.updateCommunityAuthor(newTriggerKAV, kavUpdateAuthor);
        }
    }

    public void onBeforeUpdate(List<Knowledge__kav> newTriggerKAV,  Map<Id, Knowledge__kav> oldTriggerKAVMap){
        System.debug('**CSALGADO** In onBeforeUpdate');

        //Create Set of ArticleNumbers from Knowledge Article Versions
        List<Knowledge__kav> kaMissingCKAList = new List<Knowledge__kav>();
        Set<String> kavArticleNumbers = new Set<String>();
        //Create Set of Knowledge Article Versions with Author but need Community Author
        Set<Id> kavUpdateAuthor = new Set<Id>();
        for (Knowledge__kav kav : newTriggerKAV) {
            System.debug('**CSALGADO** Article Number = ' + kav.ArticleNumber);
            if(kav.Custom_Knowledge_Article__c == null) {
                kaMissingCKAList.add(kav);
                kavArticleNumbers.add(kav.ArticleNumber);
            }
            if(oldTriggerKAVMap.get(kav.Id).Author__c == null && kav.Author__c != null && kav.Community_Author__c == null){
                kavUpdateAuthor.add(kav.Author__c);
            }
        }
        if(!kaMissingCKAList.isEmpty() && !kavArticleNumbers.isEmpty()){
            KnowledgeGateway.updateKnowledgeArticleVersion(kaMissingCKAList, kavArticleNumbers);
        }
        if(!kavUpdateAuthor.isEmpty()){
            KnowledgeGateway.updateCommunityAuthor(newTriggerKAV, kavUpdateAuthor);
        }
    }

    //public void onBeforeDelete(List<Knowledge__kav> oldTriggerKAVMap){}

    public void onAfterInsert(List<Knowledge__kav> newTriggerKAV) {
        System.debug('**CSALGADO** In onAfterInsert');

        //Create List of Knowledge Article Versions that need a new Custom Knowledge Article
        List<Knowledge__kav> newKAVList = new List<Knowledge__kav>();
        //Create List of Knowledge Article Versions that need the Custom Knowledge Article updated
        List<Knowledge__kav> updateKAVList = new List<Knowledge__kav>();
        //Create a Set of User Ids from KAV List
        Set<Id> usersIdSet = new Set<Id>();
        for (Knowledge__kav newKAV : newTriggerKAV) {
            System.debug('**CSALGADO** Decision: ' + newKAV.PublishStatus + ' ' + newKAV.Custom_Knowledge_Article__c);
            if (newKAV.PublishStatus == 'Draft' && newKAV.Custom_Knowledge_Article__c == null) {
                newKAVList.add(newKAV);
                usersIdSet.add(newKAV.OwnerId);
                usersIdSet.add(newKAV.Author__c);
            }
            else if(newKAV.PublishStatus == 'Draft' && newKAV.Custom_Knowledge_Article__c != null){
                updateKAVList.add(newKAV);
                usersIdSet.add(newKAV.OwnerId);
                usersIdSet.add(newKAV.Author__c);
            }
        }
        if (!newKAVList.isEmpty()) {
            //ToDo - CHECK if this method could update the CKA incorrectly..
            KnowledgeGateway.insertCustomKnowledgeArticle(newKAVList, usersIdSet);
        }
        if (!updateKAVList.isEmpty()) {
            KnowledgeGateway.updateCustomKnowledgeArticle(updateKAVList, usersIdSet);
        }
    }

    public void onAfterUpdate(List<Knowledge__kav> newTriggerKAV,  Map<Id, Knowledge__kav> oldTriggerKAVMap){
        System.debug('**CSALGADO** In onAfterUpdate');

        //Create List of KAV's that need a new CKA
        List<Knowledge__kav> insertCKAList = new List<Knowledge__kav>();
        //Create List of KAV's that need the CKA updated
        List<Knowledge__kav> updateKAVList = new List<Knowledge__kav>();
        //Create a Set of User Ids from KAV List
        Set<Id> usersIdSet = new Set<Id>();
        for (Knowledge__kav newKAV : newTriggerKAV) {
            System.debug('**CSALGADO** Id: ' + newKAV.Id);
            Knowledge__kav oldKAV = oldTriggerKAVMap.get(newKAV.Id);

            //System.debug('**CSALGADO** Decision: ' + newKAV.PublishStatus + ' ' + oldKAV.PublishStatus + ' ' + newKAV.Custom_Knowledge_Article__c);
            //if (newKAV.PublishStatus == 'Online' /*'Published'*/ && newKAV.PublishStatus != oldKAV.PublishStatus /*&& newKAV.Custom_Knowledge_Article__c != null*/) {
            System.debug('**CSALGADO** Decision: ' + newKAV.ValidationStatus + ' ' + oldKAV.ValidationStatus + ' ' + newKAV.Custom_Knowledge_Article__c);
            if(newKAV.Custom_Knowledge_Article__c == null){
                insertCKAList.add(newKAV);
            }
            else if (newKAV.Custom_Knowledge_Article__c != null &&
                    (newKAV.ValidationStatus == 'Validated' && newKAV.ValidationStatus != oldKAV.ValidationStatus) ||
                    (newKAV.PublishStatus == 'Archived' && newKAV.PublishStatus != oldKAV.PublishStatus) ||
                    newKAV.OwnerId != oldKAV.OwnerId ||
                    newKAV.Author__c != oldKAV.Author__c
                    ) {
                System.debug('**CSALGADO** Validated/ Published/ Archived Trigger Fired'); //Salesforce! - ISSUE
                updateKAVList.add(newKAV);
            }

            usersIdSet.add(newKAV.OwnerId);
            usersIdSet.add(newKAV.Author__c);


        }
        if(!insertCKAList.isEmpty()){
            KnowledgeGateway.insertCustomKnowledgeArticle(insertCKAList, usersIdSet);
        }
        if(!updateKAVList.isEmpty()){
            KnowledgeGateway.updateCustomKnowledgeArticle(updateKAVList, usersIdSet);
        }
    }

    /*public void onAfterDelete(List<Knowledge__kav> oldTriggerKAVMap){}
    public void onAfterUnDelete(List<Knowledge__kav> newTriggerKAV){}*/
}