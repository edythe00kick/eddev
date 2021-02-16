public class LeadProcessController{

    public Flow.Interview.AskOpportunityCreation myFlow {
        get;
        set;
    }

    public String country {get;set;}
    public String leadId {get;set;}
    public String profileName {get;set;}
    public Boolean displayVal {get;set;}
    
    //public String city {get;set;}
    //public Decimal annualrevenue {get;set;}
    //public String annualrevenue {get;set;}
    //public String postalcode {get;set;}
    
    public String getmyID() {
        if (myFlow == null) return '';
        else return myFlow.CreateOppty;
    }

    public LeadProcessController(ApexPages.StandardController controller) {
        Profile p = [select id,name from profile where id =:UserInfo.getProfileId()];
        profileName = p.name;
        Lead l = [select id,country,annualrevenue,city,postalcode from lead where id =: apexpages.currentpage().getparameters().get('id')];
        if(l.country != NULL){
            country = l.country;
        }
        else{
            country = '';
        }
        /*if(l.annualrevenue != NULL){
            annualrevenue = String.valueOf(l.annualrevenue);
        }
        else{
            annualrevenue = '';
        }
        if(l.postalcode != NULL){
            postalcode = l.postalcode;
        }
        else{
            postalcode = '';
        }
        if(l.city != NULL){
            city= l.city;
        }
        else{
            city= '';
        }*/
         
        leadId = l.id;
        displayVal = false;

    }
    
    
    public PageReference getRenderVariable() {
       // displayVal = false;
       system.debug('displayval is===============>'+displayVal);
       system.debug('Parameter is===============>'+apexpages.currentpage().getparameters().get('q'));
       return null;
    }
    
    public PageReference getOID() {
        //string returl='/apex/ReCreateOpportunityUsingAdvancedFlow?accid='+getmyID()+'%26tis%3D'+getmyID();
        // string returl='/apex/AttachPartner?OppId='+getmyID();
        
           PageReference reference = new PageReference('/apex/leadConvertPage?id=' + apexpages.currentpage().getparameters().get('id') );
           reference.setRedirect(true);
           return reference;
    }

}