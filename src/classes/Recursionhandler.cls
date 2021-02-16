Public class Recursionhandler{
    public static boolean IsleadTriggerExecuted=false;
    public static boolean IsProposalTriggerExecuted=false;
    public static boolean IsLicenseKeyTriggerExecuted=false;
    public static boolean IsOrderGroupTriggerExecuted=false;
    public static boolean IsDealActivityContactTriggerExecuted=false;
    public static boolean OpportunitySplitTriggerExecuted=false;
    public static boolean ProductConfigurationTriggerExecuted=false;
    public static boolean IsOpportunityLineItemTriggerExecuted=false;
    public static boolean IsOppStampOnClosedWonExecuted=false;
    public static boolean QuoteHistoricImportHandlerExecuted=false;
    public static boolean IsContactTriggerExecuted=false;
    public static boolean IsLeadSendEmailExecuted=false; // Added by: Sharma Nemani | W-002548 | To handle recursion for sending email |Date: 01/16/2020

    //Adding a check here to see if anything is inserted originally then updated in same transaction
    public static boolean IsContactTriggerInserted=false;
    public static boolean IsOpportunityQueuableExecuted=false;
    public static boolean IsLeadSLAQueuableExecuted=false;
    public static boolean IsContactSLAQueuableExecuted=false;
    public static boolean IsFutureECURQueueableExecuted=false;
    public static boolean checkOverlaySplitOnClosedWon=false;
    public static boolean IsCampaignMemberExecuted=false;
    public static boolean IsCMUpdateLeadsExecuted=false;
    public static boolean IsCMUpdateContactsExecuted=false;
    public static boolean IsLeadUTMTriggerExecuted=false;
    public static boolean IsContactUTMTriggerExecuted=false;
    public static boolean IsCustomerSurveyAlertSent=false;
    public static boolean IsCoTermSubscriptionQueueableExecuted=false; //SF 01/23/2020 W-013849
    public static boolean IsOpportunitySplitCreated=false; //Sharma Nemani | W-004453 02/05/2020
    public static boolean IsBatchOppUpdateRenewalOrRnRExecuted=false; //EW || 05-07-2020 || W-002539
    public static boolean IsSyncPrimaryContactCurrencytoOppExecuted=false; //EW || 05-08-2020 || W-005264

    public static boolean IsOppSendEmailExecutedInAfterUpdate=false;
    public static boolean IsOppSendEmailForCallidusExecuted=false; //SF 06/29/2020 W-001151
    public static boolean IsOppSendEmailExecutedInBeforeUpdate=false;
    public static boolean IsquoteUpdatedTCV=false;//SF 02/21/2020 W-004548
    public static boolean IsBatchUpdateCampaignMemberUTMExecuted =false;//SF 03/20/2020 W-004820
    public static boolean IsBatchUpdateCampaignMemberUTMContactExecuted =false; //SF 04/01/2020 W-004929
    public static boolean IsBundleQuoteLinesExecuted =false; //Name: Chris Salgado Date: 4/22/20 Purpose: W-005056
    public static boolean IsAccountOwnerOppSplitAdded = false; //Name: Chris Salgado Date: 5/14/20 Purpose: W-004453
    public static boolean IsAccountOwnerOppSplitUpdated = false; //Name: Chris Salgado Date: 5/14/20 Purpose: W-004453
    // public static boolean isQuoteOnUpdate = false;

    //Name: Chris Salgado Date: 5/2/20 Purpose: W-005251 (CM Refactor)
    public static boolean ranForCCAAfterInsert = false;
    public static boolean ranForCCAAfterUpdate = false;
    public static boolean cmUpdateLeadBool = true;

    public static boolean IsCkaBoardChangeExecuted = false; //Eddie Wong 05/01/2020 W-005057
    public static boolean IsContractAmendExecuted = false; //Eddie Wong 05/01/2020 W-005057
    public static boolean IsLPUToBoomiExecuted = false; //Eddie Wong 09/17/2020 W-005994
    public static boolean IsGTMOppGlobalRankingUpdateExecuted = false; //Eddie Wong 01/21/2021 W-007069

}