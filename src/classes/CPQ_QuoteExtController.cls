/*------------------------------------------------------------------------+
Original Shift(developer@originalshift.com)
Purpose: Controls the user-triggered step transitions, especially approvals.
  
History:
Apr 19/19 - Original Shift - Initial Implementation for Adv. Approvals
Apr 22/19 - Original Shift - Added Submit to Deal Desk
------------------------------------------------------------------------+*/ 
public with sharing class CPQ_QuoteExtController {
    private Id quoteId; //the SBQQ__Quote__c Id
    
    //Simple constructor
    public CPQ_QuoteExtController(ApexPages.StandardController stdController) {
        quoteId = stdController.getId();
    }
    
    //Submit for Approval (Adv Approvals)
    public PageReference onSubmit() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.submit(quoteId, SBAA__Approval__c.Quote__c);
        }
        return new PageReference('/' + quoteId);
    }
    
    //Recall Approval (Adv Approvals)
    public PageReference onRecall() {
        if (quoteId != null) {
            SBAA.ApprovalAPI.recall(quoteId, SBAA__Approval__c.Quote__c);
            //Sergio Flores
            //Date: 07/23/2019
            //W-012635
            update new SBQQ__Quote__c(Id = quoteId, Locked_For_Reps__c = false);
        }
        return new PageReference('/' + quoteId);
    }
    
    //Submit to Deal Desk
    public PageReference onSubmitToDD() {
        Id cpqQuoteRecordTypeId_Submitted = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('SubmitToDD').getRecordTypeId();
        if(quoteId != null && cpqQuoteRecordTypeId_Submitted != null) {
	        update new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'Deal Desk Review', RecordTypeId = cpqQuoteRecordTypeId_Submitted);
        }
        return new PageReference('/' + quoteId);
    }
    
    //Recall from Deal Desk
    public PageReference onRecallFromDD() {
        Id cpqQuoteRecordTypeId_Draft = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByDeveloperName().get('Draft').getRecordTypeId();
        if(quoteId != null && cpqQuoteRecordTypeId_Draft != null) {
	        update new SBQQ__Quote__c(Id = quoteId, SBQQ__Status__c = 'Draft', RecordTypeId = cpqQuoteRecordTypeId_Draft);
        }
        return new PageReference('/' + quoteId);
    }
    
}