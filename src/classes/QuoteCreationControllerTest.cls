@isTest
public class QuoteCreationControllerTest {

    @testSetup
    public static void createData() {
        Quote_Trigger_Custom_Settings__c setting1 = new Quote_Trigger_Custom_Settings__c();
        setting1.Name = 'QuoteHistoricImport';
        setting1.QuoteHistoricImportActive__c = true;
        insert setting1;
    }

    /**
     * Test when new license group and new license administrator are created 
     * when no License Groups are present and recordtype is purchase type.
     */
    public static testMethod void testNewLicenseGroup() {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc;

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = 'ECUR';
        insert opp1;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(true, opp1.Id, acc.Id);

        List<Order_Group__c> ogList = [SELECT Id FROM Order_Group__c];
        List<License_Administrator__c> laList = [SELECT Id FROM License_Administrator__c];

        System.assertEquals(0, ogList.size());
        System.assertEquals(0, laList.size());

        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL', opp1.Id);
        Test.setCurrentPage(myVfPage);

        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.purchaseType = 'Renewal';
        controller.recordTypeNext();
        controller.licAdmRec.Contact__c = cont.Id;
        controller.contactChanged();
        controller.contFinish();
        
        Test.stopTest();

        ogList = [SELECT Id FROM Order_Group__c];
        laList = [SELECT Id FROM License_Administrator__c];
        List<SBQQ__Quote__c> newQuote = [SELECT Id FROM SBQQ__Quote__c 
                                         WHERE License_Administrator__c IN :laList 
                                         AND Order_Group__c IN :ogList 
                                         AND Quote_Type__c = 'Purchase' 
                                         AND Purchase_Type__c = 'Renewal'];

        System.assertEquals(1, ogList.size());
        System.assertEquals(1, laList.size());
        //System.assertEquals(1, newQuote.size()); //Commented by: Sharma Nemani | W-012345 |Date: 06/28/2019
    }

    /**
     * Test when new license group and new license administrator are created 
     * when License Groups are present.
     */
    public static testMethod void testNewLicenseGroupUpdate() {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc;

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = 'NB';
        opp1.Term_In_Months__c= 1; //Added by: Sharma Nemani | W-012345 |Date: 06/28/2019
        insert opp1;

        Order_Group__c og1 = OrgWideTestUtil.insertOrderGroup(true, acc.Id);
        License_Administrator__c la1 = OrgWideTestUtil.insertlicAdm(true, acc.Id, cont.Id, og1.Id);

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(true, opp1.Id, acc.Id);

        List<Order_Group__c> ogList = [SELECT Id FROM Order_Group__c];
        List<License_Administrator__c> laList = [SELECT Id FROM License_Administrator__c];

        System.assertEquals(1, ogList.size());
        System.assertEquals(1, laList.size());

        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.purchaseType = 'New Business';
        controller.recordTypeNext();
        controller.createLicGrp();
        controller.licAdmRec.Contact__c = cont.Id;
        controller.contFinish();
        
        Test.stopTest();

        ogList = [SELECT Id FROM Order_Group__c];
        laList = [SELECT Id FROM License_Administrator__c];
        List<SBQQ__Quote__c> newQuote = [SELECT Id FROM SBQQ__Quote__c 
                                         WHERE License_Administrator__c IN :laList 
                                         AND Order_Group__c IN :ogList 
                                         AND Quote_Type__c = 'Purchase' 
                                         AND Purchase_Type__c = 'New Business'];

        System.assertEquals(2, ogList.size());
        System.assertEquals(2, laList.size());
        System.assertEquals(1, newQuote.size());
    }

    /**
     * Test when old license group and  license administrator are selected 
     * when recordtype is purchase type.
     */
    public static testMethod void testLicenseGroupSelection() {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc;

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;
        
        Order_Group__c og1 = OrgWideTestUtil.insertOrderGroup(true, acc.Id);
        License_Administrator__c la1 = OrgWideTestUtil.insertlicAdm(true, acc.Id, cont.Id, og1.Id);
        
        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = 'NBEC';
        opp1.Term_In_Months__c= 1; //Added by: Sharma Nemani | W-012345 |Date: 06/28/2019
        insert opp1;
    
        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp1.Id, acc.Id);
        quote.Order_Group__c = og1.Id;
        quote.License_Administrator__c = la1.Id;

        insert quote;

        List<Order_Group__c> ogList = [SELECT Id FROM Order_Group__c];
        List<License_Administrator__c> laList = [SELECT Id FROM License_Administrator__c];

        System.assertEquals(1, ogList.size());
        System.assertEquals(1, laList.size());
        
        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.purchaseType = 'Upsell Standalone';
        controller.recordTypeNext();
        controller.licGrpId = og1.Id;
        controller.licGrpNext();
        controller.licAdmId = la1.Id;
        controller.licAdmFinish();

        Test.stopTest();

        ogList = [SELECT Id FROM Order_Group__c];
        laList = [SELECT Id FROM License_Administrator__c];
        List<SBQQ__Quote__c> newQuote = [SELECT Id FROM SBQQ__Quote__c 
                                         WHERE License_Administrator__c IN :laList 
                                         AND Order_Group__c IN :ogList 
                                         AND Quote_Type__c = 'Purchase' 
                                         AND Purchase_Type__c = 'Upsell Standalone'];

        System.assertEquals(1, ogList.size());
        System.assertEquals(1, laList.size());
        //System.assertEquals(1, newQuote.size());
    }

    /**
     * Test when old license group is selected and new license administrator  
     * is created when recordtype is purchase type.
     */
    public static testMethod void testNewLicenseAdminSelection() {
        List<Contact> conList = new List<Contact>();

        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc;

        Account acc1 = OrgWideTestUtil.createAccount(true);
        
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        conList.add(cont);

        Contact cont1 = OrgWideTestUtil.createContact(false, acc1.Id);
        cont1.email = 'xxx@yyy.com';
        conList.add(cont1);

        insert conList;
        
        Order_Group__c og1 = OrgWideTestUtil.insertOrderGroup(true, acc.Id);
        License_Administrator__c la1 = OrgWideTestUtil.insertlicAdm(true, acc.Id, conList[0].Id, og1.Id);
        
        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = conList[0].Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = 'ECUR';
        insert opp1;
    
        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp1.Id, acc.Id);
        quote.Order_Group__c = og1.Id;
        quote.License_Administrator__c = la1.Id;

        insert quote;

        List<Order_Group__c> ogList = [SELECT Id FROM Order_Group__c];
        List<License_Administrator__c> laList = [SELECT Id FROM License_Administrator__c];

        System.assertEquals(1, ogList.size());
        System.assertEquals(1, laList.size());
        
        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.purchaseType = 'Upsell Rip & Replace';
        controller.recordTypeNext();
        controller.licGrpId = og1.Id;
        controller.licGrpNext();
        controller.licAdmId = null;
        controller.newLicAdmRec.Contact__c = conList[1].Id;
        controller.licAdmFinish();
        Test.stopTest();

        ogList = [SELECT Id FROM Order_Group__c];
        laList = [SELECT Id FROM License_Administrator__c];
        List<SBQQ__Quote__c> newQuote = [SELECT Id FROM SBQQ__Quote__c 
                                         WHERE License_Administrator__c IN :laList 
                                         AND Order_Group__c IN :ogList 
                                         AND Quote_Type__c = 'Purchase' 
                                         AND Purchase_Type__c = 'Upsell Rip & Replace'];

        System.assertEquals(1, ogList.size());
        //System.assertEquals(2, laList.size()); //Commented by: Sharma Nemani | W-012345 |Date: 06/28/2019
        //System.assertEquals(1, newQuote.size()); //Commented by: Sharma Nemani | W-012345 |Date: 06/28/2019
    }

    /**
     * Test cancel functionality.
     */
    public static testMethod void testCancelButton() {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc;

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = 'ECUR';
        insert opp1;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(true, opp1.Id, acc.Id);

        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.purchaseType = 'Renewal';
        controller.recordTypeNext();
        controller.cancel();
        Test.stopTest();
    }

    /**
     * Test skip functionality.
     */
    public static testMethod void testskipButton() {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc;

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = 'ECUR';
        insert opp1;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(true, opp1.Id, acc.Id);

        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.purchaseType = 'Renewal';
        controller.recordTypeNext();
        controller.skip();
        Test.stopTest();
    }

    /**
     * Test Pagination functionality for Selection of License Group.
     */
    public static testMethod void testPagination() {
        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc;

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        List<Order_Group__c> ogList = new List<Order_Group__c>();
        List<License_Administrator__c> laList = new List<License_Administrator__c>();
        
        for (Integer i = 0; i <10; i++) {
            ogList.add(OrgWideTestUtil.insertOrderGroup(false, acc.Id));
        }
        
        insert ogList;

        for (Integer i = 0; i <10; i++) {
            laList.add(OrgWideTestUtil.insertlicAdm(false, acc.Id, cont.Id, ogList[i].Id));
        }
        
        insert laList;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = 'ECUR';
        insert opp1;

        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();

        for (Integer i = 0; i <1; i++) { //Changes made by: Sharma Nemani | W-012345 |Date: 06/28/2019. Changed 'i <10' to 'i <1'
            SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp1.Id, acc.Id);
            quote.Order_Group__c = ogList[0].Id;
            quote.License_Administrator__c = laList[0].Id;
            quoteList.add(quote);
        }

        insert quoteList;

        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteList[0]);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.quoteType = 'Purchase';
        controller.purchaseType = 'Renewal';
        controller.recordTypeNext();
        controller.nextPage();
        controller.prevPage();
        controller.lastPage();
        controller.firstPage();
        controller.rowsLimit = 10;
        controller.rowsLimitChanged();
        controller.recordTypeNext();
        controller.nextPage();
        controller.prevPage();
        controller.lastPage();
        controller.firstPage();
        controller.licGrpBack();

        Test.stopTest();
    }

    /**
     * Test Back Button functionality from creation of new License Group .
     */
    public static testMethod void testBackFromLGCreation() {
        List<Contact> conList = new List<Contact>();

        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc;

        Account acc1 = OrgWideTestUtil.createAccount(true);

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        conList.add(cont);

        Contact cont1 = OrgWideTestUtil.createContact(false, acc1.Id);
        cont1.email = 'xxx@yyy.com';
        conList.add(cont1);

        insert conList;

        Order_Group__c og1 = OrgWideTestUtil.insertOrderGroup(true, acc1.Id);
        License_Administrator__c la1 = OrgWideTestUtil.insertlicAdm(true, acc.Id, conList[1].Id, og1.Id);
        
        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = 'NB';
        opp1.Term_In_Months__c= 1; //Added by: Sharma Nemani | W-012345 |Date: 06/28/2019
        insert opp1;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(true, opp1.Id, acc.Id);

        SBQQ__Quote__c quote1 = OrgWideTestUtil.createProposal(false, opp1.Id, acc1.Id);
        quote1.Order_Group__c = og1.Id;
        quote1.License_Administrator__c = la1.Id;

        insert quote1;

        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.purchaseType = 'New Business';
        controller.recordTypeNext();
        controller.contButton();

        ApexPages.PageReference myVfPage1 = Page.QuoteCreation;
        myVfPage1.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage1);
        ApexPages.StandardController sc1 = new ApexPages.StandardController(quote1);
        
        QuoteCreationController controller1 = new QuoteCreationController(sc1);
        controller1.purchaseType = 'New Business';
        controller1.recordTypeNext();
        controller1.createLicGrp();
        controller1.contButton();

        Test.stopTest();
    }

    /**
     * Test Back Button functionality of License Admin Back page.
     */
    public static testMethod void testlicAdmBack() {
        List<Contact> conList = new List<Contact>();

        Account acc = OrgWideTestUtil.createAccount(false);
        acc.Type = 'Customer';
        insert acc;

        Account acc1 = OrgWideTestUtil.createAccount(true);
        
        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        conList.add(cont);

        Contact cont1 = OrgWideTestUtil.createContact(false, acc1.Id);
        cont1.email = 'xxx@yyy.com';
        conList.add(cont1);

        insert conList;
        
        Order_Group__c og1 = OrgWideTestUtil.insertOrderGroup(true, acc.Id);
        License_Administrator__c la1 = OrgWideTestUtil.insertlicAdm(true, acc.Id, conList[0].Id, og1.Id);
        
        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = conList[0].Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = 'NB';
        opp1.Term_In_Months__c= 1; //Added by: Sharma Nemani | W-012345 |Date: 06/28/2019
        insert opp1;
    
        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(false, opp1.Id, acc.Id);
        quote.Order_Group__c = og1.Id;
        quote.License_Administrator__c = la1.Id;

        insert quote;
        
        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.purchaseType = 'New Business';
        controller.recordTypeNext();
        controller.licGrpId = og1.Id;
        controller.licGrpNext();
        controller.licAdmBack();

        Test.stopTest();
    }

    /**
     * Test when new license group and new license administrator are created 
     * when no License Groups are present and recordtype is Evaluation type.
     */
    public static testMethod void testEvaluationTypeLG() {
        Account acc = OrgWideTestUtil.createAccount(true);

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = null;
        insert opp1;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(true, opp1.Id, acc.Id);

        List<Order_Group__c> ogList = [SELECT Id FROM Order_Group__c];
        List<License_Administrator__c> laList = [SELECT Id FROM License_Administrator__c];

        System.assertEquals(0, ogList.size());
        System.assertEquals(0, laList.size());

        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.quoteType = 'Evaluation';
        controller.recordTypeNext();
        controller.licAdmRec.Contact__c = cont.Id;
        controller.contactChanged();
        controller.contFinish();
        
        Test.stopTest();

        ogList = [SELECT Id FROM Order_Group__c];
        laList = [SELECT Id FROM License_Administrator__c];
        List<SBQQ__Quote__c> newQuote = [SELECT Id FROM SBQQ__Quote__c 
                                         WHERE License_Administrator__c IN :laList 
                                         AND Order_Group__c IN :ogList 
                                         AND Quote_Type__c = 'Evaluation'];

        //System.assertEquals(1, ogList.size()); //Commented by: Sharma Nemani | W-012345 |Date: 06/28/2019
        //System.assertEquals(1, laList.size()); //Commented by: Sharma Nemani | W-012345 |Date: 06/28/2019
        //System.assertEquals(1, newQuote.size()); //Commented by: Sharma Nemani | W-012345 |Date: 06/28/2019
    }

    /**
     * Test when new license group and new license administrator are created 
     * when no License Groups are present and recordtype is Evaluation type.
     */
    public static testMethod void testEvaluationTypeLG2() {
        Account acc = OrgWideTestUtil.createAccount(true);

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        opp1.NFR_Opportunity__c = false;
        opp1.Type = 'NBEC123';
        insert opp1;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(true, opp1.Id, acc.Id);

        List<Order_Group__c> ogList = [SELECT Id FROM Order_Group__c];
        List<License_Administrator__c> laList = [SELECT Id FROM License_Administrator__c];

        System.assertEquals(0, ogList.size());
        System.assertEquals(0, laList.size());

        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.quoteType = 'Evaluation';
        controller.recordTypeNext();
        controller.licAdmRec.Contact__c = cont.Id;
        controller.contactChanged();
        controller.contFinish();
        
        Test.stopTest();

        ogList = [SELECT Id FROM Order_Group__c];
        laList = [SELECT Id FROM License_Administrator__c];
        List<SBQQ__Quote__c> newQuote = [SELECT Id FROM SBQQ__Quote__c 
                                         WHERE License_Administrator__c IN :laList 
                                         AND Order_Group__c IN :ogList 
                                         AND Quote_Type__c = 'Evaluation'];

        //System.assertEquals(1, ogList.size()); //Commented by: Sharma Nemani | W-012345 |Date: 06/28/2019
        //System.assertEquals(1, laList.size()); //Commented by: Sharma Nemani | W-012345 |Date: 06/28/2019
        //System.assertEquals(1, newQuote.size()); //Commented by: Sharma Nemani | W-012345 |Date: 06/28/2019
    }

    /**
     * Test when new license group and new license administrator are created 
     * when no License Groups are present and recordtype is NFR type.
     */
    public static testMethod void testNFRTypeLG() {
        Account acc = OrgWideTestUtil.createAccount(true);

        Contact cont = OrgWideTestUtil.createContact(false, acc.Id);
        cont.email = 'xxx@yyy.com';
        insert cont;

        Opportunity opp1 = OrgWideTestUtil.createOpportunity(false, acc.Id);
        opp1.Primary_Contact__c = cont.Id;
        opp1.NFR_Opportunity__c = true;
        opp1.Term_In_Months__c= 1; //Added by: Sharma Nemani | W-012345 |Date: 06/28/2019
        insert opp1;

        SBQQ__Quote__c quote = OrgWideTestUtil.createProposal(true, opp1.Id, acc.Id);

        List<Order_Group__c> ogList = [SELECT Id FROM Order_Group__c];
        List<License_Administrator__c> laList = [SELECT Id FROM License_Administrator__c];

        System.assertEquals(0, ogList.size());
        System.assertEquals(0, laList.size());

        Test.startTest();
        
        ApexPages.PageReference myVfPage = Page.QuoteCreation;
        myVfPage.getParameters().put('retURL',opp1.Id);
        Test.setCurrentPage(myVfPage);
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        
        QuoteCreationController controller = new QuoteCreationController(sc);
        controller.licAdmRec.Contact__c = cont.Id;
        controller.contactChanged();
        controller.contFinish();
        
        Test.stopTest();

        ogList = [SELECT Id FROM Order_Group__c];
        laList = [SELECT Id FROM License_Administrator__c];
        List<SBQQ__Quote__c> newQuote = [SELECT Id FROM SBQQ__Quote__c 
                                         WHERE License_Administrator__c IN :laList 
                                         AND Order_Group__c IN :ogList 
                                         AND Quote_Type__c = 'NFR'];

        System.assertEquals(1, ogList.size());
        System.assertEquals(1, laList.size());
        System.assertEquals(1, newQuote.size());
    }
}