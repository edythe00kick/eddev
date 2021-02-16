/*
 * Trigger Name - QuoteHistoricImportTrigger
 * Trigger for the Quote object
 *
 * @author - Eddie Wong
 * Date - 6/11/2019
 * Purpose - The purpose of this trigger is to clone attachment from proposal to quote AFTER a quote is updated.
 */

trigger QuoteHistoricImportTrigger on SBQQ__Quote__c (after update) {

    /*
    Sergio Flores
    Commenting out this class, no longer needed post CPQ go live 
    07/09/2019
    QuoteHistoricImportHandler handler = new QuoteHistoricImportHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isUpdate && Trigger.isAfter) handler.OnAfterUpdate(trigger.oldMap, trigger.newMap);*/

}