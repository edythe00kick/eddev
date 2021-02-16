/* Author: Sharma Nemani | W-011959
 * Date: 05/27/2019
 * Description: This is the Controller for the QuoteContractExtension Visualforce Page that is used
 * for Rip & Replace.
*/
public class QuoteContractExtensionCtrl {
    public String quoteId{get;set;}
    public List<selectContracts> getContracts{get;set;}
    public String contractNumber{get;set;}
    public String baseUrl{get;set;}
    public boolean allowed{get;set;}
    public QuoteContractExtensionCtrl(ApexPages.StandardController controller){
        allowed = false;
        quoteId = ((SBQQ__Quote__c)controller.getRecord()).id;
        contractNumber = '';
        baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        List<profile> p = [select id,name from profile where Id =:userInfo.getProfileId()]; 
            if(p.size() > 0  && (p[0].name.equalsIgnoreCase('Alteryx - Sales - Deal Desk') || p[0].name.equalsIgnoreCase('system administrator'))){
                allowed = true;
            }
    }
    
    public static List<selectContracts> getContractsOnQuoteToSelect(String quoteId){
        List<selectContracts> lstContracts = new List<selectContracts>();
        SBQQ__Quote__c quote = [select SBQQ__Account__c,SBQQ__Opportunity2__c,SBQQ__StartDate__c   from SBQQ__Quote__c where Id =:quoteId];
        String accId = '';
        if(quote!=null){
            accId = quote.SBQQ__Account__c;
        }
        if(accId == null){
            return lstContracts;
        }
        List<Id> contractId = new List<Id>();
        Map<Id,Related_Contract__c> mapOfRC = new Map<Id,Related_Contract__c>();
        for(Related_Contract__c rc:[select id,Opportunity__c,Contract__c,Contract__r.ContractNumber,Contract__r.Status,Contract__r.EndDate,Contract__r.StartDate,Opportunity__r.AccountId
                                    from Related_Contract__c
                                    where Opportunity__c =:quote.SBQQ__Opportunity2__c
                                    AND Opportunity__r.AccountId =:quote.SBQQ__Account__c]){
            mapOfRC.put(rc.Contract__c,rc);
            contractId.add(rc.Contract__c);
        }

        /*
        Author: Eddie Wong
        Work  : W-004529
        Date  : 03/31/2020
         */
        List<Contract> lstContract = [select id,Name,ContractNumber,Status,EndDate,StartDate,Account.Name
                                      from Contract
                                      where AccountId =:accId
                                      AND EndDate >= :quote.SBQQ__StartDate__c.addMonths(Integer.valueOf(System.Label.Related_Contract_Look_Back_In_Month))];//OR Id IN: contractId

        for(Contract con : lstContract){
            contractId.add(con.Id);
        }
        for(Contract cont : lstContract){
            if(mapOfRC!=null && mapOfRC.containsKey(cont.Id)){
                lstContracts.add(new selectContracts(cont,true));
                mapOfRC.remove(cont.Id);
            }else{
                lstContracts.add(new selectContracts(cont,false));
            }
        }
        List<Contract> lstContractFromSearchedAccounts = [select id,Name,ContractNumber,Status,EndDate,StartDate,Account.Name
                                                          from Contract
                                                          where Id IN: mapOfRC.keyset()];
        for(Contract cont : lstContractFromSearchedAccounts){
            lstContracts.add(new selectContracts(cont,true));
        }
        return lstContracts;
    }
    
    public class selectContracts{
        public Contract contractRecord{get;set;}
        public Boolean selected{get;set;}
        public List<String> listAlreadyAvailableContacts{get;set;}
        public selectContracts(contract contractRecord,Boolean selected){
            this.contractRecord = contractRecord;
            this.selected = selected;
        }
    }
    /*
       Author: Eddie Wong
       Work  : W-004529
       Date  : 03/31/2020
        */
    @RemoteAction
    public static List<Contract> getContracts(String keyWord,List<String> availableContracts,String searchContractsForThisAccount,String quoteId) { //eddie add String quoteId
        String searchKey= '%'+keyWord+'%';
        List<Contract> lstContract = new List<Contract>();
        System.debug('inside remote action getContracts' + quoteId);
        SBQQ__Quote__c quote = [select SBQQ__Account__c,SBQQ__Opportunity2__c,SBQQ__StartDate__c from SBQQ__Quote__c where Id =:quoteId]; //eddie add
        if(String.isBlank(keyWord) && String.isNotBlank(searchContractsForThisAccount)){
            System.debug('eddie inside remoteaction' + '');
            lstContract = [select id,Name,ContractNumber,Status,EndDate,StartDate,Account.Name,SBQQ__Quote__r.SBQQ__StartDate__c
                           from Contract
                           where (ContractNumber like :searchKey OR Name like :searchKey)
                           AND Id NOT IN:availableContracts
                           AND AccountId =: searchContractsForThisAccount
                           AND EndDate >= :quote.SBQQ__StartDate__c.addMonths(Integer.valueOf(System.Label.Related_Contract_Look_Back_In_Month)) limit 10];
        }else if(String.isNotBlank(keyWord)){
            lstContract = [select id,Name,ContractNumber,Status,EndDate,StartDate,Account.Name
                           from Contract
                           where (ContractNumber like :searchKey OR Name like :searchKey)
                           AND Id NOT IN:availableContracts
                           AND EndDate >= :quote.SBQQ__StartDate__c.addMonths(Integer.valueOf(System.Label.Related_Contract_Look_Back_In_Month)) limit 10];
        }
        return lstContract;
    }
    
    @RemoteAction
    public static List<Account> getAccounts(String keyWord) {
        String searchKey= '%'+keyWord+'%';
        List<Account> lstContract = [select id,Name from Account where Name like :searchKey limit 20];
        return lstContract;
    }
    
    @RemoteAction
    public static List<selectContracts> showContracts(String quoteId) { // from quote's Account
        List<selectContracts> lstContract = getContractsOnQuoteToSelect(quoteId);
        return lstContract;
    }
    
    @RemoteAction
    public static String createJunctionObjectRecords(List<String> selectedContractsId,String quoteId) { // from quote's Account
        List<Related_Contract__c> lstJuncctionObject = new List<Related_Contract__c>();
        SBQQ__Quote__c quote = [select SBQQ__Opportunity2__c,SBQQ__Account__c from SBQQ__Quote__c where Id = :quoteId];
        List<Contract> lstContract = [select id,Name,ContractNumber from Contract where AccountId =:quote.SBQQ__Account__c];
        List<String> contractIds = new List<String>();
        for(Contract con : lstContract){
            contractIds.add(con.Id);
        }
        List<Related_Contract__c> lstRC = [select id,Opportunity__c,Contract__c,Opportunity__r.AccountId
                                           from Related_Contract__c
                                           where  Opportunity__c=:quote.SBQQ__Opportunity2__c
                                           AND Opportunity__r.AccountId =:quote.SBQQ__Account__c];
        if(selectedContractsId.size() == 0){
            delete lstRC;
            return quote.SBQQ__Opportunity2__c;
        }
        
        Map<Id,Related_Contract__c> mapOfRC = new Map<Id,Related_Contract__c>();
        if(quote.SBQQ__Opportunity2__c != null){
            for(Related_Contract__c rc:lstRC){
                mapOfRC.put(rc.Contract__c,rc);
            }
            for(String contractId : selectedContractsId){
                Related_Contract__c  rc = new Related_Contract__c();
                rc.Contract__c  = contractId;
                rc.Opportunity__c  = quote.SBQQ__Opportunity2__c;
                rc.ExternalId__c = contractId+quote.SBQQ__Opportunity2__c;
                lstJuncctionObject.add(rc);
                if(mapOfRC!=null && mapOfRC.containskey(contractId)){
                    mapOfRC.remove(contractId);
                }
            }
        }else{
            return 'No Opportunity linked with Quote';
        } 
        try{
            upsert lstJuncctionObject ExternalId__c;
            delete mapOfRC.values();
            return quote.SBQQ__Opportunity2__c;
        }catch(Exception ee){
           return ee.getMessage();
        }
    }
}