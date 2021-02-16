public with sharing class WiCustomObjectTriggerHelper {

    @TestVisible
    static Set<Id> recordsIdToShareToWISet;

    public static void onAfterInsert() {
        shareToWiRecordList(Trigger.new);
    }

    public static void onAfterUpdate() {
        recordsIdToShareToWISet = wi.WiExternalUtility.filterRecordsToShareToWI(Trigger.oldMap, Trigger.newMap);
        wi.WiExternalUtility.sendRecordsToWI(recordsIdToShareToWISet);
    }

    public static void onAfterDelete() {
        shareToWiRecordList(Trigger.old);
    }

    public static void onAfterUndelete() {
        shareToWiRecordList(Trigger.new);
    }

    private static void shareToWiRecordList(List<SObject> records) {
        recordsIdToShareToWISet = wi.WiExternalUtility.filterRecordsToShareToWI(records);
        wi.WiExternalUtility.sendRecordsToWI(recordsIdToShareToWISet);
    }

}