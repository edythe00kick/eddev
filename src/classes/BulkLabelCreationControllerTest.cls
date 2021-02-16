@isTest
private class BulkLabelCreationControllerTest {
	public static Account a;
	public static Contact c;
    @isTest
    public static void testParsing() {
    	createRecords();
    	Blob blbtemp = Blob.valueOf('Ship To: {Contact Name},Ship To Company: {Account Name},Ship To: {Telephone Number},Street 12,Street 2,Street 3,City,State - two digit ISO Code including Canada,Zip/Postal Code,Ship to Email,Country - two digit ISO Code,Service Type,Weight (in lbs),Length (cm),Width (cm),Height (cm),Contact Id,Is Return,Declared Value,Part Number,Country of Manufacture,HS Code,Product Description,Fulfillment Product\nAlexander Chang,ecoATM,(425) 943-8000,5985 EXPLORER DR,,,MISSISSAUGA,ON,L4W5K6,test@test.com,CA,FedEx International Economy,0.85,32,1,24,' + c.Id + ',false,10,12345,US,1231231231,test tset,');

    	BulkLabelCreationController controller = new BulkLabelCreationController();
    	controller.attachBody = blbtemp;
    	controller.parseCurrentFile();
    	system.debug('customShipmentsList === ' + controller.customShipmentsList.size());
    	controller.createShipments();
        controller.hasProcessingErrors = true;
        controller.checkShipmentStatus();
        controller.hasProcessingErrors = false;
        controller.checkShipmentStatus();
    	controller.previousStatus = 'VALIDATION_COMPLETED';
    	controller.checkShipmentStatus();
    	controller.previousStatus = 'PROCESSING_COMPLETED';
    	controller.checkShipmentStatus();
    }

    @isTest
    public static void testParsing2() {
    	createRecords();
    	Blob blbtemp = Blob.valueOf('Ship To: {Contact Name},Ship To Company: {Account Name},Ship To: {Telephone Number},Street 1,Street 2,Street 3,City,State - two digit ISO Code including Canada,Zip/Postal Code,Ship to Email,Country - two digit ISO Code,Service Type,Weight (in lbs),Length (cm),Width (cm),Height (cm),Contact Id,Is Return,Declared Value,Part Number,Country of Manufacture,HS Code,Product Description,Fulfillment Product\nAlexander Chang,ecoATM,(425) 943-8000,5985 EXPLORER DR,,,MISSISSAUGA,ON,L4W5K6,test@test.com,CA,FedEx International Economy,0.85,32,1,24,' + c.Id + ',false,10,12345,US,1231231231,test tset,');

    	BulkLabelCreationController controller = new BulkLabelCreationController();
    	controller.attachBody = blbtemp;
    	controller.parseCurrentFile();
    	system.debug('customShipmentsList === ' + controller.customShipmentsList.size());
    	controller.createShipments();
    	controller.checkShipmentStatus();
    	controller.previousStatus = 'VALIDATION_COMPLETED';
    	controller.checkShipmentStatus();
    	controller.previousStatus = 'PROCESSING_COMPLETED';
    	controller.checkShipmentStatus();
    }

    @isTest
    public static void testParsing3Error() {
        createRecords();
        Blob blbtemp = Blob.valueOf('Street 1,Contact Id,Service Type\nTest,123123,FedEx International');

        BulkLabelCreationController controller = new BulkLabelCreationController();
        controller.attachBody = blbtemp;
        controller.parseCurrentFile();
        system.debug('customShipmentsList === ' + controller.customShipmentsList.size());
        controller.createShipments();
        controller.checkShipmentStatus();
        controller.previousStatus = 'VALIDATION_COMPLETED';
        controller.checkShipmentStatus();
        controller.previousStatus = 'PROCESSING_COMPLETED';
        controller.checkShipmentStatus();
    }

	public static void createRecords() {
    	a = new Account(Name = 'test');
    	insert a;
    	c = new Contact(FirstName = 'test', LastName = 'test', AccountId = a.Id);
    	insert c;

		//FEDEX PREF
		zkfedex__ShipmatePreference__c testFedexShippingPref = new zkfedex__ShipmatePreference__c(
			zkfedex__ShippingCity__c = 'City', 
			zkfedex__ShippingState__c = 'TN', 
			zkfedex__ShippingStreet__c = 'Street', 
			zkfedex__ShippingPostalCode__c = '37011',
            zkfedex__CompanyName__c = 'Test Company',
            zkfedex__emailLabelTextBodyDefault__c = 'test info', 
            zkfedex__SenderNameDefault__c = 'test sender', 
            zkfedex__SenderEMailDefault__c = 'test@test.tst',
            zkfedex__SenderPhoneDefault__c = '123',
            zkfedex__LabelImageTypeDefault__c = 'test label'
		);
		insert testFedexShippingPref;

		String prefName = [SELECT Name FROM zkfedex__ShipmatePreference__c LIMIT 1].Name;

		BulkShipmentSettings__c setting = new BulkShipmentSettings__c(
			Name = 'FedEx',
			ShipmatePreferenceName__c = prefName,
			DefaultPackagingType__c = 'Your packaging',
			DimensionUnits__c = 'LB / IN',
			PaymentType__c = 'Sender');
		insert setting;
	}
}