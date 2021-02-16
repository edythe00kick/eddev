/**
 * Created by chris on 1/8/2020.
 */

public class DellBoomiKnowledge {

    @future(callout=true)
    public static void buildRequest(Set<Id> ckasForCall, Set<ID> kavsForCall) {
        System.debug('**CSALGADO**: In DellBoomiKnowledge buildRequest ');
        //List of KAVs
        List<Knowledge__kav> kavsList = [SELECT Id, Title, Summary, Environment_Details__c, Cause__c, Resolution__c, Community_Article_Body__c, Community_Author__c, Community_Board_Id__c, Community_Labels__c, Custom_Knowledge_Article__c, RecordTypeId
        FROM Knowledge__kav
        WHERE Id IN :kavsForCall];

        //Map of KAVs to Set of Labels
        Map<Id, Set<String>> kavIdToSetofLabels = new Map<Id, Set<String>>();

        for(Knowledge__DataCategorySelection dcSelection : [SELECT Id, ParentId, DataCategoryName FROM Knowledge__DataCategorySelection WHERE ParentId IN :kavsForCall]){
            if(kavIdToSetofLabels.containsKey(dcSelection.ParentId)) {
                Set<String> tempSet = kavIdToSetofLabels.get(dcSelection.ParentId);
                tempSet.add(dcSelection.DataCategoryName);
            }
            else{
                Set<String> permSet = new Set<String>();
                permSet.add(dcSelection.DataCategoryName);
                kavIdToSetofLabels.put(dcSelection.ParentId, permSet);
            }
        }
        System.debug('**CSALGADO** Labels Size: ' + kavIdToSetofLabels.size());

        //Map of CKAs
        Map<Id, Custom_Knowledge_Article__c> ckaMap = new Map<Id, Custom_Knowledge_Article__c>([SELECT Id, Community_Id__c, Send_to_Community__c, Last_Community_Upload__c
        FROM Custom_Knowledge_Article__c
        WHERE Id IN :ckasForCall]);

        Map<Id, Set<Id>> kavIdToCDIdSetMap = new Map<Id, Set<Id>>();
        for( ContentDocumentLink cdl : [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM Knowledge__kav WHERE Id IN :kavsList)]){
            if(kavIdToCDIdSetMap.containskey(cdl.LinkedEntityId)){
                Set<Id> tempSet = kavIdToCDIdSetMap.get(cdl.LinkedEntityId);
                tempSet.add(cdl.ContentDocumentId);
            }
            else{
                Set<Id> permSet = new Set<Id>();
                permSet.add(cdl.ContentDocumentId);
                kavIdToCDIdSetMap.put(cdl.LinkedEntityId, permSet);
            }
        }
        System.debug('**CSALGADO** kavIdToCDIdSetMap Size: ' + kavIdToCDIdSetMap.size());

        //Map of CDLs
        Map<Id, ContentDocumentLink> cdlMap = new Map<Id, ContentDocumentLink>([SELECT Id, LinkedEntityId, ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId
                IN (SELECT Id FROM Knowledge__kav WHERE Id IN :kavsList)]);
        System.debug('**CSALGADO** cdlMap Size: ' + cdlMap.size());

        //Set of CD Ids
        Set<Id> cdIds = new Set<Id>();
        for(ContentDocumentLink cdl : cdlMap.values()){
            cdIds.add(cdl.ContentDocumentId);
        }

        //Datetime to filter the CVs query to only created after the last upload date
        Datetime newDT = Datetime.newInstance(0);
        if(ckaMap.containsKey(kavsList[0].Custom_Knowledge_Article__c) && ckaMap.get(kavsList[0].Custom_Knowledge_Article__c).Last_Community_Upload__c != null){
            newDT = ckaMap.get(kavsList[0].Custom_Knowledge_Article__c).Last_Community_Upload__c;
        }

        //Map KAV to Set of CVIds
        Map<Id, Set<Id>> kavToSetOfCVIdsMap = new Map<Id, Set<Id>>();
        for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId IN :cdIds AND CreatedDate > :newDT]){
            if(cdlMap.containsKey(cv.ContentDocumentId)){
                if(kavToSetOfCVIdsMap.containsKey(cdlMap.get(cv.ContentDocumentId).LinkedEntityId)){
                    Set<Id> tempSet = kavToSetOfCVIdsMap.get(cdlMap.get(cv.ContentDocumentId).LinkedEntityId);
                    tempSet.add(cv.Id);
                }
                else{
                    Set<Id> permSet = new Set<Id>();
                    permSet.add(cv.Id);
                    kavToSetOfCVIdsMap.put(cdlMap.get(cv.ContentDocumentId).LinkedEntityId, permSet);
                }
            }
            else{
                system.debug('**CSALGADO** - No Content Document Link for this Content Version\'s ContentDocumentId');
            }
        }

        //Map CDId to Set of CVIds
        Map<Id, Id> cdIdToCVIdMap = new Map<Id, Id>();
        Set<Id> querySetCDIds = kavIdToCDIdSetMap.containsKey(kavsList[0].Id)? kavIdToCDIdSetMap.get(kavsList[0].Id): new Set<Id>();
        for(ContentVersion cv : [SELECT Id, ContentDocumentId FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId IN :querySetCDIds /*AND CreatedDate > :newDT*/]) {
            if(kavIdToCDIdSetMap.containsKey(kavsList[0].Id) && kavIdToCDIdSetMap.get(kavsList[0].Id).contains(cv.ContentDocumentId)){
                cdIdToCVIdMap.put(cv.ContentDocumentId, cv.Id);
            }
            else{
                system.debug('**CSALGADO** - No Content Document Link for this Content Version\'s ContentDocumentId');
            }
        }

        //Map KAV to Set of CVIds
        Map<Id, Set<Id>> kavIdToSetOfCVIdsMap = new Map<Id, Set<Id>>();
        if(kavIdToCDIdSetMap.containsKey(kavsList[0].Id)){
            for(Id cdId : kavIdToCDIdSetMap.get(kavsList[0].Id)){
                if(cdIdToCVIdMap.containsKey(cdId)) {
                    if (kavIdToSetOfCVIdsMap.containsKey(kavsList[0].Id)){
                        Set<Id> tempSet = kavIdToSetOfCVIdsMap.get(kavsList[0].Id);
                        tempSet.add(cdIdToCVIdMap.get(cdId));
                    }
                    else{
                        Set<Id> permSet = new Set<Id>();
                        permSet.add(cdIdToCVIdMap.get(cdId));
                        kavIdToSetOfCVIdsMap.put(kavsList[0].Id, permSet);
                    }
                }
            }
        }

        //Build HTTP Request
        if(!kavsList.isEmpty()) {

            //Test JSON Generator
            JSONGenerator generator = JSON.createGenerator(true);
            generator.writeStartObject();
            generator.writeFieldName('data');
            generator.writeStartObject();
            generator.writeStringField('type', 'message');
            generator.writeStringField('ckaid', kavsList[0].Custom_Knowledge_Article__c);

            if(kavIdToSetOfCVIdsMap.containsKey(kavsList[0].Id) && kavIdToSetOfCVIdsMap.get(kavsList[0].Id).size() > 0 /*&& cdIdToSetOfCVIdsMap.containsKey(kavIdToCDIdSetMap.get(kavsList[0].Id))*/) {
                generator.writeFieldName('contentversionid');
                generator.writeStartArray();
                for (Id cvId : kavIdToSetOfCVIdsMap.get(kavsList[0].Id)/*cdIdToSetOfCVIdsMap.get(kavIdToCDIdSetMap.get(kavsList[0].Id))*/){
                    generator.writeString(cvId);
                }
                generator.writeEndArray();
            }

            if(ckaMap.containsKey(kavsList[0].Custom_Knowledge_Article__c) && ckaMap.get(kavsList[0].Custom_Knowledge_Article__c).Community_Id__c != null) {
                generator.writeStringField('communityid', ckaMap.get(kavsList[0].Custom_Knowledge_Article__c).Community_Id__c);
            }

            //Name: Chris Salgado Date: 3/25/2020 Purpose: W-0000?
            generator.writeStringField('subject', kavsList[0].Title.unescapeHtml4());

            String recordTypeName = Schema.getGlobalDescribe().get('Knowledge__kav').getDescribe().getRecordTypeInfosById().get(kavsList[0].RecordTypeId).getName();
            String kavBody = '';
            switch on recordTypeName{
                when 'Break Fix' {
                    kavBody = '<h2>Environment Details</h2> <br> ' + kavsList[0].Environment_Details__c + '<br><br> <h2>Cause</h2> <br> ' + kavsList[0].Cause__c + '<br><br> <h2>Resolution</h2> <br> ' + kavsList[0].Resolution__c;
                }
                when 'How To'{
                    kavBody = kavsList[0].Community_Article_Body__c;
                }
                when else{
                    kavBody = '';
                }
            }

            //Fix the issue with broken inline images
            kavBody.replace('https://communitydev.alteryx.com', '');

            //Name: Chris Salgado Date: 3/17/2020 Purpose: W-004791
            //kavBody = kavBody.unescapeHtml4();
            generator.writeStringField('body', kavBody.unescapeHtml4());
            //Test Code Start
            //Name: Chris Salgado Date: 3/25/2020 Purpose: W-0000?
            generator.writeStringField('teaser', kavsList[0].Summary != null? kavsList[0].Summary.unescapeHtml4() :'' );
            String labelsString = '';
            if(kavIdToSetofLabels != null && !kavIdToSetofLabels.isEmpty()) {
                if (kavIdToSetofLabels.get(kavsList[0].Id).size() < 2) {
                    labelsString = new List<String>(kavIdToSetofLabels.get(kavsList[0].Id)).get(0);
                } else {
                    boolean first = true;
                    for (String tempLabel : kavIdToSetofLabels.get(kavsList[0].Id)) {
                        if (first) {
                            labelsString = tempLabel;
                            first = false;
                        } else {
                            labelsString = labelsString + ', ' + tempLabel;
                        }
                    }
                }
            }
            //Replace _ with ' '
            labelsString = labelsString.replace('_', ' ');
            String labelsString2 = kavsList[0].Community_Labels__c;
            labelsString2 = labelsString2.replace(';', ',');
            //Name: Chris Salgado Date: 3/25/2020 Purpose: W-0000?
            generator.writeStringField('labels', labelsString2.unescapeHtml4());

            String communityAuthor = 'SonaliM';
            if(kavsList[0].Community_Author__c != null) {
                communityAuthor = [SELECT Id, Name FROM LiSFIntegration__Li_Community_User__c WHERE Id = :kavsList[0].Community_Author__c].Name;
                generator.writeStringField('author', 'login/' + communityAuthor);
            }
            else{
                generator.writeStringField('author', communityAuthor);
            }

            generator.writeFieldName('board');
            generator.writeStartObject();
            generator.writeStringField('id', kavsList[0].Community_Board_Id__c);
            generator.writeEndObject();
            generator.writeEndObject();
            generator.writeEndObject();
            String jsonString = generator.getAsString();
            System.debug('**CSALGADO** Test JSON String = ' + jsonString);

            final String url = label.boomi_knowledge_login;
            Http boomiListener = new Http();
            HttpRequest requestListener = new HttpRequest();
            String findReturnStatus;

            requestListener.setEndpoint(url);
            requestListener.setMethod('POST');
            requestListener.setBody(jsonString);
            requestListener.setTimeout(120000);

            if (!Test.isRunningTest()) {
                HttpResponse response = boomiListener.send(requestListener);
                findReturnStatus = response.getStatus();

                System.Debug(findReturnStatus);
            }
        }

        //Uncheck Send To Community on CKAs
        List<Custom_Knowledge_Article__c> ckasResponseUpdate = new List<Custom_Knowledge_Article__c>();
        for (Id ckaId : ckasForCall) {
            Custom_Knowledge_Article__c ckaToUpdate = new Custom_Knowledge_Article__c(Id = ckaId);
            ckaToUpdate.Send_to_Community__c = false;
            ckasResponseUpdate.add(ckaToUpdate);
        }

        if (!ckasResponseUpdate.isEmpty()) {
            update ckasResponseUpdate;
        }
    }

    @future(callout=true)
    public static void BoardRequest (Set<Id> ckasForBoard, Set<ID> kavsForBoard){
        System.debug('**EWONG**: In DellBoomiKnowledge BoardRequest ');
        //List of KAVs
        List<Knowledge__kav> kavsList = [SELECT Id, Title, Environment_Details__c, Cause__c, Resolution__c, Community_Article_Body__c, Community_Board_Id__c, Community_Labels__c, Custom_Knowledge_Article__c, RecordTypeId
                                        FROM Knowledge__kav
                                        WHERE Id IN :kavsForBoard];

        //Map of CKAs
        Map<Id, Custom_Knowledge_Article__c> ckaMap = new Map<Id, Custom_Knowledge_Article__c>([SELECT Id, Community_Id__c, Send_to_Community__c, Last_Community_Upload__c
                                                                                                FROM Custom_Knowledge_Article__c
                                                                                                WHERE Id IN :ckasForBoard]);

        if(!kavsList.isEmpty()){
            //NEW TEST CODE
            JSONGenerator generator2 = JSON.createGenerator(true);
            generator2.writeStartObject();
            generator2.writeFieldName('data');
            generator2.writeStartObject();
            generator2.writeStringField('type', 'board');
            generator2.writeStringField('ckaid', kavsList[0].Custom_Knowledge_Article__c);
            if (ckaMap.containsKey(kavsList[0].Custom_Knowledge_Article__c) && ckaMap.get(kavsList[0].Custom_Knowledge_Article__c).Community_Id__c != null) {
                generator2.writeStringField('communityid', ckaMap.get(kavsList[0].Custom_Knowledge_Article__c).Community_Id__c);
            }
            generator2.writeFieldName('board');
            generator2.writeStartObject();
            generator2.writeStringField('id', kavsList[0].Community_Board_Id__c);
            generator2.writeEndObject();
            generator2.writeEndObject();
            generator2.writeEndObject();
            String jsonString = generator2.getAsString();
            System.debug('**EWONG** Test Archive JSON String = ' + jsonString);
            //END TEST CODE

            //Final
            final String url = label.boomi_knowledge_login;
            Http boomiListener = new Http();
            HttpRequest requestListener = new HttpRequest();
            String findReturnStatus;

            requestListener.setEndPoint(url);
            requestListener.setMethod('POST');
            requestListener.setBody(jsonString);
            requestListener.setTimeout(120000);

            if(!Test.isRunningTest()){
                HttpResponse response = boomiListener.send(requestListener);
                findReturnStatus = response.getStatus();

                System.debug(findReturnStatus);
            }
        }
    }

    @future(callout=true)
    public static void labelRequest (Set<Id> ckasForLabels, Set<ID> kavsForLabels){
        System.debug('**CSALGADO**: In DellBoomiKnowledge labelRequest ');
        //List of KAVs
        List<Knowledge__kav> kavsList = [SELECT Id, Title, Environment_Details__c, Cause__c, Resolution__c, Community_Article_Body__c, Community_Board_Id__c, Custom_Knowledge_Article__c, RecordTypeId
        FROM Knowledge__kav
        WHERE Id IN :kavsForLabels];

        //Map of CKAs
        Map<Id, Custom_Knowledge_Article__c> ckaMap = new Map<Id, Custom_Knowledge_Article__c>([SELECT Id, Community_Id__c, Send_to_Community__c, Last_Community_Upload__c
        FROM Custom_Knowledge_Article__c
        WHERE Id IN :ckasForLabels]);

        //Map of KAVs to Set of Labels
        Map<Id, Set<String>> kavIdToSetofLabels = new Map<Id, Set<String>>();
        for(Knowledge__DataCategorySelection dcSelection : [SELECT Id, ParentId, DataCategoryName FROM Knowledge__DataCategorySelection WHERE ParentId IN :kavsForLabels]){
            if(kavIdToSetofLabels.containsKey(dcSelection.ParentId)) {
                Set<String> tempSet = kavIdToSetofLabels.get(dcSelection.ParentId);
                tempSet.add(dcSelection.DataCategoryName);
            }
            else{
                Set<String> permSet = new Set<String>();
                permSet.add(dcSelection.DataCategoryName);
                kavIdToSetofLabels.put(dcSelection.ParentId, permSet);
            }
        }
        System.debug('**CSALGADO** Labels Size: ' + kavIdToSetofLabels.size());

        if(!kavIdToSetofLabels.isEmpty() && kavIdToSetofLabels.containsKey(kavsList[0].Id)) {

            // NEW TEST CODE
            JSONGenerator generator2 = JSON.createGenerator(true);
            generator2.writeStartObject();
            generator2.writeFieldName('data');
            generator2.writeStartObject();
            generator2.writeStringField('type', 'label');
            generator2.writeStringField('text', new List<String>(kavIdToSetofLabels.get(kavsList[0].Id)).get(0));
            if (ckaMap.containsKey(kavsList[0].Custom_Knowledge_Article__c) && ckaMap.get(kavsList[0].Custom_Knowledge_Article__c).Community_Id__c != null) {
                generator2.writeStringField('communityid', ckaMap.get(kavsList[0].Custom_Knowledge_Article__c).Community_Id__c);
            }
            generator2.writeEndObject();
            generator2.writeEndObject();
            String jsonString2 = generator2.getAsString();
            System.debug('**CSALGADO** Test Label JSON String 2 = ' + jsonString2);
            // END TEST CODE

            //Final
            final String url = label.boomi_knowledge_login;
            Http boomiListener = new Http();
            HttpRequest requestListener = new HttpRequest();
            String findReturnStatus;

            requestListener.setEndpoint(url);
            requestListener.setMethod('POST');
            requestListener.setBody(jsonString2);
            requestListener.setTimeout(120000);

            if (!Test.isRunningTest()) {
                HttpResponse response = boomiListener.send(requestListener);
                findReturnStatus = response.getStatus();

                System.Debug(findReturnStatus);
            }
        }
    }

    @future(callout=true)
    public static void archiveRequest (Set<Id> ckasForArchive, Set<ID> kavsForArchive, Boolean restore){
        System.debug('**CSALGADO**: In DellBoomiKnowledge archiveRequest ');
        //List of KAVs
        List<Knowledge__kav> kavsList = [SELECT Id, Title, Environment_Details__c, Cause__c, Resolution__c, Community_Article_Body__c, Community_Board_Id__c, Custom_Knowledge_Article__c, RecordTypeId
        FROM Knowledge__kav
        WHERE Id IN :kavsForArchive];
        System.debug('**CSALGADO** kavsList: ' + kavsList);

        //Map of CKAs
        Map<Id, Custom_Knowledge_Article__c> ckaMap = new Map<Id, Custom_Knowledge_Article__c>([SELECT Id, Community_Id__c, Send_to_Community__c, Last_Community_Upload__c
        FROM Custom_Knowledge_Article__c
        WHERE Id IN :ckasForArchive]);
        System.debug('**CSALGADO** ckaMap: ' + ckaMap);

        if(!kavsList.isEmpty()) {
            // NEW TEST CODE
            JSONGenerator generator2 = JSON.createGenerator(true);
            generator2.writeStartObject();
            generator2.writeFieldName('data');
            generator2.writeStartObject();
            generator2.writeStringField('type', 'archive');
            if (ckaMap.containsKey(kavsList[0].Custom_Knowledge_Article__c) && ckaMap.get(kavsList[0].Custom_Knowledge_Article__c).Community_Id__c != null) {
                generator2.writeStringField('communityid', ckaMap.get(kavsList[0].Custom_Knowledge_Article__c).Community_Id__c);
            }
            generator2.writeFieldName('board');
            generator2.writeStartObject();
            generator2.writeStringField('id', restore?  kavsList[0].Community_Board_Id__c: 'internalkb-archive');
            generator2.writeEndObject();
            generator2.writeEndObject();
            generator2.writeEndObject();
            String jsonString = generator2.getAsString();
            System.debug('**CSALGADO** Test Archive JSON String = ' + jsonString);
            // END TEST CODE

            //Final
            final String url = label.boomi_knowledge_login;
            Http boomiListener = new Http();
            HttpRequest requestListener = new HttpRequest();
            String findReturnStatus;

            requestListener.setEndpoint(url);
            requestListener.setMethod('POST');
            requestListener.setBody(jsonString);
            requestListener.setTimeout(120000);

            if (!Test.isRunningTest()) {
                HttpResponse response = boomiListener.send(requestListener);
                findReturnStatus = response.getStatus();

                System.Debug(findReturnStatus);
            }
        }
    }
}