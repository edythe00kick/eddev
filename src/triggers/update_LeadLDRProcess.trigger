trigger update_LeadLDRProcess on Task (after insert) {
    
    Set<Id> lead_ids = new Set<Id>();
    Set<Id> contact_ids = new Set<Id>();
    Map<Id,Id> task_map= new Map<Id, Id>();
    Map<Id, Id> contactId_taskId_map = new Map<Id, Id>();
    
    for(Task t : Trigger.new) {
    
        if(t.WhoId != null) {
            
            String whoId = t.WhoId;
            if(whoId.startsWith('00Q')) {
            
                lead_ids.add(t.WhoId);
                task_map.put(t.WhoID ,t.OwnerId);
            
            } else if(whoId.startsWith('003')) {
            
                contact_ids.add(t.WhoId);
                contactId_taskId_map.put(t.WhoId, t.Id);
            
            }
            
        }
        
    }
    
    List<Lead> leads = new List<Lead>();
    List<Contact> contacts = new List<Contact>();
    
    Set<Id> user_ids = new Set<Id>();
    
    for(Lead l : [SELECT  Id, Pain_Point_Values__c, Lead_Owner_Manager_Email__c,
            Pain_Pont__c, LDR_Process_Button_Visibility__c,
            Lead_Development_Rep_Email__c, Lead_Development_Rep_ID__c,
            Lead_Development_Rep_Name__c, OwnerId, X1st_SAO_Submitted_Date__c,
            Most_Recent_SAO_Submitted_Date__c, 
            X1st_SAO_Submitted_Date_Reference__c, 
            Most_Recent_SAO_Submitted_Date_Reference__c
            FROM Lead 
            WHERE Id IN :lead_ids]) {
    
        leads.add(l);
        user_ids.add(l.OwnerId);
    
    }
    
    System.debug('>>>> leads:' + leads);
    System.debug('>>>> user_ids:' + user_ids);
    
    
    for(Contact c : [SELECT Id, OwnerId, LDR_Process_Button_Visibility__c,
            Pain_Point__c, Pain_Point_Values__c, 
            Lead_Development_Rep_Email__c, Lead_Development_Rep_Name__c,
            Lead_Development_Rep_ID__c, X1st_SAO_Submitted_Date__c,
            X1st_SAO_Submitted_Date_Reference__c,
            Most_Recent_SAO_Submitted_Date__c,
            Most_Recent_SAO_Submitted_Date_Reference__c, 
            Lead_Owner_Manager_Email__c,
            Account.Lead_Development_Rep__c
            FROM Contact
            WHERE Id IN :contact_ids]) {
                
        contacts.add(c);
        user_ids.add(c.OwnerId);
        user_ids.add(c.Account.Lead_Development_Rep__c);
    
    }
    
    System.debug('>>>> contacts:' + contacts);
    System.debug('>>>> user_ids:' + user_ids);
    
    Map<Id, User> users_map = new Map<Id, User>();
    for(User u : [SELECT Id, Name, Email, Manager.Email 
            FROM User
            WHERE Id IN :user_ids]) {
        
        users_map.put(u.Id, u);
        
    }
    
    List<Lead> leads_to_update = new List<Lead>();
    List<Contact> contacts_to_update = new List<Contact>();
    for(Lead l : leads) {
        
        if(l.Pain_Point_Values__c != null 
                && l.LDR_Process_Button_Visibility__c == False
                && l.X1st_SAO_Submitted_Date__c == NULL) {
            
            Id current_lead_owner = l.OwnerId;
            l.OwnerId = task_map.get(l.id); // lead's new owner
            l.LDR_Process_Button_Visibility__c = true;
            l.Pain_Pont__c = l.Pain_Point_Values__c;
            l.Pain_Point_Values__c = '';
            l.X1st_SAO_Submitted_Date__c 
                = l.X1st_SAO_Submitted_Date_Reference__c;
            l.Most_Recent_SAO_Submitted_Date__c 
                = l.Most_Recent_SAO_Submitted_Date_Reference__c;
                
            User prev_lead_owner = users_map.get(current_lead_owner);
            l.Lead_Development_Rep_Email__c = prev_lead_owner.Email;
            l.Lead_Development_Rep_Name__c = prev_lead_owner.Name;
            l.Lead_Development_Rep_ID__c = prev_lead_owner.Id;
            if(prev_lead_owner.Manager.Email != null) {
                
                l.Lead_Owner_Manager_Email__c = prev_lead_owner.Manager.Email;
                
            }
            leads_to_update.add(l);
            
        } else if(l.Pain_Point_Values__c != null 
                && l.LDR_Process_Button_Visibility__c == False
                && l.X1st_SAO_Submitted_Date__c != NULL) {
            
            Id current_lead_owner = l.OwnerId;
            l.OwnerId = task_map.get(l.id); // lead's new owner
            l.LDR_Process_Button_Visibility__c = true;
            l.Pain_Pont__c = l.Pain_Point_Values__c;
            l.Pain_Point_Values__c = '';
            l.Most_Recent_SAO_Submitted_Date__c 
                = l.Most_Recent_SAO_Submitted_Date_Reference__c;
                
            User prev_lead_owner = users_map.get(current_lead_owner);
            l.Lead_Development_Rep_Email__c = prev_lead_owner.Email;
            l.Lead_Development_Rep_Name__c = prev_lead_owner.Name;
            l.Lead_Development_Rep_ID__c = prev_lead_owner.Id;
            if(prev_lead_owner.Manager.Email != null) {
                
                l.Lead_Owner_Manager_Email__c = prev_lead_owner.Manager.Email;
                
            }
            leads_to_update.add(l);
            
        }
        
    }
    
    for(Contact c : contacts) {
        
        if(c.Pain_Point_Values__c != null 
                && c.LDR_Process_Button_Visibility__c == False
                && c.X1st_SAO_Submitted_Date__c == NULL) {
                    
            c.LDR_Process_Button_Visibility__c = true;
            c.Pain_Point__c = c.Pain_Point_Values__c;
            c.Pain_Point_Values__c = '';
            c.X1st_SAO_Submitted_Date__c 
                = c.X1st_SAO_Submitted_Date_Reference__c;
            c.Most_Recent_SAO_Submitted_Date__c 
                = c.Most_Recent_SAO_Submitted_Date_Reference__c;
                
            if(contactId_taskId_map.containsKey(c.Id)) {
            
                c.SAO_Task_Id__c = contactId_taskId_map.get(c.Id);
            
            }
                
            
            if(users_map.containsKey(c.OwnerId)) {
                
                User contact_owner = users_map.get(c.OwnerId);
                if(contact_owner.Manager.Email != null) {
                    
                    c.Lead_Owner_Manager_Email__c = contact_owner.Manager.Email;
                    
                }
                
            }
            
            if(users_map.containsKey(c.Account.Lead_Development_Rep__c)) {
                
                User ldr = users_map.get(c.Account.Lead_Development_Rep__c);
                c.Lead_Development_Rep_Email__c = ldr.Email;
                c.Lead_Development_Rep_Name__c = ldr.Name;
                c.Lead_Development_Rep_ID__c = ldr.Id;
                
            }
            
            contacts_to_update.add(c);
                    
        } else if(c.Pain_Point_Values__c != null 
                && c.LDR_Process_Button_Visibility__c == False
                && c.X1st_SAO_Submitted_Date__c != NULL) {
            
            c.LDR_Process_Button_Visibility__c = true;
            c.Pain_Point__c = c.Pain_Point_Values__c;
            c.Pain_Point_Values__c = '';
            c.Most_Recent_SAO_Submitted_Date__c 
                = c.Most_Recent_SAO_Submitted_Date_Reference__c;
                
            if(contactId_taskId_map.containsKey(c.Id)) {
            
                c.SAO_Task_Id__c = contactId_taskId_map.get(c.Id);
            
            }
            
            if(users_map.containsKey(c.OwnerId)) {
                
                User contact_owner = users_map.get(c.OwnerId);
                if(contact_owner.Manager.Email != null) {
                    
                    c.Lead_Owner_Manager_Email__c = contact_owner.Manager.Email;
                    
                }
                
            }
            
            if(users_map.containsKey(c.Account.Lead_Development_Rep__c)) {
                
                User ldr = users_map.get(c.Account.Lead_Development_Rep__c);
                c.Lead_Development_Rep_Email__c = ldr.Email;
                c.Lead_Development_Rep_Name__c = ldr.Name;
                c.Lead_Development_Rep_ID__c = ldr.Id;
                
            }
            
            contacts_to_update.add(c);
            
        }
        
    }
    
    if(!leads_to_update.isEmpty()) {
        
        try {
            
            update leads_to_update;
            
        } catch (Exception ex) { for(Task t : trigger.new) { Exception cause = ex.getCause(); t.addError(cause != null ? cause.getMessage() : ex.getMessage()); } }
        
    }
    
    if(!contacts_to_update.isEmpty()) {
        
        try {
            
            update contacts_to_update;
            
        } catch (Exception ex) { for(Task t : trigger.new) { Exception cause = ex.getCause(); t.addError(cause != null ? cause.getMessage() : ex.getMessage()); } }
        
    }
     
}