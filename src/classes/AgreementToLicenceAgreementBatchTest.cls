/* Author: Sharma Nemani | W-013322
 * Date: 10/04/2019
 * Description: This is the test class for "AgreementToLicenseAgreementBatch" batch class.
*/
@isTest
public class AgreementToLicenceAgreementBatchTest {
    @testSetup static void setup() {
        Apttus__APTS_Agreement__c  agr = new Apttus__APTS_Agreement__c();
        agr.Name = 'test';
		insert agr;
        
        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=agr.id;
        insert attach;
        
        License_Agreement__c  la = new License_Agreement__c();
        //la.Name = 'test';
        la.OSCPQ_External_Id__c = agr.Id;
        insert la;
        
            
    }
    @isTest static void testMethod1() {
        Test.startTest();
        	database.executeBatch(new AgreementToLicenceAgreementBatch(),1);
        Test.stopTest();
    }
}