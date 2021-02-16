/*
*Author:Chris Salgado
*Date:05/10/19
*Description:This is a static variable class that is used to keep track of a list of License Products that we need to resend to
* boomi for integration.  The reason this was created was because there is a before trigger on updating the Quote, then every
* License Product will be added to the resend to boomi list for after update.
*/
public class ResendToBoomiList {
    public static List<License_Product__c> finalLicProdList = new List<License_Product__c>();
    public static List<License_Product_Update__c> finalLicProdUpdateList = new List<License_Product_Update__c>(); //Eddie Wong || 09/16/2020 || W-005994 || To resend License Product Update to Boomi

    public static void licProdList2Update(List<License_Product__c> licProdList) {
        finalLicProdList = licProdList;
    }

    //Eddie Wong || 09/16/2020 || W-005994 || To resend License Product Update to Boomi
    public static void licProdUpdateList2Update(List<License_Product_Update__c> licProdUpdateList) {
        finalLicProdUpdateList = licProdUpdateList;
    }
}