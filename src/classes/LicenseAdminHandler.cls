/**
 * Created by ewong on 9/17/2020.
 */

public class LicenseAdminHandler {

    private boolean myIsExecuting = false;
    private integer BatchSize = 0;
    public String currentEvent;
    public list<License_Administrator__c> LicenseAdminToGet;

    public LicenseAdminHandler(boolean isExecuting, integer size, List<License_Administrator__c> new_val) {

    }

    //Eddie Wong || W-005569 || 09/23/2020 || To create License Product for SheerID
    public void onAfterInsert(Map<id, License_Administrator__c> mapNew) {
        System.debug('**Eddie**: In Handler OnAfterInsert ');

        Set<Id> licAdminSet = new Set<Id>();
        Map<Id, License_Administrator__c> lAIdToLAMap = new Map<Id, License_Administrator__c>();

        for (License_Administrator__c licAdmin : mapNew.values()) {
            if (licAdmin.SheerID__c == true) {
                licAdminSet.add(licAdmin.Id);
                lAIdToLAMap.put(licAdmin.Id, licAdmin);
            }
        }

        if (!lAIdToLAMap.isEmpty()) {
            System.debug('eddie check inside license admin handler queueable call = ' + lAIdToLAMap);
            LicenseProductQueueable executelicProdQueueable = new LicenseProductQueueable(lAIdToLAMap);
            ID jobID = System.enqueueJob(executelicProdQueueable);

        }


    }
}