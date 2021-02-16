/**
 * Created by csalgado on 12/17/2019.
 */

public with sharing class CaseToKnowledgeController {
    @AuraEnabled
    public static Case getCase(String recordId){
        Case mainCase = new Case();

        if(recordId != null){
            system.debug('**CSALGADO** recordId =' + recordId);
            mainCase = [SELECT Id, Description, Close_Comments__c FROM Case WHERE Id = :recordId LIMIT 1];
            system.debug('**CSALGADO** mainCase =' + mainCase);
        }
        else{
            system.debug('**CSALGADO** ERROR: recordId =' + recordId);
        }

        return mainCase;
    }

    @AuraEnabled
    public static String insertKnowledge(Knowledge__kav know) {
        system.debug('**CSALGADO** know: ' + know);
        //Return value
        String returnString = 'Success';

        //Check for invalid characters in URL
        boolean invalid = false;
        if(!((know.UrlName.capitalize()).containsOnly('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ-1234567890'))){
            invalid = true;
            returnString = 'Invalid';
        }

        //Check for duplicate URLs
        Boolean duplicate = false;
        List<Knowledge__kav> duplicateKnows = [SELECT Id FROM Knowledge__kav WHERE UrlName = :know.UrlName];
        if(!invalid && duplicateKnows.size()>0){
            duplicate = true;
            returnString = 'Duplicate';
        }

        //Check for required fields
        Boolean missingFields = false;
        if(!invalid && !duplicate && (know.Environment_Details__c == null || know.Cause__c == null || know.Resolution__c == null)){
            missingFields = true;
            returnString = 'Missing Field';
        }

        Knowledge__kav insertKnow = new Knowledge__kav();
        Id breakFixRecordTypeId = Knowledge__kav.sObjectType.getDescribe().getRecordTypeInfosByName().get('Break Fix').getRecordTypeId();
        if(!duplicate && !missingFields && !invalid){
            insertKnow.Title = know.Title;
            insertKnow.UrlName = know.UrlName;
            insertKnow.Summary = know.Summary;
            insertKnow.Environment_Details__c = know.Environment_Details__c;
            insertKnow.Cause__c = know.Cause__c;
            insertKnow.Resolution__c = know.Resolution__c;
            insertKnow.Origin_Case__c = know.Origin_Case__c;
            insertKnow.Community_Board__c = know.Community_Board__c;
            insertKnow.Community_Labels__c = know.Community_Labels__c;
            insertKnow.RecordTypeId = breakFixRecordTypeId;
            try{
                insert insertKnow;
            }
            catch(exception ex){
                system.debug('inside catch exception');
                //know.addError('Unable to add Knowledge');
            }
        }
        //return insertKnow;
        return returnString;

    }

    @AuraEnabled
    public static List<String> getFieldDependencyMap(String communityBoard, String controllingField, String dependentField){
        system.debug('**CSALGADO** In getFieldDependencyMap' + communityBoard);
        Map<String,List<String>> objResults = new Map<String,List<String>>();
        List<String> labelsList = new List<String>();
        String controlField = controllingField.toLowerCase();
        String dependField = dependentField.toLowerCase();

        Map<String, Schema.SObjectField> objFieldMap =  Schema.sObjectType.Knowledge__kav.fields.getMap();
        if(!objFieldMap.containsKey(controlField) || !objFieldMap.containsKey(dependField)){
            return labelsList;
        }
        system.debug('**CSALGADO** objFieldMap contains fields');

        Schema.SObjectField dField = objFieldMap.get(dependField);
        Schema.SObjectField cField = objFieldMap.get(controlField);

        List<Schema.PicklistEntry> controlEntries = cField.getDescribe().getPicklistValues();
        List<PicklistEntryWrapper> dependEntries = wrapPicklistEntries(dField.getDescribe().getPicklistValues());

        system.debug('**CSALGADO** Past wrapPicklistEntries');

        List<String> controllingValues = new List<String>();
        for (Schema.PicklistEntry ple : controlEntries) {
            String label = ple.getLabel();
            objResults.put(label, new List<String>());
            controllingValues.add(label);
        }

        for (PicklistEntryWrapper plew : dependEntries) {
            String label = plew.label;
            String validForBits = base64ToBits(plew.validFor);
            for (Integer i = 0; i < validForBits.length(); i++) {
                String bit = validForBits.mid(i, 1);
                if (bit == '1') {
                    objResults.get(controllingValues.get(i)).add(label);
                }
            }
        }

        if(objResults.containsKey(communityBoard)) {
            system.debug('**CSALGADO** objResults contains ' + communityBoard);
            labelsList = objResults.get(communityBoard);
        }

        return labelsList;
    }

    public static String decimalToBinary(Integer val) {
        String bits = '';
        while (val > 0) {
            Integer remainder = Math.mod(val, 2);
            val = Integer.valueOf(Math.floor(val / 2));
            bits = String.valueOf(remainder) + bits;
        }
        return bits;
    }

    public static String base64ToBits(String validFor) {
        if (String.isEmpty(validFor)) return '';

        String validForBits = '';

        for (Integer i = 0; i < validFor.length(); i++) {
            String thisChar = validFor.mid(i, 1);
            Integer val = base64Chars.indexOf(thisChar);
            String bits = decimalToBinary(val).leftPad(6, '0');
            validForBits += bits;
        }

        return validForBits;
    }

    private static final String base64Chars = '' +
            'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
            'abcdefghijklmnopqrstuvwxyz' +
            '0123456789+/';

    private static List<PicklistEntryWrapper> wrapPicklistEntries(List<Schema.PicklistEntry> PLEs) {
        return (List<PicklistEntryWrapper>)
                JSON.deserialize(JSON.serialize(PLEs), List<PicklistEntryWrapper>.class);
    }

    public class PicklistEntryWrapper{
        public String active {get;set;}
        public String defaultValue {get;set;}
        public String label {get;set;}
        public String value {get;set;}
        public String validFor {get;set;}
        public PicklistEntryWrapper(){
            System.debug('In PicklistEntryWrapper Constructor');
        }
    }
}