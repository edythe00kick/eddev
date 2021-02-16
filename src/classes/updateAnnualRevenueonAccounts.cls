/*
* @name : updateAnnualRevenueonAccounts : a batch class which updates Account records with information from Data.com's D&B information
* @author : Unknown
* @date : 20151215
* @modified : Cs 00182103 - JPH - 20171103 : Updated the Code coverage to 90%   adjusted to use the non-Datacloud records of D&B Company info Changed from the calculation from SalesVolume to Revenue Added Descriptive Comments
* @testclass : Test_updateAnnualRevenueonAccounts.cls
*/

global class updateAnnualRevenueonAccounts implements Database.Batchable<sObject>{
    //jp public String myaccountId=''; // Used for test code only

    public Map<String,Account> mapInitialDUNStoAccount = new Map<String,Account>();
    public Map<String,Set<String>> mapInitalDUNStoRelatedDUNS = new Map<String,Set<String>>();
    public Map<String,String> mapDUNStoUltParentDUNS = new Map<String,String>();
    public Map<String,String> mapDUNStoParentDUNS = new Map<String,String>();
    public Map<String,String> mapDUNStoDomesticDUNS = new Map<String,String>();

    public Set<String> setFullDUNSList = new Set<String>();

    public Map<String,String> mapFullAccountDunsList = new Map<String,String>();
    public Map<String,String> mapDUNStoAccountName = new Map<String,String>();
    public Map<String,String> tempCountryMap = new Map<String,String>();

    public Map<String,Account> finalaccountmap = new Map<String,Account>(); 
    public Map<String,Decimal> dbRevenueMap = new Map<String,Decimal>(); //Map to put DandB Revenue amount into

    public list<String> dbCalculateRevenue = new list<String>();
    public List<Account> updatedAccList = new List<Account>();

    // 
    // @name : start  
    // @description : Create the set of accounts to update, return this list to the database for processing. If Testing, feed in Id's directly.
    //          If this is running not as a test, find all accounts with either GU Parent, Parent Revenue or Name being Blank.
    //
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query='';

        //Query all accounts where Global Ultimate Parent Name, Global Ultimate Parent Revenue, Parent Company Name and Parent Annual Revenue fields are empty
        query = 'SELECT Id,DandbCompanyid,dunsnumber,Secondary_Annual_Revenue__c, Name,AnnualRevenue, Global_Ultimate_Parent_Name__c,Global_Ultimate_Parent_Revenue__c,Parent_Company_Name__c,Parent_Annual_Revenue__c FROM Account WHERE DunsNumber != NULL AND (Last_D_B_Information_Update_Date__c < LAST_N_DAYS:90 OR Last_D_B_Information_Update_Date__c = NULL OR Global_Ultimate_Parent_Name__c = NULL OR Global_Ultimate_Parent_Revenue__c = NULL OR Parent_Company_Name__c = NULL OR Parent_Annual_Revenue__c = NULL)';

        return Database.getQueryLocator(query);
    }

    // 
    // @name : execute  
    // @description : 
    //  1 - Clean the Duns number on the account to match the 9 digit format by adding leading 0s to the number.
    //  2 - Map all of the necessary DUNS numbers for use in queries late. Create maps from Account to related DUNS numbers.
    //  3 - Create a mapping from the Duns numbers to the revenue amounts. If the revenue is unavailable, calculate the revenue using the available SalesTurnoverGrowthRate and PriorYearRevenue.
    //  4 - Create final map to update accounts with Global Parent, Parent and Domestic Parent information included
    //
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Account> scopeList = (List<Account>)scope;

        system.debug('scopeList==>'+scopeList);

        // 1 : Format DUNS Numbers if needed, then fill the list of accounts to be updated based on which accounts have a DUNS number available
        for(Account a : scopeList ){
            // Process ony those accounts that have a D-U-N-S Number
            if(a.dunsnumber != NULL){
                String dnumber =  a.dunsnumber;
                Integer len = a.dunsnumber.length();
                
                //Check if length of D-U-N-S Number is less than 9 and add zeroes as per the difference in the beginning of the D-U-N-S Number
                if(len < 9){
                    for(integer i=9-len;i>0;i--){
                        dnumber = '0'+dnumber;
                    }
                }

            //Map of Duns Number to Account Record
            mapInitialDUNStoAccount.put(dnumber,a);                 
            }
        }

        system.debug('mapInitialDUNStoAccount==>'+mapInitialDUNStoAccount);

        // 2 : Map all related Parent, GLobal Parent, and Domestic Parent Duns numbers
        if(!mapInitialDUNStoAccount.isEmpty()){
            // JPH - Cs 00182103 : Moved isrunningtest() portion internally to increase test code 
            // 2a : Query all DataCloudDandBCompany records whose DUNSNumber lies in the mapInitialDUNStoAccount map's keyset.
            if(!test.isrunningtest()){
                for(DatacloudDandBcompany db : [select id, DunsNumber, name, SalesVolume, PriorYearRevenue, SalesTurnoverGrowthRate, DomesticUltimateDunsNumber, DomesticUltimateBusinessName, ParentOrHqBusinessName, ParentOrHqDunsNumber, GlobalUltimateBusinessName, GlobalUltimateDunsNumber from DatacloudDandBcompany where DunsNumber in : mapInitialDUNStoAccount.keyset() LIMIT 100 ]){
                    if(db.GlobalUltimateDunsNumber != NULL &&  db.ParentOrHqDunsNumber != NULL && db.DomesticUltimateDunsNumber != NULL){
                        mapInitalDUNStoRelatedDUNS.put(db.dunsnumber,new Set<String>{db.GlobalUltimateDunsNumber, db.ParentOrHqDunsNumber,db.DomesticUltimateDunsNumber});
                        mapDUNStoUltParentDUNS.put(db.dunsnumber,db.GlobalUltimateDunsNumber);
                        mapDUNStoParentDUNS.put(db.dunsnumber,db.ParentOrHqDunsNumber);
                        mapDUNStoDomesticDUNS.put(db.dunsnumber,db.DomesticUltimateDunsNumber);
                    }
                }   
            } else {
                for(DandBcompany db : [select id,DunsNumber,name,SalesVolume,PriorYearRevenue,SalesTurnoverGrowthRate,DomesticUltimateBusinessName,DomesticUltimateDunsNumber,ParentOrHqBusinessName,ParentOrHqDunsNumber,GlobalUltimateBusinessName,GlobalUltimateDunsNumber from DandBcompany where DunsNumber in : mapInitialDUNStoAccount.keyset() LIMIT 100 ]){
                    if(db.GlobalUltimateDunsNumber != NULL &&  db.ParentOrHqDunsNumber != NULL && db.DomesticUltimateDunsNumber != NULL){
                        mapInitalDUNStoRelatedDUNS.put(db.dunsnumber,new Set<String>{db.ParentOrHqDunsNumber, db.GlobalUltimateDunsNumber,db.DomesticUltimateDunsNumber});
                        mapDUNStoUltParentDUNS.put(db.dunsnumber,db.GlobalUltimateDunsNumber);
                        mapDUNStoParentDUNS.put(db.dunsnumber,db.ParentOrHqDunsNumber);
                        mapDUNStoDomesticDUNS.put(db.dunsnumber,db.DomesticUltimateDunsNumber);
                    }
                }
            }
        }

        system.debug('mapInitalDUNStoRelatedDUNS==>'+mapInitalDUNStoRelatedDUNS);
        system.debug('mapInitalDUNStoRelatedDUNS.values() : '+ mapInitalDUNStoRelatedDUNS.values());

        if(!mapInitalDUNStoRelatedDUNS.isEmpty()){
            //Merge all the parent and global parent DUNSNumbers in one set
            for(Set<String> DCDandBCompanyDUNSNumbers : mapInitalDUNStoRelatedDUNS.values()){
                setFullDUNSList.addall(DCDandBCompanyDUNSNumbers);
            }
        }

        system.debug('setFullDUNSList==>'+setFullDUNSList);

        // 3 : Map available Revenue from the cloud, create mapDUNStoAccountName, if revenue is unavailable, check whether we can calculate the value from the Cloud and add to the map 
        if(!setFullDUNSList.isEmpty()){ 
            Decimal tempRev = 0;
            list<String> tempCompanyId = new list<string>();
            map<String,String> tempComptoDUNSLookup = new map<string,string>();

            //JPH - Cs 00182103 : Commented out to use the DandBCompany object, which can be used in test code.
            //Query all DataCloudDandBCompany records whose DUNSNumber lies in the setFullDUNSList.
            if(!test.isrunningtest()){
                for(DatacloudDandBCompany db : [SELECT id,DunsNumber,name, CompanyId, Country FROM DatacloudDandBCompany WHERE DunsNumber IN : setFullDUNSList LIMIT 100 ]){
                    mapDUNStoAccountName.put(db.dunsnumber, db.name);
                    tempCountryMap.put(db.dunsnumber,db.Country);
                    mapFullAccountDunsList.put(db.dunsnumber, db.CompanyId);
                    tempCompanyId.add(db.CompanyId);
                    tempComptoDUNSLookup.put(db.CompanyId, db.dunsnumber);
                }

                if(!mapFullAccountDunsList.isEmpty()){
                    for(DatacloudCompany db : [SELECT id,DunsNumber,name,AnnualRevenue, CompanyId, Country FROM DatacloudCompany WHERE CompanyId IN : tempCompanyId LIMIT 100 ]){
                        String tempDUNS = tempComptoDUNSLookup.get(db.CompanyId);
                        if(db.AnnualRevenue > 0 && db.AnnualRevenue != null){
                            dbRevenueMap.put(tempDUNS, db.AnnualRevenue);   
                        } else {
                            dbCalculateRevenue.add(db.CompanyId);
                        }
                    }

                    for(DatacloudDandBCompany db : [SELECT id,DunsNumber,name, CompanyId, PriorYearRevenue, SalesTurnoverGrowthRate FROM DatacloudDandBCompany WHERE CompanyId IN : dbCalculateRevenue LIMIT 100 ]){
                        if(db.PriorYearRevenue != null && db.SalesTurnoverGrowthRate != null){
                            tempRev = (db.PriorYearRevenue * (1 + db.SalesTurnoverGrowthRate));
                            dbRevenueMap.put(db.dunsnumber, tempRev);   
                        } else {
                            dbRevenueMap.put(db.dunsnumber, 0);
                        }   
                    }
                }

            } else {
                for(DandBcompany db : [select id,DunsNumber,name,PriorYearRevenue,SalesTurnoverGrowthRate, Country from DandBcompany where DunsNumber in : setFullDUNSList Limit 100 ]){
                    if(db.name != NULL &&  db.PriorYearRevenue != NULL && db.SalesTurnoverGrowthRate != NULL){
                        tempRev = (db.PriorYearRevenue * (1 + db.SalesTurnoverGrowthRate));
                        dbRevenueMap.put(db.dunsnumber, tempRev); //add value to be used for Revenue mapping to records. - JPH - Cs 00182103
                        mapFullAccountDunsList.put(db.dunsnumber, db.dunsnumber);
                        mapDUNStoAccountName.put(db.dunsnumber, db.name);
                        tempCountryMap.put(db.dunsnumber,db.Country);
                    }
                }
            }
        }

        system.debug('mapFullAccountDunsList==>'+mapFullAccountDunsList);

        // 4 : Loop through each account to update by DUNS, Gather related DUNs information, create the finalAccountMap which will update the infromation on the account.
        //check if we found DataCloudDandBCompany records corresponding to the DUNSNumbers in the setFullDUNSList
        if(!mapFullAccountDunsList.isEmpty()){

            //Iterate on the mapInitialDUNStoAccount map's keyset
            for(String DNumber : mapInitialDUNStoAccount.keyset()){  
                Account acc = mapInitialDUNStoAccount.get(DNumber); //find the related Account from the DUNS

                //find the related parent account infromation
                if(mapInitalDUNStoRelatedDUNS.containskey(DNumber)){

                    //hold the value of the parents DUNS number
                    Set<String> ParentandGlobalDUNSNumbers = mapInitalDUNStoRelatedDUNS.get(DNumber); 

                    //JPH - Cs 00182103 : Commented out to use the DandBCompany object, which can be used in test code.
                    String tempGUDUNS = mapDUNStoUltParentDUNS.get(DNumber);
                    String tempPRDUNS = mapDUNStoParentDUNS.get(DNumber);
                    String tempDomesticDUNS = mapDUNStoDomesticDUNS.get(DNumber);

                    if( tempGUDUNS == '000000000' ){ tempGUDUNS = DNumber; }
                    if( tempPRDUNS == '000000000' ){ tempPRDUNS = DNumber; }
                    if( tempDomesticDUNS == '000000000' ){ tempDomesticDUNS = DNumber; }

                    // 4 : BEGIN CREATION OF THE finalaccountmap
                    //cycle through the list of parent DUNS numbers
                    for(String ParentorGlobalParentDUNSNumber : ParentandGlobalDUNSNumbers ){

                        //If the parent DUNs is available in the map we created, we will update the information on the appropriate account
                        if(mapFullAccountDunsList.containsKey(ParentorGlobalParentDUNSNumber) || ParentorGlobalParentDUNSNumber == '000000000'){
                            String tempNameDUNS = '';
                            Decimal tempDandBRev = 0;
                            String tempCountry = '';
                            
                            //system.debug('***** ParentorGlobalParentDUNSNumber : '+ ParentorGlobalParentDUNSNumber);
                            if(ParentorGlobalParentDUNSNumber == '000000000' || ParentorGlobalParentDUNSNumber == DNumber){
                                ParentorGlobalParentDUNSNumber = DNumber;
                                tempDandBRev = dbRevenueMap.get(DNumber);
                                tempNameDUNS = mapDUNStoAccountName.get(DNumber);
                                tempCountry = tempCountryMap.get(DNumber);
                            } else {
                                tempDandBRev = dbRevenueMap.get(ParentorGlobalParentDUNSNumber);
                                tempNameDUNS = mapDUNStoAccountName.get(ParentorGlobalParentDUNSNumber);     
                                tempCountry = tempCountryMap.get(DNumber);                              
                            }

                            //update the global ultimate parent information on each account
                            if(tempGUDUNS == ParentorGlobalParentDUNSNumber ){  
                                acc.Global_Ultimate_Parent_Name__c = tempNameDUNS;
                                acc.Global_Ultimate_DUNS_Number__c = ParentorGlobalParentDUNSNumber;
                                acc.Global_Ultimate_Parent_Revenue__c = tempDandBRev; //Add Revenue Lookup - JPH - Cs 00182103
                                acc.Global_Ultimate_Parent_Account_Country__c = tempCountry;
                                acc.Last_D_B_Information_Update_Date__c = date.today();
                                finalaccountmap.put(acc.Id,acc);
                            }

                            system.debug('*** JP *** : tempPRDUNS : '+ tempPRDUNS + '; ' + ParentorGlobalParentDUNSNumber);
                            //update the immediate parent information on each account
                            if(tempPRDUNS == ParentorGlobalParentDUNSNumber){
                                acc.Parent_Company_Name__c= tempNameDUNS;
                                acc.Parent_DUNS_Number__c = ParentorGlobalParentDUNSNumber;
                                acc.Parent_Annual_Revenue__c = tempDandBRev; //Add Revenue Lookup - JPH - Cs 00182103
                                acc.Parent_Account_Country__c = tempCountry;
                                acc.Last_D_B_Information_Update_Date__c = date.today();
                                finalaccountmap.put(acc.Id,acc);
                            }

                            if(tempDomesticDUNS == ParentorGlobalParentDUNSNumber){
                                acc.Domestic_Ultimate_Business_Name__c = tempNameDUNS;
                                acc.Domestic_Ultimate_DUNS_Number__c = ParentorGlobalParentDUNSNumber;
                                acc.Domestic_Ultimate_Annual_Revenue__c = tempDandBRev; //Add Revenue Lookup - JPH - Cs 00182103
                                acc.Domestic_Ultimate_Parent_Country__c = tempCountry;
                                acc.Last_D_B_Information_Update_Date__c = date.today();
                                finalaccountmap.put(acc.Id,acc);
                            }
                        }
                    }
                }
            }
        }

        //finally fill the update list of changes with our information built in the previous steps
        if(!finalaccountmap.isEmpty()){
            updatedAccList.addAll(finalaccountmap.values());
        }
        
        system.debug('finalaccountmap==>'+finalaccountmap);
        system.debug('updatedAccList==>'+updatedAccList);

        //perform the update to the list of accounts.
        if(!updatedAccList.isEmpty()){
            try{update updatedAccList;}catch(Exception e){system.debug('Exception occured=================>'+e.getmessage());}
        }
    }   

    global void finish(Database.BatchableContext BC){}
}