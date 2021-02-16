/*
 * Author: Sharma Nemani 
 * Date: 03/27/2019
 * Description: Lead Util class for sending emails and creating tasks for PDG Workflow Rules.
 */
public class  LeadUtil{
    Public Static Boolean runOnce = true;
	// Method to send emails and create tasks from Lead
	// Parameters: Map of Id, String(to check if its for Hot or Warm) and Map of Lead new map 
    public static void leadTaskandEmail(Map<String, List<Lead>> leadTaskEmailMap, List<lead> leadList){
        Set<Id> userIds = new Set<Id>();
        Map<Id, User> userMap = new Map<Id, User>();
        List<Task> taskList = new List<Task>();
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        Set<String> emailTemplateName = new Set<String>{'Lead_Hot_SLA_Date_Template_24_hours_Email', 'Lead_Warm_SLA_Date_Template_48_hours_Email', 'Lead_Dispensation_SLA_Warm_2_Days_Email', 'Lead_Conversion_SLA_Warm_21_Days_Email', 'Lead_Dispensation_SLA_Hot_1_Day_Email', 'Lead_Conversion_SLA_Hot_14_Days_Email'};
		String etHot = '';
        String etWarm = '';
        String etWarm2day = '';
        String etWarm21day = '';
        String etHot1day = '';
        String etHot14day = '';
        for(List<Lead> ldList : leadTaskEmailMap.values())
            for(Lead ld : ldList)
            	userIds.add(ld.OwnerId);
        
        if(userIds.size()>0){
            userMap =  new Map<Id, User>([SELECT Id, ManagerId FROM User WHERE Id IN: userIds]);
        }
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
        }
		//Iterate over the Lead map and create the tasks and emails

        for(String emailfor : leadTaskEmailMap.keySet()){
            for(Lead ldId : leadTaskEmailMap.get(emailfor)){
                Task tsk = new Task();
                Messaging.SingleEmailMessage email;
                Messaging.SingleEmailMessage email1;
                String emailTemplatetoUse = '';
                String LeadOwnerId = ldId.OwnerId;
                String LeadsId = ldId.Id;
                
                tsk.OwnerId =  ldId.OwnerId;
                tsk.WhoId = ldId.Id;
                if(emailfor == 'HOT'){
                    tsk.Subject = 'QL Hot Assigned: 24-hour outreach SLA in effect';
                    tsk.ActivityDate = System.today().addDays(1); 
                    emailTemplatetoUse = etHot;
                    taskList.add(tsk);
                }else if(emailfor == 'WARM'){
                    tsk.Subject = 'QL Warm Assigned: 48-hour outreach SLA in effect';
                    tsk.ActivityDate = System.today().addDays(2);
                    emailTemplatetoUse = etWarm;
                    taskList.add(tsk);
                }
                if(emailfor == 'WARM2DAY')
                    emailTemplatetoUse = etWarm2day;
                
                if(emailfor == 'WARM21DAY')
                    emailTemplatetoUse = etWarm21day;
                    
                if(emailfor == 'HOT1DAY')
                    emailTemplatetoUse = etHot1day;
                   
                if(emailfor == 'HOT14DAY')
                    emailTemplatetoUse = etHot14day;
                    
                if(userMap.containsKey(LeadsId) && userMap.get(LeadsId).ManagerId!= null){
                    email1 = Messaging.renderStoredEmailTemplate(emailTemplatetoUse, LeadOwnerId, LeadsId);
                    String email1Subject = email1.getSubject();
                    String email1TextBody = email1.getPlainTextBody();
                    email1.setTargetObjectId(userMap.get(LeadOwnerId).ManagerId);
                    email1.setSubject(email1Subject);
                    email1.setPlainTextBody(email1TextBody);
                    email1.saveAsActivity = false;
                    allmsg.add(email1);
                }
                
                email = Messaging.renderStoredEmailTemplate(emailTemplatetoUse, LeadOwnerId, LeadsId);
                String emailSubject = email.getSubject();
                String emailTextBody = email.getPlainTextBody();
                email.setTargetObjectId(LeadOwnerId);
                email.setSubject(emailSubject);
                email.setPlainTextBody(emailTextBody);
                email.saveAsActivity = false;
                allmsg.add(email);
            }
        }
        
        try {
            runOnce = false;
            if(taskList.size()>0)
                insert taskList;
            if(leadList.size()>0)
                update leadList;
            if(!Test.isRunningTest())
                Messaging.sendEmail(allmsg,false);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }	

    }
        
}