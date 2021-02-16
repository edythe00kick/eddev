/**
 * Custom Trigger for the ADM_Work object
 * 
 * @author  JP Horton <jhorton@alteryx.com>
 * @since   20170901
 */
public with sharing class ADM_WorkTriggerHandler {

//
// custom trigger handler setup to handler all triggers received on my custom object: User_Story__c
//
    private boolean myIsExecuting = false;
    private integer BatchSize = 0;

//
// constructor
//
    public ADM_WorkTriggerHandler(boolean isExecuting, integer size) {
        myIsExecuting = isExecuting;
        BatchSize = size;
    }

//
// On Before Insert - 
//   
//public void OnBeforeInsert(list<agf__ADM_Work__c> lstNew) {}

//
// On After Insert - 
// 
//	public void OnAfterInsert(map<id, agf__ADM_Work__c> mapNew) {}

//
// On Before Update - 
//    
//public void OnBeforeUpdate(map<id, agf__ADM_Work__c> mapOld, map<id, agf__ADM_Work__c> mapNew) { }

//
// On After Update -
//
public void OnAfterUpdate(map<id, agf__ADM_Work__c> mapOld, map<id, agf__ADM_Work__c> mapNew) {

	for(agf__ADM_Work__c A : mapNew.values()){
		agf__ADM_Work__c B = mapOld.get(A.Id);
		
		system.debug('**** ADM_WorkTriggerHandler.OnAfterUpdate : B.Release__c : ' + B.Release__c);
		system.debug('**** ADM_WorkTriggerHandler.OnAfterUpdate : A.Release__c : ' + A.Release__c);
		//Check if the Release field has changed
		if(B.Release__c != A.Release__c && A.Release__c != null){
			/*if(B.Release__c == null){
				//check that the Release Has been input for the first time
				system.debug('**** in section A ****');
				createReleaseStamp(A.Id,A.Release__c);	
			}else {*/
				//check that the Release Has been changed from an existing
				system.debug('**** in section B ****');
				manageExistingReleaseStamps(A.Id,A.Release__c);
				createReleaseStamp(A.Id,A.Release__c);
			/*}	*/
		// Due to the way the VF page handles the update, we cannot compare B and A} else if (B.Release__c != A.Release__c && A.Release__c == null) {
		} else if (A.Release__c == null) {
			//check that the Release Has been changed from an existing
			//handle existing Release In objects : Change Existing to , Change to Not Selected
			system.debug('**** in section C ****');
			manageExistingReleaseStamps(A.Id,A.Release__c);
		}
	}
	
} 

//
// On Before Delete - 
//
//public void OnBeforeDelete(map<ID, Requirements__c> mapOld) {}

//
// On After Delete - 
//
//public void OnAfterDelete(map<ID, Requirements__c> mapOld) {}

//
// On Undelete -
//
//public void OnUndelete(list<Requirements__c> lstNew) {}

/*******************  Utility Classes  ***********************/
	private void createReleaseStamp(Id WorkId, Id ReleaseId){
		system.debug('**** In ADM_WorkTriggerHandler.createReleaseStamp ****');
		agf__ADM_Released_In__c insertRFlag = new agf__ADM_Released_In__c();
		list<agf__ADM_Released_In__c> updateRFlag = new list<agf__ADM_Released_In__c>();
		agf__ADM_Work__c w = [SELECT Id, agf__Subject__c, Release__r.Name, Release__c FROM agf__ADM_Work__c WHERE Id =: WorkId];
		
		list<agf__ADM_Released_In__c> RFlagCheck = new list<agf__ADM_Released_In__c>([SELECT Id, agf__Release__c, agf__Release_Name__c, agf__Selected__c, agf__Stamped_On__c, agf__Subject__c, agf__Work__c, Release_Status__c FROM agf__ADM_Released_In__c WHERE agf__Work__c =: WorkId AND agf__Release__c =: ReleaseId]);
		
		system.debug('**** In ADM_WorkTriggerHandler.createReleaseStamp : RFlagCheck.size() : '+ RFlagCheck.size());
		if( RFlagCheck.size() == 0 ){	
			//create new Release Stamps
			insertRFlag.agf__Release__c = ReleaseId;
			insertRFlag.agf__Release_Name__c = w.Release__r.Name;
			insertRFlag.agf__Selected__c = true;
			insertRFlag.agf__Stamped_On__c = datetime.now();
			insertRFlag.agf__Subject__c = w.agf__Subject__c;
			insertRFlag.agf__Work__c = WorkId;
			insertRFlag.Release_Status__c = 'Selected for Release';
			insert insertRFlag;
			system.debug('**** In ADM_WorkTriggerHandler.createReleaseStamp : insert A success! ****');
		} else{
			system.debug('**** In ADM_WorkTriggerHandler.createReleaseStamp : Fill Update existing list! ****');
			//remove existing Release Stamps
			for(agf__ADM_Released_In__c a : RFlagCheck){
				if(a.agf__Selected__c == false){
					//create new Release Stamps
					a.agf__Release_Name__c = w.Release__r.Name;
					a.agf__Selected__c = true;
					a.agf__Stamped_On__c = datetime.now();
					a.agf__Subject__c = w.agf__Subject__c;
					a.agf__Work__c = WorkId;
					a.Release_Status__c = 'Selected for Release';
					updateRFlag.add(a);
				}
				
			}
			
			if(updateRFlag.size() > 0){
				update updateRFlag;
				system.debug('**** In ADM_WorkTriggerHandler.createReleaseStamp : update to existing Release Flags success! ****');	
			}
		}
	}
	
	private void manageExistingReleaseStamps(Id WorkId, Id NewReleaseId){
		system.debug('**** In ADM_WorkTriggerHandler.manageExistingReleaseStamps ****');
		list<agf__ADM_Released_In__c> RFlagCheck = new list<agf__ADM_Released_In__c>([SELECT Id, agf__Scheduled_Release_Date__c, Deployed_to_Production__c FROM agf__ADM_Released_In__c WHERE agf__Work__c =: WorkId AND agf__Release__c !=: NewReleaseId]);
		list<agf__ADM_Released_In__c> updateList = new list<agf__ADM_Released_In__c>();
		
		system.debug('**** In ADM_WorkTriggerHandler.manageExistingReleaseStamps : RFlagCheck.size() : '+ RFlagCheck.size());
		//check if we have to update existing release stamps
		if( RFlagCheck.size() > 0 ){	
			//check for how to adjust new Release Stamps
			for(agf__ADM_Released_In__c r : RFlagCheck){
				//if no release date, removed prior to release
				if(r.Deployed_to_Production__c == false){
					r.agf__Selected__c = false;
					r.Release_Status__c = 'Removed Prior to Release';
					updateList.add(r);	
				} else {
					//if there is a release date, these items are being re-released
					r.agf__Reverted__c = true;
					r.Release_Status__c = 'Reverted';
					updateList.add(r);
				}	
			}
			update updateList;
			
			system.debug('**** In ADM_WorkTriggerHandler.manageExistingReleaseStamps : update of updateList! ****');
		} else{return;
		system.debug('**** In ADM_WorkTriggerHandler.manageExistingReleaseStamps : No release stamps to update ****');
		}
	}

}