/**
 * Created by chris on 1/16/2020.
 */

public with sharing class UploadExternalImageController {
    @AuraEnabled
    public static boolean insertExternalImageURL(String kavId, String externalURL){
        system.debug('**CSALGADO** UploadExternalImageController.insertExternalImageURL: ' + kavId + ' / ' + externalURL);

        Knowledge__kav kav = [SELECT Custom_Knowledge_Article__c FROM Knowledge__kav WHERE Id = :kavId LIMIT 1];
        External_Image_URL__c eiu = new External_Image_URL__c();
        eiu.Custom_Knowledge_Article__c = kav.Custom_Knowledge_Article__c;
        eiu.External_URL__c = externalURL;

        insert eiu;
        return true;

    }

    @AuraEnabled
    public static Id insertExternalImageURL2(String kavId){
        system.debug('**CSALGADO** UploadExternalImageController.insertExternalImageURL: ' + kavId);

        Knowledge__kav kav = [SELECT Custom_Knowledge_Article__c FROM Knowledge__kav WHERE Id = :kavId LIMIT 1];
        External_Image_URL__c eiu = new External_Image_URL__c();
        eiu.Custom_Knowledge_Article__c = kav.Custom_Knowledge_Article__c;
        eiu.External_URL__c = 'Uploading...';

        insert eiu;
        return eiu.Id;

    }

    @AuraEnabled
    public static String sendExternalImageRequest(String content, String eiuId){
        system.debug('**CSALGADO** UploadExternalImageController.sendExternalImageRequest: ' + content);

        // NEW TEST CODE
        JSONGenerator generator = JSON.createGenerator(true);
        generator.writeStartObject();
            generator.writeFieldName('data');
            generator.writeStartObject();
                generator.writeStringField('type', 'image');
                generator.writeStringField('eiuId', eiuId);
                generator.writeStringField('image', content.substringafter(','));
                //Test Code Start
                generator.writeStringField('attachid', '');
                generator.writeStringField('ckaid', '');
                generator.writeStringField('text', '');
                generator.writeFieldName('contentversionid');
                generator.writeStartArray();
                    generator.writeString('');
                generator.writeEndArray();
                generator.writeStringField('communityid', '');
                generator.writeStringField('subject', '');
                generator.writeStringField('body', '');
                generator.writeStringField('teaser', '');
                generator.writeStringField('labels', '');
                generator.writeStringField('author', '');
                generator.writeFieldName('board');
                generator.writeStartObject();
                    generator.writeStringField('id', '');
                generator.writeEndObject();
                //Test Code End
            generator.writeEndObject();
        generator.writeEndObject();
        String jsonString = generator.getAsString();
        System.debug('**CSALGADO** Test JSON String = ' + jsonString);
        // END TEST CODE

        //Final
       // final String url = label.test_login; // only for UAT purpose
        final String url = label.boomi_knowledge_login; // for Prod
        Http boomiListener = new Http();
        HttpRequest requestListener = new HttpRequest();
        String findReturnStatus = '';

        requestListener.setEndpoint(url);
        requestListener.setMethod('POST');
        requestListener.setBody(jsonString);
        //requestListener.setBody(content);
        requestListener.setTimeout(120000);

        if (!Test.isRunningTest()) {
            HttpResponse response = boomiListener.send(requestListener);
            findReturnStatus = response.getStatus();

            System.Debug(findReturnStatus);
        }
        return findReturnStatus;
    }

    @AuraEnabled
    public static List<External_Image_URL__c> getExternalImageURLs (String kavId){
        return [Select Id, External_URL__c
                From External_Image_URL__c
                Where Custom_Knowledge_Article__c
                        IN (Select Custom_Knowledge_Article__c From Knowledge__kav Where Id = :kavId)];
    }
}