@isTest
public class SelectProposalAttachment_CPQTest {

    static testMethod void testSelectProposalAttachment_CPQ() {
        Account account = (Account)SmartFactory.createSObject('Account');
        insert account;
        
        Contact contact = (Contact)SmartFactory.createSObject('Contact');
        contact.AccountId = account.Id;
        insert contact;
        
        Opportunity opp = (Opportunity)SmartFactory.createSObject('Opportunity');
        opp.AccountId = account.Id;
        insert opp;
        
        SBQQ__Quote__c quote = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opp.Id;
        insert quote;
        
        Attachment attach = (Attachment)SmartFactory.createSObject('Attachment');
        attach.parentId = quote.Id;
        insert attach;
        
        PageReference pageRef = Page.SelectProposalAttachment_CPQ;
        pageRef.getParameters().put('pid', quote.Id);
        Test.setCurrentPageReference(pageRef);
        SelectProposalAttachment_CPQ spa = new SelectProposalAttachment_CPQ(null);
        spa.isChecked = true;
        spa.nextbutton();
        spa.prevbutton();
        spa.getAttachments();
        spa.attachments.get(0).selected = true;
        spa.doSelect();
        spa.doCancel();
    }
}