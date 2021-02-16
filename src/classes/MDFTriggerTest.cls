@isTest
private class MDFTriggerTest {

    static wi.wiWebhookTestHelper MOCK_SUCCESS_RESPONSE = new wi.wiWebhookTestHelper(200, 'OK');
    static Integer BULK_SIZE = 200;
    static Integer HTTP_SUCCESS_CODE = 200;

    @testSetup
    static void setupTestData() {
        List<MDF__c> tRecords = new List<MDF__c>();
        tRecords.addAll(createTestRecords(BULK_SIZE, true));
        tRecords.addAll(createTestRecords(BULK_SIZE, false));
        insert tRecords;

        wi__WIWebHookConfig__c config = wi__WIWebHookConfig__c.getOrgDefaults();
        config.put('wi__Notification_Email__c', 'email@webinfinity.test');
        config.put('wi__AccessKeyDev__c', '12345');
        config.put('wi__accessKeyLive__c', '678910');
        upsert config;
        System.assertNotEquals(null, config.Id);
    }

    @isTest
    static  void afterInsertTest_SendToWI_Positive() {
        List<MDF__c> tRecords = new List<MDF__c>();
        tRecords.addAll(createTestRecords(BULK_SIZE, true));
        insert tRecords;
        Integer nbrOfSharedRecords = WiCustomObjectTriggerHelper.recordsIdToShareToWISet.size();

        Test.startTest();
            wi.wiWebhookTestHelper.setManagedMock(MOCK_SUCCESS_RESPONSE);
        Test.stopTest();
        System.assertEquals(HTTP_SUCCESS_CODE, wi.WiExternalUtility.getCalloutResponse().getStatusCode(), 'Status Code Was Not Successful');
        System.assertEquals(BULK_SIZE, nbrOfSharedRecords, 'Number of Shared Records was not equal to expected size of ' + BULK_SIZE);
    }

    @isTest
    static  void afterInsertTest_SendToWI_Negative_EmptySet() {
        List<MDF__c> tRecords = new List<MDF__c>();
        tRecords.addAll(createTestRecords(BULK_SIZE, false));
        insert tRecords;
        Integer nbrOfSharedRecords = WiCustomObjectTriggerHelper.recordsIdToShareToWISet.size();

        Test.startTest();
            wi.wiWebhookTestHelper.setManagedMock(MOCK_SUCCESS_RESPONSE);
        Test.stopTest();
        System.assertEquals(null, wi.WiExternalUtility.getCalloutResponse(), 'Callout Response was not Equal to NULL');
        System.assertEquals(0, nbrOfSharedRecords);

    }

    @isTest
    static  void afterUpdateTest_SendToWI_Positive() {
        List<MDF__c> tRecords = new List<MDF__c>([
                SELECT Id
                FROM MDF__c
                WHERE Share_To_WI__c = TRUE
                LIMIT 200
        ]);

        for(Integer i = 0; i < BULK_SIZE; i++) {
            tRecords[i].MDF_Activity_Name__c = 'Test ' + i;
        }
        update tRecords;
        Integer nbrOfSharedRecords = WiCustomObjectTriggerHelper.recordsIdToShareToWISet.size();
        Test.startTest();
            wi.wiWebhookTestHelper.setManagedMock(MOCK_SUCCESS_RESPONSE);
        Test.stopTest();
        System.debug('call out respsonse'+ wi.WiExternalUtility.getCalloutResponse());
        System.assertEquals(HTTP_SUCCESS_CODE, wi.WiExternalUtility.getCalloutResponse().getStatusCode(), 'Status Code Was Not Successful');
        System.assertEquals(BULK_SIZE, nbrOfSharedRecords, 'Number of Shared Records was not equal to expected size of ' + BULK_SIZE);
    }

    @isTest
    static  void afterUpdateTest_SendToWI_Negative_EmptySet() {
        List<MDF__c> tRecords = new List<MDF__c>([
                SELECT Id
                FROM MDF__c
                WHERE Share_To_WI__c = FALSE
                LIMIT 200
        ]);

        for(Integer i = 0; i < BULK_SIZE; i++) {
            tRecords[i].Name = 'Test Name ' + i;
        }
        update tRecords;
        Integer nbrOfSharedRecords = WiCustomObjectTriggerHelper.recordsIdToShareToWISet.size();
        Test.startTest();
            wi.wiWebhookTestHelper.setManagedMock(MOCK_SUCCESS_RESPONSE);
        Test.stopTest();
        System.assertEquals(null, wi.WiExternalUtility.getCalloutResponse(), 'Callout Response was not Equal to NULL');
        System.assertEquals(0, nbrOfSharedRecords);
    }

    @isTest
    static  void afterDeleteTest_SendToWI_Positive() {
        delete [SELECT Id FROM MDF__c WHERE Share_To_WI__c = TRUE LIMIT 200];
        Integer nbrOfSharedRecords = WiCustomObjectTriggerHelper.recordsIdToShareToWISet.size();
        Test.startTest();
            wi.wiWebhookTestHelper.setManagedMock(MOCK_SUCCESS_RESPONSE);
        Test.stopTest();
        System.assertEquals(HTTP_SUCCESS_CODE, wi.WiExternalUtility.getCalloutResponse().getStatusCode(), 'Status Code Was Not Successful');
        System.assertEquals(BULK_SIZE, nbrOfSharedRecords, 'Number of Shared Records was not equal to expected size of ' + BULK_SIZE);
    }

    @isTest
    static  void afterDeleteTest_SendToWI_Negative_EmptySet() {
        delete [SELECT Id FROM MDF__c WHERE Share_To_WI__c = FALSE LIMIT 200];
        Integer nbrOfSharedRecords = WiCustomObjectTriggerHelper.recordsIdToShareToWISet.size();
        Test.startTest();
            wi.wiWebhookTestHelper.setManagedMock(MOCK_SUCCESS_RESPONSE);
        Test.stopTest();
        System.assertEquals(null, wi.WiExternalUtility.getCalloutResponse(), 'Callout Response was not Equal to NULL');
        System.assertEquals(0, nbrOfSharedRecords);
    }

    @isTest
    static  void afterUndeleteTest_SendToWI_Positive() {
        List<MDF__c> tRecords = new List<MDF__c>([
                SELECT Id
                FROM MDF__c
                WHERE Share_To_WI__c = TRUE
                LIMIT 200
        ]);
        delete tRecords;

        undelete tRecords;
        Integer nbrOfSharedRecords = WiCustomObjectTriggerHelper.recordsIdToShareToWISet.size();
        Test.startTest();
            wi.wiWebhookTestHelper.setManagedMock(MOCK_SUCCESS_RESPONSE);
        Test.stopTest();
        System.assertEquals(HTTP_SUCCESS_CODE, wi.WiExternalUtility.getCalloutResponse().getStatusCode(), 'Status Code Was Not Successful');
        System.assertEquals(BULK_SIZE, nbrOfSharedRecords, 'Number of Shared Records was not equal to expected size of ' + BULK_SIZE);
    }

    @isTest
    static  void afterUndeleteTest_SendToWI_Negative_EmptySet() {
        List<MDF__c> tRecords = new List<MDF__c>([
                SELECT Id
                FROM MDF__c
                WHERE Share_To_WI__c = FALSE
                LIMIT 200
        ]);
        delete tRecords;

        undelete tRecords;
        Test.startTest();
            wi.wiWebhookTestHelper.setManagedMock(MOCK_SUCCESS_RESPONSE);
        Test.stopTest();
        System.assertEquals(null, wi.WiExternalUtility.getCalloutResponse(), 'Callout Response was not Equal to NULL');
        System.assertEquals(0, WiCustomObjectTriggerHelper.recordsIdToShareToWISet.size(), 'Number of Share Records was not equal to 0');
    }

    static List<MDF__c> createTestRecords(Integer numberOfRecords, Boolean shareToWI) {
        List<MDF__c> records = new List<MDF__c>();
        for(Integer i = 0; i < numberOfRecords; i++) {
            records.add(new MDF__c(
                    Name = 'Test Record ' + i,
                    Share_To_WI__c = shareToWI
            ));
        }
        System.assertNotEquals(null, records);
        return records;
    }

}