/*
 * Class Name - ContractHistoricImportHandler.
 * Test Class Name - ContractHistoricImportHandler_Test.
 *
 * @author - Eddie Wong
 * Date - 6/19/2019
 * Purpose - This is the handler for "ContractHistoricImportTrigger" trigger and handle the
 * trigger functionality.
 */

public with sharing class ContractHistoricImportHandler {
    // Stores the value of Trigger.isExecuting
    private Boolean myIsExecuting = false;
    // Stores the value of Trigger.size
    private integer batchSize = 0;
    // Additional Transient Variables put here

    /**** Constructor of this class.****/

    public ContractHistoricImportHandler(Boolean isExecuting, Integer size) {
        myIsExecuting = isExecuting;
        batchSize = size;
    }

    /* onAfterUpdate */
    public void OnAfterUpdate(map<id, Contract> mapOld, map<id, Contract> mapNew) {
        AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
        system.debug('alteryxToggleCS : '+ alteryxToggleCS);
    
        if( alteryxToggleCS.ContractHistoricImportTrigger_Active__c )
        {   
            Map<Id, Id> attachMap = new Map<Id, Id>();
            Set<Id> qExtIds = New Set<Id>(); //OSCPQ_External_Id__c
            //Set<Id> qIds = New Set<Id>(); //Ids
            
            for(Contract B : mapNew.values()){
                Contract A = mapOld.get(B.Id);
            
                if(A.Attachment_migration__c != B.Attachment_migration__c && B.Attachment_migration__c == true && B.OSCPQ_External_Id__c != NULL){
                    attachMap.put(B.OSCPQ_External_Id__c, B.Id);
                    qExtIds.add(B.OSCPQ_External_Id__c);
                    //qIds.add(B.Id);
                }
            }
    
             Attachment[] insertAttList = new Attachment[]{};
    
             for(Attachment a : [select name, body, ParentId from Attachment where ParentId in :qExtIds]){
                 system.debug('inside QuoteHistoricImportHandler attachment for loop ' + a);
                 Attachment att = new Attachment(name = a.name, body = a.body, parentid = attachMap.get(a.ParentId));
                 insertAttList.add(att);
             }
    
             if(insertAttList.size() > 0){
                 insert insertAttList;
             }
        }
    }
}