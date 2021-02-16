/**
 * Created by ewong on 7/8/2020.
 */

public with sharing class AmendContractGateway {
    public static void amendContractAPICall(Map<Id, Id> oppIdToContIdMap) {
        System.debug('In AmendContractGateway = ' + oppIdToContIdMap);
        System.debug('eddie inside userinfo.getProfileId()' + userinfo.getProfileId());
        System.debug('eddie check Userinfo.getUserId() = ' + Userinfo.getUserId());

        Id contractId;
        String strOppId;
        String strOppName;
        Id oppOwnerId;

        Map<Id, Opportunity> oppIdToOppMap = new Map<Id, Opportunity>([SELECT Id,Name,OwnerId,SBQQ__AmendedContract__c FROM Opportunity WHERE Id IN :oppIdToContIdMap.keyset()]);

        System.debug('eddie check oppIdToOppMap = ' + oppIdToOppMap);

        for (Id oppId : oppIdToOppMap.keySet()) {
            System.debug('eddie inside for loop oppIdToContIdMap' + oppIdToOppMap.get(oppId));
            contractId = oppIdToOppMap.get(oppId).SBQQ__AmendedContract__c;
            strOppId = oppId;
            strOppName = oppIdToOppMap.get(oppId).Name;
            oppOwnerId = oppIdToOppMap.get(oppId).OwnerId;
        }

        try {
            System.debug('inside try api call = ' + Userinfo.getUserId());

            CPQ_ApiWrapper.amendContract(contractId);
        } catch (Exception e) {
            System.debug('inside catch exception + ' + e.getMessage());

            Messaging.CustomNotification notification2 = new Messaging.CustomNotification();
            notification2.setBody('Here is the error message ===== ' + e.getMessage());
            notification2.setTitle('Co-term quote failed to create for opp [' + strOppName + ']. Please reach out to Deal Desk for help.');
            notification2.setSenderId(Userinfo.getUserId());
            notification2.setNotificationTypeId(System.Label.Custom_Notification_Type_ID);
            notification2.setTargetId(strOppId); // target object id
            notification2.send(new Set<String> { oppOwnerId }); // target user id.

            String[] toAddresses = new String[] {'ewong@alteryx.com'}; //Need to change to dg_sfdcteam@alteryx.com
            Messaging.Email[] messages = new Messaging.Email[0];

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject('CotermExceptionError IN AmendContractGateway');
            //mail.setPlainTextBody('test 1');
            mail.setHtmlBody('Here is the opportunity ID: ' + strOppId + '</br></br><b>' + e.getMessage());
            messages.add(mail);

            Messaging.sendEmail(messages, false);
        }
    }

}