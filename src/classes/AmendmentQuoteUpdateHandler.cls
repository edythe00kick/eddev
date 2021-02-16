/**
 * Created by ewong on 7/14/2020.
 */

public with sharing class AmendmentQuoteUpdateHandler {
    public static void onAfterInsert(List<Amendment_Quote_Update_Event__e> newTriggerAC) {

        System.debug('In checking recursionhandler iscontractamendexecuted = ' + Recursionhandler.IsContractAmendExecuted );
        Recursionhandler.IsContractAmendExecuted    = true;
        System.debug('inside AmendmentQuoteUpdateHandler');
        Set<Id> oppIds = new Set<Id>();
        Set<Id> conIds = new Set<Id>();
        Set<Id> quoteIds = new Set<Id>();

        for (Amendment_Quote_Update_Event__e amendQuote : newTriggerAC) {
            oppIds.add(Id.valueOf(amendQuote.Opportunity_Id__c));
            conIds.add(Id.valueOf(amendQuote.Contract_Id__c));
            quoteIds.add(Id.valueOf(amendQuote.Quote_Id__c));
        }

        System.debug('In oppIds' + oppIds);
        System.debug('In conIds' + conIds);
        System.debug('In quoteIds' + quoteIds);

        if (!quoteIds.isEmpty()) {
            AmendmentQuoteUpdateGateway.updateAmendmentQuote(conIds, quoteIds);
        }

        if (!oppIds.isEmpty()) {
            System.debug('eddie inside AmendmentQuoteUpdateHandler updateOppToRemovePrimaryQuote');
            AmendmentQuoteUpdateGateway.updateOppToRemovePrimaryQuote(oppIds);
        }

        if (!oppIds.isEmpty()) {
            System.debug('eddie inside deleteamendmentopp handler');
            AmendmentQuoteUpdateGateway.deleteAmendmentOpp(oppIds);
        }



    }
}