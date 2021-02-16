/*
 * Class Name - AutoCloseLeads.
 * Test Class Name - AutoCloseLeadsContactsTest.
 * 
 * %W% %E% Grazitti Team
 * This batch class closes those Leads where there's 
 * no activity in the last 90 days
 */

/**
 * #W-009808
 * Autoclose Leads after 90 days with no activity
 * 
 * This class runs daily and Auto Close the Leads that 
 * meets the Criteria
 * @author Grazitti Team
 * @version 1.0 September 19, 2018
 */

 public class AutoCloseLeads implements  Database.Batchable<sObject>,  Database.Stateful {

    
    public List<Lead> allClosedLeads = new List<Lead>();
    public Auto_Close_Limits__c limits = Auto_Close_Limits__c.getInstance('System Settings');
    public String finalStatus = limits.Final_Status__c;
    public String leadOutComeReason = limits.Lead_Outcome_Reason__c;
    public List<String> addressValues = limits.Recipient__c.split(',');

    public Database.QueryLocator start(Database.BatchableContext bc) {

        system.debug(LoggingLevel.INFO,'Inside start method of AutoCloseLeads');
        Date mkkLimit = System.Today().addDays(- Integer.valueOf(limits.marketing_Limit__c));
        Date nonMkkLimit = System.Today().addDays(- Integer.valueOf(limits.Non_Marketing_Limit__c));
        List<String> statusCriteria = limits.Status_Criteria__c.split(',');
        //Name: Chris Salgado Date: 8/28/19 Purpose: W-010954
        List<String> leadRecordType = limits.Lead_Record_Type_Name__c.split(',');
        List<String> leadOwnerID = limits.Lead_OwnerID_Exclude__c.split(',');
        
        String query =  'SELECT ID, Name, Last_Task_Completed_Date__c, Status, '
                        + 'Marketing_Generated__c '
                        + 'FROM Lead WHERE Status IN :statusCriteria '
                        + 'AND RecordType.Name IN :leadRecordType '
                        + 'AND OwnerId NOT IN :leadOwnerID '
                        + 'AND ((Last_Task_Completed_Date__c < :nonMkkLimit '
                        + 'AND Marketing_Generated__c = False) '
                        + 'OR (Last_Task_Completed_Date__c < :mkkLimit ' 
                        + 'AND Marketing_Generated__c = True))';

        System.debug(LoggingLevel.INFO,'query ' + query);
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Lead> scope) {
        system.debug(LoggingLevel.INFO,'Inside execute method of AutoCloseLeads' + ' ' + scope);
        system.debug(LoggingLevel.INFO,'Inside execute method of AutoCloseLeads' + ' ' + scope.size());
        List<Lead> leadsToClose = new List<Lead>();

        Set<Id> leadIds = new Set<Id>();

        for(Lead l : scope)
        {
            leadIds.add(l.Id);
        }

        Map<Id, LeadHistory> leadHistoryIdleadHistoryMap = new  Map<Id, LeadHistory>
        ([SELECT LeadId FROM LeadHistory WHERE LeadID IN : leadIds and Field = 'status' and createddate = last_n_days:10]);

        Map<Id, LeadHistory> leadIdleadHistoryMap = new  Map<Id, LeadHistory>();

        for(LeadHistory lh : leadHistoryIdleadHistoryMap.values())
        {
            leadIdleadHistoryMap.put(lh.LeadId, lh);
        }

        //Map of history

        for(Lead ld : scope){

            //Sergio Flores
            //Date: 03/10/2020
            //W-004454
            LeadHistory leadHistory = leadIdleadHistoryMap.get(ld.Id);

            //If leadhistory is null that means there hasn't been a status change in the past 10 days for the lead
            //so it is good to close it out
            if(leadHistory == null)
            {
                ld.Status = finalStatus;
                ld.Lead_Close_Reason__c = leadOutComeReason;
                leadsToClose.add(ld);
            }

        }
        
        system.debug(LoggingLevel.INFO,'Updated Leads' + ' ' + leadsToClose);
        try {
            if (!leadsToClose.isEmpty()) {
                update leadsToClose;
                for(lead lds : leadsToClose){
                    allClosedLeads.add(lds);
                }
            }
        } catch (Exception e) {
            String body = 'Errors occurred during batch process.<br/><br/>' 
                + 'Batch Class Name: AutoCloseLeads.<br/><br/>'
                + 'Error Message: ' + e.getMessage() + '<br/>'
                + 'Error Type: ' + e.getTypeName() + '<br/>' 
                + 'Line Number: ' + e.getLineNumber() + '<br/>' 
                + 'Stack Trace: ' + e.getStackTraceString() + '<br/><br/><br/>';

            body += generateEmailBody(leadsToClose, 'LIST OF AUTO-CLOSED LEADS FAILED TO UPDATE');
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Error: Auto Close Leads with no activity');
            mail.setToAddresses(new String[]{'alteryxsfdc@grazitti.com'});
            mail.setHtmlBody(body);
            Messaging.sendEmail(new Messaging.Email[] { mail });
        }
    }

    public void finish(Database.BatchableContext bc) {
        String body = generateEmailBody(allClosedLeads, 'LIST OF AUTO-CLOSED LEADS');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(addressValues);
        mail.setSubject('Auto Closed Leads with no activity'+System.UserInfo.getOrganizationName());
        mail.setHtmlBody(body);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    /*public void execute(SchedulableContext SC) {
        AutoCloseLeads batch = new AutoCloseLeads();
        Database.executeBatch(batch);

    }*/

    public static String generateEmailBody(List<Lead> LeadsToClose, String text) {
        String Message = '<table style="border:1px solid black;border-collapse: collapse;"><tr><th colspan="12" style="padding: 0 10px;border:1px solid black;">'
                         + text + '</th></tr><tr><th style="padding: 0 10px;border:1px solid black;">ID</th><th style="padding: 0 10px;border:1px solid black;">Name</th><th style="border:1px solid black;">Status</th><th style="padding: 0 10px;border:1px solid black;">Record Type</th><th style="padding: 0 10px;border:1px solid black;">Last Task Completed Date</th> <th style="padding: 0 10px;border:1px solid black;"> Marketing Generated</th></tr>';
        
        for(Lead ld : LeadsToClose){
            Message += '<tr>'+
                '<td style="border:1px solid black;" >' +ld.Id+'</td>'+
                '<td style="border:1px solid black;" >' +ld.Id+'</td>'+
                '<td style="border:1px solid black;">'  +ld.Status+'</td>'+
                '<td style="border:1px solid black;">Lead</td>'+
                '<td style="border:1px solid black;">'  +ld.Last_Task_Completed_Date__c+'</td>'+
                '<td style="border:1px solid black;">'  +ld.Marketing_Generated__c+'</td>'+
                '</tr>';
        }
        
        Message += '</table>';
        System.debug('Message'+Message);
        return Message;
    }
}