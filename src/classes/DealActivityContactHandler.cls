public class DealActivityContactHandler {

    public DealActivityContactHandler(Boolean isExecuting, List<Deal_Activity_Contact__c> newRecords) {
        
        Recursionhandler.IsDealActivityContactTriggerExecuted = true;
    }

    public void onBeforeUpdate(List<Deal_Activity_Contact__c> newRecords)
    {

        List<Deal_Activity_Contact__c> approvedDACList = new List<Deal_Activity_Contact__c>();
        Set<Id> dacUserIds = new Set<Id>();
        Map<Id, Id> dacToCreatedByIdMap = new Map<Id, Id>();

        for(Deal_Activity_Contact__c dac : newRecords)
        {
            Deal_Activity_Contact__c oldDAC = (Deal_Activity_Contact__c)Trigger.oldMap.get(dac.ID);

            if(dac.Qualification_Status__c != oldDAC.Qualification_Status__c && (dac.Qualification_Status__c == 'Approved')
               && oldDAC.Rep_Territory_Code__c == null)
            {
                approvedDACList.add(dac);
                dacUserIds.add(dac.CreatedById);
                dacToCreatedByIdMap.put(dac.Id, dac.CreatedById);
            }
        }

        //Author: Sergio Flores
        //Date: 12/13/2018
        //W-010723
        if(!approvedDACList.isEmpty())
        {
            Map<Id, User> userIdToUserMap = new Map<Id, User>([Select Id, Rep_Territory_Code__c, CY_Sales_Territory_Code__c
                                                                   From User
                                                                   Where Id IN : dacUserIds]);

            if(!userIdToUserMap.isEmpty())
                {
                    system.debug('Inside map not empty');
                    for(Deal_Activity_Contact__c dac : approvedDACList)
                    {
                        //need to stamp approval date to today and then compare if close date is equal to 2018
                        //need to disable following workflow rule: 01Q44000000UrXQ
                        Date closeDate = date.today();
                        User u = userIdToUserMap.get(dacToCreatedByIdMap.get(dac.Id));
                        //if the opp closes in 2018 or before, then we need to grab the legacy rep territory code field
                        //else use the new sales terr code field
                        system.debug('closed date ' + closeDate);
                        if(closeDate.year() <= 2018) 
                        {
                            if(u.Rep_Territory_Code__c != '')
                            {
                                system.debug('Inside Opp Update');
                                dac.Rep_Territory_Code__c = u.Rep_Territory_Code__c;
                                dac.Approval_Date__c = closeDate;
                            }                       
                        }
                        else 
                        {
                            if(u.CY_Sales_Territory_Code__c != '')
                            {
                                dac.Rep_Territory_Code__c = u.CY_Sales_Territory_Code__c;
                                dac.Approval_Date__c = closeDate;
                            }
                        }
                    }
                }
        }


    }
    
       /* Author: Sharma Nemani | W-010093 --> START
     	* Date: 06/20/2019
     	* Description: This method is to create a Contact Role in Opportunity when the "Qualification Status" of a 
     	*              Deal ActivityContact is flipped
     	*              to 'Approved'.
     	*/
    public void onAfterUpdate(Map<Id,Deal_Activity_Contact__c> newRecordsMap,Map<Id,Deal_Activity_Contact__c> oldRecordsMap){
        
        // Query on Deal_Activity_Contact__c to get  Deal_Activity__r.Related_Opportunity__c required to create OppContactRole.
        List<Deal_Activity_Contact__c> dac = [select id,Contact__c,Qualification_Status__c,Deal_Activity__c,Deal_Activity__r.Related_Opportunity__c  from Deal_Activity_Contact__c where Id IN:newRecordsMap.keyset() limit 50000];
        
        // Map to make combination of Contact (from Deal_Activity_Contact__c) Id and OppId (from Deal_Activity__c)
        Map<Id,Id> mapOfContactAndOpportunityIds = new Map<Id,Id>();
        
        // Setting the combination in Map - mapOfContactAndOpportunityIds of ContactIds And OppIds
        for(Deal_Activity_Contact__c dacRec : dac){
            if(newRecordsMap.get(dacRec.Id).Contact__c !=null && newRecordsMap.get(dacRec.Id).Deal_Activity__c !=null && newRecordsMap.get(dacRec.Id).Qualification_Status__c =='Approved' && newRecordsMap.get(dacRec.Id).Qualification_Status__c != oldRecordsMap.get(dacRec.Id).Qualification_Status__c){
                mapOfContactAndOpportunityIds.put(dacRec.Contact__c,dacRec.Deal_Activity__r.Related_Opportunity__c);
            }
        }
        
        Map<Id,OpportunityContactRole> mapOpportunityContactRole ;
        
        // Checking if OppContactRole exists in Contact & Opp combination available in Map - 
        // mapOfContactAndOpportunityIds.
        
        if(mapOfContactAndOpportunityIds.size() > 0){
            //AND OpportunityId IN : mapOfContactAndOpportunityIds.values()
            mapOpportunityContactRole  = new Map<Id,OpportunityContactRole>([select id,ContactId from OpportunityContactRole where ContactId IN:mapOfContactAndOpportunityIds.keyset() AND OpportunityId IN : mapOfContactAndOpportunityIds.values()]);
        }
        
        // Removing all those combination of contactIds and OppIds which are already a part of OppcontactRoles.
         
        if(mapOpportunityContactRole!=null){
            for(Id oppContactRole : mapOpportunityContactRole.keyset()){
                if(mapOfContactAndOpportunityIds!=null && mapOfContactAndOpportunityIds.containsKey(mapOpportunityContactRole.get(oppContactRole).ContactId)){
                    mapOfContactAndOpportunityIds.remove(mapOpportunityContactRole.get(oppContactRole).ContactId);
                }
            }
        }
        List<OpportunityContactRole> lstOppConRole = new List<OpportunityContactRole>();
        // Preparing a List of new OpportunityContactRole .
        If(mapOfContactAndOpportunityIds.size() > 0){
            for(Id conId : mapOfContactAndOpportunityIds.keyset()){
                OpportunityContactRole ocr = new OpportunityContactRole();
                ocr.ContactId = conId;
                ocr.OpportunityId = mapOfContactAndOpportunityIds.get(conId);
                ocr.Role = 'Data Artisan';
                lstOppConRole.add(ocr);
            }
        }
        insert lstOppConRole;
    }
    // Sharma Nemani | Date: 06/20/2019 | W-010093 --> END
}