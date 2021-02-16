trigger AmendmentQuoteUpdateTrigger on Amendment_Quote_Update_Event__e (after insert) {

    System.debug('In AmendmentQuoteUpdateTrigger ');
    
    if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            System.debug('In AfterInsert trigger');
            AmendmentQuoteUpdateHandler.onAfterInsert(Trigger.new);
        }
    }
}