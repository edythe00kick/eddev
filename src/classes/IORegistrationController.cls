//class is used to save registration form in a Lead record
public without sharing class IORegistrationController {
    @AuraEnabled
    public static String save(Lead myLead){//method to save lead during registration for guest user     
        string errorMsg='';
        system.debug(mylead.Phone);
        mylead.Partner_User_Requested_Lead__c = true;
        myLead.LeadSource = 'Partner Generated';
        myLead.RecordTypeId = label.Altx_Partner_Lead_Record_Type_Id;
        myLead.OwnerId = UserInfo.getUserId();
        
        //Show Error if lead aleady exists
        List<Lead> LeadtList = [select id from Lead where email =: myLead.Email and isConverted = false];
        if(LeadtList.size() > 0){
            //errorMsg='This email address already exists. Please email channels@alteryx.com if you should have any questions.';
            if(!test.isRunningTest())
                return errorMsg; 
        }
              
        try{
            insert myLead;
            return '';
        }
        catch (Exception ex) {
            if(ex.getMessage().contains('INVALID_EMAIL_ADDRESS')){
                errorMsg='Please Provide Valid Email Address';
                return errorMsg;  
            }
            return ex.getMessage(); 
        }
    }    
}