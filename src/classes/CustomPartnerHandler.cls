public without sharing class CustomPartnerHandler {
 
    public map<id,id> oppIdToPartnerAccountIdMap = new map<id,id>();
    public set<Id> opportunityIdsToDeleteSharing = new set<Id>();
    public set<Id> oppIdsDistributorCheck = new set<Id>(); // W-007052 : JPH : 20180131 : List of Opps to Mark as Distributor Deals
    public set<Id> oppIdsDistributorUnCheck = new set<Id>(); // W-007052 : JPH : 20180131 : List of Opps to unMark as Distributor Deals
    public list<OpportunityShare> oppSharesListToBeDeleted = new list<OpportunityShare>();
    public Map<Id, Id> oppIdToPartnerIdMap = new Map<Id, Id>();
    public Map<Id, Id> oppIdToParIdDelMap = new Map<Id, Id>();
    public List<Id> parIdsToDelete = new List<Id>();
    public List<Partner> parsToDelete = new List<Partner>();
    public List<Partner> parsToInsert = new List<Partner>();
    public List<Custom_Partner__c> partToUpdate = new List<Custom_Partner__c>();
    public Map<String, Id> uniqueIdToCparIdMap = new Map<String, Id>();
    public Map<Id, Id> oppIdToParAccIdMap = new Map<Id, Id>();
    public Map<Id, Id> oppIdToAccIdMap = new Map<Id, Id>();
    public Map<Id, Id> oppIdToAccIdMapDelete = new Map<Id, Id>(); //Sergio FLores Adding for testing
    public Map<Id, Id> oppIdsToAccIdsMap = new Map<Id, Id>();
    public List<OpportunitySplit> oppSplitToDelete = new List<OpportunitySplit>();
    public List<OpportunityTeamMember> oppTeamMemberToDelete = new List<OpportunityTeamMember>(); //Sergio Flores 05/17/2019
    public List<OpportunitySplit> oppSplitToInsert = new List<OpportunitySplit>();
    public List<OpportunitySplit> oppSplitToInsertOnUpdate = new List<OpportunitySplit>(); //refactored Sergio Flores
    String distributor = System.Label.distributor;//Added by Sergio Flores
    String referrer = System.Label.Referrer;//2019-02-13 to account for distributor and referrer values
    public Set<Id> customPartnerIds = new Set<Id>(); //Grazz Parnter 6-11-2019
    public Set<Id> oppIds = new Set<Id>(); //Grazz Parnter 6-11-2019    

    /*CPQ Refactor SF 03/25/2019 PartnerUpdate*/
    public List<SBQQ__Quote__c> propToUpdate 
        = new List<SBQQ__Quote__c>();

    public CustomPartnerHandler() {

    }
	
    // // SF Refactor W-004528 02/26/2020
  public static void updateOppSplitTeamMember(Map<Id, Custom_Partner__c> newRecords){
        system.debug('inside update opp split team member ' + newRecords);

        Set<Id> opportunityIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();

        for(Custom_Partner__c par : newRecords.values())
        {
            opportunityIds.add(par.OpportunityId__c);
            accountIds.add(par.AccountToId__c);
        }

        Map<Id,Account> accountIdToAccountMap = new Map<Id, Account>([select id,Business_Development_Owner__c, Partner_Type__c   from Account where Id IN :accountIds]);
      	Map<Id, OpportunitySplit> oppSplitExistingMap = new Map<Id, OpportunitySplit>([select id from OpportunitySplit where SplitTypeId =:Label.OverlayOpportunitySplitId AND OpportunityId IN : opportunityIds]);

        for(Custom_Partner__c par : newRecords.values())
        {
            Account acc = accountIdToAccountMap.get(par.AccountToId__c);
            OpportunitySplit oppS = oppSplitExistingMap.get(par.OpportunityId__c);

            // Eddie Wong
            // 04/28/2020
            // W-005192
            // To stop overlay split from being created when customer partner role is 'Fulfillment Resale'
            if(oppS ==null && acc != null && acc.Partner_Type__c != 'DMR' && par.Role__c != 'Fulfillment Resale')
            {
                OpportunityTeamMember otm = new OpportunityTeammember();
                otm.OpportunityId= par.OpportunityId__c;
                otm.TeamMemberRole='Business Development Representative';
                //Name: Chris Salgado Date: 9/23/2019 Purpose: W-013092
                if(!Test.isRunningTest())
                {
                    if(acc.Business_Development_Owner__c == null)
                    {                
                        par.addError('This Partner cannot be added because the Partner Account Record does not have a Business Development Rep identified. Please have SalesOps update this field and then try again.');                	                    
                    }
                }

                if(Test.isRunningTest())
                otm.userId = [SELECT Id FROM User WHERE Profile.Name = 'Alteryx - Sales - Business Development' AND isactive = true limit 1].Id;
                else
                otm.userId = acc.Business_Development_Owner__c ;
                insert otm;
                
                OpportunitySplit oppSplit = new OpportunitySplit();
                oppSplit.OpportunityId = par.OpportunityId__c;
                if(Test.isRunningTest())
                oppSplit.SplitOwnerId = [SELECT Id FROM User WHERE Profile.Name = 'Alteryx - Sales - Business Development' AND isactive = true limit 1].Id;
                else
                oppSplit.SplitOwnerId = acc.Business_Development_Owner__c ;
                oppSplit.SplitTypeId = Label.OverlayOpportunitySplitId;
                oppSplit.SplitPercentage = 100;
                insert oppSplit;
            }
        }
      	
        
    } 
   // Sharma Nemani | W-011380 | Case: 00266466 --> END
    
    public void onAfterInsert(List<Custom_Partner__c> newRecords)
    {
        
        Map<Id, Id> oppIdsToAccIdsInsertSplitsMap = new Map<Id, Id>();
        Map<Id, Custom_Partner__c> wiOppToPartnerMap = new Map<Id, Custom_Partner__c>();
        Set<Id> wiPartnerAccounts = new Set<Id>();
        Map<Id, Custom_Partner__c> customPartnerIdToCustomPartnerMap = new Map<Id, Custom_Partner__c>();

        system.debug('inside after insert class');
        for (Custom_Partner__c par : newRecords) { 

                system.debug('partner rol = ' + par.Role__c);
                system.debug('distributor custom handler ' + distributor);
                
                //If partner inserted is Var or distributor, then update 
                //the related quote by stamping to the partner
                if (par.Role__c == 'Value Added Reseller' 
                    || distributor.contains(par.Role__c)) {
                        system.debug('inside after insert value added reseller');
                    oppIdToPartnerIdMap.put(par.OpportunityId__c, par.AccountToId__c);
                }

                //These will create opp sharing rules to the opportunity
                if ((par.AccountToId__c != null && par.OpportunityId__c != null) 
                   && par.IsPrimary__c == true) 
                {
                   
                    oppIdToPartnerAccountIdMap.put(par.OpportunityId__c,par.AccountToId__c);
                    opportunityIdsToDeleteSharing.add(par.OpportunityId__c);
                }

                //W-007052 : JPH : 20180131 : Check if a Distributor has been added as a Partner Role
                //W-011028 : SF: 20190129 : Need to add custom label to handle multiple roles that
                //are considered distributors

                if( distributor.contains(par.Role__c))
                {
                    oppIdsDistributorCheck.add(par.OpportunityId__c);
                }

                if(par.AccountToId__c!= null && par.OpportunityId__c!= null){
                    Partner newPar = new Partner();
                    newPar.OpportunityId = par.OpportunityId__c;
                    newPar.AccountToId = par.AccountToId__c;
                    newPar.Role = par.Role__c;
                    newPar.IsPrimary = par.IsPrimary__c;
                    parsToInsert.add(newPar);

                    uniqueIdToCparIdMap.put('' + par.OpportunityId__c + par.AccountToId__c, par.Id); 
                }

                //here we insert opportunity splits if the partner added
                //is now a referrer or VAR
                if (par.Role__c == 'Value Added Reseller'|| referrer.contains(par.Role__c) ) 
                {
                    system.debug('inside var or referrer partner inserted');
                    oppIdsToAccIdsInsertSplitsMap.put(par.OpportunityId__c, par.AccountToId__c);

                    //Name: Chris Salgado
                    //Date: 8/21/2019
                    //W-012809
                    if(par.OpportunityId__c != null && par.AccountToId__c != null){
                        wiOppToPartnerMap.put(par.OpportunityId__c, par);
                        wiPartnerAccounts.add(par.AccountToId__c); //Name: Chris Salgado Date: 9/13/2019 Purpose: W-013076
                    }
                }

                if(par.IsPrimary__c)
                customPartnerIdToCustomPartnerMap.put(par.Id, par);

                //Grazz Parnter 6-11-2019
                customPartnerIds.add(par.Id);
                oppIds.add(par.OpportunityId__c);

                
            }
        /*CPQ Refactor SF 03/25/2019 PartnerUpdate*/

        //this is where we stamp the quote with a partner on insert
        /*if (!oppIdToPartnerIdMap.isEmpty()) {
            propToUpdate = CustomPartnerGateway.updateProposals(oppIdToPartnerIdMap, 'insert');
        }*/

         if(!wiOppToPartnerMap.isEmpty() && !wiPartnerAccounts.isEmpty()){
            CustomPartnerGateway.wiOppPartnerUpdate(wiOppToPartnerMap, wiPartnerAccounts,  true);
        }

        if (!oppIdsToAccIdsInsertSplitsMap.isEmpty()) {
            system.debug('inside inserting opp splits ' + oppIdsToAccIdsInsertSplitsMap);
            oppSplitToInsert = CustomPartnerGateway.insertOppSplit(oppIdsToAccIdsInsertSplitsMap);
            system.debug('inside inserting opp splits ' + oppSplitToInsert);
        }

        if(!customPartnerIdToCustomPartnerMap.isEmpty()){
            updateOppSplitTeamMember(customPartnerIdToCustomPartnerMap);  // SF Refactor W-004528 02/26/2020
        }   

    }
	
    public void onAfterUpdate(List<Custom_Partner__c> newRecords)
    {
        parIdsToDelete = new List<Id>();
        //parsToDelete = new List<Partner>();
        parsToInsert = new List<Partner>();
        partToUpdate = new List<Custom_Partner__c>();
        uniqueIdToCparIdMap = new Map<String, Id>();
        oppIdToParAccIdMap = new Map<Id, Id>();
        oppIdToAccIdMap = new Map<Id, Id>();
        oppIdsToAccIdsMap = new Map<Id, Id>();
        oppSplitToDelete = new List<OpportunitySplit>();
        oppSplitToInsertOnUpdate = new List<OpportunitySplit>();
        Map<Id, Custom_Partner__c> customPartnerIdToCustomPartnerMap = new Map<Id, Custom_Partner__c>();

        

        for (Custom_Partner__c par : newRecords) { 

                system.debug('partner rol = ' + par.Role__c);
                system.debug('distributor custom handler ' + distributor);

                Custom_Partner__c oldPar = (Custom_Partner__c)Trigger.oldMap.get(par.Id);
                
                //If partner inserted is Var or distributor, then update 
                //the related quote by stamping to the partner
                if (par.Role__c == 'Value Added Reseller' 
                    || distributor.contains(par.Role__c)) {

                    oppIdToPartnerIdMap.put(par.OpportunityId__c, par.AccountToId__c);
                } 

                //Here is where we create a Standard partner and stamp a uniqueid
                //on the standard partner as well as the custom partner for relationship purpose
                //that way we can delete or update the Custom Partner and its corresponding
                //standard partner
                if (par != oldPar && par.OpportunityId__c != null 
                    && par.AccountToId__c != null 
                    && par.Partner_Id__c == oldPar.Partner_Id__c) {
                    parIdsToDelete.add(par.Partner_Id__c);

                    Partner newPar = new Partner();
                    newPar.OpportunityId = par.OpportunityId__c;
                    newPar.AccountToId = par.AccountToId__c;
                    newPar.Role = par.Role__c;
                    newPar.IsPrimary = par.IsPrimary__c;
                    parsToInsert.add(newPar);
                    uniqueIdToCparIdMap.put('' + par.OpportunityId__c + par.AccountToId__c, par.Id);
                }
                // Added by Hemendra Singh Rajawat on June 07, 2018

                //If the partner is updated and it is not a VAR or distributor
                //then remove the partner from the quote
                if (par.Role__c != oldPar.Role__c 
                    && par.Role__c != 'Value Added Reseller' 
                    && !distributor.contains(par.Role__c)) {
                    oppIdToParAccIdMap.put(par.OpportunityId__c, par.AccountToId__c);
                }

                //If the partner is updated and it is not a VAR or referrer
                //then we must remove the opportunity split
                if (par.Role__c != oldPar.Role__c && !referrer.contains(par.Role__c)
                    && par.Role__c != 'Value Added Reseller'
                    && (oldPar.Role__c == 'Value Added Reseller' 
                        || referrer.contains(oldPar.Role__c))) {
                    oppIdToAccIdMap.put(par.OpportunityId__c, par.AccountToId__c);
                }

                //here we insert opportunity splits if the partner added
                //is now a referrer or VAR
                if (par.Role__c != oldPar.Role__c 
                    && oldPar.Role__c != 'Value Added Reseller'
                    && referrer.contains(oldPar.Role__c)
                    && (par.Role__c == 'Value Added Reseller' 
                        || referrer.contains(par.Role__c))) {
                    oppIdsToAccIdsMap.put(par.OpportunityId__c, par.AccountToId__c);
                }

                //Here if the partner is primary and both the account and opportunity change
                //then we have to update the sharing rules and delete old sharing rules
                if(par.AccountToId__c != oldPar.AccountToId__c && par.OpportunityId__c != oldPar.OpportunityId__c){
                    if((par.AccountToId__c != null && par.OpportunityId__c != null) && par.IsPrimary__c == true){
                        oppIdToPartnerAccountIdMap.put(par.OpportunityId__c,par.AccountToId__c);
                        opportunityIdsToDeleteSharing.add(oldPar.OpportunityId__c);
                    }
                }
                // W-007052 : JPH : 20180131 : Check if a Partner has been changed to a Distributor
                //W-011028 : SF: 20190129 : Need to add custom label to handle multiple roles that
                //are considered distributors
                if( distributor.contains(par.Role__c) && oldPar.Role__c != par.Role__c ){
                    oppIdsDistributorCheck.add(par.OpportunityId__c);
                }

                if(par.IsPrimary__c && !par.IsPrimary__c)
                customPartnerIdToCustomPartnerMap.put(par.Id, par);
                
            }
        /*CPQ Refactor SF 03/25/2019 PartnerUpdate*/

        /*if (!oppIdToPartnerIdMap.isEmpty()) {
            propToUpdate = CustomPartnerGateway.updateProposals(oppIdToPartnerIdMap, 'insert');
        }
        if (!oppIdToParAccIdMap.isEmpty()) {
            propToUpdate = CustomPartnerGateway.updateProposals(oppIdToParAccIdMap, 'update');
        }*/

        if (!parIdsToDelete.isEmpty()) {
            parsToDelete = CustomPartnerGateway.deletePartners(parIdsToDelete);
        }

        if (!oppIdToAccIdMap.isEmpty()) {
            oppSplitToDelete = CustomPartnerGateway.deleteOppSplit(oppIdToAccIdMap);
        }

        if (!oppIdsToAccIdsMap.isEmpty()) {
            oppSplitToInsertOnUpdate = CustomPartnerGateway.insertOppSplit(oppIdsToAccIdsMap);
        }
        
        if(!customPartnerIdToCustomPartnerMap.isEmpty()){
            updateOppSplitTeamMember(customPartnerIdToCustomPartnerMap);  // SF Refactor W-004528 02/26/2020
        }  
        
    }
    /* Added by: Sharma Nemani | W-011380 | Case: 00266466 --> START
     * Description: To delete Opportunity Split when a Custom Partner is deleted from the Opportunity.
     * Date: 07/29/2018
     */
    public static void deleteOppSplitTeamMember(List<Custom_Partner__c> newRecords){
        Custom_Partner__c cp = newRecords[0];

        // Eddie Wong
        // 04/28/2020
        // W-005192
        // Overlay Split will not be deleted when a custom partner with role 'Fulfillment Resale' is deleted
        if(cp.Role__c != 'Fulfillment Resale'){
            List<OpportunitySplit> opS = [select id,SplitOwnerId from OpportunitySplit where OpportunityId=:cp.OpportunityId__c AND SplitTypeId=:Label.OverlayOpportunitySplitId];
            if(opS.size() > 0){
                List<OpportunityTeamMember> lstOTm = [select id from OpportunityTeamMember where OpportunityId=:cp.OpportunityId__c AND userId=:opS[0].SplitOwnerId];
                delete opS;
                delete lstOTm;
                System.debug('eddie inside onafterdelete6');
            }
        }
    }
    // Sharma Nemani | W-011380 | Date: 07/29/2018 --> END
    
    public void onAfterDelete(List<Custom_Partner__c> oldRecords)
    {
        Map<Id, Custom_Partner__c> wiOppToPartnerMap = new Map<Id, Custom_Partner__c>();
        Set<Id> wiPartnerAccounts = new Set<Id>(); //Always empty for Delete


        for (Custom_Partner__c oldpar : oldRecords) {
            System.debug('eddie inside onafterdelete'+ oldpar.Role__c);

                if (oldpar.Role__c == 'Value Added Reseller' 
                    || distributor.contains(oldpar.Role__c)) {

                   oppIdToParIdDelMap.put(oldpar.OpportunityId__c, oldpar.AccountToId__c);
                    System.debug('eddie inside onafterdelete2'+ oldpar.Role__c);
                }

                // Added by Hemendra Singh Rajawat on June 07, 2018
                if (oldpar.Role__c == 'Value Added Reseller'
                    || referrer.contains(oldpar.Role__c)) {

                    oppIdToAccIdMapDelete.put(oldpar.OpportunityId__c, oldpar.AccountToId__c);
                    System.debug('eddie inside onafterdelete3'+ oldpar.Role__c);

                    //Name: Chris Salgado
                    //Date: 8/21/2019
                    //W-012809
                    //Name: Chris Salgado Date: 9/13/2019 Purpose: W-013076
                    if(oldpar.OpportunityId__c != null && oldpar.AccountToId__c != null){
                        wiOppToPartnerMap.put(oldpar.OpportunityId__c, oldpar);
                    }
                }

                if((oldpar.AccountToId__c != null && oldpar.OpportunityId__c != null) && oldpar.IsPrimary__c == true){
                     opportunityIdsToDeleteSharing.add(oldpar.OpportunityId__c);
                 }
                 // W-007052 : JPH : 20180131 : Check if the deleted Partner was a distributor 
                 //W-011028 : SF: 20190129 : Need to add custom label to handle multiple roles that
                 //are considered distributors

                 if( distributor.contains(oldpar.Role__c)){
                     oppIdsDistributorUnCheck.add(oldpar.OpportunityId__c);
                 }

                //Grazz Parnter 6-11-2019
                oppIds.add(oldpar.OpportunityId__c);
                parIdsToDelete.add(oldpar.Partner_Id__c);
        }
        /*CPQ Refactor SF 03/25/2019 PartnerUpdate*/
         /*if (!oppIdToParIdDelMap.isEmpty()) {
            propToUpdate = CustomPartnerGateway.updateProposals(oppIdToParIdDelMap, 'delete');
        }*/

        if(!wiOppToPartnerMap.isEmpty()){
            CustomPartnerGateway.wiOppPartnerUpdate(wiOppToPartnerMap, wiPartnerAccounts, false);
        }
        
        if (!parIdsToDelete.isEmpty()) {
            parsToDelete = CustomPartnerGateway.deletePartners(parIdsToDelete);
        }

        if (!oppIdToAccIdMapDelete.isEmpty()) {
            oppSplitToDelete = CustomPartnerGateway.deleteOppSplit(oppIdToAccIdMapDelete);
            oppTeamMemberToDelete = CustomPartnerGateway.deleteOppTeamMember(oppIdToAccIdMapDelete);
            System.debug('eddie inside onafterdelete4'+ oppSplitToDelete);
            
            system.debug('oppSplitToDelete ' + oppSplitToDelete);
            system.debug('oppTeamMemberToDelete ' + oppTeamMemberToDelete);
        }
        deleteOppSplitTeamMember(oldRecords);
        System.debug('eddie inside onafterdelete5');
    }
  
    public void andFinally(){
      // W-007052 : JPH : 20180131 : Handle the case where the Opp's DistDeal Checkbox is set to FALSE
        if(oppIdsDistributorUnCheck.size() >0){
            //W-011136 : SF : 20190211 : Update hardcoded partner roles of software distributor to include all distributor values
            String distributor = System.Label.distributor;

            Set<String> distributorValues = new Set<String>();
            for(String d : distributor.split(','))
            {
                distributorValues.add(d);
            }

            list<Custom_Partner__c> removeFromOppList = new list<Custom_Partner__c>([SELECT Id, Role__c, OpportunityId__c FROM Custom_Partner__c WHERE OpportunityId__c IN :oppIdsDistributorUnCheck AND Role__c IN : distributorValues]);
            if( !removeFromOppList.IsEmpty() ){
                system.debug('Inside updated partner delete role');
                Integer i = 0;
                while ( i < removeFromOppList.size() ){
                if( oppIdsDistributorUnCheck.contains(removeFromOppList.get(i).OpportunityId__c) ){
                    oppIdsDistributorUnCheck.remove(removeFromOppList.get(i).OpportunityId__c);
                }else{}
                i++;
              }
            }
            //Send oppIdsDistributorUnCheck to an uncheck method
            system.debug('Send oppIdsDistributorUnCheck to get Unchecked');
            CustomPartnerGateway.uncheckDistCheckbox(oppIdsDistributorUnCheck);
        }
      
      // W-007052 : JPH : 20180131 : Handle the case where the Opp's DistDeal Checkbox is set to TRUE 
        if(oppIdsDistributorCheck.size() >0){
            //Send oppIdsDistributorCheck to a check the box method
            system.debug('Send oppIdsDistributorCheck to get checked');
            CustomPartnerGateway.checkDistCheckbox(oppIdsDistributorCheck);
        }
      
        if(opportunityIdsToDeleteSharing.size() >0){
            oppSharesListToBeDeleted = CustomPartnerGateway.deleteOpportunitySharingRules(opportunityIdsToDeleteSharing);
            if(oppSharesListToBeDeleted.size() > 0){
                Database.delete(oppSharesListToBeDeleted);
            }
        }

        if(oppIdToPartnerAccountIdMap.size() > 0){
            CustomPartnerGateway.createOpportunitySharingRules(oppIdToPartnerAccountIdMap); 
        }

        try {
            /*CPQ Refactor SF 03/25/2019 PartnerUpdate*/
            if (!propToUpdate.isEmpty()) {
                //update propToUpdate;
            }

            if (!parsToDelete.isEmpty()) {
                delete parsToDelete;
            }

            if (!parsToInsert.isEmpty()) {
                insert parsToInsert;

                if(!uniqueIdToCparIdMap.isEmpty()){
                    partToUpdate = CustomPartnerGateway.updatePartners(parsToInsert, uniqueIdToCparIdMap);

                    if(!partToUpdate.isEmpty())
                        update partToUpdate;
                }
            }

            if (!oppSplitToDelete.isEmpty()) {
                delete oppSplitToDelete;
            }
            /*if (!customPartnerIds.isEmpty()) {
                CustomPartnerGateway.updateOpportunityField(customPartnerIds);
      }*/
            //Grazz Parnter 6-11-2019
            if(!oppIds.isEmpty()){
                CustomPartnerGateway.updateRelatedOpportunity(oppIds);
            }

            //Sergio Flores
            //Date: 05/17/2019
            //Remove opp team members when partner is changed
            if(!oppTeamMemberToDelete.isEmpty())
            {
                delete oppTeamMemberToDelete;
            }

            if (!oppSplitToInsert.isEmpty()) {
                // Added By: Sharma Nemani | W-012584 & W-012585 | Date: 07/17/2019 --> START
                try{
                    //insert oppSplitToInsert;
                }catch(Exception ee){
                    
                }
                // Sharma Nemani | W-012584 & W-012585 | Date: 07/17/2019 --> END
            }

            if(!oppSplitToInsertOnUpdate.isEmpty())
            {
                insert oppSplitToInsertOnUpdate;
            }

        } catch(Exception ex) {
            List<Custom_Partner__c> cPars 
                = (List<Custom_Partner__c>) Trigger.new;
			
            // Added by: Sharma Nemani | W-012839 | Case: 00295033 | Date: 08/12/2019 --> START
            if(cPars == null){
                return;
            }
            // Sharma Nemani | W-012839 | Case: 00295033 | Date: 08/12/2019 --> END
            for(Custom_Partner__c cp : cPars) {
                Exception cause = ex.getCause();
                String msg = (cause != null) 
                             ? cause.getMessage() : ex.getMessage();

                cp.addError(msg); 
            }
        }
    }
}