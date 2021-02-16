/*------------------------------------------------------------------------+
Alteryx - Enterprise Applications
Purpose: Triggers Contract creation for Activated Orders

Details: Simple schedule class that calls the contract automation batch.

History:
9/10/2019 - Alteryx - Initial Implementation
------------------------------------------------------------------------+*/
global class OSCPQ_ContractAutomation_Schedule implements Schedulable{
    global void execute(SchedulableContext context) {
        String settingsAPIName = 'Default';
        @testVisible CPQ_Setting__mdt settings = OSCPQ_Utils.getContractSettings(settingsAPIName);
        //List<Id> orderIdsToContract = new List<Id>(); //List of all Order Ids that we should contract in a separate transaction

        if(settings.Contracting_GenerationPoint__c == 'Order'){
            System.debug('**CSALGADO** - In Contract Auto Sched');
            Integer contractingLimit = Integer.ValueOf(Label.CPQ_Contract_Creation_Limit);
            Map<Id, Order> queryOrdersMap = new Map<Id, Order>([SELECT Id FROM Order WHERE Status = 'Activated' AND SBQQ__Contracted__c = false LIMIT :contractingLimit]);
            List<Id> orderIdsToContract = new List<Id>(queryOrdersMap.keySet());
            /*for(Order order : [SELECT Id FROM Order WHERE Status = 'Activated' AND SBQQ__Contracted__c = false]){
                orderIdsToContract.add(order.Id);
            }*/

            if(!orderIdsToContract.isEmpty()){
                System.debug('**CSALGADO** - Calling Order Auto Queue');
                OSCPQ_OrderAutomation_Queueable queueJob = new OSCPQ_OrderAutomation_Queueable(orderIdsToContract, settings);
                System.enqueueJob(queueJob);
            }
        }
    }
}