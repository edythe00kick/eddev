trigger SetNextTaskPlanDate on Task (after insert, after update,after delete) {
   
    Map<Id,Task> taskId2task = new Map<Id,Task>();
    Set<Id> setLeadIds = new Set<Id>();
    Set<Id> setTaskIds = new Set<Id>();  
    Set<Id> setContactIds  = new Set<Id>(); 
    Set<Id> setAccountIds = new Set<Id>(); 
    Set<Id> setOpportunityIds= new Set<Id>();   
    Map<Id,List<Task>> lead2TasksMap = new Map<Id,List<Task>>();          
    Map<Id,List<Task>> contact2TasksMap = new Map<Id,List<Task>>();     
    Map<Id,List<Task>> opportunity2TasksMap = new Map<Id,List<Task>>();     
    Map<Id,List<Task>> account2TasksMap= new Map<Id,List<Task>>();  
    Map<Id,Lead> leadid2lead = new Map<Id,Lead>();    
    List<Lead>updatedleadList = new List<Lead>();
    Map<Id,Contact> contactId2Contact = new Map<Id,Contact>();    
    List<Contact>updatedContactList = new List<Contact>();
    Map<Id,Account> accountId2Account = new Map<Id,Account>();    
    List<Account>updatedAccountList = new List<Account>();
    Map<Id,Opportunity> opportunityId2Opportunity = new Map<Id,Opportunity>();    
    List<Opportunity>updatedOpportunityList = new List<Opportunity>();
    
    Map<Id,Account> updatedAccountMap = new Map<Id,Account>();
    Set<Id> openAccSet = new Set<Id>();
    Set<Id> closedAccSet = new Set<Id>();
Date d = system.today();

    if(Trigger.isDelete){
        for(Task tmpTask : Trigger.old) {
            //taskId2task.put(tmpTask.id,tmpTask);
            if(tmpTask.whoId != NULL){
                if((tmpTask.whoId+'').startsWithIgnoreCase('00Q')) {
                    setLeadIds.add(tmpTask.whoId); 
                }
                if((tmpTask.whoId+'').startsWithIgnoreCase('003')) {            
                    setContactIds.add(tmpTask.whoId); 
                } 
            }
            /*if(tmpTask.whoId == NULL) {               
               if(tmpTask.whatId != NULL && (tmpTask.whatId+'').startsWithIgnoreCase('001')){
                   setAccountIds.add(tmpTask.AccountId);
               }
            }  else if((tmpTask.whoId+'').startsWithIgnoreCase('00Q')) {
                setLeadIds.add(tmpTask.whoId); 
            } else if((tmpTask.whoId+'').startsWithIgnoreCase('003')) { 
                if(tmpTask.whatId != NULL && (tmpTask.whatId+'').startsWithIgnoreCase('001')){
                   setAccountIds.add(tmpTask.AccountId);                                          
                }            
                setContactIds.add(tmpTask.whoId); 
            }            
            if(tmpTask.accountid != NULL && (tmpTask.accountid+'').startsWithIgnoreCase('001')){
                setAccountIds.add(tmpTask.accountid);
            }*/
        }  
    }
       
    if(Trigger.isInsert || Trigger.isUpdate){
        for(Task tmpTask : Trigger.new) {
            //taskId2task.put(tmpTask.id,tmpTask);   
             if(tmpTask.whoId != NULL){
                if((tmpTask.whoId+'').startsWithIgnoreCase('00Q')) {
                    setLeadIds.add(tmpTask.whoId); 
                }
                if((tmpTask.whoId+'').startsWithIgnoreCase('003')) {            
                    setContactIds.add(tmpTask.whoId); 
                } 
            }
               
           /* if(tmpTask.whoId == NULL){
               if(tmpTask.whatId != NULL && (tmpTask.whatId+'').startsWithIgnoreCase('001')){
                   setAccountIds.add(tmpTask.AccountId);
               }
            }            
            else if((tmpTask.whoId+'').startsWithIgnoreCase('00Q')) {
                setLeadIds.add(tmpTask.whoId); 
            }
            else if((tmpTask.whoId+'').startsWithIgnoreCase('003')){ 
                setContactIds.add(tmpTask.whoId); 
                if(tmpTask.whatId != NULL && (tmpTask.whatId+'').startsWithIgnoreCase('001')){
                   setAccountIds.add(tmpTask.AccountId);
                }            
            }            
            if(tmpTask.accountid != NULL && (tmpTask.accountid+'').startsWithIgnoreCase('001')){
               setAccountIds.add(tmpTask.accountid);                
            }*/
        }
    }    
    system.debug('contactidset------------------------>'+setContactIds);
    system.debug('leadidset------------------------>'+setLeadIds);
    
//    MAP<Id, Account> myAccWithOpenTasks = new Map<Id,Account>();
//    MAP<Id, Account> myAccWithClosedTasks = new Map<Id,Account>();
    
    /*if(setAccountIds.isEmpty() == FALSE) {
        myAccWithOpenTasks = new Map<Id,Account>([SELECT Id, Name,Next_Task_Planned__c,Next_Task_Planned_Date__c,Last_Task_Completed__c,Last_Task_Completed_Date__c, (SELECT Id,Task_Completion_Date__c,createddate,ActivityDate,Subject,isClosed,isDeleted,whoid,whatid,accountid from Tasks WHERE IsClosed = false  AND isDeleted = false AND ActivityDate >=:d AND AccountId in :setAccountIds ORDER BY ActivityDate ASC,CreatedDate ASC limit 1) from Account where id in :setAccountIds]);    
        myAccWithClosedTasks = new Map<Id,Account>([SELECT Id, Name,Next_Task_Planned__c,Next_Task_Planned_Date__c,Last_Task_Completed__c,Last_Task_Completed_Date__c, (SELECT Id,Task_Completion_Date__c,createddate,ActivityDate,Subject,isClosed,isDeleted,whoid,whatid,accountid from Tasks WHERE IsClosed = true AND isDeleted = false ORDER BY Task_Completion_Date__c Desc limit 1) from Account where id in :setAccountIds]);        
    }*/
    
    
    /*Map<Id,Account> AccountsMap = new Map<Id,Account>([select id,Name,Next_Task_Planned__c,Next_Task_Planned_Date__c,Last_Task_Completed__c,Last_Task_Completed_Date__c from Account where id in :setAccountIds ]);
    
    for(Task t:[ SELECT Id,Task_Completion_Date__c,createddate,ActivityDate,Subject,isClosed,isDeleted,whoid,whatid,accountid from Task WHERE isDeleted = false AND isclosed = false AND accountid in :setAccountIds AND ActivityDate >=:d ORDER BY ActivityDate ASC , CreatedDate ASC ] )
    {
       // Boolean flag = false;
       // Account acc = AccountsMap.get(t.accountid);
        if(!openAccSet.contains(t.accountid)){
            Account acc = AccountsMap.get(t.accountid);
            if(acc.Next_Task_Planned__c != t.subject && acc.Next_Task_Planned_Date__c != t.activitydate ){
                acc.Next_Task_Planned__c = t.subject;
                acc.Next_Task_Planned_Date__c  = t.activitydate;
                updatedAccountMap.put(t.accountid ,acc);
            }
            
            openAccSet.add(t.accountid);
        }
    }
    for(Id aId : AccountsMap.keyset()){
        if(!openAccSet.contains(aId)){
            Account acc = AccountsMap.get(aId);
            if(acc.Next_Task_Planned__c != NULL){
                 acc.Next_Task_Planned__c = '';
                 acc.Next_Task_Planned_Date__c  = NULL;
                 updatedAccountMap.put(aId,acc);
             }
        }    
    }
    
    for(Task t:[ SELECT Id,Task_Completion_Date__c,createddate,ActivityDate,Subject,isClosed,isDeleted,whoid,whatid,accountid from Task WHERE isDeleted = false AND isclosed = true AND accountid in :setAccountIds AND (activitydate = LAST_N_QUARTERS:2 OR activitydate = THIS_QUARTER)  ORDER BY Task_Completion_Date__c DESC ] )
    {
        if(!closedAccSet.contains(t.accountId)){ 
            closedAccSet.add(t.accountid);
            if(!updatedAccountMap.containskey(t.accountid)){
                Account acc = AccountsMap.get(t.accountid);
                if(acc.Last_Task_Completed__c != t.subject && acc.Last_Task_Completed_Date__c != t.activitydate){
                    acc.Last_Task_Completed__c = t.subject;
                    acc.Last_Task_Completed_Date__c = t.activitydate;
                    updatedAccountMap.put(t.accountid ,acc);
                }
            }
            else{
                Account acc = AccountsMap.get(t.accountid);
                if(acc.Last_Task_Completed__c != t.subject && acc.Last_Task_Completed_Date__c != t.activitydate){
                    acc.Last_Task_Completed__c = t.subject;
                    acc.Last_Task_Completed_Date__c = t.activitydate;
                    updatedAccountMap.put(t.accountid ,acc);
                }
            
            }
        } 
    }
    
    for(Id aId : AccountsMap.keyset()){
        if(!closedAccSet.contains(aId)){
            if(updatedAccountMap.containskey(aId)){
               Account acc = updatedAccountMap.get(aId);
               if(acc.Last_Task_Completed__c != NULL){
                   acc.Last_Task_Completed__c = '';
                   acc.Last_Task_Completed_Date__c = NULL;
                   updatedAccountMap.put(aId,acc);
               }
            }
            else{
                Account acc = AccountsMap.get(aId);
                if(acc.Last_Task_Completed__c != NULL){
                    acc.Last_Task_Completed__c = '';
                    acc.Last_Task_Completed_Date__c = NULL;
                    updatedAccountMap.put(aId ,acc);
                }

            }
        }    
    }
    
    
    if(updatedAccountMap.keyset().size() > 0 && updatedAccountMap.keyset() != NULL){
        for(Id accId : updatedAccountMap.keyset()){
            updatedAccountList.add(updatedAccountMap.get(accId));
        }
    }
    if(!updatedAccountList.isEmpty()){
        update updatedAccountList;
    }*/
     
    
    
    
    
    
    
    MAP<Id, Contact> myContactWithOpenTasks = new Map<Id,Contact>();
    MAP<Id, Contact> myContactWithClosedTasks = new Map<Id,Contact>();
    
    if(setContactIds.isEmpty() == FALSE) {    
        myContactWithOpenTasks = new Map<Id,Contact>([SELECT Id, Name,Next_Task_Planned__c,Next_Task_Planned_Date__c,Last_Task_Completed__c,Last_Task_Completed_Date__c, (SELECT Id,Task_Completion_Date__c,createddate,ActivityDate,Subject,isClosed,isDeleted,whoid,whatid,accountid from Tasks WHERE IsClosed = false  AND isDeleted = false AND ActivityDate >=:d ORDER BY ActivityDate ASC,CreatedDate ASC limit 1) from Contact where id in :setContactIds]);    
        myContactWithClosedTasks = new Map<Id,Contact>([SELECT Id, Name,Next_Task_Planned__c,Next_Task_Planned_Date__c,Last_Task_Completed__c,Last_Task_Completed_Date__c, (SELECT Id,Task_Completion_Date__c,createddate,ActivityDate,Subject,isClosed,isDeleted,whoid,whatid,accountid from Tasks WHERE IsClosed = true AND isDeleted = false ORDER BY Task_Completion_Date__c DESC NULLS LAST limit 1) from Contact where id in :setContactIds]);        
    }

    MAP<Id, Lead> myLeadsWithOpenTasks = new Map<Id,Lead>();
    MAP<Id, Lead> myLeadsWithClosedTasks = new Map<Id,Lead>();

    if(setLeadIds.isEmpty() == FALSE) {    
        myLeadsWithOpenTasks = new Map<Id,Lead>([SELECT Id, Name,Next_Task_Planned__c,Next_Task_Planned_Date__c,Last_Task_Completed__c,Last_Task_Completed_Date__c, (SELECT Id,Task_Completion_Date__c,createddate,ActivityDate,Subject,isClosed,isDeleted,whoid,whatid,accountid from Tasks WHERE IsClosed = false  AND isDeleted = false AND ActivityDate >=:d ORDER BY ActivityDate ASC,CreatedDate ASC limit 1) from Lead where id in :setLeadIds]);    
        myLeadsWithClosedTasks = new Map<Id,Lead>([SELECT Id, Name,Next_Task_Planned__c,Next_Task_Planned_Date__c,Last_Task_Completed__c,Last_Task_Completed_Date__c, (SELECT Id,Task_Completion_Date__c,createddate,ActivityDate,Subject,isClosed,isDeleted,whoid,whatid,accountid from Tasks WHERE IsClosed = true AND isDeleted = false ORDER BY Task_Completion_Date__c DESC NULLS LAST limit 1) from Lead where id in :setLeadIds]);        
    }
    //Set<Lead> toBeUpdatedLeads = new Set<Lead>();
    
    /*for(Lead tmpLead : myLeadsWithOpenTasks.values()) {
        List<task> tmpTask = tmpLead.tasks;
        if(tmpTask.isEmpty() == FALSE) {
            if(tmpLead.Next_Task_Planned_Date__c != tmpTask[0].ActivityDate ) {
                Lead l1 = new Lead(id = tmpLead.id);
                l1.Next_Task_Planned__c = tmpTask[0].Subject;    
                l1.Next_Task_Planned_Date__c = tmpTask[0].activitydate;         
            }
        }    
    } */
  
  
      for(Lead c : myLeadsWithOpenTasks.values()) {
        List<task> tmpTask = c.tasks;
        if(tmpTask.isEmpty() == FALSE) {
            if(!leadid2lead.containskey(c.id)){
                    if(c.Next_Task_Planned_Date__c != tmpTask[0].ActivityDate || c.Next_Task_Planned__c != tmpTask[0].Subject) {
                        Lead l1 = new Lead(id = c.id);
                        l1.Next_Task_Planned__c = tmpTask[0].Subject;    
                        l1.Next_Task_Planned_Date__c = tmpTask[0].activitydate;  
                        leadid2lead.put(l1.id,l1);       
                    }
            }
        } 
        else{
               if(c.Next_Task_Planned__c != NULL){
                   if(!leadid2lead.containskey(c.id)){
                            Lead l1 = new Lead(id = c.id);                      
                            l1.Next_Task_Planned__c = '';    
                            l1.Next_Task_Planned_Date__c = NULL;  
                            leadid2lead.put(l1.id,l1);       
                        
                  } 
              }
        }   
    }  
    
    for(Lead c : myLeadsWithClosedTasks.values()) {
        List<task> tmpTask = c.tasks;
        if(tmpTask.isEmpty() == FALSE) {
            if(!leadid2lead.containskey(c.id)){
                    if(c.Last_Task_Completed_Date__c != tmpTask[0].ActivityDate || c.Last_Task_Completed__c  != tmpTask[0].Subject) {
                        Lead l1 = new Lead(id = c.id);
                        l1.Last_Task_Completed__c =  tmpTask[0].Subject; 
                        l1.Last_Task_Completed_Date__c= tmpTask[0].activitydate;  
                        leadid2lead.put(l1.id,l1);       
                    }
            }
            else{
                Lead cc = leadid2lead.get(c.id);
                if(cc.Last_Task_Completed_Date__c != tmpTask[0].ActivityDate || cc.Last_Task_Completed__c  != tmpTask[0].Subject) {
                        cc.Last_Task_Completed__c =  tmpTask[0].Subject; 
                        cc.Last_Task_Completed_Date__c= tmpTask[0].activitydate;  
                        leadid2lead.put(cc.id,cc);       
                }  
            }
        } 
        else{
                if(c.Last_Task_Completed__c  != NULL){
                    if(!leadid2lead.containskey(c.id)){
                            Lead l1 = new Lead(id = c.id);
                            l1.Last_Task_Completed__c ='';
                            l1.Last_Task_Completed_Date__c= NULL;  
                            leadid2lead.put(l1.id,l1);              
                    }
                    else{
                        Lead cc = leadid2lead.get(c.id);
                        cc.Last_Task_Completed__c = ''; 
                        cc.Last_Task_Completed_Date__c= NULL;  
                        leadid2lead.put(cc.id,cc);                         
                    }
               }
        }   
    } 
  
  
     if(leadid2lead.keyset() != null && leadid2lead.keyset().size() > 0){
         for(Id leadId :leadid2lead.keyset()){
             updatedleadList.add(leadid2lead.get(leadId));
         }
     }
     if(!updatedleadList.isEmpty()){
         try{
             update updatedleadList;
         }
         catch(DMLException e){
                 List<String> s = e.getMessage().split(',',2);
                 if(trigger.isInsert || trigger.isUpdate){
                    trigger.new[0].addError('Error on Lead :'+s[1].split(':')[0]);
                 }
                 else if(trigger.isDelete){
                    trigger.old[0].addError('Error on Lead :'+s[1].split(':')[0]);                        
                 }
         }
         catch(Exception de){
                 if(trigger.isInsert || trigger.isUpdate){
                    trigger.new[0].addError(de.getMessage());
                 }
                 else if(trigger.isDelete){
                    trigger.new[0].addError(de.getMessage());                        
                 }
         }

     }
       
    for(Contact c : myContactWithOpenTasks.values()) {
        List<task> tmpTask = c.tasks;
        if(tmpTask.isEmpty() == FALSE) {
            if(!contactId2Contact.containskey(c.id)){
                    if(c.Next_Task_Planned_Date__c != tmpTask[0].ActivityDate || c.Next_Task_Planned__c != tmpTask[0].Subject) {
                        Contact l1 = new Contact(id = c.id);
                        l1.Next_Task_Planned__c = tmpTask[0].Subject;    
                        l1.Next_Task_Planned_Date__c = tmpTask[0].activitydate;  
                        contactId2Contact.put(l1.id,l1);       
                    }
            }
        } 
        else{
               if(c.Next_Task_Planned__c != NULL){
                   if(!contactId2Contact.containskey(c.id)){
                            Contact l1 = new Contact(id = c.id);
                            l1.Next_Task_Planned__c = '';    
                            l1.Next_Task_Planned_Date__c = NULL;  
                            contactId2Contact.put(l1.id,l1);       
                        
                 } 
              }
        }   
    }  
    
    for(Contact c : myContactWithClosedTasks.values()) {
        List<task> tmpTask = c.tasks;
        if(tmpTask.isEmpty() == FALSE) {
            if(!contactId2Contact.containskey(c.id)){
                    if(c.Last_Task_Completed_Date__c != tmpTask[0].ActivityDate || c.Last_Task_Completed__c  != tmpTask[0].Subject) {
                        Contact l1 = new Contact(id = c.id);
                        l1.Last_Task_Completed__c =  tmpTask[0].Subject; 
                        l1.Last_Task_Completed_Date__c= tmpTask[0].activitydate;  
                        contactId2Contact.put(l1.id,l1);       
                    }
            }
            else{
                Contact cc = contactId2Contact.get(c.id);
                if(cc.Last_Task_Completed_Date__c != tmpTask[0].ActivityDate || cc.Last_Task_Completed__c  != tmpTask[0].Subject) {
                        cc.Last_Task_Completed__c =  tmpTask[0].Subject; 
                        cc.Last_Task_Completed_Date__c= tmpTask[0].activitydate;  
                        contactId2Contact.put(cc.id,cc);       
                }  
            }
        } 
        else{
            if(c.Last_Task_Completed__c  != NULL){
                if(!contactId2Contact.containskey(c.id)){
                        Contact l1 = new Contact(id = c.id);
                        l1.Last_Task_Completed__c ='';
                        l1.Last_Task_Completed_Date__c= NULL;  
                        contactId2Contact.put(l1.id,l1);              
                }
                else{
                    Contact cc = contactId2Contact.get(c.id);
                    cc.Last_Task_Completed__c = ''; 
                    cc.Last_Task_Completed_Date__c= NULL;  
                    contactId2Contact.put(cc.id,cc);                         
                }
            }
        }   
    } 
  
  
     if(contactId2Contact.keyset() != null && contactId2Contact.keyset().size() > 0){
         for(Id conId:contactId2Contact.keyset()){
             updatedContactList.add(contactId2Contact.get(conId));
         }
     }
     if(!updatedContactList.isEmpty()){
         try{
             update updatedContactList;
         }
         catch(DMLException e){
                 List<String> s = e.getMessage().split(',',2);
                 if(trigger.isInsert || trigger.isUpdate){
                    trigger.new[0].addError('Error on Contact :'+s[1].split(':')[0]);
                 }
                 else if(trigger.isDelete){
                    trigger.old[0].addError('Error on Contact :'+s[1].split(':')[0]);                        
                 }
         }
         catch(Exception de){
                 if(trigger.isInsert || trigger.isUpdate){
                    trigger.new[0].addError(de.getMessage());
                 }
                 else if(trigger.isDelete){
                    trigger.new[0].addError(de.getMessage());                        
                 }
         }
     }
     
/*    
    for(Task t:[ SELECT Id,Task_Completion_Date__c,createddate,ActivityDate,Subject,isClosed,isDeleted,whoid,whatid,accountid from Task WHERE isDeleted = false AND ((whoId in :setLeadIds or whoId in :setContactIds) OR (whatid in :setOpportunityIds or whatid in :setAccountIds) OR (accountid in :setAccountIds)) ORDER BY ActivityDate ASC , CreatedDate ASC ] )
    {
            //taskId2task.put(t.id,t);
            if(t.whoId != NULL && (t.whoId+'').startsWithIgnoreCase('00Q') && setLeadIds.contains(t.whoId) ){
                if(!lead2TasksMap.containskey(t.whoid)){
                    System.debug('@@@@@@@@@@@@@@task id'+t.id);
                    //lead2TasksMap.put(t.whoid,new Set<Id>{t.id});
                    lead2TasksMap.put(t.whoid,new List<Task>{t});
                }
                else{
                    //lead2TasksMap.get(t.whoid).add(t.id);
                    lead2TasksMap.get(t.whoid).add(t);
                }
            }
            else if(t.whoId != NULL && (t.whoId+'').startsWithIgnoreCase('003') && setContactIds.contains(t.whoId)){
                    if(!contact2TasksMap.containskey(t.whoid)){
                        contact2TasksMap.put(t.whoid,new List<Task>{t});
                    }
                    else{
                        contact2TasksMap.get(t.whoid).add(t);
                    }    
            }
            
            
           if(t.accountid != NULL && (t.accountid+'').startsWithIgnoreCase('001') && setAccountIds.contains(t.accountid )){
                 if(!account2TasksMap.containskey(t.accountid)){
                        account2TasksMap.put(t.accountid ,new List<Task>{t});
                    }
                    else{
                        account2TasksMap.get(t.accountid).add(t);
                    } 
            } 
        }
        
        if(!lead2TasksMap.isEmpty()){
            for(Id leadId : lead2TasksMap.keyset()){
                 List<Task> tasks =  lead2TasksMap.get(leadId);
                 System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@set'+tasks);
                 List<Task> closedtasklist = new List<Task>();
                 List<Task> opentasklist = new List<Task>();
                 Boolean bool = TRUE;
                 for(Task tas : tasks ){
                      //Task tas = taskId2task.get(taskId);
                      if(tas.isClosed == true){
                          closedtasklist.add(tas);
                      }
                      else{
                           //opentasklist.add(tas);
                           if(tas.ActivityDate >= Date.Today() && bool  == TRUE){
                           System.debug('@@@@@@@@@task'+tas);
                                opentasklist.add(tas);
                                bool = FALSE;
                           }
                      }
                 }
                 if(!opentasklist.isEmpty()){
                     Lead l = new Lead(id=leadId);
                     if(!leadid2lead.containskey(leadId)){
                         l.Next_Task_Planned__c = opentasklist[0].subject;
                         l.Next_Task_Planned_Date__c = opentasklist[0].activitydate;
                         leadid2lead.put(l.id,l);
                     }
                     
                 } else{
                     Lead l = new Lead(id=leadId);
                     if(!leadid2lead.containskey(leadid)){
                         l.Next_Task_Planned__c = '';
                         l.Next_Task_Planned_Date__c = NULL;
                         leadid2lead.put(l.id,l);
                         system.debug('11111111111111111111111111');
                     }                     
                 }
                 if(!closedtasklist.isEmpty()){
                     Boolean flag1 = TRUE;
                     Task t3 = new Task();
                     for(Task ta : closedtasklist){
                         if(ta.Task_Completion_Date__c != NULL){
                             if(flag1 == TRUE){
                                t3 =ta;
                                system.debug('##########task1'+t3);
                                flag1 = false;
                             }
                             else{
                                 if(ta.Task_Completion_Date__c > t3.Task_Completion_Date__c){
                                     t3 = ta;
                                     system.debug('##########task2'+t3);
                                 } 
                             }
                        }     
                     }
                     if(t3.Task_Completion_Date__c != NULL) {
                         Lead le = new Lead(id=leadId);               
                         Lead lea =leadid2lead.get(leadId);
                         lea.Last_Task_Completed__c = t3.subject;
                         lea.Last_Task_Completed_Date__c= t3.activitydate;
                         leadid2lead.put(lea.id,lea);                         
                     }
                 }
                 else{
                     Lead l = new Lead(id=leadId);
                     if(!leadid2lead.containskey(l.id)){
                         l.Last_Task_Completed__c = '';
                         l.Last_Task_Completed_Date__c= NULL;
                         leadid2lead.put(l.id,l);
                     }
                     else{
                         Lead l1 =leadid2lead.get(leadId);
                         l1.Last_Task_Completed__c = '';
                         l1.Last_Task_Completed_Date__c= NULL;
                         leadid2lead.put(l1.id,l1);
                     }
                 }
            }
        }
        
        for(Id leadId : setLeadIds){
            if(!lead2TasksMap.containskey(leadId)){
                if(!leadid2lead.containskey(leadId)){
                    Lead ld = new Lead(id = leadId);
                     ld.Last_Task_Completed__c = '';
                     ld.Last_Task_Completed_Date__c = NULL;
                     ld.Next_Task_Planned__c = '';
                     ld.Next_Task_Planned_Date__c = NULL;
                     updatedleadList.add(ld);
                }
            }
        }
        
        
        if(!leadid2lead.isEmpty()){
            for(Id leadId : leadid2lead.keyset()){
                updatedleadList.add(leadid2lead.get(leadId));
            }
        }
        if(updatedleadList.size() > 0 && updatedleadList!= NULL){
            try{
                update updatedleadList;      
            }
            catch(DMLException e){
                 List<String> s = e.getMessage().split(',',2);
                 if(trigger.isInsert || trigger.isUpdate){
                    trigger.new[0].addError('Error on Lead :'+s[1].split(':')[0]);
                  //trigger.new[0].addError(e.getMessage());
                 }
                 else if(trigger.isDelete){
                        // trigger.old[0].addError(e.getMessage());
                    trigger.old[0].addError('Error on Lead :'+s[1].split(':')[0]);                        
                 }
            }
            catch(Exception de){
                 if(trigger.isInsert || trigger.isUpdate){
                    trigger.new[0].addError(de.getMessage());
                 }
                 else if(trigger.isDelete){
                    trigger.new[0].addError(de.getMessage());                        
                 }
            }
        }
   

        if(!contact2TasksMap.isEmpty()){
            for(Id conId : contact2TasksMap.keyset()){
                 List<Task> tasks =  contact2TasksMap.get(conId);
                 System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@set'+tasks);
                 List<Task> closedtasklist = new List<Task>();
                 List<Task> opentasklist = new List<Task>();
                 Boolean bool = TRUE;
                 for(Task tas : tasks ){
                      //Task tas = taskId2task.get(taskId);
                      if(tas.isClosed == true){
                          closedtasklist.add(tas);
                      }
                      else{
                           //opentasklist.add(tas);
                           if(tas.ActivityDate >= Date.Today() && bool  == TRUE){
                           System.debug('@@@@@@@@@task'+tas);
                                opentasklist.add(tas);
                                bool = FALSE;
                           }
                      }
                 }
                 if(!opentasklist.isEmpty()){
                     Contact l = new Contact(id=conId);
                     if(!contactId2Contact.containskey(conId)){
                         l.Next_Task_Planned__c = opentasklist[0].subject;
                         l.Next_Task_Planned_Date__c = opentasklist[0].activitydate;
                         contactId2Contact.put(l.id,l);
                     }
                     
                 }
                 else{
                    Contact l = new Contact(id=conId);
                     if(!contactId2Contact.containskey(conId)){
                         l.Next_Task_Planned__c = '';
                         l.Next_Task_Planned_Date__c = NULL;
                         contactId2Contact.put(l.id,l);
                         system.debug('11111111111111111111111111');
                     }
                     
                 }
                 if(!closedtasklist.isEmpty()){
                     Boolean flag1 = TRUE;
                     Task t3 = new Task();
                     for(Task ta : closedtasklist){
                         if(ta.Task_Completion_Date__c != NULL){
                             if(flag1 == TRUE){
                                t3 =ta;
                                system.debug('##########task1'+t3);
                                flag1 = false;
                             }
                             else{
                                 if(ta.Task_Completion_Date__c > t3.Task_Completion_Date__c){
                                     t3 = ta;
                                     system.debug('##########task2'+t3);
                                 } 
                             }
                         }
                     }
                     if(t3.Task_Completion_Date__c != NULL){
                         Contact le = new Contact(id=conId);                    
                         if(!contactId2Contact.containskey(conId)){
                             le.Last_Task_Completed__c = t3.subject;
                             le.Last_Task_Completed_Date__c= t3.activitydate;
                             contactId2Contact.put(le.id,le);
                         }
                         else{
                             Contact lea =contactId2Contact.get(conId);
                             lea.Last_Task_Completed__c = t3.subject;
                             lea.Last_Task_Completed_Date__c= t3.activitydate;
                             contactId2Contact.put(lea.id,lea);
                         }
                     }

                 }
                 else{
                     Contact l = new Contact(id=conId);
                     if(!contactId2Contact.containskey(l.id)){
                         l.Last_Task_Completed__c = '';
                         l.Last_Task_Completed_Date__c= NULL;
                         contactId2Contact.put(l.id,l);
                     }
                     else{
                         Contact l1 =contactId2Contact.get(conId);
                         l1.Last_Task_Completed__c = '';
                         l1.Last_Task_Completed_Date__c= NULL;
                         contactId2Contact.put(l1.id,l1);
                     }
                 }
            }
        }   
   
        for(Id conId: setContactIds){
            if(!contact2TasksMap.containskey(conId)){
                if(!contactId2Contact.containskey(conId)){
                    Contact ld = new Contact(id = conId);
                     ld.Last_Task_Completed__c = '';
                     ld.Last_Task_Completed_Date__c = NULL;
                     ld.Next_Task_Planned__c = '';
                     ld.Next_Task_Planned_Date__c = NULL;
                     updatedContactList.add(ld);
                }
            }
        }
        
        
        if(!contactId2Contact.isEmpty()){
            for(Id conId : contactId2Contact.keyset()){
                updatedContactList.add(contactId2Contact.get(conId));
            }
        }
        if(updatedContactList.size() > 0 && updatedContactList!= NULL){
            try{
                update updatedContactList;           
            }
            catch(DMLException e){
                 List<String> s = e.getMessage().split(',',2);
                 if(trigger.isInsert || trigger.isUpdate){
                    trigger.new[0].addError('Error on Contact :'+s[1].split(':')[0]);
                  //trigger.new[0].addError(e.getMessage());
                 }
                 else if(trigger.isDelete){
                        // trigger.old[0].addError(e.getMessage());
                    trigger.old[0].addError('Error on Contact :'+s[1].split(':')[0]);                        
                 }
            }
            catch(Exception de){
                 if(trigger.isInsert || trigger.isUpdate){
                    trigger.new[0].addError(de.getMessage());
                 }
                 else if(trigger.isDelete){
                    trigger.new[0].addError(de.getMessage());                        
                 }
            }
        }     
   system.debug('account2tasksmap--------------------------------->'+account2TasksMap);
        if(!account2TasksMap.isEmpty()){
            for(Id accId : account2TasksMap.keyset()){
                 List<Task> tasks =  account2TasksMap.get(accId );
                 System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@set'+tasks);
                 List<Task> closedtasklist = new List<Task>();
                 List<Task> opentasklist = new List<Task>();
                 Boolean bool = TRUE;
                 for(Task tas : tasks ){
                      //Task tas = taskId2task.get(taskId);
                      if(tas.isClosed == true){
                          closedtasklist.add(tas);
                      }
                      else{
                           //opentasklist.add(tas);
                           if(tas.ActivityDate >= Date.Today() && bool  == TRUE){
                           System.debug('@@@@@@@@@task'+tas);
                                opentasklist.add(tas);
                                bool = FALSE;
                           }
                      }
                 }
                 if(!opentasklist.isEmpty()){
                     Account l = new Account (id=accId );
                     if(!accountId2Account.containskey(accId )){
                         l.Next_Task_Planned__c = opentasklist[0].subject;
                         l.Next_Task_Planned_Date__c = opentasklist[0].activitydate;
                         accountId2Account.put(l.id,l);
                     }
                 }
                 else{
                     Account l = new Account (id=accId );
                     if(!accountId2Account.containskey(accId )){
                         l.Next_Task_Planned__c = '';
                         l.Next_Task_Planned_Date__c = NULL;
                         accountId2Account.put(l.id,l);
                         system.debug('11111111111111111111111111');
                     }
                 }
                 if(!closedtasklist.isEmpty()){
                     Boolean flag1 = TRUE;
                     Task t3 = new Task();
                     for(Task ta : closedtasklist){
                         if(ta.Task_Completion_Date__c != NULL){
                             if(flag1 == TRUE){
                                t3 =ta;
                                system.debug('##########acctask1'+t3);
                                flag1 = false;
                             }
                             else{
                                 if(ta.Task_Completion_Date__c > t3.Task_Completion_Date__c){
                                     t3 = ta;
                                     system.debug('##########acctask2'+t3);
                                 } 
                             }
                         }
                     }
                     if(t3.Task_Completion_Date__c != NULL){
                         Account le = new Account(id=accId );
                         if(!accountId2Account.containskey(accId )){
                             le.Last_Task_Completed__c = t3.subject;
                             le.Last_Task_Completed_Date__c= t3.activitydate;
                             accountId2Account.put(le.id,le);
                         }
                         else{
                             Account lea =accountId2Account.get(accId );
                             lea.Last_Task_Completed__c = t3.subject;
                             lea.Last_Task_Completed_Date__c= t3.activitydate;
                             accountId2Account.put(lea.id,lea);
                         }
                     }

                 }
                 else{
                 system.debug('-------------------------------->accountclosedtasklist is empty');
                     Account l = new Account (id=accId );
                     if(!accountId2Account.containskey(l.id)){
                         l.Last_Task_Completed__c = '';
                         l.Last_Task_Completed_Date__c= NULL;
                         accountId2Account.put(l.id,l);
                     }
                     else{
                         Account l1 =accountId2Account.get(accId );
                         l1.Last_Task_Completed__c = '';
                         l1.Last_Task_Completed_Date__c= NULL;
                         accountId2Account.put(l1.id,l1);
                     }
                 }
            }
        }   
   
        for(Id accId : setAccountIds){
            if(!account2TasksMap.containskey(accId )){
                if(!accountId2Account.containskey(accId )){
                    Account ld = new Account(id = accId );
                     ld.Last_Task_Completed__c = '';
                     ld.Last_Task_Completed_Date__c = NULL;
                     ld.Next_Task_Planned__c = '';
                     ld.Next_Task_Planned_Date__c = NULL;
                     updatedAccountList.add(ld);
                }
            }
        }
        
        
        if(!accountId2Account.isEmpty()){
            for(Id accId : accountId2Account.keyset()){
                updatedAccountList.add(accountId2Account.get(accId ));
            }
        }
        system.debug('updatedAccountList--------------------------------->'+updatedAccountList);
        if(updatedAccountList.size() > 0 && updatedAccountList != NULL){
            try{
                update updatedAccountList;         
            }
            catch(DMLException e){
                 List<String> s = e.getMessage().split(',',2);
                 if(trigger.isInsert || trigger.isUpdate){
                    trigger.new[0].addError('Error on Account :'+s[1].split(':')[0]);
                  //trigger.new[0].addError(e.getMessage());
                 }
                 else if(trigger.isDelete){
                        // trigger.old[0].addError(e.getMessage());
                    trigger.old[0].addError('Error on Account :'+s[1].split(':')[0]);                        
                 }
            }
            catch(Exception de){
                 if(trigger.isInsert || trigger.isUpdate){
                    trigger.new[0].addError(de.getMessage());
                 }
                 else if(trigger.isDelete){
                    trigger.new[0].addError(de.getMessage());                        
                 }
            }
        }  
        


*/


         
}