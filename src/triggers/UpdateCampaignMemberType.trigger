trigger UpdateCampaignMemberType on CampaignMember (after insert,after update,after delete, before insert, before update,before delete) {
    TriggerFactory.createHandler(CampaignMember.sObjectType);
}
// This Trigger Updates the Lead and Contact (Campaign Member Type Field) when a Responded Campaign Member is Added to them.//