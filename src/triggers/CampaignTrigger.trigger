/*
Test Class- TestCampaignTrigger
*/
trigger CampaignTrigger on Campaign (before insert, before update, after insert) {
    
    TriggerFactory.createHandler(Campaign.sObjectType);
}