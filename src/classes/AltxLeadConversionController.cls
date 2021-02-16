public class AltxLeadConversionController {    
    @AuraEnabled
    public static string getstringOfName(string LeadId){
        system.debug('lead id @@ '+LeadId);
        List<Lead> ld = [select id, Name, Lead_ID__c, Company, Partner_Representative__r.Name, Partner_Account__c, owner.name, owner.email from Lead where id =: LeadId Limit 1];
        system.debug('Lead query is '+ld);
       
        Database.DmlOptions options = new Database.DmlOptions();
        options.emailHeader.triggerUserEmail = true;
        Database.update(ld, options);
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();     
        System.debug('Owner  mailId = = = '+ ld[0].owner.email);       
        String[] toAddresses = new String[] {ld[0].owner.email};   
            String currLeadURL = System.Label.Alteryx_CommunityStartUrl +'/'+ ld[0].Id ; 
        
        System.debug('URL********'+currLeadURL );
        String msgBody = 'Hi ' + ld[0].owner.name + ', <br /><br />A request to convert this lead record was submitted by "' + ld[0].Partner_Account__c +'".<br></br> <br></br> Name : ' + ld[0].Name + '<br></br> Company : ' + ld[0].Company + '<br></br> Partner Representative : ' + ld[0].Partner_Representative__r.Name;
        msgBody +=  '<br></br> Partner Account : ' + ld[0].Partner_Account__c + '<br></br> Lead Link : ' + '<a href="' +currLeadURL + '">' + currLeadURL + '</a>';     
        mail.setToAddresses(toAddresses);          
        
        mail.setSubject('Request to Convert Lead : '+ ld[0].Lead_ID__c);        
        mail.setBccSender(false);        
        mail.setUseSignature(false);        
        
        mail.setHtmlBody(msgBody);        
        system.debug('mail is @@ '+mail);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return ld[0].owner.name;
    }
}