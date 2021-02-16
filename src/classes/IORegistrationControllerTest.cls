@isTest
public class IORegistrationControllerTest {

    static testmethod void TestIORegistrationController1(){
        
        Test.StartTest();
        
        Account acc = OrgWideTestUtil.createAccount(true);
        Contact con = OrgWideTestUtil.createContact(true,acc.Id);    
        //Lead ld = OrgWideTestUtil.createLead(true);
        Lead ld1 = OrgWideTestUtil.createLead(false); 
        ld1.email = con.email;
        insert ld1;       
                
        // Error for duplicate email
        String result = IORegistrationController.save(ld1);
    }
    
    static testmethod void TestIORegistrationController2(){
        
        Test.StartTest();
        
        //Matching company name
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.name = 'Test Account';
        insert acc;
    
        //Domain Name
        Lead ld = OrgWideTestUtil.createLead(false);
        ld.company = 'Test Account';
                        
        //Match Domain Name
        String result = IORegistrationController.save(ld);
        Test.StopTest();
    }
}