@isTest
 private class Test_CreateECRTasksonAgreement{

     static testMethod void testCreateECRTasksonAgreement() {
         Account a = new Account(name='TesB',phone='98765495201', type='Customer');
        insert a;
        Opportunity o = new Opportunity(Name='Gomp', CloseDate=system.today(), StageName= System.label.StageName_B ,AccountId=a.id,Type='ECR'  );
        insert o;
         
         Apttus__APTS_Agreement__c agreement = new Apttus__APTS_Agreement__c();
         agreement.Apttus__Account__c = a.id;
         agreement.Apttus__Related_Opportunity__c = o.id;
         agreement.Apttus__Status__c = 'Activated';
         insert agreement;
         
         Billing_Schedule__c subSchedule = new Billing_Schedule__c();
         Date d = Date.Today().addDays(75);
         subSchedule.Subscription_Start_Date__c = d;
         subSchedule.Subscription_End_Date__c = d.addDays(364);
         subSchedule.Year__c = '2nd';
         subSchedule.Agreement__c = agreement.id;
         insert subSchedule;
         
         
         Billing_Schedule__c  bs = [select id,Days_left_in_Subscription_Start__c  from Billing_Schedule__c  where id =: subSchedule.id];
         system.debug('@@ @@'+bs.Days_left_in_Subscription_Start__c );
         
         Test.StartTest();
             CreateECRTasksonAgreement obj = new CreateECRTasksonAgreement ();
             Database.executeBatch(obj);
         Test.StopTest();

     }

     static testMethod void Test_ScheduleCreateECRTasksonAgreement() {
         ScheduleCreateECRTasksonAgreement obj = new ScheduleCreateECRTasksonAgreement();
         obj.execute(null);
     }
 }