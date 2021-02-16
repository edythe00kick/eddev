/*
* @author: Pulkit
* Last Updated on : Sept 20, 2017
* Last Update:
* Modified the code:
*    - When the case is getting closed, the milestone tracker was automatically removed.
*    - So, we updated the code to automatically compelete the Milestone when the case is 
*         getting closed the tracker does not get removed.
* @author: Pulkit
* Last Updated On: Feb 08 , 2017
* Last Update: 
*    Sunset the following:
*  - On creation, if value of "Task or Project" field is filled, empty it.
*  - On updation, if value of "Task or Project" field is filled, verify it and
*      correct it if it is wrong.
*
* Test Class: test_CaseTrigger
*/
public with sharing class CaseHandler
implements ITrigger
{   
    public static Boolean sendExpirationMailsOnlyOnce = false;
    
    public Map<String,Set<String>> bothSessionsScheduledMap = new Map<String,Set<String>>();
    public Map<String,Set<String>> session1ScheduledMap = new Map<String,Set<String>>();
    public Map<String,Set<String>> noSessionScheduledMap = new Map<String,Set<String>>();
    
    public String bothSessionsScheduledTemplateId;
    public String session1ScheduledTemplateId;
    public String noSessionScheduledTemplateId;
    
    public List<EmailMessage> emailMessagesToBeInserted = new List<EmailMessage>();
    
    public Set<String> caseCreatedByIds = new  Set<String>();
    public List<WebToCaseHelper__c> helpers = new List<WebToCaseHelper__c>();
    
    // Cases where "Task or Project" field is filled
    public Set<Id> case_top = new Set<Id>();
    /*
public List<WebToCaseHelper__c> updatehelpers = new List<WebToCaseHelper__c>();
public map<String , WebToCaseHelper__c > threadId_ToWtch_Map = new Map<String , WebToCaseHelper__c>();
public set<String> updatecaseIds = new set<String>();    
*/
    /*
If the Entitlement Name is not set then, check to see if the Contact on the Case has an active Entitlement
and select the first one.  If not then check to see if the Account on the Case has an active Entitlement.
*/
    public Set<Id> contactIds = new Set<Id>();
    public Set<Id> acctIds = new Set<Id>();
    public List <EntitlementContact> entlContacts = New List <EntitlementContact>();
    public List <Entitlement> entls =  New List <Entitlement>();
    public List<Id> Closed_cases = New List<Id>();
    List<Pager_Duty_Integration_Settings__c> pagerSettings 
        = Pager_Duty_Integration_Settings__c.getAll().Values();

    List<String> callOutBodyList = new List<String>();

    /*SF Commented for 2020-01-23 Release
    // Added by: Sharma Nemani | W-002551 | 01/21/2020 --> START  
    List<Sobject> lstCase = new List<Sobject>();
    Map<Id,String> mapRTs = new Map<Id,String>();
    // Added by: Sharma Nemani | W-002551 | 01/21/2020 --> END*/
    
    // Constructor
    public CaseHandler() {
        bothSessionsScheduledTemplateId = Label.bothSessionsScheduledTemplateId;
        session1ScheduledTemplateId = Label.session1ScheduledTemplateId;
        noSessionScheduledTemplateId = Label.noSessionScheduledTemplateId;
    }
    
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore()
    { 
        /*SF Commented for 2020-01-23 Release
       // Added by: Sharma Nemani | W-002551 | 01/21/2020 --> START
        for(RecordType rt : [select id,developername from RecordType]){
            mapRTs.put(rt.Id, rt.developername);
        }
        // Added by: Sharma Nemani | W-002551 | 01/21/2020 --> END*/
         
        if(trigger.isInsert){
            
            /*Added by Paramvir 22Feb,2016. Auto fill the Contact field on cases where record type is "SFDC Support Ticket". The contact
field will auto fill with the contact record that matched "Created By" user.
*/
            for(SObject sObj : Trigger.New){
                Case newCase = (Case)sObj;
                system.debug('##### --> ' + newCase);
                if( newCase.recordtypeid == Label.SFDC_Internal_Support_Ticket_RecordTypeId ){
                    caseCreatedByIds.add(UserInfo.getUserId());
                }
                if(newCase.RecordTypeId ==  Schema.SObjectType.Case.getRecordTypeInfosByName().get('Alteryx Standard Case').getRecordTypeId()){
                    if(newCase.EntitlementId == null && newcase.ContactId!= null){
                        contactIds.add(newCase.ContactId);
                        if(newCase.AccountId!= null){
                            acctIds.add(newCase.AccountId);
                        }
                    }
                }
                /*SF Commented for 2020-01-23 Release
                // Added by: Sharma Nemani | W-002551 | 01/21/2020 --> START
                if(newCase.recordTypeId!=null && mapRTs.size()>0 && mapRTs.containsKey(newCase.recordTypeId) && mapRTs.get(newCase.recordTypeId) == 'Solutions_Architecture_Request'){
                    lstCase.add(sObj);
                }
                // Added by: Sharma Nemani | W-002551 | 01/21/2020 --> END
            }
            
            // Added by: Sharma Nemani | W-002551 | 01/21/2020 --> START
            if(lstCase.size() > 0){
                List<Contact> lstCon = [select id ,Phone ,Email from contact where LastName=:userInfo.getLastName() AND FirstName=:userInfo.getFirstName()];
                if(lstCon.size() > 0){
                    for(Sobject cse : lstCase){
                       cse.put('ContactId',lstCon[0].Id);
                    }
                }
            }
            // Added by: Sharma Nemani | W-002551 | 01/21/2020 --> END*/
            }
            
            If(acctIds.isEmpty() && !contactIds.isEmpty()){
                for(Contact con : [Select Id,AccountID
                                   FROM Contact
                                   WHERE AccountId!=Null AND
                                   Id in:contactIds]){
                                       
                                       acctIds.add(con.AccountId);                    
                                   }
            }
            
            
            if(!contactIds.isEmpty()){
                entlContacts = [Select EntitlementId,ContactId,Entitlement.AssetId 
                                FROM EntitlementContact
                                Where ContactId in:contactIds AND Entitlement.EndDate >= Today 
                                AND Entitlement.StartDate <= Today];
            }if(entlContacts.isEmpty() && !acctIds.isEmpty()){ 
                entls = [Select Id,StartDate,EndDate,AccountId,AssetId
                         FROM Entitlement
                         Where AccountId in:acctIds And EndDate >= Today And StartDate <= Today];
            }
            if(caseCreatedByIds.size() > 0){
                Map<String,string> userMap = CaseGateway.findActiveUsersWithContacts(caseCreatedByIds);
                if(!userMap.isEmpty()){
                    for(SObject sObj : Trigger.New){
                        case c  = (Case)sObj;
                        if(c.recordtypeid == Label.SFDC_Internal_Support_Ticket_RecordTypeId && userMap.containsKey(UserInfo.getUserId()) &&  userMap.get(UserInfo.getUserId()) != NULL && c.contactid != userMap.get(UserInfo.getUserId()) ){
                            c.contactid = userMap.get(UserInfo.getUserId());
                        } 
                    }
                }
            }
            
        }
        if(trigger.isUpdate) {
            //8-10-2018 Requirement: We have a new "Closed" status for duplicate cases, "Closed - Duplicate". 
            //We'd like to see if it is possible to carry over the information (i.e Case Category, Case Reason, etc) of the Original case (if this info has been filled out),
            //to prevent the team from having to fill out manually.
            //
            //A case gets duplicated when:
            //•  A customer or anyone cc’d replies to the original case email that initiated the case creation , then duplicate is created
            //
            //Required Fields to auto populate duplicate case:
            //•  Products
            //•  Software Version
            //•  Case Category
            //•  Case Reason (API = Case_Detail__c)
            //•  New Required Field: Account Name
            //Check to see if the Parent Case value is not blank and Status = Closed - Duplicate, then execute the autopopulation logic

            //Name: Chris Salgado Date: 9/13/2019 Purpose: W-013055
            system.debug('Inside bulkify is Update');
            Set<Id> parentCaseIds = new Set<Id>();
            Map<Id, Id> childIdCaseToParentCaseIdMap = new Map<Id, Id>();
            List<Case> childCasesList = new List<Case>();
            String stardard_case_recype_Id = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Standard Case').getRecordTypeId();
            String portal_case_recype_Id = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('Case Portal').getRecordTypeId();
            Map<Id, Case> caseIdToCaseMap = new Map<Id, Case>();
            Set<Id> contactIds = new Set<Id>();

            for (SObject sObj : Trigger.New) {
                Case newCase = (Case) sObj;
                Case oldCase = (Case)Trigger.oldMap.get(sObj.Id);
                system.debug('newCase sobject' + newCase);
                if (newCase.ParentId != null) {
                    parentCaseIds.add(newCase.ParentId);
                    childIdCaseToParentCaseIdMap.put(newCase.Id, newCase.ParentId);
                    childCasesList.add(newCase);
                    system.debug('ChildCase Parent Id =' + newCase.ParentId);
                }

                //Sergio Flores
                //Date 11/13/2019
                //W-013577
                system.debug('case survey logic ' + newCase.Status + oldCase.Status + newCase.RecordTypeId + RecursionHandler.IsCustomerSurveyAlertSent);
                if(newCase.Status == 'Closed' && oldCase.Status != 'Closed' && newCase.Status != 'Closed - Duplicate' && (newCase.RecordTypeId == stardard_case_recype_Id || newCase.RecordTypeId == portal_case_recype_Id) && RecursionHandler.IsCustomerSurveyAlertSent == false )
                {
                    
                    system.debug('inside closed cs case');
                    caseIdToCaseMap.put(newCase.Id, newCase);
                    contactIds.add(newCase.ContactId);
                }


            }

            if(!caseIdToCaseMap.isEmpty())
            {
                CaseGateway.csClosedCaseNotificationsWithorWithoutSurveyLink(caseIdToCaseMap, contactIds);
            }

            if (!parentCaseIds.isEmpty()) {
                Map<Id, Case> childCaseToParentCaseMap = new Map<Id, Case>([
                        Select Id, AccountId, Products__c, Software_Version__c, Case_Category__c, Case_Detail__c
                        From Case
                        Where Id IN :parentCaseIds
                ]);

                //Need to check if ParentCaseList is empty, if empty, don't execute below code
                if (!childCaseToParentCaseMap.isEmpty())
                {
                    for (Case childCase : childCasesList)
                    {
                        Case parentCase = childCaseToParentCaseMap.get(childIdCaseToParentCaseIdMap.get(childCase.Id));
                        if (parentCase != null)
                        {
                            system.debug('parentCase map ' + parentCase);
                            childCase.AccountId = parentCase.AccountId;
                            childCase.Products__c = parentCase.Products__c;
                            childCase.Software_Version__c = parentCase.Software_Version__c;
                            childCase.Case_Category__c = parentCase.Case_Category__c;
                            childCase.Case_Detail__c = parentCase.Case_Detail__c;
                        }
                    }
                }
            }

            
        }
        
    }
    
    public void bulkAfter(){
        if(trigger.isUpdate){
            String stardard_case_recype_Id = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('Alteryx Standard Case').getRecordTypeId();
           

            for(SObject sObj : Trigger.New){
                Case newCase = (Case)sObj;
                
                //updatecaseIds.add(newCase.Thread_Id__c);
                
                
                if(newCase.RecordTypeId == Label.QuickstartCaseId && newCase.Track_Quick_Start_Email__c != NULL && ((Case)Trigger.oldMap.get(newCase.Id)).Track_Quick_Start_Email__c  != newCase.Track_Quick_Start_Email__c &&
                   newCase.Status != 'Closed' && newCase.Status != 'Onsite Quick Start' && newCase.Status != 'Closed- Expired' && newCase.status != 'Transfer to PS' ){
                       
                       system.debug('successfully entered first check');
                       if(newCase.Session_1_Scheduled__c != NULL && newCase.Session_2_Scheduled__c != NULL){
                           system.debug('successfully entered second check');
                           if(!bothSessionsScheduledMap.containsKey(bothSessionsScheduledTemplateId)){
                               bothSessionsScheduledMap.put(bothSessionsScheduledTemplateId,new Set<String>{newCase.Id});
                           }
                           else{
                               bothSessionsScheduledMap.get(bothSessionsScheduledTemplateId).add(newCase.Id);
                           }
                           
                       }
                       else if(newCase.Session_1_Scheduled__c != NULL && newCase.Session_2_Scheduled__c == NULL){
                           if(!session1ScheduledMap.containsKey(session1ScheduledTemplateId)){
                               session1ScheduledMap.put(session1ScheduledTemplateId,new Set<String>{newCase.Id});
                           }
                           else{
                               session1ScheduledMap.get(session1ScheduledTemplateId).add(newCase.Id);
                           }
                       }
                       else if(newCase.Session_1_Scheduled__c == NULL && newCase.Session_2_Scheduled__c == NULL){
                           if(!noSessionScheduledMap.containsKey(noSessionScheduledTemplateId)){
                               noSessionScheduledMap.put(noSessionScheduledTemplateId,new Set<String>{newCase.Id});
                           }
                           else{
                               noSessionScheduledMap.get(noSessionScheduledTemplateId).add(newCase.Id);
                           }
                       }
                   }
                
                If(newCase.IsClosed == True && newCase.SlaStartDate<= System.now() && newCase.SlaExitDate == null && newCase.RecordTypeId == stardard_case_recype_Id){
                    Closed_cases.add(newCase.Id);
                }

                
            }

            
        }

        // JPH - 20190402 - CPQ 
        //Sergio Flores
        //Date: 05/22/2019
        //CPQ Refactor : W-011692
        if(Trigger.isUpdate){
            CaseGateway.updateProposalLicenseType(Trigger.old, Trigger.new);
        }
    }
    
    
    
    //  Sharma Nemani | Date: 06/18/2019 | W-010069 --> END

    
    public void beforeInsert(SObject so)
    {       
    	
        Case cas = (Case) so;
        
        if(cas.web_name__c != null && cas.web_name__c!=cas.suppliedName){
            cas.suppliedName = cas.web_name__c;
        }
        if(cas.Web_Company__c!= null && cas.web_name__c!=cas.suppliedCompany){
            cas.suppliedCompany= cas.Web_Company__c;
        }
        if(cas.Web_Email__c != null && cas.web_name__c!=cas.suppliedEmail){
            cas.suppliedEmail = cas.Web_Email__c;
        }
        if(cas.Web_Phone__c != null && cas.web_name__c!=cas.suppliedPhone){
            cas.suppliedPhone= cas.Web_Phone__c;
        }
        
        /*Default EntitleMent*/
        if(!entlContacts.isEmpty()){
            if(cas.EntitlementId == null && cas.ContactId!= null){
                for(EntitlementContact ec: entlContacts){
                    if(ec.ContactId==cas.ContactId){
                        cas.EntitlementId = ec.EntitlementId;
                        if(cas.AssetId==null && ec.Entitlement.AssetId!=null){
                            cas.AssetId=ec.Entitlement.AssetId;
                        }
                    }
                }
            }
        }else if(!entls.isEmpty()){
            if(cas.EntitlementId == null && cas.AccountId!= null){
                for(Entitlement e: entls){
                    if(e.AccountId == cas.AccountId){
                        cas.EntitlementId = e.Id;
                        if(cas.AssetId==null && e.AssetId!=null)
                            cas.AssetId=e.AssetId;
                    }
                }
            }
            else if(cas.EntitlementId == null && cas.Suppliedname!= null &&
                    cas.Suppliedname!='' && cas.SuppliedEmail!=null &&
                    cas.SuppliedEmail!=''){
                        
                for(Entitlement e: entls){
                    Id AccId = e.AccountId;
                    if(acctIds.Contains(AccId)){
                        cas.EntitlementId = e.Id;
                        if(cas.AssetId==null && e.AssetId!=null)
                            cas.AssetId=e.AssetId;
                    }
                }
            }
        } 
        
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){}
    
    /**
* beforeDelete
*
* This method is called iteratively for each record to be deleted during a BEFORE
* trigger.
*/
    public void beforeDelete(SObject so)
    {   
    }
    
    public void afterInsert(SObject so)
    {
        //setContactNameAndEmail(so);
        Case cas = (Case) so;
        if(cas.WebToCasePage__c == true) {
            System.debug('ch> inside afterInsert method');
            System.debug('ch> case id:' + cas.Id);
            // web_to_case_ids.add(cas.Id);
            WebToCaseHelper__c wtc = new WebToCaseHelper__c();
            wtc.Name                         = cas.CaseNumber;
            wtc.OwnerId                      = Label.WebToCaseHelperOwnerId;
            wtc.Subject__c                   = cas.Subject;
            wtc.Description__c               = cas.Description;
            wtc.Business_System__c           = cas.Business_System__c;
            wtc.Business_System_Category__c  = cas.Business_System_Category__c;
            wtc.Requested_Completion_Date__c = cas.Requested_Completion_Date__c;
            wtc.Thread_Id__c                 = cas.Thread_Id__c;
            wtc.Status__c                    = cas.Status;
            wtc.Contact__c                   = cas.ContactId;
            helpers.add(wtc);
        }
        
        //Commented by Grazitti Team
        /*if(checkRecursive.runOnce() || test.isRunningTest()){ 
        // W-007049 : JPH : 20180201 : Send a PagerDuty Notification in the event the Priority is High 
        String caseSubjectToSend = '';
        String checkPriority = cas.Priority;
        String checkProd = cas.Products__c;
        String checkCat = cas.Case_Category__c;
        String checkOrigin = cas.Origin;
        
        if(cas.Priority == null){checkPriority = 'NULL';} else{}
        if(cas.Products__c == null){checkProd = 'NULL';} else{}
        if(cas.Case_Category__c == null){checkCat = 'NULL';} else{}
        if(cas.Origin == null){checkOrigin = 'NULL';} else{}
        
        String pdIntName = Label.PagerDuty_Config_Name;
        try {
            Pager_Duty_Integration_Settings__c pdConfig = Pager_Duty_Integration_Settings__c.getInstance(pdIntName);
            system.debug('*** pdConfig.Id :' + pdConfig.Id);
            
            if(pdConfig.PD_Products__c == null){pdConfig.PD_Products__c = '';} else{}
            if(pdConfig.PD_Priority__c == null){pdConfig.PD_Priority__c = '';} else{}
            if(pdConfig.PD_Case_Category__c == null){pdConfig.PD_Case_Category__c = '';} else{}
            if(pdConfig.PD_Origin__c == null){pdConfig.PD_Origin__c = '';} else{}
            
            system.debug('*** debug pdConfig.PD_Priority__c = ' + pdConfig.PD_Priority__c);
            system.debug('*** debug pdConfig.PD_Products__c = ' + pdConfig.PD_Products__c);
            system.debug('*** debug pdConfig.PD_Case_Category__c = ' + pdConfig.PD_Case_Category__c);
            
            //if(cas.Priority == 'High'){
            if( checkRecursive.runOnce() && 
               (
                   ( pdConfig.PD_Email_to_Case_Override__c == true && (pdConfig.PD_Origin__c.Contains(checkOrigin) || pdConfig.PD_Origin__c == '' ) ) ||
                   ( (pdConfig.PD_Priority__c.Contains(checkPriority) || pdConfig.PD_Priority__c == '' ) 
                    && ( pdConfig.PD_Products__c.Contains(checkProd) || pdConfig.PD_Products__c == '' ) 
                    && ( pdConfig.PD_Case_Category__c.Contains(checkCat) || pdConfig.PD_Case_Category__c == '' ) )
               )
              ){
                  caseSubjectToSend = cas.CaseNumber + ' : ' + cas.Status +' : '+cas.Subject; 
                  system.debug('*** PagerDuty Post On Insert : ' + caseSubjectToSend);
                  CaseGateway.pagerDutyPostCallout(caseSubjectToSend);    
              }    
        } catch (Exception e){
            system.debug('**PagerDuty Configuration Error : There must be a Custom Setting Pager_Duty_Integration_Settings__c named based on the label PagerDuty_Config_Name.');
        }
        }*/

        // W-010324 - PagerDuty code update - Hemendra Singh Rajawat on Sept 28, 2018
        String category = cas.Case_Category__c != null ? cas.Case_Category__c : 'null';
        String origin = cas.Origin != null ? cas.Origin : 'null';
        String product = cas.Products__c != null ? cas.Products__c : 'null';
        String priority = cas.Priority != null ? cas.Priority : 'null';
        String severity = cas.Severity__c != null ? cas.Severity__c : 'null';
        String description = cas.CaseNumber+' : '+cas.Status+' : '+cas.Subject;

        for (Pager_Duty_Integration_Settings__c setting : pagerSettings) {

            setting.PD_Products__c = setting.PD_Products__c!= null ? setting.PD_Products__c : '';
            setting.PD_Case_Category__c = setting.PD_Case_Category__c!= null ? setting.PD_Case_Category__c : '';
            setting.PD_Origin__c = setting.PD_Origin__c!= null ? setting.PD_Origin__c : '';  
            setting.PD_Priority__c = setting.PD_Priority__c!= null ? setting.PD_Priority__c : '';
            setting.PD_Severity__c = setting.PD_Severity__c != null ? setting.PD_Severity__c : '';

system.debug('*** AI checkRecursive.runOnce() : '+ checkRecursive.runOnce());
system.debug('*** AI setting.PD_Email_to_Case_Override__c : ' +setting.PD_Email_to_Case_Override__c);
system.debug('*** AI setting.PD_Origin__c : '+setting.PD_Origin__c);
system.debug('*** AI setting.PD_Priority__c : '+setting.PD_Priority__c);
system.debug('*** AI setting.PD_Products__c : '+setting.PD_Products__c);
system.debug('*** AI setting.PD_Case_Category__c : '+setting.PD_Case_Category__c);
system.debug('*** AI setting.PD_Severity__c : '+setting.PD_Severity__c);
system.debug('*** AI origin, priority, product, category, severity : '+ origin+', ' +priority+', ' + product+', ' + category+', ' + severity);
            if (
            (setting.PD_Email_to_Case_Override__c && (setting.PD_Origin__c == origin))  
                || (!setting.PD_Email_to_Case_Override__c
                    && (setting.PD_Priority__c.contains(priority) || setting.PD_Priority__c == '') 
                    && (setting.PD_Products__c.contains(product) || setting.PD_Products__c == '') 
                    && (setting.PD_Case_Category__c.contains(category) || setting.PD_Case_Category__c == '')
                    && (setting.PD_Severity__c.contains(severity) || setting.PD_Severity__c == ''))) {
system.debug('*** AfterInsert : Case # : '+cas.CaseNumber + ' : PD Config : '+ setting.Name);
                system.debug('Sergio Debug: Case Information: '+ origin );
                String key = setting.get('PD_RequestServiceKey__c') != null ? (String) setting.get('PD_RequestServiceKey__c') : '';
                String client = setting.get('PD_Client__c') != null ? (String) setting.get('PD_Client__c') : '';
                String endPoint = setting.get('PD_Endpoint__c') != null ? (String) setting.get('PD_Endpoint__c') : '';
                
                String data = '{"service_key": "' + key + '", "event_type": "trigger",'
                                + '"description":"' + description + '" ,"client": "' + client + '",'
                                + '"client_url": "https://monitoring.service.com","details": {"ping time": "1500ms","load avg": 0.75}}';

                data += ',,,' + endpoint;

                callOutBodyList.add(data);break;
            }
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so)
    {
        
        Case casenew = (Case) so;
        case caseold = (Case) oldSo;
        
        //Commented by Grazitti on Sept 27, 2018
        /*if(checkRecursive.runOnce() || test.isRunningTest()){
        // W-007049 : JPH : 20180201 : Send a PagerDuty Notification if the Priority is changed to High
        String caseSubjectToSend = '';
        String checkPriority = casenew.Priority;
        String checkProd = casenew.Products__c;
        String checkCat = casenew.Case_Category__c;
        String checkOrigin = casenew.Origin;
        
        if(casenew.Priority == null){checkPriority = 'NULL';} else{}
        if(casenew.Products__c == null){checkProd = 'NULL';} else{}
        if(casenew.Case_Category__c == null){checkCat = 'NULL';} else{}
        if(casenew.Origin == null){checkOrigin = 'NULL';} else{}
        
        String pdIntName = Label.PagerDuty_Config_Name;
        try{
            Pager_Duty_Integration_Settings__c pdConfig = Pager_Duty_Integration_Settings__c.getInstance(pdIntName);         
            system.debug('*** pdConfig.Id :' + pdConfig.Id);
            
            if(pdConfig.PD_Products__c == null){pdConfig.PD_Products__c = '';} else{}
            if(pdConfig.PD_Priority__c == null){pdConfig.PD_Priority__c = '';} else{}
            if(pdConfig.PD_Case_Category__c == null){pdConfig.PD_Case_Category__c = '';} else{}
            if(pdConfig.PD_Origin__c == null){pdConfig.PD_Origin__c = '';} else{}
            
            system.debug('*** debug pdConfig.PD_Priority__c = ' + pdConfig.PD_Priority__c);
            system.debug('*** debug pdConfig.PD_Products__c = ' + pdConfig.PD_Products__c);
            system.debug('*** debug pdConfig.PD_Case_Category__c = ' + pdConfig.PD_Case_Category__c);
            
            //if(cas.Priority == 'High'){
            if( checkRecursive.runOnce() && casenew.Priority != caseold.Priority &&
               (
                   ( pdConfig.PD_Email_to_Case_Override__c == true && (pdConfig.PD_Origin__c.Contains(checkOrigin) || pdConfig.PD_Origin__c == '' ) ) ||
                   ( (pdConfig.PD_Priority__c.Contains(checkPriority) || pdConfig.PD_Priority__c == '' ) 
                    && ( pdConfig.PD_Products__c.Contains(checkProd) || pdConfig.PD_Products__c == '' ) 
                    && ( pdConfig.PD_Case_Category__c.Contains(checkCat) || pdConfig.PD_Case_Category__c == '' ) )
               )       
              ){
                  caseSubjectToSend = casenew.CaseNumber + ' : ' + casenew.Status +' : '+casenew.Subject; 
                  system.debug('*** PagerDuty Post On Update : ' + caseSubjectToSend);
                  CaseGateway.pagerDutyPostCallout(caseSubjectToSend);
              }        
        } catch (Exception e){
            system.debug('**PagerDuty Configuration Error : There must be a Custom Setting Pager_Duty_Integration_Settings__c named based on the label PagerDuty_Config_Name.');
        }
        }*/

        /*
        // W-010324 - PagerDuty code update - Hemendra Singh Rajawat on Sept 28, 2018
        if (casenew.Severity__c != caseold.Severity__c && checkRecursive.runOnce()) {
            String category = casenew.Case_Category__c != null ? casenew.Case_Category__c : 'null';
            String origin = casenew.Origin != null ? casenew.Origin : 'null';
            String product = casenew.Products__c != null ? casenew.Products__c : 'null';
            String priority = casenew.Priority != null ? casenew.Priority : 'null';
            String severity = casenew.Severity__c != null ? casenew.Severity__c : 'null';
            String description = casenew.CaseNumber+' : '+casenew.Status+' : '+casenew.Subject;

            for (Pager_Duty_Integration_Settings__c setting : pagerSettings) {

                setting.PD_Products__c = setting.PD_Products__c!= null ? setting.PD_Products__c : '';
                setting.PD_Case_Category__c = setting.PD_Case_Category__c!= null ? setting.PD_Case_Category__c : '';
                setting.PD_Origin__c = setting.PD_Origin__c!= null ? setting.PD_Origin__c : '';  
                setting.PD_Priority__c = setting.PD_Priority__c!= null ? setting.PD_Priority__c : '';
                setting.PD_Severity__c = setting.PD_Severity__c != null ? setting.PD_Severity__c : '';


                if (
                (setting.PD_Email_to_Case_Override__c && (setting.PD_Origin__c.contains(origin) || setting.PD_Origin__c == '')) 
                    || (!setting.PD_Email_to_Case_Override__c
                        && (setting.PD_Priority__c.contains(priority) || setting.PD_Priority__c == '') 
                        && (setting.PD_Products__c.contains(product) || setting.PD_Products__c == '') 
                        && (setting.PD_Case_Category__c.contains(category) || setting.PD_Case_Category__c == '')
                        && (setting.PD_Severity__c.contains(severity) || setting.PD_Severity__c == ''))) {
system.debug('*** AfterUpdate : Case # : '+casenew.CaseNumber + ' : PD Config : '+ setting.Name);
                    String key = setting.get('PD_RequestServiceKey__c') != null ? (String) setting.get('PD_RequestServiceKey__c') : '';
                    String client = setting.get('PD_Client__c') != null ? (String) setting.get('PD_Client__c') : '';
                    String endPoint = setting.get('PD_Endpoint__c') != null ? (String) setting.get('PD_Endpoint__c') : '';
                    
                    String data = '{"service_key": "' + key + '", "event_type": "trigger",'
                                    + '"description":"' + description + '" ,"client": "' + client + '",'
                                    + '"client_url": "https://monitoring.service.com","details": {"ping time": "1500ms","load avg": 0.75}}';

                    data += ',,,' + endpoint;

                    callOutBodyList.add(data);break;
                }
            }
        }*/
    }
    
    public void afterDelete(SObject so) {
    }
    
    /**
    * andFinally
    *
    * This method is called once all records have been processed by the trigger. Use this 
    * method to accomplish any final operations such as creation or updates of other records.
    */
    public void andFinally() {
        
        system.debug('bothSessionsScheduledMap==>'+bothSessionsScheduledMap);
        if (!bothSessionsScheduledMap.isEmpty() || !session1ScheduledMap.isEmpty() || !noSessionScheduledMap.isEmpty()) {
            emailMessagesToBeInserted = CaseGateway.generateEmailMsgforCase(bothSessionsScheduledMap,session1ScheduledMap,noSessionScheduledMap);
            
            system.debug('emailMessagesToBeInserted==>'+emailMessagesToBeInserted);   
            
            if(emailMessagesToBeInserted.size() > 0){
                try{
                    insert emailMessagesToBeInserted;
                }catch(Exception e){for(EmailMessage em : emailMessagesToBeInserted){em.adderror('EmailMessage Insertion Failed==>'+e.getMessage());}}
            }
        }
        
        if (!Closed_cases.IsEmpty()) {
            milestoneUtils.completeMilestone(Closed_cases, 'Response Time', System.now());
        }
        
        if (!helpers.isEmpty()) {
            CaseGateway.insertWebToCaseHelpers(helpers);
        }
// JPH - 20190402 - CPQ

        if (!callOutBodyList.isEmpty()) {
            CaseGateway.pagerDutyPostCallout(callOutBodyList);
        }
    }
}