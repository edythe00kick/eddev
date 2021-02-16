/*
 * Trigger Name - ContractHistoricImportTrigger
 * Trigger for the Contract object
 *
 * @author - Eddie Wong
 * Date - 6/19/2019
 * Purpose - The purpose of this trigger is to clone attachment from Agreement to Contract AFTER contract is updated.
 */

trigger ContractHistoricImportTrigger on Contract (after update) {
  
    ContractHistoricImportHandler handler = new ContractHistoricImportHandler(Trigger.isExecuting, Trigger.size);

    if(Trigger.isUpdate && Trigger.isAfter) handler.OnAfterUpdate(trigger.oldMap, trigger.newMap);
}