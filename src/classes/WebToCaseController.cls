global class WebToCaseController {
    public Case c {get; set;}
    public boolean isThankyou {get;set;}
    public String contactName {get; set;}
    public String contactPhone {get; set;}
    public String caseId {get;set;}
    public list<SelectOption> businessSystem;
    public list<SelectOption> businessSystemCategory;
    public String contactEmail{get;set;}
    public Attachment anAttachment { get; set; }
    public static boolean isAttachment {get;set;}
    public string userAgent {get;set;}
    public Boolean isIE{get;set;}
    public Boolean isCaseCreated{get;set;}
    public boolean email_error;
    
    public WebToCaseController() {
        isCaseCreated = apexPages.currentPage().getParameters().get('c') == null ?  true : false;
        
        if(!test.isRunningTest()){
        userAgent = ApexPages.CurrentPage().getHeaders().get('USER-AGENT');
        Integer ieIndex = userAgent.indexOf('MSIE');
        }
        isAttachment = false;
        this.anAttachment = new Attachment();
        isThankyou = false;
        contactName = 'Contact Name';
        contactPhone = 'Contact Phone';
        c = new Case();
        c.RecordTypeId = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('Business Systems Support Ticket').getRecordTypeId();
        c.WebToCasePage__c = true;
        //c.OwnerId = Label.WebToCaseOwnerId;
    }
    
    public Pagereference searchContact(){
        email_error = false; 
        List<Contact> con = [SELECT Id, Name, Phone FROM Contact WHERE Email = :contactEmail and Email!= null and Email!='' ORDER BY CreatedDate ASC];
        if(contactEmail == '' || contactEmail == null){
            email_error = true;
        }else if(!contactEmail.toLowerCase().contains('@alteryx.com')){
            email_error = true;
        }else if(con.size() > 1){
            email_error = true;
        }else if(con.size() == 0 && con.isEmpty()){
             email_error = true;
        }
        else If(con.size() == 1){
        contactName = con.get(0).Name;
        contactPhone = con.get(0).Phone;
        c.contactId = con.get(0).id;
        }
        If(email_error == true){
            contactName = 'Contact Name';
            contactPhone = 'Contact Phone';
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'It is either your email address is wrong or your contact record does not exist in Alteryx\'s contact database. Please reach out to your manager to have your contact record added by the Enterprise Applications team'));
            return null;
        }
        return null;
    } 
    

    
    public Pagereference attachment(){
        boolean hasError = false;
        if((contactEmail == '') || (c.subject == null || c.subject == '') || (c.Description == null || c.Description == '') || (c.Business_System__c  == null) || (c.Business_System_Category__c == null) || (c.Requested_Completion_Date__c == null)) {
            
            hasError = true;
            return null;
            }
            
        return null;
    }
    
    public PageReference save(){
        searchContact();
        if(!email_error){
            try {
                boolean hasError = false;
                /*if(contactEmailonsave == '') {
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'It is either your email address is wrong or your contact record does not exist in Alteryxs contact database. Please reach out to your manager to have your contact record added by the Enterprise Applications team'));
                    hasError = true;
                }*/
                
                if(c.subject == null || c.subject == ''){
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Subject: You must enter a value'));
                    hasError = true;
                }
                
                if(c.Description == null || c.Description == '' ){
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Description: You must enter a value'));
                    hasError = true;
                }
                
                if(c.Business_System__c  == null){
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enterprise Application: You must enter a value'));
                    hasError = true;
                }
                
                if(c.Business_System_Category__c == null ){
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Enterprise Application Category: You must enter a value'));
                    hasError = true;
                }
                
                /* Commented out from Enterprise System Enhancement - JPH - 20180713
                if(c.Requested_Completion_Date__c == null){
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Requested Completion Date: You must enter a value'));
                    hasError = true;
                } 
                
                if(c.Requested_Completion_Date__c != null && c.Requested_Completion_Date__c <= Date.today()){
                
                    hasError = true;
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Requested Completion Date must be a Future Date.')); 
                }*/
              
                if(hasError){
                    contactName = 'Contact Name';
                    contactPhone = 'Contact Phone';
                    c.Business_System__c = null;
                    c.Subject = null;
                    c.Description = null;
                    c.Requested_Completion_Date__c = null;
                    return null;
                }
                c.businessHoursId = System.Label.WebToCaseBusinessHoursId;
                // Creating the DMLOptions for "Assign using active assignment rules" checkbox
                // W-004416 - JPH - 2020-02-10
                Database.DMLOptions dmlOpts = new Database.DMLOptions();
                dmlOpts.assignmentRuleHeader.useDefaultRule= true;
                
                c.setOptions(dmlOpts);
                insert c; 
                caseId = c.id;
                system.debug('@@-->>'+this.anAttachment);
                 
                if( this.anAttachment.Name <> NULL && this.anAttachment.Body <> NULL ){
                        
                    anAttachment.ParentId = c.Id;
                    anAttachment.IsPrivate = false;
                    try { 
                        insert anAttachment;
                    } 
                    catch(DMLException e) { ApexPages.addMessage(new Apexpages.Message(ApexPAges.Severity.ERROR, e.getMessage())); return null; }
                    finally { anAttachment = new Attachment();}
                }
                  
                if(c.id != null){
                 
                   pagereference pr = new PageReference('/apex/WebToCase?c=true');
                   pr.setRedirect(true);
                   return pr;
                }
                 
            }
                
            catch(Exception ex) {
                Exception cause = ex.getCause();
                String msg = cause != null ? cause.getMessage() : ex.getMessage();
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, msg));
                return null;
            }
       
            isThankyou = true;
        }
        else
            return null; 
        
        return null;
    }
    
    public pagereference reset(){
        PageReference pageRef = Page.WebToCase;
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    Public Pagereference cancel(){
        return New Pagereference('/apex/WebToCase'); 
    }
            
}