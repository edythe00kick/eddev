public with sharing class FedexShipmentService {
    public zkfedex__ShipmatePreference__c shipmatePreference {get; set;}
    public BulkShipmentSettings__c settings {get; set;}

    /*
     * Name                 : FedexShipmentService
     * Description          : Constructor
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   : 
     *
     */
    public FedexShipmentService() {
        //get shipment setting for preferences names
        settings = BulkShipmentSettings__c.getInstance('FedEx');
        //get current shipmate preference
        shipmatePreference = getShipmatePreference();
    }

    /*
     * Name                 : createBulkShipment
     * Description          : 
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    public Id createBulkShipment() {
        zkfedex__BulkShipment__c shipment = new zkfedex__BulkShipment__c();
        shipment.zkfedex__ShipmatePreference__c = shipmatePreference.Id;
        insert shipment;

        return shipment.Id;
    }

    /*
     * Name                 : createQueuedShipmentRecord
     * Description          : Create Queued shipment based on CustomShipment
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    public zkfedex__QueuedShipment__c createQueuedShipmentRecord(CustomShipment cs) {
        String contactId = '';
        if (cs.contactId != null && cs != null && cs.contactId.length() > 15) {
            contactId = cs.contactId.substring(0,15);
        }
        zkfedex__QueuedShipment__c queuedShipment = new zkfedex__QueuedShipment__c();
        queuedShipment.zkfedex__ShipDate__c = Date.today();
        queuedShipment.zkfedex__DropoffType__c = dropoffTypeMap.get(shipmatePreference.zkfedex__DropoffTypeDefault__c);
        queuedShipment.zkfedex__LabelImageType__c = 'Thermal 4x6 - Zebra';
        queuedShipment.zkfedex__Contact__c = contactId;
        queuedShipment.zkfedex__ServiceType__c = serviceTypeMapping.get(cs.serviceType);
        queuedShipment.zkfedex__PackagingType__c = settings.DefaultPackagingType__c;
        queuedShipment.zkfedex__WeightDimensionUnits__c = settings.DimensionUnits__c;
        queuedShipment.zkfedex__ReturnShipment__c = false;
        queuedShipment.zkfedex__PaymentType__c = settings.PaymentType__c;

        //FROM
        queuedShipment.zkfedex__SenderName__c = shipmatePreference.zkfedex__SenderNameDefault__c;
        queuedShipment.zkfedex__SenderCompany__c = shipmatePreference.zkfedex__CompanyName__c;
        queuedShipment.zkfedex__SenderPhone__c = shipmatePreference.zkfedex__SenderPhoneDefault__c;
        queuedShipment.zkfedex__SenderEmail__c = shipmatePreference.zkfedex__SenderEMailDefault__c;
        queuedShipment.zkfedex__EmailRecipient1__c = shipmatePreference.zkfedex__SenderEMailDefault__c;
        queuedShipment.zkfedex__SenderStreet__c = shipmatePreference.zkfedex__ShippingStreet__c;
        queuedShipment.zkfedex__SenderCity__c = shipmatePreference.zkfedex__ShippingCity__c;
        queuedShipment.zkfedex__SenderState__c = shipmatePreference.zkfedex__ShippingState__c;
        queuedShipment.zkfedex__SenderPostalCode__c = shipmatePreference.zkfedex__ShippingPostalCode__c;
        queuedShipment.zkfedex__SenderCountry__c = shipmatePreference.zkfedex__ShippingCountry__c;
        queuedShipment.zkfedex__PaymentType__c = settings.PaymentType__c;

        //TO
        queuedShipment.zkfedex__RecipientName__c = cs.toContactName;
        queuedShipment.zkfedex__RecipientCompany__c = cs.toAccountName;
        queuedShipment.zkfedex__RecipientPhone__c = cs.toPhone;
        queuedShipment.zkfedex__RecipientStreet__c = cs.toStreet1;
        if (cs.toStreet2 != null) {
            queuedShipment.zkfedex__RecipientStreet__c = queuedShipment.zkfedex__RecipientStreet__c + '\n' + cs.toStreet2;
        }
        if (cs.toStreet3 != null) {
            queuedShipment.zkfedex__RecipientStreet__c = queuedShipment.zkfedex__RecipientStreet__c + ' ' + cs.toStreet3;
        }
        queuedShipment.zkfedex__RecipientCity__c = cs.toCity;
        queuedShipment.zkfedex__RecipientState__c = cs.toState;
        queuedShipment.zkfedex__RecipientPostalCode__c = cs.toPostalCode;
        queuedShipment.zkfedex__RecipientCountry__c = cs.toCountry;

        //Message
        queuedShipment.zkfedex__EmailMessage__c = shipmatePreference.zkfedex__EMailMessageDefault__c;       

        //Return
        if (cs.isReturn == 'true') {
            queuedShipment.zkfedex__ReturnShipment__c = true;
        }

        return queuedShipment;
    }

    /*
     * Name                 : createQueuedPackage
     * Description          : Create queued package
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    public zkfedex__QueuedPackage__c createQueuedPackage(Decimal declaredValue, Decimal weight,Decimal length,Decimal width,Decimal height) {
        zkfedex__QueuedPackage__c queuedPackage = new zkfedex__QueuedPackage__c();
        queuedPackage.zkfedex__DeclaredValue__c = declaredValue;
        queuedPackage.zkfedex__Weight__c = weight * 0.393;
        queuedPackage.zkfedex__Length__c = length;
        queuedPackage.zkfedex__Width__c = width;
        queuedPackage.zkfedex__Height__c = height;
        return queuedPackage;
    }

    /*
     * Name                 : createCommodity
     * Description          : Create commoditity for queued package
     * Author               : Zenkraft Developers
     * Create Date          : 04/07/2016
     * Last Modified Date   :
     *
     */
    public zkfedex__QueuedInternationalCommodity__c createCommodity(
            String countryOfManufacture,
            String descriptionProduct,
            String hsCode,
            String partNumber,
            Decimal unitPrice,
            Decimal weight,
            Decimal quantity,
            Id queuedShipmentId,
            Integer seqNumber) {
        //fill object manually  (without commodity data object)
        zkfedex__QueuedInternationalCommodity__c intlCommodity = new zkfedex__QueuedInternationalCommodity__c();
        intlCommodity.zkfedex__CiMarksAndNumbers__c  = null;
        intlCommodity.zkfedex__CountryOfManufacture__c  = countryOfManufacture;
        intlCommodity.zkfedex__Description__c  = descriptionProduct;
        intlCommodity.zkfedex__HarmonizedCode__c  = hsCode;
        intlCommodity.zkfedex__NumberOfPieces__c  = 1;
        intlCommodity.zkfedex__PartNumber__c  = partNumber;
        intlCommodity.zkfedex__Quantity__c  = quantity;
        intlCommodity.zkfedex__QuantityUnits__c  = 'EA';
        intlCommodity.zkfedex__UnitPrice__c  = unitPrice;
        intlCommodity.zkfedex__WeightUnits__c  = 'LB';
        intlCommodity.zkfedex__Weight__c  = weight * 0.393;
        intlCommodity.zkfedex__QueuedShipment__c = queuedShipmentId;
        intlCommodity.zkfedex__SequenceNumber__c = seqNumber;

        return intlCommodity;
    }

    /*
     * Name                 : getShipmatePreference
     * Description          : Get current zkfedex__ShipmatePreference__c
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    private zkfedex__ShipmatePreference__c getShipmatePreference() {
        return [
            SELECT  Id, Name, zkfedex__FedExAccountNumber__c, zkfedex__FedExMeterNumber__c, zkfedex__EncryptedFedExMeterNumber__c, zkfedex__SubscriptionDataEncrypted__c, zkfedex__GenericFedExEndUserKey__c, 
                    zkfedex__GenericFedExEndUserPassword__c, zkfedex__EncryptedGenericFedExEndUserKey__c, zkfedex__EncryptedGenericFedExEndUserPasswd__c, zkfedex__GenericCredentialsEncrypted__c, 
                    zkfedex__CompanyName__c, zkfedex__ShippingStreet__c, zkfedex__ShippingCity__c, zkfedex__ShippingState__c, zkfedex__ShippingPostalCode__c, zkfedex__ShippingCountry__c, zkfedex__ShippingIsResidential__c, 
                    zkfedex__BillingStreet__c, zkfedex__BillingCity__c, zkfedex__BillingState__c, zkfedex__BillingPostalCode__c, zkfedex__BillingCountry__c, zkfedex__LabelImageTypeDefault__c, zkfedex__EMailMessageDefault__c, 
                    zkfedex__SendEMailNotificationToShipper__c, zkfedex__SendEMailNotificationToRecipient__c, zkfedex__EMailNotifyOnExceptionDefault__c, zkfedex__EMailNotifyOnDeliveryDefault__c, 
                    zkfedex__SenderNameDefault__c, zkfedex__SenderEMailDefault__c, zkfedex__SenderPhoneDefault__c, zkfedex__DetailedViewShipmatePreferenceList__c, zkfedex__DetailedViewReUsePackageList__c, 
                    zkfedex__AccountIsSetupForSmartPostOutbound__c, zkfedex__AccountIsSetupForSmartPostReturns__c, zkfedex__SmartPostHubId__c, zkfedex__DropoffTypeDefault__c
            FROM zkfedex__ShipmatePreference__c
            WHERE Name = :settings.ShipmatePreferenceName__c
            LIMIT 1];
    }

    /*
     * Name                 : getJobStatus
     * Description          : Check status from response
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    public String getJobStatus(String bulkJobId) {
        List<zkfedex__BulkShipmentStatus__c> statuses = [SELECT zkfedex__Status__c FROM zkfedex__BulkShipmentStatus__c WHERE zkfedex__BatchId__c = :bulkJobId];
        if(!statuses.isEmpty()) {
            return statuses[0].zkfedex__Status__c;
        }
        return null;
    }

    /*
     * Name                 : getJobStatus
     * Description          : Check status from response for validation and label creation.
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    public Map<String, String> getQueuedItemStatusesMap(String bulkJobId, String bulkShipmentId) {
        Map<String, String> statusesMap = new Map<String, String>();
        Map<Id, zkfedex__QueuedShipment__c> queuedShipmentsMap = new Map<Id, zkfedex__QueuedShipment__c>([SELECT zkfedex__Contact__c FROM zkfedex__QueuedShipment__c WHERE zkfedex__BulkShipment__c = :bulkShipmentId]);
        List<zkfedex__QueuedShipmentStatus__c> queuedItemsStatuses = [SELECT zkfedex__QueuedShipment__c, zkfedex__Status__c, zkfedex__StatusMessage__c FROM zkfedex__QueuedShipmentStatus__c WHERE zkfedex__BatchId__c = :bulkJobId];
        for ( zkfedex__QueuedShipmentStatus__c status : queuedItemsStatuses ) {
            zkfedex__QueuedShipment__c queuedShipment = queuedShipmentsMap.get(status.zkfedex__QueuedShipment__c);
            //String relatedContact = queuedShipment != null ? queuedShipment.zkfedex__Contact__c : '';
            if ( ! statusesMap.containsKey(queuedShipment.Id))
            statusesMap.put(queuedShipment.Id, status.zkfedex__Status__c + ':' + status.zkfedex__StatusMessage__c);
        }
        return statusesMap;
    }

    /*
     * Name                 : validateShipments
     * Description          : Send request to validate data
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    public String validateShipments(Id bulkShipmentId, Boolean performAddressValidation) {
        return zkfedex.BulkShipmentInterface.validateBulkShipment(bulkShipmentId, performAddressValidation);
    }

    /*
     * Name                 : processShipments
     * Description          : Send request to create labels and shipments
     * Author               : Zenkraft Developers
     * Create Date          : 03/07/2016
     * Last Modified Date   :
     *
     */
    public String processShipments(Id bulkShipmentId) {
        return zkfedex.BulkShipmentInterface.processBulkShipment(bulkShipmentId);
    }

    private Map<String, String> serviceTypeMapping = new Map<String, String>{
        'FedEx First Overnight' => 'Domestic: FedEx First Overnight',
        'FedEx Priority Overnight' => 'Domestic: FedEx Priority Overnight',
        'FedEx Standard Overnight' => 'Domestic: FedEx Standard Overnight',
        'FedEx 2 Day AM' => 'Domestic: FedEx 2Day A.M.',
        'FedEx 2 Day' => 'Domestic: FedEx 2Day',
        'FedEx Express Saver' => 'Domestic: FedEx Express Saver',
        'FedEx Ground' => 'Domestic: FedEx Ground',
        'FedEx Home Delivery (Ground)' => 'Domestic: FedEx Home Delivery',
        'FedEx International Economy' => 'International: FedEx International Economy',
        'FedEx International First' => 'International: FedEx International First',
        'FedEx International Priority' => 'International: FedEx International Priority'
    };

    private Map<String,String> dropoffTypeMap = new Map<String,String> {
        'BUSINESS_SERVICE_CENTER' => 'Business Service Center',
        'DROP_BOX' => 'Drop Box',
        'REGULAR_PICKUP' => 'Regular Pickup',
        'REQUEST_COURIER' => 'Request Courier',
        'STATION' => 'Station'
    };
}