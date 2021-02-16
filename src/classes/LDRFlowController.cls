public class LDRFlowController{

    public Flow.Interview.LDR_flow myFlow {
        get;
        set;
    }

    public String getmyID() {
        if (myFlow == null) {
            return '';
        }
        else {
                if (myFlow.RightOwner == 'No')
                    return myflow.LeadID;
                else {
                 //Commented by Paramvir 5 November,2015 for passing record type of SAO Task instead of Sales Activity Record Type Task
                 //string reference='00T/e?who_id='+ApexPages.CurrentPage().getparameters().get('id')+'&retURL=/apex/TaskRedirect?id='+ApexPages.CurrentPage().getparameters().get('id');

                 string reference='00T/e?who_id='+ApexPages.CurrentPage().getparameters().get('id')+'&retURL=/apex/TaskRedirect?id='+ApexPages.CurrentPage().getparameters().get('id')+'&RecordType='+Label.SAOSubmitsRecordTypeId;
                 
                 return reference ;
           }
       }   
    }

    public LDRFlowController(ApexPages.StandardController controller) {}

    public PageReference getOID() {
        PageReference reference = new PageReference('/'+getmyID());
        reference.setRedirect(true);
        return reference;
    }

}