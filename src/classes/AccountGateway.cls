public without sharing class AccountGateway {

    //Chris Salgado
    //Date: 08/14/2019
    //W-012807
    //Stamp the Tax Reg Number on all open Quotes
    public static void updateTaxRegNumOnQuotes(List<Account> accts){
       //Declarations
        List<SBQQ__Quote__c> updateQuotes = new List<SBQQ__Quote__c>();
        Map<Id, String> acctToTaxMap = new Map<Id, String>();
        
        //Map creation
        for(Account acct : accts){
            acctToTaxMap.put(acct.Id, acct.Tax_Reg_Number__c);
        }                
		
        //Query and Loop to make change
		for(SBQQ__Quote__c quo : [SELECT Id, SBQQ__Account__r.Id, Tax_Reg_Number__c FROM SBQQ__Quote__c WHERE SBQQ__Status__c != 'Accepted' AND SBQQ__Primary__c = TRUE AND SBQQ__Opportunity2__c IN
                                  (SELECT Id FROM Opportunity WHERE StageName != '5 - Closed Won' AND Account.Id IN :accts)]){                                      
                                      System.debug('** CSALGADO ** -  Quote: ' + quo.Id);
                                      quo.Tax_Reg_Number__c = acctToTaxMap.get(quo.SBQQ__Account__r.Id);
                                      updateQuotes.add(quo);
                                  }   

        //Update
        if(!updateQuotes.isEmpty()){
            update updateQuotes;
        }        
    }

    //Sergio Flores
    //Date: 11/27/2019
    //W-013601
    public static void syncQuoteAddress(Map<Id, Account> accountIdToAccountMap)
    {
        string Status_To_Sync_Quote_Address = System.Label.Status_To_Sync_Quote_Address;

        Set<String> quoteStatus = new Set<String>();

        for(String s : Status_To_Sync_Quote_Address.Split(',') )
        {
            quoteStatus.add(s);
        }

        //Need to query all open primary quotes where we need to sync the address to
        Map<Id, SBQQ__Quote__c> quoteIdToQuotes = new Map<Id, SBQQ__Quote__c>(
            [Select Id, BillToAccount__c ,SBQQ__ShippingName__c, SBQQ__ShippingStreet__c, SBQQ__ShippingCity__c, 
            SBQQ__ShippingState__c, SBQQ__ShippingPostalCode__c, SBQQ__ShippingCountry__c, SBQQ__PrimaryContact__r.pw_ccpro__MailingCountryLookup__r.Price_Book__c,
            SBQQ__PrimaryContact__r.pw_ccpro__MailingCountryLookup__r.Default_Currency_Standard_Purchase__c,
            SBQQ__PrimaryContact__r.Account.Name, SBQQ__Opportunity2__r.isclosed
            From SBQQ__Quote__C Where BillToAccount__c IN : accountIdToAccountMap.keySet() AND SBQQ__Primary__c = true AND SBQQ__Status__c IN : quoteStatus]);

        if(!quoteIdToQuotes.isEmpty())
        {
            List<SBQQ__Quote__C> quoteAddressToUpdateList = new List<SBQQ__Quote__C>();

            for(SBQQ__Quote__c quote : quoteIdToQuotes.values())
            {
                Account account = accountIdToAccountMap.get(quote.BillToAccount__c);

                if(account !=null && !quote.SBQQ__Opportunity2__r.isclosed)
                {
                    //Updating from the Primary Contact Information
                    system.debug('Inside syncQuoteAddress ' + account);
                    quote.SBQQ__BillingName__c = account.Name;
                    quote.SBQQ__BillingStreet__c = account.BillingStreet;
                    quote.SBQQ__BillingCity__c = account.BillingCity;
                    quote.SBQQ__BillingState__c = account.BillingState;
                    quote.SBQQ__BillingPostalCode__c = account.BillingPostalCode;
                    quote.SBQQ__BillingCountry__c = account.BillingCountry;
                    quoteAddressToUpdateList.add(quote);
                }
            }

            if(!quoteAddressToUpdateList.isEmpty())
            update quoteAddressToUpdateList;
            
        }

    }
}