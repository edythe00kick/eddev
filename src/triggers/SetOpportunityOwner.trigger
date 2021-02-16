trigger SetOpportunityOwner on OpportunityTeamMember(after insert,after update) {
    
    if(UserInfo.getUserName() == 'sfdcadmin@alteryx.com' || UserInfo.getUserId() == System.Label.System_Administrator_Integration) { return; }
    
    if(UserInfo.getUserId()!= System.Label.System_Administrator_Integration){
        if (UtilityClass.SetOpportunityOwnerIsFirstRun == true) {
            UtilityClass.SetOpportunityOwnerIsFirstRun = false;
            List < OpportunityTeamMember > otm_list = new List < OpportunityTeamMember > ();
            List < OpportunityTeamMember > update_otm_list = new List < OpportunityTeamMember > ();
    
            SET < ID > OpptyIDs = new set < ID > ();
            Map < ID, string > opID_ownerEmail_Map = new Map < ID, string > ();
    
            for (OpportunityTeamMember otm: Trigger.new) {
    
                OpptyIDs.add(otm.OpportunityID);
                otm_list.add(otm);
    
            }
            for (opportunity op: [SELECT ID, Owner.Email FROM Opportunity where ID IN: OpptyIDs]) {
                opID_ownerEmail_Map.put(op.ID, Op.Owner.Email);
    
            }
    
    
    
            for (OpportunityTeamMember otm: [SELECT ID, OpportunityID,
                Opportunity_Owner__c FROM OpportunityTeamMember WHERE ID IN: TRIGGER.NEW
            ]) {
    
                otm.Opportunity_Owner__c = opID_ownerEmail_Map.get(otm.OpportunityID);
                update_otm_list.add(otm);
            }
    
            try {
                if (!update_otm_list.isempty())
                    update update_otm_list;
            } catch (Exception e) {
                System.debug('Error message:' + e);
    
            }
        }
    }
}