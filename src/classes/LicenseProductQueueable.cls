/**
 * Created by ewong on 9/17/2020.
 * W-005569
 * To create License Product for SheerID
 * Test Class - DellBoomiTest
 */

public without sharing class LicenseProductQueueable implements Queueable {

    public Map<Id, License_Administrator__c> lAIdToLAMap;

    public LicenseProductQueueable(Map<Id, License_Administrator__c> lAIdToLAMap) {
        this.lAIdToLAMap = lAIdToLAMap;
    }

    public void execute(QueueableContext context) {

        System.debug('inside LicenseProductQueueable = ' + lAIdToLAMap.keySet());

        Map<Id, License_Administrator__c> newLAIdToLAMap = new Map<Id, License_Administrator__c>([SELECT Id,Account__c,Contact__c,Order_Group__c
                                                                                                    FROM License_Administrator__c
                                                                                                    WHERE ID IN :lAIdToLAMap.keySet()]);

        List<License_Product__c> licProductToInsert = new List<License_Product__c>();

        if(!newLAIdToLAMap.isEmpty()) {
            for (License_Administrator__c licAdmin : newLAIdToLAMap.values()) {
                License_Product__c lp = new License_Product__c();
                lp.Account__c = licAdmin.Account__c;
                lp.Start_Date__c = System.today();
                lp.End_Date__c = System.today().addDays(-1).addYears(1);
                lp.Name__c = 'Alteryx Designer';
                lp.License_Group__c = licAdmin.Order_Group__c;
                lp.Licensed_Owner__c = licAdmin.Contact__c;
                lp.License_Administrator__c = licAdmin.Id;
                lp.Product__c = Label.AlteryxDesignerID;
                lp.Quantity__c = 1;
                lp.RecordTypeId = Schema.SObjectType.License_Product__c.getRecordTypeInfosByName().get('AFG License Product').getRecordTypeId();
                lp.NoSendToDellBoomi__c = true;
                licProductToInsert.add(lp);
            }
        }

        try {
            if(!licProductToInsert.isEmpty()) {
                System.debug('inside inserting new LP = ' + licProductToInsert);
                insert licProductToInsert;
            }

        } catch (Exception e) {
            System.debug(e.getMessage());
        }

    }

}