@isTest
public class Test_Alteryxnews{

    public static testmethod void Alteryxnewstest(){
       // create a new email and envelope object
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
      
       // setup the data for the email
      email.subject = 'Create Contact';
      email.fromAddress = 'someaddress@email.com';
      email.plainTextBody = 'email body\n2225256325\nTitle';

      // call the email service class and test it with the data in the testMethod
      Alteryxnews testInbound = new Alteryxnews();
      testInbound.handleInboundEmail(email, env);
    }
}