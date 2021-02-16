@isTest
public class OSCPQ_TestFactory {
    public static Product2 createBasicRenewableProduct(integer counter, boolean insertFlag){
        Product2 prod = new Product2(
                 Name = 'Simple Renewable Product ' + counter,
                 SBQQ__QuantityEditable__c = true,
                 isActive = true,
                 ProductCode = 'SimpleRenewalProd' + counter,
                 SBQQ__DefaultQuantity__c = 1.0,
                 SBQQ__PricingMethod__c = 'List',
                 SBQQ__SubscriptionPricing__c = 'Fixed Price',
                 SBQQ__SubscriptionTerm__c = 12,
                 SBQQ__SubscriptionType__c = 'Renewable',
                 SBQQ__PriceEditable__c = true,
            	 SBQQ__ChargeType__c = 'Recurring',
                 SBQQ__BillingFrequency__c = 'Annual',
            	 SBQQ__BillingType__c = 'Advance'
             );
        
        if(insertFlag){
            insert prod;
        }
        
        return prod;
    }
    
   public static Product2 createBasicAssetProduct(integer counter, boolean insertFlag){
        Product2 prod = new Product2(
                Name = 'Simple Asset Product ' + counter,
                SBQQ__QuantityEditable__c = true,
                isActive = true,
                ProductCode = 'SimpleAssetProd' + counter,
                SBQQ__DefaultQuantity__c = 1.0,
                SBQQ__PricingMethod__c = 'List',
                SBQQ__SubscriptionPricing__c = 'Fixed Price',
                SBQQ__SubscriptionTerm__c = 12,
                SBQQ__SubscriptionType__c = 'One-Time',
                SBQQ__AssetAmendmentBehavior__c = 'Allow Refund',
                SBQQ__AssetConversion__c = 'One per quote line',
                SBQQ__PriceEditable__c = true,
            	SBQQ__ChargeType__c = 'One-Time'
             );
        
       if(insertFlag){
            insert prod;
        }
       
        return prod;
    }
    
    public static List<PricebookEntry> createPBEntries(List<Product2> products, boolean insertFlag){
        Id pricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> pbEntries = new List<PricebookEntry>();
        for(Product2 prod : products){
            pbEntries.add(new PricebookEntry(
                Pricebook2Id = pricebookId,
                Product2Id = prod.Id,
                UnitPrice = 100.00,
                IsActive = true
            ));
        }
        
        if(insertFlag){
            insert pbEntries;
        }
        
        return pbEntries;
    }
    
    public static Account createSingleAccount(boolean insertFlag){
        Account a = new Account(Name = 'testAcct',
                                SBQQ__AssetQuantitiesCombined__c = true,
                                SBQQ__CoTermedContractsCombined__c = false,
                                SBQQ__ContractCoTermination__c = '',
                                SBQQ__CoTerminationEvent__c = '',
                                SBQQ__IgnoreParentContractedPrices__c = false,
                                SBQQ__PreserveBundle__c = true,
                                SBQQ__RenewalModel__c = 'Contract Based',
                               	SBQQ__RenewalPricingMethod__c = 'Uplift',
                                
                               	BillingCountry = 'United States',
                                BillingStreet = '1060 W Addison St',
                                BillingCity = 'Chicago',
                                BillingState = 'IL',
                                BillingPostalCode = '60613',
                                Managed_Partner__c = true
                               );
        
        if(insertFlag){
            insert a;
        }
        
        return a;
    }

    public static List<Account> createMultipleAccount(boolean insertFlag, integer numberOfAccounts){
        List<Account> lAccounts = new List<Account>();
        for (Integer i = 0; i < numberOfAccounts; i++){
            Account acc = new Account();
            acc.Name = 'OWTU Account' + i;
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
            acc.Type = 'Customer';
            lAccounts.add(acc);
        }

        if(insertFlag && !lAccounts.isEmpty()){
            insert lAccounts;
        }

        return lAccounts;
    }
    
    public static Contact createSingleContact(Account a, boolean insertFlag){
        Contact c = new Contact(LastName = 'Tester',
                                AccountId = a.Id
                               );
        
        if(insertFlag){
            insert c;
        }
        
        return c;
    }
    
    public static Opportunity createSingleOpp(Account a, boolean insertFlag){
        Opportunity newOpp = new Opportunity(
                Name = 'Oppty for ' + a.Name,
                AccountId = a.Id,
                CloseDate = Date.today(),
                Pricebook2Id = Test.getStandardPricebookId(),
            	SBQQ__QuotePricebookId__c = Test.getStandardPricebookId(),
            	StageName = 'Prospecting'
            );
        
        if(insertFlag){
            insert newOpp;
        }
        
        return newOpp;
    }

    public static List<Opportunity> createMultipleOpps(List<Account> lAccounts, boolean insertFlag, String oppType){
        List<Opportunity> newOppList = new List<Opportunity>();
        for (Integer i = 0; i < lAccounts.size(); i++){
            Opportunity o = new Opportunity();
            o.Name = 'Oppty for ' + lAccounts.get(i).Name;
            o.AccountId = lAccounts.get(i).Id;
            o.CloseDate = Date.today();
            o.Pricebook2Id = Test.getStandardPricebookId();
            o.SBQQ__QuotePricebookId__c = Test.getStandardPricebookId();
            o.StageName = '0 - Discovery';
            o.Type = oppType;
            newOppList.add(o);
        }

        if(!newOppList.isEmpty() && insertFlag){
            insert newOppList;
        }

        return newOppList;
    }
    
    public static Contract createSingleContract(Account a, boolean insertFlag){
        Contract c = new Contract(AccountId = a.Id,
                                  StartDate = Date.today(),
                                  ContractTerm = 12,
                                  SBQQ__RenewalTerm__c = 12,
                                  SBQQ__RenewalForecast__c = false,
                                  SBQQ__RenewalQuoted__c = false,
                                  RecordTypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId()
                                 );
        
        if(insertFlag){
            insert c;
        }
        
        return c;
    }
    
    public static SBQQ__Subscription__c createSingleSubscription(Contract c, Product2 p, boolean insertFlag){
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(SBQQ__Quantity__c = 1,
                                                              SBQQ__Product__c = p.Id,
                                                              SBQQ__SubscriptionStartDate__c = Date.today(),
                                                              SBQQ__SubscriptionEndDate__c = Date.today() + 364,
                                                              SBQQ__Contract__c = c.id,
                                                              SBQQ__Account__c = c.AccountId
                                                             );
        
        if(insertFlag){
            insert sub;
        }
        
        return sub;
    }

    public static SBQQ__Quote__c createSingleQuote(Account a, Opportunity o, boolean isPrimary, boolean insertFlag){
        SBQQ__Quote__c q = new SBQQ__Quote__c(SBQQ__Opportunity2__c = o.Id,
                                                SBQQ__SalesRep__c = UserInfo.getUserId(), //Name: Chris Salgado Date: 10/22/19 Purpose: W-013453
                                                SBQQ__Account__c = a.Id,
                                                SBQQ__PaymentTerms__c = 'Net 30',
                                                SBQQ__BillingFrequency__c = 'Annual',
                                                SBQQ__StartDate__c = Date.today(),
                                                SBQQ__SubscriptionTerm__c = 12,
                                                SBQQ__Primary__c = true,
                                                SBQQ__Partner__c = null,
                                                SBQQ__PricebookId__c = Test.getStandardPricebookId(),
                                                SBQQ__PriceBook__c = Test.getStandardPricebookId(),
                                                Partner_Role__c = '',
                                                SBQQ__Distributor__c = null,
                                                Distributor_Role__c = '',
                                                Influencer_Account__c = null,
                                                Influencer_Role__c = ''
                                            );
        
        if(insertFlag){
            insert q;
        }
        
        return q;
    }

    public static List<SBQQ__Quote__c> createMultipleQuotes(List<Account> lAccounts, List<Opportunity> lOpps, boolean isPrimary, boolean insertFlag, String purchaseType, String quoteType, String quoteStatus){
        List<SBQQ__Quote__c> lQuotes = new List<SBQQ__Quote__c>();
        for(Integer i = 0; i < lOpps.size(); i++){
            SBQQ__Quote__c q = new SBQQ__Quote__c();

            q.SBQQ__Opportunity2__c = lOpps.get(i).Id;
            q.SBQQ__SalesRep__c = UserInfo.getUserId();
            q.SBQQ__Account__c = lAccounts.get(i).Id;
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
            q.Purchase_Type__c = purchaseType;
            q.Quote_Type__c = quoteType;
            //q.SBQQ__Status__c = quoteStatus;
            lQuotes.add(q);
        }

        if(!lQuotes.isEmpty() && insertFlag){
            insert lQuotes;
        }

        return lQuotes;
    }


    public static SBQQ__QuoteDocument__c createSingleQuoteDoc(SBQQ__Quote__c q, Opportunity o, boolean insertFlag){
        SBQQ__QuoteDocument__c doc = new SBQQ__QuoteDocument__c(SBQQ__Quote__c = q.Id,
                                                               SBQQ__Opportunity__c = o.Id,
                                                               SBQQ__Version__c = 1,
                                                               SBQQ__SignatureStatus__c = 'Pending'
                                                               );
        
        if(insertFlag){
            insert doc;
        }
        
        return doc;
    }
    
    public static Order createSingleOrder(Account a, Opportunity o, SBQQ__Quote__c q, boolean insertFlag){
        Order ord = new Order(OpportunityId = o.Id,
                              AccountId = a.Id,
                              SBQQ__Quote__c = q.Id,
                              EffectiveDate = Date.today(),
                              RecordTypeId = Schema.SObjectType.Order.getRecordTypeInfosByDeveloperName().get('CPQ').getRecordTypeId(),
                              Status = 'Draft',
                              SBQQ__Contracted__c = false,
                              SBQQ__PriceCalcStatus__c = 'Not Needed'
                             );

        
        //Check for Billing. If present, then add necessary billing fields that may interfere with baseline CPQ processes
        List<PackageLicense> pkgLicenses = [SELECT CreatedDate,ExpirationDate,Id,Status FROM PackageLicense WHERE NamespacePrefix = 'blng'];
        if(!pkgLicenses.isempty()){
            ord.put('blng__BillingDayOfMonth__c', '1');
        }

        if(insertFlag){
            insert ord;
        }
        
        return ord;
    }
    
    public static OrderItem createSingleOrderitem(Order ord, Product2 prod, PricebookEntry pbe, boolean insertflag){
        OrderItem oi = new OrderItem(OrderId = ord.Id,
                                    Product2Id = prod.Id,
                                    PricebookEntryId = pbe.Id,
                                    Quantity = 1,
                                    SBQQ__ChargeType__c = 'Recurring',
                                    SBQQ__BillingFrequency__c = 'Annual',
                                    SBQQ__BillingType__c = 'Advance',
                                    UnitPrice = 100.0,
                                    SBQQ__DefaultSubscriptionTerm__c = 12);
        if(insertFlag){
            insert oi;
        }
        
        return oi;
    }

    public static SBQQ__QuoteLineGroup__c createSingleQuoteLineGroup(Account acct, SBQQ__Quote__c quote, boolean insertFlag) {
        SBQQ__QuoteLineGroup__c qlGroup = new SBQQ__QuoteLineGroup__c();
        qlGroup.SBQQ__Quote__c = quote.Id;
        qlGroup.SBQQ__Account__c = acct.Id;
        qlGroup.SBQQ__Number__c = 1;
        qlGroup.Name = 'TestGroup';

        if(insertFlag) {
            insert qlGroup;
        }

        return qlGroup;
    }

    public static SBQQ__QuoteLine__c createSingleQuoteLine(SBQQ__Quote__c quote, Product2 prod, boolean insertFlag) {
        SBQQ__QuoteLine__c ql = new SBQQ__QuoteLine__c();
        ql.SBQQ__Quote__c = quote.Id;
        ql.SBQQ__Product__c = prod.Id;
        ql.SBQQ__Number__c = 1;
        

        if(insertFlag) {
            insert ql;
        }

        return ql;
    }
    
    public static User createSingleUser(String firstName, String lastName, boolean insertFlag) {
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = firstName + lastName, 
                          Email= firstName + lastName + '@testingOrg.com', 
            			  EmailEncodingKey='UTF-8', 
                          FirstName = firstName,
                          LastName = lastName, 
                          LanguageLocaleKey='en_US', 
            			  LocaleSidKey='en_US', 
                          ProfileId = p.Id, 
            			  TimeZoneSidKey='America/Los_Angeles', 
                          UserName= firstName + lastName + Math.random() + '@testingOrg.com'
                         );
        system.debug(u.UserName);
        
        if(insertFlag) {
            insert u;
        }
        
        return u;
    }
}