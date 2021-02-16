/* Created By: Sharma Nemani | W-012241 
 * Date: 06/13/2019
 * Description : This handler class is used in EchoSignAgreementTrigger which will update Quote's status as per 
 * echosign_dev1__SIGN_Agreement__c Object's Status.
 */

public class EchoSignAgreementHandler { 
    public static void afterUpdateInsert(Map<Id,echosign_dev1__SIGN_Agreement__c> mapSIGN_AgreementNew,Map<Id,echosign_dev1__SIGN_Agreement__c> mapSIGN_AgreementOld,Boolean isInsert){
        Map<String,String> mapQuotestatus = new  Map<String,String>();
        
        List<Id> signAgreementIds = new List<Id>();
        
        List<echosign_dev1__SIGN_Agreement__c> lstAgreement = [select id,echosign_dev1__Status__c,CPQ_Quote__c,CPQ_Quote__r.SBQQ__Status__c from echosign_dev1__SIGN_Agreement__c where Id IN : mapSIGN_AgreementNew.keyset() AND CPQ_Quote__r.SBQQ__Status__c != 'Accepted' AND CPQ_Quote__c !=null]; //'CPQ_Quote__r.SBQQ__Status__c != 'Accepted' Added by: Sharma Nemani | W-013490 | Case: 00307966 | Date: 10/29/2019 
        
        for(echosign_dev1__SIGN_Agreement__c sa : lstAgreement){ // mapSIGN_AgreementNew.values()
            //Checking if the Agreement Status is not 'Cancelled / Declined' and a Quote exists in CPQ_Quote__c
            //and mapping the EchoSign Agreement' Status value to Quote's Status Value.
            // Out for Signature : Out for Signature, Waiting for Counter-Signature : Waiting for Alteryx Counter Signature, Signed : Fully Signed
            if((sa.echosign_dev1__Status__c != 'Cancelled / Declined' && sa.CPQ_Quote__c !=null) && ((!isInsert && sa.echosign_dev1__Status__c != mapSIGN_AgreementOld.get(sa.Id).echosign_dev1__Status__c) || isInsert)){
                if(sa.echosign_dev1__Status__c == 'Out for Signature'){
                     mapQuotestatus.put(sa.CPQ_Quote__c,'Out for Signature');
                }else if(sa.echosign_dev1__Status__c == 'Waiting for Counter-Signature'){
                    mapQuotestatus.put(sa.CPQ_Quote__c,'Waiting for Alteryx Counter Signature');
                }else if(sa.echosign_dev1__Status__c == 'Signed'){
                    mapQuotestatus.put(sa.CPQ_Quote__c,'Fully Signed');
                    
                }
            }
        }
        // To stamp the Date & Time on the "Signed Date & Time" field in Quote when the "Status" of EchoSign Agreement 
        // is changed to 'Signed'.
        if(mapQuotestatus.size() > 0){
            List<SBQQ__Quote__c> lstQuote = [select id,SBQQ__Status__c,Signed_Date_Time__c from SBQQ__Quote__c where Id IN:mapQuotestatus.keyset()];
            for(SBQQ__Quote__c sbQuote : lstQuote){
                sbQuote.SBQQ__Status__c = mapQuotestatus.get(sbQuote.Id);
                if(sbQuote.SBQQ__Status__c == 'Fully Signed'){
                    sbQuote.Signed_Date_Time__c = system.now();
                }
            }
            update lstQuote;
        }
    }
}