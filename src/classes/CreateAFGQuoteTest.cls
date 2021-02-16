/* Author: Sharma Nemani | W-012645
 * Date: 07/22/2019
 * Description: Test Class for "CreateAFGQuote" Class.
*/
@isTest
private class CreateAFGQuoteTest {
    static testMethod void createOpportunityTest() {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc;

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;
        CreateAFGQuote.createOpportunity(cont.Id);
    }
    
}