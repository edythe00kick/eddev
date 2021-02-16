public with sharing class QuoteCreationController {
    public Boolean hideSidebar{get;set;}
    public Boolean showSidebar{get;set;}
    public Boolean hasError{get;set;}
    public Boolean showRecordType{get;set;}
    public Boolean showLGLA{get;set;}
    public Boolean showLicGrpBlock{get;set;}
    public Boolean showLicAdmBlock{get;set;}
    public Boolean showContBlock{get;set;}
    public Boolean showSkip{get;set;}
    public String contButtonText{get;set;}
    public String quoteType{get;set;}
    public String purchaseType{get;set;}
    public boolean calledFromQuote = false; //Added by: Sharma Nemani | W-012345 | Date: 06/26/2019.
    public List<SelectOption> quoteTypes {get;set;}
    public List<SelectOption> purchaseTypes{get;set;}
    public List<Order_Group__c> licGrpList{get;set;}
    public List<License_Administrator__c> licAdmList{get;set;}
    public Order_Group__c licGrpRec{get;set;}
    public License_Administrator__c licAdmRec{get;set;}
    public License_Administrator__c newLicAdmRec{get;set;}
    public Id licGrpId{get;set;}
    public Id licAdmId{get;set;}
    public Integer startRow{get;set;}
    public Integer rowsLimit{get;set;}
    public Integer totalRecords{get;set;}
    public Integer currentPage{get;set;}
    public Integer totalPage{get;set;}
    public Opportunity opp{get;set;}
    Account acc;
    Id accId;
    Id oppId; 
    Id propId;
    String dealDesk;
    String submitOrderGroup;
    Boolean approvalRequired = false;
    String retURL;
    String retId;
    String opportunityId;
    public SBQQ__Quote__c quote{get;set;}
	
    public boolean isAllowed{get;set;}
    
    public QuoteCreationController(ApexPages.StandardController controller) {
        
        propId = ApexPages.currentPage().getParameters().get('propId');
        
        opportunityId = ApexPages.currentPage().getParameters().get('opprId'); // Added By: Sharma Nemani | W-012645 | Date: 07/25/2019
        
        
        
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        accId = ApexPages.currentPage().getParameters().get('accId'); //Added by: Sharma Nemani | W-012345 | Date: 06/26/2019.
        oppId = ApexPages.currentPage().getParameters().get('oppId'); //Added by: Sharma Nemani | W-012345 | Date: 06/26/2019.
        
        dealDesk = ApexPages.currentPage().getParameters().get('dealdesk');
        submitOrderGroup = ApexPages.currentPage().getParameters().get('SubmitOrderGroup');
        showRecordType = false;
        quoteTypes = new List<SelectOption>();
        
        // Added By: Sharma Nemani | W-012345 --> START
        // Date: 06/27/2019 
        if(!String.isBlank(propId)){
            quote = [select id,SBQQ__Account__r.Id,SBQQ__Opportunity2__r.Id,RecordType.DeveloperName,
                     Purchase_Type__c from SBQQ__Quote__c where Id = : propId limit 1]; 
            
            accId = quote.SBQQ__Account__r.Id;
            oppId = quote.SBQQ__Opportunity2__r.Id;

            if(quote.RecordType.DeveloperName != 'Draft'){
                
                // Added by: Sharma Nemani | W-013514 | Date: 11/04/2019 --> START
                // Description: To let Deal Desk and Fulfillment edit License Group on an Accepted Quote.
                isAllowed = false;
                profile pfName = [select id,name from profile where Id =:UserInfo.getProfileId()];
                system.debug('pfName.name :: '+pfName.name);
                if(pfName.name.equalsIgnoreCase('Alteryx - Fulfillment') || pfName.name.equalsIgnoreCase('Alteryx - Sales - Deal Desk')){
                    isAllowed = true;
                    showLGLA = true;
                	showLicGrpBlock = true;
                	recordTypeNext(); 
                }
                
                system.debug('showLGLA :: '+showLGLA);
                system.debug('isAllowed :: '+isAllowed);
                // Sharma Nemani | W-013514 | Date: 11/04/2019 --> END
                
                return;
            }
        }
        
        if(String.isNotBlank(opportunityId)){
            oppId = opportunityId;
            quoteType = 'AFG';
        }
        
        // Sharma Nemani | W-012345 | Date: 06/27/2019 --> END
        
        // Added By: Sharma Nemani | W-012345 --> START
        // Date: 06/26/2019
        if (retURL != null || oppId!= null) {
            if(retURL != null){
                retId = retURL.replace('/', '');
            }
            else if(oppId!= null){
                retId = oppId;
            }
        // Sharma Nemani | W-012345 | Date: 06/26/2019 --> END
        
        System.debug('Test ;;' + retURL +' ; '+ oppId); 
            if (retId.startsWith('006')) {
                retId = retId.substringBefore('?'); //Sergio Flores 07/19/2019 W-012518
                oppId = retId;
                opp = [SELECT Id, AccountId, NFR_Opportunity__c, Type FROM Opportunity WHERE Id = :oppId];
                if (opp.NFR_Opportunity__c) {
                    quoteTypes.add(new SelectOption('NFR', 'NFR'));
                    quoteType = 'NFR';
                    recordTypeNext();
                } else {
                    if (opp.Type != null) {
                        List<Quote_Creation_Mapping__mdt> mapping = [SELECT Class_of_Business__c, Allowed_Purchase_Type__c 
                                                                     FROM Quote_Creation_Mapping__mdt 
                                                                     WHERE Class_of_Business__c = :opp.Type];

                        if (!mapping.isEmpty()) {
                            quoteTypes.add(new SelectOption('Purchase', 'Purchase'));
                            quoteTypes.add(new SelectOption('Evaluation', 'Evaluation'));
                            purchaseTypes = new List<SelectOption>();
                            for (String type : mapping[0].Allowed_Purchase_Type__c.split(',')) {
                                purchaseTypes.add(new SelectOption(type, type));
                            }
                            quoteType = 'Purchase';
                            //Added by: Sharma Nemani | W-012645 | 07/25/2019
                            if(String.isNotBlank(opportunityId)){
                                quoteType = 'AFG';
                            }
                            showRecordType = true;
                        } else {
                            quoteTypes.add(new SelectOption('Evaluation', 'Evaluation'));
                            quoteType = 'Evaluation';
                            showRecordType = true;
                        }
                    } else {
                        quoteTypes.add(new SelectOption('Evaluation', 'Evaluation'));
                        quoteType = 'Evaluation';
                        showRecordType = true;
                    }
                }
            } else if(oppId == null) { //Added by: Sharma Nemani | W-012345 | Date: 06/26/2019. Added if(oppId == null).
                hasError = true;
            }
        } else {
            hasError = true;
        }
        // Added by: Sharma Nemani | W-012345 --> START
        // Date: 06/26/2019
        if(retURL == null){
            calledFromQuote = true;
            recordTypeNext();
        }
        else{
            showRecordType = true;
        }
      //  Sharma Nemani | W-012345 | Date: 06/26/2019 --> END
      
    }

    public void recordTypeNext() {
        if (quoteType == null && !isAllowed) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                        'Quote Type is required.'));
        } else if (!calledFromQuote && (quoteType == 'Purchase' && purchaseType == null && !isAllowed)) { // "calledFromQuote". Added by Sharma Nemani | W-012345 | Date: 06/26/2019 | to check whether page is opened from quote or Opp.
            
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                        'Purchase Type is required.'));
            
        } else {
            hideSidebar = true;
            showSidebar = false;
            showRecordType = false;
            showLGLA = true;
            
            if(opp!=null){ // Added by: Sharma Nemani | W-013514 | Date: 11/04/2019
            	accId = opp.AccountId;   
            }
            showLicGrpBlock = false;
            showLicAdmBlock = false;
            showContBlock = false;
            licAdmList = new List<License_Administrator__c>();
            licGrpRec = new Order_Group__c();
            licAdmRec = new License_Administrator__c();
            newLicAdmRec = new License_Administrator__c();
                        
            if(accId!=null){ // Added by: Sharma Nemani | W-013514 | Date: 11/04/2019
                acc = [SELECT Id, Name FROM Account WHERE Id = :accId];
            }
            
            showSkip = !(dealDesk == 'true');
            
            if (licGrpExist()) {
                showLicGrpBlock = true;
            } else {
                licAdmList.add(new License_Administrator__c());
                contButtonText = 'Back To Record Type';
                showContBlock = true;
            }
        }
    }

    public PageReference cancel() {
        // Added By: Sharma Nemani | W-012345 --> START
        // Date: 06/27/2019     
        PageReference pr = new PageReference(retURL!=null?retURL:System.URL.getSalesforceBaseUrl().toExternalForm()+'/'+propId);
        pr.setRedirect(true); // Sharma Nemani | W-012345 | Date: 06/27/2019  --> END
        return pr;
    }
    
    private Boolean licGrpExist() {
        licGrpList = [SELECT Id, Name, Primary_License_Administrator__c, 
                      License_Group_Name__c, 
                      (SELECT Id, Name, Order_Group__c, Amount__c, Accepted_Date__c 
                       FROM Quotes__r 
                       WHERE SBQQ__Status__c = 'Accepted' 
                       ORDER BY Accepted_Date__c DESC LIMIT 5) 
                      FROM Order_Group__c 
                      WHERE Id IN (SELECT Order_Group__c FROM SBQQ__Quote__c 
                                   WHERE SBQQ__Account__c = :accId)
                      ORDER BY CreatedDate];


        if (!licGrpList.isEmpty()) {
            startRow = 0;
            totalRecords = licGrpList.size();
            currentPage = 1;
            rowsLimit = 10;
            totalPage = Integer.valueOf(Math.ceil(Double.valueOf(totalRecords)/rowsLimit));
            return true;
        } else {
            return false;
        }
    }

    public PageReference skip() {
        SBQQ__Quote__c newQuote = createQuote(accId, oppId, null, null, quoteType, purchaseType);
        // Added by: Sharma Nemani | W-012645 | Date: 06/25/2019 --> START
        if(String.isNotBlank(opportunityId)){
            newQuote.RecordTypeId = [select id from recordType where developername = 'Draft_Simple'].Id;
        }
        // Sharma Nemani | W-012645 | Date: 06/25/2019 --> END
        try {
            // Changes made by: Sharma Nemani | W-012345 --> START
            // Date: 06/28/2019
            if(String.isBlank(propId)){
                insert newQuote;
            }else{
                newQuote.Id = propId;
                update newQuote;
            }
          //  Sharma Nemani | W-012345 | Date: 06/28/2019 --> END

        } catch (Exception ex) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }

        PageReference pr = new PageReference('/' + newQuote.Id);

        /*PageReference pr = new PageReference('/apex/ProposalRedirect?recordType='
                                             +recordType+'&purchasetype='
                                             +purchasetype+'&accId='+accId
                                             +'&oppId='+oppId);*/
        pr.setRedirect(true);
        return pr;
    }

    public void licGrpBack() {
        showSidebar = true;
        hideSidebar = false;
        showRecordType = true;
        showLGLA = false;
    }

    public void licGrpNext() {
        licAdmList = [SELECT Name, Contact__c, Contact__r.Name FROM License_Administrator__c 
                      WHERE Order_Group__c = :licGrpId];
        
        licGrpRec = [SELECT License_Group_Name__c, Name, License_Administrator__c 
                     FROM Order_Group__c WHERE Id = :licGrpId];
        licAdmRec = new License_Administrator__c();
        licAdmList.add(new License_Administrator__c());
        newLicAdmRec = new License_Administrator__c();
        showLicGrpBlock = false;
        showLicAdmBlock = true;
        showContBlock = false;
    }
    
    public void createLicGrp() {
        licAdmList = new List<License_Administrator__c>();
        licAdmList.add(new License_Administrator__c());
        licGrpRec = new Order_Group__c();
        licAdmRec = new License_Administrator__c();
        contButtonText = 'Back';
        showLicGrpBlock = false;
        showLicAdmBlock = false;
        showContBlock = true;
    }
    
    public PageReference licAdmFinish() {
        if (!String.isBlank(licAdmId)) {
            /*if (dealDesk == 'true') {
                SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = propId);
                quote.Order_Group__c = licGrpId;
                quote.License_Administrator__c = licAdmId;
                
                if (SubmitOrderGroup != 'True') {
                    quote.Approval_Stage__c = 'Submitted to Deal Desk';
                    if(approvalCheck()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                        'This quote required approval, please submit to approval prior to submitting to Deal Desk.'));
                        
                        return null;
                    }
                }
                
                try {
                    update quote;
                    PageReference pr = new PageReference('/' + propId);
                    pr.setRedirect(true);
                    return pr;
                } catch (Exception ex) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
                    return null;
                }
            } else {*/
            	
                SBQQ__Quote__c newQuote = createQuote(accId, oppId, licGrpId, licAdmId, quoteType, purchaseType);
            	//Added by: Sharma Nemani | W-012645 | Date: 07/25/2019 --> START
				if(String.isNotBlank(opportunityId)){
                    newQuote.RecordTypeId = [select id from recordType where developername = 'Draft_Simple'].Id;
                    newQuote.SBQQ__StartDate__c = system.today();

                }
            	// Sharma Nemani | W-012645 | Date: 07/25/2019 --> END
                try {
                 // Changes made by: Sharma Nemani | W-012345 --> START
                // Date: 06/28/2019
                    if(String.isBlank(propId)){
                        insert newQuote;
                    }else{
                        newQuote.Id = propId;
                        update newQuote;
                    }
                    //  Sharma Nemani | W-012345 | Date: 06/28/2019 --> END
                
                    PageReference pr = new PageReference('/' + newQuote.Id);

                    /*PageReference pr 
                        = new PageReference('/apex/ProposalRedirect?recordType=' 
                                            +recordType+'&purchasetype=' 
                                            +purchasetype+'&accId='+accId 
                                            +'&oppId='+oppId+'&ogId='+licGrpId 
                                            +'&licAdmId='+licAdmId);*/
                    
                    pr.setRedirect(true);
                    return pr;
                } catch (Exception ex) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
                }
            //}
        } else {
            Savepoint sp = Database.setSavepoint();
            try {
                if (newLicAdmRec.Contact__c == null) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select the contact.'));
                    return null;
                }
                
                newLicAdmRec.Order_Group__c = licGrpRec.Id;
                newLicAdmRec.Account__c = acc.Id;
                insert newLicAdmRec;
                
                if (licGrpRec.License_Administrator__c == null) {
                    licGrpRec.License_Administrator__c = newLicAdmRec.Id;
                    update licGrpRec;
                }

                PageReference pr;

                /*if (dealDesk == 'true') {
                    SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = propId);
                    quote.Order_Group__c = licGrpId;
                    quote.License_Administrator__c = newLicAdmRec.Id;
                    
                    if (SubmitOrderGroup != 'True') {
                        quote.Approval_Stage__c = 'Submitted to Deal Desk';
                        if(approvalCheck()){
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                            'This quote required approval, please submit to approval prior to submitting to Deal Desk.'));
                            
                            return null;
                        }
                    }
                    
                    update quote;
                    pr = new PageReference('/' + propId); 
                } else {*/
                    SBQQ__Quote__c newQuote = createQuote(accId, oppId, licGrpRec.Id, newLicAdmRec.Id, quoteType, purchaseType);
                // Changes made by: Sharma Nemani | W-012345 --> START
                // Date: 06/28/2019 
                
                // Added by: Sharma Nemani | W-012645 | 07/25/2019 --> START
				if(String.isNotBlank(opportunityId)){
                    newQuote.RecordTypeId = [select id from recordType where developername = 'Draft_Simple'].Id;
                    newQuote.SBQQ__StartDate__c = system.today();
                }
                // Sharma Nemani | W-012645 | 07/25/2019 --> END
                if(String.isBlank(propId)){
                        insert newQuote;
                    }else{
                        newQuote.Id = propId;
                        update newQuote;
                    }
                //  Sharma Nemani | W-012345 | Date: 06/28/2019 --> END
                
                    pr = new PageReference('/' + newQuote.Id);

                    /*pr = new PageReference('/apex/ProposalRedirect?recordType='
                                           +recordType+'&purchasetype='
                                           +purchasetype+'&accId='+accId
                                           +'&oppId='+oppId+'&ogId='+licGrpRec.Id
                                           +'&licAdmId='+newLicAdmRec.Id);*/
                //}
                pr.setRedirect(true);
                return pr;
            } catch (Exception ex) {
                newLicAdmRec = new License_Administrator__c();
                Database.rollback(sp);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
            }
        }
        return null;
    }
    
    public void licAdmBack() {
        showLicGrpBlock = true;
        showLicAdmBlock = false;
        showContBlock = false;
    }
    
    public PageReference contButton() {
        if (contButtonText == 'Back To Record Type') {
            showRecordType = true;
            showLGLA = false;
            showContBlock = false;
            showSidebar = true;
        } else if (contButtonText == 'Back'){
            showLicAdmBlock = false;
            showContBlock = false;
            showLicGrpBlock = true;
            return null;
        }
        return null;
    }
    
    public void contactChanged() {
        if (String.isBlank(licGrpRec.License_Group_Name__c) && licAdmRec.Contact__c != null) {
            Contact con = [SELECT Id, Name FROM Contact WHERE Id = :licAdmRec.Contact__c];
            licGrpRec.License_Group_Name__c = acc.Name + ' - ' + con.Name;
        } else if (String.isNotBlank(licGrpRec.License_Group_Name__c) && licAdmRec.Contact__c == null) {
            licGrpRec.License_Group_Name__c = null;
        }
    }
    
    public PageReference contFinish() {
        Savepoint sp = Database.setSavepoint();
        try {
            if (licAdmRec.Contact__c == null) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Please select the contact.'));
                return null;
            }
            
            licGrpRec.Account__c = acc.Id;
            Contact con = [SELECT Id, Name FROM Contact WHERE Id = :licAdmRec.Contact__c];
            if (String.isBlank(licGrpRec.License_Group_Name__c)) {
                licGrpRec.License_Group_Name__c = acc.Name + ' - ' + con.Name;
            }
            insert licGrpRec;
            
            licAdmRec.Order_Group__c = licGrpRec.Id;
            licAdmRec.Account__c = acc.Id;
            insert licAdmRec;
            
            licGrpRec.License_Administrator__c = licAdmRec.Id;
            update licGrpRec;

            PageReference pr;
            
            /*if (dealDesk == 'true') {
                SBQQ__Quote__c quote = new SBQQ__Quote__c(Id = propId);
                quote.Order_Group__c = licGrpRec.Id;
                quote.License_Administrator__c = licAdmRec.Id;
                
                if (SubmitOrderGroup != 'True') {
                    quote.Approval_Stage__c = 'Submitted to Deal Desk';
                    if(approvalCheck()){
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,
                        'This quote required approval, please submit to approval prior to submitting to Deal Desk.'));
                        
                        return null;
                    }
                }
                
                update quote;
                pr = new PageReference('/' + propId);
            } else {*/
                SBQQ__Quote__c newQuote = createQuote(accId, oppId, licGrpRec.Id, licAdmRec.Id, quoteType, purchaseType);
               // Changes made by: Sharma Nemani | W-012345 --> START
               // Date: 06/28/2019 
               
               //Added by: Sharma Nemani | W-012645| 07/25/2019 --> START
                if(String.isNotBlank(opportunityId)){
                    newQuote.RecordTypeId = [select id from recordType where developername = 'Draft_Simple'].Id;
                }
            // Sharma Nemani | W-012645| 07/25/2019 --> END
                if(String.isBlank(propId)){
                    insert newQuote;
                }else{
                    newQuote.Id = propId;
                    update newQuote;
                }
                //  Sharma Nemani | W-012345 | Date: 06/28/2019 --> END
                
                /*pr = new PageReference('/apex/ProposalRedirect?recordType='
                                       +recordType+'&purchasetype='
                                       +purchasetype+'&accId='+accId
                                       +'&oppId='+oppId+'&ogId='+licGrpRec.Id
                                       +'&licAdmId='+licAdmRec.Id);*/

                pr = new PageReference('/' + newQuote.Id);
            //}
            pr.setRedirect(true);
            return pr;
        } catch (Exception ex) {
            Database.rollback(sp);
            licGrpRec = new Order_Group__c();
            licAdmRec = new License_Administrator__c();
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,ex.getMessage()));
        }
        return null;
    }
    
    public void rowsLimitChanged() {
        startRow = 0;
        currentPage = 1;
        totalPage = Integer.valueOf(Math.ceil(Double.valueOf(totalRecords)/rowsLimit));
    }
    
    public void firstPage() {
        startRow = 0;
        currentPage = 1;
    }
    
    public void prevPage() {
        startRow -= rowsLimit;
        startRow = (startRow < 0) ? 0 : startRow;
        currentPage--;
        currentPage = (currentPage <= 0) ? 1 : currentPage;
    }
    
    public void nextPage() {
        startRow += rowsLimit;
        currentPage++;
        if (currentPage > totalPage) {
            startRow = rowsLimit*(totalRecords/rowsLimit);
            currentPage = totalPage;
        }
        if (startRow == totalRecords) {
            startRow = totalRecords - rowsLimit;
        }
    }
    
    public void lastPage() {
        startRow = rowsLimit*(totalRecords/rowsLimit);
        currentPage = totalPage;
        if (startRow == totalRecords) {
            startRow = totalRecords - rowsLimit;
        }
    }

    public SBQQ__Quote__c createQuote(Id accId, Id oppId, Id lgId, Id laId, String quoteType, String purchaseType) {
        SBQQ__Quote__c newQuote = new SBQQ__Quote__c();
        newQuote.SBQQ__Account__c = accId;
        newQuote.SBQQ__Opportunity2__c = oppId;
        newQuote.Order_Group__c = lgId;
        newQuote.License_Administrator__c = laId;
        newQuote.Quote_Type__c = quoteType;
        //Added by: Sharma Nemani | W-012645 | Date: 08/07/2019 --> START
        //Description: To add 12 months as Subscription Term if the Quote is being created from the
        //'Create AFG Quote' button on Contact object.
        if(String.isNotBlank(opportunityId)){
            newQuote.SBQQ__SubscriptionTerm__c  = 12;
        }
        //Sharma Nemani | W-012645 | Date: 08/07/2019 --> END
        
        
        if (quoteType == 'Purchase') {
            newQuote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft').getRecordTypeId();
        } else {
            newQuote.RecordTypeId = Schema.SObjectType.SBQQ__Quote__c.getRecordTypeInfosByName().get('Draft_Simple').getRecordTypeId();
        }
        newQuote.Purchase_Type__c = (quoteType == 'Purchase') ? purchaseType : '';
        //Added by: Sharma Nemani | W-012645 | Date: 07/25/2019 --> START
        if(String.isNotBlank(opportunityId)){
            newQuote.RecordTypeId = [select id from recordType where developername = 'Draft_Simple'].Id;
        }
        //Sharma Nemani | W-012645 | Date: 07/25/2019 --> END
        return newQuote;
    }
    
    /*public boolean approvalCheck(){
        return false;
    }*/
}