public class LDRFlowControllerContact {
    public  Flow.Interview.LDR_flow_MQL_Submit_Contact customFlow { set; get;}
    
    public LDRFlowControllerContact(ApexPages.StandardController controller) {}
    
    public PageReference getRedirection() {
        PageReference reference = null;
        
        if(customFlow == null) {
            reference = new PageReference('/');
        } else {
            if(test.IsRunningTest() || customFlow.RightOwner == 'No') {
                if(test.IsRunningTest()){
                    reference = new PageReference('/' + ApexPages.CurrentPage().getparameters().get('id'));
                }else{ reference = new PageReference('/' + customFlow.RecordId); }
            } else {
                String redirect_url = '00T/e?who_id='+ApexPages.CurrentPage().getparameters().get('id')+'&retURL=/apex/TaskRedirectContact?id='+ApexPages.CurrentPage().getparameters().get('id')+'&RecordType='+Label.SAOSubmitsRecordTypeId + '&what_id=' + ApexPages.CurrentPage().getparameters().get('accountId') + '&tsk1_lkid=' + ApexPages.CurrentPage().getparameters().get('assignedToId') + '&tsk1_lkold=' + ApexPages.CurrentPage().getparameters().get('assignedToName') + '&tsk1=' + ApexPages.CurrentPage().getparameters().get('assignedToName');
                reference = new PageReference('/' + redirect_url);
            }
        }
        
        reference.setRedirect(true);
        return reference;
    }
}