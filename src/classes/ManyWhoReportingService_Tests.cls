@istest
public class ManyWhoReportingService_Tests {

    private static testmethod void ManyWhoReportingService() {
        ManyWhoFlow__c flow = new ManyWhoFlow__c();
        flow.Name = 'Test';
        flow.JoinUri__c = 'https://flow.manywho.com?join=abcd';
        insert flow;
    
        ManyWhoAPI.StateAPI state = new ManyWhoAPI.StateAPI();
        state.id = 'abcd';
    
        String jsonMsg = JSON.serialize(state);

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/report';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonMsg);
        
        RestContext.request = req;
        RestContext.response= res;

        ManyWhoReportingService.doPost();
    }

}