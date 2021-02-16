public without sharing class CaseGateway
{ 
   //Added by Paramvir on Feb4,2016
   public static Map<String,Messaging.SingleEmailMessage> caseId2SingleEmailMessagesList;
   
    public static List<EmailMessage> generateEmailMsgforCase(Map<String,Set<String>> bothSessionsScheduledMap,Map<String,Set<String>> session1ScheduledMap,Map<String,Set<String>> noSessionScheduledMap)
    {
     List<EmailMessage> emailMessagesToBeInserted = new List<EmailMessage>();
     
     //Added by Paramvir on Feb 4,2016
     Map<String,Messaging.SingleEmailMessage> bothSessionsScheduledMails = new Map<String,Messaging.SingleEmailMessage>();
     Map<String,Messaging.SingleEmailMessage>session1ScheduledMails      = new Map<String,Messaging.SingleEmailMessage>();
     Map<String,Messaging.SingleEmailMessage> noSessionScheduledMails    = new Map<String,Messaging.SingleEmailMessage>();  
     
     List<EmailMessage> emailMessagesToBeInsertedBothSessionsScheduled = new List<EmailMessage>();
     List<EmailMessage> emailMessagesToBeInsertedSession1Scheduled     = new List<EmailMessage>();
     List<EmailMessage> emailMessagesToBeInsertedNoSessionScheduled    = new List<EmailMessage>();
       
        system.debug('bothSessionsScheduledMap in case gateway'+bothSessionsScheduledMap); 
        
        if(!bothSessionsScheduledMap.isEmpty()){
            //Messaging.reserveSingleEmailCapacity(bothSessionsScheduledMap.size());
            Set<String> caseIds = new Set<String>();
            
            for(Set<String> caseIdSet : bothSessionsScheduledMap.Values()){
                caseIds.addAll(caseIdSet);  
            }    
            system.debug('caseIdSet in case gateway'+caseIds); 
            
            if(caseIds.size() > 0){
                bothSessionsScheduledMails = createSingleEmailMesagesList(caseIds,Label.bothSessionsScheduledTemplateId);
            }

            system.debug('bothSessionsScheduledMails in gateway'+bothSessionsScheduledMails);
            
            if(bothSessionsScheduledMails.size() > 0){
                emailMessagesToBeInsertedBothSessionsScheduled = sendEmailsAndcreateEmailMesageRecordsList(bothSessionsScheduledMails);
                emailMessagesToBeInserted.addAll(emailMessagesToBeInsertedBothSessionsScheduled);
            }
 
        }
        
        if(!session1ScheduledMap.isEmpty()){
            Set<String> caseIds = new Set<String>();
            
            for(Set<String> caseIdSet : session1ScheduledMap.Values()){
                caseIds.addAll(caseIdSet);  
            }    
            system.debug('caseIdSet in case gateway'+caseIds); 
            
            if(caseIds.size() > 0){
                session1ScheduledMails = createSingleEmailMesagesList(caseIds,Label.session1ScheduledTemplateId);
            }

            system.debug('bothSessionsScheduledMails in gateway'+bothSessionsScheduledMails);
            
            if(session1ScheduledMails.size() > 0){
                emailMessagesToBeInsertedSession1Scheduled = sendEmailsAndcreateEmailMesageRecordsList(session1ScheduledMails);
                emailMessagesToBeInserted.addAll(emailMessagesToBeInsertedSession1Scheduled);
            } 
        }
        
        if(!noSessionScheduledMap.isEmpty()){
            Set<String> caseIds = new Set<String>();
            
            for(Set<String> caseIdSet : noSessionScheduledMap.Values()){
                caseIds.addAll(caseIdSet);  
            }    
            system.debug('caseIdSet in case gateway'+caseIds); 
            
            if(caseIds.size() > 0){
                noSessionScheduledMails = createSingleEmailMesagesList(caseIds,Label.noSessionScheduledTemplateId);
            }

            system.debug('bothSessionsScheduledMails in gateway'+bothSessionsScheduledMails);
            
            if(noSessionScheduledMails.size() > 0){
                emailMessagesToBeInsertedNoSessionScheduled = sendEmailsAndcreateEmailMesageRecordsList(noSessionScheduledMails);
                emailMessagesToBeInserted.addAll(emailMessagesToBeInsertedNoSessionScheduled);
            } 
        }

        return emailMessagesToBeInserted;
    }
    
    
    public static Map<String,Messaging.SingleEmailMessage> createSingleEmailMesagesList(Set<String> caseIds,String templateId){
        system.debug('caseIds in Gateway<==>'+caseIds);
        system.debug('templateId in Gateway<==>'+templateId);
        
        List<Messaging.SingleEmailMessage> singleEmailMessagesList = new List<Messaging.SingleEmailMessage>();
        List<String> toAddresses = new List<String>();
        toAddresses.add(Label.QuickStartEmailToAddress);
        
        //Added by Paramvir on Feb4,2016
        caseId2SingleEmailMessagesList = new Map<String,Messaging.SingleEmailMessage>();
        
        for(Id caseId : caseIds){
            Case c = (Case)Trigger.newMap.get(caseId);
            if(c.ContactId != NULL){
                    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();    
                //toAddresses.add(Label.QuickStartEmailToAddress);
                //String[] toAddresses = new String[]{'invalid@emailaddr.es'};
                mail.setToAddresses(toAddresses);
                mail.setUseSignature(false);
                mail.setSaveAsActivity(false);
                mail.setSenderDisplayName('Alteryx Designer Quick Start');
                //if(c.ContactId != NULL){
                mail.setTargetObjectId(c.ContactId);
                mail.setWhatId(c.id);
                //}
                /*else if(c.Quote_Proposal_Primary_Contact__c != NULL){
                        mail.setTargetObjectId(c.Quote_Proposal_Primary_Contact__c);
                }*/
                mail.setTemplateId(templateId);
                singleEmailMessagesList.add(mail); 
                
                if(!caseId2SingleEmailMessagesList.containsKey(c.id)){
                    caseId2SingleEmailMessagesList.put(c.id,mail);
                }  
     
            }
        }

        return caseId2SingleEmailMessagesList;
    }
    
    public static List<EmailMessage> sendEmailsAndcreateEmailMesageRecordsList(Map<String,Messaging.SingleEmailMessage> emailMessagesList){
        List<EmailMessage> emailMsgstoBeInserted = new List<EmailMessage>();
        Set<String> processedContactIds = new Set<String>();
        
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(emailMessagesList.values());
        Database.rollback(sp);
        system.debug('emailMessagesList==>'+emailMessagesList);
        integer i =0;
        for(Messaging.SingleEmailMessage mail : emailMessagesList.values()){
           
           if(mail.getTargetObjectId() != NULL && mail.whatid != NULL){
              String caseId = mail.whatid;
              String mailTextBody = mail.getPlainTextBody();
              String mailHtmlBody = mail.getHTMLBody();
              String mailSubject = mail.getSubject();
              //emailMsgstoBeInserted.add(new EmailMessage(MessageDate=system.now(),ParentId=caseId,subject=mailSubject,FromAddress=Label.QuickStartEmailFromAddress,HtmlBody=mailHtmlBody,TextBody=mailTextBody,ToAddress=Label.QuickStartEmailToAddress ));    
              EmailMessage em = new EmailMessage(MessageDate=system.now(),ParentId=caseId,subject=mailSubject,FromAddress=Label.QuickStartEmailFromAddress,HtmlBody=mailHtmlBody,TextBody=mailTextBody);    
              String toAddresses = '';
              if(Trigger.NewMap.get(caseId) != NULL){
                  Case cse = (Case)Trigger.NewMap.get(caseId);
                  if(cse.Account_Owner_Email__c != NULL ){
                      toAddresses = cse.Account_Owner_Email__c;
                  }
                  if(cse.Quote_Proposal_Primary_Contact_Email__c != NULL ){
                      toAddresses = toAddresses + ',' +cse.Quote_Proposal_Primary_Contact_Email__c;
                  }
                  if(cse.Opportunity_Owner_Email__c != NULL){
                      toAddresses = toAddresses + ',' + cse.Opportunity_Owner_Email__c;
                  }
                  if(cse.Contact_Email_Custom__c != NULL){
                      toAddresses = toAddresses + ',' + cse.Contact_Email_Custom__c;
                  }
              }
              
              em.ToAddress = toAddresses;
              em.CcAddress = Label.QuickStartEmailToAddress;
              emailMsgstoBeInserted.add(em);
              i++;
           }
        }    
        system.debug('i is <==>'+i);
        system.debug('emailMsgstoBeInserted size is <==>'+emailMsgstoBeInserted);  
        
        return emailMsgstoBeInserted;
    }
    
    
    public static Map<String,string> findActiveUsersWithContacts (Set<String> userIds){
        Map<String,string> userToContactIdMap = new Map<String,string>(); 
        Map<String,string> lastNameToUserIdMap = new Map<String,string>();
        Map<String,string> emailToUserIdMap = new Map<String,string>();

        for(User u : [select id,email,lastname from user where id in : userIds AND isActive = TRUE]){
            lastNameToUserIdMap.put(u.lastName, u.id);
            emailToUserIdMap.put(u.email, u.id);
        }
        for(contact con : [select id,email,lastName from contact where email in : emailToUserIdMap.keySet() AND lastName in : lastNameToUserIdMap.keySet() order by createddate]){

            if(lastNameToUserIdMap.containsKey(con.lastName) && emailToUserIdMap.containsKey(con.email) ){
                if(lastNameToUserIdMap.get(con.lastName) == emailToUserIdMap.get(con.email))
                    userToContactIdMap.put(lastNameToUserIdMap.get(con.lastName), con.Id);
            }
        }

        return userToContactIdMap;       
    }
    
    public static void insertWebToCaseHelpers(List<WebToCaseHelper__c> helpers) {
        insert helpers;
    }
    /* commented by Pulkit
    public static void updateTaskOrProjectField(Set<Id> cas_top) {
        // Cases associated with either project or task
        Set<Id> case_pt = new Set<Id>();
        
        Map<Id, List<TASKRAY__Project__c>> cas_to_projects
            = new Map<Id, List<TASKRAY__Project__c>>();
        
        for(TASKRAY__Project__c project : [SELECT Id, Case__c
                FROM TASKRAY__Project__c
                WHERE Case__c IN :cas_top]) {
                    
            List<TASKRAY__Project__c> projects 
                = cas_to_projects.containsKey(project.Case__c) 
                ? cas_to_projects.get(project.Case__c)
                : new List<TASKRAY__Project__c>();
            projects.add(project);
            case_pt.add(project.Case__c);
            cas_to_projects.put(project.Case__c, projects);
        }
        
        /
          Iterate over the map named cas_to_projects, fill "Task or Project"
          field with correct value.
         /
         for(Id case_id : cas_to_projects.keySet()) {
             Case cas = (Case) Trigger.newMap.get(case_id);
             if(cas.Task_or_Project__c != 'Project') {
                 cas.Task_or_Project__c = 'Project';
             }
         }
         
         Map<Id, List<TASKRAY__Project_Task__c>> cas_to_tasks
            = new Map<Id, List<TASKRAY__Project_Task__c>>();
         
         for(TASKRAY__Project_Task__c task : [SELECT Id, Case__c
                FROM TASKRAY__Project_Task__c
                WHERE Case__c IN :cas_top]) {
                    
             List<TASKRAY__Project_Task__c> tasks
                = cas_to_tasks.containsKey(task.Case__c)
                ? cas_to_tasks.get(task.Case__c)
                : new List<TASKRAY__Project_Task__c>();
             tasks.add(task);
             case_pt.add(task.Case__c);
             cas_to_tasks.put(task.Case__c, tasks);
         }
         
         for(Id case_id : cas_to_tasks.keySet()) {
             Case cas = (Case) Trigger.newMap.get(case_id);
             if(cas.Task_or_Project__c != 'Task') {
                 cas.Task_or_Project__c = 'Task';
             }
         }
         
         /
           Cases that aren't in the map named cas_to_projects don't have
           projects or tasks associated with them. So, empty field on Case
          /
         for(Id case_id : cas_top) {
             if(!case_pt.contains(case_id)) {
                 Case cas = (Case) Trigger.newMap.get(case_id);
                 cas.Task_or_Project__c = null;
             }
         }
    }*/

    /**
     * Updating a Proposal with the License Type Selected by Fulfillment.  This is specific to our Licensing Process
     * @param oldMapCases pulling a map of old records
     * @param newCases pulling list of new records
     */
    
    // JPH - 20190402 - commented for CPQ development
    //Sergio Flores
    //Date: 05/22/2019
    //CPQ Refactor : W-011692
    public static void updateProposalLicenseType(List<Case> oldCases, List<Case> newCases){
        List<SBQQ__Quote__c> quoteUpdate = new List<SBQQ__Quote__c>();
        Map<Id,Case> oldMapCases = new Map<Id,Case>(oldCases);
        for(Case newCase : newCases){
            Case oldCase = oldMapCases.get(newCase.Id);
            if(String.ISBLANK(oldCase.License_Type__c) && !String.ISBLANK(newCase.License_Type__c)){
                SBQQ__Quote__c quote = new SBQQ__Quote__c();
                quote.Id = newCase.Quote__c;
                quote.License_Type__c = newCase.License_Type__c;
                quoteUpdate.add(quote);
            }
        }
        if(quoteUpdate.size() > 0){
            update quoteUpdate;
        }
    }
    
    /* W-007049 : JPH : 20180201 : Send a PagerDuty Notification in the event the Priority is High
    @future(callout=true) 
    public static void pagerDutyPostCallout(String tempdesc){ 
        
        Pager_Duty_Integration_Settings__c pdConfig = Pager_Duty_Integration_Settings__c.getValues('PagerDuty_Config');
        
        Http http = new Http(); 
        HttpRequest request = new HttpRequest(); 
        request.setEndpoint(pdConfig.PD_Endpoint__c); 
        request.setMethod('POST'); 
        request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
        // Set the body as a JSON object 
        request.setBody('{"service_key": "' + pdConfig.PD_RequestServiceKey__c + '", "event_type": "trigger","description":"' + tempdesc + '" ,"client": "' + pdConfig.PD_Client__c + '","client_url": "https://monitoring.service.com","details": {"ping time": "1500ms","load avg": 0.75}}'); 
        request.setTimeout(120000);
        
        HttpResponse response = new HttpResponse();
        if( !test.isRunningTest() ){
            response = http.send(request);  
        } else {
            response.setStatusCode(201);
        }
        
        // Parse the JSON response 
        if (response.getStatusCode() != 201) { 
            System.debug('The status code returned was not expected: ' + 
            response.getStatusCode() + ' ' + response.getStatus()); 
        } else { 
            System.debug(response.getBody()); 
        }
    } */

    // W-010324 - PagerDuty code update - Hemendra Singh Rajawat on Sept 28, 2018
    @future(callout = true) 
    public static void pagerDutyPostCallout(List<String> callOutBodyList){ 
        List<String> dataList;
        String body;
        String endPoint;
        
        for (String data : callOutBodyList) {
            dataList = data.split(',,,');
            body = dataList[0];
            endPoint = dataList[1];

            Http http = new Http(); 
            HttpRequest request = new HttpRequest(); 
            request.setEndpoint(endPoint); 
            request.setMethod('POST'); 
            request.setHeader('Content-Type', 'application/json;charset=UTF-8'); 
            request.setBody(body); 
            request.setTimeout(120000);             
            HttpResponse response = new HttpResponse();
            if( !test.isRunningTest() ){
              response = http.send(request);  
            } else {
              response.setStatusCode(201);
            }
            
            // Parse the JSON response 
            if (response.getStatusCode() != 201) { 
              System.debug('The status code returned was not expected: ' + 
              response.getStatusCode() + ' ' + response.getStatus()); 
            } else { 
              System.debug(response.getBody()); 
            }
        }
    }

    //Sergio Flores
    //Date 11/13/2019
    //W-013577
    public static void csClosedCaseNotificationsWithorWithoutSurveyLink(Map<Id, Case> caseIdToCaseMap, Set<Id> contactIds){
        RecursionHandler.IsCustomerSurveyAlertSent = true;

        system.debug('inside cs case closed notification ' + caseIdToCaseMap + ' ' + contactIds);

        String stardard_case_recype_Id = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Standard Case').getRecordTypeId();
        String portal_case_recype_Id = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('Case Portal').getRecordTypeId();

        Set<String> caseRecordTypes = new Set<String>();
        caseRecordTypes.add(stardard_case_recype_Id);
        caseRecordTypes.add(portal_case_recype_Id);

        //Here we have all the cases closed in the last 7 days not counting the cases recently closed and the cases only related to the contacts 
        //of the cases recently closed
        Map<Id, Case> existingCasesAlreadyClosedMap = new Map<Id, Case>(
            [Select Closed_Date__c, ContactId, Products__c, Date_of_Escalation__c
            From Case
            Where IsClosed = true
            AND ContactId IN : contactIds
            AND Id NOT IN : caseIdToCaseMap.keySet() 
            AND RecordTypeId IN : caseRecordTypes]);

        List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject from EmailTemplate 
        where DeveloperName = 'SUPPORT_2018_Case_Response_for_Closed_Cases_w_o_Survey_link_2'
        OR DeveloperName = 'SUPPORT_2018_Case_Response_for_Closed_Cases_w_survey_link_2'
        Order By DeveloperName];

        system.debug('list of email templates ' + lstEmailTemplates);

        List<Messaging.SingleEmailMessage> allEmails = new List<Messaging.SingleEmailMessage>();

        Map<Id, Set<String>> contactIdToProductsLessThan7Map = new Map<Id, Set<String>>();

        system.debug('existingCasesAlreadyClosedMap '+  existingCasesAlreadyClosedMap);

        for(Case existingCase : existingCasesAlreadyClosedMap.values())
        {
                       
            system.debug('inside no contact found in either map ' + existingCase);
            Set<String> productsRelatedToContact = new Set<String>();
            if(existingCase.Closed_Date__c > (Date.Today() - 7))
            {
                system.debug('inside adding less than 7 map ');
                //check to see if already in the map
                if(!contactIdToProductsLessThan7Map.containsKey(existingCase.ContactId))
                {
                    productsRelatedToContact.add(existingCase.Products__c);
                    contactIdToProductsLessThan7Map.put(existingCase.ContactId, productsRelatedToContact);
                }
                else
                {
                    system.debug('inside alreadyInLessThan7Map ');
                    productsRelatedToContact = contactIdToProductsLessThan7Map.get(existingCase.ContactId);
                    productsRelatedToContact.add(existingCase.Products__c);
                }
               
            }
            

        }

        system.debug('lessThan7Map ' + contactIdToProductsLessThan7Map);

        //SF 12/11/2019 W-013724
        Id customerSupportEmailId = [select Id from OrgWideEmailAddress where Address = 'support@alteryx.com' limit 1].Id;

        for(Case recentlyClosedCase : caseIdToCaseMap.values())
        {
            Set<String> existingProductsLessThan7 = contactIdToProductsLessThan7Map.get(recentlyClosedCase.ContactId);

            system.debug('inside last loop ' + recentlyClosedCase + ' ' + existingProductsLessThan7);
            if( (existingProductsLessThan7 == null && recentlyClosedCase.Products__c != 'Non - Product') || (existingProductsLessThan7 != null && !existingProductsLessThan7.contains(recentlyClosedCase.Products__c ) && recentlyClosedCase.Products__c != 'Non - Product') )
            {
                system.debug('lessThan7Map Email Loop ' + existingProductsLessThan7);
                //Use less than 7 email template and add to email list
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(lstEmailTemplates[1].Id, recentlyClosedCase.ContactId, recentlyClosedCase.Id);
                email.setSaveAsActivity(false);
                email.setOrgWideEmailAddressId(customerSupportEmailId);
                allEmails.add(email);
                recentlyClosedCase.Sent_Survey_Email__c = true;
                recentlyClosedCase.Survey_Sent_DateTime__c = System.now();
            }
            else
            {
                system.debug('did not meet the above scenarios so just send email without survey ' + existingProductsLessThan7);
                //Use more than 7 email template and add to email list
                Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(lstEmailTemplates[0].Id, recentlyClosedCase.ContactId, recentlyClosedCase.Id);
                email.setOrgWideEmailAddressId(customerSupportEmailId);
                email.setSaveAsActivity(false);
                allEmails.add(email);
            }


        }

        if(!allEmails.isEmpty())
        {
            system.debug('inside sending cs email surveys ' + allEmails);
            Messaging.sendEmail(allEmails,false);
        }

    }
}