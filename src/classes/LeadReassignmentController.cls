/**
 * Created by ewong on 10/20/2020.
 */

public with sharing class LeadReassignmentController {
    @AuraEnabled
    public static boolean leadReassignemntEmailManager(String recordId) {
        System.debug('eddie inside leadReassignemntEmailManager = ' + recordId);
        Id leadOwnerId = System.UserInfo.getUserId();
        System.debug('eddie check leadOwnerId + ' + leadOwnerId);

        String strManagerName;
        String strXDRName;
        String strXDREmail;
        String strManagerEmail;
        String strLeadId;
        String strURL = URL.getSalesforceBaseUrl().toExternalForm() + '/' + recordId;

        //List<User> u = new List<User>([SELECT Id,Name,ManagerId,Manager.Name,Manager.Email FROM Users WHERE Id =: leadOwnerId LIMIT 1]);
        Map<Id, User> uIdToUserMap = new Map<Id, User>([SELECT Id,Name,Email,ManagerId,Manager.Name,Manager.Email FROM User WHERE Id =: leadOwnerId LIMIT 1]);

        for(User u : uIdToUserMap.values()) {
            strManagerName = u.Manager.Name;
            strXDRName = u.Name;
            strManagerEmail = u.Manager.Email;
            strXDREmail = u.Email;
        }

        Map<Id, Lead> leadIdToLeadMap = new Map<Id, Lead>([SELECT Id, Lead_ID__c FROM Lead WHERE Id =: recordId LIMIT 1]);

        for(Lead ld : leadIdToLeadMap.values()) {
            strLeadId = ld.Lead_ID__c;
        }

        String[] toAddresses = new String[] {strManagerEmail};
        String[] ccAddresses = new String[] {strXDREmail};
        Messaging.Email[] messages = new Messaging.Email[0];

        OrgWideEmailAddress noreplyEmail = [SELECT Id, DisplayName FROM OrgWideEmailAddress WHERE Address = 'no_reply@alteryx.com' LIMIT 1];

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setOrgWideEmailAddressId(noreplyEmail.Id);
        mail.setToAddresses(toAddresses);
        mail.setCcAddresses(ccAddresses);
        mail.setSubject('XDR lead reassignment request for ' + strLeadId);
        mail.setHtmlBody('Hello ' + strManagerName + ',</br></br>' + strXDRName + ' has requested to reassign this lead to the appropriate representative.  Please update the lead owner to the correct representative.' + '</br></br> Link to lead record: ' + strURL + '</br></br>Thank You!');
        messages.add(mail);

        if(!messages.isEmpty()){
            Messaging.SendEmailResult [] r = Messaging.sendEmail(messages, false);
            if(r[0].isSuccess()){
                System.debug('Sent :: '+' ');

            }else{
                System.debug('Error in sent :: '+r[0].getErrors()[0].getMessage());
            }
        }

        return true;

    }

}