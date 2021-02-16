Global class DisableContactInSandboxScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {
        DisableContactInSandboxLoader myLoader = new DisableContactInSandboxLoader();
        //
        // Query for settings
        //
        myLoader.query = 'select Id, Email FROM Contact where Email != null';
        
        //
        // determine if code is executing in Production - if so, then skip - don't every run in production
        //
        string myURL = System.URL.getSalesforceBaseURL().getHost();
        if (myURL == 'alteryx.my.salesforce.com') {
            system.debug('****Do Not Execute in Production ******** myURL: '+ myURL);           
        } else {
            ID batchprocessid = Database.executeBatch(myLoader,200);  // <- set to the rows to process in the batch 
        }
        
    }
}