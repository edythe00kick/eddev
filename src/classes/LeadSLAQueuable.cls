public without sharing class LeadSLAQueuable implements Queueable {

    public Map<Id, Lead> leadIdToLeadMap;

    public LeadSLAQueuable(Map<Id, Lead> leadIdToLeadMap) {
        this.leadIdToLeadMap = leadIdToLeadMap;
        
    }

    public void execute(QueueableContext context) {
        RecursionHandler.IsLeadSLAQueuableExecuted = true; 
         System.debug('inside executeLeadSLQTaskAndEmail queuable ' +leadIdToLeadMap);

        Set<Id> userIds = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();
        Map<Id, Id> ownerIdToManagerId = new Map<Id, Id>();
        //List<Task> taskList = new List<Task>();       //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Set<String> emailTemplateName = new Set<String>{'Lead_Hot_SLA_Date_Template_24_hours_Email', 'Lead_Warm_SLA_Date_Template_48_hours_Email', 'Lead_Dispensation_SLA_Warm_2_Days_Email', 'Lead_Conversion_SLA_Warm_21_Days_Email', 'Lead_Dispensation_SLA_Hot_1_Day_Email', 'Lead_Conversion_SLA_Hot_14_Days_Email',
        'Rep_Lead_Dispensation_SLA_Warm_2_Days_Email', 'Rep_Lead_Conversion_SLA_Warm_21_Days_Email', 'Rep_Lead_Dispensation_SLA_Hot_1_Day_Email', 'Rep_Lead_Conversion_SLA_Hot_14_Days_Email'};
		String etHot = '';
        String etWarm = '';
        String etWarm2day = '';
        String etWarm21day = '';
        String etHot1day = '';
        String etHot14day = '';
        //Sergio Flores
        //Date 01/31/2020
        //W-013893
        String repWarm2Day = '';
        String repWarm21Day = '';
        String repWarm1Day = '';
        String repWarm14Day = '';

        for(Lead l : leadIdToLeadMap.values())
        {
            userIds.add(l.OwnerId);
        }
       
        if(userIds.size()>0){
            userMap =  new Map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN: userIds]);
        }

        for(User u : userMap.values())
        {
            ownerIdToManagerId.put(u.Id, u.ManagerId);
        }

         System.debug('userMap queuable ' +userMap);

        for(EmailTemplate etlist : [SELECT Id,DeveloperName,Subject, Body FROM EmailTemplate WHERE DeveloperName IN: emailTemplateName]){
            if(etlist.DeveloperName == 'Lead_Hot_SLA_Date_Template_24_hours_Email'){
                etHot = etList.Id;
            }else if(etlist.DeveloperName == 'Lead_Warm_SLA_Date_Template_48_hours_Email'){
                etWarm = etList.Id;
            }else if(etlist.DeveloperName == 'Lead_Dispensation_SLA_Warm_2_Days_Email'){
                etWarm2day = etList.Id;
            }else if(etlist.DeveloperName == 'Lead_Conversion_SLA_Warm_21_Days_Email'){
                etWarm21day = etList.Id;
            }else if(etlist.DeveloperName == 'Lead_Dispensation_SLA_Hot_1_Day_Email'){
                etHot1day = etList.Id;
            }else if(etlist.DeveloperName == 'Lead_Conversion_SLA_Hot_14_Days_Email'){
                etHot14day = etList.Id;
            }
            else if(etlist.DeveloperName == 'Rep_Lead_Dispensation_SLA_Warm_2_Days_Email'){
                repWarm2Day = etList.Id;
            }else if(etlist.DeveloperName == 'Rep_Lead_Conversion_SLA_Warm_21_Days_Email'){
                repWarm21Day = etList.Id;
            }else if(etlist.DeveloperName == 'Rep_Lead_Dispensation_SLA_Hot_1_Day_Email'){
                repWarm1Day = etList.Id;
            }else if(etlist.DeveloperName == 'Rep_Lead_Conversion_SLA_Hot_14_Days_Email'){
                repWarm14Day = etList.Id;
            }
        }
		//Iterate over the Lead map and create the tasks and emails

        System.debug('email templates  ' +etHot + ' ' +etWarm + ' ' +etWarm2day + ' ' +etWarm21day + ' ' +etHot1day + ' ' +etHot14day);

        for(Lead l: leadIdToLeadMap.values())
        {
            System.debug('inside lead sla queuable loop');
            //Task tsk = new Task();                                                     //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            Messaging.SingleEmailMessage email;
            Messaging.SingleEmailMessage email1;
            String managerEmailTemplatetoUse;
            String repEmailTemplatetoUse;
            String LeadOwnerId = l.OwnerId;
            String LeadsId = l.Id;
            
            //tsk.OwnerId =  l.OwnerId;                                                  //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            //tsk.WhoId = l.Id;                                                          //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created

            //This is where we get the manager Id
            Id managerId = ownerIdToManagerId.get(l.OwnerId);

            if(l.Dispensation_SLA_QL__c == 'Hot SLA In-policy')
            {
               // tsk.Subject = 'QL Hot Assigned: 24-hour outreach SLA in effect';       //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
               // tsk.ActivityDate = System.today().addDays(1);                          //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
                repEmailTemplatetoUse = etHot;
               // taskList.add(tsk);                                                     //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            }
            else if(l.Dispensation_SLA_QL__c == 'Warm SLA In-policy')
            {
               // tsk.Subject = 'QL Warm Assigned: 48-hour outreach SLA in effect';      //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
               // tsk.ActivityDate = System.today().addDays(2);                          //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
                repEmailTemplatetoUse = etWarm;
               // taskList.add(tsk);                                                     //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            }
            if(l.Dispensation_SLA_QL__c == 'Warm SLA Out-of-policy')
            {
                repEmailTemplatetoUse = repWarm2Day;
                if(managerId !=null)
                managerEmailTemplatetoUse = etWarm2day;
            }
            if(l.Conversion_SLA_QL__c == 'Warm SLA Out-of-policy')
            {
                repEmailTemplatetoUse = repWarm21Day;
                if(managerId !=null)
                managerEmailTemplatetoUse = etWarm21day;
            }
   
            if(l.Dispensation_SLA_QL__c == 'Hot SLA Out-of-policy')
            {
                repEmailTemplatetoUse = repWarm1Day;
                if(managerId !=null)
                managerEmailTemplatetoUse = etHot1day;
            } 
            if(l.Conversion_SLA_QL__c == 'Hot SLA Out-of-policy')
            {
                repEmailTemplatetoUse = repWarm14Day;
                if(managerId !=null)
                managerEmailTemplatetoUse = etHot14day;
            }

            OrgWideEmailAddress noreplyEmail = [select Id, DisplayName from OrgWideEmailAddress where Address = 'no_reply@alteryx.com' limit 1];
            String[] ccAddresses = new String[] {'marketingops@alteryx.com'};   

            //System.debug('nonreplyEmailId ' + noreplyEmailId + managerEmailTemplatetoUse + repEmailTemplatetoUse);
                
            if(managerEmailTemplatetoUse != null)
            {                  
                System.debug('inside sending to manager leadsla ' + managerId);
                email1 = Messaging.renderStoredEmailTemplate(managerEmailTemplatetoUse, LeadOwnerId, LeadsId);
                String email1Subject = email1.getSubject();
                String email1TextBody = email1.getPlainTextBody();
                email1.setTargetObjectId(managerId);
                email1.setSubject(email1Subject);
                email1.setPlainTextBody(email1TextBody);
                email1.setccAddresses(ccAddresses);
                if(noreplyEmail.Id != null)
                email1.setOrgWideEmailAddressId(noreplyEmail.Id);
                email1.saveAsActivity = false;
                allmsg.add(email1);
            }

            if(repEmailTemplatetoUse != null)
            {     
                email = Messaging.renderStoredEmailTemplate(repEmailTemplatetoUse, LeadOwnerId, LeadsId);
                String emailSubject = email.getSubject();
                String emailTextBody = email.getPlainTextBody();
                email.setTargetObjectId(LeadOwnerId);
                email.setSubject(emailSubject);
                email.setPlainTextBody(emailTextBody);
                email.setccAddresses(ccAddresses);
                if(noreplyEmail.Id != null)
                email.setOrgWideEmailAddressId(noreplyEmail.Id);
                email.saveAsActivity = false;
                allmsg.add(email);
            }    
            
        }
        
        //System.debug('inside lead sla queuable taskList ' + taskList);
        System.debug('inside lead sla queuable allmsg ' + allmsg);
        
        try 
        {
            //if(taskList.size()>0)    //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            //    insert taskList;     //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            if(!Test.isRunningTest())
                Messaging.sendEmail(allmsg,false);
        } 
        catch (Exception e) {
            System.debug(e.getMessage());
        }
    }	

}