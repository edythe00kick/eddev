/*
 * Queueable apex class that handles anything on the order
 * that cannot be handled in the same transaction as Activation
 * 	Ex: Contracting off the order
 */
public class OSCPQ_OrderAutomation_Queueable implements Queueable{
	private List<Id> orderIdsToContract; //Using Ids rather than Object as we'll want to requery in case the activation failed
    CPQ_Setting__mdt settings;
    /*
     * Constructor to populate the class's list(s)
     */
    public OSCPQ_OrderAutomation_Queueable(List<Id> contractedOrderIds, CPQ_Setting__mdt cpqSettings){
        orderIdsToContract = contractedOrderIds;
        settings = cpqSettings;
    }
    
    /*
     * Primary method of execution
     */
    public void execute(QueueableContext context){
        if(settings != null){
            //Handle Contracting
            if(!orderIdsToContract.isEmpty() && settings.Contracting_GenerationPoint__c == 'Order'){
                List<Order> orderList = [SELECT Id, SBQQ__Contracted__c FROM Order WHERE Id IN :orderIdsToContract AND Status = 'Activated' AND SBQQ__Contracted__c = false];
                if(!orderList.isEmpty()){
                    for(Order ord : orderList){
                        ord.SBQQ__Contracted__c = true;
                    }
                    
                    
                    Database.SaveResult[] updateList = new Database.SaveResult[]{};
                    try{
                        updateList = Database.update(orderList, false);
                    }
                    finally{ //Log errors as necessary
                        OSCPQ_Utils.createQTCErrorFromDMLSave('CPQ_OrderAutomation_Queueable Failed to activate Orders', //Subject
                                                            'CPQ', //targetPackage
                                                            'Order Automation', //process
                                                            'CPQ_OrderAutomation_Queueable', //classMethodName
                                                            UserInfo.getUserId(), //runningUserId
                                                            updateList, //srList
                                                            false, //createMultipleRecords
                                                            true //performDML
                                                           );
                    }
                }
            }
        }
    }
}