@isTest
private class TestIncumbentTechSearchController {
    @isTest
    private static void testController() {
        Incumbent_Technology__c it = new Incumbent_Technology__c();
        it.Name = 'Test IT';
        insert it;
        
        IncumbentTech_SearchController itsc = new IncumbentTech_SearchController();
        itsc.getAccountIndustryValues();
        itsc.getIncumbentTechTechnologyValues();
        itsc.getAccountTypeValues();
        itsc.getIncumbentCompetitorValues();
        itsc.getIncumbentTechNames();
        
        itsc.industry = 'Former Customer';
        itsc.technology = 'Cloudera';
        itsc.technologyType = 'Big Data';
        itsc.accountType = 'Former Customer';
        itsc.competitor = 'true';
        itsc.doSearch();
        itsc.doSearch();
        
        itsc.setNextPage();
        itsc.getNextPage();
        itsc.setPreviousPage();
        itsc.getPreviousPage();
    }
}