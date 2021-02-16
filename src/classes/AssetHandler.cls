/**
 * Created by csalgado on 10/10/2019.
 */

public with sharing class AssetHandler {
    /*List<Asset> newAssets;

    public AssetHandler(List<Asset> newList)
    {
        this.newAssets = newList;
    }*/

    public void onBeforeInsert(List<Asset> newAssets)
    {
        System.debug('In AssetHandler onBeforeInsert');
        Set<Id> queryQuoteLineIds = new Set<Id>();
        //Map<Id,Id> quoteLineToContractMap = new Map<Id,Id>();

        for(Asset ast : newAssets)
        {
            System.debug('Quote Line: ' + ast.SBQQ__QuoteLine__c);
            if(ast.SBQQ__QuoteLine__c != null)
            {
                queryQuoteLineIds.add(ast.SBQQ__QuoteLine__c);
            }
            else
            {
                queryQuoteLineIds.add(ast.SBQQ__LatestQuoteLine__c);
            }
        }

		
         System.debug('Query Set Size: ' + queryQuoteLineIds.size());
         Map<Id,SBQQ__QuoteLine__c> quoteLineToContractMap = new Map<Id,SBQQ__QuoteLine__c>([SELECT Id, SBQQ__Quote__r.Related_Contract__c
                                                                                            FROM SBQQ__QuoteLine__c
                                                                                            WHERE Id IN :queryQuoteLineIds]);
        
        /*for(SBQQ__QuoteLine__c ql : [SELECT Id, SBQQ__Quote__r.Related_Contract__c
                                                        FROM SBQQ__QuoteLine__c
                                                        WHERE Id IN :queryQuoteLineIds])
        {            
            System.debug('Contract: ' + ql.SBQQ__Quote__r.Related_Contract__c);
            quoteLineToContractMap.put(ql.Id, ql.SBQQ__Quote__r.Related_Contract__c);
        }*/

        for(Asset asse : newAssets)
        {
            if(quoteLineToContractMap.containsKey(asse.SBQQ__QuoteLine__c))
            {
            	asse.Contract__c = quoteLineToContractMap.get(asse.SBQQ__QuoteLine__c).SBQQ__Quote__r.Related_Contract__c;
            }
        }
    }
}