public without sharing class CustomPartnerGateway{
  
    Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partner Opportunity').getRecordTypeId();
    Id altxRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Alteryx Record Type').getRecordTypeId();
    
    /*used to update sharing rule when opportunity owner changed : Trigger-OpportunityHandler
    @Future
    public static void UpdateOpportunitySharingRules(Set<Id> opportunityIdsForSharing){
        system.debug('-----Function Called------'+opportunityIdsForSharing);
        map<id,id> oppIdToPartnerAccountIdMap = new map<id,id>(); 
        for(Custom_Partner__c cp :[select id,AccountToId__c,OpportunityId__c from custom_Partner__c where AccountToId__c != null and IsPrimary__c = true and OpportunityId__c  in :opportunityIdsForSharing]){
            oppIdToPartnerAccountIdMap.put(cp.OpportunityId__c,cp.AccountToId__c);
        }
        system.debug('@@------>>'+oppIdToPartnerAccountIdMap);
        if(oppIdToPartnerAccountIdMap.size() > 0){
            createOpportunitySharingRules(oppIdToPartnerAccountIdMap);
        }
    }*/
    
    public static void createOpportunitySharingRules(Map<id,id> oppIdToPartnerAccountIdMap){
        map<id,list<id>> accountToUserIdsMap = new map<id,list<id>>();
        map<id,set<id>> oppToExistingSharingMap = new map<id,set<id>>();
        list<OpportunityShare> oppShareList = new list<OpportunityShare>();
        for(user u:[select id,contactId,Contact.accountId from user where userType = 'PowerPartner' and contactId != null AND contact.accountId in:oppIdToPartnerAccountIdMap.values() and IsActive = true]){
             if(accountToUserIdsMap.containsKey(u.Contact.accountId)){
                list<id> userIds = accountToUserIdsMap.get(u.Contact.accountId);
                userIds.add(u.id);
                accountToUserIdsMap.put(u.Contact.accountId,userIds);
            }else{
                accountToUserIdsMap.put(u.Contact.accountId,new List<Id>{u.id});
            }
        }
        //Get the existing Opportunity Sharings
        for(OpportunityShare os:[select id,OpportunityId,UserOrGroupId  from OpportunityShare where OpportunityId in :oppIdToPartnerAccountIdMap.keyset()]){
            if(oppToExistingSharingMap.containsKey(os.OpportunityId)){
                set<id> userIds = oppToExistingSharingMap.get(os.OpportunityId);
                userIds.add(os.UserOrGroupId);
                oppToExistingSharingMap.put(os.OpportunityId,userIds);
            }else{
                oppToExistingSharingMap.put(os.OpportunityId,new Set<Id>{os.UserOrGroupId});
            }
        }
        //Create Opportunity Sharing Rules
        for(id oppId : oppIdToPartnerAccountIdMap.keyset()){
            if(accountToUserIdsMap.containsKey(oppIdToPartnerAccountIdMap.get(oppId))){
                for(id userID: accountToUserIdsMap.get(oppIdToPartnerAccountIdMap.get(oppId))){
                    if(oppToExistingSharingMap.containsKey(oppId)){
                        //set userIds = 
                        if(!oppToExistingSharingMap.get(oppId).contains(userId)){
                            OpportunityShare os = new OpportunityShare();
                            os.OpportunityAccessLevel = 'Read';
                            os.OpportunityId = oppId;
                            os.UserOrGroupId = userID;
                            oppShareList.add(os);
                        }
                    }else{
                        OpportunityShare os = new OpportunityShare();
                        os.OpportunityAccessLevel = 'Read';
                        os.OpportunityId = oppId;
                        os.UserOrGroupId = userID;
                        oppShareList.add(os);
                    }
                }
            }
        }
        system.debug('@@-Create Opp Share Rules->>');
        system.debug('@@--oppShareList-->>'+oppShareList);
        if(oppShareList.size() > 0)
            insert oppShareList;
    }
    public static list<OpportunityShare> deleteOpportunitySharingRules(Set<id> opportunityIdsToDeleteSharing){
        return [select id from opportunityShare where OpportunityId in :opportunityIdsToDeleteSharing and RowCause = 'Manual'];
    }

    // W-007052 : JPH : 20180131 : Handle the case where the Opp's DistDeal Checkbox is set to FALSE
    public static void uncheckDistCheckbox(set<id> oppIds){
        list<Opportunity> oppList = new list<Opportunity>([SELECT Id, Distributor_Deal__c FROM Opportunity WHERE Id IN :oppIds]);
        list<Opportunity> oppUpdates = new list<Opportunity>();
        for(Opportunity o : oppList){
            o.Distributor_Deal__c = false;
            oppUpdates.add(o);
        }
      
        if(!oppUpdates.IsEmpty()){
            update oppUpdates;
        }
    }
    
    // W-007052 : JPH : 20180131 : Handle the case where the Opp's DistDeal Checkbox is set to TRUE
    public static void checkDistCheckbox(set<id> oppIds){
        list<Opportunity> oppList = new list<Opportunity>([SELECT Id, Distributor_Deal__c FROM Opportunity WHERE Id IN :oppIds]);
        list<Opportunity> oppUpdates = new list<Opportunity>();
        for(Opportunity o : oppList){
            o.Distributor_Deal__c = true;
            oppUpdates.add(o);
        }
      
        if(!oppUpdates.IsEmpty()){
            update oppUpdates;
        }
    }

    // Added by Hemendra Singh Rajawat on May 11, 2018
    // JPH - 20190402 - Commented for CPQ Development
    /*
    public static List<Apttus_Proposal__Proposal__c> updateProposals(Map<Id, Id> oppIdToPartnerIdMap,
                                                                     String event) {
        List<Apttus_Proposal__Proposal__c> propToUpdate 
            = new List<Apttus_Proposal__Proposal__c>();

        for (Opportunity opp : [SELECT Id, (SELECT Id, Partner_Account__c
                                            FROM R00N70000001yUfDEAU__r 
                                            WHERE Apttus_Proposal__Primary__c = true)
                                FROM Opportunity
                                WHERE Id IN :oppIdToPartnerIdMap.keySet()]) {

            Id partnerId = oppIdToPartnerIdMap.get(opp.Id);
            for (Apttus_Proposal__Proposal__c prop : opp.R00N70000001yUfDEAU__r) {
                if (event == 'insert') {
                    if (prop.Partner_Account__c != partnerId) {
                        prop.Partner_Account__c = partnerId;
                        propToUpdate.add(prop);
                    }
                } else if (event == 'delete') {
                    if (prop.Partner_Account__c == partnerId) {
                        prop.Partner_Account__c = NULL;
                        prop.Partner_Contact__c = NULL;                        
                        propToUpdate.add(prop);
                    }
                } else if (event == 'update') {
                    if (prop.Partner_Account__c == partnerId) {
                        prop.Partner_Account__c = NULL;
                        prop.Partner_Contact__c = NULL;                        
                        propToUpdate.add(prop);
                    }
                }
            }
        }
        return propToUpdate;
    }
*/
    // Added by Hemendra Singh Rajawat on May 14, 2018
    public static List<Partner> deletePartners(List<Id> parIdsToDelete) {
        return [SELECT Id FROM Partner WHERE Id IN :parIdsToDelete];
    }

    public static List<Custom_Partner__c> updatePartners(List<Partner> partners,
        Map<String, Id> uniqueIdToCparIdMap) {
        
        Map<String, Id> uniqueIdToPartId = new Map<String, Id>();
        List<Custom_Partner__c> parsToUpdate = new List<Custom_Partner__c>();

        for (Partner par : partners) {
            uniqueIdToPartId.put('' + par.OpportunityId + par.AccountToId, par.Id);
        }

        for (String uniqueId : uniqueIdToPartId.keySet()) {
            if (uniqueIdToCparIdMap.containsKey(uniqueId)) {
                Custom_Partner__c cp 
                    = new Custom_Partner__c(Id = uniqueIdToCparIdMap.get(uniqueId));

                cp.Partner_Id__c = uniqueIdToPartId.get(uniqueId);
                parsToUpdate.add(cp);
            }
        }

        return parsToUpdate;
    }

    // Added by Hemendra Singh Rajawat on June 07, 2018
    public static List<OpportunitySplit> deleteOppSplit(Map<Id, Id> oppIdToAccIdMap) {
        Map<Id, Id> accIdToOwnerId = new Map<Id, Id>();
        List<OpportunitySplit> oppSplitToDelete = new List<OpportunitySplit>();

        for (Account acc : [SELECT Id, Business_Development_Owner__c 
                            FROM Account
                            WHERE Id IN :oppIdToAccIdMap.values() 
                            AND Business_Development_Owner__c != NULL]) {

            accIdToOwnerId.put(acc.Id, acc.Business_Development_Owner__c);
        }

        for (OpportunitySplit oppSplit : [SELECT Id 
                                          FROM OpportunitySplit 
                                          WHERE OpportunityId IN :oppIdToAccIdMap.keySet() 
                                          AND SplitOwnerId IN :accIdToOwnerId.values() 
                                          AND SplitTypeId = :Label.OverlayOpportunitySplitId]) {

            oppSplitToDelete.add(oppSplit);
        }

        return oppSplitToDelete;
    }
    
    //Sergio Flores
    //Date: 05/17/2019
    //Remove OpportunityTeamMembers
    public static List<OpportunityTeamMember> deleteOppTeamMember(Map<Id, Id> oppIdToAccIdMap) {
 
        List<OpportunityTeamMember> oppTeamMembersList = new List<OpportunityTeamMember>();
        Map<Id, Id> accIdToOwnerId = new Map<Id, Id>();
 
        for (Account acc : [SELECT Id, Business_Development_Owner__c 
                            FROM Account
                            WHERE Id IN :oppIdToAccIdMap.values() 
                            AND Business_Development_Owner__c != NULL]) {
 
            accIdToOwnerId.put(acc.Id, acc.Business_Development_Owner__c);
        }
 
        //Sergio Flores
        //Need to also remove the OpportunityTeamMembers added
        for(OpportunityTeamMember otm : [SELECT Id 
                                          FROM OpportunityTeamMember 
                                          WHERE OpportunityId IN :oppIdToAccIdMap.keySet() 
                                          AND userId IN :accIdToOwnerId.values() ])
        {
            oppTeamMembersList.add(otm);
        }
 
        system.debug('oppTeamMembersList ' + oppTeamMembersList);
 
        return oppTeamMembersList;
    }

    // Added by Hemendra Singh Rajawat on June 07, 2018
    public static List<OpportunitySplit> insertOppSplit(Map<Id, Id> oppIdsToAccIdsMap) {
        Map<Id, Id> accIdToOwnerId = new Map<Id, Id>();
        List<OpportunitySplit> oppSplitToInsert = new List<OpportunitySplit>();
        List<OpportunityTeamMember> oppTeamMembersList = new List<OpportunityTeamMember>();
        
        for (Account acc : [SELECT Id, Business_Development_Owner__c 
                            FROM Account
                            WHERE Id IN :oppIdsToAccIdsMap.values() 
                            AND Business_Development_Owner__c != NULL]) {

            accIdToOwnerId.put(acc.Id, acc.Business_Development_Owner__c);
        }

        for (Id oppId : oppIdsToAccIdsMap.keySet()) {
            Id businessDevelopementUserId = accIdToOwnerId.get(oppIdsToAccIdsMap.get(oppId)); 
 
            if( businessDevelopementUserId != null){
                //Need to create Opp Team Members before creating splits
                OpportunityTeamMember otm = new OpportunityTeammember();
                otm.OpportunityId=oppId;
                otm.TeamMemberRole='Business Development Representative';
                otm.userId = businessDevelopementUserId;
                oppTeamMembersList.add(otm);
            
                OpportunitySplit oppSplit = new OpportunitySplit();
                oppSplit.OpportunityId = oppId;
                oppSplit.SplitOwnerId = businessDevelopementUserId ;
                oppSplit.SplitTypeId = Label.OverlayOpportunitySplitId;
                oppSplit.SplitPercentage = 100;
                oppSplitToInsert.add(oppSplit);
            }
        }
        try {
 
            if(!oppTeamMembersList.IsEmpty()){
                 
                //insert oppTeamMembersList; Commented by: Sharma Nemani | W-011380 | Case: 00266466 | Date: 07/29/2018
            } 
        } 
        catch (Exception ex) {
            system.debug('inside catch exception');
            trigger.new[0].addError('erro'); 
        } 

        return oppSplitToInsert;
    }
    
    /*public static void updateOpportunityField(Set<Id> cpIds) {
        //Map<Id, Opportunity> oppsTpUpdate = new Map<Id, Opportunity>();
        boolean updateOpp = false;
        Opportunity opp;
        
        if (!cpIds.isEmpty()) {
            List<Custom_Partner__c> cpdata = [SELECT Id, AccountToId__c, AccountToId__r.Referral_Discount__c, AccountToId__r.Name, OpportunityId__c, IsPrimary__c, Role__c,
                                              OpportunityId__r.RecordTypeId, OpportunityId__r.Partner_Account_Lookup__c, OpportunityId__r.Partner_Role__c,
                                              OpportunityId__r.Partner_Account_Name__c, OpportunityId__r.Referral_Discount__c
                                              FROM Custom_Partner__c
                                              WHERE Id In : cpIds];
            if (cpdata.size() > 0) {
                for (Custom_Partner__c cp : cpdata) {
                    opp = new Opportunity();
                    if (cp.AccountToId__c != null && cp.OpportunityId__c != null) {
                        if (cp.OpportunityId__r.RecordTypeId != partnerRecordTypeId) {
                            opp.RecordTypeId = partnerRecordTypeId;
                            updateOpp = true;                        
                        }
                        if (cp.IsPrimary__c && (cp.AccountToId__c != cp.OpportunityId__r.Partner_Account_Lookup__c
                            || cp.Role__c != cp.OpportunityId__r.Partner_Role__c || cp.AccountToId__r.Name != cp.OpportunityId__r.Partner_Account_Name__c)) {
            
                            opp.Id = cp.OpportunityId__c;
                            opp.Partner_Account_Lookup__c = cp.AccountToId__c;
                            opp.Partner_Role__c = cp.Role__c;
                            opp.Partner_Account_Name__c = cp.AccountToId__r.Name;
                            updateOpp = true; 
            
                            if (cp.Role__c == 'Referrer') {                                
                                decimal ref_discount = (cp.AccountToId__r.Referral_Discount__c != null && 
                                                         cp.AccountToId__r.Referral_Discount__c.contains('%')) ? 
                                    decimal.valueOf(cp.AccountToId__r.Referral_Discount__c.removeEnd('%')) : 0;
                                            
                                if (cp.OpportunityId__r.Referral_Discount__c != ref_discount) {
                                        opp.Referral_Discount__c = ref_discount;
                                        updateOpp = true;
                                }
                            } else if (cp.OpportunityId__r.Referral_Discount__c != null) {
                                    opp.Referral_Discount__c = null;
                                    updateOpp = true;
                            }
                        }
                    } else {
                        if (cp.OpportunityId__r.RecordTypeId != altxRecordTypeId) {
                            opp.RecordTypeId = altxRecordTypeId;
                            updateOpp = true;                        
                        }
                        if (cp.OpportunityId__r.Partner_Account_Lookup__c != null || cp.OpportunityId__r.Partner_Role__c != null 
                            || cp.OpportunityId__r.Partner_Account_Name__c != null) {
                                   
                            opp.Partner_Account_Lookup__c = null;
                            opp.Partner_Role__c = null;
                            opp.Partner_Account_Name__c = null;
                            updateOpp = true;
                        }
                        if (cp.OpportunityId__r.Referral_Discount__c != null) {
                            opp.Referral_Discount__c = null;
                            updateOpp = true;
                        }
                    }
                }
                try {
                    if(updateOpp) {
                        update Opp; 
                    }
                } catch (Exception ex) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
                }
            }
        } 
    }*/
    
    public static void updateRelatedOpportunity(Set<Id> oppids) {
        Map<Id, Opportunity> oppsTpUpdate = new Map<Id, Opportunity>();
        
        Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partner Opportunity').getRecordTypeId();
        Id altxRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Alteryx Record Type').getRecordTypeId();
        
        boolean updateOpp = false;
        boolean hasPrimary = false;
        
        for(Opportunity opp :  [SELECT Id, RecordTypeId, Partner_Account_Lookup__c, Partner_Role__c,
                                Partner_Account_Name__c, Referral_Discount__c,
                                (SELECT Id, AccountToId__c, AccountToId__r.Referral_Discount__c, 
                                 AccountToId__r.Name, IsPrimary__c, Role__c
                                 FROM Custom_Partners__r)
                                FROM Opportunity
                                WHERE Id In : oppids])
        {
            
            if(!opp.Custom_Partners__r.isEmpty()){
                for (Custom_Partner__c cp : opp.Custom_Partners__r) {
                    if (opp.RecordTypeId != partnerRecordTypeId) {
                        opp.RecordTypeId = partnerRecordTypeId;
                        updateOpp = true;                        
                    }
                    
                    if (cp.IsPrimary__c){
                        hasPrimary = true;
                        if((cp.AccountToId__r.Name != opp.Partner_Account_Name__c || cp.Role__c != opp.Partner_Role__c
                            || cp.AccountToId__c != opp.Partner_Account_Lookup__c )) {
                                
                                opp.Partner_Account_Lookup__c = cp.AccountToId__c;
                                opp.Partner_Role__c = cp.Role__c;
                                opp.Partner_Account_Name__c = cp.AccountToId__r.Name;
                                
                                updateOpp = true;   
                            }
                    }
                    if (cp.Role__c == 'Collaborative Sale') {
                        decimal ref_discount = (cp.AccountToId__r.Referral_Discount__c != null && 
                                                cp.AccountToId__r.Referral_Discount__c.contains('%')) ? 
                            decimal.valueOf(cp.AccountToId__r.Referral_Discount__c.removeEnd('%')) : 0;
                            
                        if (opp.Referral_Discount__c != ref_discount) {
                            opp.Referral_Discount__c = ref_discount;
                            updateOpp = true;
                        }
                    } else if (opp.Referral_Discount__c != null && !label.additionalPartnerRoles.containsIgnoreCase(cp.Role__c)) {
                        opp.Referral_Discount__c = null;
                        updateOpp = true;
                    }          
                }
                if(!hasPrimary){
                    updateOppFields(opp, true);
                    updateOpp = true;
                }
            } else {
                updateOppFields(opp, false);
                updateOpp = true;
            }
            
            if(updateOpp){
                oppsTpUpdate.put(opp.Id, opp);
            }
        }
        
        try{
            if(!oppsTpUpdate.isEmpty()) {
                update oppsTpUpdate.values(); 
            }
        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
    }
    
    public static Opportunity updateOppFields(Opportunity opp, boolean hasPartners){
        Id altxRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Alteryx Record Type').getRecordTypeId();
        
        if (opp.RecordTypeId != altxRecordTypeId && !hasPartners) {
            opp.RecordTypeId = altxRecordTypeId;
        } 
        if (opp.Partner_Account_Lookup__c != null || opp.Partner_Role__c != null 
            || opp.Partner_Account_Name__c != null) {
                
                opp.Partner_Account_Lookup__c = null;
                opp.Partner_Role__c = null;
                opp.Partner_Account_Name__c = null;
            }
        if (opp.Referral_Discount__c != null) {
            opp.Referral_Discount__c = null;
        }
        
        return opp;
    }

     //Name: Chris Salgado
    //Date: 8/21/2019
    //W-012809
    public static void wiOppPartnerUpdate(Map<Id, Custom_Partner__c> wiOppToPartnerMap, Set<Id> wiPartnerAccounts, Boolean share){
        Map<Id, Account> wiPartnerToAccountsMap = new Map<Id, Account>();
        system.debug('**CSALGADO** : PartnerAccounts- ' + wiPartnerAccounts.size());
        if(!wiPartnerAccounts.isEmpty()){
            for(Account acct : [SELECT Id,wi__Share_to_WI__c FROM Account WHERE Id IN :wiPartnerAccounts]){
                wiPartnerToAccountsMap.put(acct.Id, acct);
            }
        }

        List<Opportunity> updateOpps = new List<Opportunity>();
        for(Opportunity opp : [SELECT Id, wi__Share_to_WI__c, wi__Associated_Partner__c FROM Opportunity WHERE Id IN :wiOppToPartnerMap.keySet()]){
            if(wiOppToPartnerMap.containsKey(opp.Id)){
                system.debug('**CSALGADO** : In first IF');
                //Path for Insert VS Delete
                if(share) {
                    system.debug('**CSALGADO** : In second IF');
                    //Check that the Account is set to WI Share = True
                    if(wiPartnerToAccountsMap.containsKey(wiOppToPartnerMap.get(opp.Id).AccountToId__c) &&
                            wiPartnerToAccountsMap.get(wiOppToPartnerMap.get(opp.Id).AccountToId__c).wi__Share_to_WI__c == share) {
                        system.debug('**CSALGADO** : In third IF');
                        opp.wi__Share_to_WI__c = share; //True
                        system.debug('**CSALGADO** : Partner Map- ' + wiOppToPartnerMap.get(opp.Id));
                        system.debug('**CSALGADO** : Partner Value- ' + wiOppToPartnerMap.get(opp.Id).AccountToId__c);
                        opp.wi__Associated_Partner__c = wiOppToPartnerMap.get(opp.Id).AccountToId__c;
                    }
                }
                else{
                    opp.wi__Share_to_WI__c = share; //False
                    opp.wi__Associated_Partner__c = null;
                }
                updateOpps.add(opp);
            }
        }

        if(!updateOpps.isEmpty()){
            update updateOpps;
        }
    }
    
}