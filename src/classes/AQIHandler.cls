/**
 * Created by chris on 12/29/2019.
 */

public with sharing class AQIHandler {
    public void afterInsert(List<aqi_ltng_mng__Article_Quality__c> aqiNewList){
        system.debug('**CSALGADO** In onAfterInsert');
        Set<String> knowledgeIdSet = new Set<String>();
        for(aqi_ltng_mng__Article_Quality__c newAQI : aqiNewList) {
            system.debug('**CSALGADO** Test AQI:' + newAQI);
            knowledgeIdSet.add(newAQI.aqi_ltng_mng__Knowledge_Article_Version_Id__c);
        }

        Map<String, Knowledge__kav> stringIdToKnowledgeMap = new Map<String, Knowledge__kav>([SELECT Id, Custom_Knowledge_Article__c FROM Knowledge__kav WHERE Id IN :knowledgeIdSet]);

        List<Custom_Knowledge_Article__c> updateCKAList = new List<Custom_Knowledge_Article__c>();
        for(aqi_ltng_mng__Article_Quality__c finalAQI : aqiNewList) {
            if(stringIdToKnowledgeMap.containsKey(finalAQI.aqi_ltng_mng__Knowledge_Article_Version_Id__c) && stringIdToKnowledgeMap.get(finalAQI.aqi_ltng_mng__Knowledge_Article_Version_Id__c).Custom_Knowledge_Article__c != null){
                Custom_Knowledge_Article__c updateCKA = new Custom_Knowledge_Article__c(Id = stringIdToKnowledgeMap.get(finalAQI.aqi_ltng_mng__Knowledge_Article_Version_Id__c).Custom_Knowledge_Article__c);
                updateCKA.AQI_Score__c = finalAQI.aqi_ltng_mng__AQ_Score__c;
                updateCKA.AQI_Coaching_Notes__c = finalAQI.aqi_ltng_mng__Internal_Notes__c != null? finalAQI.aqi_ltng_mng__Internal_Notes__c.stripHtmlTags(): null;
                updateCKAList.add(updateCKA);
            }
        }

        if(!updateCKAList.isEmpty()){
            update updateCKAList;
        }
    }

    public void afterUpdate(List<aqi_ltng_mng__Article_Quality__c> aqiNewList, Map<Id, aqi_ltng_mng__Article_Quality__c> aqiOldMap){
        system.debug('**CSALGADO** In onAfterUpdate');
        Set<String> knowledgeIdSet = new Set<String>();
        for(aqi_ltng_mng__Article_Quality__c newAQI : aqiNewList) {
            system.debug('**CSALGADO** Test AQI:' + newAQI);
            aqi_ltng_mng__Article_Quality__c oldAQI = aqiOldMap.get(newAQI.Id);
            if(newAQI.aqi_ltng_mng__AQ_Score__c != oldAQI.aqi_ltng_mng__AQ_Score__c) {
                knowledgeIdSet.add(newAQI.aqi_ltng_mng__Knowledge_Article_Version_Id__c);
            }
        }

        Map<String, Knowledge__kav> stringIdToKnowledgeMap = new Map<String, Knowledge__kav>([SELECT Id, Custom_Knowledge_Article__c FROM Knowledge__kav WHERE Id IN :knowledgeIdSet]);

        List<Custom_Knowledge_Article__c> updateCKAList = new List<Custom_Knowledge_Article__c>();
        for(aqi_ltng_mng__Article_Quality__c finalAQI : aqiNewList) {
            if(stringIdToKnowledgeMap.containsKey(finalAQI.aqi_ltng_mng__Knowledge_Article_Version_Id__c) && stringIdToKnowledgeMap.get(finalAQI.aqi_ltng_mng__Knowledge_Article_Version_Id__c).Custom_Knowledge_Article__c != null){
                aqi_ltng_mng__Article_Quality__c finalOldAQI = aqiOldMap.get(finalAQI.Id);
                Custom_Knowledge_Article__c updateCKA = new Custom_Knowledge_Article__c(Id = stringIdToKnowledgeMap.get(finalAQI.aqi_ltng_mng__Knowledge_Article_Version_Id__c).Custom_Knowledge_Article__c);
                updateCKA.AQI_Score__c = finalOldAQI.aqi_ltng_mng__AQ_Score__c;
                updateCKA.AQI_Coaching_Notes__c = finalAQI.aqi_ltng_mng__Internal_Notes__c != null? finalOldAQI.aqi_ltng_mng__Internal_Notes__c.stripHtmlTags(): null;
                updateCKAList.add(updateCKA);
            }
        }

        if(!updateCKAList.isEmpty()){
            update updateCKAList;
        }
    }
}