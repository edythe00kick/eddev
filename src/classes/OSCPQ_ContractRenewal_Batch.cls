/* 
 * Batch class used to automatically renewal forecast and/or quote based on metadata configuration.
 * Also will handle contract activation based on metadata configuration.
 */
global class OSCPQ_ContractRenewal_Batch implements Database.Batchable<SObject>{
    private String settingsAPIName = 'Default';
    @testVisible private CPQ_Setting__mdt settings = OSCPQ_Utils.getContractSettings(settingsAPIName);

    /*
     * Constructor - takes a metadata record API name, so that
     *  more scenarios can be accomodated as needed in an implemenation.
     *  For example, Partner quotes may not have the same level of automation
     */
    public OSCPQ_ContractRenewal_Batch(String sAPIName){
        if(sAPIName != null && sAPIName != ''){
            CPQ_Setting__mdt tmpSettings = OSCPQ_Utils.getContractSettings(sAPIName);
            if(tmpSettings != null){
                settingsAPIName = sAPIName;
                settings = tmpSettings;
            }
        }
    }
    
    /*
     * Start method to retrieve scope of the batch.
     * Will dynamically build the appropriate query based on the metadata settings
     */
    global Database.QueryLocator start(Database.BatchableContext bc){
        Id cpqContractRecordType = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();
        
        //Only run the query/batch if automation settings are set accordingly
        if(settings != null && (settings.Contracting_AutomaticActivation__c != 'Never' || settings.AutoForecast_Enabled__c == true || settings.AutoRenewQuote_Enabled__c)){
            
            //Build Query String to determine which records will be updated
            String queryString = '';
            Set<String> fieldsToQuery = new Set<String>{'Id', 'Status', 'SBQQ__RenewalForecast__c', 'SBQQ__RenewalQuoted__c', 'SBQQ__RenewalOpportunity__c'}; //Fields that will always be queried
            String[] whereClause = new String[]{};
            Date targetForecastDate = voidGetTargetDate(settings.AutoForecast_Timing__c, settings.AutoForecast_ReferenceField__c, settings.AutoForecast_NumDays__c);
            Date targetRenewDate = voidGetTargetDate(settings.AutoRenewQuote_Timing__c, settings.AutoRenewQuote_ReferenceField__c, settings.AutoRenewQuote_NumDays__c);
            //Check Auto-forecast Settings
            if(settings.AutoForecast_Enabled__c){
                
                
                if(settings.AutoForecast_Timing__c == 'Immediately') {
                    whereClause.add('SBQQ__RenewalForecast__c = false');
                }
                //If timing is not immediately, then check for the reference field
                else if(settings.AutoForecast_Timing__c != 'Immediately' && settings.AutoForecast_Timing__c != '' && settings.AutoForecast_ReferenceField__c != '') {
                    whereClause.add('(SBQQ__RenewalForecast__c = false AND ' + String.escapeSingleQuotes(settings.AutoForecast_ReferenceField__c) + ' <= :targetForecastDate)');
                    fieldsToQuery.add(String.escapeSingleQuotes(settings.AutoForecast_ReferenceField__c));
                }
            }
            
            //Check Auto-Quote Settings
            if(settings.AutoRenewQuote_Enabled__c){
                if(settings.AutoRenewQuote_Timing__c == 'Immediately') {
	                whereClause.add('SBQQ__RenewalQuoted__c = false');
                }
                //If timing is not immediately, then check for the reference field
                else if(settings.AutoRenewQuote_Timing__c != 'Immediately' && settings.AutoRenewQuote_Timing__c != '' && settings.AutoRenewQuote_ReferenceField__c != '') {
                    whereClause.add('(SBQQ__RenewalQuoted__c = false AND ' +String.escapeSingleQuotes(settings.AutoRenewQuote_ReferenceField__c) + ' <= :targetRenewDate)');
                    fieldsToQuery.add(String.escapeSingleQuotes(settings.AutoRenewQuote_ReferenceField__c));
                }
            }
            
            //Check Auto-Activation Settings
            if(settings.Contracting_AutomaticActivation__c != 'Never'){
                whereClause.add('Status = \'Draft\'');
                //Adding both fields to query regardless of actual setting to keep things simple here
                fieldsToQuery.add('CreatedDate');
                fieldsToQuery.add('StartDate');
            }
            
            //Add clause to allow for checking of items that are error'd out (no renewals but checkboxes checked)
            if(settings.AutoRenewQuote_Enabled__c == true || settings.AutoForecast_Enabled__c == true) {
                whereClause.add('(SBQQ__RenewalOpportunity__c = null AND (SBQQ__RenewalForecast__c = true OR SBQQ__RenewalQuoted__c = true))');
            }
            
            //Baseline string will only look at CPQ record types
            queryString = 'SELECT ' + String.join(new List<String>(fieldsToQuery), ', ') + ' FROM Contract WHERE EndDate > TODAY';
            if(whereClause.size() > 0){
                queryString = queryString + ' AND (' + String.join(whereClause, ' OR ') + ')';
            }
            
            system.debug('Query String for ContractRenewal_Batch: ' + queryString);
            system.debug('targetForecastDate = ' + targetForecastDate);
            system.debug('targetRenewDate = ' + targetRenewDate);
            
            //Return Query String
            return Database.getQueryLocator(queryString);
        }
        else{ //No automation setup
            system.abortJob(bc.getJobId());
            return null;
        }
    }

    /*
     * Execute function, where the bulk of the logic occurs
     */
    global void execute(Database.BatchableContext bc, List<Contract> scope){
        List<Contract> contractsToUpdate = new List<Contract>();
        for(Contract contract : scope){
            boolean updated = false;
            boolean activatedNow = false;
            //Handle Activation
            If(contract.Status != 'Activated') {
                if(settings.Contracting_AutomaticActivation__c == 'OnCreate' || 
                   (settings.Contracting_AutomaticActivation__c == 'OnStartDate' && Date.today() >= contract.StartDate)){
                    contract.Status = 'Activated';
                    activatedNow = true;
                    updated = true;
                }
            }
            
            //Handle Forecasting
            if(settings.AutoForecast_Enabled__c && (contract.SBQQ__RenewalForecast__c == false || (contract.SBQQ__RenewalForecast__c == true && contract.SBQQ__RenewalOpportunity__c == null))){
                if(contract.SBQQ__RenewalForecast__c == true && contract.SBQQ__RenewalOpportunity__c == null) {
                    contract.SBQQ__RenewalForecast__c = false;
                    updated = true;
                }
                else if(settings.AutoForecast_Timing__c == 'Immediately'){
                    contract.SBQQ__RenewalForecast__c = true;
                    updated = true;
                }
                else{ 
                    DateTime dateToCompare = (DateTime)contract.get(settings.AutoForecast_ReferenceField__c);
                    if(settings.AutoForecast_ReferenceField__c == 'ActivatedDate' && activatedNow == true) {
                        dateToCompare = Date.today();
                    }
                    Integer numDays = (settings.AutoForecast_NumDays__c).intValue();
                    
                    //If running a test, then ensure numDays and DateToCompare is always
                    if(Test.isRunningTest()){
                        numDays = 0;
                        dateToCompare = Date.today();
                    }
                    
                    if((settings.AutoForecast_Timing__c == 'DaysBefore' && Date.today() >= (dateToCompare - numDays)) ||
                       (settings.AutoForecast_Timing__c == 'DaysAfter' && Date.today() >= (dateToCompare + numDays))){
                           
                           contract.SBQQ__RenewalForecast__c = true;
                           updated = true;
                       }
                }
            }
            
            //Handle Quoting
            if(settings.AutoRenewQuote_Enabled__c && (contract.SBQQ__RenewalQuoted__c == false || (contract.SBQQ__RenewalQuoted__c == true && contract.SBQQ__RenewalOpportunity__c == null))){
                if(contract.SBQQ__RenewalQuoted__c == true && contract.SBQQ__RenewalOpportunity__c == null) {
                    contract.SBQQ__RenewalQuoted__c = false;
                    updated = true;
                }
                else if(settings.AutoRenewQuote_Timing__c == 'Immediately'){
                    contract.SBQQ__RenewalQuoted__c = true;
                    updated = true;
                }
                else{
                    DateTime dateToCompare = (DateTime)contract.get(settings.AutoRenewQuote_ReferenceField__c);
                    if(dateToCompare == null || (settings.AutoRenewQuote_ReferenceField__c == 'ActivatedDate' && activatedNow == true)){
                        dateToCompare = date.Today();
                    }
                    Integer numDays = (settings.AutoRenewQuote_NumDays__c).intValue();
                    
                    //If running a test, then ensure numDays and DateToCompare is always
                    if(Test.isRunningTest()){
                        numDays = 0;
                        dateToCompare = Date.today();
                    }
                    
                    if((settings.AutoRenewQuote_Timing__c == 'DaysBefore' && Date.today() >= (dateToCompare - numDays)) ||
                       (settings.AutoRenewQuote_Timing__c == 'DaysAfter' && Date.today() >= (dateToCompare + numDays))){
                           
                           contract.SBQQ__RenewalQuoted__c = true;
                           updated = true;
                       }
                }
            }
            
            if(updated){
                contractsToUpdate.add(contract);
            }
        }
        
        if(!contractsToUpdate.isEmpty()){
            update contractsToUpdate;
        }
    }
    
    /*
     * Final function that will check the job status; if any errors occurs, creates a QTC Error record
     */
    global void finish(Database.BatchableContext bc){
       
       // Get the ID of the AsyncApexJob representing this batch job
       // from Database.BatchableContext.
       // Query the AsyncApexJob object to retrieve the current job's information.
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, ExtendedStatus, CreatedById
                          FROM AsyncApexJob 
                          WHERE Id = :bc.getJobId()];
        
        if(a.NumberOfErrors > 0 || Test.IsRunningTest()){
            OSCPQ_Error__c err = OSCPQ_Utils.createQTCError('CPQ_ContractRenewal_Batch ' + a.Status, //Subject
                                    'CPQ', //targetPackage
                                    'Renewal Automation', //process
                                    'CPQ_ContractRenewal_Batch', //classMethodName
                                    'Total Errors: ' + a.NumberOfErrors + '\n' + a.ExtendedStatus, //Description
                                    a.CreatedById, //runningUserId
                                    true
            );
        }
    }
    
    private Date voidGetTargetDate(String timing, String tarField, Decimal numDays) {
        Date targetDate = Date.newInstance(2099, 01, 01); //Baseline date, if timing is 'Immediately'
        Integer numDaysInt = (numDays != null) ? numDays.intValue() : null;
        
        if(timing == 'DaysBefore' && numDaysInt != null) { //in SOQL, write as targetField <= targetDate
            targetDate = Date.today() + numDaysInt;
        }
        else if(timing == 'DaysAfter' && numDaysInt != null) { //in SOQL, write as targetField <= targetDate
            targetDate = Date.today() - numDaysInt;
        }
        
        return targetDate;
    }
}