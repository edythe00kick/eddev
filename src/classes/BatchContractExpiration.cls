/*
*Author:Chris Salgado
*Date:05/13/19
*Description:Update Contracts to Expired and the associated Subscriptions
*/
global class BatchContractExpiration implements Database.Batchable<SObject>, Database.Stateful
{
    global Set<Id> accountIdSet;

    global BatchContractExpiration(){
        accountIdSet = new Set<Id>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String query = 'SELECT Id,Name,AccountId,Status,Status_Category__c,StartDate,EndDate ' +
                'FROM Contract ' +
                'WHERE EndDate <= Today AND Status_Category__c=\'In Effect\' AND Status_Category__c!=\'Expired\'';
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Contract> contractList)
    {

        for(Contract c : contractList )
        {
           	
            // c.Status = 'Expired'; Commented By: Sharma Nemani | Date: 06/26/2019
            c.Status = 'Terminated'; //Added By: Sharma Nemani | Date: 06/26/2019
            
            c.Status_Category__c = 'Expired';
            /*if(!accountIdSet.contains(c.Account.Id)){ // Commented By: Sharma Nemani | Date: 06/26/2019
                accountIdSet.add(c.Account.Id);
            }*/
            
            // Added By: Sharma Nemani | Date: 06/26/2019 --> START
 
            if(!accountIdSet.contains(c.AccountId)){
                accountIdSet.add(c.AccountId);
            }
           // Sharma Nemani | Date: 06/26/2019 --> END
        }
        update contractList;
    }
    global void finish(Database.BatchableContext BC)
    {
        List<Account> accountsUpdated = new List<Account>();
        if(accountIdSet.size() > 0 && !accountIdSet.isEmpty()){
            accountsUpdated  = SubscriptionGateway.UpdateAccountWithLicenseProduct(accountIdSet);
            if(accountsUpdated.size() > 0 && !accountsUpdated.isEmpty()){
                try{
                    update accountsUpdated;
                }
                catch(Exception e){
                    System.debug('Exception is==========================>'+e.getMessage());
                }
            }
        }
    }
}