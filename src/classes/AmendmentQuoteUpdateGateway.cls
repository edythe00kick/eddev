/**
 * Created by ewong on 7/14/2020.
 */

public with sharing class AmendmentQuoteUpdateGateway {

    public static void updateAmendmentQuote(Set<Id> conIds, Set<Id> quoteIds) {

        String uId = userinfo.getUserId();
        System.debug('eddie check recursionhandler = ' + Recursionhandler.IsContractAmendExecuted);
        System.debug('eddie inside updateAmendmentQuote');
        System.debug('eddie getUserId = ' + uId);
        Set<Id> oppIdSet = new Set<Id>();
        String strQuoteId;
        String strQuoteName;
        String strOppId;
        String strOppName;
        Id oppOwnerId;
        List<Opportunity> oppListToSetPrimary = new List<Opportunity>();
        //List<SBQQ__Quote__c> quoteListForPrimaryUpdate = new List<SBQQ__Quote__c>();
        List<SBQQ__Quote__c> lQuotes = new List<SBQQ__Quote__c>([SELECT Id,Name,CurrencyIsoCode,OSCPQ_Amended_Contract__c,SBQQ__Opportunity2__c,Quote_Type__c,SBQQ__MasterContract__c,Purchase_Type__c,SBQQ__StartDate__c,SBQQ__ExpirationDate__c,SBQQ__Type__c,SBQQ__EndDate__c
        FROM SBQQ__Quote__c
        WHERE Id IN : quoteIds
        //AND SBQQ__Type__c = 'Amendment'
        //AND Purchase_Type__c = 'Upsell Co-term'
        ]);

        System.debug('eddie checking lQuotes = ' + lQuotes);

        for(Id id : quoteIds){
            strQuoteId = id;
        }

        Map<Id, Opportunity> oppIdToOppMap = new Map<Id, Opportunity>([Select Id,Name,SBQQ__RenewedContract__c,SBQQ__AmendedContract__c,SBQQ__RenewedContract__r.EndDate,OwnerId,CurrencyIsoCode,Type,SBQQ__AmendedContract__r.SBQQ__Quote__r.Order_Group__c,SBQQ__AmendedContract__r.SBQQ__Quote__r.License_Administrator__c
        FROM Opportunity
        WHERE SBQQ__AmendedContract__c IN : conIds
        AND CreatedById != :uId
        AND IsClosed = false
        ORDER BY LastModifiedDate desc
        limit 1]);

        System.debug('eddie checking oppIdToOppMap = ' + oppIdToOppMap);
        System.debug('eddie checking strQuoteId = ' + strQuoteId);

        Map<Id, Opportunity> conIdToOppIdMap = new Map<Id, Opportunity>();

        if (!oppIdToOppMap.isEmpty()){
            for (Opportunity opp : oppIdToOppMap.values()) {
                Opportunity op = new Opportunity();
                op.Id = opp.Id;
                op.SBQQ__PrimaryQuote__c = strQuoteId;
                oppListToSetPrimary.add(op);
                conIdToOppIdMap.put(opp.SBQQ__AmendedContract__c,opp);
            }
        }

        System.debug('eddie checking conIdToOppIdMap = ' + conIdToOppIdMap);

        List<SBQQ__Quote__c> lQuotesForUpdate = new List<SBQQ__Quote__c>();

        if (!lQuotes.isEmpty()) {
            for (SBQQ__Quote__c quote : lQuotes) {
                System.debug('eddie inside for loop to check conIdToOppIdMap' + conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c));

                SBQQ__Quote__c q = new SBQQ__Quote__c();
                q.Id = quote.Id;
                q.Class_of_Business__c = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).Type;
                q.SBQQ__Opportunity2__c = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).Id;
                q.Quote_Type__c = quote.Quote_Type__c;
                q.OwnerId = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).OwnerId;
                q.SBQQ__SalesRep__c = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).OwnerId;
                q.SBQQ__MasterContract__c = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).SBQQ__AmendedContract__c; // quote.SBQQ__MasterContract__c;
                q.OSCPQ_Amended_Contract__c = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).SBQQ__AmendedContract__c; //quote.OSCPQ_Amended_Contract__c;
                q.Purchase_Type__c = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).Type == 'ECUR'? 'Renewal' : 'Upsell Co-term';
                q.SBQQ__StartDate__c = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).Type == 'ECUR'? conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).SBQQ__RenewedContract__r.EndDate.addDays(1) : Date.today();  //quote.SBQQ__StartDate__c;
                q.SBQQ__ExpirationDate__c = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).Type == 'ECUR'? quote.SBQQ__StartDate__c.addDays(90) : quote.SBQQ__StartDate__c.addDays(30);//quote.SBQQ__ExpirationDate__c;
                q.SBQQ__Type__c = 'Amendment'; //quote.SBQQ__Type__c;
                q.SBQQ__EndDate__c = quote.SBQQ__EndDate__c;
                q.SBQQ__ExpirationDate__c = NULL;
                q.Order_Group__c = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).SBQQ__AmendedContract__r.SBQQ__Quote__r.Order_Group__c;
                q.License_Administrator__c = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).SBQQ__AmendedContract__r.SBQQ__Quote__r.License_Administrator__c;
                q.OSCPQ_Renewed_Contract__c = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).Type == 'ECUR' && conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).SBQQ__RenewedContract__c != NULL? conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).SBQQ__RenewedContract__c : NULL;
                //q.MLA_Effective_Date__c = System.today();
                lQuotesForUpdate.add(q);
                strQuoteName = quote.Name;
                strOppId = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).Id;
                strOppName = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).Name;
                oppOwnerId = conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).OwnerId;
                oppIdSet.add(conIdToOppIdMap.get(quote.OSCPQ_Amended_Contract__c).Id);
            }
        }

        List<SBQQ__Quote__c> quoteListForPrimaryUpdate = new List<SBQQ__Quote__c>([SELECT Id,OSCPQ_Amended_Contract__c,SBQQ__MasterContract__c,SBQQ__Opportunity2__c,Quote_Type__c
        FROM SBQQ__Quote__c
        WHERE SBQQ__Opportunity2__c IN : oppIdSet
        AND SBQQ__Primary__c = true
        AND Id NOT IN :quoteIds]);

        List<SBQQ__Quote__c> quoteListToUnPrimary = new List<SBQQ__Quote__c>();

        if(!quoteListForPrimaryUpdate.isEmpty()) {
            for (SBQQ__Quote__c quote : quoteListForPrimaryUpdate){
                SBQQ__Quote__c q = new SBQQ__Quote__c();
                q.Id = quote.Id;
                q.SBQQ__Primary__c = false;
                quoteListToUnPrimary.add(q);
            }
        }

        //To stamp the correct opp in the new co-term quote
        try {
            if (!lQuotesForUpdate.isEmpty()) {
                System.debug('inside lQuotesForUpdate = ' + lQuotesForUpdate);
                update lQuotesForUpdate;
                System.debug('after update lQuotesForUpdate');

                //Id typeId = [SELECT Id FROM CustomNotificationType WHERE CustomNotifTypeName = 'coterm quote notification'].Id;
                Messaging.CustomNotification notification = new Messaging.CustomNotification();
                notification.setBody('Please click on this notification to access the quote.');
                notification.setTitle('Your co-term quote ' + strQuoteName + ' has been created!');
                notification.setSenderId(Userinfo.getUserId());
                notification.setNotificationTypeId(System.Label.Custom_Notification_Type_ID);
                notification.setTargetId(strQuoteId); // target object id
                notification.send(new Set<String> { oppOwnerId }); // target user id.
            }
        } catch (Exception e) {
            System.debug('An exception occurred: ' + e.getMessage());


            Messaging.CustomNotification notification2 = new Messaging.CustomNotification();
            notification2.setBody('Here is the error message =================' + e.getMessage());
            notification2.setTitle('Co-term quote failed to create for opp [' + strOppName + ']. Please reach out to Deal Desk for help.');
            notification2.setSenderId(Userinfo.getUserId());
            notification2.setNotificationTypeId(System.Label.Custom_Notification_Type_ID);
            notification2.setTargetId(strOppId); // target object id
            notification2.send(new Set<String> { oppOwnerId }); // target user id.

            String[] toAddresses = new String[] {'ewong@alteryx.com'};  //Need to change to dg_sfdcteam@alteryx.com
            Messaging.Email[] messages = new Messaging.Email[0];

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setSubject('CotermExceptionError IN class AmendmentQuoteUpdateGateway, method updateAmendmentQuote');
            mail.setHtmlBody('Here is the opp: ' + strOppId + '</br></br><b>' + e.getMessage());
            messages.add(mail);

            Messaging.sendEmail(messages, false);



        }

        // To un-primary previous quotes when new co-term quote is created
        if(!quoteListToUnPrimary.isEmpty()) {
            try {
                update quoteListToUnPrimary;
            } catch (Exception e) {
                System.debug('An exception occurred quoteListToUnPrimary: ' + e.getMessage());
            }
        }

        // Stamping original opp's primary quote field
        if (!oppListToSetPrimary.isEmpty()) {
            try {
                update oppListToSetPrimary;
            } catch (Exception e) {
                System.debug('An exception occurred oppListToSetPrimary: ' + e.getMessage());
            }
        }


    }

    public static void updateOppToRemovePrimaryQuote(Set<Id> opps) {
        System.debug('eddie check recursionhandler = ' + Recursionhandler.IsContractAmendExecuted);
        System.debug('eddie inside AmendmentQuoteUpdateGateway = ' + opps);
        List<Opportunity> lOpp = new List<Opportunity>();


        for (Opportunity opp : [SELECT Id,SBQQ__PrimaryQuote__c FROM Opportunity WHERE Id IN : opps]) {
            System.debug('eddie check opp in for loop = ' + opp);
            Opportunity op = new Opportunity();
            op.Id = opp.Id;
            op.SBQQ__PrimaryQuote__c = null;
            lOpp.add(op);
        }

        System.debug('eddie checking lOpp = ' + lOpp);

        if(!lOpp.isEmpty()) {
            try {
                update lOpp;
            } catch (Exception e) {
                System.debug('An exception occurred: ' + e.getMessage());
            }
        }
    }

    public static void deleteAmendmentOpp(Set<Id> opps) {
        System.debug('eddie inside deleteAmendmentOpp gateway' + opps);
        List<Opportunity> lOpp = new List<Opportunity>();

        for (Opportunity opp : [SELECT Id FROM Opportunity WHERE Id IN : opps AND SBQQ__PrimaryQuote__c = '']) {
            Opportunity op = new Opportunity();
            op.Id = opp.Id;
            lOpp.add(op);
        }

        if(!lOpp.isEmpty()) {
            try {
                delete lOpp;
            } catch (Exception e) {
                System.debug('An exception occurred: ' + e.getMessage());
            }
        }

    }

}