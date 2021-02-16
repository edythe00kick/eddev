public class RunLeadAssignmentRules {
    
    @future
    public static void reassignLeadWithDefaultAssignmentRule(Set<Id> leadIds) {    
        system.debug('leadIds=====================================>'+leadIds);
        List<Lead> leadstoUpdate = new List<Lead>();
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        
        for(Id leadId : leadIds){
            Lead newLead = new Lead(id = leadId);
            newLead.setOptions(dmo);
            leadstoUpdate.add(newLead);
        }
        
        if(leadstoUpdate.size() > 0 && !leadstoUpdate.isEmpty()){
            try{ update leadstoUpdate; }catch(Exception e){Trigger.new[0].addError(e.getMessage());}
        }
        system.debug('leadstoUpdate=====================================>'+leadstoUpdate);
    }

}