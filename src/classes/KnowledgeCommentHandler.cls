/**
 * Created by csalgado on 12/19/2019.
 */

public with sharing class KnowledgeCommentHandler {
    /*public void onBeforeInsert(List<Knowledge_Comment__c> newTriggerKC){}
    public void onBeforeUpdate(List<Knowledge_Comment__c> newTriggerKC,  Map<Id, Knowledge_Comment__c> oldTriggerKCMap){}
    public void onBeforeDelete(List<Knowledge_Comment__c> oldTriggerKCMap){}*/

    public void onAfterInsert(List<Knowledge_Comment__c> newTriggerKC) {
        system.debug('**CSALGADO** In onAfterInsert');

        //Create a List of Knowledge Comments that are flagged
        List<Knowledge_Comment__c> flaggedKCList = new List<Knowledge_Comment__c>();
        //Create a Set of Knowledge Article Ids related to the Knowledge Comments
        Set<Id> kavIdSet = new Set<Id>();
        for(Knowledge_Comment__c kc : newTriggerKC){
            if(kc.Active__c) {
                flaggedKCList.add(kc);
                kavIdSet.add(kc.Knowledge__c);
            }
        }
        if(!flaggedKCList.isEmpty() && !kavIdSet.isEmpty()){
            KnowledgeCommentGateway.flagCustomKnowledge(flaggedKCList, kavIdSet);
        }
    }

    public void onAfterUpdate(List<Knowledge_Comment__c> newTriggerKC,  Map<Id, Knowledge_Comment__c> oldTriggerKCMap){
        system.debug('**CSALGADO** In onAfterUpdate');

        //Create a List of Knowledge Comments that are flagged
        List<Knowledge_Comment__c> flaggedKCList = new List<Knowledge_Comment__c>();
        //Create a Set of Knowledge Article Ids related to the Knowledge Comments
        Set<Id> kavIdSet = new Set<Id>();
        for(Knowledge_Comment__c newKC : newTriggerKC){
            Knowledge_Comment__c oldKC = oldTriggerKCMap.get(newKC.Id);
            if(newKC.Active__c != oldKC.Active__c){
                flaggedKCList.add(newKC);
                kavIdSet.add(newKC.Knowledge__c);
            }
        }
        if(!flaggedKCList.isEmpty() && !kavIdSet.isEmpty()){
            KnowledgeCommentGateway.flagCustomKnowledge(flaggedKCList, kavIdSet);
        }
    }
    /*public void onAfterDelete(List<Knowledge_Comment__c> oldTriggerKCMap){}
    public void onAfterUnDelete(List<Knowledge_Comment__c> newTriggerKC){}*/
}