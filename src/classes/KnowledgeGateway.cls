/**
 * Created by csalgado on 12/18/2019.
 */

public with sharing class KnowledgeGateway {
    //Update KA
    public static void updateKnowledgeArticleVersion(List<Knowledge__kav> kavList, Set<String> kavArticleNumbers) {
        System.debug('In KnowledgeGateway ' + 'onBeforeUpdate');

        //Create a Map from a Query of Custom Knowledge Articles that match the Set of ArticleNumbers
        Map<String, Custom_Knowledge_Article__c> articleNumToCKAMap = new Map<String, Custom_Knowledge_Article__c>();
        for (Custom_Knowledge_Article__c cka : [SELECT Id, Status__c, Article_Number__c FROM Custom_Knowledge_Article__c WHERE Article_Number__c IN :kavArticleNumbers]) {
            articleNumToCKAMap.put(cka.Article_Number__c, cka);
        }

        //Update Knowledge Article Version with the related Custom Knowledge Article
        List<Custom_Knowledge_Article__c> updateCKAList = new List<Custom_Knowledge_Article__c>();
        for (Knowledge__kav kav : kavList) {
            if (articleNumToCKAMap.containsKey(kav.ArticleNumber) && kav.Custom_Knowledge_Article__c == null) {

                kav.Custom_Knowledge_Article__c = articleNumToCKAMap.get(kav.ArticleNumber).Id;

                Custom_Knowledge_Article__c updateCKA = new Custom_Knowledge_Article__c();
                updateCKA.Id = articleNumToCKAMap.get(kav.ArticleNumber).Id;
                updateCKA.Status__c = kav.PublishStatus;
                updateCKA.Version__c = kav.VersionNumber;
                updateCKAList.add(updateCKA);
            }
        }

        //Update Custom Knowledge Article with new Knowledge Article Status and Version
        if(!updateCKAList.isEmpty()){
            update updateCKAList;
        }
    }

    //Insert CKA
    public static void insertCustomKnowledgeArticle(List<Knowledge__kav> kavList, Set<Id> usersIdSet){
        System.debug('In KnowledgeGateway ' + 'onAfterInsert');

        //Check if CKA with same Article Number already exists
        /*Set<String> articleNumbers = new Set<String>();
        for(Knowledge__kav tempKav : kavList){
            articleNumbers.add(tempKav.ArticleNumber);
        }

        Map<String, Id> articleNumToCKAMap = new Map<String, Id>();
        for(Custom_Knowledge_Article__c tempCka : [SELECT Id, Article_Number__c FROM Custom_Knowledge_Article__c WHERE Article_Number__c IN :articleNumbers]){
            articleNumToCKAMap.put(tempCka.Article_Number__c, tempCka.Id);
        }*/

        //Query the Set of User Ids and create a Map of User Id to User
        Map<Id, User> userIdToUserMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :usersIdSet]);

        //Create a List of Custom Knowledge Articles that need to be inserted
        List<Custom_Knowledge_Article__c> insertCKAList = new List<Custom_Knowledge_Article__c>();
        //Create a List of Knowledge Articles that need to be updated
        //List<Knowledge__kav> updateKAVList = new List<Knowledge__kav>();
        for (Knowledge__kav kav : kavList) {
            /*if(articleNumToCKAMap.containsKey(kav.ArticleNumber)){
                Knowledge__kav updateKav = new Knowledge__kav(Id = kav.Id);
                updateKav.Custom_Knowledge_Article__c = articleNumToCKAMap.get(kav.ArticleNumber);
                updateKAVList.add(updateKav);
            }
            else {*/
                Custom_Knowledge_Article__c insertCKA = new Custom_Knowledge_Article__c();
                insertCKA.Article_Number__c = kav.ArticleNumber;
                insertCKA.Title__c = kav.Title;
                insertCKA.Status__c = kav.PublishStatus;
                insertCKA.Version__c = kav.VersionNumber;
                insertCKA.KCS_Article_Owner__c = userIdToUserMap.containsKey(kav.OwnerId) ? userIdToUserMap.get(kav.OwnerId).Email : '';
                insertCKA.KCS_Article_Author__c = userIdToUserMap.containsKey(kav.Author__c) ? userIdToUserMap.get(kav.Author__c).Email : '';
                insertCKA.Knowledge__c = kav.Id;

                insertCKAList.add(insertCKA);
            //}
        }

        //Insert Custom Knowledge Articles
        if(!insertCKAList.isEmpty()){
            insert insertCKAList;
        }

        //Update Knowledge Articles
        /*if(!updateKAVList.isEmpty()){
            update updateKAVList;
        }*/
    }


    //Update CKA
    public static void updateCustomKnowledgeArticle(List<Knowledge__kav> kavList, Set<Id> usersIdSet) {
        System.debug('In KnowledgeArticleVersionGateway ' + 'onAfterUpdate');

        //Query the Set of User Ids and create a Map of User Id to User
        Map<Id, User> userIdToUserMap = new Map<Id, User>([SELECT Id, Email FROM User WHERE Id IN :usersIdSet]);

        //Query for the current CustomKnowledgeArticles
        Map<Id, Custom_Knowledge_Article__c> ckaMap = new Map<Id, Custom_Knowledge_Article__c>([Select Id, Knowledge__c From Custom_Knowledge_Article__c Where Id IN (Select Custom_Knowledge_Article__c From Knowledge__kav Where Id IN: kavList)]);

        //Create a List of Custom Knowledge Articles that need to be updated
        List<Custom_Knowledge_Article__c> updateCKAList = new List<Custom_Knowledge_Article__c>();
        //Create a List of Knowledge Articles published for KC unflagging
        Set<Id> publishedKAVSet = new Set<Id>();
        for (Knowledge__kav kav : kavList) {
            Custom_Knowledge_Article__c updateCKA = new Custom_Knowledge_Article__c (Id = kav.Custom_Knowledge_Article__c);
            updateCKA.Title__c = kav.Title;
            system.debug('**CSALGADO** PublishStatus: ' + kav.PublishStatus);
            //Integration trigger
            if(kav.PublishStatus == 'Online' || kav.ValidationStatus == 'Validated'){
                updateCKA.Status__c = kav.PublishStatus == 'Online'? 'Published': kav.PublishStatus;
                updateCKA.Send_to_Community__c = true;
            }
            updateCKA.Version__c = kav.VersionNumber;
            updateCKA.KCS_Article_Owner__c = userIdToUserMap.containsKey(kav.OwnerId) ? userIdToUserMap.get(kav.OwnerId).Email : '';
            updateCKA.KCS_Article_Author__c = userIdToUserMap.containsKey(kav.Author__c) ? userIdToUserMap.get(kav.Author__c).Email : '';
            if(ckaMap.containsKey(kav.Custom_Knowledge_Article__c) && ckaMap.get(kav.Custom_Knowledge_Article__c).Knowledge__c != kav.Id){
                updateCKA.Knowledge__c = kav.Id;
            }
            updateCKAList.add(updateCKA);
            
            if(kav.PublishStatus == 'Online'){
                publishedKAVSet.add(kav.Id);
            }

        }

        //Update Custom Knowledge Articles
        if(!updateCKAList.isEmpty()){
            update updateCKAList;
        }

        //Unflag Knowledge Comments
        if(!publishedKAVSet.isEmpty()){
             //unflagAllKCs(publishedKAVSet);
        }
    }
    
    public static void unflagAllKCs(Set<Id> publishedKAVSet){
        List<Knowledge_Comment__c> updateKCList = new List<Knowledge_Comment__c>();
        
        for(Knowledge_Comment__c kc : [SELECT Id, Active__c FROM Knowledge_Comment__c WHERE Knowledge__c IN :publishedKAVSet]){
            if(kc.Active__c == true){
                kc.Active__c = false;
                updateKCList.add(kc);
            }
        }

        //Update Knowledge Comments
        if(!updateKCList.isEmpty()){
            update updateKCList;
        }
    }

    //Delete CKA

    //Undelete CKA

    public static void updateCommunityAuthor(List<Knowledge__kav> kavList, Set<Id> kavAuthors){
        Map<Id, String> userToEmailMap = new Map<Id, String>();
        for(User usr : [SELECT Id, Email FROM User WHERE Id IN :kavAuthors]){
            userToEmailMap.put(usr.Id, usr.Email);
        }

        Map<String, Id> emailtoContactMap = new Map<String, Id>();
        for(Contact con : [SELECT Id, Email
                            FROM Contact
                            WHERE Email IN :userToEmailMap.values()
                            ORDER BY LastModifiedDate DESC]){

            if(!emailtoContactMap.containsKey(con.Email)) {
                emailtoContactMap.put(con.Email, con.Id);
            }
        }

        Map<String, Id> contactToCommunityUserMap = new Map<String, Id>();
        for(LiSFIntegration__Li_Community_User__c communityUser : [SELECT Id, LiSFIntegration__Email_Address__c, LiSFIntegration__Contact__c
                                                                    FROM LiSFIntegration__Li_Community_User__c
                                                                    WHERE LiSFIntegration__Contact__c IN : emailtoContactMap.values()
                                                                    ORDER BY LastModifiedDate DESC]){
            if(!contactToCommunityUserMap.containsKey(communityUser.LiSFIntegration__Contact__c)){
                contactToCommunityUserMap.put(communityUser.LiSFIntegration__Contact__c, communityUser.Id);
            }
        }

        for(Knowledge__kav kavUpdate : kavList){
            if(userToEmailMap.containsKey(kavUpdate.Author__c)){
                if(emailtoContactMap.containsKey(userToEmailMap.get(kavUpdate.Author__c))) {
                    if (contactToCommunityUserMap.containsKey(emailtoContactMap.get(userToEmailMap.get(kavUpdate.Author__c)))) {
                        kavUpdate.Community_Author__c = contactToCommunityUserMap.get(emailtoContactMap.get(userToEmailMap.get(kavUpdate.Author__c)));
                    } else {
                        System.debug('Community User record related to Contact not found!');
                        kavUpdate.Community_Author__c = 'a7019000001cgAAAAY';
                    }
                }
                else{
                    System.debug('Contact record with matching Email not found!');
                    kavUpdate.Community_Author__c = 'a7019000001cgAAAAY';
                }
            }
            else{
                System.debug('User record for Knowledge Author not found!');
                kavUpdate.Community_Author__c = 'a7019000001cgAAAAY';
            }
        }
    }
}