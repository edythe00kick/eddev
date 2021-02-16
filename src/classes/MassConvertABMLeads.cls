global class MassConvertABMLeads implements Database.Batchable<sObject>
{
public String query;
  
    global Database.QueryLocator start(Database.BatchableContext BC)
    {

        query = 'SELECT Id,LeanData__Reporting_Matched_Account__c,isConverted,Ownerid,Status,Email,LD_Matched_Account_Owner__c,LD_Matched_ABM_Level__c from Lead where LeanData__Reporting_Matched_Account__c != NULL AND LD_Matched_Account_Owner__c != NULL AND LD_Matched_ABM_Level__c != NULL AND (LD_Matched_ABM_Level__c = \'Gold\' OR LD_Matched_ABM_Level__c = \'Silver\') AND LD_Matched_Account_Owner__c = \'Randy Clem\' AND isConverted = FALSE';
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<sObject> scope)
    {

        Map<String,String> leadId2LeadStatus              = new Map<String,String>();
        Map<String,String> leadId2LeadEmail               = new Map<String,String>();
        Map<String,String> leadId2ReportingMatchedAccount = new Map<String,String>();
        Map<String,Contact> contactEmail2Contact          = new Map<String,Contact>(); 
        Map<String,Contact> contactId2Contact             = new Map<String,Contact>(); 
        
        List<Database.LeadConvert> leadsToConvert = new List<Database.LeadConvert>();
        List<Database.LeadConvertResult> lcr;
        List<Contact> contacts2Update = new List<Contact>();
        
        List<Lead> leadsList = (List<Lead>)scope;
        
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];   
          
        
        for(Lead myLead : leadsList)
        {
             if(myLead.Status != NULL){
                   leadId2LeadStatus.put(myLead.id,myLead.status);
             } 
             if(myLead.Email != NULL){
                   leadId2LeadEmail.put(myLead.id,myLead.Email);
                   leadId2ReportingMatchedAccount.put(myLead.id,myLead.LeanData__Reporting_Matched_Account__c );
             } 
             
        }    
        
        for(Contact con : [select id,email,AccountId from Contact where email != NULL AND email in: leadId2LeadEmail.values() AND AccountId in: leadId2ReportingMatchedAccount.values() ORDER BY LastModifiedDate DESC]){
            if(!contactEmail2Contact.containsKey(con.email)){
                contactEmail2Contact.put(con.email,con);
                contactId2Contact.put(con.id,con);
            }
        }
        
         
         for(Lead myLead : leadsList)
         { 
             Database.LeadConvert ltc = new database.LeadConvert();
             ltc.setConvertedStatus(convertStatus.MasterLabel);
             ltc.setLeadId(myLead.Id);
             ltc.setAccountId(myLead.LeanData__Reporting_Matched_Account__c);
             ltc.setDoNotCreateOpportunity(true);
             if(myLead.Email != NULL && contactEmail2Contact.containsKey(myLead.Email)){
                 Contact cont = contactEmail2Contact.get(myLead.Email);
                 if(cont.Email == myLead.email && cont.AccountId == myLead.LeanData__Reporting_Matched_Account__c){
                     ltc.setContactId(contactEmail2Contact.get(myLead.Email).Id);
                 }
             }
             leadsToConvert.add(ltc);
             
         }
     
         if(!leadsToConvert.isEmpty()){
             lcr = Database.convertLead(leadsToConvert,false);
             
             if(lcr != NULL && !lcr.isEmpty()){
                 for (Database.LeadConvertResult res : lcr){
                        
                        if (!res.isSuccess()){
                            system.debug('Error in Lead Conversion ==>'+res);
                        }
                        else{
                             Contact c= new Contact(id=res.getContactId());
                             c.ABM_Sourced__c = true;
                             if(leadId2LeadStatus.containsKey(res.getLeadId())){
                                 c.Contact_Status__c = leadId2LeadStatus.get(res.getLeadId());
                             } 
                             c.Randy_Clem_Contact__c = TRUE;
                             contacts2Update.add(c); 
                        }
                        
                 }
             }
         }
         
         if(!contacts2Update.isEmpty()){
             Database.update(contacts2Update,false);
         }
         
         
    }   
    global void finish(Database.BatchableContext BC)
    { 
    }
}