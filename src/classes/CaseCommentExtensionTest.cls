@isTest
public class CaseCommentExtensionTest{
    Public static testmethod void method(){
 
        Case cas = new case(Subject='Test this Code',Description='This Description',Products__c ='Data',Business_System_Category__c='Feature Enhancement',Business_System__c='SFDC',Requested_Completion_Date__c=Date.today().AddDays(7),Case_Category__c='SDK',Severity__c='SEV 1');
        Insert cas;  
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cas);
        CaseCommentExtension cce = new CaseCommentExtension(sc);
        cce.addComment();
        PageReference pageRef = Page.Post_Case_Comment;
    }
}