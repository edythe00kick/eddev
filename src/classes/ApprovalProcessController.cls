public class ApprovalProcessController {

    public Flow.Interview.ApprovalProcess myFlow {
        get;
        set;
    }

    public String getmyID() {
        if (myFlow == null) return '';
        else return myFlow.OppID;
    }

    public ApprovalProcessController(ApexPages.StandardController controller) {}

    public PageReference getOID() {

        //string returl='/apex/ReCreateOpportunityUsingAdvancedFlow?accid='+getmyID()+'%26tis%3D'+getmyID();
        // string returl='/apex/AttachPartner?OppId='+getmyID();
        PageReference reference = new PageReference('/' + getmyID());

        reference.setRedirect(true);

        return reference;

    }

}