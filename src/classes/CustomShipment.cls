public with sharing class CustomShipment {
    	public String toContactName {get; set;}
    	public String toAccountName {get; set;}
    	public String toPhone {get; set;}
    	public String toStreet1 {get; set;}
    	public String toStreet2 {get; set;}
    	public String toStreet3 {get; set;}
    	public String toCity {get; set;}
    	public String toState {get; set;}
    	public String toPostalCode {get; set;}
    	public String toCountry {get; set;}
    	public String serviceType {get; set;}
    	public String weight {get; set;}
    	public String length {get; set;}
    	public String width {get; set;}
    	public String height {get; set;}
    	public String shipFrom {get; set;}
    	public String contactId {get; set;}
        public String declaredValue {get; set;}
        public String countryOfManufacture {get; set;}
        public String partNumber {get; set;}
        public String productDescription {get; set;}
        public String hsCode {get; set;}
        public String isReturn {get; set;}
        public String fulfillmentProduct {get; set;}
        public String shipToEmail {get; set;}

        public CustomShipment() {
            
        }

    	public void put(String fieldName, String fieldValue) {
    		if (fieldName == 'toContactName') this.toContactName = fieldValue;
    		if (fieldName == 'toAccountName') this.toAccountName = fieldValue;
    		if (fieldName == 'toPhone') this.toPhone = fieldValue;
    		if (fieldName == 'toStreet1') this.toStreet1 = fieldValue;
    		if (fieldName == 'toStreet2') this.toStreet2 = fieldValue;
    		if (fieldName == 'toStreet3') this.toStreet3 = fieldValue;
    		if (fieldName == 'toCity') this.toCity = fieldValue;
    		if (fieldName == 'toState') this.toState = fieldValue;
    		if (fieldName == 'toPostalCode') this.toPostalCode = fieldValue;
    		if (fieldName == 'toCountry') this.toCountry = fieldValue;
    		if (fieldName == 'serviceType') this.serviceType = fieldValue;
    		if (fieldName == 'weight') this.weight = fieldValue;
    		if (fieldName == 'length') this.length = fieldValue;
    		if (fieldName == 'width') this.width = fieldValue;
    		if (fieldName == 'height') this.height = fieldValue;
    		if (fieldName == 'shipFrom') this.shipFrom = fieldValue;
    		if (fieldName == 'contactId') this.contactId = fieldValue;
            if (fieldName == 'declaredValue') this.declaredValue = fieldValue;
            if (fieldName == 'countryOfManufacture') this.countryOfManufacture = fieldValue;
            if (fieldName == 'partNumber') this.partNumber = fieldValue;
            if (fieldName == 'productDescription') this.productDescription = fieldValue;
            if (fieldName == 'hsCode') this.hsCode = fieldValue;
            if (fieldName == 'isReturn') this.isReturn = fieldValue;
            if (fieldName == 'fulfillmentProduct') this.fulfillmentProduct = fieldValue;
            if (fieldName == 'shipToEmail') this.shipToEmail = fieldValue;
    	}
}