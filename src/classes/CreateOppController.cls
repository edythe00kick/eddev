// Test Class Name - CreateOppControllerTest
public class CreateOppController {

    public Flow.Interview.CreateOpportunityNew myFlow {get;set;}
    public string accId ='';
    public string conId ='';
    public CreateOppController(ApexPages.StandardController controller) {
        accId = ApexPages.currentPage().getparameters().get('accId') != null
            ? ApexPages.currentPage().getparameters().get('accId') : '';
        conId = ApexPages.currentPage().getparameters().get('conId') != null 
            ? ApexPages.currentPage().getparameters().get('conId') : '';
    }

    public PageReference getretURL() {
        if(conId =='' && accId!= ''){
            return new PageReference('/' + accId);
        } else if (accId == '' && conId!= ''){
            return new PageReference('/' + conId);
        } else if(conId =='' && accId == ''){
            return new PageReference('/home/home.jsp');
        }
        if (myFlow != null && myFlow.getVariableValue('OppId') != null) {
            if (myFlow.getVariableValue('is_partner_deal')!= null  
                && String.ValueOf(myFlow.getVariableValue('is_partner_deal')) == 'true') {
                return new PageReference('/apex/AddPartner?id='+myFlow.getVariableValue('oppId'));
            }
           return new PageReference('/'+myFlow.getVariableValue('OppId'));
        }
        return null;
    }
}