public class LeadMQLAcceptProcessController{

    public Flow.Interview.AcceptMQLFlow myFlow {
        get;
        set;
    }

    public String getmyID() {
        if (myFlow == null) return '';
        else return myFlow.CreateOppty;
    }

    public LeadMQLAcceptProcessController(ApexPages.StandardController controller) {}

    public PageReference getOID() {

        //string returl='/apex/ReCreateOpportunityUsingAdvancedFlow?accid='+getmyID()+'%26tis%3D'+getmyID();
        // string returl='/apex/AttachPartner?OppId='+getmyID();
        PageReference reference = new PageReference('/apex/leadConvertPage?id=' + apexpages.currentpage().getparameters().get('id') );

        reference.setRedirect(true);

        return reference;

    }

}