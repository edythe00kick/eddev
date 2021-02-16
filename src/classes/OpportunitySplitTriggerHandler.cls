/* Author: Sharma Nemani | W-013113 | Case: 00302043
   Date:11/12/2019
   Description: Handler Class for OpportunitySplitTrigger.
*/ 
public with sharing class OpportunitySplitTriggerHandler {

    
    
    /* Added By: Sharma Nemani | W-013113 | Case: 00302043
       Date: 11/12/2019
       Description: "Split Owner Role" - Should be stamped with the User Role of the Owner of the Split at time of Split creation
     			    "Opportunity Owner Role" - Should be stamped with the User Role of the Owner of the related Opportunity at time of Split creation
  	*/
    public void onBeforeInsert(List<opportunitySplit> oppSplit){

        Set<Id> oppIds = new Set<Id>();

        for(opportunitySplit os : oppSplit)
        {
            if(os.Opportunity_Split_User_Role__c !=null)
            os.Split_Owner_Role__c = os.Opportunity_Split_User_Role__c;
            system.debug('opp split split owner role ' + os.Split_Owner_Role__c);

            oppIds.add(os.OpportunityId);
        }

        Map<Id,opportunity> oppIdToOppMap = new Map<Id,opportunity>([select id, isClosed, owner.userRole.Name from opportunity where Id IN: oppIds]);

        for(OpportunitySplit os : oppSplit){
            
            Opportunity o = oppIdToOppMap.get(os.OpportunityId);

            os.Opportunity_Owner_Role__c  = o.owner.userRole.Name;
            system.debug('opp split opp owner role ' + os.Opportunity_Owner_Role__c);
        }
    }
    
    /* Added By: Sharma Nemani | W-013113 | Case: 00302043
       Date: 11/12/2019
       Description: Opportunity_Owner_Role__c updated only when the Opportunity Owner changes
    */  
    public static void onOppOwnerChange(Set<Id> setOppOwnerIds){
        List<opportunitySplit> oppSplit = [select id,Opportunity_Owner_Role__c,opportunity.isClosed,opportunity.owner.userRole.Name from opportunitySplit where opportunityId IN:setOppOwnerIds];
        for(opportunitySplit oppSplt : oppSplit){
            oppSplt.Opportunity_Owner_Role__c = oppSplt.opportunity.owner.userRole.Name;
        }
        update oppSplit;
    }
    
}