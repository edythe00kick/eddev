/**
 * Created by csalgado on 2/13/2020.
 */

public with sharing class ExternalImageURLHandler {
    public void onAfterUpdate(List<External_Image_URL__c> newEIUList, Map<Id,External_Image_URL__c> oldEIUMap){
        List<External_Image_URL__c> updateEIUList = new List<External_Image_URL__c>();
        Set<Id> ckaIds = new Set<Id>();
        for(External_Image_URL__c eiu : newEIUList) {
            if (eiu.External_URL__c != null && eiu.External_URL__c != oldEIUMap.get(eiu.Id).External_URL__c){
                updateEIUList.add(eiu);
                ckaIds.add(eiu.Custom_Knowledge_Article__c);
            }
        }

        if(!updateEIUList.isEmpty() && !ckaIds.isEmpty()){
            addImageToKnowledge(updateEIUList, ckaIds);
        }
    }

    public static void addImageToKnowledge(List<External_Image_URL__c> updateEIUList, Set<Id> ckaIds){
        List<Knowledge__kav> updateKAV = new List<Knowledge__kav>();
        Map<Id, Knowledge__kav> ckaToKnowledgeMap = new Map<Id, Knowledge__kav>();
        for(Knowledge__kav kav : [SELECT Id, Custom_Knowledge_Article__c, Environment_Details__c, Resolution__c, Community_Article_Body__c, RecordTypeId FROM Knowledge__kav WHERE Custom_Knowledge_Article__c IN :ckaIds ORDER BY LastModifiedDate DESC]){
            if(!ckaToKnowledgeMap.containskey(kav.Custom_Knowledge_Article__c)){
                ckaToKnowledgeMap.put(kav.Custom_Knowledge_Article__c, kav);
            }
        }

        for(External_Image_URL__c eiu : updateEIUList){
            if(ckaToKnowledgeMap.containsKey(eiu.Custom_Knowledge_Article__c)){
                Knowledge__kav kav2 = new Knowledge__kav(Id = ckaToKnowledgeMap.get(eiu.Custom_Knowledge_Article__c).Id);
                String recordTypeName = Schema.getGlobalDescribe().get('Knowledge__kav').getDescribe().getRecordTypeInfosById().get(ckaToKnowledgeMap.get(eiu.Custom_Knowledge_Article__c).RecordTypeId).getName();
                switch on recordTypeName{
                    when 'Break Fix' {
                        kav2.Resolution__c = ckaToKnowledgeMap.get(eiu.Custom_Knowledge_Article__c).Resolution__c + '<br><br>'+ eiu.External_URL__c;
                    }
                    when 'How To'{
                        kav2.Community_Article_Body__c = ckaToKnowledgeMap.get(eiu.Custom_Knowledge_Article__c).Community_Article_Body__c + '<br><br>'+ eiu.External_URL__c;
                    }
                }
                updateKAV.add(kav2);
            }
        }

        if(!updateKAV.isEmpty()) {
            update updateKAV;
        }
    }
}