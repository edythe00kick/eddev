@isTest
public class Test_schedupdateAnnualRevenueonAccounts{


    public static testMethod void testupdateAnnualRevenueonAccounts1() {
           Test.StartTest();
           ScheduleupdateAnnualRevenueonAccounts  obj = new ScheduleupdateAnnualRevenueonAccounts ();
           obj.execute(null);
           //String sch = '0 0 23 * * ?'; 
           //system.schedule('Test Territory Check', sch, sh1);
           //obj.execute(new SchedulableContext (null));
           Test.stopTest();           
     }
     
}