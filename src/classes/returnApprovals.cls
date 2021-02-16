public class returnApprovals {   
  //capture the quote id
    public ID quoteID {get; set;}
    //public List<sbaa__ApprovalRule__c> ruleList = new List<sbaa__ApprovalRule__c>();
    public List<sbaa__Approval__c> ruleList = new List<sbaa__Approval__c>(); 

    @testVisible public List<sbaa__Approval__c> getApprovalRuleList() {
        List<sbaa__Approval__c> approvalsList = [Select Id, sbaa__Rule__c,  sbaa__Rule__r.Name, sbaa__Rule__r.sbaa__Approver__r.Name, sbaa__AssignedTo__r.Name From sbaa__Approval__c Where Quote__c =: quoteID];
        system.debug('approvalsList ' + approvalsList);
        
        Set<Id> approvalIds = new Set<Id>();
        Set<String> approvalRuleName = new Set<String>(); //Need to concat ruleandAssignedTo 
        
        for(sbaa__Approval__c approval : approvalsList)
        {                 
            if(!approvalRuleName.contains(approval.sbaa__Rule__r.Name + approval.sbaa__AssignedTo__r.Name) && approval.sbaa__Rule__r.sbaa__Approver__r.Name != 'Deal Desk Queue' )
            {                   
                approvalRuleName.add(approval.sbaa__Rule__r.Name + approval.sbaa__AssignedTo__r.Name);
                approvalIds.add(approval.Id);
            }  
        }
        //ruleList = [Select name, Rule_Criteria__C From sbaa__ApprovalRule__c Where Id IN : approvalIds];
        ruleList = [Select sbaa__Rule__r.Name , sbaa__Rule__r.Rule_Criteria__C, sbaa__AssignedTo__r.Name From sbaa__Approval__c where Id IN : approvalIds Order By sbaa__AssignedTo__r.Name];
        
        system.debug('inside approval list for visualforce template ' + ruleList);
        return ruleList;
    }
}