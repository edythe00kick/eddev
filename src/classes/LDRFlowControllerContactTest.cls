@isTest
public class LDRFlowControllerContactTest {
    @isTest
    private static void testScenario1() {
        Account acc = createAccount(true);
        Contact con = createContact(true, acc.Id);
        ApexPages.StandardController standardController = new ApexPages.StandardController(con);
        
        PageReference pageRef = Page.MQLSubmitContact;
        pageRef.getParameters().put('id', con.Id);
        pageRef.getParameters().put('OwnerID', con.OwnerId);
        pageRef.getParameters().put('CurrentUserID', con.OwnerId);
        Test.setCurrentPageReference(pageRef);
        
        LDRFlowControllerContact lfcc = new LDRFlowControllerContact(standardController);
        Map<String, Object> param = new Map<String, Object>();
        //param.put('RecordId', con.Id);
        //param.put('RecordOwnerId', con.OwnerId);
        //param.put('CurrentUserId', con.Id);
        
        //lfcc.customFlow = new Flow.Interview.LDR_flow_MQL_Submit_Contact(new Map<String, Object>());
        lfcc.customFlow = NULL;
        lfcc.getRedirection();
    }
    
     @isTest
    private static void testScenario2() {
        Account acc = createAccount(true);
        Contact con = createContact(true, acc.Id);
        ApexPages.StandardController standardController = new ApexPages.StandardController(con);
        
        PageReference pageRef = Page.MQLSubmitContact;
        pageRef.getParameters().put('id', con.Id);
        pageRef.getParameters().put('OwnerID', con.OwnerId);
        pageRef.getParameters().put('CurrentUserID', con.OwnerId);
        Test.setCurrentPageReference(pageRef);
        
        LDRFlowControllerContact lfcc = new LDRFlowControllerContact(standardController);
        Map<String, Object> param = new Map<String, Object>();
        //param.put('RecordId', con.Id);
        //param.put('RecordOwnerId', con.OwnerId);
        //param.put('CurrentUserId', con.Id);
        
        lfcc.customFlow = new Flow.Interview.LDR_flow_MQL_Submit_Contact(new Map<String, Object>());
        lfcc.getRedirection();
    }
    
    // Create Account
    public static Account createAccount(boolean do_insert) {
        Account acc = new Account();
        acc.Name = 'LLDRP Account';
        if(do_insert) {
            insert acc;
        }
        return acc;
    }
    
    // Create Contact
    public static Contact createContact(boolean do_insert, id account_id) {
        Contact con = new Contact();
        con.FirstName = 'LLDRP';
        con.LastName = 'Contact';
        con.Email = 'contact@lldrp.com';
        con.AccountId = account_id;
        if(do_insert) {
            insert con;
        }
        return con;
    }
}