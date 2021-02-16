public with sharing class CaseTimeHandler {
    //
// custom trigger handler setup to handler all triggers received on my custom object: User_Story__c
//
    private boolean myIsExecuting = false;
    private integer BatchSize = 0;

//
// constructor
//
    public CaseTimeHandler(boolean isExecuting, integer size) {
        myIsExecuting = isExecuting;
        BatchSize = size;
    }

//
// On Before Insert - 
//   
//public void OnBeforeInsert(list<Case_Time_Entry__c> lstNew) {}

//
// On After Insert - 
// 
public void OnAfterInsert(map<id, Case_Time_Entry__c> mapNew) {
	list<Id> casesToUpdate = new list<Id>();
	
	for(Case_Time_Entry__c ct : mapNew.values()){
		if(ct.Case__c != null){
			casesToUpdate.add(ct.Case__c);
		}
	}
	
	system.debug('**** casesToUpdate.size() : '+ casesToUpdate.size());
	if(!casesToUpdate.IsEmpty()){
		updateCaseTimeRollup(casesToUpdate);
	}
}

//
// On Before Update - 
//    
//public void OnBeforeUpdate(map<id, Case_Time_Entry__c> mapOld, map<id, Case_Time_Entry__c> mapNew) { }

//
// On After Update -
//
public void OnAfterUpdate(map<id, Case_Time_Entry__c> mapOld, map<id, Case_Time_Entry__c> mapNew) {
	list<Id> casesToUpdate = new list<Id>();
	
	for(Case_Time_Entry__c A : mapNew.values()){
		Case_Time_Entry__c B = mapOld.get(A.Id);
		
		if(A.Case__c != B.Case__c && A.Case__c != null){
			casesToUpdate.add(A.Case__c);
			if(B.Case__c != null){
				casesToUpdate.add(B.Case__c);	
			}
		}
	}
	
	system.debug('**** casesToUpdate.size() : '+ casesToUpdate.size());
	if(!casesToUpdate.IsEmpty()){
		updateCaseTimeRollup(casesToUpdate);
	}
} 

//
// On Before Delete - 
//
//public void OnBeforeDelete(map<ID, Case_Time_Entry__c> mapOld) {}

//
// On After Delete - 
//
public void OnAfterDelete(map<ID, Case_Time_Entry__c> mapOld) {
	list<Id> casesToUpdate = new list<Id>();
	
	for(Case_Time_Entry__c ct : mapOld.values()){
		if(ct.Case__c != null){
			casesToUpdate.add(ct.Case__c);
		}
	}
	
	system.debug('**** casesToUpdate.size() : '+ casesToUpdate.size());
	if(!casesToUpdate.IsEmpty()){
		updateCaseTimeRollup(casesToUpdate);
	}
}

//
// On Undelete -
//
public void OnUndelete(list<Case_Time_Entry__c> lstNew) {
	list<Id> casesToUpdate = new list<Id>();
	
	for(Case_Time_Entry__c ct : lstNew){
		if(ct.Case__c != null){
			casesToUpdate.add(ct.Case__c);
		}
	}
	
	system.debug('**** casesToUpdate.size() : '+ casesToUpdate.size());
	if(!casesToUpdate.IsEmpty()){
		updateCaseTimeRollup(casesToUpdate);
	}
}

/*******************  Utility Classes  ***********************/
	private void updateCaseTimeRollup(list<Id> caseIds){
		system.debug('**** updateCaseTimeRollup ****');
		integer tempCount = 0;
		list<Case> caseUpdates = [SELECT Id, Case_Time_Total__c FROM Case WHERE Id in: caseIds];
		//map<id, Case> updateMap = new map<id,Case>(caseUpdates);
			
		for(Case c : caseUpdates){
			tempcount = [SELECT COUNT() FROM Case_Time_Entry__c WHERE Case__c =: c.Id];
		    c.Case_Time_Total__c = tempcount; //perform the desired action
		}
		
		if(!caseUpdates.IsEmpty()){
			update caseUpdates;
		}
	}
}