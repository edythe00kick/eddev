global class DisableContactInSandboxLoader implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
    //
    // query string is set in either the DisableContactInSandboxScheduler.cls 
    //
    public string query;

    //==============================================================================         
    // Implementation of the Database.Batchable interface. 
    //==============================================================================     
    // The "Start" method is where you setup any variables used in the query string in the ScheduledDataCleanupScheduler/ScheduledDataCleanupButton class
    // and the return query.
    // 
    global database.querylocator start(Database.BatchableContext BC) 
    { 
         return Database.getQueryLocator(query); 
    } 

    //
    // Execute class will be called with N number of 
    //
    global void execute(Database.BatchableContext BC, List<Contact> scope) 
    { 
        //
        // Add stage to end of the email address so that emails are not sent from sandbox to contacts
        //
        for (Contact x: scope) {
            x.Email = x.Email + 'staged';
        }
        database.update(scope);
    } 

    //
    // After all batches have been processed, final work that needs to be done
    //
    global void finish(Database.BatchableContext BC) 
    { 
        { 
            //processOpps.CleanLeadFinalMethod(); 
        } 
    } 
}