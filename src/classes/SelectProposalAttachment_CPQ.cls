public with sharing class SelectProposalAttachment_CPQ {
    public Boolean inCollection {get;set;}
    public List<selectedAttachment> attachments {get;set;}
    public string proposalId;
    public SBQQ__Quote__c proposal;
    public string id;
    public boolean showtext {get;set;}
    public boolean isChecked {get;set;}

    // Wrapper Class
    public class selectedAttachment {
        public Attachment attachment {get;set;}
        public Boolean selected {get; set;}
        
        
        public selectedAttachment (Attachment a) {
            attachment = a;
            selected = false;
        }
    }

    public SelectProposalAttachment_CPQ(ApexPages.StandardController stdController) {
        inCollection = false;
        proposalId =  ApexPages.currentPage().getParameters().get('id');//eddie add
        system.debug('Proposal Id is' + proposalId );
        attachments  = new List<selectedAttachment>();
        proposal = [select Id,name , SBQQ__Account__c,SBQQ__Account__r.Name,
                    SBQQ__Opportunity2__c, Owner.Email, Account_currently_in_collections__c, 
                   /*Activation_Checklist_Reviewed__c,*/ Order_Form_Checklist_Reviewed__c // 'Order_Form_Checklist_Reviewed__c' - Added By: Sharma Nemani | W-012706 | Case: 00288482 | Date: 07/24/2019
                    FROM SBQQ__Quote__c
                    WHERE Id =: proposalId limit 1 ];
                    
        if(proposal!= null && proposal.Account_currently_in_collections__c == true){
            inCollection = true;
        }
        id = '';
        showtext = true;
         
        //isChecked = proposal.Activation_Checklist_Reviewed__c; // Commented by: Sharma Nemani | W-012804 | Date: 08/07/2019
        isChecked = proposal.Order_Form_Checklist_Reviewed__c; // Added By: Sharma Nemani | W-012706 | Case: 00288482 | Date: 07/24/2019
    }
    
    public SelectProposalAttachment_CPQ() {
    }
    
    public pageReference nextbutton(){
        showtext = false;
        return null;
    }

    //Eddie Wong
    //04-22-2020
    //W-005164
    //To insert checklist page when order form button is clicked
    public pageReference doSkipToCongaComposer(){
        If (isChecked) {
            proposal.Order_Form_Checklist_Reviewed__c = true;
            proposal.Order_Form_Checklist_Reviewed_By__c = UserInfo.getUserId();
            try {
                update proposal;
            } catch (Exception e) {
                ApexPages.addMessages(e);
            }
        }
        return null;
    }
    
    public pageReference prevbutton(){
        showtext = true;
        return null;
    }
    
    public pageReference getAttachments () {
        
        List<Attachment> attchmentList = [SELECT Id,ParentId, Name,  OwnerId, CreatedDate, Description , IsPrivate 
                                          FROM Attachment 
                                          WHERE ParentId =: proposalId ORDER BY createddate desc];

        system.debug('List of attachments in abc' + attchmentList );                   
            for(Attachment attchment : attchmentList ) {
                           
               attachments.add(new selectedAttachment(attchment));            
            }
         
        system.debug('List of attachments' + attachments );
        return null;              
    }

    public pageReference doSelect () {
        for(selectedAttachment sa : attachments) {
            if(sa.selected == true) {
                 id = sa.attachment.Id;
                 break;
            }
        }
        if (id !=  null) {
            Echosign_dev1__SIGN_Agreement__c agr = new echosign_dev1__SIGN_Agreement__c();
            string Ename= 'Alteryx Quote '+ proposal.Name +' for '+proposal.SBQQ__Account__r.Name;
            String emailTo = Proposal.Owner.Email;
            
            if(Ename.length()>79){
            agr.Name = Ename.Substring(0,79);
            }
            else{
                agr.Name =Ename;
                
            }
           
            agr.echosign_dev1__AgreementLocale__c = 'English (United States)';
            agr.echosign_dev1__SignatureType__c = 'e-Signature';
            agr.echosign_dev1__Attachment_ID_Order__c = id;
            agr.echosign_dev1__Account__c = proposal.SBQQ__Account__c;
            agr.echosign_dev1__Opportunity__c = proposal.SBQQ__Opportunity2__c;
            agr.echosign_dev1__Authoring__c = true;
            agr.echosign_dev1__Enable_Automatic_Reminders__c = true;
            agr.echosign_dev1__RemindRecipient__c = 'Every Day, Until Signed';
            agr.echosign_dev1__Message__c = 'Hello, ' + '\n \n' + 'On behalf of everyone at Alteryx, thank you for your order. Attached, please find your order form for signature. Prior to signing please review the following are correct and comply with your internal policy and let us know if any corrections are needed:' + '\n\n'  + '&#9679; Payment Terms, Pricing and Currency'+ '\n' + '&#9679; Company Name' + '\n' + '&#9679; Ship to and billing Addresses' + '\n' + '&#9679; Contact Information' + '\n\n' + 'Also, if you are not authorized under your Company’s Signature Authority Policy to sign for this purchase please forward to appropriate signer or contact us.' + '\n\n' + 'We are committed to providing you with the highest level of customer satisfaction possible. If for any reason you have questions or comments, we are delighted to hear from you. Again, thank you for your patronage. We look forward to serving you.' + '\n\n' + 'Sincerely, ' + '\n\n' + 'Chris Gilbert' + '\n' + 'Director, Deal Desk';
            agr.echosign_dev1__Cc__c = emailTo;
            agr.CPQ_Quote__c = proposalId;
            try{
                insert agr;
            }catch(Exception e){ApexPages.addMessages(e); return null;}
            
            Attachment selAttachment = [select ParentId, Name ,Description, IsPrivate,Body from Attachment where Id =: id limit 1];
            
            if(agr.Id != null || agr.Id != '') {        
                Attachment atc = new Attachment();
                atc.ParentId = agr.Id;
                atc.Name = selAttachment.Name;
                atc.Body = selAttachment.Body;
                atc.Description = selAttachment.Description;
                atc.IsPrivate = selAttachment.IsPrivate;
                try{
                insert atc;
                }catch(Exception e){ApexPages.addMessages(e); return null;}
                system.debug('Parent ID>>>>>>>>>' + selAttachment.ParentId);   
            }
            try{
                update agr;
            }catch(Exception e){ApexPages.addMessages(e); return null;}

            if (isChecked) {
                //proposal.Activation_Checklist_Reviewed__c = true; // Commented by: Sharma Nemani | W-012804 | Date: 08/07/2019
                proposal.Order_Form_Checklist_Reviewed__c = true; // Added By: Sharma Nemani | W-012706 | Case: 00288482 | Date: 07/24/2019
                //proposal.Activation_Checklist_Reviewed_By__c = UserInfo.getUserId(); // Commented by: Sharma Nemani | W-012804 | Date: 08/07/2019
                proposal.Order_Form_Checklist_Reviewed_By__c = UserInfo.getUserId(); // Added By: Sharma Nemani | W-012706 | Case: 00288482 | Date: 07/24/2019
                try{
                    update proposal;
                } catch (Exception e) {
                    ApexPages.addMessages(e); 
                    return null;
                }
            }
            
            //PageReference pageRef = new PageReference('/apex/echosign_dev1__EchoSignAgreementAdvanced?id=' + agr.Id); // Commented by: Sharma Nemani | W-013718 | Case: 00315507 | Date: 12/09/2019
            PageReference pageRef = new PageReference('/apex/echosign_dev1__AgreementEditor?id=' + agr.Id); // Added By: Sharma Nemani | W-013718 | Case: 00315507 | Date: 12/09/2019
            return pageRef; 
        }
        else 
            return null;
    }
    
    public pageReference doCancel () {
        PageReference pageRef = new PageReference('/' + proposalId);
        return pageRef;
    }
}