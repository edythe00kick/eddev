/*
 * Name: Sharma Nemani | W-011054 | Case: 00260518
 * Description: This controller is used on the Javascript button "Clone ECUR To NBEC" which would clone the ECUR to NBEC and
   update the fields.
 * Date: 03/11/2019
*/
global class ClsCloneECURtoNBEC {    
    //Method to Clone ECUR to NBEC Opportunity
    webService static String cloneECURtoNBEC(Id oppId){
        String outputMSG = '';
        List<Custom_Partner__c> partnertobeCloned = new List<Custom_Partner__c>();
        List<Apttus_Proposal__Proposal__c> proposals = [Select Apttus_Proposal__Opportunity__c, Apttus_Proposal__Primary__c,
                                                       Terms_InYears__c, Terms_InMonths_DD__c From Apttus_Proposal__Proposal__c
                                                       Where Apttus_Proposal__Primary__c = True AND Apttus_Proposal__Opportunity__c =: oppId]; //Querying the Primary Proposal from the Opportunity.
        String oppQuery = 'Select id,Account.OwnerId, '+getUpdatedFields('Opportunity')+' from Opportunity Where Id =: oppId';
        Opportunity opptoClone = Database.query(oppQuery); //Query the Parent Opportunity
        if(opptoClone.Type == 'ECUR'){ //Clone to be performed only if the Type is ECUR.
            Opportunity tobecloned = opptoClone.clone(false,true); //Cloning the Parent Opportunity
            tobecloned.Name = opptoClone.Name + ' (NBEC Portion)';
            tobecloned.Parent_Opportunity__c = opptoClone.Id; //Assigning Parent Opportunity ID with the Parent Opportunity
            tobecloned.Original_Close_Date__c = null;
            tobecloned.Type = 'NBEC';
            tobecloned.Original_Amount__c = null;
            tobecloned.Original_Plan_Amount__c = null;
            tobecloned.Total_Contract_Value_Amount__c = 0;//Opportunity Handler Trigger, Line 55 is updating the value in its before insert trigger. 
            tobecloned.Original_Total_Contract_Value_Amount__c = null;
            tobecloned.OwnerId = opptoClone.Account.OwnerId;
            tobecloned.Original_Term_Length_in_Months__c = null;
            tobecloned.Original_Term_Length_in_Years__c = null;
            tobecloned.SAO_Date__c = null; //Chris Salgado Date: 4/3/19 W-010937
            tobecloned.SQO_Date__c = null; //Chris Salgado Date: 4/17/19 W-010937
            if(proposals.size()>0){
            	tobecloned.Related_Contract_Terms_In_Years__c = proposals[0].Terms_InYears__c; //Cloning Terms in Years from Primary Proposal to Opportunity's Related Contract Terms in Years field.
            	tobecloned.Related_Contract_Terms_In_Months__c = proposals[0].Terms_InMonths_DD__c; //Cloning Terms in Months(DD) from Primary Proposal to Opportunity's Related Contract Terms in Months field.
            }
            try{
                insert tobecloned;
                String partnerQuery = 'select id, '+getUpdatedFields('Custom_Partner__c')+' from Custom_Partner__c where OpportunityId__c =: oppId'; //Query string for fetching the Parent Opportunity's Partner.
                List<Custom_Partner__c> partners = Database.query(partnerQuery);
                if(partners.size()>0){
                    for(Custom_Partner__c partner : partners){
                        Custom_Partner__c clonedPartner = partner.clone(false,true);
                        clonedPartner.OpportunityId__c = tobecloned.id;
                        partnertobeCloned.add(clonedPartner);
                    }
                }
                
                if(partnertobeCloned.size()>0)
                    insert partnertobeCloned;
                
                outputMSG =  tobecloned.Id;
                insertOpportunityPartner(oppId, opptoClone.AccountId, tobecloned.Id);
            }catch(Exception ex){
                outputMSG =  'Exception';
            }
        }else{
            outputMSG = 'NotInType';
        }
        return outputMSG;
    }
    //Method to create the dynamic query of the objects.
    public Static string getUpdatedFields(String obj){
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap();
        List<String> editableFields = new List<String>();
        for(Schema.SObjectField fieldRef : fields.values()) {
            Schema.DescribeFieldResult fieldResult = fieldRef.getDescribe();
            if(fieldResult.isUpdateable() && fieldResult.isAccessible()) {
                editableFields.add(fieldResult.getname());
            }
        }
        return string.join(editableFields,',');
    }
    //Future method to create Standard Opportunity Partners for the cloned Opportunity.
    @future
    public static void insertOpportunityPartner(Id oppId, Id OppAccId, Id tobecloned){
        List<Partner> standardPartnertobeCloned = new List<Partner>();
        List<Partner> standardPartners = [select id, Role, OpportunityId, IsPrimary, AccountToId from Partner where OpportunityId =: oppId];
        if(standardPartners.size()>0){
            for(Partner part : standardPartners){
                if (part.AccountToId != OppAccId) {
                    Partner clonedStandardPartner = part.clone(false,true);
                    clonedStandardPartner.OpportunityId = tobecloned;
                    standardPartnertobeCloned.add(clonedStandardPartner);
                }
            }
        }
        if(standardPartnertobeCloned.size()>0)
                    insert standardPartnertobeCloned;
    }
}