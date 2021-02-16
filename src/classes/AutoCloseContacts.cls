/*
 * Class Name - AutoCloseContacts.
 * Test Class Name - AutoCloseLeadsContactsTest.
 * 
 * %W% %E% Grazitti Team
 * This batch class closes those Contact where there's 
 * no activity in the last 90 days
 */

/**
 * #W-009808
 * Autoclose As/Contacts after 90 days with no activity
 * 
 * This class runs daily and Auto Close the Contact that 
 * meets the Criteria
 * @author Grazitti Team
 * @version 1.0 September 19, 2018
 */

 public class AutoCloseContacts implements 
        Database.Batchable<sObject>, Database.Stateful {
 
    public List<Contact> allClosedContacts = new List<Contact>();
    public Auto_Close_Limits__c limits = Auto_Close_Limits__c.getInstance('System Settings');
    public String finalStatus = limits.Final_Status__c;
    public String outComeReason = limits.Lead_Outcome_Reason__c;
    public List<String> addressValues = limits.Recipient__c.split(',');

    public Database.QueryLocator start(Database.BatchableContext BC){

        Date mkkLimit = System.Today().addDays(- Integer.valueOf(limits.marketing_Limit__c));
        Date nonMkkLimit = System.Today().addDays(- Integer.valueOf(limits.Non_Marketing_Limit__c));
        List<String> statusCriteria = limits.Status_Criteria__c.split(',');

        String query = 'SELECT ID, Name, Last_Task_Completed_Date__c, Contact_Status__c, Marketing_Generated__c '
                       + 'FROM Contact WHERE Contact_Status__c IN :statusCriteria '
                       + 'AND ((Last_Task_Completed_Date__c < :nonMkkLimit '
                       + 'AND Marketing_Generated__c = False) '
                       + 'OR (Last_Task_Completed_Date__c < :mkkLimit '
                       + 'AND Marketing_Generated__c = True))';

        System.debug('query ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext BC, List<Contact> scope){
        List<Contact> contactsToClose = new List<Contact>();

        //Eddie Wong
        //Date: 04/21/2020
        //W-004891
        //To create a "Grace Period" for the Contact Auto-Close automation

        set<Id> contactIds = new Set<Id>();

        for(Contact c : scope)
        {
            contactIds.add(c.Id);
        }

        Map<Id, ContactHistory> contactHistoryIdContactHistoryMap = new Map<Id, ContactHistory>
                ([Select ContactId FROM ContactHistory WHERE ContactId IN :contactIds and Field = 'Contact_Status__c' and createddate = last_n_days:10]);

        Map<Id, ContactHistory> contactIdContactHistoryMap = new Map<Id, ContactHistory>();

        for(ContactHistory cH : contactHistoryIdContactHistoryMap.values())
        {
            contactIdContactHistoryMap.put(cH.ContactId, cH);
        }

        for (Contact con : scope) {

            ContactHistory contactHistory = contactIdContactHistoryMap.get(con.Id);

            if(contactHistory == null)
            {
                con.Contact_Status__c = finalStatus;
                con.Contact_Outcome_Reason__c = outComeReason;
                contactsToClose.add(con);
            }

        }
        try {
            if (!contactsToClose.isEmpty()) {
                update contactsToClose;
                for(Contact con : contactsToClose){
                    allClosedContacts.add(con);
                }
            }
        
        } catch (Exception e) {
            String body = 'Errors occurred during batch process.<br/><br/>' 
                + 'Batch Class Name: AutoCloseContacts.<br/><br/>'
                + 'Error Message: ' + e.getMessage() + '<br/>'
                + 'Error Type: ' + e.getTypeName() + '<br/>' 
                + 'Line Number: ' + e.getLineNumber() + '<br/>' 
                + 'Stack Trace: ' + e.getStackTraceString() + '<br/><br/><br/>';

            body += generateEmailBody(contactsToClose, 'LIST OF AUTO-CLOSED CONTACTS FAILED TO UPDATE');

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Error: Auto Close Contacts');
            mail.setToAddresses(new String[]{'alteryxsfdc@grazitti.com'});
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.Email[] { mail });
        }
    }

    public void finish(Database.BatchableContext BC){
        String body = generateEmailBody(allClosedContacts, 'LIST OF AUTO-CLOSED CONTACTS');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(addressValues);
        mail.setSubject('Auto Close Contacts '+System.UserInfo.getOrganizationName());
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    /*public void execute(SchedulableContext SC) {
        AutoCloseContacts batch = new AutoCloseContacts();
        Database.executeBatch(batch);

    }*/

    public static String generateEmailBody(List<Contact> contactsToClose, String text){
        String Message = '<table style="border:1px solid black;border-collapse: collapse;"><tr><th colspan="12" style="padding: 0 10px;border:1px solid black;">'
                         + text + '</th></tr><tr><th style="padding: 0 10px;border:1px solid black;">ID</th><th style="padding: 0 10px;border:1px solid black;">Name</th><th style="border:1px solid black;">Status</th><th style="padding: 0 10px;border:1px solid black;">Record Type</th><th style="padding: 0 10px;border:1px solid black;">Last Task Completed Date</th> <th style="padding: 0 10px;border:1px solid black;"> Marketing Generated</th></tr>';
        
        for(Contact con : contactsToClose){
            Message+='<tr>'+
                '<td style="border:1px solid black;" >' +con.Id+'</td>'+
                '<td style="border:1px solid black;" >' +con.Name+'</td>'+
                '<td style="border:1px solid black;">'  +con.Contact_Status__c+'</td>'+
                '<td style="border:1px solid black;">Contact</td>'+
                '<td style="border:1px solid black;">'  +con.Last_Task_Completed_Date__c+'</td>'+
                '<td style="border:1px solid black;">'  +con.Marketing_Generated__c+'</td>'+
                '</tr>';            
        } 
        
        Message+='</table>';
        System.debug('Message'+Message);
        return Message;

    }
}