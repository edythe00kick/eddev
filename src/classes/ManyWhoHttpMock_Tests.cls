@istest
public class ManyWhoHttpMock_Tests {

    private static testmethod void ManyWhoHttpMock() {
        ManyWhoHttpMock mock = null;
        
        mock = new ManyWhoHttpMock(null, null);
        mock = new ManyWhoHttpMock('hello', 'world');

        HTTPRequest req = new HTTPRequest();

        req.setEndPoint('https://google.com');
        req.setMethod('GET');           
        mock.respond(req);
        
        req.setEndPoint('https://flow.manywho.com/api/run/1/flow');                    
        mock.respond(req);
    }

}