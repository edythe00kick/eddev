/**
***    @description:    Trigger Handler for Event_Registration__c.
***    @author:         JP Horton (jhorton@alteryx.com)
***    @createdDate :   December 1, 2017
***    @testclass :     EventRegistrationTriggerTest.cls
***/
public with sharing class EventRegistrationTriggerHandler {
    
// A map of registration email to lead or contact 
    private map<String, sObject> uniqueEmailList = new map<String, sObject>();
    private map<String,String> futureUniqueEmailList = new map<String,String>();
    private map<String, Contact> contactsByEmail = new map<String, Contact>();
    private map<String, Lead> leadsByEmail = new map<String, Lead>();

// A list of emails fetched from Referrer_Email__c on Event_Registration__c
    private Set<String> referrerEmails = new Set<String>();

//
// custom trigger handler setup to handler all triggers received on my custom object: User_Story__c
//
    private boolean myIsExecuting = false;
    private integer BatchSize = 0;

//
// constructor
//
    public EventRegistrationTriggerHandler(boolean isExecuting, integer size) {
        myIsExecuting = isExecuting;
        BatchSize = size;
    }

//
// On Before Insert - create wrapper class and then invoke any methods that you want executed before insert
// For example, data defaults 
//   
    public void OnBeforeInsert(list<Event_Registration__c> lstNew) {
        system.debug('**** referrerEmails.size() before run: '+ referrerEmails.size());
        fillReffererEmailList(lstNew);
        createLeadContactMap();
        
        for( Event_Registration__c e : lstNew ){
            if(contactsByEmail.containsKey(e.Email_Address__c)){
                e.Contact__c = contactsByEmail.get(e.Email_Address__c).Id;
            } else if (leadsByEmail.containsKey(e.Email_Address__c)){
                e.Lead__c = leadsByEmail.get(e.Email_Address__c).Id;
            }
        }
    } 
//
// On After Insert - 
// 
    public void OnAfterInsert(map<id, Event_Registration__c> mapNew) {   
        system.debug('**** referrerEmails.size() before run: '+ referrerEmails.size());
        fillReffererEmailList(mapNew.values());
       
        list<Event_Registration__c> newLeadNeeded = new list<Event_Registration__c>();
       
        for( Event_Registration__c e : mapNew.values() ){
            if( e.Contact__c == null && e.Lead__c == null ){
                newLeadNeeded.add(e);
            }
        }
        
        if( !newLeadNeeded.isEmpty() ){
            createAdditionalLeads(newLeadNeeded);
        }       
        
        for( String k : uniqueEmailList.keySet() ){
            futureUniqueEmailList.put(k,k);
        }
        
        uniqueEmailList.clear();
        leadsByEmail.Clear();
        findLead();
        linkRegistrationToNewLead(mapNew.keySet(), futureUniqueEmailList);
    }
//
// On Before Update - 
//    
//    public void OnBeforeUpdate(map<id, Event_Registration__c> mapOld, map<id, Event_Registration__c> mapNew) { }
    
//
// On After Update -
//
//    public void OnAfterUpdate(map<id, Event_Registration__c> mapOld, map<id, Event_Registration__c> mapNew) { }

//
// On Before Delete - 
//
//    public void OnBeforeDelete(map<ID, Event_Registration__c> mapOld) {}

//
// On After Delete - You have a list of items that have been deleted.  If there is anything that you need to do
// this could be updating various fields on Event_Registration__c base on items deleted.
//
//    public void OnAfterDelete(map<ID, Event_Registration__c> mapOld) {}

//
// On Undelete -
//
//    public void OnUndelete(list<Event_Registration__c> lstNew) {}

/************************* Private Classes **********************************/    
    private void fillReffererEmailList(list<Event_Registration__c> eventRegList){
        for(Event_Registration__c e : eventRegList){
            if(e.Email_Address__c != null){
                referrerEmails.add(e.Email_Address__c.trim().toLowerCase());
            }
            system.debug('**** referrerEmails.size() after run: '+ referrerEmails.size());
        }
    }

     /**
     * Find lead or contact in SFDC on the basis of registration email
     * so that Event_Registration__c can be associated with them.
     */
    private void createLeadContactMap() {
        uniqueEmailList.clear();
        findContact();
        findLead();   
    }

    /**
     * Find leads in SFDC on the basis of set named "referrerEmails" and fill map
     * named "uniqueEmailList".
     */
    private void findLead() {
    system.debug('*** in FindLead() ****');
    system.debug('**** FindLead referrerEmails.size() : '+ referrerEmails.size());
        for(Lead l : [SELECT Id, Email FROM Lead WHERE isConverted = false AND Email IN :referrerEmails]) {
          system.debug('**** IN LOOP findLead() ****');
            if(!uniqueEmailList.containsKey(l.Email)){
                uniqueEmailList.put(l.Email, l);
                leadsByEmail.put(l.Email, l);
                system.debug('**** NEW LEAD LOOKUP! : '+ l.Email);
            }
        }
    }

    /**
     * Find contacts in SFDC on the basis of set named "referrerEmails" and fill map
     * named "uniqueEmailList".
     */
    private void findContact() {
        for(Contact c : [SELECT Id, Email FROM Contact WHERE Email IN :referrerEmails]) {
            if(!uniqueEmailList.containsKey(c.Email)){
                uniqueEmailList.put(c.Email, c);
                contactsByEmail.put(c.Email, c);
            }
        }
    }

     /**
     * For registrations that don't have a lead or contact in SFDC related
     * to their email address, create leads.
     */    
     private void createAdditionalLeads(list<Event_Registration__c> allEventReg) {

        list<Event_Registration__c> newLeadFromEventReg = new list<Event_Registration__c>();

        for(Event_Registration__c e : allEventReg){
            if(!uniqueEmailList.containsKey(e.Email_Address__c)) {
                newLeadFromEventReg.add(e);
            }
        }

        if(newLeadFromEventReg.isEmpty()) {
            return;
        }
        
        Id MQLMatchingQueue = [select Id from Group where Type = 'Queue' AND DeveloperNAME = 'MQL_Matching_Queue'].Id;
        
        List<Lead> newLeads = new List<Lead>();
        for(Event_Registration__c e : newLeadFromEventReg) {
            Lead l = new Lead();
            l.FirstName = e.First_Name__c;
            l.LastName = e.Last_Name__c;
            l.Company = e.Company__c;
            l.Phone = e.Business_Phone__c;
            l.Title = e.Business_Title__c;
            l.Email = e.Email_Address__c;
            l.Street = e.Mailing_Address_1__c;
            l.City = e.Mailing_City__c;
            l.State = e.Mailing_State_Province__c;
            l.Country = e.Mailing_Country__c;
            l.Department1__c = e.Business_Department__c;
            l.OwnerId = MQLMatchingQueue;
            l.LeadSource = 'Inspire Registration';
            newLeads.add(l);
        }
        
        system.debug('**** Totals LEAD to Insert : '+ newLeads.size());
        if(!newLeads.isEmpty()) {
            insert newLeads;
        }
    }
    
    @future
    private static void linkRegistrationToNewLead(Set<Id> allEventReg, map<String,String> tempUniqueEmailList) {
        list<Event_Registration__c> updateEventReg = new list<Event_Registration__c>();
        list<Event_Registration__c> tempEventReg = [SELECT Id, Lead__c, Email_Address__c FROM Event_Registration__c WHERE Id IN :allEventReg AND Lead__c = null AND Contact__c = null];
        map<String, Lead> tempLeadsByEmail = new map<String, Lead>();

        set<String> emailSet = new set<String>();
        
        for( Event_Registration__c e : tempEventReg ){
            emailSet.add(e.Email_Address__c);
        }

        
        for(Lead l : [SELECT Id, Email FROM Lead WHERE isConverted = false AND Email IN :emailSet]) {
          //system.debug('**** IN LOOP findLead() ****');
            if(!tempUniqueEmailList.containsKey(l.Email)){
                tempLeadsByEmail.put(l.Email, l);
                //system.debug('**** NEW LEAD LOOKUP! : '+ l.Email);
            }
        }
        
        for( Event_Registration__c e : tempEventReg ){
            if (tempLeadsByEmail.containsKey(e.Email_Address__c)){
                e.Lead__c = tempLeadsByEmail.get(e.Email_Address__c).Id;
                //system.debug('**** leadsByEmail.get(e.Email_Address__c).Id : ' + leadsByEmail.get(e.Email_Address__c).Id);
                updateEventReg.add(e);
            }
        }
        
       // system.debug('**** updateEventReg.size()'+ updateEventReg.size());
        
        if(!updateEventReg.IsEmpty()){
            update updateEventReg;
        }
    }
    

}