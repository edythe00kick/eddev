/*
* @name : TestUtils : a class for commonly needed Test Utility object creation scripts
* @author : JP Horton 
* @date : 20170913
*/
global without sharing class TestUtils {

    public static Account getAccount(String name)
    {        
        Account a = new Account();
        a.Name = name;
        a.Phone = '1234567890';
        a.Type ='Prospect';
                
        return a;
    }
    
    public static Contact getContact(String name,Id AccountId)
    {        
        Contact c = new Contact();
        c.LastName = name;
        c.AccountID = AccountId;
                
        return c;
    }
    
    public static Opportunity getOpportunity(String name, Id AccountId, Id RecTypeId)
    {
        Opportunity o = new Opportunity();
        o.AccountID = AccountId;
        o.Name = name;
        o.RecordTypeId = RecTypeId;
                
        o.StageName = '0 - Discovery';
        o.CloseDate =  system.today();

        return o;
    }
    
    public static Attachment getAttachment(String name, Id ParentId)
    {
        Attachment attach=new Attachment();     
        attach.Name = name;
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = ParentId;
        return attach;
    }
    
    public static Case getCase(Id RecTypeId){
        Case c = new Case();
        c.RecordTypeId = RecTypeId;
        c.Status = 'Submitted';
        c.Type = 'Bug';
        c.Task_or_Project__c = 'Task';
        c.Requested_Completion_Date__c = date.today();
        c.Estimated_Completion_Date__c = date.today();
        return c;
    }
    
    public static User getUser(String name,Id profId){
        User u = new User();
        u.ProfileId = profId;
        u.LastName = name;
        u.Email = 'puser000@amamama.com';
        u.Username = 'puser000@amamama.com' + System.currentTimeMillis();
        u.CompanyName = 'TEST';
        u.Title = 'title';
        u.Alias = 'alias';
        u.TimeZoneSidKey = 'America/Los_Angeles';
        u.EmailEncodingKey = 'UTF-8';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';   
        
        return u;
    }
    
    public static agf__ADM_Work__c getWork(String subString, Id RecId){
        agf__ADM_Work__c w = new agf__ADM_Work__c();
        w.RecordTypeId = RecId;
        w.agf__Subject__c = subString;
        
        return w;
    }

}