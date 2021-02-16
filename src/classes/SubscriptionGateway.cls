/*
*Author:Chris Salgado
*Date:05/13/19
*Description:Subscription methods
*/
public class SubscriptionGateway{
    public static List<Account> UpdateAccountWithLicenseProduct(Set<Id> accIds) {

        Map<Id,Account> accId2Account = new Map<Id,Account>();
        Set<Id> accWithGalleyProduct = new Set<Id>();
        Set<Id> accWithDnowProduct = new Set<Id>();
        Map<Id, Set<String>> accId2LicensedProduct = new Map<Id, Set<String>>();
        List<Account> accListtobeUpdated = new List<Account>();

        for(SBQQ__Subscription__c subscript : [SELECT id
                ,SBQQ__Account__c
                ,SBQQ__Contract__c
                ,SBQQ__Contract__r.Status_Category__c
                ,SBQQ__Contract__r.Account.Id
                ,SBQQ__Contract__r.Account.Licensed_Product__c
                ,SBQQ__Product__r.Name
                ,SBQQ__Product__r.Family
        FROM SBQQ__Subscription__c
        WHERE SBQQ__Contract__r.Account.Id in : accIds
            AND SBQQ__Contract__r.Status_Category__c = 'In Effect']){

            if(!accId2Account.containsKey(subscript.SBQQ__Contract__r.Account.Id)) {

                Account a = new Account(id=subscript.SBQQ__Contract__r.Account.Id);
                a.Licensed_Product__c = subscript.SBQQ__Contract__r.Account.Licensed_Product__c;
                accId2Account.put(subscript.SBQQ__Contract__r.Account.Id,a);

            }

            if(subscript.SBQQ__Product__r.Name != null) {

                if(!accId2LicensedProduct.containsKey(subscript.SBQQ__Contract__r.Account.Id)) {

                    Set<String> prod_names = new Set<String>();
                    prod_names.add(subscript.SBQQ__Product__r.Name.trim().toLowerCase());
                    accId2LicensedProduct.put(subscript.SBQQ__Contract__r.Account.Id, prod_names);

                } else {

                    Set<String> prod_names = accId2LicensedProduct.get(subscript.SBQQ__Contract__r.Account.Id);
                    prod_names.add(subscript.SBQQ__Product__r.Name.trim().toLowerCase());
                    accId2LicensedProduct.put(subscript.SBQQ__Contract__r.Account.Id, prod_names);

                }

                if( subscript.SBQQ__Product__r.Family != NULL
                        && subscript.SBQQ__Product__r.Family == 'Gallery'
                        && !accWithGalleyProduct.contains(subscript.SBQQ__Contract__r.Account.Id)){

                    accWithGalleyProduct.add(subscript.SBQQ__Contract__r.Account.Id);

                }

                if( subscript.SBQQ__Product__r.Family != NULL
                        && subscript.SBQQ__Product__r.Family == 'DNow'
                        && !accWithDnowProduct.contains(subscript.SBQQ__Contract__r.Account.Id)){

                    accWithDnowProduct.add(subscript.SBQQ__Contract__r.Account.Id);

                }

            }

        }

        System.debug('>>>> accId2LicensedProduct:' + accId2LicensedProduct);

        for(Id accId : accIds){

            if(accId2Account.containsKey(accId)){

                Account acc = accId2Account.get(accId);
                String oldLicensedProduct = (acc.Licensed_Product__c == null)
                        ? '' : acc.Licensed_Product__c.toLowerCase().trim();

                acc.Licensed_Product__c = '';
                Boolean updateAccount = false;

                if(accId2LicensedProduct.containsKey(accId)) {

                    for(String name : accId2LicensedProduct.get(accId)) {

                        if(name.equals('alteryx enterprise solution')
                                || name.equals('alteryx unlimited enterprise license')
                                || name.equals('channel - unlimited internal use license')) {

                            acc.Licensed_Product__c = 'Unlimited Enterprise';
                            updateAccount = true;


                        } else if((name.equals('alteryx departmental solution')
                                || name.equals('alteryx unlimited departmental license'))
                                && (acc.Licensed_Product__c != 'Unlimited Enterprise')) {

                            acc.Licensed_Product__c = 'Unlimited Departmental';
                            updateAccount = true;

                        } else if((name.equals('alteryx server')
                                || name.equals('alteryx development server')
                                || name.equals('alteryx enterprise server')
                                || name.equals('alteryx private cloud server')
                                || name.equals('alteryx private cloud server (bundle)')
                                || name.equals('alteryx private server - no data')
                                || name.equals('alteryx redundant server')
                                || name.equals('alteryx runtime server')
                                || name.equals('alteryx server sandbox'))
                                && (acc.Licensed_Product__c != 'Unlimited Enterprise'
                                && acc.Licensed_Product__c != 'Unlimited Departmental')) {

                            acc.Licensed_Product__c = 'Server';
                            updateAccount = true;

                        } else if((name.equals('alteryx designer with data')
                                || name.equals('alteryx professional edition')
                                || name.equals('alteryx desktop communications edition'))
                                && (acc.Licensed_Product__c != 'Unlimited Enterprise'
                                && acc.Licensed_Product__c != 'Unlimited Departmental'
                                && acc.Licensed_Product__c != 'Server')) {

                            acc.Licensed_Product__c = 'Designer with Data';
                            updateAccount = true;

                        } else if((name.equals('alteryx designer with spatial')
                                || name.equals('alteryx desktop spatial'))
                                && (acc.Licensed_Product__c != 'Unlimited Enterprise'
                                && acc.Licensed_Product__c != 'Unlimited Departmental'
                                && acc.Licensed_Product__c != 'Server'
                                && acc.Licensed_Product__c != 'Designer with Data')) {

                            acc.Licensed_Product__c = 'Designer with Spatial';
                            updateAccount = true;

                        } else if((name.equals('alteryx designer')
                                || name.equals('alteryx designer with scheduler')
                                || name.equals('alteryx desktop (ecur/ecr only)')
                                || name.equals('alteryx for visual analytics')
                                || name.equals('alteryx professional edition no data')
                                || name.equals('alteryx personal edition'))
                                && (acc.Licensed_Product__c != 'Unlimited Enterprise'
                                && acc.Licensed_Product__c != 'Unlimited Departmental'
                                && acc.Licensed_Product__c != 'Server'
                                && acc.Licensed_Product__c != 'Designer with Data'
                                && acc.Licensed_Product__c != 'Designer with Spatial')) {

                            acc.Licensed_Product__c = 'Designer';
                            updateAccount = true;

                        } else if((name.equals('alteryx designer - partner fee'))
                                && (acc.Licensed_Product__c != 'Unlimited Enterprise'
                                && acc.Licensed_Product__c != 'Unlimited Departmental'
                                && acc.Licensed_Product__c != 'Server'
                                && acc.Licensed_Product__c != 'Designer with Data'
                                && acc.Licensed_Product__c != 'Designer with Spatial'
                                && acc.Licensed_Product__c != 'Designer')) {

                            acc.Licensed_Product__c = 'Partner Fee';
                            updateAccount = true;

                        } else if(accWithGalleyProduct.contains(accId)
                                && (acc.Licensed_Product__c != 'Unlimited Enterprise'
                                && acc.Licensed_Product__c != 'Unlimited Departmental'
                                && acc.Licensed_Product__c != 'Server'
                                && acc.Licensed_Product__c != 'Designer with Data'
                                && acc.Licensed_Product__c != 'Designer with Spatial'
                                && acc.Licensed_Product__c != 'Designer'
                                && acc.Licensed_Product__c != 'Partner Fee')) {

                            acc.Licensed_Product__c = 'Gallery';
                            updateAccount = true;

                        } else if(accWithDnowProduct.contains(accId)
                                && (acc.Licensed_Product__c != 'Unlimited Enterprise'
                                && acc.Licensed_Product__c != 'Unlimited Departmental'
                                && acc.Licensed_Product__c != 'Server'
                                && acc.Licensed_Product__c != 'Designer with Data'
                                && acc.Licensed_Product__c != 'Designer with Spatial'
                                && acc.Licensed_Product__c != 'Designer'
                                && acc.Licensed_Product__c != 'Partner Fee'
                                && acc.Licensed_Product__c != 'Gallery')) {

                            acc.Licensed_Product__c = 'DNow';
                            updateAccount = true;

                        }

                    }

                    if(updateAccount == true
                            && oldLicensedProduct != acc.Licensed_Product__c.toLowerCase()) {

                        updateAccount = TRUE;

                    } else if(updateAccount == true
                            && oldLicensedProduct == acc.Licensed_Product__c.toLowerCase()) {

                        updateAccount = false;

                    } else if(oldLicensedProduct != '' ) {

                        acc.Licensed_Product__c= '';
                        updateAccount = true;

                    }

                    if(updateAccount) {

                        accListtobeUpdated.add(acc);

                    }

                }

            } else {

                accListtobeUpdated.add(new Account(id=accId ,Licensed_Product__c= ''));

            }

        }

        return accListtobeUpdated;

    }


    // Eddie Wong
    // 06/22/2020
    // W-005163
    // Stamping Subscriptions with LP for new QL with new product
    public static void updateSubscriptionWithLicProd(Set<Id> qLineIds, Map<Id, SBQQ__Subscription__c> subIdToSubMap ){

        Map<Id, License_Product__c> licProdIdToLPMap = new Map<Id, License_Product__c>([SELECT Id, Quote_Line__c FROM License_Product__c WHERE Quote_Line__c IN : qLineIds]);

        Map<Id, License_Product__c> quoteLineIdToLicenseProductMap =  new Map<Id, License_Product__c>();

        for(License_Product__c lp : licProdIdToLPMap.values())
        {
            quoteLineIdToLicenseProductMap.put(lp.Quote_Line__c, lp);
        }


        for (SBQQ__Subscription__c sub : subIdToSubMap.values()){

            License_Product__c lp = quoteLineIdToLicenseProductMap.get(sub.SBQQ__QuoteLine__c);

            if(lp !=null)
            {
                sub.License_Product__c = lp.Id;
            }

        }


    }

    // Eddie Wong
    // 06/22/2020
    // W-005163
    // Stamping Subscriptions with LP for for existing QL with added quantity
    public static void updateSubscriptionWithLicProdWithOriginalQL(Map<Id, SBQQ__Subscription__c> qLineToOriginalQLineMap ){

        Map<Id, License_Product__c> originalQLLicProdIdToLPMap = new Map<Id, License_Product__c>([SELECT Id,Quote_Line__c FROM License_Product__c WHERE Quote_Line__c IN : qLineToOriginalQLineMap.keySet()]);

        System.debug('eddie inside originalQLLicProdIdToLPMap' + originalQLLicProdIdToLPMap);
        System.debug('eddie inside originalQLLicProdIdToLPMap' + originalQLLicProdIdToLPMap.values());

        Map<Id, License_Product__c> originalQuoteLineIdToLicenseProductMap =  new Map<Id, License_Product__c>();


        for (License_Product__c lp : originalQLLicProdIdToLPMap.values())
        {
            originalQuoteLineIdToLicenseProductMap.put(lp.Quote_Line__c, lp);
        }

        System.debug('eddie inside originalQuoteLineIdToLicenseProductMap' + originalQuoteLineIdToLicenseProductMap);


        for (SBQQ__Subscription__c sub : qLineToOriginalQLineMap.values()){

            System.debug('eddie inside originalQuoteLineIdToLicenseProductMap.get(sub)' + originalQuoteLineIdToLicenseProductMap.get(sub.SBQQ__OriginalQuoteLine__c));

            License_Product__c lp = originalQuoteLineIdToLicenseProductMap.get(sub.SBQQ__OriginalQuoteLine__c);

            System.debug('eddie inside lp check' + lp);

            if(lp !=null)
            {
                sub.License_Product__c = lp.Id;
            }


        }


    }




}