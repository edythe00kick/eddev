public without sharing class CampaignGateway
{
    //UPDATE THE AVAILABLE SEATS AS TOTAL ON CAMPAIGN INSERT
    public static void updateAvailableSeatsOnInsert(List<sObject> newCampaigns){    
        for(sObject camp : newCampaigns){
            Campaign campp = (Campaign)camp;
            if(campp.Total_number_of_Seats__c != null){
                campp.Maximum_Number_of_Subscribers__c = campp.Total_number_of_Seats__c;
            }    
        }   
    }
    
    //UPDATE THE AVAILABLE SEATS ON TOTAL SEAT UPDATE
    public static void updateAvailableSeatsOnUpdate(Map<ID,sObject> newMap,Map<ID,sObject> oldMap){
        
        for(ID campID : newMap.keyset()){
            Campaign newCamp = (Campaign)newMap.get(campID);
            Campaign oldCamp = (Campaign)oldMap.get(campID);
            
            if(newCamp.Event_Cap_Qualified__c == true && newCamp.Total_number_of_Seats__c != null && oldCamp.Total_number_of_Seats__c == null &&
            newCamp.Maximum_Number_of_Subscribers__c == null){
                newCamp.Maximum_Number_of_Subscribers__c = newCamp.Total_number_of_Seats__c;
            }
            
            if(newCamp.Event_Cap_Qualified__c == true && newCamp.Total_number_of_Seats__c != oldCamp.Total_number_of_Seats__c && 
                newCamp.Total_number_of_Seats__c != null && newCamp.Total_number_of_Seats__c > oldCamp.Total_number_of_Seats__c && newCamp.Total_number_of_Seats__c > 0){
                
                System.debug('___filter_passed_');
                System.debug('___old_total_'+oldCamp.Total_number_of_Seats__c+'__new_total__'+newCamp.Total_number_of_Seats__c+'___available__'+oldCamp.Maximum_Number_of_Subscribers__c);
                
                //IF AVAILABLE SEATS ARE EMPTY
                if(newCamp.Maximum_Number_of_Subscribers__c == null){
                
                    newCamp.Maximum_Number_of_Subscribers__c = newCamp.Total_number_of_Seats__c;
                }
                //IF AVAILABLE SEATS HAVE VALUE IN IT
                else{
                
                    if(newCamp.Total_number_of_Seats__c > oldCamp.Total_number_of_Seats__c)
                        newCamp.Maximum_Number_of_Subscribers__c += newCamp.Total_number_of_Seats__c - oldCamp.Total_number_of_Seats__c;
                    
                    else
                       newCamp.Maximum_Number_of_Subscribers__c += oldCamp.Total_number_of_Seats__c - newCamp.Total_number_of_Seats__c;    
                }
            }
            else if(newCamp.Event_Cap_Qualified__c == true && newCamp.Total_number_of_Seats__c != oldCamp.Total_number_of_Seats__c && 
                oldCamp.Total_number_of_Seats__c != null && newCamp.Total_number_of_Seats__c < oldCamp.Total_number_of_Seats__c && oldCamp.Total_number_of_Seats__c > 0){
                //if(newCamp.Maximum_Number_of_Subscribers__c != null){
                    newCamp.Maximum_Number_of_Subscribers__c -= (oldCamp.Total_number_of_Seats__c - newCamp.Total_number_of_Seats__c);
                //}
            }
            //IF TOTAL NUMBER OF SEATS ARE BEING UPDATING TO EMPTY
            else if(newCamp.Total_number_of_Seats__c != oldCamp.Total_number_of_Seats__c && newCamp.Total_number_of_Seats__c == null){
            
                newCamp.Maximum_Number_of_Subscribers__c = newCamp.Total_number_of_Seats__c;           
            }
            
            System.debug('__hi__maximum__'+newCamp.Maximum_Number_of_Subscribers__c);  
        }  
        
        
    }
    
    //INSERT THE WAITING CAMPAIGN MEMBERS WHEN AVAILABLE SEATS INCREASES
    //public static Map<Id,Integer> campaignWithRecentVacantSeats(Map<ID,sObject> newMap,Map<ID,sObject> oldMap,Set<String> campaignNameSetCustomSetting){
    /*public static Map<Id,Integer> campaignWithRecentVacantSeats(Map<ID,sObject> newMap,Map<ID,sObject> oldMap){
        
        Map<Id,Integer> campIdWithRecentVacantSeats = new Map<Id,Integer>();
        
        for(ID campID : newMap.keyset()){
        
            Campaign newCamp = (Campaign)newMap.get(campID);
            Campaign oldCamp = (Campaign)oldMap.get(campID);
            Integer numberOfRecentVacantSeats = 0;
            //if(campaignNameSetCustomSetting.contains(newCamp.name) && newCamp.Maximum_Number_of_Subscribers__c != oldCamp.Maximum_Number_of_Subscribers__c 
            if(newCamp.Event_Cap_Qualified__c == true && newCamp.Maximum_Number_of_Subscribers__c != oldCamp.Maximum_Number_of_Subscribers__c 
                && newCamp.Maximum_Number_of_Subscribers__c != null && 
                newCamp.Maximum_Number_of_Subscribers__c > 0){
                
                System.debug('__filter_Passed__');
                if(oldCamp.Maximum_Number_of_Subscribers__c != null){
                    numberOfRecentVacantSeats = Integer.valueOf(newCamp.Maximum_Number_of_Subscribers__c - oldCamp.Maximum_Number_of_Subscribers__c);
                    campIdWithRecentVacantSeats.put(campID,numberOfRecentVacantSeats);
                }
                else{
                    numberOfRecentVacantSeats = Integer.valueOf(newCamp.Maximum_Number_of_Subscribers__c);
                    campIdWithRecentVacantSeats.put(campID,numberOfRecentVacantSeats);
               }
             } 
          } 
          System.debug('___campIdWithRecentVacantSeats___'+campIdWithRecentVacantSeats);
          return campIdWithRecentVacantSeats;  
    }*/
    
    //INSERT THE WAITING CAMPAIGN MEMBERS WHEN AVAILABLE SEATS INCREASES
    /*public static Map<Id,Campaign> campaignWithWaitingMember(Set<Id> campaignIds){
    
        Map<Id,Campaign> campWithWaitedMembers = new Map<ID,Campaign>([SELECT id,name,Maximum_Number_of_Subscribers__c, (SELECT id,isdeleted,status,Contact.Partner_ID__c ,lead.Partner_ID__c FROM CampaignMembers WHERE (Status=: Label.CampaignWaitingStatus OR Status=: Label.CampaignPartnerWaitingStatus) AND isdeleted=false ORDER BY createddate ASC) FROM Campaign where id =: campaignIds]);
        return campWithWaitedMembers;
    }*/
    
    public static Map<Id, List<CampaignMemberStatus>> getCampaignMemberStatus(Set<Id> campaign_ids) {
        Map<Id, List<CampaignMemberStatus>> campaignMemberStatuses
            = new Map<Id, List<CampaignMemberStatus>>();
        
        for(CampaignMemberStatus cms : [SELECT Id, Label, isDefault, CampaignId 
                                        FROM CampaignMemberStatus 
                                        WHERE CampaignId IN :campaign_ids]) {
            List<CampaignMemberStatus> cmss 
                = campaignMemberStatuses.containsKey(cms.CampaignId) 
                    ? campaignMemberStatuses.get(cms.CampaignId) 
                    : new List<CampaignMemberStatus>();
            cmss.add(cms);
            campaignMemberStatuses.put(cms.CampaignId, cmss);
        }
        insertCampaignMemberStatus(campaignMemberStatuses);
        return campaignMemberStatuses;
    }
  //----Added by sandeep on 28-7-2017  
	public static void insertCampaignMemberStatus(Map<Id, List<CampaignMemberStatus>> campaignMemberStatuses){
        List<ID> Cmids= new list<ID>();
        List<CampaignMemberStatus> Cmstoinsert=new List<CampaignMemberStatus>();
        Boolean HasRepondedStatus=false;
        for(ID c:campaignMemberStatuses.keySet()){
            for(CampaignMemberStatus cms: campaignMemberStatuses.get(c)){
                if(cms.Label=='Responded'){
                       HasRepondedStatus=true;
                    if(!cms.IsDefault){
                        cms.IsDefault=true;
                        Cmstoinsert.add(cms);
                    }
                }
            }
            if(!HasRepondedStatus){
                Cmids.add(c);
            }
        }
        if(!cmids.isEmpty()){
            for(ID cm :Cmids){
                CampaignMemberStatus cs=new CampaignMemberStatus(Label='Responded', IsDefault=true,  CampaignId=cm);
                Cmstoinsert.add(cs);
            }
        }
        if(!Cmstoinsert.isEmpty()){
            upsert Cmstoinsert;
        }
    }  
}