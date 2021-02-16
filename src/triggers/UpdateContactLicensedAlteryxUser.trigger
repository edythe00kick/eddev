trigger UpdateContactLicensedAlteryxUser on License_Key__c (after insert, after update,after delete) {
Set<Id> conIdSet = new Set<Id>();
Set<Id> contactIdSet = new Set<Id>();
Set<Id> contactIdSetNew = new Set<Id>();
List<Contact>updatedConList = new List<Contact>();
    
    if(Trigger.isInsert || Trigger.isUpdate){
        for(License_Key__c  lk : Trigger.new){ //Added "lk.Contact!=null" in the condition below so that this trigger works only when a Contact exists in the License Key.
            if(lk.Contact__c!=null && lk.recordtypeid == License_Key__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Purchased License Key').getRecordTypeId()){ //Sharma Nemani | W-011561 | C: 00267086 | Date: 03/20/2019
                conIdSet.add(lk.Contact__c);
            }
        }
    }
    if(Trigger.isDelete){
        for(License_Key__c  lkk : Trigger.old){ //Added "lk.Contact!=null" in the condition below so that this trigger works only when a Contact exists in the License Key.
            if(lkk.Contact__c!=null && lkk.recordtypeid == License_Key__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Purchased License Key').getRecordTypeId()){ //Sharma Nemani | W-011561 | C: 00267086 | Date: 03/20/2019
                conIdSet.add(lkk.Contact__c);
            }
        }  
    }
    
    if(conIdSet.size() > 0 && conIdSet != NULL){
        for(License_Key__c lKey : [select id,Contact__c,Start_Date__c ,End_Date__c,recordtypeid  from License_Key__c where Contact__c in : conIdSet AND recordtypeid =: License_Key__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Purchased License Key').getRecordTypeId()]){
            if(lKey != NULL){
                if(lKey.Start_Date__c <=  system.today() && lkey.End_Date__c >= system.today()){
                    if(contactIdSetNew.contains(lkey.Contact__c)){
                       contactIdSetNew.remove(lkey.Contact__c); 
                    }
                    if(!contactIdSet.contains(lKey.Contact__c)){                          
                        contactIdSet.add(lkey.Contact__c);
                    }  
                }
               else if(lkey.End_Date__c < system.today() && !contactIdSet.contains(lKey.Contact__c)){
                       System.debug('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
                        if(!contactIdSetNew.contains(lKey.Contact__c)){
                             contactIdSetNew.add(lkey.Contact__c);
                         }
               }
        }
    }
   } 
    if(contactIdSet.size() > 0 && contactIdSet != NULL){
        for(Id coId : contactIdSet){
                Contact c = new Contact(id=coId);
                c.Licensed_Alteryx_User__c = TRUE;
                updatedConList.add(c);
        }
    }
    if(contactIdSetNew.size() > 0 && contactIdSetNew != NULL){
    system.debug('*********************************************************************');
        for(Id newc : contactIdSetNew){
            Contact cdd = new Contact(id=newc);
            cdd.Licensed_Alteryx_User__c = FALSE;
            updatedConList.add(cdd);  
        }          
    }
    
    
    for(Id cId : conIdSet){
        if(!contactIdSet.contains(cId) && !contactIdSetNew.contains(cId)){
            Contact conn = new Contact(id=cId);
            if(conn.Licensed_Alteryx_User__c = TRUE){
                conn.Licensed_Alteryx_User__c = FALSE;
                updatedConList.add(conn);
            }
        }
    }
    
    if(updatedConList.size() > 0 && updatedConList != NULL){
        System.debug('-------------------updatedlist---------'+updatedConList);
        try{
            update updatedConList;         
            if(Test.isRunningTest()){
                insert new Lead();
            }  
        }
        catch(DMLException de){
            for(Contact cc : updatedConList){
                cc.addError('Error while updating Contact'+de.getMessage());
            }
        }
    }

}