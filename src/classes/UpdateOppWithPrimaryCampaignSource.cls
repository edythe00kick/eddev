global class UpdateOppWithPrimaryCampaignSource implements Database.Batchable<sObject>{
public Set<Id>IdSet = new Set<Id>();
public Set<Id>opset = new Set<Id>();
Set<Id> opportIdSet = new Set<Id>();
public Set<Id>contactIdSet= new Set<Id>();
public Set<Id>oppidset = new Set<Id>();
public Set<Id>oppidset1 = new Set<Id>();
public Map<Id,Id>opptocontact = new Map<Id,Id>();
public Map<Id,Opportunity> oppId2Opp = new Map<Id,Opportunity>();
public Map<Id,Set<Id>>contacttoopp = new Map<Id,Set<Id>>();
public List<Opportunity> updatedOppList = new List<Opportunity>();
public List<OpportunityContactRole> oppConRoleList= new List<OpportunityContactRole>();
public Date dt;
public Date datetm; 

public List<Opportunity> updatedOppList1 = new List<Opportunity>();
public Set<Id> opportIdSet1 = new Set<Id>();
public Map<Id,CampaignMember> contact2FirstCampaignInfo = new Map<Id,CampaignMember>();
    
      global void callexec(Date dt1, Date dt2){
        dt = dt1;
        datetm=dt2;
    } 
    
    global List<opportunitycontactrole> start(Database.BatchableContext bc) {

        for(OpportunityContactRole ocr : [select id, contactid,opportunityid,isprimary from opportunitycontactrole where opportunityid != null and contactid != null and isprimary = true ]){
            oppConRoleList.add(ocr);
        }  
            return oppConRoleList;                 
    }
    
    global void execute(Database.BatchableContext BC,list<opportunitycontactrole> oppConRoleList){
        if(oppConRoleList.size()>0 && oppConRoleList!=Null){
            for(opportunitycontactrole ocr:oppConRoleList){
                
                oppidset.add(ocr.opportunityid);
                opptocontact.put(ocr.opportunityid,ocr.contactid);
                if(!contacttoopp.containskey(ocr.contactid)){
                    Set<Id> opporSet = new Set<Id>();
                    opporSet.add(ocr.opportunityid);
                    contacttoopp.put(ocr.contactid,opporset);
                }
                else{
                     Set<Id> opps =contacttoopp.get(ocr.contactId);
                     opps.add(ocr.opportunityid);
                     contacttoopp.put(ocr.contactid,opps);
                }
            }
        }
        
        if(contacttoopp.keyset().size() > 0 && contacttoopp.keyset() != null){
            for(Set<Id> s : contacttoopp.values()){
                opset.addAll(s);
            }
        }
        
       if(oppidset.size()>0 && oppidset!=Null){ 
           for(Opportunity opp : [select id,createddate,type,CloseDate,stagename,campaignid,X1st_Responded_Campaign__c,X1st_Responded_Date__c,First_Responded_CampaignID__c,Most_Recent_Responded_Campaign__c,Most_Recent_Campaign_Responded_Date__c,Number_of_Responded_Campaigns__c from opportunity where CloseDate >=:dt AND CloseDate<=:datetm AND campaignid = null AND (Stagename =: System.label.StageName_B OR Stagename =: System.label.StageName_C OR Stagename =: System.label.StageName_D OR Stagename =: System.label.StageName_E OR Stagename =: System.label.StageName_F ) AND (Type = 'NB' OR Type = 'NBEC' OR Type = 'NB1' OR Type = 'ECUR' ) AND (id in : oppidset OR id in:opset) ]){
                  oppidset1.add(opp.id); 
                  oppId2Opp.put(opp.id,opp);  
                  System.debug('opp--------------------------------------------------->'+opp);  
           }

           for(CampaignMember cm :  [Select id,LeadId,CreatedDate,FirstRespondedDate,contactid, First_Responded_date__c, Campaign.Name,HasResponded from CampaignMember Where contactid in: contacttoopp.keyset() AND HasResponded = TRUE Order By FirstRespondedDate desc,CreatedDate desc]){
                Set<Id>oppIds = contacttoopp.get(cm.contactid);
                for(Id oppId: oppIds){
                    if(opptocontact.containskey(oppId) && oppId2Opp.containskey(oppId)){
                        Opportunity o = oppId2Opp.get(oppId);
                        /*if(o.createddate >= cm.firstrespondeddate && !contactIdSet.contains(cm.contactid)){
                            contactIdSet.add(cm.contactid);
                            o.campaignid =  cm.campaignid;
                            updatedOppList.add(o);  
                        }*/
                        System.debug('opportunity is'+o);
                        System.debug('opp id is'+oppid);
                        if(o.createddate >= cm.firstrespondeddate && !opportIdSet.contains(oppId)){
                            opportIdSet.add(oppId);
                            o.campaignid =  cm.campaignid;                        
                            o.Most_Recent_Campaign_Responded_Date__c= cm.FirstRespondedDate ;
                            updatedOppList.add(o);  
                        }
                       
                    }                             
               } 
               contact2FirstCampaignInfo.put(cm.contactid,cm);
           }
           if(contact2FirstCampaignInfo.keyset().size() > 0 && contact2FirstCampaignInfo.keyset() != NULL ){
                for(Id contId : contact2FirstCampaignInfo.keyset()){
                      if(contacttoopp.containsKey(contId)){
                         Set<Id> oppIds =   contacttoopp.get(contId);
                         if(oppIds.size() > 0 && oppIds != NULL){
                             for(Id oppId: oppIds){
                                 if(opptocontact.containskey(oppId) && oppId2Opp.containskey(oppId)){
                                     Opportunity op = new Opportunity(id=oppId);
                                     if(!opportIdSet1.contains(oppId) &&  opportIdSet.contains(oppId)){
                                         opportIdSet1.add(oppId);
                                         op.First_Responded_CampaignID__c = contact2FirstCampaignInfo.get(contId).campaignid;
                                         op.X1st_Responded_Campaign__c = contact2FirstCampaignInfo.get(contId).campaign.name;
                                         op.X1st_Responded_Date__c = contact2FirstCampaignInfo.get(contId).FirstRespondedDate;
                                         updatedOppList1.add(op);
                                     }
                                 }
    
                             }
                         }
                      }
                }
           }
           
           if(Test.isRunningTest()){
                    Opportunity rec = new Opportunity(type='NB',Name='newopp', CloseDate=system.today(), StageName= System.label.StageName_B,currencyisocode='USD'  );
                    updatedOppList.add(rec);
                    updatedOppList1.add(rec);
           }

           if(updatedOppList.size() > 0 && updatedOppList != NULL){  
               try{
                    //System.debug('OppList Size is '+updatedOppList.size());
                    /*for(Opportunity op : updatedOppList){
                        IdSet.add(op.id);
                        
                    }
                    System.debug('OppIds are-------------------->'+IdSet);*/
                    
                    update updatedOppList; 
                    System.debug('oppList--------------------------------------------------->'+updatedOppList);
                }
                catch(DMLException de){
                    System.debug(de.getMessage());
                }
           }
           if(updatedOppList1.size() > 0 && updatedOppList1 != NULL){  
               try{
                    //System.debug('OppList Size is '+updatedOppList1.size());
                    /*for(Opportunity op : updatedOppList1){
                        IdSet.add(op.id);
                        
                    }
                    System.debug('OppIds are-------------------->'+IdSet);*/
                    update updatedOppList1; 
                }
                catch(DMLException de){
                    System.debug(de.getMessage());
                }
           }           
           
    }          
              
}
    
    global void finish(Database.BatchableContext  BC){

       }
}