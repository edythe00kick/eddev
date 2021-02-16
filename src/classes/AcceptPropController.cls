/*
 * Class Name - AcceptPropController
 * 
 * %W% %E% Grazitti Team
 * This class is the controller of "AcceptProp" VF Page.
 */

/**
 * This class contains different methods to handle the page functionality.
 * 
 * @author Hemendra Singh Rajawat
 * @version 1.0 October 29, 2018

 Last Edit by Sergio Flores 05/20/2019
 For refactoring for CPQ
 
 */

public class AcceptPropController {
    public String errorMsg{get;set;}
    public String retURL{get;set;}
    public SBQQ__Quote__c quote{get;set;}
    public Boolean showCheckList{get;set;}
    public Boolean isPurchased{get;set;}
    private String quoteId;
    private String oppId;
    private List<OpportunityContactRole> oppContRole;
    private Proposal_Settings__mdt propSetting;
    private Set<String> validStage;
    private String initialOppStage;
    private string salesChannel = 'Direct';
    private Boolean updateAccount = false;
    
    public AcceptPropController(ApexPages.StandardController controller) {
        showCheckList = true;
        isPurchased = false;
        
        quoteId = ApexPages.currentPage().getParameters().get('id');
        
        if(!Test.isRunningTest()){ //Sharma Nemani | Date: 06/24/2019
            propSetting = UtilityClass.getProposalSettings('Settings');
            validStage = new Set<String>(propSetting.Valid_Stage_Name__c.split(','));
        }else{
            validStage = new Set<String>{'3 - Negotiate','4 - Finalize + Close'};
        }
        String Invalid_Partner_Roles = '';
        if(!Test.isRunningTest()){ //Sharma Nemani | Date: 06/24/2019
            Invalid_Partner_Roles = propSetting.Invalid_Partner_Roles__c;
        }else{
            Invalid_Partner_Roles = 'Partner Sales Representative,Partner Technical Representative';
        }
         
        
        quote = [SELECT Id, Name, SBQQ__Opportunity2__c, Purchase_Type__c,
                SBQQ__Account__c, Account_currently_in_collections__c, Quote_Type__c,
                SBQQ__Status__c, SBQQ__Partner__c, //Prior_Contract__c,
                SBQQ__Opportunity2__r.StageName,
                SBQQ__Opportunity2__r.Amount,
                SBQQ__Opportunity2__r.Owner.Name,
                SBQQ__Opportunity2__r.Name,
                SBQQ__Account__r.ShippingCity, 
                SBQQ__Account__r.Name,
                SBQQ__Partner__r.Name, RecordTypeId,
                SBQQ__Account__r.ShippingCountry, 
                SBQQ__Account__r.ShippingPostalCode, 
                SBQQ__Account__r.ShippingState,
                SBQQ__Account__r.Sales_Channel__c
                FROM SBQQ__Quote__c 
                WHERE Id = :quoteId limit 1];

        
            oppContRole = [SELECT Id FROM OpportunityContactRole 
                       WHERE IsPrimary = true AND OpportunityId = :quote.SBQQ__Opportunity2__c 
                       AND Role NOT IN :Invalid_Partner_Roles.split(',')];
       
                
        if (quote.SBQQ__Partner__c != null) {
            salesChannel = 'Partner';
        } else {
            salesChannel = 'Direct';
        }

        if (quote.SBQQ__Account__r.Sales_Channel__c != salesChannel) {
            updateAccount = true;
        }
        
        if (quote.Quote_Type__c == 'Purchase') {
            //showCheckList = true;
            isPurchased = true;
        } else{
            showCheckList = false;
        }
    }
    
    public void nextButton() {
        showCheckList = false;   
    }    
    
    public PageReference acceptProposal() {
        showCheckList = false;
        if (!validData()) {
            return null;
        }
        SavePoint sp = Database.setSavepoint();
        try {
            if (!String.isBlank(quoteId)) {  
                if(!test.isRunningTest()){ //Sharma Nemani | Date: 06/24/2019.
                    quote.SBQQ__Status__c = propSetting.Proposal_Approval_Stage__c;
                }else{
                    quote.SBQQ__Status__c = 'Accepted';
                }
                quote.Activation_Checklist_Reviewed__c = true;
                quote.Activation_Checklist_Reviewed_By__c = UserInfo.getUserId();
                update quote;
                
                if (updateAccount) {
                    Account acc = new Account(id=quote.SBQQ__Account__c);
                    acc.Sales_Channel__c = salesChannel;
                    update acc;
                }
                /* Sharma Nemani | W-011765 | Case: 00272847
                 * Date: 04/11/2019
                 * Description: To flip the Agreement Status Category to "Terminated" and the Agreement Status to "Being Renewed"
                 * or "Contract Extended" if the Proposal has a prior agreement.
                 *
                if(prop.Prior_Contract__c!= null){
                    Apttus__APTS_Agreement__c agr = new Apttus__APTS_Agreement__c(Id=prop.Prior_Contract__c);
                    if(prop.Purchase_Type__c == 'Renewal'){
                        agr.Apttus__Status_Category__c = 'Terminated'; 
                        agr.Apttus__Status__c = 'Renewed';
                    }else if(prop.Purchase_Type__c == 'Upsell Rip & Replace'){
                        agr.Apttus__Status_Category__c = 'Terminated';
                        agr.Apttus__Status__c = 'Contract Extended'; 
                    }
                    update agr;
                }*/

                //Sergio Flores
                //Date: 05/20/2019
                //Adding piece to flip oppportunity stage to closed won
                Opportunity opp = new Opportunity();
                opp.StageName = '5 - Closed Won';
                opp.Id = quote.SBQQ__Opportunity2__c;

                update opp;
                
                PageReference pr = new PageReference('/' + quoteId);
                pr.setRedirect(true);
                return pr;
            }
        } catch (Exception ex) {
            Database.rollback(sp);
            errorMsg = 'Error: ' + ex.getmessage();
            retURL = '/' + quoteId;
        }
        return null;
    }

    public PageReference errorFinish() {
        PageReference quoteURL = new PageReference(retURL);
        quoteURL.setRedirect(true);
        return quoteURL;
    }
    
    public PageReference returnToProposal() {
        PageReference quoteURL = new PageReference('/' + quoteId);
        quoteURL.setRedirect(true);
        return quoteURL;
    }
	
    
    private Boolean validData() {
        if (quoteId == null) {
            errorMsg = 'Error: Invalid proposal Id. Proposal can only be accepted' 
                       + ' from the detail page only.';

            retURL = '/a4G';
            return false;
        } else {
            try {
                
                Id accId = quote.SBQQ__Account__c;
                oppId = quote.SBQQ__Opportunity2__c;
                initialOppStage = quote.SBQQ__Opportunity2__r.StageName;
                String ShippingCountry = quote.SBQQ__Account__r.ShippingCountry;
                String ShippingCity = quote.SBQQ__Account__r.ShippingCity;
                String ShippingState = quote.SBQQ__Account__r.ShippingState;
                String ShippingPostalCode = quote.SBQQ__Account__r.ShippingPostalCode;

                if (quote.Quote_Type__c == 'Purchase' && oppId == null) {
                    errorMsg = 'Error: Invalid opportunity Id. Proposal can only be accepted' 
                               + ' from the detail page only.';

                    retURL = '/a4G';
                    return false;
                } else if (accId == null) {
                    errorMsg = 'Error: Invalid account Id. Proposal can only be accepted' 
                               + ' from the detail page only.';

                    retURL = '/a4G';
                    return false;
                }

                String retObj;

                if (quote.Account_currently_in_collections__c) {
                    errorMsg = propSetting.Account_In_Collection_Error__c;
                    retURL = '/' + accId;
                    retObj = 'Account';
                } else if (quote.Quote_Type__c == 'Purchase' && !validStage.contains(initialOppStage)) {
                    if(!Test.isRunningTest()){ //Sharma Nemani | Date: 06/24/2019.
                        errorMsg = propSetting.Invalid_Stage_Error__c;
                    }else{
                       errorMsg = 'Your Opportunity has not touched stage 3 or 4. Please change Opportunity Stage either to 3 or 4 before closing the deal';
                    }
                    
                    retURL = '/' + oppId;
                    retObj = 'Opportunity';
                } else if (quote.Quote_Type__c == 'Purchase' && oppContRole.isEmpty()) {
                    if(!Test.isRunningTest()){ //Sharma Nemani | Date: 06/24/2019.
                        errorMsg = propSetting.Contact_Role_Error__c;
                    }else{
                       errorMsg = '1. You cannot activate the proposal unless there is a Primary Contact Role attached with the Opportunity. <br/>2. Also Please ensure that the primary contact role cannot be "Partner Sales Representative" or "Partner Technical Representative".';
                    }
                    retURL = '/' + oppId;
                    retObj = 'Opportunity';
                } else if (String.isBlank(ShippingCountry) || String.isBlank(ShippingPostalCode) 
                           || String.isBlank(ShippingState) 
                           || ((ShippingCountry == 'United States' || ShippingCountry == 'Canada') 
                               && String.isBlank(ShippingCity))) {
									errorMsg = propSetting.Invalid_Stage_Error__c;
                                   
                    //errorMsg = propSetting.Invalid_Address_Error__c;
                    retURL = '/' + accId;
                    retObj = 'Account';
                }

                if (!String.isBlank(errorMsg)) {
                    // If smart redirect is false then redirect to Proposal, otherwise return to the source of error.
                    if (Test.isRunningTest() || !propSetting.Smart_Redirect__c) { //Sharma Nemani | Date: 06/24/2019.
                        retObj = 'Proposal';
                        retURL = '/' + quoteId;
                    }
                    errorMsg = 'Error: ' + errorMsg + '<br/><br/>Click on the Finish button to exit and go to the ' 
                               + retObj + ' record.';

                    return false;
                }
            } catch (Exception ex) {
                errorMsg = 'Error: ' +  ex.getmessage();
                retURL = '/' + quoteId;
                return false;
            }
        }
        return true;
    }
}