@isTest
private class Test_UpdateNumberofContactRolesTrigger {

    static testmethod void TestConTrigger() {
        Test.startTest();
            User u = [select id,name,isactive from User where profileid =: System.Label.SysAdminProfileID and isactive = TRUE limit 1];
            System.runAs(u) {
            Account at = new Account(name='TestingtgAccountt',CurrencyIsoCode='USD', phone='9876054321');
            insert at;
            Contact c = new Contact(FirstName='Rock',LastName='Rsajj Sharma',email='ragjjs@alteryx.com',CurrencyIsoCode='USD', AccountId=at.id);
            insert c;
            List<Opportunity> oppList1 = new List<Opportunity>();
            Opportunity ot = new Opportunity(CurrencyIsoCode = 'USD',Name = 'Test-Opportunity',StageName = System.label.StageName_B, CloseDate=Date.Today(), AccountId=at.id);
            Opportunity otp = new Opportunity(CurrencyIsoCode = 'USD',Name = 'Tett-Opportunity26',StageName = System.label.StageName_C, CloseDate=Date.Today(), AccountId=at.id);
            oppList1.add(ot);
            oppList1.add(otp);
            insert oppList1;
            }
        Test.StopTest(); 
    }
}