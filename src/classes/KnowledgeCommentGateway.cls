/**
 * Created by csalgado on 12/19/2019.
 */

public with sharing class KnowledgeCommentGateway {
    public static void flagCustomKnowledge(List<Knowledge_Comment__c> flaggedKCList, Set<Id> kavIdSet){
        System.debug('In KnowledgeCommentGateway - ' + 'onBeforeUpdate');

        //Create a Map of Knowledge Article Version Id to Knowledge Article Version
        Map<Id, Knowledge__kav> kavIdToKAVMap = new Map<Id, Knowledge__kav>([SELECT Id, Custom_Knowledge_Article__c, Author__c, OwnerId, Title
                                                                            FROM Knowledge__kav
                                                                            WHERE Id IN :kavIdSet]);

        //Create a List of Custom Knowledge Articles to Update
        List<Custom_Knowledge_Article__c> updateCKAList = new List<Custom_Knowledge_Article__c>();
        //Create a List of Knowledge Article Versions to Email
        List<Knowledge__kav> emailKAVList = new List<Knowledge__kav>();
        //Create a Map of Knowledge Article Version Ids to Knowledge Comments
        Map<Id, Knowledge_Comment__c> kavIdToKCMap = new Map<Id, Knowledge_Comment__c>();
        for(Knowledge_Comment__c kc : flaggedKCList){
            if(kavIdToKAVMap.containsKey(kc.Knowledge__c)){
                //Add updated Custom Knowledge Article to List
                Custom_Knowledge_Article__c updateCKA = new Custom_Knowledge_Article__c(Id = kavIdToKAVMap.get(kc.Knowledge__c).Custom_Knowledge_Article__c);
                updateCKA.Flagged__c = kc.Active__c;
                updateCKAList.add(updateCKA);

                //Add Knowledge Article Versions with an active Knowledge Comment to List
                if(kc.Active__c){
                    emailKAVList.add(kavIdToKAVMap.get(kc.Knowledge__c));
                    kavIdToKCMap.put(kc.Knowledge__c, kc);
                }
            }
        }

        //Update Custom Knowledge Articles
        if(!updateCKAList.isEmpty()){
            update updateCKAList;
        }

        //Update Custom Knowledge Articles
        if(!emailKAVList.isEmpty() && !kavIdToKCMap.isEmpty()){
            //Name: Chris Salgado Purpose: Done in workflow now
            //emailFlaggedKnowledge(emailKAVList, kavIdToKCMap);
        }
    }

    /*public static void emailFlaggedKnowledge(List<Knowledge__kav> emailKAVList, Map<Id, Knowledge_Comment__c> kavIdToKCMap){
        System.debug('In KnowledgeGateway - ' + 'emailFlaggedKnowledge');

        //Iterate through Knowledge Article Version list and Owner and Author to Set
        Set<Id> userIdsSet = new Set<Id>();
        for(Knowledge__kav KA : emailKAVList){
            userIdsSet.add(KA.Author__c);
            userIdsSet.add(KA.OwnerId);
        }

        //Query for Users and Map Id to Email
        Map<Id, String> userIdToEmailMap = new Map<Id, String>();
        for(User u : [SELECT Id, email FROM User WHERE Id IN :userIdsSet]){
            userIdToEmailMap.put(u.Id, u.email);
        }

        //Create a list of mail to send
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        //Create new email for each Knowledge Article Version in list
        for(Knowledge__kav KAV : emailKAVList) {
            //Create a list of the email addresses to send to
            List<String> emailAddresses = new List<String>();
            if(KAV.OwnerId != null && userIdToEmailMap.containsKey(KAV.OwnerId)){
                emailAddresses.add(userIdToEmailMap.get(KAV.OwnerId));
            }
            if(KAV.Author__c != null && userIdToEmailMap.containsKey(KAV.Author__c) && KAV.OwnerId != KAV.Author__c){
                emailAddresses.add(userIdToEmailMap.get(KAV.Author__c));
            }

            //Create the body
            String body = '';
            if(kavIdToKCMap.containsKey(KAV.Id)) {
                body =  'Written By: ' + kavIdToKCMap.get(KAV.Id).CreatedByName__c +
                '<br>' +
                'Comment: ' + kavIdToKCMap.get(KAV.Id).Comment__c +
                '<br>' +
                '<a href="' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + KAV.Id + '"> Knowledge Article Link </a>';
            }
            //If email list is not empty send an email
            if(!emailAddresses.isEmpty() && body != null) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emailAddresses);
                mail.setSubject('Knowledge Article Flagged - TITLE: ' + KAV.Title);
                mail.setHtmlBody(body);
                mailList.add(mail);
            }
        }

        //If mail list is not empty send
        if(!mailList.isEmpty()) {
            Messaging.sendEmail(mailList);
        }
    }*/
}