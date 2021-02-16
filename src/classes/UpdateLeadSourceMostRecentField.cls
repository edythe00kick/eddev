global class UpdateLeadSourceMostRecentField  implements Database.Batchable<sObject>,Database.Stateful{
        global List<CampaignMember>  campaigns_to_mail;
        
        global UpdateLeadSourceMostRecentField() {
            campaigns_to_mail = new List<CampaignMember>();
        }
    global Database.QueryLocator start(Database.BatchableContext BC){
       string query='SELECT Id, LeadId, Lead.isConverted, ContactId, Contact.Contact_Source_Most_Recent__c, Lead.Lead_Source_Most_Recent__c, Lead_Source_Most_Recent__c, Lead.Most_Recent_Campaign_ID__c, Contact.Most_Recent_Campaign_ID__c, CampaignId  FROM CampaignMember WHERE hasResponded = true AND (( Lead.Lead_Source_Most_Recent__c != null AND Lead.Most_Recent_Campaign_ID__c  != null AND Lead.isConverted = false AND Lead.CreatedDate >= 2016-01-28T00:00:00.000Z) OR ( Contact.Contact_Source_Most_Recent__c != null AND Contact.Most_Recent_Campaign_ID__c  != null AND Contact.CreatedDate >= 2016-01-28T00:00:00.000Z))'; 
       return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<CampaignMember> scope) {
        List<CampaignMember>  campaign_to_update = new List<CampaignMember>();
       
        for(CampaignMember cm : scope) {
             if(cm.Lead_Source_Most_Recent__c != cm.Contact.Contact_Source_Most_Recent__c && cm.CampaignId == cm.Contact.Most_Recent_Campaign_ID__c)
            {
                campaigns_to_mail.add(cm);
            }

            else if(cm.Lead_Source_Most_Recent__c != cm.Lead.Lead_Source_Most_Recent__c && cm.CampaignId == cm.Lead.Most_Recent_Campaign_ID__c)
            {
                if(cm.Lead.isConverted==false)
                {
                campaigns_to_mail.add(cm);
                }
            }

        }
        
    }
    
    global void finish(Database.BatchableContext BC){
        String csv_file = 'Lead:Id, Lead:Lead Source - Most Recent, Lead:Most Recent Campaign ID, Contact:Id, Contact:Contact Source - Most Recent, Contact:Most Recent Campaign Id, Campaign Member:Id, Campaign Member: Campaign Id,Campaign Member: Channel\n';
        
        for(campaignMember cm: campaigns_to_mail)
        {
            csv_file += cm.LeadId + ',' + cm.Lead.Lead_Source_Most_Recent__c + ',' + cm.Lead.Most_Recent_Campaign_ID__c + ','+ cm.ContactId + ',' + cm.Contact.Contact_Source_Most_Recent__c + ',' + cm.Contact.Most_Recent_Campaign_ID__c +',' + cm.Id + ',' + cm.CampaignId +','+ cm.Lead_Source_Most_Recent__c + '\n';
        }
        System.debug('>>>> Ready to send email');
          
        String email_subject = 'csv file for leads';
        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        Blob attachment_body = Blob.valueOf(csv_file);
        attachment.setFileName(email_subject);
        attachment.setBody(attachment_body);

        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        String[] toAddresses = new list<string> {'sandeeps@grazitti.co.uk'};
        email.setSubject(email_subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody(email_subject);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{attachment});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
     
    }       
}