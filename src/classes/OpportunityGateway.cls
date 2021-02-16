public without sharing class OpportunityGateway
{
    /*Commented by Paramvir on 27January,2016 as we don't need this anymore
    public static void createAccountTeamMembers (Set <String> accountIdSet)
    {
    Set<String> zipCodesSet = new Set<String>();
    Set<String> allUserIdsSet = new Set<String>();
    Set<String> SalesRegionandTerritorySet = new Set<String>();
    Set<String> ExpandRegionandTerritorySet = new Set<String>();
    Map<String,String> accountIds2BillingPostalCode = new Map<String,String>();
    Map<String,String> accountIds2BillingCity = new Map<String,String>();
    
    Map<String,String> zipCodeId2SalesRegionandTerritory = new Map<String,String>();
    Map<String,String> zipCodeId2ExpandRegionandTerritory = new Map<String,String>();
    Map<String,Set<String>> salesRegionandTerritory2UserList= new Map<String,Set<String>>();
    Map<String,Set<String>> expandRegionandTerritory2UserList = new Map<String,Set<String>>();
    Map<String,Integer> userId2CountofAccounts = new Map<String,Integer>();
    List<Account> accountList = new List<Account>();
    List<Account> updatedaccountList = new List<Account>();
    List<AccountTeamMember> accountTeammemberstobeInserted = new List<AccountTeamMember>();
    Set<Id> accountOwnerIdsModified = new Set<Id>();
    Set<String> accountBillingPostalCodeandCity = new Set<String>();
    Map<String,Account> accountId2Account = new Map<String,Account>();
    Map<String,Set<String>> zipCode2ZipCodeIdandName = new Map<String,Set<String>>();
    Map<String,String> zipCodeandCityId2ExpandRegionandTerritory = new Map<String,String>();
    
        if(accountIdSet != NULL){
            for(Account a : [select id,Gallery__c,name,annualrevenue,billingpostalcode,billingcity,Commercial_Expand_Rep__c,ownerid from Account where id in : accountIdSet AND AnnualRevenue != NULL AND Billingpostalcode != NULL AND Billingcity != NULL AND Gallery__c = FALSE AND Strategic__c = FALSE]){
                //if(a.AnnualRevenue != NULL && a.billingpostalcode != NULL && a.billingcity != NULL){
                    if(a.AnnualRevenue < 1000000000){
                        zipCodesSet.add(a.billingpostalcode);
                        accountIds2BillingPostalCode.put(a.id,a.billingpostalcode);
                        accountIds2BillingCity.put(a.id,a.billingcity);
                        accountBillingPostalCodeandCity.add(a.billingpostalcode+a.billingcity);
                        accountId2Account.put(a.id,a);
                    }
                //}
            }

            system.debug('zipCodesSet===============>'+zipCodesSet);
            system.debug('accountIds2BillingPostalCode===============>'+accountIds2BillingPostalCode);
            if(!zipCodesSet.isEmpty()){
                for(pw_ccpro__ZipCode__c  zc :[select id,pw_ccpro__City__c,Land_Sales_Region__c,Land_Sales_Territory__c,Zip_Code_Sales_Region__c,Zip_Code_Sales_Territory__c,Name from pw_ccpro__ZipCode__c where name in: accountIds2BillingPostalCode.values() and pw_ccpro__City__c in: accountIds2BillingCity.values() ]){
                    
                    if(zc.Zip_Code_Sales_Region__c != NULL && zc.Zip_Code_Sales_Territory__c != NULL){
                        if(accountBillingPostalCodeandCity.contains(zc.name+zc.pw_ccpro__City__c)){
                            zipCodeId2ExpandRegionandTerritory.put(zc.id+zc.name,zc.Zip_Code_Sales_Territory__c+zc.Zip_Code_Sales_Region__c);
                            zipCodeandCityId2ExpandRegionandTerritory.put(zc.name+zc.pw_ccpro__City__c,zc.Zip_Code_Sales_Territory__c+zc.Zip_Code_Sales_Region__c);                            
                        }
                    }    
                }    
            }
            
            system.debug('zipCodeId2SalesRegionandTerritory===============>'+zipCodeId2SalesRegionandTerritory);
            system.debug('zipCodeId2ExpandRegionandTerritory===============>'+zipCodeId2ExpandRegionandTerritory);
              
                for(String s : zipCodeId2ExpandRegionandTerritory.values()){
                        ExpandRegionandTerritorySet.add(s);
                }
            system.debug('ExpandRegionandTerritorySet===============>'+ExpandRegionandTerritorySet);
                for(User u :[select id,Test_User__c,Sales_Team__c,Sales_Region__c,Sales_Territory__c,Do_Not_Assign_Accounts__c,isactive,isportalenabled  from user where Do_Not_Assign_Accounts__c = FALSE and isactive = TRUE and isportalenabled = false AND Sales_Region__c != NULL AND Sales_Territory__c != NULL AND Sales_Team__c = 'Commercial Expand Representative' limit 50000]){
                            
                            if(ExpandRegionandTerritorySet.contains(u.Sales_Region__c+u.Sales_Territory__c)){
                                    if(!expandRegionandTerritory2UserList.containsKey(u.Sales_Region__c+u.Sales_Territory__c)){
                                        expandRegionandTerritory2UserList.put(u.Sales_Region__c+u.Sales_Territory__c ,new Set<String>{u.id});
                                    }
                                    else{
                                        Set<String> userIdSet = expandRegionandTerritory2UserList.get(u.Sales_Region__c+u.Sales_Territory__c);
                                        userIdSet.add(u.id);
                                        expandRegionandTerritory2UserList.put(u.Sales_Region__c+u.Sales_Territory__c ,userIdSet);
                                    }
                            }     
                        
                }

                for(Set<String> UserIdsSet : expandRegionandTerritory2UserList.values()){
                    allUserIdsSet.addAll(UserIdsSet);
                }
                system.debug('allUserIdsSet===================>'+allUserIdsSet);
            
            for(Account a : [select id,name,ownerid from Account where ownerid in :allUserIdsSet]){
                integer c = 0;
                if(!userId2CountofAccounts.containsKey(a.ownerid)){
                    userId2CountofAccounts.put(a.ownerid,c+1);
                }
                else{
                    integer d = userId2CountofAccounts.get(a.ownerid);
                    d = d+1;
                    userId2CountofAccounts.put(a.ownerid,d);
                    
                }
            }
            
            for(String s : allUserIdsSet){
                if(!userId2CountofAccounts.containsKey(s)){
                        userId2CountofAccounts.put(s,0);
                }
            }
            system.debug('userId2CountofAccounts=========>'+userId2CountofAccounts);
            
            for(Id accId : accountIds2BillingPostalCode.keyset()){
                //if(accountId2Account.get(accId).Gallery__c != TRUE){ 
                    Account act = accountId2Account.get(accId);
                    Boolean bo = False;
                    if(zipCodeandCityId2ExpandRegionandTerritory.containsKey(act.billingpostalcode+act.billingcity)){
                        if(expandRegionandTerritory2UserList.containsKey(zipCodeandCityId2ExpandRegionandTerritory.get(act.billingpostalcode+act.billingcity))){
                            if(expandRegionandTerritory2UserList.get(zipCodeandCityId2ExpandRegionandTerritory.get(act.billingpostalcode+act.billingcity)).size() == 1){
                                Set<String> ss = expandRegionandTerritory2UserList.get(zipCodeandCityId2ExpandRegionandTerritory.get(act.billingpostalcode+act.billingcity));
                                for(String s : ss){
                                    if(userId2CountofAccounts.containsKey(s)){
                                        if(s != act.ownerId){
                                            Account a = new Account(id=accId,Commercial_Expand_Rep__c = s);
                                            updatedAccountList.add(a);
                                            bo = True;
                                            AccountTeamMember atm = new AccountTeamMember(accountId=accId,teammemberrole='Commercial Expand Representative',userid=s);
                                            AccountTeamMember landatm = new AccountTeamMember(accountId=accId,teammemberrole='Commercial Land Representative',userid=act.ownerid);
                                            accountTeammemberstobeInserted.add(atm);
                                            accountTeammemberstobeInserted.add(landatm);
                                        }
                                        else{
                                            Account a = new Account(id=accId,Commercial_Expand_Rep__c ='No Rep Found');
                                            updatedAccountList.add(a);
                                            bo = True;
                                            AccountTeamMember landatm = new AccountTeamMember(accountId=accId,teammemberrole='Commercial Land Representative',userid=act.ownerid);
                                            accountTeammemberstobeInserted.add(landatm);
                                        }
                                    }
                                }
                            }
                            else if(expandRegionandTerritory2UserList.get(zipCodeandCityId2ExpandRegionandTerritory.get(act.billingpostalcode+act.billingcity)).size() > 1){
                                    integer accountsCount =0; String uId =''; boolean b = false;
                                    for(String u : expandRegionandTerritory2UserList.get(zipCodeandCityId2ExpandRegionandTerritory.get(act.billingpostalcode+act.billingcity))){
                                        if(b == false && userId2CountofAccounts.containsKey(u)){
                                            //if(userId2CountofAccounts.get(u) != 0){
                                                accountsCount = userId2CountofAccounts.get(u);
                                                uId  = u;
                                                b = true;
                                            //}
                                        }
                                        else{
                                            if(userId2CountofAccounts.containsKey(u)){
                                                //if(userId2CountofAccounts.get(u) != 0){
                                                    if(userId2CountofAccounts.get(u) < accountsCount){
                                                        accountsCount = userId2CountofAccounts.get(u);
                                                        uId = u;
                                                    }
                                                //}
                                            }
                                        }
                                    }
                                    if(uId != ''){                                   
                                        if(uId != act.ownerid){
                                            Account a = new Account(id=accId,Commercial_Expand_Rep__c = uId);
                                            updatedAccountList.add(a);
                                            bo = True;
                                            AccountTeamMember atm = new AccountTeamMember(accountId=accId,teammemberrole='Commercial Expand Representative',userid=uId);
                                            AccountTeamMember landatm = new AccountTeamMember(accountId=accId,teammemberrole='Commercial Land Representative',userid=act.ownerid);
                                            accountTeammemberstobeInserted.add(atm);
                                            accountTeammemberstobeInserted.add(landatm);
                                        }
                                        else{
                                            Account a = new Account(id=accId,Commercial_Expand_Rep__c = 'No Rep Found');
                                            updatedAccountList.add(a);
                                            bo = True;
                                            AccountTeamMember landatm = new AccountTeamMember(accountId=accId,teammemberrole='Commercial Land Representative',userid=act.ownerid);
                                            accountTeammemberstobeInserted.add(landatm);
                                        }
                                    }
                            }
                        }
                    }
             
                    if(bo == False){
                        Account a = new Account(id=accId,Commercial_Expand_Rep__c = 'No Rep Found');
                        updatedAccountList.add(a);
                        AccountTeamMember landatm = new AccountTeamMember(accountId=accId,teammemberrole='Commercial Land Representative',userid=act.ownerid);
                        accountTeammemberstobeInserted.add(landatm);                        
                    }
                //}
            }
            system.debug('updatedAccountList================>'+updatedAccountList);
            if(!updatedAccountList.isEmpty()){
                try{
                    update updatedAccountList;}catch(Exception e){Trigger.new[0].addError(e.getMessage());}
            }
            system.debug('accountTeammemberstobeInserted================>'+accountTeammemberstobeInserted);
            if(!accountTeammemberstobeInserted.isEmpty()){
                try{
                    insert accountTeammemberstobeInserted;}catch(Exception e){Trigger.new[0].addError(e.getMessage());}   
            }
            
        }
    }*/
    
    
    public static void validateOpportunity(){
        system.debug('Trigger.new==============>'+Trigger.New);
        system.debug('Trigger.old==============>'+Trigger.Old);
        system.debug('Trigger.newMap==============>'+Trigger.NewMap);
        system.debug('Trigger.oldMap==============>'+Trigger.oldMap);
        
        Set<Id> oppIdsbeyondstage2 = new Set<Id>();
        Set<Id> oppIdsbeyondstage2havingOLI = new Set<Id>();
        Set<Id> oppIdsbeyondstage2nothavingOLI = new Set<Id>();
        Set<Id> errorOppIdSet = new Set<Id>();
        Set<Id> updatedOppSet = new Set<Id>();
        Set<Id> oppsHavingPrimaryContactRole = new Set<Id>();
        Set<Id> oppsWithoutPrimaryContactRole = new Set<Id>();          
        Set<Id> oppOwnerNoAllowForecasting = new Set<Id>();
        Map<Id, Id> newOppOwnerIdToOppIdMap = new Map<Id, Id>();
        List<Opportunity> updatedoppList = new List<Opportunity>();
        
        //Commented by Paramvir December 24,2015 as we do not need this going forward
        /*for(Sobject so : Trigger.New){
            Opportunity opp = (Opportunity)so;  
            if( ((Opportunity)trigger.oldmap.get(opp.ID)).stageName != ((Opportunity)trigger.newmap.get(opp.ID)).stageName && opp.stageName != 'Disqualified' && opp.stageName != 'Closed Lost' && opp.stageName != System.label.StageName_B && UserInfo.getProfileId()!= System.Label.SysAdminProfileID) {
                 oppIdsbeyondstage2.add(opp.id);   
            }
        }*/
        
        for(OpportunityContactRole ocr : [select id,contactid,opportunityid,role,isprimary from opportunitycontactrole where opportunityId in: Trigger.newMap.keyset()]){
                if(ocr.isprimary == TRUE ){
                    oppsHavingPrimaryContactRole.add(ocr.opportunityId);
                }
                if(ocr.isprimary == TRUE &&  (ocr.role == 'Partner Technical Representative' || ocr.role == 'Partner Sales Representative')){
                    errorOppIdSet.add(ocr.opportunityId); 
                }
                if(ocr.isprimary == TRUE && ocr.role != 'Partner Technical Representative' && ocr.role != 'Partner Sales Representative'){
                    if(( ((Opportunity)Trigger.newMap.get(ocr.opportunityId)).Primary_Contact__c != ocr.contactId ||  ((Opportunity)Trigger.newMap.get(ocr.opportunityId)).Primary_Contact_Role__c != ocr.role ) &&  !updatedOppSet.contains(ocr.opportunityId)){
                          Opportunity opp = (Opportunity)Trigger.newMap.get(ocr.opportunityId);
                          opp.Primary_Contact__c  =  ocr.contactId;
                          opp.Primary_Contact_Role__c = ocr.role;
                          updatedoppList.add(opp);  
                          updatedOppSet.add(ocr.opportunityId);                        
                   }
                }
            }
                        
            for(Id oppId : Trigger.newMap.keyset()){                
                if(!oppsHavingPrimaryContactRole.contains(oppId) && ((Opportunity)Trigger.newMap.get(oppId)).StageName != NULL && ((Opportunity)Trigger.newMap.get(oppId)).StageName != System.label.StageName_B && ((Opportunity)Trigger.newMap.get(oppId)).StageName != System.label.StageName_A){
                    oppsWithoutPrimaryContactRole.add(oppId);
                }
                if(((Opportunity)Trigger.newMap.get(oppId)).OwnerId != ((Opportunity)Trigger.oldMap.get(oppId)).OwnerId){
                    newOppOwnerIdToOppIdMap.put(((Opportunity)Trigger.newMap.get(oppId)).OwnerId, oppId);
                }
            }


            //Name: Chris Salgado
            //Date: 10/30/19
            //Purpose: W-012676
            String adminProfiles = System.Label.QuoteAdminProfiles;
        	for(User newOppOwner : [SELECT Id, ForecastEnabled, Profile.Name FROM User WHERE Id IN :newOppOwnerIdToOppIdMap.keySet()]){
                if(newOppOwner.ForecastEnabled == false && !adminProfiles.Contains(newOppOwner.Profile.Name)){
                    oppOwnerNoAllowForecasting.add(newOppOwnerIdToOppIdMap.get(newOppOwner.Id));                    
                }
            }
        	
        
            //Commented by Paramvir December 24,2015 as we do not need this going forward
            /*if(!oppIdsbeyondstage2.isEmpty()){
                for(OpportunitylineItem oli : [select id,opportunityid from OpportunitylineItem where opportunityid in : oppIdsbeyondstage2] ){
                    oppIdsbeyondstage2havingOLI.add(oli.opportunityId);
                }

                for(Id opId :oppIdsbeyondstage2){
                      if(!oppIdsbeyondstage2havingOLI.contains(opId)){
                          oppIdsbeyondstage2nothavingOLI.add(opId);  
                      }
                 }  
             }*/
      
        if(!Test.isRunningTest()){

           // if(Recursionhandler.IsContractAmendExecuted == False) { // EW || W-005162 || 07/15/2020 || To exclude code from being called during co-term opp and quote creation process
               
               Boolean hasPermission = FeatureManagement.checkPermission('Primary_Contact_Exemption'); 

               if(!oppsWithoutPrimaryContactRole.isEmpty() && hasPermission == false && UserInfo.getUserName() != 'sfdcadmin@alteryx.com'){
                       Trigger.new[0].addError('Please add a Primary Contact Role to the opportunity prior to making edits. Let SalesOps know if you have any questions.');
               } 
               else if(!errorOppIdSet.isEmpty() && UserInfo.getProfileId()!= System.Label.SysAdminProfileID && UserInfo.getUserName() != 'sfdcadmin@alteryx.com'){
                         Trigger.new[0].addError('You cannot have a primary contact with role as Partner Technical Representative or Partner Sales Representative.');
               }
               else if(!oppOwnerNoAllowForecasting.isEmpty()){
                   Trigger.new[0].addError('You cannot change the Opportunity Owner to a User with Allow Forecasting = False.');
               }
           //}
        }
           //Commented by Paramvir December 24,2015 
           /*for(SObject so :Trigger.new){
               Opportunity op = (Opportunity)so;
               if(!oppsWithoutPrimaryContactRole.isEmpty() && UserInfo.getProfileId()!= System.Label.SysAdminProfileID){
                   Trigger.new[0].addError('Please add a Primary Contact Role to the opportunity prior to making edits. Let SalesOps know if you have any questions.');
               } 
               else if(!errorOppIdSet.isEmpty() && UserInfo.getProfileId()!= System.Label.SysAdminProfileID){
                     Trigger.new[0].addError('You cannot have a primary contact with role as Partner Technical Representative or Partner Sales Representative.');
                }
                //else if(oppIdsbeyondstage2nothavingOLI.size() > 0 && UserInfo.getProfileId()!= System.Label.SysAdminProfileID ){
                    //Trigger.new[0].addError('You cannot move an opportunity past Sales Stage 2 if you do not have Opportunity Product Line Items. Contact Sales Ops if you have any questions.');
                //}
            }*/
    }

    //Author: Sergio Flores
    //Date: 10-8-2018
    //W-010408
    /*public static void createCommissionFields()
    {
        system.debug('Inside createComissionFields');
        for(Sobject so : Trigger.new)
        {
            Opportunity opp = (Opportunity) so; 
            opp.Commission_Date__c = opp.CloseDate;
            opp.Commission_Amount__c = opp.Amount;
            //opp.Date_Stage_Moved_to_7_Closed_Won__c	 = date.today();

            if(opp.Type != 'NB')
            {
                opp.NB_Commission_Logo__c = false;
            }
            else
            {
                opp.NB_Commission_Logo__c = true;
            }

        }
    }*/

    //Author: Sergio Flores
    //Date: 10-8-2018
    //W-010408
    /*public static void updateCommissionFields()
    {
        system.debug('Inside updateComissionFields');
        for(Sobject so : Trigger.new)
        {
            Opportunity opp = (Opportunity) so;
            Opportunity oldOpportunity = (Opportunity)Trigger.oldMap.get(opp.ID);

            system.debug('Opp StageName' + opp.StageName);  
            
            

        }
    }*/

    @future
    public static void createOppTeamMember(Set<Id> allOppIds){
    
        List<OpportunityTeamMember> OppMems = new List<OpportunityTeamMember>(); 
        for(Opportunity Opp : [Select Id, ownerId, Partner_Account_Name__c from Opportunity where id in: allOppIds ]){
            if(Opp.Partner_Account_Name__c != null && Opp.Partner_Account_Name__c != ''){
                   OpportunityTeamMember OppMem   = new OpportunityTeamMember();
                   OppMem.UserId                  = Opp.OwnerId;
                   OppMem.OpportunityId           = Opp.Id;      
                   OppMem.TeamMemberRole          = 'Partner Representative';        
                   OppMems.add(OppMem);
            } 
        }
        if(OppMems.size() > 0){
              try{insert OppMems; } catch(Exception e){ System.debug('Exception while inserting OppTeamMembers'+e.getMessage()); }
        }
            
    }
    
    public static Map<Id, Account> getOppAccount(Set<Id> account_ids) {
        
        Map<Id, Account> accounts_map = new Map<Id, Account>();
        
        if(!account_ids.isEmpty()) {
            
            for(Account acc : [SELECT Id, Enterprise_Expand_Geo_Owner__c
                    FROM Account WHERE Id IN :account_ids]) {
                
                accounts_map.put(acc.Id, acc);
                
            }
            
        }
        
        return accounts_map;
        
    }
    
    @future
    public static void 
            uncheckLDRProcessButtonVisibility(Set<ID> sao_contact_ids) {
        System.debug('>>>> sao_contact_ids in gateway:' + sao_contact_ids);
        Set<String> stage_close_vals = new Set<String>();
        //stage_close_vals.add('6.5 - Pending Review');
        stage_close_vals.add('5 - Closed Won');
        stage_close_vals.add('Closed Lost');
        stage_close_vals.add('Disqualified');
        
        List<Contact> contacts_to_update = new List<Contact>();
        
        for(Opportunity opp : [SELECT Id, StageName, SAO_Contact__c
                FROM Opportunity 
                WHERE SAO_Contact__c IN :sao_contact_ids
                AND StageName != null]) {
            
            if(stage_close_vals.contains(opp.StageName)) {
                
                Contact con = new Contact();
                con.Id = opp.SAO_Contact__c;
                con.LDR_Process_Button_Visibility__c = false;
                contacts_to_update.add(con);
                
            }
            
        }
        
        if(!contacts_to_update.isEmpty()) {
            update contacts_to_update;
        }
        
    }

    /*Sharma Nemani | W - 011067 | Case: 00260714
     *Date: 03/29/2019 
	 *Description: To populate the field "Lead Owner - Sales" on Contact with the Contact Owner at the time of Opportunity creation. 
     */ 
	    public static void updatePrimaryContact(Set<Id> conIds){
	        List<Contact> conListforUpdate = new List<Contact>();
	      
	        if(conIds.size()>0){ // Updated the query below to populate the field "Lead Owner - LDR Conversion" on Contact with the Contact Owner at the time of Opportunity creation.
	            for(Contact con : [select id, Owner.Name, Lead_Owner_Sales__c, Warm_SLA_Date__c, Hot_SLA_Date__c, Lead_Owner_LDR_Conversion__c, Lead_Owner_Role__c //Sharma Nemani | Date: 04/11/2019 | W-011315 | Case: 00260711 
	                               from Contact where Id IN: conIds]){
	                                   if((con.Lead_Owner_Sales__c == null || con.Lead_Owner_Sales__c == '')  && (con.Warm_SLA_Date__c != null || con.Hot_SLA_Date__c != null)){
	                                       con.Lead_Owner_Sales__c = con.Owner.Name;
	                                   }
                                       //Sharma Nemani | W-011315 | Case: 00260711
                                       //Date: 04/11/2019
                                       //Description: To populate the field "Lead Owner - LDR Conversion" on Contact with the Contact Owner at the time of Opportunity creation. 
                                       if((con.Lead_Owner_LDR_Conversion__c == null || con.Lead_Owner_LDR_Conversion__c == '')  && (con.Warm_SLA_Date__c != null || con.Hot_SLA_Date__c != null)
                                         && (con.Lead_Owner_Role__c.containsIgnoreCase('ldr') || con.Lead_Owner_Role__c.containsIgnoreCase('sdr'))){
	                                       con.Lead_Owner_LDR_Conversion__c = con.Owner.Name;
	                                   }
                                       conListforUpdate.add(con);
	                               }
	            if(conListforUpdate.size()>0)
	                update conListforUpdate;
	        }
	    }


    //Sergio Flores
    //Date: 06/15/2019
    //W-012281

    // Eddie Wong
    // Date: 05/08/2020
    // W-005264
    public static void syncPrimaryContactCurrencytoOpp(Set<Id> primaryContactIds, List<Opportunity> newRecords){

        Recursionhandler.IsSyncPrimaryContactCurrencytoOppExecuted = true;

        System.debug('eddie inside syncPrimaryContactCurrencytoOpp');
        List<Opportunity> oppCurrencyToUpdate = new List<Opportunity>();

        Map<Id, Contact> contactIdToContactMap = new Map<Id, Contact>([Select pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c, pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c,
                                                                       pw_ccpro__MailingCountryLookup__r.Price_Book__c
                                                                       From Contact
                                                                       Where Id IN : primaryContactIds]);

        for(Opportunity opp : newRecords)
        {
            Opportunity o = new Opportunity();
            Contact primaryContact = contactIdToContactMap.get(opp.Primary_Contact__c);

            if(primaryContact !=null)
            {
                o.Id = opp.Id;
                o.CurrencyIsoCode = primaryContact.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c;
                if(primaryContact.pw_ccpro__MailingCountryLookup__r.Default_Price_Book_Standard_Purchase__c != 'Standard Price Book')
                o.Pricebook2Id = primaryContact.pw_ccpro__MailingCountryLookup__r.Price_Book__c;
                oppCurrencyToUpdate.add(o);

            }
        }

        if(!oppCurrencyToUpdate.isEmpty()){
            update oppCurrencyToUpdate;
        }
    }
    
    //Name: Chris Salgado
    //Date: 10/24/2019
    //Purpose: W-012834
    public static void getPartnerContactFromPrimary(Set<Id> primaryContactIds, List<Opportunity> newRecords){
        Map<Id, Contact> contactIdToContactMap = new Map<Id, Contact>([SELECT Id, Partner_Contact__c
                                                                        FROM Contact
                                                                        WHERE Id IN :primaryContactIds]);

        for(Opportunity opp : newRecords)
        {
            Contact primaryContact = contactIdToContactMap.get(opp.Primary_Contact__c);

            if(primaryContact != null && primaryContact.Partner_Contact__c != null) //Should & would it write null if it is blank?
            {
                opp.Partner_Contact__c = primaryContact.Partner_Contact__c;
            }
        }
    }

    //Sergio Flores
    //Date: 06/11/2019
    //W-012192
    //This is for populating the contract start dates along other fields to autopopulate
    //on the opportunity
    public static void stampContractStartDate(Map<Id, Contract> renewedContractToOppMap, List<Opportunity> newRecords){
        system.debug('inside stampContractStartDate ' + renewedContractToOppMap);

        for(Opportunity opp : newRecords)
        {
            Contract contract;
            /*if(opp.SBQQ__RenewedContract__c !=null)
            contract = renewedContractToOppMap.get(opp.SBQQ__RenewedContract__c);
            else*/
            contract = renewedContractToOppMap.get(opp.SBQQ__AmendedContract__c);

            if(contract != null)
            {
                if(contract.SBQQ__Opportunity__r.Type == 'NBEC' || contract.SBQQ__Opportunity__r.Type == 'ECUR' || contract.SBQQ__Opportunity__r.Type == 'NB')
                {
                    system.debug('contract ' + contract + ' opportunity ' + opp);
                    opp.Contract_Start_Date__c = contract.EndDate.addDays(1);
                    opp.Contract_End_Date__c = opp.Contract_Start_Date__c.addMonths(integer.valueOf(contract.ContractTerm));
                    opp.Contract_End_Date__c = opp.Contract_End_Date__c.addDays(-1);
                    opp.Primary_Contact__c = contract.SBQQ__Opportunity__r.Primary_Contact__c;
                    if(opp.SBQQ__RenewedContract__c !=null)
                    opp.Type = 'ECUR';
                    else
                    opp.Type = 'NBEC';
                    // Added by: Sharma Nemani | W-002569 | Date: 01/23/2020 --> START
                    if(opp.Type == 'NBEC' ){
                        opp.Name = contract.SBQQ__Opportunity__r.Account.Name + '- NBEC -' + contract.SBQQ__Opportunity__r.Primary_Contact__r.Name + '- ' + contract.ContractNumber;
                    }else if(opp.Type == 'NB'){
                        opp.Name = contract.SBQQ__Opportunity__r.Account.Name + '- NB -' + contract.SBQQ__Opportunity__r.Primary_Contact__r.Name + '- ' + contract.ContractNumber;
                    }else{
                        opp.Name = contract.SBQQ__Opportunity__r.Account.Name + '- ECUR -' + contract.SBQQ__Opportunity__r.Primary_Contact__r.Name + '- ' + contract.ContractNumber;
                    }
                    // Added by: Sharma Nemani | W-002569 | Date: 01/23/2020 --> END
                    //opp.Best_Case_Term__c = contract.SBQQ__Opportunity__r.Best_Case_Term__c; Sergio Flores 02/21/2020 W-004548
                    opp.Forecast_Amount__c = contract.SBQQ__Opportunity__r.Forecast_Amount__c;
                    opp.Amount = contract.SBQQ__Opportunity__r.Amount;
                    
                    
                }
             

            }
        }
    }

  /* Added by: Sharma Nemani | W-010857 | Case: 00246316 --> START
  * Date: 08/08/2019
  * Description: This method is to prevent any user from creating Opportunity if the user is not part
  * of Account Team or an Account Owner in the current Account.
  Edited by Sergio 11/6/2019 since this method causes an error with batch classes since there is no ApexPages reference
  */
    public static void allowOpportunityIfLoggedInUserExistInAccountTeam(Opportunity opp){

        //if (userinfo.getName() != 'Automated Process') { //EW || 07/13/2020 || W-005162
            Profile pf = [select id ,Name from Profile where ID =:userinfo.getProfileId()];
            //Profile pf = [select id,Name from Profile where Name = 'System Administrator'];

            if (pf.Name != 'System Administrator' && pf.Name != 'Alteryx - Integration User (Pswd never exp)') {
                List<AccountTeamMember> lstAccountTeamMember = [select AccountId,UserId from AccountTeamMember where UserId = :opp.OwnerId AND AccountId = :opp.AccountId];

                List<Account> lstAcc;
                if (opp.AccountId != null) {
                    lstAcc = [select id, CreatedDate, OwnerId,Owner.profile.Id from Account where Id = :opp.AccountId];
                }

                Boolean showError = true;
                //system.debug('userProfile :: '+userinfo.getProfileId());
                //system.debug('AccProfile :: '+lstAcc[0].Owner.profile.Id);
                //system.debug('lstAccountTeamMember :: '+lstAccountTeamMember.size());

                if (lstAcc != null && (lstAcc[0].OwnerId == userinfo.getUserId() || pf.Name.equalsIgnoreCase('System Administrator') || pf.Name.equalsIgnoreCase('Alteryx - Sales - Deal Desk') || pf.Name.equalsIgnoreCase('Alteryx - Sales - Sales Ops') || pf.Name.equalsIgnoreCase('Alteryx - Academic Liaison'))) {
                    showError = false;
                } else if (!(lstAcc != null && showError && (ApexPages.currentPage().getParameters().get('retURL') != null || ((system.now().getTime() - lstAcc[0].CreatedDate.getTime()) >= 60000)) && lstAccountTeamMember.size() == 0)) {
                    showError = false;
                    // Added "ApexPages.currentPage().getParameters().get('retURL')" to know whether Opportunity is being created from Contact or
                    // being created after lead conversion .
                } else if (!(lstAcc != null && showError && lstAcc[0].OwnerId != userinfo.getUserId() && lstAccountTeamMember.size() == 0)) {
                    showError = false;
                } else if (showError && lstAccountTeamMember.size() == 0) {
                    showError = true;
                }

                system.debug('showError :: ' + showError);
                if (showError) {
                    opp.addError('You cannot create Opportunity as you are not an Account Owner or part of the Account Team in this current Account.');
                }
            }
        //}
        
    }

            /**
             * @Name Eddie Wong
             * @Work W-007075
             * @Date 1/20/2021
             * @Description Global Ranking field stamping on opp before insert
            */
    public static void stampGTMGlobalRankingOnOpp(Set<Id> primaryContactIds, List<Opportunity> newRecords){

        Map<Id, Contact> conIdToConMap = new Map<Id, Contact>([SELECT Id,Account.Global_Ranking__c
                                                                        FROM Contact
                                                                        WHERE Id IN :primaryContactIds]);

        System.debug('ed check conIdToConMap = ' + conIdToConMap);

        if(!conIdToConMap.isEmpty()) {
            for (Opportunity opp : newRecords) {
                opp.Global_Ranking__c = conIdToConMap.get(opp.Primary_Contact__c).Account.Global_Ranking__c;
            }
        }
    }

    // Sharma Nemani | W-010857 | Case: 00246316 | Date: 08/12/2019 --> END
}