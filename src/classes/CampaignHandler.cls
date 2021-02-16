/**
 * Trigger Handler for the Agreement SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public with sharing class CampaignHandler implements ITrigger{
   
    List<Campaign> campaignList = new List<Campaign>();
    Set<Id> campaignIdSetCustomSetting = new Set<Id>();
    //Set<String> campaignNameSetCustomSetting = new Set<String>();
    Map<Id,Integer> campaignWithRecentVacantSeatMap = new Map<Id,Integer>();
    Map<Id,Campaign> campaignWithWaitingMembers = new Map<Id,Campaign>();
    List<CampaignMember> campaignMemberToBeUpdated = new List<CampaignMember>();
    Map<String, CampaignMemberStatusCustom__c> cm_status_map
        = new Map<String, CampaignMemberStatusCustom__c>();
    List<CampaignMemberStatus> cm_status = new List<CampaignMemberStatus>();
    Map<Id, List<CampaignMemberStatus>> campaignMemberStatuses
        = new Map<Id, List<CampaignMemberStatus>>();
    
    // Constructor
    public CampaignHandler(){
    
    }

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){ 
        
        // Commented by Oshin on February 2, 2016
        //READY A MAP OF CAMPAIGN ID WITH NAME FROM CUSTOM SETTING
        /*for(Campaign_Name_With_Status__c setting : Campaign_Name_With_Status__c.getall().values()){
            campaignNameSetCustomSetting.add(setting.Campaign_Name__c.trim());
        }*/
        
        // Added by Oshin on February 2, 2016
        /*if(campaignIdSetCustomSetting.isEmpty() 
                && campaignNameSetCustomSetting.isEmpty()) {
            for(Marketo_Campaign_Name__c mcn : [SELECT Id, Name
                    , Campaign_Id__c FROM Marketo_Campaign_Name__c]) {
                campaignNameSetCustomSetting.add(mcn.Name.trim());
            }
        }
        
        System.debug('__campaignNameSetCustomSetting___'+campaignNameSetCustomSetting);*/
        System.debug('__Label.CampaignWaitingStatus__'+Label.CampaignWaitingStatus+'__Label.CampaignPartnerWaitingStatus_'+Label.CampaignPartnerWaitingStatus);
        
        //UPDATE THE AVAILABLE SEATS AS TOTAL ON CAMPAIGN INSERT
        if(Trigger.isInsert){
            //CampaignGateway.updateAvailableSeatsOnInsert(Trigger.new,campaignNameSetCustomSetting);
            CampaignGateway.updateAvailableSeatsOnInsert(Trigger.new);
            
        }
        
        //UPDATE THE AVAILABLE SEATS ON TOTAL SEAT UPDATE
        if(Trigger.isUpdate){
        
            System.debug('__inside_before_update__');
            
            //UPDATE THE AVAILABLE SEATS ON TOTAL SEAT UPDATE
            //CampaignGateway.updateAvailableSeatsOnUpdate(Trigger.newMap,Trigger.oldMap,campaignNameSetCustomSetting);
            CampaignGateway.updateAvailableSeatsOnUpdate(Trigger.newMap,Trigger.oldMap);
            
            //INSERT THE WAITING CAMPAIGN MEMBERS WHEN AVAILABLE SEATS INCREASES
            //campaignWithRecentVacantSeatMap = CampaignGateway.campaignWithRecentVacantSeats(Trigger.newMap,Trigger.oldMap,campaignNameSetCustomSetting);
            //campaignWithRecentVacantSeatMap = CampaignGateway.campaignWithRecentVacantSeats(Trigger.newMap,Trigger.oldMap);
            //System.debug('___campaignWithRecentVacantSeatMap___'+campaignWithRecentVacantSeatMap);
            
            //GET CAMPAIGN MEMBERS WITH WAITED MEMBERS
            //if(!campaignWithRecentVacantSeatMap.isEmpty())
                //campaignWithWaitingMembers = CampaignGateway.campaignWithWaitingMember(campaignWithRecentVacantSeatMap.keyset());
            
            //System.debug('__campaignWithWaitingMembers___'+campaignWithWaitingMembers);
        }
    }
    
    public void bulkAfter(){
        if(Trigger.isInsert) {
            /* 
             * Get all the values that should be used to set default values
             * for Campaign Member Status
             */
            cm_status_map = CampaignMemberStatusCustom__c.getAll();
            System.debug('cm_status_map'+cm_status_map);
            Set<Id> campaign_ids = new Set<Id>();
            for(SObject sobj : Trigger.new) {
                Campaign c = (Campaign) sobj;
                campaign_ids.add(c.Id);
                
            }
             
            campaignMemberStatuses = CampaignGateway.getCampaignMemberStatus(campaign_ids);
            //---Added by sandeep
            If(!campaignMemberStatuses.isEmpty()){
                List<CampaignMemberStatus> cstatuslisttoDelete = new  List<CampaignMemberStatus>();
                List<CampaignMemberStatus> cstatuslisttoUpdate = new  List<CampaignMemberStatus>();
                For(Id camp_Id : campaign_ids){
                    for(CampaignMemberStatus cstatus: campaignMemberStatuses.get(camp_Id)){
                       /* If(cstatus.Label.toLowerCase() == 'responded'){
                            cStatus.isDefault = True;
                            cstatuslisttoUpdate.add(cStatus);
                        }*/
                        If(cstatus.Label.toLowerCase() != 'responded' && 
                            cstatus.Label.toLowerCase() != 'sent')
                            cstatuslisttoDelete.add(cstatus); 
                    }
                }
                //update cstatuslisttoUpdate;
                delete cstatuslisttoDelete;
            }
        } 
    }
        
    public void beforeInsert(SObject so) {
        
        /*Campaign cm = (Campaign)so;
        campaignList.add(cm);*/
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        
        //System.debug('___campaignWithWaitingMembers___'+campaignWithWaitingMembers);
        /*
        if(!campaignWithWaitingMembers.isEmpty()){
        
            Campaign camp = campaignWithWaitingMembers.get(((Campaign)so).id);
            Integer totalWaitingMembers = camp.campaignMembers.size();
            
            System.debug('__totalWaitingMembers___'+totalWaitingMembers); 
            
            if(totalWaitingMembers > 0){
                
                Campaign campUpdate = (Campaign)so;
                System.debug('___camp___'+campUpdate.Maximum_Number_of_Subscribers__c);
                
                Integer numberOfRecentVacantSeats = campaignWithRecentVacantSeatMap.get(camp.id);
                Integer counter = numberOfRecentVacantSeats;
                System.debug('__numberOfRecentVacantSeats___'+numberOfRecentVacantSeats);
                
                for(Integer i=0 ; i<numberOfRecentVacantSeats; i++){
                    
                    if(totalWaitingMembers > 0 && totalWaitingMembers >= i+1){
                        
                        System.debug('___i_am_in___'+i);
                        if(camp.campaignMembers[i].lead != null && camp.campaignMembers[i].lead.Partner_ID__c != null){
                            campaignMemberToBeUpdated.add(new CampaignMember(id=camp.campaignMembers[i].id,status='Partner Responded + Workshop Confirmed'));
                            counter--;
                        }
                        else if(camp.campaignMembers[i].contact != null && camp.campaignMembers[i].contact.Partner_ID__c != null){
                            campaignMemberToBeUpdated.add(new CampaignMember(id=camp.campaignMembers[i].id,status='Partner Responded + Workshop Confirmed'));
                            counter--;
                        }
                        else{
                            campaignMemberToBeUpdated.add(new CampaignMember(id=camp.campaignMembers[i].id,status='Registered + Workshop Confirmed'));
                            counter--;
                        }
                    } 
                } 
                
                System.debug('__available___'+campUpdate.Maximum_Number_of_Subscribers__c);
                if(campUpdate.Maximum_Number_of_Subscribers__c != null && totalWaitingMembers != null){

                    campUpdate.Maximum_Number_of_Subscribers__c = counter;
                }
                System.debug('_____available__'+counter);           
           }
        }*/
    }
    
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so)
    {   
        
    }
    
    public void afterInsert(SObject so)
    {
        Campaign cm = (Campaign) so;
        
        /*if(campaignMemberStatuses.containsKey(cm.Id)) {
            List<CampaignMemberStatus> cmss
                = campaignMemberStatuses.get(cm.Id);
            for(CampaignMemberStatus cms : cmss) {
                String val = cms.Label == null ? '' 
                                : cms.Label.trim().toLowerCase();
                if(val == 'responded') {
                    cms.isDefault = true;
                    cm_status.add(cms);
                }
            }
        }*/
        
        if(!cm_status_map.isEmpty()) {
            for(CampaignMemberStatusCustom__c cms_rec
                    : cm_status_map.values()) {
                    
                CampaignMemberStatus cms = new CampaignMemberStatus(
                    CampaignId = cm.Id,
                    Label = cms_rec.Name,
                    hasResponded = cms_rec.Responded__c,
                    isDefault = cms_rec.Default__c);
                cm_status.add(cms);
                        
                
            }
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so)
    {
    }
    
    public void afterDelete(SObject so)
    {
    }
    
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally()
    {
        /*if(campaignList != NULL && !campaignList.isempty()){
            CampaignGateway.updateCampaignInfoOnInsert(campaignList);
        }*/
        //System.debug('__campaignMemberToBeUpdated____'+campaignMemberToBeUpdated);
        //if(!campaignMemberToBeUpdated.isEmpty())
            //update campaignMemberToBeUpdated;
        if(!cm_status.isEmpty())
            upsert cm_status;
    }
}