/*
Class for generating sessionId for lithium API
Test Class:LithiumSearchControllerTest
Developed By:- Grazitti Interactive
*/
public class Lithium_authentication{
    
    public String sessionId;
    public String username;
    public String password;
    public String strEndPoint;
    public String lithium_url;
    public Lithium_Search_Configuration__c searchConfiguration = Lithium_Search_Configuration__c.getinstance();
    
    public String authenticate(){  
        if(searchConfiguration!=null)
        {
            lithium_url =searchConfiguration.Lithium_Endpoint_URL__c;
            username=searchConfiguration.Lithium_Search_Username__c;
            password=searchConfiguration.Lithium_Search_Password__c;
        }
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();    
        username='user.login='+ EncodingUtil.urlEncode(username, 'UTF-8'); 
        password='&user.password='+ EncodingUtil.urlEncode(password, 'UTF-8');     
        strEndPoint = lithium_url+'/restapi/vc/authentication/sessions/login?'+username+password;  
        req.setEndpoint(strEndpoint);
        req.setMethod('GET');         
        if(!Test.isrunningTest()){
            try{ 
                res = http.send(req);
            }catch(Exception e){System.debug('Exception under session key'+e);}
        }else {
            staticresource testStatic = [select id, body from staticresource where name = 'SessionIdCall' limit 1];
            res = new HTTPResponse();
            string tempStr = testStatic.body.tostring();
            res.setBody(tempStr);
        }
        Dom.Document doc = res.getBodyDocument();
        Dom.XMLNode details= doc.getRootElement();
        try{
            sessionId= details.getChildElement('value', null).getText();
        }catch(Exception e){System.debug('Exception sessionId' + e);} 
        return sessionId; 
    }
    
    
}