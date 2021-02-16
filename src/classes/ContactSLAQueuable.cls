/* Sharma Nemani | PDG Workflow Rules.
     * Date: 03/27/2019
    // Description: Method to fetch email templates, send emails and create task from contact*/
public without sharing class ContactSLAQueuable implements Queueable {

    public Map<Id, Contact> contactIdToContactMap;

    public ContactSLAQueuable(Map<Id, Contact> contactIdToContactMap) {
        this.contactIdToContactMap = contactIdToContactMap;
        
    }

    public void execute(QueueableContext context) {
        RecursionHandler.IsContactSLAQueuableExecuted = true; 
         System.debug('inside executeContactSLQTaskAndEmail queuable ' +contactIdToContactMap);

        Set<Id> userIds = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();
        Map<Id, Id> ownerIdToManagerId = new Map<Id, Id>();
        //List<Task> taskList = new List<Task>();            //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Set<String> emailTemplateName = new Set<String>{'Contact_Hot_SLA_Date_Template_24_hours_Email', 'Contact_Warm_SLA_Date_Template_48_hours_Email', 'Contact_Dispensation_SLA_Warm_2_Days_Email', 'Contact_Conversion_SLA_Warm_21_Days_Email', 'Contact_Dispensation_SLA_Hot_1_Day_Email', 'Contact_Conversion_SLA_Hot_14_Days_Email',
        'Rep_Contact_Dispensation_SLA_Warm_2_Days_Email', 'Rep_Contact_Conversion_SLA_Warm_21_Days_Email', 'Rep_Contact_Dispensation_SLA_Hot_1_Day_Email', 'Rep_Contact_Conversion_SLA_Hot_14_Days_Email'};
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

        for(Contact c : contactIdToContactMap.values())
        {
            userIds.add(c.OwnerId);
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
            if(etlist.DeveloperName == 'Contact_Hot_SLA_Date_Template_24_hours_Email'){
                etHot = etList.Id;
            }else if(etlist.DeveloperName == 'Contact_Warm_SLA_Date_Template_48_hours_Email'){
                etWarm = etList.Id;
            }else if(etlist.DeveloperName == 'Contact_Dispensation_SLA_Warm_2_Days_Email'){
                etWarm2day = etList.Id;
            }else if(etlist.DeveloperName == 'Contact_Conversion_SLA_Warm_21_Days_Email'){
                etWarm21day = etList.Id;
            }else if(etlist.DeveloperName == 'Contact_Dispensation_SLA_Hot_1_Day_Email'){
                etHot1day = etList.Id;
            }else if(etlist.DeveloperName == 'Contact_Conversion_SLA_Hot_14_Days_Email'){
                etHot14day = etList.Id;
            }
            else if(etlist.DeveloperName == 'Rep_Contact_Dispensation_SLA_Warm_2_Days_Email'){
                repWarm2Day = etList.Id;
            }else if(etlist.DeveloperName == 'Rep_Contact_Conversion_SLA_Warm_21_Days_Email'){
                repWarm21Day = etList.Id;
            }else if(etlist.DeveloperName == 'Rep_Contact_Dispensation_SLA_Hot_1_Day_Email'){
                repWarm1Day = etList.Id;
            }else if(etlist.DeveloperName == 'Rep_Contact_Conversion_SLA_Hot_14_Days_Email'){
                repWarm14Day = etList.Id;
            }
        }
		//Iterate over the Contact map and create the tasks and emails

        System.debug('email templates  ' +etHot + ' ' +etWarm + ' ' +etWarm2day + ' ' +etWarm21day + ' ' +etHot1day + ' ' +etHot14day);

        for(Contact c : contactIdToContactMap.values())
        {
            System.debug('inside Contact sla queuable loop' + c);
            //Task tsk = new Task();                                                  //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            Messaging.SingleEmailMessage email;
            Messaging.SingleEmailMessage email1;
            String managerEmailTemplatetoUse;
            String repEmailTemplatetoUse;
            String ContactOwnerId = c.OwnerId;
            String ContactsId = c.Id;
            
            //tsk.OwnerId =  c.OwnerId;                                               //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            //tsk.WhoId = c.Id;                                                       //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created

            //This is where we get the manager Id
            Id managerId = ownerIdToManagerId.get(c.OwnerId);

            if(c.Dispensation_SLA_QL__c == 'Hot SLA In-policy')
            {
                //tsk.Subject = 'QL Hot Assigned: 24-hour outreach SLA in effect';    //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
                //tsk.ActivityDate = System.today().addDays(1);                       //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
                repEmailTemplatetoUse = etHot;
                //taskList.add(tsk);                                                  //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            }
            else if(c.Dispensation_SLA_QL__c == 'Warm SLA In-policy')
            {
                //tsk.Subject = 'QL Warm Assigned: 48-hour outreach SLA in effect';   //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
                //tsk.ActivityDate = System.today().addDays(2);                       //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
                repEmailTemplatetoUse = etWarm;
                //taskList.add(tsk);                                                  //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            }
            if(c.Dispensation_SLA_QL__c == 'Warm SLA Out-of-policy')
            {
                repEmailTemplatetoUse = repWarm2Day;
                if(managerId !=null)
                managerEmailTemplatetoUse = etWarm2day;
            }
                            
            if(c.Conversion_SLA_QL__c == 'Warm SLA Out-of-policy')
            {
                repEmailTemplatetoUse = repWarm21Day;
                if(managerId !=null)
                managerEmailTemplatetoUse = etWarm21day;
            }
                               
            if(c.Dispensation_SLA_QL__c == 'Hot SLA Out-of-policy')
            {
                repEmailTemplatetoUse = repWarm1Day;
                if(managerId !=null)
                managerEmailTemplatetoUse = etHot1day;
            }
                              
            if(c.Conversion_SLA_QL__c == 'Hot SLA Out-of-policy')
            {
                repEmailTemplatetoUse = repWarm14Day;
                if(managerId !=null)
                managerEmailTemplatetoUse = etHot14day;
            }
                

            Id noreplyEmailId = [select Id from OrgWideEmailAddress where Address = 'no_reply@alteryx.com' limit 1].Id;
            System.debug('nonreplyEmailId ' + noreplyEmailId + managerEmailTemplatetoUse + repEmailTemplatetoUse);
            String[] ccAddresses = new String[] {'marketingops@alteryx.com'};  
            
            if(managerEmailTemplatetoUse != null)
            {                  
                System.debug('inside sending to manager contactsla ' + managerId);
                email1 = Messaging.renderStoredEmailTemplate(managerEmailTemplatetoUse, ContactOwnerId, ContactsId);
                String email1Subject = email1.getSubject();
                String email1TextBody = email1.getPlainTextBody();
                email1.setTargetObjectId(managerId);
                email1.setSubject(email1Subject);
                email1.setPlainTextBody(email1TextBody);
                email1.setccAddresses(ccAddresses);
                if(noreplyEmailId != null)
                email1.setOrgWideEmailAddressId(noreplyEmailId);
                email1.saveAsActivity = false;
                allmsg.add(email1);
            }

            if(repEmailTemplatetoUse != null)
            {     
                email = Messaging.renderStoredEmailTemplate(repEmailTemplatetoUse, ContactOwnerId, ContactsId);
                String emailSubject = email.getSubject();
                String emailTextBody = email.getPlainTextBody();
                email.setTargetObjectId(ContactOwnerId);
                email.setSubject(emailSubject);
                email.setPlainTextBody(emailTextBody);
                email.setccAddresses(ccAddresses);
                if(noreplyEmailId != null)
                email.setOrgWideEmailAddressId(noreplyEmailId);
                email.saveAsActivity = false;
                allmsg.add(email);
            }    
            
        }
        
        //System.debug('inside Contact sla queuable taskList ' + taskList);
        System.debug('inside Contact sla queuable allmsg ' + allmsg);
        
        try 
        {
            //if(taskList.size()>0)                     //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            //    insert taskList;                      //Eddie Wong || 04/27/2020 || W-005127 || To comment out so task doesn't get created
            if(!Test.isRunningTest())
                Messaging.sendEmail(allmsg,false);
        } 
        catch (Exception e) {
            System.debug(e.getMessage());
        }
    }	

}