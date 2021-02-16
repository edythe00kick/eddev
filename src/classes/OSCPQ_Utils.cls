/* Utilities used for CPQ Customizations and used by the Original Shift Implementation Package
 * 
 */
public with sharing class OSCPQ_Utils {
    /* 
     * Class that retrieves all setting fields for the given specified CPQ Metadata record.
     * All CPQ unmanaged package classes should call this method rather than directly fetching the settings
     */
    public static CPQ_Setting__mdt getContractSettings(String apiName){
        CPQ_Setting__mdt settings;
        
        try{
	        settings = [SELECT  Contracting_AutomaticActivation__c,
                        		Contracting_GenerationPoint__c,
                        		Ordering_AutomaticActivation__c,
                                AutoForecast_Enabled__c,
                        		AutoForecast_Timing__c,
                                AutoForecast_NumDays__c,
                                AutoForecast_ReferenceField__c,
                                AutoRenewQuote_Enabled__c,
                        		AutoRenewQuote_Timing__c,
                                AutoRenewQuote_NumDays__c,
                                AutoRenewQuote_ReferenceField__c,
                        		RenewCoTerm_DeforecastOrphans__c,
                        		RenewalCoTerm_DeforecastAsync__c,
                         		Quoting_Automate_Quote_Steps__c,
                        		TwinMapping_MapFromContractToQuote__c,
                        		TwinMapping_PrimaryQuoteToOpp__c,
                        		TwinMapping_MapToContract__c,
                                TwinMapping_CloneQuoteGroups__c
                        FROM CPQ_Setting__mdt 
                        WHERE QualifiedApiName = :apiName
                       ];
        }
        catch(exception e){
            System.debug('An exception occurred in CPQ_Utils.getContractSettings: ' + e.getMessage());
            createQTCError('Could not fetch relevant CPQ Metadata of API Name ' + apiName,
                                'CPQ',
                                'Fetching Metadata',
                                'CPQ_Utils.getContractSettings',
                                e.getMessage(),
                                UserInfo.getUserId(),
                                true
                                );
        }
        
        return settings;
    }
    
    /* 
     * Class that retrieves all setting fields for the given specified CPQ Metadata record.
     * All CPQ unmanaged package classes should call this method rather than directly fetching the settings
     */
    public static CPQ_Custom_Setting__mdt getCPQCustomSettings(String apiName){
        CPQ_Custom_Setting__mdt settings;
        
        try{
	        settings = [SELECT  Months_for_Stub_Sub_Schedule__c
                        FROM CPQ_Custom_Setting__mdt 
                        WHERE QualifiedApiName = :apiName
                       ];
        }
        catch(exception e){
            System.debug('An exception occurred in CPQ_Utils.getCPQCustomSettings: ' + e.getMessage());
            createQTCError('Could not fetch relevant CPQ Custom Metadata of API Name ' + apiName,
                                'CPQ',
                                'Fetching Metadata',
                                'CPQ_Utils.getCPQCustomSettings',
                                e.getMessage(),
                                UserInfo.getUserId(),
                                true
                                );
        }
        
        return settings;
    }
    
    /*
     * Class that creates a relevant QTC Error.
     * Params:
     *   Subject = the Subject/Name of the Record
     *   targetPackage = CPQ or Billing
     *   process = name of the functionality (ex: 'Renewal Automation')
     *   classMethodName = name of the offending apex class and method (if possible)
     *   description = full description including any errors
     *   runningUser = user for which the error occured
     *   performDML = true to do an insert DML in this function.
     */
    public static OSCPQ_Error__c createQTCError(String subject, String targetPackage, String process, String classMethodName, String description, Id runningUserId, boolean performDML){
        OSCPQ_Error__c error = new OSCPQ_Error__c(OSCPQ_Subject__c = subject,
                                              OSCPQ_Package__c = targetPackage,
                                              OSCPQ_Process__c = process,
                                              OSCPQ_Class__c = classMethodName,
                                              OSCPQ_Error_Description__c = description,
                                              OSCPQ_Running_User__c = runningUserId
                                             );
        
        if(performDML){
            insert error;
        }
        
        return error;
    }
    
    /*
     * Method that creates QTC Errors from a save result.
     * Calls this class's createQTCError method.
     * Params:
     *   Subject = the Subject/Name of the Record
     *   targetPackage = CPQ or Billing
     *   process = name of the functionality (ex: 'Renewal Automation')
     *   classMethodName = name of the offending apex class and method (if possible)
     *   runningUser = user for which the error occured
     *   srList = Database.saveresult from the relevant database insert/update operation
     *   createMultipleRecords = If true, will create multiple Error Records, 1 per each failed SaveResult
     *   performDML = true to do an insert DML in this function.     
	 */
    public static List<OSCPQ_Error__c> createQTCErrorFromDMLSave(String subject, String targetPackage, String process, String classMethodName, Id runningUserId, Database.SaveResult[] srList, boolean createMultipleRecords, boolean performDML){
        List<OSCPQ_Error__c> qtcErrList = new List<OSCPQ_Error__c>();
        String[] errMessages = new String[]{};
        for(Database.SaveResult sr : srList){
            if(!sr.isSuccess()){
                errMessages.add(String.join(sr.getErrors(), '\n'));
            }
        }
        if(!errMessages.isEmpty()){
            if(!createMultipleRecords){ //Create a single error logic
            	qtcErrList.add(createQTCError(subject,
                              targetPackage,
                              process,
                              classMethodName,
                              String.join(errMessages, '\n'),
                              runningUserId,
                              false));
            }
            else{ //One error record per failed record
                for(String errMsg : errMessages){
                    qtcErrList.add(createQTCError(subject,
                              targetPackage,
                              process,
                              classMethodName,
                              errMsg,
                              runningUserId,
                              false));
                }
            }
        }
        
        if(performDML){
            insert qtcErrList;
        }
        return qtcErrList;
    }
    
    /*
     * Method that creates QTC Errors from a Delete result.
     * Calls this class's createQTCError method.
     * Params:
     *   Subject = the Subject/Name of the Record
     *   targetPackage = CPQ or Billing
     *   process = name of the functionality (ex: 'Renewal Automation')
     *   classMethodName = name of the offending apex class and method (if possible)
     *   runningUser = user for which the error occured
     *   srList = Database.deleteresult from the relevant database insert/update operation
     *   createMultipleRecords = If true, will create multiple Error Records, 1 per each failed DeleteResult
     *   performDML = true to do an insert DML in this function.     
	 */
    public static List<OSCPQ_Error__c> createQTCErrorFromDMLSave(String subject, String targetPackage, String process, String classMethodName, Id runningUserId, Database.DeleteResult[] srList, boolean createMultipleRecords, boolean performDML){
        List<OSCPQ_Error__c> qtcErrList = new List<OSCPQ_Error__c>();
        String[] errMessages = new String[]{};
        for(Database.DeleteResult sr : srList){
            if(!sr.isSuccess()){
                errMessages.add(String.join(sr.getErrors(), '\n'));
            }
        }
        if(!errMessages.isEmpty()){
            if(!createMultipleRecords){ //Create a single error logic
            	qtcErrList.add(createQTCError(subject,
                              targetPackage,
                              process,
                              classMethodName,
                              String.join(errMessages, '\n'),
                              runningUserId,
                              false));
            }
            else{ //One error record per failed record
                for(String errMsg : errMessages){
                    qtcErrList.add(createQTCError(subject,
                              targetPackage,
                              process,
                              classMethodName,
                              errMsg,
                              runningUserId,
                              false));
                }
            }
        }
        
        if(performDML){
            insert qtcErrList;
        }
        return qtcErrList;
    }
    
    /*
     * Method that twin maps from one object to another, based on a specified relational field.
     *     This 'push' method should be used when called from the 'source' object (ex: on Quote Trigger when doing Quote-->Opp)
     * Params:
     *   fromObjectRecordList: list of 'source' object records we will twin map from
     *   toObjectApiName: target object will will twin map to
     *   relationshipFieldApiName: API Name of the relationship (lookup or M-D) field on the Source object
     *   requerySourceObject: if true, will re-SOQL query to make sure that all fields are present. 
     * 	 					  Should only be false if being called from a source object's trigger.
	 */
    public static void twinMapFieldsPush(List<sObject> fromObjectRecordList, String toObjectApiName, String relationshipFieldApiName, boolean requerySourceObject) {
        String fromObjectApiName = (!fromObjectRecordList.isEmpty()) ? fromObjectRecordList[0].getSObjectType().getDescribe().getName() : null;
        
        //From/To object fields will be used so that we can successfully map from a String-->ID
        Map<String, Schema.SObjectField> fromObjectFields = Schema.getGlobalDescribe().get(fromObjectApiName).getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> toObjectFields;

        Schema.sObjectType toObjectType;
        List<Schema.DescribeSObjectResult> toObjectDescribeRes = Schema.describeSObjects(new List<String>{toObjectApiName});
        if(!toObjectDescribeRes.isEmpty()){
            toObjectType = toObjectDescribeRes[0].getSobjectType();
            toObjectFields = toObjectType.getDescribe().fields.getMap();
        }
        
        List<String> fieldNamesToTwinMapList = getTwinMappableFieldList(fromObjectApiName, toObjectApiName, relationshipFieldApiName, true);
        List<sObject> recordsToUpdateList = new List<sObject>();
                    
        if(toObjectType!= null && !fieldNamesToTwinMapList.isEmpty() && !fromObjectRecordList.isEmpty()){
            
            //If requerySourceObject is checked, then attempt to re-query via dynamic SOQL
            if(requerySourceObject){
                String queryStr = 'Select ' + String.join(fieldNamesToTwinMapList, ', ') + ', ' + relationshipFieldApiName
                    			+ ' FROM ' + fromObjectApiName + ' WHERE Id IN :fromObjectRecordList';
                
                try {
                    fromObjectRecordList = database.query(queryStr);        
                }
                catch (QueryException e) { //perform exception handling
                    OSCPQ_Error__c err = createQTCError('Failed to query fields on ' + fromObjectApiName, //String subject
                                                        'CPQ', //String targetPackage 
                                                        'TwinMapping', //String process 
                                                        'OSCPQ_Utils.twinMapFieldsPush', //String classMethodName 
                                                        'Failed to query fields on ' + fromObjectApiName + '\n' + e.getMessage(), //String description
                                                        UserInfo.getUserId(), //Id runningUserId
                                                        true //boolean performDML
                                                       );
                }
            }
            
            //Loop through the 'from' record list and push field values to the associated 'to' object
            for(sObject fromObjRecord : fromObjectRecordList){
                if(fromObjRecord.get(relationshipFieldApiName) != null){
                    sObject targetRecordToUpdate = toObjectType.newSObject(); //Create 'new' version of the to object, specifying an Id so we can upsert/update
                    
                    targetRecordToUpdate.put('Id', fromObjRecord.get(relationshipFieldApiName)); //always add an Id
                    for(String fieldNameToTwinMap : fieldNamesToTwinMapList){
                        Schema.DisplayType fromFieldType = fromObjectFields.get(fieldNameToTwinMap).getDescribe().getType();
                        Schema.DisplayType toFieldType = toObjectFields.get(fieldNameToTwinMap).getDescribe().getType();
                        //Only Twin Map if they are identical field types for identical field types, or if we are doing a valid string-->Id map
                        if(toFieldType == fromFieldType 
                            || (toFieldType == Schema.DisplayType.ID && fromFieldType == Schema.DisplayType.STRING && fromObjRecord.get(fieldNameToTwinMap) instanceOf String)
                        ) {
                            targetRecordToUpdate.put(fieldNameToTwinMap, fromObjRecord.get(fieldNameToTwinMap));
                        }
                    }

                    recordsToUpdateList.add(targetRecordToUpdate);
                }
            }
        }
        if(!recordsToUpdateList.isEmpty()){
            Recursionhandler.IsquoteUpdatedTCV = true; //There is an update from twin push so we need to sync quote tcv;
            update recordsToUpdateList;
        }
    }
    
    /*
     * Method that twin maps from one object to another, based on a specified relational field.
     *     This 'pull' method should be used when called from the 'target' object (ex: on Opp Trigger when doing Quote-->Opp)
     * Params:
     *   fromObjectRecordList: list of 'source' object records we will twin map from
     *   toObjectApiName: target object will will twin map to
     *   relationshipFieldApiNameOnTo: API Name of the relationship (lookup or M-D) field on the SOURCE object
     *   performDMLOperations: will actually perform a DML update. Usually set to False if called on a trigger from the target/from object
	 */
    public static void twinMapFieldsPull(List<sObject> toObjectRecordList, String fromObjectApiName, String relationshipFieldApiNameOnTo, boolean performDMLOperations) {
        String toObjectApiName = (!toObjectRecordList.isEmpty()) ? toObjectRecordList[0].getSObjectType().getDescribe().getName() : null;
        //From/To object fields will be used so that we can successfully map from a String-->ID
        Map<String, Schema.SObjectField> fromObjectFields = Schema.getGlobalDescribe().get(fromObjectApiName).getDescribe().fields.getMap();
        Map<String, Schema.SObjectField> toObjectFields;

        Schema.sObjectType toObjectType;
        List<Schema.DescribeSObjectResult> toObjectDescribeRes = Schema.describeSObjects(new List<String>{toObjectApiName});
        if(!toObjectDescribeRes.isEmpty()){
            toObjectType = toObjectDescribeRes[0].getSobjectType();
            toObjectFields = toObjectType.getDescribe().fields.getMap();
        }
            
        List<String> fieldNamesToTwinMapList = getTwinMappableFieldList(fromObjectApiName, toObjectApiName, null, false);
        List<sObject> fromObjectRecordList = new List<sObject>();
        Map<Id, Id> toIdToFromIdMap = new Map<Id, Id>(); //Key of 'To' record Id, Value of 'From' record Id
        Map<Id, sObject> fromIdToFromRecordMap = new Map<Id, sObject>();
                    
        if(!fieldNamesToTwinMapList.isEmpty() && !toObjectRecordList.isEmpty()){
            
            //Build map of target-to-source ids so that we can query for the source and later retrieve it
            for(sObject toObjectRecord : toObjectRecordList){
                if(toObjectRecord.get(relationshipFieldApiNameOnTo) != null){
                    toIdToFromIdMap.put((Id)toObjectRecord.get('Id'), (Id)toObjectRecord.get(relationshipFieldApiNameOnTo));
                }
            }
            //Query all relevant records/fields from the source object via dynamic SOQL
            if(!toIdToFromIdMap.isEmpty()) {
                List<Id> fromRecordIds = toIdToFromIdMap.values();
                String queryStr = 'Select ' + String.join(fieldNamesToTwinMapList, ', ') + ', Id'
                    + ' FROM ' + fromObjectApiName + ' WHERE Id IN :fromRecordIds';
                
                try {
                    fromObjectRecordList = database.query(queryStr);
                    //Build a map of the From record Id to it's associated record. Will be chained together with the target-id-to-source-id map later
                    for(sObject fromObjectRecord : fromObjectRecordList){
                        fromIdToFromRecordMap.put((Id)fromObjectRecord.get('Id'), fromObjectRecord);
                    }
                }
                catch (QueryException e) { //perform exception handling on dynamic query
                    OSCPQ_Error__c err = createQTCError('Failed to query fields on ' + fromObjectApiName, //String subject
                                                        'CPQ', //String targetPackage 
                                                        'TwinMapping', //String process 
                                                        'OSCPQ_Utils.twinMapFieldsPull', //String classMethodName 
                                                        'Failed to query fields on ' + fromObjectApiName + '\n' + e.getMessage(), //String description
                                                        UserInfo.getUserId(), //Id runningUserId
                                                        true //boolean performDML
                                                       );
                }
                
                //Loop through the 'from' record list and push field values to the associated 'to' object
                for(sObject toObjectRecord : toObjectRecordList) {                    
                    if(toObjectRecord.get(relationshipFieldApiNameOnTo) != null && toIdToFromIdMap.containsKey((Id)toObjectRecord.get('Id'))) {
                        
                        //Get the source record Id & pull in the assoicated record from the map
                        Id sourceRecordId = toIdToFromIdMap.get((Id)toObjectRecord.get('Id'));

                        if(fromIdToFromRecordMap.containsKey(sourceRecordId)) {
                            sObject fromObjectRecord = fromIdToFromRecordMap.get(sourceRecordId);
                            
                            //Actually push the field values
                            for(String fieldNameToTwinMap : fieldNamesToTwinMapList) {
                                Schema.DisplayType fromFieldType = fromObjectFields.get(fieldNameToTwinMap).getDescribe().getType();
                                Schema.DisplayType toFieldType = toObjectFields.get(fieldNameToTwinMap).getDescribe().getType();
                                //Only Twin Map if they are identical field types for identical field types, or if we are doing a valid string-->Id map
                                if(toFieldType == fromFieldType 
                                    || (toFieldType == Schema.DisplayType.ID && fromFieldType == Schema.DisplayType.STRING && fromObjectRecord.get(fieldNameToTwinMap) instanceOf String)
                                ) {
                                    toObjectRecord.put(fieldNameToTwinMap, fromObjectRecord.get(fieldNameToTwinMap));
                                }
                            }
                        }
                    }
                }
            }
        }
        if(!toObjectRecordList.isEmpty() && performDMLOperations){
            update toObjectRecordList;
        }
    }
    
    /*
     * Helper method that determines the fields that can be twin mapped for the current user.
     * Params:
     *   fromObjectRecordList: list of 'source' object records we will twin map from
     *   toObjectApiName: target object will will twin map to
     *   relationshipFieldApiName: API Name of the relationship (lookup or M-D) field on the Source object
     *   checkRelationship: If true, will not return any mappable fields if there is not a valid relationship. Set to false when there is not a direct relationship.
	 */
    private static List<String> getTwinMappableFieldList(String fromObjectApiName, String toObjectApiName, String relationshipFieldApiName, boolean checkRelationship) {
        List<String> fieldNamesToTwinMapList = new List<String>();
        Schema.sObjectType toObjectType;
        system.debug('at getTwinMappableFieldList');
        //---BEGIN DETERMINE TWIN MAPPABLE FIELDS---//
        //Pull source object fields
        Map<String, Schema.SObjectField> fromObjectFields;
        fromObjectFields = Schema.getGlobalDescribe().get(fromObjectApiName).getDescribe().fields.getMap();
        
        //Pull target object fields                
        Map<String, Schema.SObjectField> toObjectFields;
        Schema.DescribeSObjectResult toObject = Schema.getGlobalDescribe().get(toObjectApiName).getDescribe();
        toObjectFields = toObject.fields.getMap();
        
        //Only run if the 'To' Object is updatable
        if(toObject.isUpdateable()){
            //Loop through all fields on the "From" object, and see if there is a match on the "To" object
            for(String fromFieldAPIName : fromObjectFields.keySet()){
                DescribeFieldResult fromFieldDescribeRes = fromObjectFields.get(fromFieldAPIName).getDescribe();
                
                //If this is the specified relationship field, confirm that it is a valid relationship
                if(toObjectType == null && fromFieldAPIName == relationshipFieldApiName && fromFieldDescribeRes.getRelationshipName() != ''){
                    List<Schema.sObjectType> relationshipObjs = fromFieldDescribeRes.getReferenceTo();
                    if(!relationshipObjs.isEmpty() && relationshipObjs[0].getDescribe().getName() == toObjectApiName){
                        toObjectType = relationshipObjs[0];
                    }
                }
                
                //Check if the field is valid for twin mapping, and if so, then add to the mapping list. Valid = custom & non-packaged and accessible
                if(fromFieldDescribeRes.isCustom() && fromFieldDescribeRes.isAccessible() && !fromFieldDescribeRes.isExternalId() && fromFieldDescribeRes.getName() == fromFieldDescribeRes.getLocalName()) { 
                    Schema.DisplayType fromFieldType = fromFieldDescribeRes.getType();
                    
                    //If "To" object has the same field name of matching type
                    if(toObjectFields.containskey(fromFieldAPIName)) {
                        Schema.DescribeFieldResult toField = toObjectFields.get(fromFieldAPIName).getDescribe();
                        
                        //Only Twin map if the field is accessible and is not a formula field or external Id
                        if(toField.isAccessible() 
                        && toField.isUpdateable() 
                        && (toField.getType() == fromFieldType 
                            || (toField.getType() == Schema.DisplayType.ID && fromFieldType == Schema.DisplayType.STRING))
                        && !toField.isCalculated() 
                        && !toField.isExternalId()) {
                            fieldNamesToTwinMapList.add(fromFieldAPIName);
                        }
                    }
                }
            }
        }
        //---END DETERMINE TWIN MAPPABLE FIELDS---//
        if(checkRelationship == true && toObjectType == null){ //If no valid relationship was found, then clear out the list
            fieldNamesToTwinMapList.clear();
        }
        
        return fieldNamesToTwinMapList;
    }
}