/*
 * Class Name - AgileUtility
 * Test Class Name - AgileUtilityTest
 * 
 * %W% %E% Grazitti Team
 * This class is the utility class for Agile App.
 */

/**
 * 
 * @version 1.0 November 26, 2019
 * @author Ayushi Mahawer <ayushi.mahawer@grazitti.com>
 * 
 * @author Ayushi Mahawer <ayushi.mahawer@grazitti.com>
 * @since November 26, 2019
 */
global with sharing class AgileUtility {

    public static Id businessSystemsRecTypeId
            = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Business Systems Support Ticket').getRecordTypeId();

    @AuraEnabled
    webservice static String createNewAgileWork(Id caseId) {
        String recordtype = '';
        Boolean onSuccess;
        try {
            Case caseData = [SELECT Id, Owner.Id, Description, Subject, Type, Task_or_Project__c, 
                            ContactID, Work__c, Business_System__c, Business_System_Category__c, 
                            Priority, Contact.Department 
                            FROM Case 
                            WHERE Id =: caseId];
                    
            if (caseData.Work__c == null) {
                Work__c work = new Work__c();
                
                String productTagId = [SELECT Id 
                                        FROM Product_Tag__c 
                                        WHERE Name =: caseData.Business_System__c LIMIT 1].Id;
                
                if (caseData.Type == 'Bug') {
                    recordtype = Work__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Bug').getRecordTypeId();
                                        system.debug('rtid : '+ recordtype );

                } else {
                    recordtype = Work__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('User Story').getRecordTypeId();
                    system.debug('rtid : '+ recordtype );
                }

                if (productTagId != null) {
                    work.Priority__c = caseData.Priority;
                    work.Case__c = caseData.Id;
                    work.Subject__c = caseData.Subject;
                    work.Status__c = 'New';
                    work.Product_Tag__c = productTagId;
                    work.RecordTypeId = recordtype;

                    insert work;
                    
                    caseData.Work__c = work.Id;
                    update caseData;
                }
            } else {
                return label.Error_message_for_create_work_from_case;
            }
        } catch (Exception ex) {
            return ex.getMessage();
        }
        
        return String.valueOf(0);
    }

    @AuraEnabled
    webservice Static String CreateChangeControl(Id releaseId) {
        
        if (releaseId != null) {
            Release__c releaseData = [SELECT Id, Name, Release_Manager__c, Change_Control_Case__c
                                        FROM Release__c
                                        WHERE ID =: releaseId];
            
            if (releaseData != null && releaseData.Release_Manager__c != null
                && releaseData.Change_Control_Case__c == null) {
                Case caseRec = new Case (); 
                caseRec.Subject = releaseData.Name + ' Approval';
                caseRec.ownerId = releaseData.Release_Manager__c;
                caseRec.Business_System__c = 'SFDC';
                caseRec.Business_System_Category__c = 'Change Control';
                caseRec.ContactId = label.ContactId_for_Change_Control_Case;
                caseRec.Description = releaseData.Id;
                caseRec.RecordTypeId = businessSystemsRecTypeId;
                
                try {
                    insert caseRec;
                    releaseData.Change_Control_Case__c = caseRec.Id;
                    update releaseData;
                } catch (Exception ex) {
                    return ex.getMessage();
                }
            } else {
                return label.Error_message_for_Create_Control_Change_Case;
            }
            return String.valueOf(0);
        }
        return String.valueOf(0);
    }
}