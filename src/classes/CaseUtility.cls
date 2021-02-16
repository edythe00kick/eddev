/**
 * Utility methods for the Case object
 * 
 * @author  JP Horton <jhorton@alteryx.com>
 * @since   20170901
 */
global with sharing class CaseUtility {

    /**
    * @name: CaseUtility.CreateNewAgileWork
    * @author: JP Horton
    * @description: This method creates a New agf__ADM_Work__c record from an existing Case 
    * @date: 20170901
    * @param: Id CaseId
    * @methods: N/A
    **/ 
    webservice static void CreateNewAgileWork(Id CaseId) {     
        //Query for the fields we care about from the case. 
        // Added Requesting_Department__c - JPH - W-010008 - 20181031
        Case c = [SELECT Id, Owner.Id, Description, Subject, Type, Task_or_Project__c, ContactID, agf__ADM_Work__c, Business_System__c, Business_System_Category__c, Priority, Contact.Department FROM Case WHERE Id =: CaseId];
        agf__ADM_Build__c b = [SELECT Id FROM agf__ADM_Build__c ORDER BY CreatedDate ASC LIMIT 1];
        
        if(c.agf__ADM_Work__c == null){
            //Create new agf__ADM_Work__c record to be inserted.
            agf__ADM_Work__c w = new agf__ADM_Work__c();
            String recordtype = ''; 
            String productTagId = [SELECT Id FROM agf__ADM_Product_Tag__c WHERE Name =: c.Business_System__c LIMIT 1].Id;

                /*
            IF(c.Task_or_Project__c == 'Project' || c.Type == 'New Feature' || c.Type == 'Enhancement'){
                recordtype = agf__ADM_Work__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Investigation').getRecordTypeId();
                w.agf__Details_and_Steps_to_Reproduce__c = c.Description;
                w.agf__Severity_Level__c = '4';
                w.agf__Assignee__c = UserInfo.getUserId();
            }
            ELSE*/ 
            IF(c.Type == 'Bug'){
                recordtype = agf__ADM_Work__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Bug').getRecordTypeId();
                w.agf__Details__c = c.Description;
                w.agf__Found_in_Build__c = b.Id;
                w.agf__Priority__c = c.Priority;
            }
            ELSE {
                recordtype = agf__ADM_Work__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('User Story').getRecordTypeId();
                w.agf__Details__c = c.Description;
            }
            
            IF(c.ContactID != null){
                //Added Contact Lookup for the Requestor - JPH - W-010008 - 20181031
                w.Requester__c = c.ContactID;
            }
            
            /*
            IF(c.Owner.Id != null && string.valueOf(c.Owner.Id).startsWith('005')){
                // Owner is a User
                w.BA_Owner__c = c.Owner.Id; 
            }
            // Removed for new Agile process - ZComon - W-010763 -20181212
            */ 
            
            w.RecordTypeId = recordtype;
            w.Origin_Case__c = c.Id;
            w.agf__Subject__c = c.Subject;
            w.agf__Status__c = 'New';
            w.agf__Product_Tag__c = productTagId;
            // Added department lookup during creation - JPH - W-010008 - 20181031
            w.Department__c = c.Contact.Department;
            w.Type_Custom__c = c.Business_System_Category__c;
            try{
                 insert w;
            } catch (DMLException e){
                 c.addError('**** There was a problem inserting the work item : Error Code : '+ e); return;
            } 
     
            c.agf__ADM_Work__c = w.Id;
            try{
                 update c;
            } catch (DMLException e){
                 c.addError('**** There was a problem updating the case item : Error Code : '+ e); return;
            }       
        } else {return;}
    }
}