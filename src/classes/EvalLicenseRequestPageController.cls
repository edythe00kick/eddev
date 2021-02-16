public class EvalLicenseRequestPageController {
    public Evaluation_License_Request__c elr{get; set;}
    public Boolean showEvalPage {get; set;}
    public String errorMessage {get; set;}
    
    public EvalLicenseRequestPageController(ApexPages.StandardController stdController) {
        showEvalPage = true;
        errorMessage = 'Evaluation License Request can\'t be created from ';
        
        elr = new Evaluation_License_Request__c();
        elr.Opportunity__c = ApexPages.currentPage().getParameters().get('oppId');
        Opportunity opp = [SELECT StageName FROM Opportunity WHERE Id = :ApexPages.currentPage().getParameters().get('oppId') LIMIT 1];
        if(opp.StageName == System.label.StageName_F || opp.StageName == 'Closed Lost' || opp.StageName == 'Disqualified') {
            showEvalPage = false;
            errorMessage += 'a Closed/Disqualified Opportunity';
        }
        // elr.RecordTypeId = Evaluation_License_Request__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Evaluation License Record Type').getRecordTypeId();
    }
    
    public PageReference save() {
        PageReference destination = null;
        boolean flag1 = false;
        
        List<OpportunityContactRole> ocrs = new List<OpportunityContactRole>();
        for(OpportunityContactRole ocr : [SELECT ContactId  FROM OpportunityContactRole WHERE OpportunityId=:elr.Opportunity__c]) {
            ocrs.add(ocr);
        }
        
        if(!ocrs.isEmpty()) {
            for(OpportunityContactRole ocr : ocrs) {
                if(ocr.ContactId == elr.Contact__c) {
                    flag1 = true;
                }
            }
        }
        
        if(flag1 == false) {
            Contact con = [SELECT AccountId FROM Contact WHERE Id=:elr.Contact__c LIMIT 1];
            if(con.AccountId != ApexPages.currentPage().getParameters().get('AccountID')) {
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'The Contact selected is neither one of Contact Roles nor is related to Account'));
                return null;
            }
        }
        
        try {
            insert elr;
            System.debug('denis elr.Ship_Physical_Drive_for_Data__c: ' + elr.Ship_Physical_Drive_for_Data__c);
            if(elr.Ship_Physical_Drive_for_Data__c == 'Yes') {
                destination = new PageReference('/apex/ContactMailingAddressPage?id=' + elr.Contact__c + '&elrid=' + elr.Id);
                destination.setRedirect(true);
                return destination;
            } else {
                destination = new PageReference('/' + elr.id);
                destination.setRedirect(true);
                return destination;
            }
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error inserting the record'));
        }
        return destination;
    }
    
    public PageReference cancel() {
        PageReference oppPage = new PageReference('/' + elr.Opportunity__c);
        oppPage.setRedirect(true);
        return oppPage;
    }
}