public class AddPartnerController {
    public String primaryPartnerRole {get;set;}
    public String secondaryPartnerRole {get;set;}
    public String influencerPartnerRole {get;set;}
    public String primaryReferralDiscount {get;set;}
    public String secondaryReferralDiscount {get;set;}
    public String secondaryHelpText {get;set;}
    public String primaryHelpText {get;set;}
    public String primaryheadtext {get;set;}
    public String secondaryheadtext {get;set;}
    public String primaryStrength {get;set;}
    public String primaryType {get;set;}
    public String secondaryStrength {get;set;}
    public String secondaryType {get;set;}
    public String additionalHelpText {get;set;}
    public String additionalStrength {get;set;}
    public String additionalType {get;set;}
    public Opportunity currentRecord {get;set;}
    public SBQQ__Quote__c currentQuoteRecord {get;set;}
    public SBQQ__Quote__c recordToUpdate {get;set;}
    public Contact con1 {get;set;}
    public Contact con2 {get;set;}
    public Contact con3 {get;set;}
    public List<SelectOption> primaryPartnerRoles {get;set;}
    public List<SelectOption> distributorRoles {get;set;}
    public List<SelectOption> influencerRoles {get;set;}
    public Boolean hasError {get;set;}
    public Boolean showprimaryFee {get;set;}
    public Boolean showSecondaryFee {get;set;}
    public Boolean showPage {get;set;}
    public Boolean showSecond {get;set;}
    Boolean hasPartner = false;
    Boolean hasDistributor = false;
    Boolean hasInfluencer = false;
    Id primaryPartnerId;
    Id secondaryPartnerId;
    Id influencerPartnerId;
    Set<Id> partnerIds = new Set<Id>();
    String currentPrimaryPartner;
    String currentSecondaryPartner;  
    String currentPrimaryRole;
    String currentSecondaryRole;
    String currentInfluencerPartner;
    String currentInfluencerRole;
    String accId;
    String currentId;

    Public string selectedPI{get;set;} // Added by: Sharma Nemani | W-010762 | Case: 00251431 | Date: 09/10/2019
    Public string selectedPI2{get;set;} // Added by: Sharma Nemani | W-010762 | Case: 00251431 | Date: 09/10/2019
    Opportunity opportunityRecord = new Opportunity();
    List<Custom_Partner__c> partnersToInsert = new List<Custom_Partner__c>();
    List<Custom_Partner__c> partnersToDelete = new List<Custom_Partner__c>();
    Map<String,Partner_Type_Validation__c> partnerTypeSetting;
    Map<String, List<SelectOption>> accountTypeToRolesMap;
    List<String> profileList =  new List<String>();
    
    public AddPartnerController() {
        String partnerType;
        String partnerRole;
        String oppId;
        hasError = false;
        showprimaryFee = false;
        showPage = false;
        accountTypeToRolesMap = new Map<String, List<SelectOption>>();
        partnerTypeSetting = new Map<String,Partner_Type_Validation__c>();
        Id profileId = userinfo.getProfileId();
        String profileName = [Select Id,Name from Profile where Id=:profileId].Name;
        currentId = ApexPages.currentPage().getParameters().get('id');

        AddPartnerOnQuote_Setting__c setting = AddPartnerOnQuote_Setting__c.getAll().values();

        for (Partner_Type_Validation__c ptv : Partner_Type_Validation__c.getAll().values()) {
            partnerTypeSetting.put(ptv.Primary_Partner_Role__c , ptv);
        }
               
        primaryPartnerRoles = new list <SelectOption>();
        primaryPartnerRoles.add(new SelectOption('', '--None--'));
        distributorRoles = new list <SelectOption>();
        distributorRoles.add(new SelectOption('', '--None--'));
        influencerRoles = new list <SelectOption>();
        influencerRoles.add(new SelectOption('', '--None--'));

        con1 = new Contact();
        con2 = new Contact();
        con3 = new Contact();
         
        for (Partner_Role_Mapping__mdt roleMap : [SELECT MasterLabel, Partner_Role__c 
                                                  FROM Partner_Role_Mapping__mdt
                                                  WHERE Object__c = 'Opportunity']) {

            partnerType = roleMap.MasterLabel;
            partnerRole = roleMap.Partner_Role__c;
            List<SelectOption> pickListValues = new List<SelectOption>();
            Set<String> roles = new Set<String>();
            
            if (partnerRole != null) {
                for (String partRoles : partnerRole.Split(',')) {
                    if (!roles.contains(partRoles)) {
                        pickListValues.add(new SelectOption(partRoles, partRoles));
                        roles.add(partRoles);
                    }
                }
            }
            if (!accountTypeToRolesMap.containsKey(partnerType)) {
                accountTypeToRolesMap.put(partnerType, pickListValues);
            }
        }
        

        if (currentId != null && currentId.startsWith('006')) {
            currentRecord = [SELECT Id, OwnerId, RecordTypeId, Referral_Discount__c, AccountId, 
                             Partner_Account_Name__c, Partner_Role__c, Partner_Account_Lookup__c, 
                             (SELECT Id FROM SBQQ__Quotes2__r), 
                             (SELECT Id, OpportunityId__c, AccountToId__c, AccountToId__r.Referral_Discount__c,
                              IsPrimary__c, Role__c FROM Custom_Partners__r), 
                             (SELECT Id, UserId FROM OpportunityTeamMembers) 
                             FROM Opportunity 
                             WHERE Id=: currentId];

            oppId = currentId;
            accId = currentRecord.AccountId;

            for (Custom_Partner__c partners : currentRecord.Custom_Partners__r) {

                if (partners.AccountToId__c != null && partners.IsPrimary__c) {
                    hasPartner = true;
                    primaryPartnerId = partners.Id;
                    con1.Partner_Account__c = partners.AccountToId__c;
                    currentPrimaryPartner = partners.AccountToId__c;
                    primaryPartnerRole();

                    if (partners.Role__c != null && partners.IsPrimary__c) {
                        primaryPartnerRole = partners.Role__c;
                        currentPrimaryRole = partners.Role__c;
                    }

                    checkPartner();

                    if (partners.Role__c == 'Referrer') {
                        showprimaryFee = true;
                        primaryReferralDiscount = partners.AccountToId__r.Referral_Discount__c;
                    }
                }

                if (partners.AccountToId__c != null && !partners.IsPrimary__c
                    &&  !label.additionalPartnerRoles.containsIgnoreCase(partners.Role__c)) { // To check

                    hasDistributor = true;
                    showSecond = true;
                    secondaryPartnerId = partners.Id;
                    con2.Partner_Account__c = partners.AccountToId__c;
                    currentSecondaryPartner = partners.AccountToId__c;
                    secondaryPartnerRole();

                    if (partners.Role__c != null && !partners.IsPrimary__c) {
                        secondaryPartnerRole = partners.Role__c;
                        currentSecondaryRole = partners.Role__c;
                    }

                    if (partners.Role__c == 'Referrer') {
                        showprimaryFee = true;
                        secondaryReferralDiscount = partners.AccountToId__r.Referral_Discount__c;
                    }
                }

                if (partners.AccountToId__c != null && !partners.IsPrimary__c && partners.Role__c != null
                    &&  label.additionalPartnerRoles.containsIgnoreCase(partners.Role__c)) {

                    hasInfluencer = true;    
                    con3.Partner_Account__c = partners.AccountToId__c;
                    influencerPartnerId = partners.Id;
                    currentInfluencerPartner = partners.AccountToId__c;
                    influencerPartnerRole();
                    influencerPartnerRole = partners.Role__c;
                    currentInfluencerRole = partners.Role__c;
                }
            }
        } else if (currentId != null ) {
            currentQuoteRecord = [SELECT ID, SBQQ__Partner__c, SBQQ__Account__c,SBQQ__Partner__r.Name, SBQQ__Distributor__c, 
                                  SBQQ__Distributor__r.Name, Partner_Role__c, Distributor_Role__c, Influencer_Role__c,
                                  SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.Referral_Discount__c,Influencer_Account__c,
                                  SBQQ__Partner__r.Referral_Discount__c,SBQQ__Distributor__r.Referral_Discount__c
                                  FROM SBQQ__Quote__C 
                                  WHERE Id=: currentId];

            recordToUpdate =  currentQuoteRecord.clone(false, false, false, false);
            recordToUpdate.Id= currentId;
            oppId = currentQuoteRecord.SBQQ__Opportunity2__c;
            accId = currentQuoteRecord.SBQQ__Account__c;                

            if (currentQuoteRecord.Partner_Role__c != null) {
                primaryPartnerRole = currentQuoteRecord.Partner_Role__c;
            }
            if (currentQuoteRecord.SBQQ__Partner__c != null) {
                hasPartner = true;
                con1.Partner_Account__c = currentQuoteRecord.SBQQ__Partner__c;
                
                primaryPartnerRole();
                if (currentQuoteRecord.Partner_Role__c != null) {
                    primaryPartnerRole = currentQuoteRecord.Partner_Role__c;
                }
                if (currentQuoteRecord.Partner_Role__c == 'Referrer') {
                    showprimaryFee = true;
                    primaryReferralDiscount = currentQuoteRecord.SBQQ__Partner__r.Referral_Discount__c;
                }
                checkPartner();
            }
            if (currentQuoteRecord.SBQQ__Distributor__c != null) {
                hasDistributor = true;                
                showSecond = true;
                con2.Partner_Account__c = currentQuoteRecord.SBQQ__Distributor__c;
                secondaryPartnerRole();
                if (currentQuoteRecord.Distributor_Role__c == 'Referrer') {
                    showSecondaryFee = true;
                    secondaryReferralDiscount = currentQuoteRecord.SBQQ__Distributor__r.Referral_Discount__c;
                }
            }
            if (currentQuoteRecord.Distributor_Role__c != null) {
                secondaryPartnerRole = currentQuoteRecord.Distributor_Role__c;
            }

            if (currentQuoteRecord.Influencer_Account__c != null) {
                hasInfluencer = true;                
                con3.Partner_Account__c = currentQuoteRecord.Influencer_Account__c;
                influencerPartnerRole();
            }
            if (currentQuoteRecord.Influencer_Role__c != null) {
                influencerPartnerRole = currentQuoteRecord.Influencer_Role__c;
            }
        }
        
        if (oppId != null) {
            opportunityRecord = [SELECT Id, OwnerId, (SELECT Id, UserId FROM OpportunityTeamMembers) 
                                 FROM Opportunity 
                                 WHERE Id =: oppId];
         }

        for (Add_Partner_Setting__mdt partnerSetting : [SELECT MasterLabel, Allow_Admins__c,Allowed_Profiles__c, Allow_Opportunity_Owner__c,
                                                        Allow_Opportunity_Team_Members__c,Opp_Additional_Help_text__c, Opportunity_Additional_Strength__c,
                                                        Opportunity_Additional__c,Opportunity_Primary_Strength__c, 
                                                        Opportunity_Primary_Type__c,Opportunity_Secondary_Strength__c, Opportunity_Secondary_Type__c,
                                                        Opp_Primary_Help_Text__c, Opp_Secondary_Help_Text__c, Quote_Additional_Help_Text__c,
                                                        Quote_Additional_Strength__c, Quote_Additional_Type__c, Quote_Primary_Help_Text__c,
                                                        Quote_Primary_Strength__c, Quote_Primary_Type__c, Quote_Secondary_Help_Text__c,
                                                        Quote_Secondary_Strength__c, Quote_Secondary_Type__c
                                                        FROM Add_Partner_Setting__mdt]) {

            if (opportunityRecord != null) {
                if (partnerSetting.Allow_Opportunity_Owner__c && opportunityRecord.OwnerId == UserInfo.getUserId()) {
                    showPage = true;
                }
                if (partnerSetting.Allow_Admins__c && profileName == 'System Administrator') {
                    showPage = true; 
                }
                if (partnerSetting.Allowed_Profiles__c != null) {
                    for (String allowedProfile : partnerSetting.Allowed_Profiles__c.Split(',')) {
                        profileList.add(allowedProfile);
                    }
                    if (!profileList.isEmpty() && profileList.contains(profileName)) {
                        showPage = true;
                    }
                }
                if (partnerSetting.Allow_Opportunity_Team_Members__c) {
                    for (OpportunityTeamMember oppTeam : opportunityRecord.OpportunityTeamMembers) {
                        if (oppTeam.UserId == UserInfo.getUserId()) {
                            showPage = true; 
                        }
                    }
                }
            }
                                                            
      if (currentRecord != null) {
                primaryHelpText = partnerSetting.Opp_Primary_Help_Text__c;
                primaryStrength = partnerSetting.Opportunity_Primary_Strength__c;
                primaryType = partnerSetting.Opportunity_Primary_Type__c;
                secondaryHelpText = partnerSetting.Opp_Secondary_Help_Text__c;
                secondaryStrength = partnerSetting.Opportunity_Secondary_Strength__c;
                secondaryType = partnerSetting.Opportunity_Secondary_Type__c;
                additionalHelpText = partnerSetting.Opp_Additional_Help_text__c;
                additionalStrength = partnerSetting.Opportunity_Additional_Strength__c;
                additionalType = partnerSetting.Opportunity_Additional__c;
            }
            else if (currentQuoteRecord != null) {
                primaryHelpText = partnerSetting.Quote_Primary_Help_Text__c;
                primaryStrength = partnerSetting.Quote_Primary_Strength__c;
                primaryType = partnerSetting.Quote_Primary_Type__c;
                secondaryHelpText = partnerSetting.Quote_Secondary_Help_Text__c;
                secondaryStrength = partnerSetting.Opportunity_Secondary_Strength__c;
                secondaryType = partnerSetting.Quote_Secondary_Type__c;
                additionalHelpText = partnerSetting.Quote_Additional_Help_Text__c;
                additionalStrength = partnerSetting.Quote_Additional_Strength__c;
                additionalType = partnerSetting.Quote_Additional_Type__c;
            }
        }

        
    }
    
    public PageReference saveThisOpp() {
        // Added by: Sharma Nemani | W-010762 | Case: 00251431 | 09/10/2019 --> START
        if(String.isNotBlank(primaryPartnerRole) && primaryPartnerRole=='Collaborative Sale' && (String.isBlank(selectedPI) || selectedPI=='--None--')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'Please select Partner Influence'));
            return null;
        }

        if(String.isNotBlank(secondaryPartnerRole) && secondaryPartnerRole=='Collaborative Sale' && (String.isBlank(selectedPI2) || selectedPI2=='--None--')){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'Please select Partner Influence'));
            return null;
        }
    // Sharma Nemani | W-010762 | Case: 00251431 | 09/10/2019 --> END
        hasError = false;
        showprimaryFee = false;
        Custom_Partner__c partner;

        Id partnerRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Partner Opportunity').getRecordTypeId();
        Id altxRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Alteryx Record Type').getRecordTypeId();

        if (accId != null) {
            if (accId  == con1.Partner_Account__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'Primary Partner Error: AccountTo cannot be Opportunity Account'));

                hasError = true;
            }
            if (accId == con2.Partner_Account__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'Secondary Partner Error: AccountTo cannot be Opportunity Account'));

                hasError = true;
            }
            if (accId == con3.Partner_Account__c) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'Influencer Partner Error: AccountTo cannot be Opportunity Account'));
                
                hasError = true;
            }
        }

        if ((con1.Partner_Account__c != null && (primaryPartnerRole == null || primaryPartnerRole == 'None'))
           || (con1.Partner_Account__c == null && (primaryPartnerRole != null && primaryPartnerRole == 'None'))) {
               
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'Error: Please make sure that both the partner field and the corresponding role is filled'));

            hasError = true;
        } else if (currentQuoteRecord  != null) {
            recordToUpdate.SBQQ__Partner__c = con1.Partner_Account__c;
            recordToUpdate.Partner_Role__c = primaryPartnerRole;
        }
        if ((con2.Partner_Account__c != null && (secondaryPartnerRole == null || secondaryPartnerRole== 'None'))
            || (con2.Partner_Account__c == null && (secondaryPartnerRole != null && secondaryPartnerRole== 'None'))) {
               
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'Error: Please make sure that both the Secondary Partner field and the corresponding role is filled'));

            hasError = true;
        } else if (currentQuoteRecord  != null) {
            recordToUpdate.SBQQ__Distributor__c = con2.Partner_Account__c;
            recordToUpdate.Distributor_Role__c = secondaryPartnerRole;
        }

        if ((con3.Partner_Account__c != null && (influencerPartnerRole == null || influencerPartnerRole== 'None'))
            || (con3.Partner_Account__c == null && (influencerPartnerRole != null && influencerPartnerRole== 'None'))) {

               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'Error: Please make sure that both the Additional Partner field and the corresponding role is filled'));

               hasError = true;
        } else if (currentQuoteRecord  != null) {
            recordToUpdate.Influencer_Account__c = con3.Partner_Account__c;
            recordToUpdate.Influencer_Role__c = influencerPartnerRole;
        }

        if (!hasPartner && !hasDistributor && !hasInfluencer && con1.Partner_Account__c == null
            && con2.Partner_Account__c == null && con3.Partner_Account__c == null) {
                
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'Error: Please make sure that you fill either of the Partner fields'));

            hasError = true;
            showSecond = false;
        }

        if (con1.Partner_Account__c != null && con1.Partner_Account__c == con2.Partner_Account__c) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'Error: Primary Partner and the Secondary Partner cannot be the same'));

            hasError = true;
        }
        if (!showSecond) {
            if (con2.Partner_Account__c != null || secondaryPartnerRole != null) {
                con2.Partner_Account__c = null;
                secondaryPartnerRole = null;
            }
        } else if (primaryPartnerRole != null && partnerTypeSetting.containsKey(primaryPartnerRole)) {
            Partner_Type_Validation__c pty = partnerTypeSetting.get(primaryPartnerRole);
            if (con2.Partner_Account__c != null && secondaryPartnerRole != null 
                && pty.Allow_Secondary_Partner__c) {

                String allowedRoles = pty.Secondary_Partner_Role__c != null ? pty.Secondary_Partner_Role__c : '';
                if (!allowedRoles.containsIgnoreCase(secondaryPartnerRole)) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                            'Error: You cannot add a "' + secondaryPartnerRole + '" Secondary Partner with a "' 
                            + primaryPartnerRole + '" as the Primary Partner'));
                    
                    hasError = true;
                }
            }
        }

        if (!hasError) {
            if (currentRecord != null) {
                if (con1.Partner_Account__c != null && (con1.Partner_Account__c != currentPrimaryPartner 
                    || primaryPartnerRole != currentPrimaryRole)) {
                        
                    partner = new Custom_Partner__c();
                    partner.OpportunityId__c = currentRecord.Id;
                    partner.AccountToId__c = con1.Partner_Account__c;
                    partner.IsPrimary__c = true;
                    partner.Role__c = primaryPartnerRole;
                    partnersToInsert.add(partner);
                }
                if (con1.Partner_Account__c != currentPrimaryPartner || primaryPartnerRole != currentPrimaryRole) {
                    partnerIds.add(primaryPartnerId);
                }

                if (con2.Partner_Account__c != null && (con2.Partner_Account__c != currentSecondaryPartner
                    || secondaryPartnerRole != currentSecondaryRole)) {
                        
                    partner = new Custom_Partner__c();
                    partner.OpportunityId__c = currentRecord.Id;
                    partner.AccountToId__c = con2.Partner_Account__c;
                    partner.IsPrimary__c = false;
                    partner.Role__c = secondaryPartnerRole;
                    partnersToInsert.add(partner);
                }
                if (con2.Partner_Account__c != currentSecondaryPartner || secondaryPartnerRole != currentSecondaryRole) {
                    partnerIds.add(secondaryPartnerId);
                }

                if (con3.Partner_Account__c != null && (con3.Partner_Account__c != currentInfluencerPartner
                    || influencerPartnerRole!= currentInfluencerRole)) {
                        
                    partner = new Custom_Partner__c();
                    partner.OpportunityId__c = currentRecord.Id;
                    partner.AccountToId__c = con3.Partner_Account__c;
                    partner.IsPrimary__c = false;
                    partner.Role__c = influencerPartnerRole;
                    partnersToInsert.add(partner);
                }
                if (con3.Partner_Account__c != currentInfluencerPartner || influencerPartnerRole != currentInfluencerRole) {
                    partnerIds.add(InfluencerPartnerId);
                }
                
                if (!partnerIds.isEmpty()) {
                    partnersToDelete = [Select Id from Custom_Partner__c where Id In : partnerIds];
                }
            }

            try{
                if (currentQuoteRecord != null) {
                    if (recordToUpdate.SBQQ__Distributor__c != currentQuoteRecord .SBQQ__Distributor__c 
                       || recordToUpdate.SBQQ__Partner__c != currentQuoteRecord .SBQQ__Partner__c 
                       || recordToUpdate.Partner_Role__c != currentQuoteRecord .Partner_Role__c 
                       || recordToUpdate.Distributor_Role__c != currentQuoteRecord .Distributor_Role__c 
                       || recordToUpdate.Influencer_Account__c != currentQuoteRecord .Influencer_Account__c 
                       || recordToUpdate.Influencer_Role__c != currentQuoteRecord .Influencer_Role__c ) {
                        
                        update recordToUpdate;
                    } 
                }
                if (!partnersToDelete.isEmpty()) {
                    delete partnersToDelete;
                }
                if (!partnersToInsert.isEmpty()) {
                    insert partnersToInsert;
                }
            } catch (Exception ex) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
                hasError = true;
            }
        }
        
        if (hasError) {
            return null;
        }

        /* Added by: Sharma Nemani | W-010762 | Case: 00251431 --> START
         * Date:09/04/2019
         * Description: When Role is 'Collaborative Sale', then display Partner Influence field with 6 picklist values in it.
        */
        if(selectedPI!=null && selectedPI!='--None--' && primaryPartnerRole!=null && primaryPartnerRole!='--None--' && primaryPartnerRole=='Collaborative Sale'){
            String currentIdString = (String)currentId;
            if(currentId != null && currentIdString.startsWith('006')){
                currentRecord.Partner_Role_Reason__c = selectedPI;
                update currentRecord;
            }else{
                SBQQ__Quote__c  quote = [select id, SBQQ__Opportunity2__c  from SBQQ__Quote__c  where Id =:currentId];
                if(quote.SBQQ__Opportunity2__c!=null){
                    Opportunity opp = new Opportunity(Id=quote.SBQQ__Opportunity2__c,Partner_Role_Reason__c = selectedPI);
                    update opp;
                }
            }
        }
       // Sharma Nemani | W-010762 | Case: 00251431 --> END
        
        PageReference reference = new PageReference('/' + currentId);
        return reference; 
    }
    
    public PageReference cancel() {
        PageReference reference = new PageReference('/' + currentId);
        return reference; 
    }
        
    public void primaryPartnerRole() {
        String currentAccountType;
        showprimaryFee = false;
        if (primaryPartnerRoles.size() > 0) {
            primaryPartnerRoles.clear();
            primaryPartnerRoles.add(new SelectOption('', '--None--'));
        }
        
        for (Account acc : [SELECT Partner_Type__c 
                            FROM Account 
                            WHERE Id =: con1.Partner_Account__c 
                            AND Partner_Type__c != null]) {
            currentAccountType = acc.Partner_Type__c;
            if (accountTypeToRolesMap.containsKey(currentAccountType)) {
                for (Selectoption option : accountTypeToRolesMap.get(currentAccountType)) {
                    string partnerType = option.getValue();
                    if (partnerTypeSetting.containsKey(partnerType)) {
                        primaryPartnerRoles.add(option);
                    }
                }
            }
        }
        System.debug('contact partner account ' + con1.Partner_Account__c + 'primary partner roles ' + primaryPartnerRoles);
        if (primaryPartnerRoles.size() < 2 && con1.Partner_Account__c != null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'This Account cannot be added as a Primary Partner'));

            hasError = true;
        } else if (partnerTypeSetting.containsKey(primaryPartnerRole) 
            && !partnerTypeSetting.get(primaryPartnerRole).Allow_Secondary_Partner__c) {
            
            showSecond = false;
        }

        if (con1.Partner_Account__c == null) {
            showSecond = false;
        }
        checkPartner();
    }
    
    public void secondaryPartnerRole() {
        String currentAccountType;                
        secondaryPartnerRole = null; 
        showSecondaryFee = false;
        if (distributorRoles.size() > 0) {
            distributorRoles.clear();
            distributorRoles.add(new SelectOption('', '--None--'));  
        }
        
        for (Account acc : [SELECT Partner_Type__c 
                            FROM Account 
                            WHERE Id =: con2.Partner_Account__c 
                            AND Partner_Type__c != null]) {
            
            currentAccountType = acc.Partner_Type__c;
            if (accountTypeToRolesMap.containsKey(currentAccountType)) {
                for (Selectoption option : accountTypeToRolesMap.get(currentAccountType)) {
                    string partnerType = option.getValue();
                    if (partnerTypeSetting.containsKey(partnerType)) {                        
                        distributorRoles.add(option);
                    }
                }
            }
        }
        
        if (distributorRoles.size() < 2 && con2.Partner_Account__c != null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                    'This Account cannot be added as a Secondary Partner'));

            hasError = true;                            
        }
        
        if (String.isBlank(currentAccountType) && con2.Partner_Account__c != null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                'Error: Please make sure that the Selected Account is a partner and has a valid Partner type.'));
            
            hasError = true;
        }
    }

    public void influencerPartnerRole() {
        String currentAccountType;

        if (influencerRoles.size() > 0) {
            influencerRoles.clear();
            influencerRoles.add(new SelectOption('', '--None--'));  
        }
        
        for (Account acc : [SELECT Partner_Type__c 
                            FROM Account 
                            WHERE Id =: con3.Partner_Account__c 
                            AND Partner_Type__c != null]) {
                
            currentAccountType = acc.Partner_Type__c;

            if (accountTypeToRolesMap.containsKey(currentAccountType)) {
                for (Selectoption option : accountTypeToRolesMap.get(currentAccountType)) {
                    string partnerType = option.getValue();
                    if (label.additionalPartnerRoles.containsIgnoreCase(partnerType)) {                        
                        influencerRoles.add(option); 
                    }
                }
            }
        }
        
        if (influencerRoles.size() < 2 && con3.Partner_Account__c != null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 
                'This Account cannot be added as a Additional Partner'));

            hasError = true;                            
        }
        checkPartner();
    }

    public void primaryReferralFee() {
        if (con1.Partner_Account__c != null && primaryPartnerRole == 'Referrer') {
            Account acc = [SELECT Id, Partner_Type__c, Partner_Relationship__c, 
                           Referral_Discount__c, RecordType.Name 
                           FROM Account 
                           WHERE Id=:con1.Partner_Account__c];

            primaryReferralDiscount = acc.Referral_Discount__c != null ? acc.Referral_Discount__c : '0%' ;
            showprimaryFee = true;
        } else {
            showprimaryFee = false; 
        }  
        checkPartner();
    }
    
    public void secondaryReferralFee() {
        if (con2.Partner_Account__c != null && secondaryPartnerRole == 'Referrer') {
             Account acc = [SELECT Id, Partner_Type__c, Partner_Relationship__c, 
                                Referral_Discount__c, RecordType.Name 
                            FROM Account 
                            WHERE Id=:con2.Partner_Account__c];
            secondaryReferralDiscount = acc.Referral_Discount__c != null ? acc.Referral_Discount__c : '0%';
            showSecondaryFee = true;
        } else {
            showSecondaryFee = false;
        }
    }

    public void checkPartner() {
        if (partnerTypeSetting.isEmpty()) {
            for(Partner_Type_Validation__c ptv : Partner_Type_Validation__c.getAll().values()) {
                partnerTypeSetting.put(ptv.Primary_Partner_Role__c , ptv);
            }
        }
        if (con1.Partner_Account__c != null && primaryPartnerRole != null) {
            if (partnerTypeSetting.containsKey(primaryPartnerRole)) {
                Partner_Type_Validation__c pty = partnerTypeSetting.get(primaryPartnerRole);
                if (pty.Allow_Secondary_Partner__c) {
                    showSecond = true;
                } else {
                    showSecond = false;
                }
            } else {
                showSecond = true;
            }
        } else {
            showSecond = false;
        }
        if (!showSecond) {
            con2.Partner_Account__c = null;
            secondaryPartnerRole = null;
            secondaryPartnerRole();
        }
    }
}