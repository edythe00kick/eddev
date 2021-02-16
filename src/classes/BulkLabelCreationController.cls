public with sharing class BulkLabelCreationController {
    private String bulkJobId {get; set;}
    private Id bulkShipmentId {get; set;}
    private static final String VALIDATION_COMPLETE = 'VALIDATION_COMPLETED';
    private static final String PROCESSING_COMPLETE = 'PROCESSING_COMPLETED';
    private static final String ERROR_STATUS = 'ERROR';
    private static final String SUCCESS_STATUS = 'SUCCESS';
    private Boolean validationComplete {get; set;}
    private Boolean hasValidationErrors {get; set;}
    @testVisible
    private Boolean hasProcessingErrors {get; set;}
    @testVisible
    private String previousStatus {get; set;}    

    transient public Blob attachBody {get;set;}    
    public Attachment csvAttachment {get;set;}
    public List<CustomShipment> customShipmentsList;
    public List<CustomShipment> customShipmentsListtoDisplay {get; set;}
    public Boolean isDisplayUpload {get; set;}
    public Boolean isParsed {get; set;}
    public Boolean startPoller {get; set;}
    public FedexShipmentService service {get; set;}
    public Map<String, Integer> csvLineMap {get; set;}
    public Map<Integer, Shipped_Product__c> shippedProducts {get; set;}
    public Map<Integer, zkfedex__QueuedShipment__c> queuedShipmentMap {get; set;}
    public List<String> invalidHeaders {get; set;}

    public BulkLabelCreationController() {
        csvAttachment = new Attachment();
        customShipmentsList = new List<CustomShipment>();
        customShipmentsListtoDisplay = new List<CustomShipment>();
        invalidHeaders = new List<String>();
        isDisplayUpload = true;
        isParsed = false;
        startPoller = false;
        validationComplete = false;
        hasValidationErrors = false;
        hasProcessingErrors = false;
    }


    /*
     * Name                 : parseCurrentFile
     * Description          : Get current uploaded CSV and call parse method
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    public void parseCurrentFile() {
        isDisplayUpload = false;

        try {
            this.csvAttachment.Body = this.attachBody;
            String csvBodyString = this.attachBody.toString();
            Integer firstHeader = csvBodyString.indexOf('Ship To: {Contact Name}');
            csvBodyString = csvBodyString.substring(firstHeader, csvBodyString.length());
            List<List<String>> parsedCSV = parseCSV(csvBodyString, false);
            List<String> headers = new List<String>();

            Integer rowNumber = 0;
            Integer i = 1;
            for (List<String> row : parsedCSV) {
                if (rowNumber == 0) {
                    for(String col : row) {
                        headers.add(col.trim());
                        if ( ! headerMapping.containsKey(col.trim())) {
                            invalidHeaders.add(col.trim());
                        }
                    }
                    rowNumber++;
                } else {
                    CustomShipment newshipment = new CustomShipment();
                    Integer colNumber = 0;
                    for (String col : row) {
                        col = col.replace('"','');                    
                        String fieldName = headerMapping.get(headers.get(colNumber));
                        newshipment.put(fieldName, col);
                        colNumber++;
                    }
                    customShipmentsList.add(newshipment);
                    if (i <= 1000) {
                        customShipmentsListtoDisplay.add(newshipment);
                    }
                    i++;
                }
            }
            isParsed = true;

            if ( ! invalidHeaders.isEmpty()) {
                String invalidHeadersString = '';
                for (String header : invalidHeaders) {
                    invalidHeadersString += header + ',';
                }
                invalidHeadersString = invalidHeadersString.removeEnd(',');
                String validHeadersString = '';
                for (String header : headerMapping.keySet()) {
                    validHeadersString += header + ',';
                }
                validHeadersString = validHeadersString.removeEnd(',');
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Headers in CSV: ' + invalidHeadersString));
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Valid Headers: ' + validHeadersString));
            }
        } catch (Exception e) {
            isParsed = false;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        } finally {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Please make sure that your CSV file is correct using preview (1000 max) below.'));    
        }
    }

    /*
     * Name                 : createShipments
     * Description          : Create queued records and call validation method
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    public void createShipments() {
        service = new FedexShipmentService();
        queuedShipmentMap = new Map<Integer, zkfedex__QueuedShipment__c>();
        Map<Integer, zkfedex__QueuedPackage__c> queuedPackageMap = new Map<Integer, zkfedex__QueuedPackage__c>();
        Map<Integer, zkfedex__QueuedInternationalCommodity__c> commoditiesMap = new Map<Integer, zkfedex__QueuedInternationalCommodity__c>();
        shippedProducts = new Map<Integer, Shipped_Product__c>();
        
        //Create bulk shipment record
        bulkShipmentId = service.createBulkShipment();

        //Create queued shipments and packages based on CSV file
        Integer i = 0;
        Integer comIndex = 1;
        Boolean isCSVerror = false;
        Set<Id> contactsIds = new Set<Id>();

        Set<Id> contactsToTestIds = new Set<Id>();
        Set<Id> fulfillmentToTestIds = new Set<Id>();
        Integer errorLineTemp = 1;
        for (CustomShipment cs : customShipmentsList) {
            if (cs.contactId != null) {
                try {
                    contactsToTestIds.add(Id.valueOf(cs.contactId));
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Contact Id on line ' + errorLineTemp));
                    return;
                }
            }
            if (cs.fulfillmentProduct != null) {
                try {
                    fulfillmentToTestIds.add(Id.valueOf(cs.fulfillmentProduct));
                } catch (Exception e) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Fulfillment Product Id on line ' + errorLineTemp));
                    return;
                }     
            }
            errorLineTemp++;
        }

        Map<Id, Contact> existingContactsMap = new Map<Id, Contact>([
                SELECT Id, AccountId 
                FROM Contact 
                WHERE Id IN :contactsToTestIds
                LIMIT 20000]);

        Map<Id, Fulfillment_Product__c> existingFulfillmentMap = new Map<Id, Fulfillment_Product__c>([
                SELECT Id 
                FROM Fulfillment_Product__c 
                WHERE Id IN :fulfillmentToTestIds
                LIMIT 20000]);
        errorLineTemp = 1;
        for (CustomShipment cs : customShipmentsList) {
            if (cs.contactId != null && ! existingContactsMap.containsKey(Id.valueOf(cs.contactId))) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Contact Id on line ' + errorLineTemp));
                return;
            }
            if (cs.fulfillmentProduct != null && ! existingFulfillmentMap.containsKey(Id.valueOf(cs.fulfillmentProduct))) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Fulfillment Product Id on line ' + errorLineTemp));
                return;
            }
            errorLineTemp++;
            //Queued Shipments
            zkfedex__QueuedShipment__c queuedShipmentRecord = service.createQueuedShipmentRecord(cs);
            if (cs.shipToEmail != null) {
                queuedShipmentRecord.zkfedex__EmailRecipient2__c = cs.shipToEmail;
            }
            if (existingContactsMap.containsKey(cs.ContactId) && 
                existingContactsMap.get(cs.ContactId).AccountId != null) {
                queuedShipmentRecord.zkfedex__Account__c = existingContactsMap.get(cs.ContactId).AccountId;
            }
            queuedShipmentRecord.zkfedex__BulkShipment__c = bulkShipmentId;
            queuedShipmentMap.put(i, queuedShipmentRecord);
            
            if (cs.fulfillmentProduct != null && (cs.isReturn == 'FALSE' || cs.isReturn == 'false')) {
                try {
                    shippedProducts.put(i, new Shipped_Product__c(Fulfillment_Product__c = cs.fulfillmentProduct.trim()));
                } catch (Exception e) {
                    isCSVerror = true;
                    Integer errorLine = i + 1;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Invalid Fulfillment Id on line ' + errorLine));
                }
            }

            //Queued package
            Decimal declaredValueDec = (! String.isBlank(cs.declaredValue)) ? Decimal.valueOf(cs.declaredValue) : null;
            Decimal weightDec = (! String.isBlank(cs.weight)) ? Decimal.valueOf(cs.weight) : null;
            Decimal lengthDec = (! String.isBlank(cs.length)) ? Decimal.valueOf(cs.length) : null;
            Decimal widthDec = (! String.isBlank(cs.width)) ? Decimal.valueOf(cs.width) : null;
            Decimal heightDec = (! String.isBlank(cs.height)) ? Decimal.valueOf(cs.height) : null;

            zkfedex__QueuedPackage__c queuedPackage = service.createQueuedPackage(
                declaredValueDec,
                weightDec,
                lengthDec,
                widthDec,
                heightDec);
            queuedPackageMap.put(i, queuedPackage);

            if (cs.serviceType.contains('International')) {
                queuedShipmentMap.get(i).zkfedex__DocumentContentType__c = 'NON_DOCUMENTS';
                queuedShipmentMap.get(i).zkfedex__DutiesPaymentType__c = 'SENDER';
                queuedShipmentMap.get(i).zkfedex__DutiesPayorAccount__c = service.shipmatePreference.zkfedex__FedExAccountNumber__c;
                queuedShipmentMap.get(i).zkfedex__DutiesPayorAccountCountry__c = service.shipmatePreference.zkfedex__BillingCountry__c;
                zkfedex__QueuedInternationalCommodity__c com = service.createCommodity(
                    cs.countryOfManufacture,
                    cs.productDescription,
                    cs.hsCode,
                    cs.partNumber,
                    declaredValueDec,
                    weightDec,
                    1,
                    null,
                    1);

                commoditiesMap.put(i, com);

                comIndex++;
            }

            i++;
        }

        if ( ! isCSVerror ) {
            insert queuedShipmentMap.values();
            Integer csvLine = 2;
            csvLineMap = new Map<String, Integer>();
            for (zkfedex__QueuedShipment__c qs : queuedShipmentMap.values()) {
                csvLineMap.put(qs.Id, csvLine);
                csvLine++;
            }

            for (Integer customIndex : queuedShipmentMap.keySet()) {
                queuedPackageMap.get(customIndex).zkfedex__QueuedShipment__c = queuedShipmentMap.get(customIndex).Id;
            }

            //Create queued packages
            insert queuedPackageMap.values();

            for (Integer customIndex : commoditiesMap.keySet()) {
                commoditiesMap.get(customIndex).zkfedex__QueuedShipment__c = queuedShipmentMap.get(customIndex).Id;
            }

            //Create commodities
            insert commoditiesMap.values();

            if ( ! Test.isRunningTest()) {
                bulkJobId = service.validateShipments(bulkShipmentId, true);
            }
            startPoller = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Validation process has been initiated.'));
        }
    }

    /*
     * Name                 : checkShipmentStatus
     * Description          : Action poller calls this method every 5 seconds. Method checks statuses and starts labels creation
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    public PageReference checkShipmentStatus() {
        try {
            if (String.isBlank(previousStatus) || (previousStatus != PROCESSING_COMPLETE && !hasValidationErrors) ) {
                if ( ! Test.isRunningTest() ) {
                    //get current status
                    previousStatus = service.getJobStatus(bulkJobId);
                }
            }

            if (previousStatus == VALIDATION_COMPLETE ) {
                //if validation completed - run shipment creation process
                validationComplete = true;
                Map<String,String> itemStatusesMap = service.getQueuedItemStatusesMap(bulkJobId, bulkShipmentId);

                for ( String checkId : itemStatusesMap.keySet() ) {
                    String compositeStatus = itemStatusesMap.get(checkId);
                    if(compositeStatus.containsIgnoreCase(ERROR_STATUS)) {
                        String errorMessage = compositeStatus.substring(compositeStatus.indexOf(ERROR_STATUS) + ERROR_STATUS.length() + 1, compositeStatus.length());
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'CSV Line ' + csvLineMap.get(checkId) + ': Error message: ' + errorMessage));
                        hasValidationErrors = true;
                        startPoller = false;
                    }
                }
                if ( ! hasValidationErrors ) {
                    if ( ! Test.isRunningTest() ) {
                        //Process shipment
                        if ( ! Test.isRunningTest()) {
                            bulkJobId = service.processShipments(bulkShipmentId);
                        }
                    }
                }
            } else if (previousStatus == PROCESSING_COMPLETE) {
                //if shipment created - call method for Pickup creation
                Map<String,String> itemStatusesMap = service.getQueuedItemStatusesMap(bulkJobId, bulkShipmentId);
                String errorMessageShipments = '';
                Integer successCount = 0;
                Integer errorsCount = 0; 
                for ( String checkId : itemStatusesMap.keySet() ) {
                    String compositeStatus = itemStatusesMap.get(checkId);
                    if(compositeStatus.containsIgnoreCase(ERROR_STATUS)) {
                        String errorMessage = compositeStatus.substring(compositeStatus.indexOf(ERROR_STATUS) + ERROR_STATUS.length() + 1, compositeStatus.length());
                        errorMessageShipments = errorMessageShipments + 'CSV Line ' + csvLineMap.get(checkId) + ': ' + errorMessage + '<br/>';
                        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ' Error message: ' + errorMessage));
                        hasProcessingErrors = true;
                        startPoller = false;
                        errorsCount++;
                    } else {
                        successCount++;
                    }
                }
                if ( ! hasProcessingErrors ) {
                    startPoller = false;

                    Set<Id> qsids = new Set<Id>();
                    for (zkfedex__QueuedShipment__c qs : queuedShipmentMap.values()) {
                        qsids.add(qs.Id);
                    }
                    List<zkfedex__QueuedShipmentStatus__c> qsStatus = [
                            SELECT zkfedex__Shipment__c, zkfedex__QueuedShipment__c
                            FROM zkfedex__QueuedShipmentStatus__c
                            WHERE zkfedex__Shipment__c != null AND
                                  zkfedex__QueuedShipment__c IN :qsids
                            LIMIT 10000];

                    Map<String, String> queuedShipmentToShipmentMap = new Map<String, String>();
                    for (zkfedex__QueuedShipmentStatus__c qss : qsStatus) {
                        queuedShipmentToShipmentMap.put(qss.zkfedex__QueuedShipment__c,qss.zkfedex__Shipment__c);
                    }

                    //create shipped products
                    List<Shipped_Product__c> shippedProductsToInsert = new List<Shipped_Product__c>();
                    for (Integer comindex : shippedProducts.keySet()) {
                        String qsId = queuedShipmentMap.get(comindex).Id;
                        shippedProducts.get(comindex).FedEx_Shipment__c = queuedShipmentToShipmentMap.get(qsId);
                        shippedProductsToInsert.add(shippedProducts.get(comindex));
                    }
                    insert shippedProductsToInsert;

                    PageReference page = new PageReference('/' + bulkShipmentId);
                    page.setRedirect(true);
                    return page;
                } else {
                    String finalMessage = 'The other shipments have been created and can be found <a href="/' + bulkShipmentId + '">here</a>, but please create a new CSV file with just the error lines specified above to try to <a href="/apex/BulkLabelCreation">recreate</a> those failed shipments.' +
                                          'Success: ' + successCount + '<br/>' +
                                          'Errors: ' + errorsCount + '<br/>' + errorMessageShipments;
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, finalMessage));
                }
            }             
        } catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
        }

        if (validationComplete) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Shipment validation has been completed.'));
        } else {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Validation process has been initiated.'));
        }
        return null;
    }

    /*
     * Name                 : parseCSV
     * Description          : Parse CSV file
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    public static List<List<String>> parseCSV(String contents,Boolean skipHeaders) {
        List<List<String>> allFields = new List<List<String>>();
        // end line
        // contents = contents.replace('\r\n', '\r');
        // contents = contents.replace('\n', '\r');

        // replace instances where a double quote begins a field containing a comma
        // in this case you get a double quote followed by a doubled double quote
        // do this for beginning and end of a field
        contents = contents.replaceAll(',"""',',"DBLQT').replaceall('""",','DBLQT",');
        // now replace all remaining double quotes - we do this so that we can reconstruct
        // fields with commas inside assuming they begin and end with a double quote
        contents = contents.replaceAll('""','DBLQT');
        // we are not attempting to handle fields with a newline inside of them
        // so, split on newline to get the spreadsheet rows
        List<String> lines = new List<String>();
        try {
            if (contents.contains('\r\n')) {
                lines = contents.split('\r\n');    
            } else {
                lines = contents.split('\n');
            }
            
        } catch (System.ListException e) {
            System.debug('Limits exceeded?' + e.getMessage());
        }
        Integer num = 0;
        for(String line : lines) {
            // check for blank CSV lines (only commas)
            if (line.replaceAll(',','').trim().length() == 0) break;
            
            List<String> fields = line.split(',');  
            List<String> cleanFields = new List<String>();
            String compositeField;
            Boolean makeCompositeField = false;
            for(String field : fields) {
                if (field.startsWith('"') && field.endsWith('"') && makeCompositeField == false) {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                } else if (field.startsWith('"') && makeCompositeField == false) {
                    makeCompositeField = true;
                    compositeField = field;
                } else if (field.endsWith('"')) {
                    compositeField += ',' + field;
                    cleanFields.add(compositeField.replaceAll('DBLQT','"'));
                    makeCompositeField = false;
                } else if (makeCompositeField) {
                    compositeField +=  ',' + field;
                } else {
                    cleanFields.add(field.replaceAll('DBLQT','"'));
                }
            }
            
            allFields.add(cleanFields);
        }
        if (skipHeaders) allFields.remove(0);
        return allFields;       
    }

    private static Map<String, String> headerMapping = new Map<String, String> {
        'Ship To: {Contact Name}' => 'toContactName',
        'Ship To Company: {Account Name}' => 'toAccountName',
        'Ship To: {Telephone Number}' => 'toPhone',
        'Street 1' => 'toStreet1',
        'Street 2' => 'toStreet2',
        'Street 3' => 'toStreet3',
        'City' => 'toCity',
        'State - two digit ISO Code including Canada' => 'toState',
        'Zip/Postal Code' => 'toPostalCode',
        'Country - two digit ISO Code' => 'toCountry',
        'Service Type' => 'serviceType',
        'Weight (in lbs)' => 'weight',
        'Length (cm)' => 'length',
        'Width (cm)' => 'width',
        'Height (cm)' => 'height',
        'Ship From Address' => 'shipFrom',
        'Contact Id' => 'contactId',
        'Declared Value' => 'declaredValue',
        'Part Number' => 'partNumber',
        'Country of Manufacture' => 'countryOfManufacture',
        'HS Code' => 'hsCode',
        'Product Description' => 'productDescription',
        'Is Return' => 'isReturn',
        'Fulfillment Product' => 'fulfillmentProduct',
        'Ship to Email' => 'shipToEmail'
    };

    /**
     * Utility class to iterate over lines
     **/
    public class LineReader implements Iterator<String>, Iterable<String> {       
        private String LINE_SEPARATOR = '\r';
        private String textData;
        public LineReader(String textData) {       
            this.textData = textData;
        }

        public Boolean hasNext() {
            return textData.length() > 0 ? true : false;
        }   

        public String next() {
            String row = null;
            Integer endPos = textData.indexOf(LINE_SEPARATOR);
            if(endPos == -1) {
                row = textData;
                textData = '';
            }
            else {
                row = textData.subString(0, endPos);
                textData = textData.subString(endPos + LINE_SEPARATOR.length(), textData.length());             
            }
            return row;
        }

        public Iterator<String> Iterator() {
            return this;   
        }           
    } 
}