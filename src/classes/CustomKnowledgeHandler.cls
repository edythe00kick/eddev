/**
 * Created by csalgado on 12/19/2019.
 */

public with sharing class CustomKnowledgeHandler {
    /*public void onBeforeInsert(List<Custom_Knowledge_Article__c> newTriggerCKA){}
    public void onBeforeUpdate(List<Custom_Knowledge_Article__c> newTriggerCKA,  Map<Id, Custom_Knowledge_Article__c> oldTriggerCKAMap){}
    public void onBeforeDelete(List<Custom_Knowledge_Article__c> oldTriggerCKAMap){}*/

    public void onAfterInsert(List<Custom_Knowledge_Article__c> newTriggerCKA) {
        system.debug('**CSALGADO** In onAfterInsert');

        //Create Set of ArticleNumbers from Custom Knowledge Articles
        Set<String> ckaArticleNumbers = new Set<String>();
        for (Custom_Knowledge_Article__c cka : newTriggerCKA) {
            System.debug('**CSALGADO** Article Number = ' + cka.Article_Number__c);
            ckaArticleNumbers.add(cka.Article_Number__c);
        }
        if(!ckaArticleNumbers.isEmpty()){
            CustomKnowledgeGateway.updateKnowledgeArticleVersion(newTriggerCKA, ckaArticleNumbers);
        }
    }

    public void onAfterUpdate(List<Custom_Knowledge_Article__c> newTriggerCKA,  Map<Id, Custom_Knowledge_Article__c> oldTriggerCKAMap){
        List<Custom_Knowledge_Article__c> sendToCommunityCKAList = new List<Custom_Knowledge_Article__c>();
        Set<String> articleNumbersSet = new Set<String>();
        Set<ID> ckasForCall = new Set<Id>();
        Set<ID> ckasForArchive = new Set<Id>();
        Set<ID> ckasForRestore = new Set<Id>();
        Set<ID> ckasForLabels = new Set<Id>();
        Set<Id> ckasForBoard = new Set<Id>();

        //Eddie Wong
        //04302020
        //W-005057
        //To build HTTP call for Board or Label change
        for(Custom_Knowledge_Article__c cka : newTriggerCKA) {
            Custom_Knowledge_Article__c ckaOld = oldTriggerCKAMap.get(cka.Id);

            System.debug('eddie inside  Knowledge__r.Community_Board_Id__c ' + cka.Knowledge__r.Community_Board_Id__c);
            System.debug('eddie inside  Knowledge__r.Community_Board_Id__c ' + ckaOld.Knowledge__r.Community_Board_Id__c);
            System.debug('eddie inside cka.id' + cka.id);
            System.debug('eddie inside ckaOld.id' + ckaOld.id);
            System.debug('eddie inside cka.Knowledge__r.Community_Board__c' + cka.Knowledge__r.Community_Board__c);
            System.debug('eddie inside ckaOld.Knowledge__r.Community_Board__c' + ckaOld.Knowledge__r.Community_Board__c);

            if (cka.Send_to_Community__c && cka.Send_to_Community__c != ckaOld.Send_to_Community__c) {
                sendToCommunityCKAList.add(cka);
                articleNumbersSet.add(cka.Article_Number__c);
                ckasForCall.add(cka.Id);
            }
            else if(cka.Status__c == 'Archived' && cka.Status__c != ckaOld.Status__c){
                ckasForArchive.add(cka.Id);
            }
            else if(ckaOld.Status__c == 'Archived' && cka.Status__c == 'Draft' && cka.Status__c != ckaOld.Status__c){
                ckasForRestore.add(cka.Id);
            }
            else if(cka.Community_Id__c != null && cka.Last_Community_Upload__c != ckaOld.Last_Community_Upload__c){
                ckasForLabels.add(cka.Id);
            }
            else if(cka.Knowledge__r.Community_Board__c != ckaOld.Knowledge__r.Community_Board__c){
                ckasForBoard.add(cka.Id);
            }
        }

        if(!sendToCommunityCKAList.isEmpty() && !articleNumbersSet.isEmpty()){
            //POC
            //CustomKnowledgeGateway.sendToKhoros(sendToCommunityCKAList, articleNumbersSet);

            //Final
            Map<Id, Knowledge__kav> kavMap = mapKAVFromCKAIds(ckasForCall);
            DellBoomiKnowledge.buildRequest(ckasForCall,kavMap.keySet());
        }

        if(!ckasForLabels.isEmpty()){
            Map<Id, Knowledge__kav> kavMap = mapKAVFromCKAIds(ckasForLabels);
            //NO LONGER NEEDED
            //DellBoomiKnowledge.labelRequest(ckasForLabels, kavMap.keySet());
        }

        if(!ckasForArchive.isEmpty()){
            Map<Id, Knowledge__kav> kavMap = mapKAVFromCKAIds(ckasForArchive);
            DellBoomiKnowledge.archiveRequest(ckasForArchive, kavMap.keySet(), false);
        }

        if(!ckasForRestore.isEmpty()){
            Map<Id, Knowledge__kav> kavMap = mapKAVFromCKAIds(ckasForRestore);
            DellBoomiKnowledge.archiveRequest(ckasForRestore, kavMap.keySet(), true);
        }
        if(!ckasForBoard.isEmpty()){
            Map<Id, Knowledge__kav> kavMap = mapKAVFromCKAIds(ckasForBoard);
            DellBoomiKnowledge.BoardRequest(ckasForBoard, kavMap.keySet());
        }
    }


    /*public void onAfterDelete(List<Custom_Knowledge_Article__c> oldTriggerCKAMap){}
    public void onAfterUnDelete(List<Custom_Knowledge_Article__c> newTriggerCKA){}*/

    public static Map<Id, Knowledge__kav> mapKAVFromCKAIds(Set<Id> ckaIdSet){
        return new Map<Id, Knowledge__kav>([SELECT Id, ArticleNumber
        FROM Knowledge__kav
        WHERE Custom_Knowledge_Article__c IN :ckaIdSet
        AND ValidationStatus = 'Validated'
        /*AND PublishStatus = 'Online'*/
        AND IsLatestVersion = true]);
    }
}