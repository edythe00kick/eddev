/*
Test Class- 1) TestSpecialCampaignType
2) TestCampaignMemberType
*/
public with sharing class CampaignMemberHandler implements ITrigger{

    Set<ID>leadIds1 = new Set<ID>();
    Set<ID>conIds1 = new Set<ID>();
    Set<ID>cmIds1 = new Set<ID>();
    Set<ID>leadIds2 = new Set<ID>();
    Set<ID>conIds2 = new Set<ID>();
    Set<ID>leadIds3 = new Set<ID>();
    Set<ID>conIds3 = new Set<ID>();
    Set<ID>cmIds3 = new Set<ID>();
    List<Lead>upLead = new List<Lead>();
    List<Contact>upCon= new List<Contact>();
    public static boolean bool = true;
    Map<Id, CampaignMember> respondedCampaignMembers = new Map<Id, CampaignMember>();
    Map<Id, String> leadid_to_leadSourceMostRecent = new Map<Id, String>();
    Map<Id, Campaign> campaign_map = new Map<Id, Campaign>();
    Set<Id> campaign_ids = new Set<Id>();
    Map<Id, Campaign> campaigns_to_update = new Map<Id, Campaign>();
    List<CampaignMember> campaignMembers_to_update = new List<CampaignMember>();
    Set<Id> campaign_registeredCM = new Set<Id>();
    Map<Id, List<CampaignMember>> campaignId_campaignMemberList = new Map<Id, List<CampaignMember>>();
    
    List<CampaignMember> campMembersApprovedfromWaitingList = new List<CampaignMember> (); 
    Map<Id,Set<Id>> campaignId2CampMemberIds = new  Map<Id,Set<Id>>();
    Map<Id,Integer> campaignWithChangedMemberCount = new  Map<Id,Integer>();
    integer campMembersStatusChangedCount = 0;
    Set<String> partnerLeadsIdSet = new Set<String>();
    Set<String> partnerContactsIdSet = new Set<String>();
    Set<String> campaignIdSetCustomSetting = new Set<String>();
    Set<String> campaignNameSetCustomSetting = new Set<String>();
    Map<ID,Set<ID>> approvedMemberBeingDeletedMap = new Map<ID,Set<ID>>();
    List<Campaign> campaignToBeUpdated = new List<Campaign>();
    
    Map<String,lead> leadsToUpdate = new Map<String,lead>();
    Map<String,contact> contactsToUpdate = new Map<String,contact>();
    
    public Map<Id,Integer> campaignId2ApprovedMemberCount = new Map<Id,Integer>();
    
    // Added by Oshin on Nov 3, 2016
    // A set of lead where
    Set<Id> leadIds4 = new Set<Id>();
    Set<Id> contactIds4 = new Set<Id>();
    public static Boolean ranForCCAAfterInsert = false;
    public static Boolean ranForCCAAfterUpdate = false;
    public Map<Id, String> cmToStatusMap = new Map<Id, String>();
    public Map<Id, Id> cmToLeadIdMap = new Map<Id, Id>();
    public Map<Id, Id> cmToContIdMap = new Map<Id, Id>();
    public List<Contact> contsToUpdate = new List<Contact>();
    public List<Lead> leadToUpdateList = new List<Lead>();

    public CampaignMemberHandler(){
    }
    
    public void bulkBefore(){
        
        system.debug('partnerLeadsIdSet in CampaignMemberGateway==>'+partnerLeadsIdSet);
        
        // Added by Oshin on February 2, 2016
        if(campaignIdSetCustomSetting.isEmpty() 
                && campaignNameSetCustomSetting.isEmpty()) {
            for(Campaign mcn : [SELECT Id, Name
                     FROM Campaign where Event_Cap_Qualified__c = true]) {
                campaignIdSetCustomSetting.add(
                        ID.valueOf(mcn.id));
            }
        }
        
        System.debug('___campaignIdSetCustomSetting___'+campaignIdSetCustomSetting);
        System.debug('___campaignNameSetCustomSetting___'+campaignNameSetCustomSetting);
        
        if(Trigger.isInsert || Trigger.isUpdate){
            // W-009852 Added by Hemendra Singh Rajawat on July 06, 2018
            List<String> respTrueList = new List<String>{'Responded'};
            List<String> respFalseList = new List<String>{'Sent'};
            List<UTM_Source_Fields__mdt> fields = [SELECT CampMem_Api__c FROM UTM_Source_Fields__mdt];

            for(CampaignMemberStatusCustom__c status : [SELECT Name, Responded__c 
                                                        FROM CampaignMemberStatusCustom__c]) {

                if (status.Responded__c) {
                    respTrueList.add(status.Name);
                } else {
                    respFalseList.add(status.Name);
                }
            }

            for(SObject sobj : Trigger.new) {
                CampaignMember cm = (CampaignMember)sobj;

                // W-009852 Added by Hemendra Singh Rajawat on July 06, 2018
                if (Trigger.isUpdate && !System.isBatch()) {
                    CampaignMember oldCm = (CampaignMember)Trigger.oldMap.get(cm.Id);
                    if (respTrueList.contains(oldCm.Status) && respFalseList.contains(cm.Status)) {
                        cm.Batch_Executed__c = false;
                    } else {
                        for (UTM_Source_Fields__mdt field : fields) {
                            if (oldCm.get(field.CampMem_Api__c) != cm.get(field.CampMem_Api__c)) {
                                cm.Batch_Executed__c = false;
                                break;
                            }
                        }
                    }
                }

                String new_status = cm.Status == null ? '' : cm.Status.trim().toLowerCase();
                
                if(Trigger.IsInsert && new_status == 'workshop queue') {
                    campaign_ids.add(cm.CampaignId);
                }
                if(Trigger.isUpdate) { 
                    campaign_ids.add(cm.CampaignId);  
                }
                System.debug('campid:' + cm.Id);
                if(Trigger.isUpdate) {
                    
                    System.debug('condition 1: '+((CampaignMember)Trigger.oldMap.get(cm.Id)).Status);
                    System.debug('condition 2:'+cm.Status);
                    System.debug('condition 3:' +campaignIdSetCustomSetting.contains(cm.campaignId));
                    
                    CampaignMember old_cm = (CampaignMember)Trigger.oldMap.get(cm.Id);
                    String old_status = old_cm.Status == null ? '' : old_cm.Status.trim().toLowerCase();
                    
                    System.debug('condition 1: '+old_status);
                    System.debug('condition 2:'+new_status);
                    System.debug('condition 3:' +campaignIdSetCustomSetting.contains(cm.campaignId));
                    
                    if((old_status == 'registered' || old_status == 'partner registered') 
                        && new_status == 'waitlisted' && campaignIdSetCustomSetting.contains(cm.campaignId)) {
                        
                        if(!campaignWithChangedMemberCount.containsKey(cm.campaignId)){
                            
                            campaignWithChangedMemberCount.put(cm.campaignId,1);                          
                        }
                        else{
                            
                            Integer count = campaignWithChangedMemberCount.get(cm.campaignId) + 1;
                            campaignWithChangedMemberCount.put(cm.campaignId,count);
                        }
                    }
                }
                
            }
            
            System.debug('__campaignWithChangedMemberCount____'+campaignWithChangedMemberCount);
            campaign_map = CampaignMemberGateway.getCampaigns(campaign_ids);
            partnerLeadsIdSet = CampaignMemberGateway.getPartnerLeads(campaignIdSetCustomSetting);
            partnerContactsIdSet = CampaignMemberGateway.getPartnerContacts(campaignIdSetCustomSetting);
            
        }
        if(trigger.isUpdate){
            if(!campaignWithChangedMemberCount.isEmpty()){
                for(Id campId : campaign_map.keyset()){
                    Campaign c = campaign_map.get(campId); 
                        
                    if(campaignWithChangedMemberCount.containsKey(campId) &&
                        c.Maximum_Number_of_Subscribers__c != NULL && c.Event_Cap_Qualified__c == true){
                           
                        c.Maximum_Number_of_Subscribers__c += campaignWithChangedMemberCount.get(campId);
                        System.debug('Maximum_Number_of_Subscribers__c:--'+c.Maximum_Number_of_Subscribers__c);
                        System.debug('Total_number_of_Seats__c:--'+campaign_map.get(campId).Total_number_of_Seats__c);
                           
                        if(c.Maximum_Number_of_Subscribers__c > campaign_map.get(campId).Total_number_of_Seats__c){
                            c.Maximum_Number_of_Subscribers__c = campaign_map.get(campId).Total_number_of_Seats__c;
                        }
                        campaigns_to_update.put(c.Id, c);
                    }
                } 
            }
        }
    }
    
    public void bulkAfter(){
        
        //Added by Paramvir April 4,2016
        Set<String> leadIds = new Set<String>();
        Set<String> contactIds = new Set<String>();
        set<string> campaignIDs = new set<string>();
        //set<string> campaignIDsForUpdate = new set<string>();
        for(SObject sobj : (Trigger.isDelete ? Trigger.old : Trigger.new)) {
            CampaignMember cm = (CampaignMember)sobj; 
            if(Trigger.isDelete) {
                campaignIDs.add(cm.CampaignId);
            }
            
            if(Trigger.isUpdate) {
               // campaignIDsForUpdate.add(cm.CampaignId);
                if(cm.contactID != null){
                    contactIds.add(cm.contactId);
                }else{
                    leadIds.add(cm.leadID);
                }
            }

            // #W-009847 Added by Hemendra Singh Rajawat on June 19, 2018
            if (Trigger.isInsert || Trigger.isUpdate) {
                if (cm.Status != null && cm.ContactId == null) {
                    cmToStatusMap.put(cm.Id, cm.Status);
                    cmToLeadIdMap.put(cm.Id, cm.LeadId);
                }
                if (cm.Status != null && cm.ContactId != null) {
                    cmToStatusMap.put(cm.Id, cm.Status);
                    cmToContIdMap.put(cm.Id, cm.ContactId);
                }
            }
        }
        
        
        if(trigger.isUpdate){
            System.debug('leadsid: '+leadIds );
            for(lead l :[SELECT id, Campaign_Referred_Partner_ID__c from lead where id in:leadIds]){
                 System.debug('leads data'+ l);
            }
           
            
            System.debug('contactId: '+contactIds);
            map<id,string> idToPartnerIdMap = CampaignMemberGateway.getPartnerIdFromLeadOrContact(leadIds , contactIds);
            System.debug('partner: '+idToPartnerIdMap.size());
            if(idToPartnerIdMap.size() >0){ 
                for(SObject sobj : Trigger.new) {
                    CampaignMember cm = (CampaignMember)sobj;
                    CampaignMember oldCm = (CampaignMember)Trigger.oldMap.get(cm.id);
                    System.debug('condition idtopartner'+ cm.Campaign_Referred_Partner_ID__c +' ,  '+ oldCm.Campaign_Referred_Partner_Id_Update_Time__c  +' , ' +cm.Campaign_Referred_Partner_Id_Update_Time__c);
                    if(cm.Campaign_Referred_Partner_ID__c != NULL && cm.Campaign_Referred_Partner_Id_Update_Time__c != NULL && oldCm.Campaign_Referred_Partner_Id_Update_Time__c  != cm.Campaign_Referred_Partner_Id_Update_Time__c ){
                        if(cm.contactID != null){
                            if(idToPartnerIdMap.containsKey(cm.contactID) && !contactsToUpdate.containsKey(cm.contactID) ){
                                contactsToUpdate.put(cm.contactID,new contact(id = cm.contactID, Campaign_Referred_Partner_ID__c = null));
                            }
                        }else if(cm.leadID != null){
                            if(idToPartnerIdMap.containsKey(cm.leadID) && !leadsToUpdate.containsKey(cm.leadID) ){
                                leadsToUpdate.put(cm.leadID,new lead(id = cm.leadID, Campaign_Referred_Partner_ID__c = null));
                            }
                        }
                    }
                }
            }
        }
       
         //Addition by Paramvir April 4,2016 end here
      
        // Added by Oshin on February 2, 2016
        if(campaignIdSetCustomSetting.isEmpty() 
                && campaignNameSetCustomSetting.isEmpty()) {
            for(campaign camp: [select id,name
                             from campaign where Event_Cap_Qualified__c = true and ID in :campaignIDs]){
                campaignIdSetCustomSetting.add(camp.id);
                campaignNameSetCustomSetting.add(camp.name);
            }
        }
         
        if(Trigger.isDelete){
            
            System.debug('__inside__delete__');
            
            for(SObject sobj : Trigger.old){
                CampaignMember cm = (CampaignMember)sobj;
                system.debug('@@CM Status' + cm.status + '     ------ Label - ' + Label.CampaignApprovedStatus +' --Label 2--' + Label.CampaignPartnerApprovedStatus + ' -----CampignId   ' + cm.campaignId + ' -----Custom Setting---  ' + campaignIdSetCustomSetting.contains(cm.campaignId));
                String status = cm.Status == null ? '' : cm.Status.trim().toLowerCase();
                if((status == 'registered' || status == 'partner registered') && campaignIdSetCustomSetting.contains(cm.campaignId)){
                    System.debug('___member_id__'+cm.id);
                    campaign_ids.add(cm.campaignId);
                    if(!approvedMemberBeingDeletedMap.containsKey(cm.campaignId)){
                        approvedMemberBeingDeletedMap.put(cm.campaignId,new Set<Id>{cm.Id});                          
                    }
                    else{
                        approvedMemberBeingDeletedMap.get(cm.campaignId).add(cm.id);
                    } 
                }
             }
             
             System.debug('__approvedMemberBeingDeletedMap__'+approvedMemberBeingDeletedMap);
             System.debug('__campaign_ids__'+campaign_ids);
             System.debug('__campaign_map__'+campaign_map);
             
             if(!campaign_ids.isEmpty()){
                 campaign_map = CampaignMemberGateway.getCampaigns(campaign_ids);
             }
             System.debug('__campaign_map__'+campaign_map);
                    
            if(!approvedMemberBeingDeletedMap.isEmpty()){
                for(Id campID : approvedMemberBeingDeletedMap.keyset()){
                    Campaign c = campaign_map.get(campId); 
                    
                    if(c.Maximum_Number_of_Subscribers__c != NULL && c.Maximum_Number_of_Subscribers__c >= 0){
                        c.Maximum_Number_of_Subscribers__c += approvedMemberBeingDeletedMap.get(campID).size();  
                    }
                    else if(c.Maximum_Number_of_Subscribers__c != NULL){
                        c.Maximum_Number_of_Subscribers__c = approvedMemberBeingDeletedMap.get(campID).size(); 
                    }
                    campaignToBeUpdated.add(c);
                }
            }
            System.debug('__campaignToBeUpdated___'+campaignToBeUpdated);
        }

        // #W-009847 Added by Hemendra Singh Rajawat on June 19, 2018
        if (!cmToStatusMap.isEmpty() && !cmToLeadIdMap.isEmpty()) {
            leadToUpdateList 
                = CampaignMemberGateway.updateLeads(cmToStatusMap, cmToLeadIdMap);
        }

        if (!cmToStatusMap.isEmpty() && !cmToContIdMap.isEmpty()) {
            contsToUpdate 
                = CampaignMemberGateway.updateContacts(cmToStatusMap, cmToContIdMap);
        }
    }
    
    public void beforeInsert(SObject so){
    
       CampaignMember cm = (CampaignMember) so;
       
       System.debug('__before_status__'+cm.status);
       System.debug('___campaign_map___'+campaign_map);
       System.debug('___contains_key???__'+campaign_map.containsKey(cm.CampaignId));
       
       
       if(cm.Status == 'Workshop Queue' && campaign_map.containsKey(cm.CampaignId)) {
           Campaign c = campaign_map.get(cm.CampaignId);
           
           System.debug('__campaign_name__'+c.name);
           //System.debug('___contains_key_in_custom_setting_???___'+campaignNameSetCustomSetting.contains(c.Name));
           System.debug('__available??___'+c.Maximum_Number_of_Subscribers__c);
           
           if(c.Event_Cap_Qualified__c == true){
                if(c.Maximum_Number_of_Subscribers__c != NULL && c.Maximum_Number_of_Subscribers__c  > 0) {
                    if(cm.contactId != null ){
                        if(partnerContactsIdSet.contains(cm.contactId)){
                            cm.Status = 'Partner Registered';  
                        }
                        else{
                             cm.Status = 'Registered';
                        }
                    }
                    else if(cm.leadid != null){
                        if(partnerLeadsIdSet.contains(cm.leadid)){
                            cm.Status = 'Partner Registered'; 
                        }
                        else{
                             cm.Status = 'Registered'; 
                        }
                    }
                    system.debug('cm.status==>'+ cm.Status);
                    system.debug('fieldcount==>'+ c.Maximum_Number_of_Subscribers__c);                    
                    c.Maximum_Number_of_Subscribers__c -= 1;
                    system.debug('@@@@@@@ Map before ' + campaigns_to_update);
                    campaigns_to_update.put(c.Id, c);
                    system.debug('@@@@@@@ Map after ' + campaigns_to_update);
                } else {
                        if(cm.contactId != null){
                            cm.Status = 'Waitlisted';
                        }
                        else if(cm.leadid != null){
                            cm.Status = 'Waitlisted';
                        }
                }
                
                System.debug('__after__'+cm.Status);
            }
            System.debug('__finalyy_available'+c.Maximum_Number_of_Subscribers__c);
        }
        
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        CampaignMember cm = (CampaignMember)so;
        CampaignMember cm_old = (CampaignMember) oldso;
        
        String old_status = cm_old.Status == null ? '' : cm_old.Status.trim().toLowerCase();
        String new_status = cm.Status == null ? '' : cm.Status.trim().toLowerCase();
        
        if(old_status == 'waitlisted' && (new_status == 'partner registered' || new_status == 'registered'||
            new_status == 'workshop queue') && campaignIdSetCustomSetting.contains(cm.campaignId)) {
            Campaign c = campaign_map.get(cm.CampaignId);
                
            if(c.Event_Cap_Qualified__c == true){
                if(c.Maximum_Number_of_Subscribers__c != NULL &&
                     c.Maximum_Number_of_Subscribers__c  > 0) {
    
                    if(cm.contactId != null ){
                        if(partnerContactsIdSet.contains(cm.contactId)){
                            cm.Status = 'Partner Registered';  
                        }else{
                            cm.Status = 'Registered';
                        }
                    }else if(cm.leadid != null){
                        if(partnerLeadsIdSet.contains(cm.leadid)){
                            cm.Status = 'Partner Registered'; 
                        }
                        else{
                             cm.Status = 'Registered'; 
                        }
                    }
                    c.Maximum_Number_of_Subscribers__c -= 1;
                    campaigns_to_update.put(c.Id, c);
                    
                }else{
                    if(cm.contactId != null){
                        cm.Status = 'Waitlisted';
                    }else if(cm.leadid != null){
                        cm.Status = 'Waitlisted';
                    }
                }
            }
            
        }
    }
    
    public void beforeDelete(SObject so){
            
    }
    
    public void afterInsert(SObject so){
        CampaignMember cm = (CampaignMember)so;
        System.debug('cca> cm.HasResponded in afterInsert:' + cm.HasResponded);
        
        
        if(cm.LeadID != Null){
            leadIds2.add(cm.LeadID);
        }
        if(cm.ContactID != Null){
            conIds2.add(cm.ContactID);
        }
        
        if(!ranForCCAAfterInsert) {
            // Added by Oshin on Nov 3, 2016
            System.debug('cca> cm.hasResponded:' + cm.hasResponded);
            if(cm.hasResponded == true) {
                System.debug('cca> cm.ContactId:' + cm.ContactId);
                System.debug('cca> cm.LeadId:' + cm.LeadId);
                if(cm.ContactId != null) {
                    contactIds4.add(cm.ContactId);
                } else if(cm.LeadId != null) {
                    leadIds4.add(cm.LeadId);
                }
            }
        }        
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        CampaignMember cm = (CampaignMember)so;
        CampaignMember cm_old = (CampaignMember) oldso;
        System.debug('cca> cm.HasResponded in afterUpdate:' + cm.HasResponded);
        
        if(cm.LeadId != Null){
            leadIds3.add(cm.LeadID);
            cmIds3.add(cm.ID);
        }
        
        if(cm.ContactID != Null){
            conIds3.add(cm.ContactID);
            cmIds3.add(cm.ID);
        }

        if(!ranForCCAAfterUpdate) {
            // Added by Oshin on Nov 3, 2016
            System.debug('cca> cm.hasResponded:' + cm.hasResponded);
            if(cm.hasResponded == true && cm.hasResponded != cm_old.hasResponded) {
                System.debug('cca> cm.ContactId:' + cm.ContactId);
                System.debug('cca> cm.LeadId:' + cm.LeadId);
                if(cm.ContactId != null) {
                    contactIds4.add(cm.ContactId);
                } else if(cm.LeadId != null) {
                    leadIds4.add(cm.LeadId);
                }
            }
        }
    }

    public void afterDelete(SObject so){   
        CampaignMember cm = (CampaignMember)so;
        if(cm.LeadID != Null){
            leadIds1.add(cm.LeadID);
            cmIds1.add(cm.ID);
        }
        if(cm.ContactID != Null){
            conIds1.add(cm.ContactID);
            cmIds1.add(cm.ID);
        }      
    }

    public void andFinally(){
        // Added by Oshin on Nov 3, 2016
        if(!leadIds4.isEmpty()) {
            CampaignMemberGateway.updateChannelFromLeadCCA(leadIds4);
        }
        
        System.debug('cca> contactIds4.isEmpty():' + contactIds4.isEmpty());
        if(!contactIds4.isEmpty()) {
            CampaignMemberGateway.updateChannelFromContactCCA(contactIds4);
        }
    
        //Lead tracking for partner trials and campaigns(02-03-2016)
        if(!leadsToUpdate.isEmpty()){
            update leadsToUpdate.values();
        }
        if(!contactsToUpdate.isEmpty()){
            update contactsToUpdate.values();
        }
    
        System.debug('__in_finally___'+campaignToBeUpdated);
        if(!campaignToBeUpdated.isEmpty()){
            update campaignToBeUpdated;
        }
        if(leadIds1 != Null && leadIds1.Size() >0){
            CampaignMemberGateway cmg = new CampaignMemberGateway();
            upLead= cmg.Lead_Records_Update(leadIds1);
        }
        if(conIds1 != Null && conIds1.Size() >0){
            CampaignMemberGateway cmg = new CampaignMemberGateway();
            upCon= cmg.Contact_Records_Update(conIds1);
        }
        if(leadIds2 != Null && leadIds2.Size()>0){
            CampaignMemberGateway cmg = new CampaignMemberGateway();
            upLead= cmg.Lead_Records_Update(leadIds2);
        }
        if(conIds2 != Null && conIds2.Size()>0){
            CampaignMemberGateway cmg = new CampaignMemberGateway();
            upCon= cmg.Contact_Records_Update(conIds2);
        }
        if(leadIds3 != Null && leadIds3.Size()>0){
            CampaignMemberGateway cmg = new CampaignMemberGateway();
            upLead= cmg.Lead_Records_Update(leadIds3);
        }
        if(conIds3 != Null && conIds3.Size() >0){
            CampaignMemberGateway cmg = new CampaignMemberGateway();
            upCon= cmg.Contact_Records_Update(conIds3);
        }        
        Try{
            if(upLead != Null && upLead.Size() > 0 && bool == true){
                update upLead;
                bool = false;
            }
        }
        Catch(Exception e){
            for(Lead l :upLead){
                l.addError('Can not Update Lead'+e.getMessage());
            }
        }
        Try{
            if(upCon != Null && upCon.Size() > 0){
                update upCon;
            }
        }
        Catch(Exception e){
            for(Contact c :upCon){
                c.addError('Can not Update Contact'+e.getMessage());
            }
        }
        
        if(!campaigns_to_update.isEmpty()) {
           try {
                update campaigns_to_update.values();
            } catch(Exception ex) { for(Campaign c : campaigns_to_update.values()) {c.addError('Can\'t update Campaign ' + ex.getMessage()); } }
        }

        try {
            if (!leadToUpdateList.isEmpty()) {
                update leadToUpdateList;
            }
            if (!contsToUpdate.isEmpty()) {
                update contsToUpdate;
            }
        } catch (Exception ex) {
            List<CampaignMember> cmsList 
                = (List<CampaignMember>) Trigger.new;

            for (CampaignMember cm : cmsList) { 
                Exception cause = ex.getCause();
                String msg = (cause != null) 
                             ? cause.getMessage() : ex.getMessage();

                cm.addError(msg); 
            }
        }
    }
}