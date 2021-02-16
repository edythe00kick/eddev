@isTest

private class DellBoomiTest {

    static testMethod void createLicenseProductBoomiCallout() {   

        SBQQ__Quote__c q = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        insert q;

        Product2 p = (Product2)SmartFactory.createSObject('Product2');
        p.Family = 'Alteryx Software';
        insert p;
        
        Test.startTest();                         
            License_Product__c lp = (License_Product__c)SmartFactory.createSObject('License_Product__c');
            lp.Product__c = p.Id;
            lp.Quote__c = q.Id;
            insert lp;
        Test.StopTest();
    }   
    
        static testMethod void createLicenseProductConnectPromote() {   

        SBQQ__Quote__c q = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        insert q;

        Product2 p = (Product2)SmartFactory.createSObject('Product2');
        p.Family = 'Alteryx Software';
        p.Name = 'Alteryx Connect';
        insert p;
        
        Test.startTest();                         
            License_Product__c lp = (License_Product__c)SmartFactory.createSObject('License_Product__c');
            lp.Product__c = p.Id;
            lp.Quote__c = q.Id;
            insert lp;
        Test.StopTest();
    }   
    
     static testMethod void dellBoomiResendTest() {   

        SBQQ__Quote__c q = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        insert q;

        Product2 p = (Product2)SmartFactory.createSObject('Product2');
        p.Family = 'Alteryx Software';
        p.Name = 'Alteryx Connect';
        insert p;

        License_Product__c lp = (License_Product__c)SmartFactory.createSObject('License_Product__c');
        lp.Product__c = p.Id;
        lp.Quote__c = q.Id;
        insert lp;
        
        Test.startTest();                         
        
        License_Product__c lp2 = [SELECT Id FROM License_Product__c WHERE Id =: lp.Id];
        lp2.Resend_To_Boomi__c = true;
        lp2.Dell_Boomi_In_Progress__c = false;
        lp2.NoSendToDellBoomi__c = false;
        update lp2;
        
        Test.StopTest();
    }

    static testMethod void dellBoomiSendLPUTest() {
        SBQQ__Quote__c q1 = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        insert q1;

        SBQQ__Quote__c q2 = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        insert q2;

        SBQQ.TriggerControl.disable();
        SBQQ__QuoteLine__c ql = (SBQQ__QuoteLine__c)SmartFactory.createSObject('SBQQ__QuoteLine__c');
        ql.SBQQ__Quote__c = q2.Id;
        ql.SBQQ__Quantity__c = 5;
        insert ql;
        SBQQ.TriggerControl.enable();


        Product2 p = (Product2)SmartFactory.createSObject('Product2');
        p.Family = 'Alteryx Software';
        p.Name = 'Alteryx Connect';
        insert p;

        License_Product__c lp = (License_Product__c)SmartFactory.createSObject('License_Product__c');
        lp.Product__c = p.Id;
        lp.Quote__c = q1.Id;
        lp.Activation_Id__c = 'test123';
        insert lp;

        Test.startTest();
        License_Product_Update__c lpu = (License_Product_Update__c)SmartFactory.createSObject('License_Product_Update__c');
        lpu.Quote__c = q2.Id;
        lpu.License_Product__c = lp.id;
        lpu.Quote_Line__c = ql.Id;
        insert lpu;
        Test.StopTest();

    }

    static testMethod void dellBoomiResendLPUTest() {
        SBQQ__Quote__c q1 = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        insert q1;

        SBQQ__Quote__c q2 = (SBQQ__Quote__c)SmartFactory.createSObject('SBQQ__Quote__c');
        insert q2;

        SBQQ.TriggerControl.disable();
        SBQQ__QuoteLine__c ql = (SBQQ__QuoteLine__c)SmartFactory.createSObject('SBQQ__QuoteLine__c');
        ql.SBQQ__Quote__c = q2.Id;
        ql.SBQQ__Quantity__c = 5;
        insert ql;
        SBQQ.TriggerControl.enable();


        Product2 p = (Product2)SmartFactory.createSObject('Product2');
        p.Family = 'Alteryx Software';
        p.Name = 'Alteryx Connect';
        insert p;

        License_Product__c lp = (License_Product__c)SmartFactory.createSObject('License_Product__c');
        lp.Product__c = p.Id;
        lp.Quote__c = q1.Id;
        lp.Activation_Id__c = 'test123';
        insert lp;


        License_Product_Update__c lpu = (License_Product_Update__c)SmartFactory.createSObject('License_Product_Update__c');
        lpu.Quote__c = q2.Id;
        lpu.License_Product__c = lp.id;
        lpu.Quote_Line__c = ql.Id;
        lpu.Update_Success__c = false;
        insert lpu;

        Test.StartTest();
        q2.Resend_To_Boomi__c = true;
        update q2;
        Test.stopTest();

    }

    // Eddie Wong
    // 09/23/2020
    // W-006329
    // Test method for SheerID LP sync to Boomi

    static testMethod void dellBoomiResendSheerIDLPTest() {

        Product2 p = (Product2)SmartFactory.createSObject('Product2');
        p.Family = 'Alteryx Software';
        p.Name = 'Alteryx Designer';
        p.ProductCode = 'TestProdCode';
        insert p;

        Id pricebookId = Test.getStandardPricebookId();

        pw_ccpro__CountryObject__c billToCountry = OrgWideTestUtil.createCountryCurrency(true, pricebookId);

        Account a = (Account)SmartFactory.createSObject('Account');
        a.BillingStreet = '1 acc';
        a.BillingCity = 'Irvine';
        a.BillingState = 'California';
        a.BillingPostalCode = '91111';
        a.BillingCountry = 'USA';
        a.ShippingStreet = '1 acc';
        a.ShippingCity = 'Irvine';
        a.ShippingState = 'California';
        a.ShippingPostalCode = '91111';
        a.ShippingCountry = 'USA';
        a.Name = 'test Account';
        a.pw_ccpro__BillingCountryLookup__c = billToCountry.Id;
        a.pw_ccpro__ShippingCountryLookup__c = billToCountry.Id;
        insert a;

        Order_Group__c og = (Order_Group__c)SmartFactory.createSObject('Order_Group__c');
        og.Account__c = a.Id;
        insert og;

        Contact c = (Contact)SmartFactory.createSObject('Contact');
        c.MailingStreet = '123 street';
        c.MailingCity = 'gotham';
        c.MailingState = 'Chicago';
        c.MailingCountry = 'USA';
        c.MailingPostalCode = '91220';
        c.Email = 'test@email.com';
        c.phone = '1233334444';
        c.FirstName = 'testfirst';
        c.LastName = 'testlast';
        c.SheerID_Verification_ID__c = 'testid123';
        c.pw_ccpro__MailingCountryLookup__c = billToCountry.Id;
        insert c;


        License_Administrator__c la = (License_Administrator__c)SmartFactory.createSObject('License_Administrator__c');
        la.SheerID__c = true;
        la.Contact__c = c.Id;
        la.Account__c = a.Id;
        la.Order_Group__c = og.Id;
        insert la;

        License_Product__c lp = (License_Product__c)SmartFactory.createSObject('License_Product__c');
        lp.Product__c = p.Id;
        lp.Licensed_Owner__c = c.Id;
        lp.License_Administrator__c = la.Id;
        lp.Account__c = a.Id;
        lp.Start_Date__c = System.today();
        lp.End_Date__c = System.today().addYears(1);
        lp.Product__c = p.Id;
        lp.License_Group__c = og.Id;
        lp.Quantity__c = 1;
        lp.NoSendToDellBoomi__c = false;
        lp.Resend_To_Boomi__c = false;
        insert lp;

        Test.StartTest();
        System.debug('eddie check  la.SheerID__c 4 = ' + la.SheerID__c);
        lp.Resend_To_Boomi__c = true;
        update lp;
        Test.stopTest();


    }

    static testMethod void dellBoomiSendSheerIDLPTest() {

        /*
        Product2 p = (Product2)SmartFactory.createSObject('Product2');
        p.Family = 'Alteryx Software';
        p.Name = 'Alteryx Designer';
        p.ProductCode = 'TestProdCode';
        insert p;
*/
        Id pricebookId = Test.getStandardPricebookId();

        pw_ccpro__CountryObject__c billToCountry = OrgWideTestUtil.createCountryCurrency(true, pricebookId);

        Account a = (Account)SmartFactory.createSObject('Account');
        a.BillingStreet = '1 acc';
        a.BillingCity = 'Irvine';
        a.BillingState = 'California';
        a.BillingPostalCode = '91111';
        a.BillingCountry = 'USA';
        a.ShippingStreet = '1 acc';
        a.ShippingCity = 'Irvine';
        a.ShippingState = 'California';
        a.ShippingPostalCode = '91111';
        a.ShippingCountry = 'USA';
        a.Name = 'test Account';
        a.pw_ccpro__BillingCountryLookup__c = billToCountry.Id;
        a.pw_ccpro__ShippingCountryLookup__c = billToCountry.Id;
        insert a;


        Order_Group__c og = (Order_Group__c)SmartFactory.createSObject('Order_Group__c');
        og.Account__c = a.Id;
        insert og;

        Contact c = (Contact)SmartFactory.createSObject('Contact');
        c.MailingStreet = '123 street';
        c.MailingCity = 'gotham';
        c.MailingState = 'Chicago';
        c.MailingCountry = 'USA';
        c.MailingPostalCode = '91220';
        c.Email = 'test@email.com';
        c.phone = '1233334444';
        c.FirstName = 'testfirst';
        c.LastName = 'testlast';
        c.SheerID_Verification_ID__c = 'testid123';
        c.pw_ccpro__MailingCountryLookup__c = billToCountry.Id;
        insert c;


        License_Administrator__c la = (License_Administrator__c)SmartFactory.createSObject('License_Administrator__c');
        la.SheerID__c = true;
        la.Contact__c = c.Id;
        la.Account__c = a.Id;
        la.Order_Group__c = og.Id;


        Test.StartTest();
        insert la;
        Test.stopTest();



            }
}