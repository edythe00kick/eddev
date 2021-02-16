public with sharing class IncumbentTech_SearchController {
    // Properties Declaration
    public String industry {get; set;}
    public String technologyType {get; set;}
    public String accountType {get; set;}
    public String competitor {get; set;}
    public String technology {get; set;}
    public List<Incumbent__c> incumbents {get; set;}
    
    //Pagination variables
    public Integer offset = 0;
    public Integer limit_size = 25;
    public Integer total_records = 0;
    
    public IncumbentTech_SearchController() {
        // Properties Instantiation
        industry = '';
        technologyType = '';
        accountType = '';
        competitor = '';
        technology = '';
        incumbents = new List<Incumbent__c>();
    }
    
    // Returns picklist values of Industry field on Account
    public List<SelectOption> getAccountIndustryValues() {
        List<SelectOption> options = getPicklistValues(new Account(), 'Industry', 'All');
        return options;
    }
    
    // Returns picklist values of 'Technology Type' field on Incumbent Technology
    public List<SelectOption> getIncumbentTechTechnologyValues() {
        List<SelectOption> options = getPicklistValues(new Incumbent_Technology__c(), 'Technology_Type__c', 'All');
        return options;
    }
    
    // Returns picklist values of Type field on Account
    public List<SelectOption> getAccountTypeValues() {
        List<SelectOption> temp = getPicklistValues(new Account(), 'Type', null);
        temp.sort();
        
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        options.addAll(temp);
        return options;
    }
    
    // Returns options to query on Competitor? field on Incumbent
    public List<SelectOption> getIncumbentCompetitorValues() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        options.add(new SelectOption('True', 'True'));
        options.add(new SelectOption('False', 'False'));
        return options;
    }
    
    // Returns names of all 'Incombent Technology'
    public List<SelectOption> getIncumbentTechNames() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('All', 'All'));
        
        for(Incumbent_Technology__c it : [SELECT name FROM Incumbent_Technology__c ORDER BY name ASC]) {
            options.add(new SelectOption(it.name, it.name));
        }
        
        return options;
    }
    
    // Get a list of picklist values from an existing object field.
    public static List <SelectOption> getPicklistValues(SObject obj, String fld, String firstVal) {
        List <SelectOption> options = new List <SelectOption>();
        if(firstVal != null) {
            options.add(new SelectOption(firstVal, firstVal));
        }
        // Get the object type of the SObject.
        Schema.sObjectType objType = obj.getSObjectType();
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        // Get a map of fields for the SObject
        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();
        // Get the list of picklist values for this field.
        List<Schema.PicklistEntry> values = fieldMap.get(fld).getDescribe().getPickListValues();
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            options.add(new SelectOption(a.getLabel(), a.getValue()));
        }
        return options;
    }
    
    public void doSearch() {
        String query = 'SELECT Id, Name, Account__c, Account__r.Name, Incumbent_Technology__r.Name, Technology_Type__c, Account_Owner__c, Account_Type__c, Competitor__c FROM Incumbent__c';
        
        if(!technology.equals('All') || !technologyType.equals('All') || !accountType.equals('All') || !competitor.equals('All') || !industry.equals('All')) {
            query += ' WHERE';
        }
        
        if(!technology.equals('All')) {
            query += ' Incumbent_Technology__r.Name = \'' + technology + '\' AND';
        }
        if(!technologyType.equals('All')) {
            query += ' Technology_Type__c = \'' + technologyType + '\' AND';
        }
        if(!accountType.equals('All')) {
            query += ' Account_Type__c = \'' + accountType + '\' AND';
        }
        if(!competitor.equals('All')) {
            query += ' Competitor__c = ' + competitor + ' AND';
        }
        if(!industry.equals('All')) {
            query += ' Account__r.Industry = \'' + industry +'\' AND';
        }
        
        if(query.contains('WHERE')) {
            query = query.substring(0, query.lastIndexOf('AND') - 1);
        }
        
        String queryAll = query;
        System.debug(queryAll);
        query +=  ' LIMIT ' + limit_size + ' OFFSET ' + offset;
        
        // Empty list so that we don't have stale date
        if(!incumbents.isEmpty()) {
            incumbents.clear();
        }
        
        // Fire the query and fetch records
        try {
            for(List<Incumbent__c> incums : Database.query(query)) {
                if(incums != null) {
                    incumbents.addAll(incums);
                }
            }
            total_records = Database.query(queryAll).size();
        } catch(Exception ex) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'There was an error fetching information. This might be due to too many records returned by your query. Please refine you search and try again'));
        }
    }
    
    // Pagination methods
    // Functionality for Next button
    public void setNextPage() {
        offset += limit_size;
        doSearch();
    }
    
    // States whether Next button should be shown or not
    public Boolean getNextPage() {
        if((offset + limit_size) >= total_records) {
            return true;
        } else {
            return false;
        }
    }
    
    // Functionality for Previous button
    public void setPreviousPage() {
        offset -= limit_size;
        doSearch();
    }
    
    // States whether Previous button should be shown or not
    public Boolean getPreviousPage() {
        if(offset == 0) {
            return true;
        } else {
            return false;
        }
    }
}