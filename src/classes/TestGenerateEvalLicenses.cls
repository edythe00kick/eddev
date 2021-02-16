@isTest
public class TestGenerateEvalLicenses{
    static testmethod void AddCampaignMembers(){
        // recordtypeid='012E0000000VROtIAO'
        Account a = new Account(name='TesstAccountt', phone='9876543201',CurrencyIsoCode='USD');
        insert a;
        Opportunity recd = new Opportunity(Name='Gopp', CloseDate=system.today(), StageName= System.label.StageName_B, ForecastCategoryName='Pipeline',accountid=a.id  );
        insert recd; 
        Contact c = new Contact(CurrencyIsoCode='USD',email='p@x.com',lastname='TestContact',accountid=a.id);
        insert c;
        Evaluation_License_Request__c eval = new Evaluation_License_Request__c(CurrencyIsoCode='USD',Contact__c = c.id,Product_Bundle__c='Alteryx Designer Eval',Number_of_Licenses__c = 1,Opportunity__c = recd.id ,Expiration_Date__c = date.today()+1  );
        insert eval;
        //eval.Status__c = 'Approved';
        //update eval;
    }


/*
     static testmethod  void testCallout() {
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Call method to test.
        // This causes a fake response to be sent
        // from the class that implements HttpCalloutMock. 
        
        Account a = new Account(name='TesstAccountt',recordtypeid='012E0000000VROtIAO',phone='9876543201',CurrencyIsoCode='USD' );
        insert a;
        Opportunity recd = new Opportunity(Name='Gopp', CloseDate=system.today(), StageName= System.label.StageName_B, ForecastCategoryName='Pipeline',accountid=a.id  );
        insert recd; 
        Contact c = new Contact(CurrencyIsoCode='USD',email='p@x.com',lastname='TestContact',accountid=a.id);
        insert c;
        Evaluation_License_Request__c eval = new Evaluation_License_Request__c(CurrencyIsoCode='USD',Contact__c = c.id,Product_Bundle__c='Alteryx Designer Eval',Number_of_Licenses__c = 1,Opportunity__c = recd.id ,Expiration_Date__c = date.today()+1  );
        insert eval;
        eval.Status__c = 'Approved';
        update eval;
       HttpResponse res = CalloutClass.getInfoFromExternalService();
        
        // Verify response received contains fake values
        String contentType = res.getHeader('Content-Type');
        System.assert(contentType == 'application/json');
        String actualValue = res.getBody();
        String expectedValue = '{"foo":"bar"}';
        System.assertEquals(actualValue, expectedValue);
        System.assertEquals(200, res.getStatusCode());
    }

    */
}