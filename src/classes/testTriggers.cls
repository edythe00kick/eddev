/** @isTest
  * This class contains unit tests for validating the behavior of Apex classes
  * and triggers.
  *
  * Unit tests are class methods that verify whether a particular piece
  * of code is working properly. Unit test methods take no arguments,
  * commit no data to the database, and are flagged with the testMethod
  * keyword in the method definition.
  *
  * All test methods in an organization are executed whenever Apex code is deployed
  * to a production organization to confirm correctness, ensure code
  * coverage, and prevent regressions. All Apex classes are
  * required to have at least 75% code coverage in order to be deployed
  * to a production organization. In addition, all triggers must have some code coverage.
  *
  * The @isTest class annotation indicates this class only contains test
  * methods. Classes defined with the @isTest annotation do not count against
  * the organization size limit for all Apex scripts.
  *
  * See the Apex Language Reference for more information about Testing and Code Coverage.
  */
public class testTriggers {
    
    private static Account a;
    private static Entitlement e;
    private static Case c;
    
    private static void setup() {
        a = new Account();
        a.Name = 'Test Acc';
        insert a;
        e = new Entitlement();
        e.Name = 'Test Ent';
        e.AccountId = a.Id;
        e.Type = 'Phone Support';
        insert e;
        c = new Case();
        c.Subject = 'Test Case';
        c.AccountId = a.Id;
        c.Type = 'Instructional';
        c.Case_Category__c = 'General Promote Questions';
        c.Reason = 'Generic';
        c.Products__c = 'Data';
        c.Severity__c = 'SEV 1';
        insert c;
    }
    private static testMethod void testUpdateAfterTimeEntryTrigger() 
    {
        testTriggers.setup();
        Test.startTest();
        List<Case_Time_Entry__c> lstCTE = new List<Case_Time_Entry__c>();                    
        for(Integer j = 0; j < 4 ; j++)
        {
            Case_Time_Entry__c oC = new Case_Time_Entry__c();
            oC.Case__c = c.Id;
            oC.Active_Time_Spent__c = String.ValueOf(j+'.5');
            // Added by Oshin on June 23, 2015
            oC.Date_Completed__c = Date.today();
            lstCTE.add(oC);
        }
        insert lstCTE;
        lstCTE = new List<Case_Time_Entry__c>([Select Id from Case_Time_Entry__c Where Case__c =: c.Id]);
        List<Case_Time_Entry__c> lstToDelete = new List<Case_Time_Entry__c>();
        List<Case_Time_Entry__c> lstToUpdate = new List<Case_Time_Entry__c>();                    
        for(Integer j = 0; j < 4 ; j++)
        {
            Case_Time_Entry__c oC = lstCTE[j];
            oC.Case__c = c.Id;
            if(j<=2)
            {
                lstToDelete.add(oC);
            }
            if(j>2)
            {
                oC.Active_Time_Spent__c = String.ValueOf('1.5');
                lstToUpdate.add(oC);                
            }
        }
        delete lstToDelete;
        update lstToUpdate;
        Test.stopTest();
    }
}