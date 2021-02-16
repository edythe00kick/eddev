@isTest
 private class Test_MassConvertABMLeads{

     static testMethod void testMassConvertABMLeads() {
        Account a = new Account(name='TesB',phone='98765495201');
        insert a;
        Contact c = new Contact(lastname='bhalla',accountid=a.id,email='p123@tetst.com');
        insert c;
        
        Lead l = new Lead(lastname='bhalla',company ='Graz',email='p123@tetst.com',LeanData__Reporting_Matched_Account__c =a.id,LD_Matched_Account_Owner__c='Randy Clem',Country ='United States',LD_Matched_ABM_Level__c ='Gold'); 
        insert l; 
         
         Test.StartTest();
             MassConvertABMLeads obj = new MassConvertABMLeads();
             Database.executeBatch(obj);
         Test.StopTest();

     }

}