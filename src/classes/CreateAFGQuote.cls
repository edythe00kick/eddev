/* Author: Sharma Nemani | W-012645
 * Date: 07/19/2019
 * Description: This class is used in "Create AFG Quote" button. This class creates an Opportunity and
 * License Group if there's no License Admin and finally creates a Quote.
*/
global class CreateAFGQuote {
    webservice static String createOpportunity(Id contactId){
        Contact con  = [select id, AccountId, Name, Account.Name from contact where Id =:contactId];
        profile pf = [select id,Name from profile where Id =:UserInfo.getProfileId()];
        // savepoint Added by: Sharma Nemani | W-012645 | Date: 08/07/2019
        savepoint sp = database.setsavepoint();
        if(Test.isRunningTest() || pf.Name == 'Alteryx - Academic Liaison' || pf.Name == 'System Administrator'){
            Opportunity opp = new Opportunity();
            opp.Name = con.Account.Name+' - '+con.Name+' - '+'AFG';
            opp.AccountId = con.AccountId;
            opp.ContactId = con.Id;
            opp.Type  = 'NB';
            opp.Stagename = '0 - Discovery';
            opp.CurrencyIsoCode = 'USD';
            if(Test.isRunningTest()){
                opp.Pricebook2Id = Test.getStandardPricebookId();
            }else{
                opp.Pricebook2Id = [select id from Pricebook2 where Name = 'Standard Price Book'].Id;
            }

            opp.SBQQ__QuotePricebookId__c  = opp.Pricebook2Id;
            opp.CloseDate = system.Today();
            opp.AFG_Opportunity__c  = true;
            opp.RecordTypeId = [select id from RecordType where developername = 'Alteryx_Record_Type'].Id;

            try{
                insert opp;
                List<License_Administrator__c> lstLA = [select id from License_Administrator__c where contact__c =:contactId];
                if(lstLA.size() > 0){
                    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
                    baseUrl= baseUrl+'/apex/QuoteCreation?opprId='+opp.id+'&sfdc.override=1';
                    System.debug('eddie check baseUrl = ' + baseUrl);
                    return baseUrl;
                }else{
                    return createLALGAndQuote(contactId,opp.Id,con.Account.Name+' - '+con.Name);

                }

            }catch(Exception ee){
                database.rollback(sp); //Added by: Sharma Nemani | W-012645 | Date: 08/07/2019
                return ee.getMessage();
            }
        }else{
            return 'Not a valid user';
        }
    }
    /*
    * @Name Eddie Wong
    * @Work W-006358
    * @Date 11/16/2020
    * @Description Create AFG Quote lightning web component button
    */
    @AuraEnabled
    webservice static String createAFGOpportunity(String recordId){
        System.debug('inside createAFGOpportunity = ' + recordId);
        Contact con  = [select id, AccountId, Name, Account.Name from contact where Id =:recordId];
        profile pf = [select id,Name from profile where Id =:UserInfo.getProfileId()];

        System.debug('check con and pf = ' + con + ' ' + pf);
        // savepoint Added by: Sharma Nemani | W-012645 | Date: 08/07/2019
        savepoint sp = database.setsavepoint();
        if(Test.isRunningTest() || pf.Name == 'Alteryx - Academic Liaison' || pf.Name == 'System Administrator'){
            System.debug('inside isRunningTest');
            Opportunity opp = new Opportunity();
            opp.Name = con.Account.Name+' - '+con.Name+' - '+'AFG';
            opp.AccountId = con.AccountId;
            opp.ContactId = con.Id;
            opp.Type  = 'NB';
            opp.Stagename = '0 - Discovery';
            opp.CurrencyIsoCode = 'USD';
            if(Test.isRunningTest()){
                System.debug('inside if running test');
                opp.Pricebook2Id = Test.getStandardPricebookId();
            }else{
                opp.Pricebook2Id = [select id from Pricebook2 where Name = 'Standard Price Book'].Id;
            }

            opp.SBQQ__QuotePricebookId__c  = opp.Pricebook2Id;
            opp.CloseDate = system.Today();
            opp.AFG_Opportunity__c  = true;
            opp.RecordTypeId = [select id from RecordType where developername = 'Alteryx_Record_Type'].Id;

            try{
                insert opp;
                List<License_Administrator__c> lstLA = [select id from License_Administrator__c where contact__c =:recordId];
                System.debug('check lstLA = ' + lstLA);
                if(lstLA.size() > 0){
                    String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
                    baseUrl= baseUrl+'/apex/QuoteCreation?opprId='+opp.id+'&sfdc.override=1';
                    System.debug('eddie check baseURL = ' + baseUrl);
                    return baseUrl;
                }else{
                    System.debug('eddie in createLALGAndQuote');
                    return createLALGAndQuote(recordId,opp.Id,con.Account.Name+' - '+con.Name);
                }

            }catch(Exception ee){
                database.rollback(sp); //Added by: Sharma Nemani | W-012645 | Date: 08/07/2019
                return ee.getMessage();
            }
        }else{
            return 'Not a valid user';
        }
    }


    public static String  createLALGAndQuote(Id contactId,Id oppId,String ogName){

        Contact con = [select id,Order_Group__c,AccountId from contact where Id =:contactId];
        System.debug('eddie in createLALGAndQuote = ' + con + ' ' + contactId + ' ' + oppId + ' ' + ogName);

        License_Administrator__c  la = new License_Administrator__c();
        la.Contact__c = contactId;
        la.Account__c = con.AccountId;
        insert la;

        Order_Group__c  og = new Order_Group__c();
        og.License_Group_Name__c = ogName;
        og.Account__c = con.AccountId;
        og.License_Administrator__c = la.Id;
        insert og;

        License_Administrator__c laUpdate = [select id from License_Administrator__c where Id =:la.Id];
        laUpdate.Order_Group__c = og.Id;
        update laUpdate;

        con.Order_Group__c = og.id;
        update con;
        SBQQ__Quote__c sbq = new SBQQ__Quote__c();
        sbq.SBQQ__Opportunity2__c  = oppId;
        sbq.License_Administrator__c = la.Id;
        sbq.Order_Group__c  = og.Id;
        sbq.Quote_Type__c = 'AFG';
        sbq.RecordTypeId = [select id from recordType where developername = 'Draft_Simple'].Id;
        sbq.SBQQ__SubscriptionTerm__c  = 12;
        sbq.SBQQ__StartDate__c = System.today();
        insert sbq;

        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        System.debug('eddie check baseUrl = ' + baseUrl);

        return baseUrl+'/'+sbq.Id;

    }


}