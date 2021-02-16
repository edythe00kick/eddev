/**
 * Created by ewong on 6/25/2020.
 * Eddie Wong
 * 07/07/2020
 * W-004987
 */

public class LicenseProductUpdateHandler {

    private boolean myIsExecuting = false;
    private integer BatchSize = 0;
    public String currentEvent;
    public list<License_Product_Update__c> LicenseProductUpdatesToGet;



    //** METHODS **
    public LicenseProductUpdateHandler(boolean isExecuting, integer size, List<License_Product_Update__c> new_val){
        System.debug('**Eddie**: In Handler Constructor ');
        myIsExecuting = isExecuting;

        //Query the License Products that triggered this process
        LicenseProductUpdatesToGet = [Select Id, Dell_Boomi_In_Progress__c,Dell_Boomi_Received__c,Entitlement_ID__c,FNO_Received__c,
                                    Integration_Error__c,License_Product__c,Quote__c,Quote_Line__c,Send_Entitlement_Email__c
                                    FROM License_Product_Update__c
                                    Where Id in : new_val];

        BatchSize = size;
        currentEvent = 'constructor';
    }

    public void onAfterInsert(Map<id, License_Product_Update__c> mapNew){
        System.debug('**Eddie**: In Handler OnAfterInsert ');
        currentEvent = 'OnAfterInsert';

        Set<Id> licProUpSet = new Set<Id>();
        Set<Id> licProSet = new Set<Id>();

        for(License_Product_Update__c licProdUp : mapNew.values()){
            if (licProdUp.Dell_Boomi_Received__c == null) {
                licProUpSet.add(licProdUp.Id);
                licProSet.add(licProdUp.License_Product__c);
            }
        }

        if(!licProUpSet.isEmpty()){
            //Map<Id, License_Product_Update__c> licProdUpdateMap = mapKAVFromCKAIds(LicProdUpIdToLicProdUpMap);
            DellBoomi.sendLPUToBoomi(licProUpSet,licProSet);
            //DellBoomiKnowledge.BoardRequest(ckasForBoard, kavMap.keySet());
        }

        /* Send License Product Update to Dell Boomi for Flexera
        DellBoomi sendCall = new DellBoomi(LicProdUpIdToLicProdUpMap, currentEvent);
        sendCall.sendLPUToBoomi();*/
    }

    //Eddie Wong
    // 09/16/2020
    // W-005994
    // To resend License Product Update to Boomi
    public void onBeforeUpdate(Map<id, License_Product_Update__c> mapOld, Map<id, License_Product_Update__c> mapNew, List<License_Product_Update__c> newLPUList){
        System.debug('**Eddie**: In Handler OnBeforeUpdate mapOld = ' + mapOld);
        System.debug('**Eddie**: In Handler OnBeforeUpdate mapNew = ' + mapNew);

        Set<Id> licProUpSet = new Set<Id>();
        Set<Id> licProSet = new Set<Id>();

        for(License_Product_Update__c licProdUp : mapNew.values()){
            System.debug('eddie check Recursionhandler.IsLPUToBoomiExecuted ' + Recursionhandler.IsLPUToBoomiExecuted);

            if(licProdUp.Resend_To_Boomi__c == true && RecursionHandler.IsLPUToBoomiExecuted == false){
                licProUpSet.add(licProdUp.Id);
                licProSet.add(licProdUp.License_Product__c);
                licProdUp.Resend_To_Boomi__c = false;
                licProdUp.Dell_Boomi_In_Progress__c = true;
            }
        }

        System.debug('eddie check licProdUpSet = ' + licProSet);

        if(!licProUpSet.isEmpty()){
            RecursionHandler.IsLPUToBoomiExecuted = true;
            System.debug('eddie check inside licProdUpSet handler');
            DellBoomi.sendLPUToBoomi(licProUpSet,licProSet);
        }

    }


}