/* Author: Sharma Nemani | W-013322
* Date: 10/04/2019
* Description: This batch class is to insert License Agreements from Agreement(Account) and to fetch all the attachments from Agreement(Account) to
* the License Agreements
* Object.
*/
global class AgreementToLicenceAgreementBatch implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext bc) {
        // collect the batches of records or objects to be passed to execute
        List<RecordType> rt = [select id from RecordType where DeveloperName = 'Master_License_Agreement'];
        List<Apttus__APTS_Agreement__c> lstApttus_APTS_Agreement = new List<Apttus__APTS_Agreement__c>();
        if(rt.size() > 0){
             //lstApttus_APTS_Agreement = [select id, Apttus__Account__c, CreatedById,
               //                                                      Apttus__Account_Search_Field__c,Name,OwnerId,MLA_Effective_Date__c,
                //                                                     RecordTypeId,Apttus__Status_Category__c,Apttus__APTS_Agreement__c.Apttus__Account__r.Deal_Desk_MLA_Notes__c
                //                                                     from Apttus__APTS_Agreement__c where CreatedDate > 2019-07-03T00:00:00Z AND Apttus__APTS_Agreement__c.Apttus__Account__r.Has_MLA_Temporary__c = true AND RecordTypeId =:rt[0].Id];
        }
        
        /*for(Apttus__APTS_Agreement__c agree : lstApttus_APTS_Agreement){
            
        }
        
        List<License_Agreement__c> lstLA =  new List<License_Agreement__c>();
        
        for(Apttus__APTS_Agreement__c agree : lstApttus_APTS_Agreement){
            License_Agreement__c la = new License_Agreement__c(License_Agreement_Name__c = agree.Name,OwnerId = agree.OwnerId,Account__c = agree.Apttus__Account__c,Effective_Date__c = agree.MLA_Effective_Date__c,Type__c = 'Master License Agreement',Status__c = agree.Apttus__Status_Category__c,Deal_Desk_MLA_Notes__c = agree.Apttus__Account__r.Deal_Desk_MLA_Notes__c,OSCPQ_External_Id__c = agree.Id);
            lstLA.add(la);
        }
        insert lstLA;
        
        if(Test.isRunningTest()){
            return database.getQueryLocator('select id,OSCPQ_External_Id__c from License_Agreement__c where OSCPQ_External_Id__c!=null'); //Where OSCPQ_External_Id__c!= null
        }else{
            return database.getQueryLocator('select id,OSCPQ_External_Id__c from License_Agreement__c where OSCPQ_External_Id__c!=null AND Id IN:lstLA'); //Where OSCPQ_External_Id__c!= null
        }*/
        Id recId = rt[0].Id;
        system.debug('recId : '+recId);
        system.debug('recId1 : '+('select id, Apttus__Account__c, CreatedById,Apttus__Account_Search_Field__c,Name,OwnerId,MLA_Effective_Date__c,RecordTypeId,Apttus__Status_Category__c,Apttus__APTS_Agreement__c.Apttus__Account__r.Deal_Desk_MLA_Notes__c from Apttus__APTS_Agreement__c where CreatedDate > 2019-07-03T00:00:00Z AND Apttus__APTS_Agreement__c.Apttus__Account__r.Has_MLA_Temporary__c = true AND RecordTypeId =:recId'));
        return database.getQueryLocator('select id, Apttus__Account__c, CreatedById,Apttus__Account_Search_Field__c,Name,OwnerId,MLA_Effective_Date__c,RecordTypeId,Apttus__Status_Category__c,Apttus__APTS_Agreement__c.Apttus__Account__r.Deal_Desk_MLA_Notes__c,MLA_Expiration_Date__c,Apttus__APTS_Agreement__c.Apttus__Account__r.Logo_Name_Use_Allowed__c,Apttus__APTS_Agreement__c.Apttus__Account__r.Opt_Out_Req__c from Apttus__APTS_Agreement__c where CreatedDate > 2019-07-03T00:00:00Z AND RecordTypeId =:recId');
    }
    
    global void execute(Database.BatchableContext bc, List<Apttus__APTS_Agreement__c> agreemt){
        
        Set<Id> setStr = new Set<Id>();
        Map<Id,Apttus__APTS_Agreement__c> mapAgree = new Map<Id,Apttus__APTS_Agreement__c>(agreemt);
        //for(Apttus__APTS_Agreement__c agree : agreemt){
          //  setStr.add(agree.Id);
        //}
        setStr = mapAgree.keyset();
        
        
        List<License_Agreement__c> scope1 = [select id,OSCPQ_External_Id__c from License_Agreement__c where OSCPQ_External_Id__c!=null AND OSCPQ_External_Id__c IN:setStr];
        for(License_Agreement__c agr : scope1){
            if(setStr.contains(agr.OSCPQ_External_Id__c)){
                setStr.remove(agr.OSCPQ_External_Id__c);
            }
        }
        
        system.debug('setStr :: '+setStr);
        List<License_Agreement__c> scope = new List<License_Agreement__c>();
        if(setStr.size() > 0){
            for(Id  agreeId:  setStr){
                if(mapAgree.containskey(agreeId)){
                    Apttus__APTS_Agreement__c agree = mapAgree.get(agreeId);
                    License_Agreement__c la = new License_Agreement__c(License_Agreement_Name__c = agree.Name,OwnerId = agree.OwnerId,Account__c = agree.Apttus__Account__c,Effective_Date__c = agree.MLA_Effective_Date__c,Type__c = 'Master License Agreement',Status__c = agree.Apttus__Status_Category__c,Deal_Desk_MLA_Notes__c = agree.Apttus__Account__r.Deal_Desk_MLA_Notes__c,OSCPQ_External_Id__c = agree.Id,Expiration_Date__c = agree.MLA_Expiration_Date__c,Opt_Out_Reason__c = agree.Apttus__Account__r.Opt_Out_Req__c,Logo_Allowed__c = agree.Apttus__Account__r.Logo_Name_Use_Allowed__c);
                    scope.add(la);
                }
                
            }
            insert scope;
        }
        if(setStr.size() == 0){
            return;
        }
        
        Map<String,License_Agreement__c> lstLA = new Map<String,License_Agreement__c>();        
        Set<String> setAggrId = new Set<String>();
        for(License_Agreement__c agr : scope){
            lstLA.put(agr.OSCPQ_External_Id__c,agr);
        }
        
        List<Attachment> lstAttch = [select id,ParentId,body,name from Attachment where ParentId IN: lstLA.keyset()];
        List<Attachment> insertAttList = new List<Attachment>();
        
        for(Attachment attch : lstAttch){
            if(lstLA.containsKey(attch.ParentId)){
                ///attch.ParentId = lstLA.get(attch.ParentId).Id;
                Attachment att = new Attachment(name = attch.name, body = attch.body, parentid = lstLA.get(attch.ParentId).Id);
                insertAttList.add(att);
            }
        }
        insert insertAttList; //insert
        
        /*for(Apttus__APTS_Agreement__c agr : scope){
            License_Agreement__c la = new License_Agreement__c();
            la.OSCPQ_External_Id__c = agr.Id;
            lstLA.put(agr.Id,la);
        }
        Insert lstLA.values();
        List<Attachment> lstAttch = [select id,ParentId from Attachment where ParentId IN: setAggrId];
        for(Attachment attch : lstAttch){
            if(lstLA.containsKey(attch.ParentId)){
                attch.ParentId = lstLA.get(attch.ParentId).Id;
            }
        }
        update lstAttch;*/
    }    
    global void finish(Database.BatchableContext bc){
        // execute any post-processing operations
    }    
}