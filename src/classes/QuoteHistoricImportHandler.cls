/*
 * Class Name - QuoteHistoricImportHandler.
 * Test Class Name - QuoteHistoricImportHandler_Test.
 *
 * @author - Eddie Wong
 * Date - 6/11/2019
 * Purpose - This is the handler for "QuoteHistoricImportTrigger" trigger and handle the
 * trigger functionality.
 */

public with sharing class QuoteHistoricImportHandler {
    /*Sergio Flores
    Commenting out this class, no longer needed post CPQ go live 
    07/09/2019
    // Stores the value of Trigger.isExecuting
    private Boolean myIsExecuting = false;
    // Stores the value of Trigger.size
    private integer batchSize = 0;
    // Additional Transient Variables put here

    /**** Constructor of this class.****/

    /*public QuoteHistoricImportHandler(Boolean isExecuting, Integer size) {
        myIsExecuting = isExecuting;
        batchSize = size;
    }
    
    /* onAfterUpdate */
    /*public void OnAfterUpdate(map<id, SBQQ__Quote__c> mapOld, map<id, SBQQ__Quote__c> mapNew) {
        AYX_Org_Rules_Toggle__c alteryxToggleCS = AYX_Org_Rules_Toggle__c.getInstance(userinfo.getProfileId());
        system.debug('alteryxToggleCS : '+ alteryxToggleCS);
    
        if( alteryxToggleCS.QuoteHistoricImportTrigger_Active__c )
        {   
            Map<Id, Id> attachMap = new Map<Id, Id>();
            Set<Id> qExtIds = New Set<Id>(); //OSCPQ_External_Id__c
            //Set<Id> qIds = New Set<Id>(); //Ids
            
            for(SBQQ__Quote__c B : mapNew.values()){
                SBQQ__Quote__c A = mapOld.get(B.Id);
            
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
    }*/
    
//}
    

}