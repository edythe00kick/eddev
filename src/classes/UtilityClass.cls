public class UtilityClass {

    public static boolean insertTask_SendThanksEmailIsFirstRun= true;
    public static boolean fireAssignmentRuletriggerOnce=false;
    public static boolean fireTaskTriggerOnce = false;  
    public static boolean ProposalTriggerOnStageChanegerunOnce= true; 
    public static boolean setPricebookOnOpportunityIsFirstRun= true;
    public static boolean CheckContactRoleIsFirstRun= true;
    public static boolean fillMasterAgreementQuoteIsFirstRun = true;
    public static boolean updateLeadWithFirstCampaignIsFirstRun = true;
    public static boolean updateNBECRoadMapIsFirstRun = true;
    public static boolean createNBECroadMapIsFirstRun = true;
    public static boolean SetOpportunityOwnerIsFirstRun = true;
    public static boolean updateOppWith1strespondedCampaignIsFirstRun = true;
    public static boolean resendToBoomiIsFirstRun = false; //Name: Chris Salgado Date: 10/3/2019 Purpose: W-013317
    public static Proposal_Settings__mdt proposalSettings;
    /*public static map < String, RecordType > RecordTypeNamemap() {
        map < String, RecordType > nameRecordTypemap = new map < String, RecordType > ();
        list < RecordType > recordTypelist = new list < RecordType > ();
        // Querying all the Record Types from the system
        recordTypelist = [select Id, BusinessProcessId, Description, DeveloperName, IsActive, Name, NamespacePrefix, SobjectType from RecordType];
        if (recordTypelist <> null && recordTypelist.size() > 0) {
            // Creating a map of Record Type Name vs Record Type Map
            for (RecordType RT: recordTypelist)
                nameRecordTypemap.put(RT.Name, RT);
        }
        return nameRecordTypemap;
    }*/
    
    public static Map<String, Double> getConversionRates(){
        Map<String, Double> conversionRatesMap = new Map<String,Double> ();

        for (CurrencyType curr: [SELECT IsoCode, ConversionRate
                                    FROM CurrencyType]) {
                                    
            conversionRatesMap.put(curr.IsoCode, curr.ConversionRate);
        }
        
        return conversionRatesMap;
    }

    //Sergio Flores
    //Date: 05/20/2019
    //CPQ Refactoring: W-011711
    public static Proposal_Settings__mdt getProposalSettings(string settingName){
        String propSettingFields = String.join(new List<String>(Schema.SObjectType.Proposal_Settings__mdt.fields.getMap().keySet()),',');
        List<Proposal_Settings__mdt> mySettings = Database.query('SELECT ' + propSettingFields 
                                                                 + ' FROM Proposal_Settings__mdt WHERE DeveloperName = :settingName');
        if(mySettings != null){
            proposalSettings = mySettings[0];
            return mySettings[0];
        } else {
            return null;
        }
        
    }


}