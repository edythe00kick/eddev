global class BatchUpdatePartnerAccountLookupField 
        implements Database.Batchable<sObject>, Database.Stateful {
    
    global Set<String> opp_Ids;
    
    global BatchUpdatePartnerAccountLookupField() {
        opp_Ids = new Set<String>();
    }
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        
        String query = 'SELECT Id, OpportunityId, AccountToId FROM Partner'
            + ' WHERE isPrimary = true'
            + ' AND Opportunity.Partner_Account_Lookup__c = null';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Partner> scope) {
        
        List<Opportunity> opps_to_update = new List<Opportunity>();
        
        for(Partner ptnr : scope) {
            
            Opportunity opp = new Opportunity();
            opp.Id = ptnr.OpportunityId;
            opp.Partner_Account_Lookup__c = ptnr.AccountToId;
            opps_to_update.add(opp);
            
        }
        
        if(!opps_to_update.isEmpty()) {
            
            Database.SaveResult[] srList = Database.update(opps_to_update, false);
            
            for(integer i = 0; i < srList.size(); i++) {
                if(!srList.get(i).isSuccess()) {
                    System.debug('>>>> update failed on opp: ' + opps_to_update.get(i).Id);
                    opp_Ids.add(opps_to_update.get(i).Id);
                }
            }
            
        }
        
    }
    
    global void finish(Database.BatchableContext bc) {
        
        // Get the ID of the AsyncApexJob representing this batch job
        // from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed,
            TotalJobItems, CreatedBy.Email
            FROM AsyncApexJob WHERE Id =
            :BC.getJobId()];
        // Send an email to the Apex job's submitter notifying of job completion.
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'oshink@grazitti.com'};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Batch class status ' + a.Status);
        String mailBody = 'The batch Apex job processed ' + a.TotalJobItems 
                + ' batches with '+ a.NumberOfErrors + ' failures.'
                + '\n\nList of failed records\n';
        for(String rec_id : opp_Ids) {
            mailBody += rec_id + '\n';
        }
        mail.setPlainTextBody(''+ mailBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        
    }
    
}