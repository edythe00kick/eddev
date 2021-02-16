/**
 * Created by chris on 1/26/2020.
 */

public with sharing class KnowledgeArchiveOverrideController {
    /*public String retUrl {get;set;}
    public Knowledge__kav article {get;set;}*/
    /*private final Knowledge__kav knowledgeArticle;
    private final Custom_Knowledge_Article__c customKnowledgeArticle;*/

    //public KnowledgeArchiveOverrideController(/*ApexPages.StandardController controller*/) {
    @AuraEnabled // added by sharma 27 JAN
    public static String archiveKnowledgeArticle(Id knowledgeId) {
        //retUrl = ApexPages.currentPage().getParameters().get('retURL');
        System.debug('**CSALGADO** : In KnowledgeArchiveOverrideController');
        boolean archiveIssue = false;

        String returnStatus = 'Success';

        Knowledge__kav knowledgeArticle;
        Custom_Knowledge_Article__c customKnowledgeArticle;

        //Query for Knowledge
        knowledgeArticle = [Select Id, KnowledgeArticleId, PublishStatus, ValidationStatus, Custom_Knowledge_Article__c, IsLatestVersion
                            From Knowledge__kav
                            //Where Id = :ApexPages.currentPage().getParameters().get('id')];
                            Where Id = :knowledgeId];
        System.debug('**CSALGADO** Test: ' + knowledgeArticle.KnowledgeArticleId);

        if (knowledgeArticle != null && knowledgeArticle.IsLatestVersion) {
            //Check for KA not already Archived and update KA
            if (knowledgeArticle.PublishStatus == 'Online') {
                DateTime rightNow = datetime.now();
                try {
                    KbManagement.PublishingService.archiveOnlineArticle(knowledgeArticle.KnowledgeArticleId, rightNow);
                }
                catch(exception e){
                    system.debug ('**CSALGADO** Error: ' + e);
                    archiveIssue = true;
                    returnStatus = 'Archive Issue';
                }
                if(!archiveIssue) {
                    //Query for Custom Knowledge
                    customKnowledgeArticle = [Select Id, Status__c From Custom_Knowledge_Article__c Where Id = :knowledgeArticle.Custom_Knowledge_Article__c];

                    //Check for CKA not already Archived and update CKA
                    //Custom_Knowledge_Article__c updateCustomKnowledgeArticle;
                    if (customKnowledgeArticle != null && customKnowledgeArticle.Status__c != 'Archived') {
                        Custom_Knowledge_Article__c updateCustomKnowledgeArticle = new Custom_Knowledge_Article__c(Id = customKnowledgeArticle.Id);
                        updateCustomKnowledgeArticle.Status__c = 'Archived';
                        update updateCustomKnowledgeArticle;
                    } else {
                        System.debug('Error: This Custom Article is already Archived');
                        returnStatus = 'Already Archived';
                    }
                }
            }
            else{
                System.debug('Error: Only Published Articles can be Archived');
                returnStatus = 'Only Published';
            }
        }
        else {
            System.debug('Error: You can only Archive the latest Article Version');
            returnStatus = 'Not Latest';
        }

        //return null;
        return returnStatus;
    }

}