@isTest
public class BatchUpdatePartnerAccountLookupFieldTest {

    // Create Account
    public static Account createAccount(boolean do_insert) {
    
        Account acc = new Account();
        acc.Name = 'BUPALFT Account';
        
        if(do_insert) {
            insert acc;
        }
        
        return acc;
        
    }
    
    // Create Contact
    public static Contact createContact(boolean do_insert, id account_id) {
    
        Contact con = new Contact();
        con.FirstName = 'BUPALFT';
        con.LastName = 'Contact';
        con.Email = 'contact@bupalft.com';
        con.AccountId = account_id;
        
        if(do_insert) {
            insert con;
        }
        
        return con;
        
    }
    
    // Create Opportunity
    public static Opportunity createOpportunity(boolean do_insert, id account_id) {
    
        Opportunity opp = new Opportunity();
        opp.Name = 'BUPALFT Opportunity';
        opp.AccountId = account_id;
        opp.StageName = 'Introduction';
        opp.CloseDate = Date.today() + 2;
        
        if(do_insert) {
            insert opp;
        }
        
        return opp;
        
    }
    
    // Create Partner
    public static Partner createPartner(boolean do_insert, id opp_id, id acc_to_id
            , boolean isPrimary
            , string role) {
            
        Partner ptnr = new Partner();
        ptnr.OpportunityId = opp_id;
        ptnr.AccountToId = acc_to_id;
        ptnr.isPrimary = isPrimary;
        ptnr.Role = role;
        
        if(do_insert) {
            insert ptnr;
        }
        
        return ptnr;
    }
    
    @isTest
    private static void testScenario1() {
        
        Account acc1 = createAccount(true);
        Contact con = createContact(true, acc1.Id);
        Opportunity opp = createOpportunity(true, acc1.Id);
        
        // Create partner account
        
        Account acc2 = new Account();
        acc2.Name = 'BUPALFT Partner Account';
        acc2.Partner_Type__c = 'Technology';
        acc2.RecordTypeId = Account.sObjectType.getDescribe()
            .getRecordTypeInfosByName()
            .get('Alteryx Partner Account Record Type').getRecordTypeId();
        insert acc2;
            
        Partner ptnr = createPartner(true, opp.Id, acc2.Id, true, ' Technology Provider');
        
        opp = [SELECT Partner_Account_Lookup__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(opp.Partner_Account_Lookup__c == null
            , 'This field should be null as new opportunity is created');
            
        Test.startTest();
        BatchUpdatePartnerAccountLookupField bupalf = new BatchUpdatePartnerAccountLookupField();
        Database.executeBatch(bupalf);
        Test.stopTest();
        
        opp = [SELECT Partner_Account_Lookup__c FROM Opportunity WHERE Id = :opp.Id];
        System.assert(opp.Partner_Account_Lookup__c == acc2.Id
            , 'This field should have primary partner account id as batch class updated'
            + ' opportunity');
        
    }

}