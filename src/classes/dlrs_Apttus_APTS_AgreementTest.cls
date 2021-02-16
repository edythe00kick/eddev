/**
 * Auto Generated and Deployed by the Declarative Lookup Rollup Summaries Tool package (dlrs)
 **/
@IsTest
private class dlrs_Apttus_APTS_AgreementTest
{
    @IsTest
    private static void testTrigger()
    {
        // Force the dlrs_Apttus_APTS_AgreementTrigger to be invoked, fails the test if org config or other Apex code prevents this.
        dlrs.RollupService.testHandler(new Apttus__APTS_Agreement__c());
    }
}