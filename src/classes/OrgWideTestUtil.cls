@isTest
public class OrgWideTestUtil {
    private static id standard_pricebook_id = Test.getStandardPricebookId(); // Id of Standard Pricebook
    
    // Create Work
    public static Work__c createWork(boolean do_insert, Id prodTag) {
        Work__c wrk = new Work__c();
        wrk.Subject__c = 'Test Subject';
        wrk.Product_Tag__c = prodTag;
        if(do_insert) {
            insert wrk;
        }
        return wrk;
    }

    // Create Product Tag
    public static Product_Tag__c createProdTag(boolean do_insert) {
        Product_Tag__c prodTag = new Product_Tag__c();
        prodTag.Name = 'Test Product Tag';
        prodTag.Team__c = 'CRM Team';
        if(do_insert) {
            insert prodTag;
        }
        return prodTag;
    }
    
    // Create Product
    public static Product2 createProduct(boolean do_insert) {
        Product2 prod = new Product2();
        prod.Name = 'OWTU Product';
        prod.ProductCode = '0101';
        prod.isActive = true;
        if(do_insert) {
            insert prod;
        }
        return prod;
    }
    
    // Create Product Option
    public static SBQQ__ProductOption__c createProductOption(boolean do_insert, Id configuredProduct, Id optionalProduct, Integer num) {
        SBQQ__ProductOption__c prodOption = new SBQQ__ProductOption__c();
        prodOption.SBQQ__ConfiguredSKU__c = configuredProduct;
        prodOption.SBQQ__OptionalSKU__c = optionalProduct;
        prodOption.SBQQ__Number__c = num;
        if(do_insert) {
            insert prodOption;
        }
        return prodOption;
    }
    
    // Create Pricebook Entry
    public static PricebookEntry createPricebookEntry(boolean do_insert, Id product_id, Id pricebook_id) {
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id = pricebook_id;
        pbe.Product2Id = product_id;
        pbe.UnitPrice = 100.00;
        pbe.isActive = true;
        if(do_insert) {
            insert pbe;
        }
        return pbe;
    }
    
    // Create Account
    public static Account createAccount(boolean do_insert) {
        Account acc = new Account();
        acc.Name = 'OWTU Account';
        acc.ShippingCity = 'Los Angeles';
        acc.ShippingCountry = 'United States';
        acc.ShippingState = 'California';
        acc.ShippingStreet = 'test';
        acc.ShippingPostalCode = '90001';
        acc.BillingCity = 'Los Angeles';
        acc.BillingCountry = 'United States';
        acc.BillingState = 'California';
        acc.BillingStreet = 'test';
        acc.BillingPostalCode = '90001';
        if(do_insert) {
            insert acc;
        }
        return acc;
    }
    
    // Create Partner Account
    
    public static Account createPartnerAccount(boolean do_insert) {
        Account acc = new Account();
        acc.Name = 'OWTU Account';
        acc.RecordTypeId = Account.sObjectType.getDescribe()
                .getRecordTypeInfosByName()
                .get('Alteryx Partner Account Record Type')
                .getRecordTypeId();
        acc.ShippingCity = 'Panchkula';
        acc.ShippingCountry = 'India';
        acc.ShippingState = 'Haryana';
        acc.ShippingStreet = 'test';
        acc.ShippingPostalCode = '45129';
        if(do_insert) {
            insert acc;
        }
        return acc;
    }
    
    // Create Contact
    public static Contact createContact(boolean do_insert, id account_id) {
        Contact con = new Contact();
        con.FirstName = 'OWTU';
        con.LastName = 'Contact';
        con.Email = 'contact@owtu.com';
        con.Phone = '1234567890';
        con.AccountId = account_id;
        con.MailingCity = 'Los Angeles';
        con.MailingCountry = 'United States';
        con.MailingState = 'California';
        con.MailingStreet = 'test';
        con.MailingPostalCode = '90001';
        if(do_insert) {
            insert con;
        }
        return con;
    }
    
    // Create Opportunity
    public static Opportunity createOpportunity(boolean do_insert, id account_id) {
        Opportunity opp = new Opportunity();
        opp.Name = 'OWTU Opportunity';
        opp.AccountId = account_id;
        opp.type = 'NB';
        opp.StageName = '0 - Discovery';
        opp.CloseDate = Date.today() + 2; 
        opp.Term_In_Months__c = 12; //Sergio Flores 6/24/2019 Adding mandatory field on creation
        if(do_insert) {
            insert opp;
        }
        return opp;
    }

    //Eddie add
    public static Contract createSingleContract(Account a, boolean do_insert, Opportunity opp){
        Contract c = new Contract();
        c.AccountId = a.Id;
        c.StartDate = Date.today();
        c.ContractTerm = 12;
        c.SBQQ__RenewalTerm__c = 12;
        c.SBQQ__RenewalForecast__c = false;
        c.SBQQ__RenewalQuoted__c = false;
        c.SBQQ__RenewalOpportunity__c = opp.Id;
        c.RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId();
        if(do_insert){
            insert c;
        }
        return c;
    }

    public static SBQQ__Subscription__c createSingleSubscription(Contract c, Product2 p, boolean do_insert){
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Quantity__c = 1;
        sub.SBQQ__Product__c = p.Id;
        sub.SBQQ__SubscriptionStartDate__c = Date.today();
        sub.SBQQ__SubscriptionEndDate__c = Date.today() + 364;
        sub.SBQQ__Contract__c = c.id;
        sub.SBQQ__Account__c = c.AccountId;
        if(do_insert){
            insert sub;
        }
        return sub;
    }

    //Eddie add
    public static Related_Contract__c createRelatedContract(boolean do_insert, Opportunity opp, Contract con){
        Related_Contract__c rc = new Related_Contract__c();
        rc.Opportunity__c = opp.Id;
        rc.Contract__c = con.Id;
        rc.Name = opp.Id;
        rc.ExternalId__c = opp.Id + '123';
        if(do_insert){
            insert rc;
        }
        return rc;
    }

    public static SBQQ__Quote__c createSingleQuote(Account a, Opportunity o, boolean isPrimary, boolean do_insert){
        SBQQ__Quote__c q = new SBQQ__Quote__c();
        q.SBQQ__Opportunity2__c = o.Id;
        q.SBQQ__SalesRep__c = UserInfo.getUserId(); //Name: Chris Salgado Date: 10/22/19 Purpose: W-013453
        q.SBQQ__Account__c = a.Id;
        q.SBQQ__PaymentTerms__c = 'Net 30';
        q.SBQQ__BillingFrequency__c = 'Annual';
        q.SBQQ__StartDate__c = Date.today();
        q.SBQQ__SubscriptionTerm__c = 12;
        q.SBQQ__Primary__c = true;
        q.SBQQ__Partner__c = null;
        q.SBQQ__PricebookId__c = Test.getStandardPricebookId();
        q.SBQQ__PriceBook__c = Test.getStandardPricebookId();
        q.Partner_Role__c = '';
        q.SBQQ__Distributor__c = null;
        q.Distributor_Role__c = '';
        q.Influencer_Account__c = null;
        q.Influencer_Role__c = '';
        if(do_insert){
            insert q;
        }
        return q;
    }
    
    // Create OpportunityContactRole
    public static OpportunityContactRole createOCR(Boolean doInsert, Id oppId, Id contId) {
        OpportunityContactRole ocr = new OpportunityContactRole();
        ocr.OpportunityId = oppId;
        ocr.ContactId = contId;
        ocr.isPrimary = true;
        if (doInsert) {
            insert ocr;
        }
        return ocr;
    } 

    // Create Closed Won Opportunity
        public static Opportunity createClosedOpportunity(boolean do_insert, id account_id) {
        Opportunity opp = new Opportunity();
        opp.Name = 'OWTU Opportunity';
        opp.type = 'NB';
        opp.AccountId = account_id;
        opp.StageName = '7 - Closed Won';
        opp.CloseDate = Date.today() + 2;
        if(do_insert) {
            insert opp;
        }
        return opp;
    }
    
    public static SBQQ__Quote__c createProposal(boolean do_insert, Id opp_Id, Id account_Id){
        SBQQ__Quote__c proposal = new SBQQ__Quote__c();
        proposal.SBQQ__Account__c = account_Id;
        proposal.SBQQ__Opportunity2__c = opp_Id;
        proposal.SBQQ__Type__c = 'Quote';
        proposal.SBQQ__Status__c = 'Draft';
        proposal.Quote_Type__c = 'Purchase';
        proposal.Purchase_Type__c = 'New Business';
        
        if(do_insert){
            insert proposal;
        }
        
        return proposal;
    }

    // Create Quote Line Item
    public static SBQQ__QuoteLine__c createQuoteLineItem(boolean do_insert,id product_id,id quote_id) 
        {
        SBQQ__QuoteLine__c qli = new SBQQ__QuoteLine__c();
        qli.SBQQ__Quote__c = quote_id;
        qli.SBQQ__Product__c = product_id;
        qli.SBQQ__Quantity__c = 1.00;
        qli.SBQQ__ListPrice__c = 100.00;
        qli.CurrencyISOCode = 'USD';
        qli.SBQQ__Number__c = 1;
        if(do_insert) {
            insert qli;
        }
        return qli;
    }
    
  /*JPH 20190401
    // Create Proposal
    public static Apttus_Proposal__Proposal__c createProposal(boolean do_insert, id opp_id, id account_id) {
        Apttus_Proposal__Proposal__c prop = new Apttus_Proposal__Proposal__c();
        prop.Apttus_Proposal__Opportunity__c = opp_id;
        prop.Apttus_Proposal__Account__c = account_id;
        prop.RecordTypeId = Apttus_Proposal__Proposal__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Purchased').getRecordTypeId();
        prop.Apttus_QPApprov__Approval_Status__c = 'Pending Approval';
        prop.Subscription_Start_Date__c = Date.today();
        prop.Subscription_End_Date__c = Date.today().addYears(1);
        prop.Purchase_Type__c = 'New Business';
        prop.Commitments_on_Future_Discounts__c = false;
        prop.Early_Termination_With_Fees__c = true;
        prop.Apttus_Proposal__Discount_Percent__c = 0;
        prop.Most_Favored_Nation__c = false;
        prop.Non_Standard_Clause__c = false;
        prop.Non_Standard_Services_Transactions__c = false;
        prop.Paid_Upfront_13_Months__c = 'No';
        prop.Apttus_Proposal__Payment_Term__c = 'Net 30';
        prop.Competitor__c = false;
        prop.Early_Termination_Without_Fees__c = false;
        prop.Adoption_Term__c = 12;
        prop.Legacy_Support_Exception__c = false;
        prop.Software_Discount__c = 0;
        prop.Right_to_Install_on_Two_Machines__c = false;
        prop.Services_Discount__c = 0;
        prop.Change_to_Subscription_Start_or_End_Date__c = false;
        
        if(do_insert) {
            insert prop;
        }
        
        return prop;
    }*/
    
    // Create Opportunity Product
    public static OpportunityLineItem createOpportunityLineItem(boolean do_insert, id opportunity_id, integer quantity,
            id pricebook_entry_id, decimal pricebook_entry_unitprice) {
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opportunity_id;
        oli.Quantity = quantity;
        oli.PricebookEntryId = pricebook_entry_id;
        oli.TotalPrice = quantity * pricebook_entry_unitprice;
        if(do_insert) {
            insert oli;
        }
        return oli;
    }

/* JPH 20190401
    // Create Proposal Line Item
    public static Apttus_Proposal__Proposal_Line_Item__c
            createProposalLineItem(boolean do_insert,
                                   id product_id,
                                   id quote_id) {
        Apttus_Proposal__Proposal_Line_Item__c pli
            = new Apttus_Proposal__Proposal_Line_Item__c();
        pli.Apttus_Proposal__Proposal__c = quote_id;
        pli.Apttus_Proposal__Product__c = product_id;
        pli.Apttus_QPConfig__LineType__c = 'Product/Service';
        pli.Product_Family__c = 'Alteryx Software';
        pli.Apttus_QPConfig__Quantity2__c = 1.00;
        pli.Apttus_QPConfig__NetPrice__c = 100.00;
        pli.Apttus_QPConfig__ListPrice__c = 100.00;
        pli.CurrencyISOCode = 'USD';
        if(do_insert) {
            insert pli;
        }
        return pli;
    }
    */
    // Create Proposal Subscription Schedules
    public static Billing_Schedule__c createSchedule(boolean do_insert,
                                                     Id attached_to) {
        Billing_Schedule__c schedule = new Billing_Schedule__c();
        schedule.Amount__c = 100.00;
        //schedule.Quote_Proposal__c = attached_to;
        if(do_insert) {
            insert schedule;
        }
        return schedule;
    }

    // Create attachment
    public static Attachment createAttachment(boolean do_insert, Id record_id) {
        Attachment attach = new Attachment();
        attach.Name = 'OWTU_Attachment';
        Blob bodyBlob = Blob.valueOf('Unit Test Attachment Body');
        attach.body = bodyBlob;
        attach.parentId = record_id;
        if(do_insert) {
            insert attach;
        }
        return attach;
    }

/*JPH 20190401
    // Create apttus agreement
    public static Apttus__APTS_Agreement__c createApttusAgreement(
            boolean do_insert, Id account_id) {
        Apttus__APTS_Agreement__c agrm = new Apttus__APTS_Agreement__c();
        agrm.Name = 'OWTU_Apttus_Agreement';
        agrm.Apttus__Account__c = account_id;
        if(do_insert) {
            insert agrm;
        }
        return agrm;
    }*/
    
    // Create campaign
    public static Campaign createCampaign(boolean do_insert) {
        // Initialization
        setCampaignMemberStatusDefault();
        
        Campaign cm = new Campaign();
        cm.Name = 'OWTU Campaign';
        cm.IsActive = true;
        cm.Status = 'Planned';
        cm.Program_Name__c = 'OWTU Campaign';
        cm.Region__c = 'Global';
        cm.Fiscal_Year__c = '2014';
        cm.Quarter__c = 'Q1';
        cm.Campaign_Tactic__c = '3rd Party Email';
        cm.Campaign_Offer__c = 'Analyst Report';
        cm.Vendor_Sponsored__c = 'Yes';
        cm.StartDate = Date.today();
        cm.EndDate = Date.today() + 2;
        if(do_insert) {
            insert cm;
        }
       
        return cm;
    }
    
    /* 
     * Initialize custom setting named "Campaign Member Status Default".
     * It will be used while creating campaign.
     */
    public static void setCampaignMemberStatusDefault() {
        Map<String, CampaignMemberStatusCustom__c> cm_status_map
            = CampaignMemberStatusCustom__c.getAll();
        Set<String> statuses = new Set<String>();
        
        for(CampaignMemberStatusCustom__c cms_rec : cm_status_map.values()) {
            statuses.add(cms_rec.Name.trim().toLowerCase());
        }
        
        List<CampaignMemberStatusCustom__c> cmscs
            = new List<CampaignMemberStatusCustom__c>();
        
        if(!statuses.contains('registered')) {
            cmscs.add(new CampaignMemberStatusCustom__c(Name = 'Registered'));
        }
        if(!statuses.contains('partner registered')) {
            cmscs.add(new CampaignMemberStatusCustom__c(Name = 'Partner Registered'));
        }
        if(!statuses.contains('waitlisted')) {
            cmscs.add(new CampaignMemberStatusCustom__c(Name = 'Waitlisted'));
        }
        if(!statuses.contains('workshop queue')) {
            cmscs.add(new CampaignMemberStatusCustom__c(Name = 'Workshop Queue'));
        }
        
        insert cmscs;
    }
    
    // Create Lead
    public static Lead createLead(boolean do_insert) {
        Lead l = new Lead();
        l.FirstName = 'OWTU';
        l.LastName = 'Lead';
        l.Company = 'OWTU Company';
        l.Street = 'Test Street';
        l.City = 'Hollywood';
        l.State = 'Fl';
        l.PostalCode = '88345';
        l.Country = 'United States';
        l.Email = 'leadowtu876@owtu.com';
        l.Phone = '010101';
        if(do_insert) {
            insert l;
        }
        return l;
    }
    
    // Create campaign member
    public static CampaignMember createCampaignMember(boolean do_insert,
            String type,
            Id rec_id,
            Id camp_id,
            String status) {
                
        CampaignMember cm = new CampaignMember();
        if(type == 'lead') {
            cm.LeadId = rec_id;
        } else if(type == 'contact') {
            cm.ContactId = rec_id;
        }
        
        cm.CampaignId = camp_id;
        cm.Status = status;
        
        if(do_insert) {
            insert cm;
        }
        
        return cm;
        
    }
    
    // Get a user with admin permissios
    public static User getUser() {
        User usr;
        
        try {
            usr = [SELECT Id FROM User WHERE isActive = true 
                AND Profile.Name = 'System Administrator' LIMIT 1];
        } catch(QueryException qe) {
            List<User> users;
            users = [SELECT Id, Profile.PermissionsModifyAllData 
                FROM User WHERE IsActive = true LIMIT 1000];
            for(User u : users) {
                if(u.Profile.PermissionsModifyAllData = true){
                    usr = u;
                    break;
                }
            }
        }
        
        return usr;
    }
    
    // Create a case
    public static Case createCase(boolean do_insert, Id ent_id) {
        Case cas = new Case();
        cas.Subject = 'OWTU Test Subject';
        if(ent_id != null) {
            cas.EntitlementId = ent_id;
        }
        if(do_insert) {
            insert cas;
        }
        return cas;
    }
    
    // Create Order Group
    public static Order_Group__c insertOrderGroup(Boolean doInsert, Id accId) {
        Order_Group__c og = new Order_Group__c();
        og.Account__c = accId;
        if (doInsert) {
            insert og;
        }
        return og;
    }
    
    //Create License Admin
    public static License_Administrator__c insertlicAdm(Boolean doInsert,
                                                        Id accId,
                                                        Id contId,
                                                        Id ogId) {
 
        License_Administrator__c licAdm = new License_Administrator__c();
        licAdm.Account__c = accId;
        licAdm.Order_Group__c = ogId;
        licAdm.Contact__c = contId;
        if (doInsert) {
          insert licAdm;
        }
        return licAdm;
    }
    
    // Create Custom Partner
    public static Custom_Partner__c createCustomPartner(Boolean do_insert,
                                                        Id oppId, Id accToId) {

        Custom_Partner__c cp = new Custom_Partner__c();
        cp.OpportunityId__c = oppId;
        cp.AccountToId__c = accToId;
        
        if (do_insert) {
            insert cp;                      
        }
        return cp;
    }
    
    // Create Partner
    public static Partner createPartner(Boolean do_insert, Id oppId, Id accToId,String role, Boolean primary) {

        Partner par = new Partner();
        par.OpportunityId = oppId;
        par.AccountToId = accToId;
        par.Role = role;
        par.IsPrimary = primary;
        if (do_insert) {
            insert par;                      
        }
        return par;
    }

    // Create Portal User
    //Sergio Flores
    //Date: 06/25/2019
    //CPQ Refactoring
    public static User createPortalUser(Boolean doInsert, Id contId) {
        Profile portalProfile = [SELECT Id FROM Profile where Name='Partner Community User custom'];
        User portalUser = new User(
            Username = 'owtu123' + System.now().millisecond() + '@owtu' + System.now().millisecond() + '.com',
            ContactId = contId,
            ProfileId = portalProfile.Id,
            Alias = 'test' + System.now().millisecond(),
            Email = 'owtu123' + System.now().millisecond() + '@owtu' + System.now().millisecond() + '.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'McTesty',
            CommunityNickname = 'test' + System.now().millisecond(),
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            LanguageLocaleKey = 'en_US' 
        );
        
        if (doInsert) {
            insert portalUser;
        }

        return portalUser;
    }

    //Sergio Flores
    //Date: 06/26/2019 
    //Create a country object since we stamp currency on opp from this currency
    public static pw_ccpro__CountryObject__c createCountryCurrency(Boolean doInsert, Id pbId) {
        pw_ccpro__CountryObject__c billToCountry = new pw_ccpro__CountryObject__c(Default_Price_Book_Standard_Purchase__c = 'Standard Price Book',
                                                                                    Default_Currency_Standard_Purchase__c = 'USD',
                                                                                    Price_Book__c = pbId,
                                                                                    Name = 'United States',
                                                                                    pw_ccpro__IsoCode_2__c = 'US',
                                                                                    pw_ccpro__IsoCode_3__c = 'USA',
                                                                                    pw_ccpro__Continent__c = 'North America',
                                                                                    Country_Sales_Territory__c = 'NA',
                                                                                    Subsidiary__c = 'Alteryx, Inc.'
                                                                                );

        
        if(doInsert)
        {
            insert billToCountry;
        }
        return billToCountry;
    }
        
}