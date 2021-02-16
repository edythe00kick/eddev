public class EducationalLicenseRequestPageController {
    public Evaluation_License_Request__c elr{get; set;}
    public String licenseType {get; set;}
    public boolean showEditPage {get; set;}
    
    public EducationalLicenseRequestPageController (ApexPages.StandardController stdController) {
        elr = new Evaluation_License_Request__c();
        licenseType = 'Educational License';
        
        if(ApexPages.currentPage().getParameters().get('AccntID')!='' || ApexPages.currentPage().getParameters().get('AccntID')!=Null){
           elr.Account__c = ApexPages.currentPage().getParameters().get('AccntID');
           elr.Ship_Physical_Drive_for_Data__c = 'Yes';
           // Assign Educational License Record Type
           elr.RecordTypeId = Evaluation_License_Request__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Educational License Record Type').getRecordTypeId();
        }
    }
    
    public void setLicenseToEdit() {
        if(licenseType.equals('Educational License')) {
            // Assign Educational License Record Type
            elr.RecordTypeId = Evaluation_License_Request__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Educational License Record Type').getRecordTypeId();
        } else if(licenseType.equals('NFR License')) {
            // Assign NFR License Record Type
            elr.RecordTypeId = Evaluation_License_Request__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('NFR License Record Type').getRecordTypeId();
        }
    }
    
     // Returns names of License Types
    public List<SelectOption> getLicenseTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Educational License', 'Educational License'));
        options.add(new SelectOption('NFR License', 'NFR License'));
        return options;
    }
    
    public PageReference save() {
        PageReference destination = null;
        Contact con = [SELECT Id, Email from Contact WHERE Id = :elr.Contact__c LIMIT 1];
        
        if(con.Email != null && !con.Email.contains('.edu')) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please ensure that Contact\'s email contains .edu'));
        }else if(Date.today().daysBetween(elr.Expiration_Date__c) > 180 || Date.today().daysBetween(elr.Expiration_Date__c) < 0) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Please ensure that Expiration Date falls within 180 days from today.'));
        } else {
            try {
                insert elr;
                destination = new PageReference('/' + elr.id);
                destination.setRedirect(true);
            } 
            catch(DMLException ex) { ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error inserting the record')); } 
            catch(Exception ex) { ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Due to some error the operation couldn\'t be performed')); }
        }
        return destination;
    }
    
    public PageReference cancel() {
        PageReference accPage = new PageReference('/' + elr.Account__c);
        accPage.setRedirect(true);
        return accPage;
    }
}