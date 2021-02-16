/**
 * Eddie Wong
 * W-005539
 * 06/12/2020
 * Test class for AYXUtilityRest
 */

@IsTest
public class AYXUtilityRest_Test {

    @testSetup static void setup(){


        Account accOne = OrgWideTestUtil.createAccount(true);

        Lead leadOne = OrgWideTestUtil.createLead(false);
        leadOne.Email = 'test1@test.com';
        Insert leadOne;

        Lead leadTwo = OrgWideTestUtil.createLead(false);
        leadTwo.Email = 'test2@test.com';
        Insert leadTwo;

        Contact contactOne = OrgWideTestUtil.createContact(false, accOne.Id);
        contactOne.Email = 'cTest1@test.com';
        Insert contactOne;

        Contact contactTwo = OrgWideTestUtil.createContact(false, accOne.Id);
        contactTwo.Email = 'cTest2@test.com';
        Insert contactTwo;

    }

    testMethod static void testScenarioOne(){

        Lead lOne = [SELECT Id FROM Lead WHERE Email = 'test1@test.com' LIMIT 1];
        Lead lTwo = [SELECT Id FROM Lead WHERE Email = 'test2@test.com' LIMIT 1];

        Contact cOne = [SELECT Id FROM Contact WHERE Email = 'cTest1@test.com' Limit 1];
        Contact cTwo = [SELECT Id FROM Contact WHERE Email = 'cTest2@test.com' Limit 1];

        Account aOne = [SELECT Id FROM Account LIMIT 1];


        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AYXUtilityRest/leadConvert?';
        req.httpMethod = 'GET';
        req.addParameter('a',lOne.Id + ';' + lTwo.Id);
        req.addParameter('b',cOne.Id + ';' + aOne.Id);
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        AYXUtilityRest.leadConvert();

        Test.stopTest();

    }

    /*
    private static testmethod void TestAYXUtilityHttp() {

        Lead l = [SELECT Id FROM Lead LIMIT 1];
        System.debug('eddie check lead' + l);

        Contact c = [SELECT Id FROM Contact Limit 1];
        System.debug('eddie check contact' + c);

        String setEndPointURL = 'https://alteryx--eddev2.my.salesforce.com/services/apexrest/AYXUtilityRest/leadConvert?a=' + l.Id + '&b=' + c.Id ;

        Test.setMock(HttpCalloutMock.class, new AYXUtilityRestMock('Case: Example Flow', 'My example Flow to test.'));

        System.debug('eddie inside TestAYXUtilityHttp' + setEndPointURL);

        Test.startTest();
        AYXUtilityRest.leadConvert();
        //HttpResponse res = AYXUtilityRestMock_Test.AYXUtilityRestMock(setEndPointURL);
        Test.stopTest();
    }
*/

}