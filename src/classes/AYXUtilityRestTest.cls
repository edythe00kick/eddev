/**
 * Created by ewong on 6/8/2020.
 */

@IsTest
public class AYXUtilityRestTest {

    @testSetup static void setup(){

        Account accOne = OrgWideTestUtil.createAccount(true);

        Lead leadOne = OrgWideTestUtil.createLead(true);

        Contact contactOne = OrgWideTestUtil.createContact(true, accOne.Id);

    }

    testMethod static void testScenarioOne(){

        Lead l = [SELECT Id FROM Lead LIMIT 1];
        Contact c = [SELECT Id FROM Contact Limit 1];

        String a = '+a=' + l.Id + ';';
        String b = '+b=' + c.Id + ';';


        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AYXUtilityRest/leadConvert?' + a + b ;
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response= res;
        AYXUtilityRest.leadConvert();

        Test.stopTest();

    }


}