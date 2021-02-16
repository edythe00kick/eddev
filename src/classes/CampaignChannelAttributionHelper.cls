/*
 * Contains methods to help perform operations on "Campaign Channel
 * Attribution" field on Leads and Contacts.
 */
public without sharing class CampaignChannelAttributionHelper {
    /* 
     * Check that "Campaign Channel Attribution" field value is in
     * the syntax: <value>;<value>;<value>
     */
    public static boolean checkCCA(String val) {
        Integer first_semi_colon = val.indexOf(';');
        if(first_semi_colon != -1) {
            String temp_val = val.subString(first_semi_colon + 1, val.length());
            Integer second_semi_colon = temp_val.indexOf(';');
            if(second_semi_colon != -1) {
                if(val.subString(0, first_semi_colon).length() > 0
                        && temp_val.subString(second_semi_colon + 1, temp_val.length()).length() > 0) {
                    return true;
                }
            }
        }
        return false;
    }
    
    /* 
     * Get campaign member corresponding to (lead id/contact id) and id of campaign
     * mentioned in "Campaign Channel Attribution" field.
     *
     * @param    rec_ids                        Set of ids of lead/contact
     * @param    campaign_ids                   Set of ids of campaigns
     * @param    recIdToMostRecentCampaignId    A map of lead/contact id and "Most Recent Campaign Id"
     *
     */
    /*public static Map<Id, CampaignMember> getCampaignMemberFromCCA(Set<Id> rec_ids
            , Set<Id> campaign_ids
            , Map<Id, Id> recIdToMostRecentCampaignId
            , String rec_type) {
        Map<Id, CampaignMember> rec_id_to_recent_cm = new Map<Id, CampaignMember>();
        List<CampaignMember> cms = new List<CampaignMember>();
        if(rec_type == 'lead') {
            cms = LeadGateway.getCampaignMembers(rec_ids, campaign_ids);
        } else {
            cms = ContactGateway.getCampaignMembers(rec_ids, campaign_ids);
        }
        
        System.debug('cha> cms:' + cms);
        
        for(CampaignMember cm : cms) {
            Id campaign_id = '';
            if(rec_type == 'lead') {
                campaign_id = recIdToMostRecentCampaignId.get(cm.LeadId);
            } else {
                campaign_id = recIdToMostRecentCampaignId.get(cm.ContactId);
            }
            if(cm.CampaignId == campaign_id) {
                rec_id_to_recent_cm.put(cm.LeadId, cm);
            }
        }
        
        System.debug('cha> rec_id_to_recent_cm:' + rec_id_to_recent_cm);
        
        return rec_id_to_recent_cm;
    }*/
    
    
    /*
     * Update Channel field on Campaign Member from third value stored
     * in "Campaign Channel Attribution" field on lead/contact
     *
     * @param    rec_id_to_recent_cm                        A map of lead/contact id to most recent responded campaign member
     * @param    recIdToLeadAndContactSourceMostRecent      A map of lead/contact id to "Lead Source - Most Recent"/"Contact Source - Most Recent" field respectively
     *
     */
    /*public static void updateCampaignMemberCCA(Map<Id, CampaignMember> rec_id_to_recent_cm
            ,  Map<Id, String> recIdToLeadAndContactSourceMostRecent) {
        List<CampaignMember> cms = new List<CampaignMember>();
        
        for(Id rec_id : rec_id_to_recent_cm.keySet()) {
            CampaignMember cm = rec_id_to_recent_cm.get(rec_id);
            if(recIdToLeadAndContactSourceMostRecent.containsKey(cm.LeadId)) {
                String lead_source_most_recent = recIdToLeadAndContactSourceMostRecent.get(cm.LeadId);
                cm.Lead_Source_Most_Recent__c = lead_source_most_recent;
            }
            System.debug('lg> cm.Lead_Source_Most_Recent__c:' 
                + cm.Lead_Source_Most_Recent__c);
            cms.add(cm);
        }
        
        update cms;
    }*/
}