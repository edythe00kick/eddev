/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
trigger dlrs_Apttus_Proposal_Proposal_a4ETrigger on Apttus_Proposal__Proposal_Line_Item__c
    (before delete, before insert, before update, after delete, after insert, after undelete, after update)
{
    dlrs.RollupService.triggerHandler(Apttus_Proposal__Proposal_Line_Item__c.SObjectType);
}