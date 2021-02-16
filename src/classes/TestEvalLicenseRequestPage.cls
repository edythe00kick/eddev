@isTest
private class TestEvalLicenseRequestPage {
    @isTest
    private static void testScenario1() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = System.label.StageName_B;
        opp.CloseDate = Date.today() + 7;
        opp.AccountId = acc.Id;
        insert opp;
        
        PageReference pageRef = Page.EvalLicenseRequestPage;
        pageRef.getParameters().put('oppId', opp.Id);
        pageRef.getParameters().put('AccountID', acc.Id);
        Test.setCurrentPageReference(pageRef);
        EvalLicenseRequestPageController elrpc = new EvalLicenseRequestPageController(null);
        elrpc.elr.Product_Bundle__c = 'Alteryx Designer Eval';
        elrpc.elr.Contact__c = con.Id;
        elrpc.elr.Expiration_Date__c = Date.today() + 5;
        elrpc.elr.Number_of_Licenses__c = 1;
        elrpc.elr.Ship_Physical_Drive_for_Data__c = 'Yes';
        elrpc.save();
    }
    
    @isTest
    private static void testScenario2() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        //con.AccountId = acc.Id;
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = System.label.StageName_B;
        opp.CloseDate = Date.today() + 7;
        opp.AccountId = acc.Id;
        insert opp;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.contactid = con.id;
        ocr.OpportunityId = opp.id;
        ocr.role='Data Artisan';
        insert ocr;
        
        PageReference pageRef = Page.EvalLicenseRequestPage;
        pageRef.getParameters().put('oppId', opp.Id);
        pageRef.getParameters().put('AccountID', acc.Id);
        Test.setCurrentPageReference(pageRef);
        EvalLicenseRequestPageController elrpc = new EvalLicenseRequestPageController(null);
        elrpc.elr.Product_Bundle__c = 'Alteryx Designer Eval';
        elrpc.elr.Contact__c = con.Id;
        elrpc.elr.Expiration_Date__c = Date.today() + 5;
        elrpc.elr.Number_of_Licenses__c = 1;
        elrpc.elr.Ship_Physical_Drive_for_Data__c = 'Yes';
        elrpc.save();
    }
    
    @isTest
    private static void testScenario3() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = System.label.StageName_B;
        opp.CloseDate = Date.today() + 7;
        opp.AccountId = acc.Id;
        insert opp;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.contactid = con.id;
        ocr.OpportunityId = opp.id;
        ocr.role='Data Artisan';
        insert ocr;
        
        PageReference pageRef = Page.EvalLicenseRequestPage;
        pageRef.getParameters().put('oppId', opp.Id);
        pageRef.getParameters().put('AccountID', acc.Id);
        Test.setCurrentPageReference(pageRef);
        EvalLicenseRequestPageController elrpc = new EvalLicenseRequestPageController(null);
        elrpc.elr.Product_Bundle__c = 'Alteryx Designer Eval';
        elrpc.elr.Contact__c = con.Id;
        elrpc.elr.Expiration_Date__c = Date.today() + 5;
        elrpc.elr.Number_of_Licenses__c = 1;
        elrpc.elr.Ship_Physical_Drive_for_Data__c = 'No';
        elrpc.save();
    }
    
    @isTest
    private static void testScenario4() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = System.label.StageName_B;
        opp.CloseDate = Date.today() + 7;
        opp.AccountId = acc.Id;
        insert opp;
        
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.contactid = con.id;
        ocr.OpportunityId = opp.id;
        ocr.role='Data Artisan';
        insert ocr;
        
        PageReference pageRef = Page.EvalLicenseRequestPage;
        pageRef.getParameters().put('oppId', opp.Id);
        pageRef.getParameters().put('AccountID', acc.Id);
        Test.setCurrentPageReference(pageRef);
        EvalLicenseRequestPageController elrpc = new EvalLicenseRequestPageController(null);
        elrpc.cancel();
    }
    
    @isTest
    private static void testScenario5() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.AccountId = acc.Id;
        insert con;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = System.label.StageName_F;
        opp.CloseDate = Date.today() + 7;
        opp.AccountId = acc.Id;
        insert opp;
        
        PageReference pageRef = Page.EvalLicenseRequestPage;
        pageRef.getParameters().put('oppId', opp.Id);
        pageRef.getParameters().put('AccountID', acc.Id);
        Test.setCurrentPageReference(pageRef);
        EvalLicenseRequestPageController elrpc = new EvalLicenseRequestPageController(null);
    }
}