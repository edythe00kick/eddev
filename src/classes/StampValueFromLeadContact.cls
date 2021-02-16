/*
 * Class Name - StampValueFromLeadContact.
 * Test Class Name - ScheduleStampValueTest.
 * 
 * %W% %E% Grazitti Team
 * This batch class is the replacement of Stamp Values from Lead/Contact 
 * process builder. 
 */

/**
 * #W-009852
 * UTM Source
 * 
 * This class runs multiple times a day and update the fields of the 
 * CampaignMember records whose HasResponded field is true and are not already 
 * executed.
 * 
 * @author Hemendra Singh Rajawat
 * @version 1.0 July 04, 2018
 */

public class StampValueFromLeadContact 
    implements Database.Batchable<sObject>, Database.Stateful {

    // Store the campaign member id and contact id related to that campaign member.
    public static Map<Id,Id> campMemIdToContIdMap = new Map<Id,Id>();
    // Store the campaign member id and lead id related to that campaign member.
    public static Map<Id,Id> campMemIdToLeadIdMap = new Map<Id,Id>();
    // Store the contact id and contact.
    public Map<Id,Contact> contIdIdToContMap = new Map<Id,Contact>();
    // Store the lead id and lead.
    public Map<Id,Lead> leadIdIdToLeadMap = new Map<Id,Lead>();
    // Store the fields of the UTM Source Custom Metadata.
    public List<UTM_Source_Fields__mdt> fields;
    // Store the campaign member records to update.
    public List<CampaignMember> campMemToUpdate = new List<CampaignMember>();
    // Store the lead records to update.
    public Set<Lead> ldsToUpdate = new Set<Lead>();
    // Store the contact records to update.
    public Set<Contact> contsToUpdate = new Set<Contact>();
    
    /**
     * Collects the batches of records or objects to be passed to execute.
     */
    public List<CampaignMember> start(Database.BatchableContext bc) {
        DateTime lastDate 
            = UTM_Source_Date__c.getValues('LastDate').Last_Executed_Date__c;

        fields = [SELECT Lead_Api__c, Contact_Api__c,
                  CampMem_Api__c 
                  FROM UTM_Source_Fields__mdt];

        String query = 'SELECT Id, ContactId, LeadId';
        for (UTM_Source_Fields__mdt field : fields) {
            query += ', ' + field.CampMem_Api__c;
        }
        query += ' FROM CampaignMember WHERE LastModifiedDate >= :lastDate '
            + 'AND HasResponded = true AND Batch_Executed__c = false';

        system.debug('*** query : '+ query);
        List<CampaignMember> campMembers = Database.query(query);
        for (CampaignMember campMem : campMembers) {
            if (campMem.ContactId != null) {
                campMemIdToContIdMap.put(campMem.Id, campMem.ContactId);
            } else if (campMem.LeadId != null) {
                campMemIdToLeadIdMap.put(campMem.Id, campMem.LeadId);
            }
        }

        if (!campMemIdToLeadIdMap.isEmpty()) {
            List<Id> leadIds = campMemIdToLeadIdMap.values();
            String query1 = 'SELECT Id';
            for (UTM_Source_Fields__mdt field : fields) {
                query1 += ', ' + field.Lead_Api__c;
            }
            query1 += ' FROM Lead WHERE ID IN :leadIds'; 
            system.debug('*** query1 :' + query1);
            List<Lead> leads = Database.query(query1);
            leadIdIdToLeadMap = new Map<Id, Lead>(leads);
        }

        if (!campMemIdToContIdMap.isEmpty()) {
            List<Id> contIds = campMemIdToContIdMap.values();
            String query2 = 'SELECT Id';
            for (UTM_Source_Fields__mdt field : fields) {
                query2 += ', ' + field.Contact_Api__c;
            }
            query2 += ' FROM Contact WHERE ID IN :contIds'; 

            system.debug('*** query2 : ' + query2);
            List<Contact> contacts = Database.query(query2);
            contIdIdToContMap = new Map<Id, Contact>(contacts);
        }
        system.debug('*** campMembers.size() :' + campMembers.size());
        return campMembers;
    }

    /**
     * Process each batch of records which are coming from start.
     * Update the fields of the campaignmember records.
     */
    public void execute(Database.BatchableContext bc, 
                        List<CampaignMember> campMembers) {

        Contact cont;
        Lead ld;
        Boolean dataCorrect;
        Map<String, Schema.SobjectField> leadfields 
            = Lead.sObjectType.getDescribe().fields.getMap();

        Map<String, Schema.SobjectField> contfields 
            = Contact.sObjectType.getDescribe().fields.getMap();

        for (CampaignMember campMem : campMembers) {
            if (campMem.ContactId != null 
                && contIdIdToContMap.containsKey(campMem.ContactId)) {

                cont = contIdIdToContMap.get(campMem.ContactId);
                dataCorrect = false;

                for (UTM_Source_Fields__mdt field : fields) {
                    if (cont.get(field.Contact_Api__c) != null) {
                        dataCorrect = true;
                        break;
                    }
                }

                if (dataCorrect) {
                    for (UTM_Source_Fields__mdt field : fields) {
                        if (campMem.get(field.CampMem_Api__c) != cont.get(field.Contact_Api__c)) {
                            campMem.put(field.CampMem_Api__c, cont.get(field.Contact_Api__c));
                        }
                        if (contfields.get(field.Contact_Api__c).getDescribe().isUpdateable()) {
                            cont.put(field.Contact_Api__c, null);
                        }
                    }
                    campMem.Batch_Executed__c = true;
                    campMemToUpdate.add(campMem);
                    contsToUpdate.add(cont);
                }
            } else if (campMem.LeadId != null 
                && leadIdIdToLeadMap.containsKey(campMem.LeadId)) {

                ld = leadIdIdToLeadMap.get(campMem.LeadId);
                dataCorrect = false;

                for (UTM_Source_Fields__mdt field : fields) {
                    if (ld.get(field.Lead_Api__c) != null) {
                        dataCorrect = true;
                        break;
                    }
                }

                if (dataCorrect) {
                    for (UTM_Source_Fields__mdt field : fields) {
                        if (campMem.get(field.CampMem_Api__c) != ld.get(field.Lead_Api__c)) {
                            campMem.put(field.CampMem_Api__c, ld.get(field.Lead_Api__c));
                        }
                        if (leadfields.get(field.Lead_Api__c).getDescribe().isUpdateable()) {
                            ld.put(field.Lead_Api__c, null);
                        }
                    }
                    campMem.Batch_Executed__c = true;
                    campMemToUpdate.add(campMem);
                    ldsToUpdate.add(ld);
                }
            }
        }
    }

    /**
     * Execute any post-processing operations.
     */
    public void finish(Database.BatchableContext bc){
        try {
        system.debug('*** campMemToUpdate.size() :' + campMemToUpdate.size());
                system.debug('*** contsToUpdate.size() :' + contsToUpdate.size());
                        system.debug('*** ldsToUpdate.size() :' + ldsToUpdate.size());
            if (!campMemToUpdate.isEmpty()) {
                update campMemToUpdate;
            }
            if (!contsToUpdate.isEmpty()) {
                List<Contact> contactsToUpdate = new List<Contact>(contsToUpdate);
                update contactsToUpdate;
            }
            if (!ldsToUpdate.isEmpty()) {
                List<Lead> leadsToUpdate = new List<Lead>(ldsToUpdate);
                update leadsToUpdate;
            }
        } catch (Exception e) {
            String body = 'Errors occurred during batch process.\n\n' 
                + 'Batch Class Name: StampValueFromLeadContact.\n\n'
                + 'Error Message: ' + e.getMessage() + '\n'
                + 'Error Type: ' + e.getTypeName() + '\n' 
                + 'Line Number: ' + e.getLineNumber() + '\n' 
                + 'Stack Trace: ' + e.getStackTraceString();

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Error: Stamp Value From Lead/Contact');
            mail.setToAddresses(new String[]{'alteryxsfdc@grazitti.com'});
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.Email[] { mail });
        }
    }
}