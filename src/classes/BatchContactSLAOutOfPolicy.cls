global without sharing class  BatchContactSLAOutOfPolicy implements Database.Batchable<sObject>, Database.Stateful {
    
    global BatchContactSLAOutOfPolicy() {
    }
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        String converted = '4 - Converted';
        
        String query = 'Select Id, OwnerId, LastModifiedDate, DG_Lead_Status__c,  Warm_SLA_Date__c, Hot_SLA_Date__c, Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c FROM Contact'
            + ' Where (Hot_SLA_Date__c >= 2020-02-19 OR Warm_SLA_Date__c >= 2020-02-19) AND ((Business_Days_Since_Warm_SLA__c > 0 AND Business_Days_Since_Warm_SLA__c <= 22) OR (Business_Days_Since_Hot_SLA__c > 0 AND Business_Days_Since_Hot_SLA__c <= 22)) AND Contact_Status__c !=: converted limit 50000';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Contact> contactRecords) {
        system.debug('BatchContactSLAOutOfPolicy contactRecords ' + contactRecords);
       List<Contact> contactsToUpdateList = new List<Contact>();
       List<DispensationWarmSLA__c> dwSLACustomSetting = DispensationWarmSLA__c.getall().values();
        List<DispensationHotSLA__c> dhSLACustomSetting = DispensationHotSLA__c.getall().values();
        List<ConversionWarmSLA__c> cwSLACustomSetting = ConversionWarmSLA__c.getall().values();
        List<ConversionHotSLA__c> chSLACustomSetting = ConversionHotSLA__c.getall().values();
        Set<String> dwslaDGStatus = new Set<String>();
        Set<String> dhslaDGStatus = new Set<String>();
        Set<String> cwslaDGStatus = new Set<String>();
        Set<String> chslaDGStatus = new Set<String>();
       
        for(DispensationWarmSLA__c dswsla : dwSLACustomSetting)
        {
            dwslaDGStatus.add(dswsla.DG_Status__c);
        }

        for(DispensationHotSLA__c dshsla : dhSLACustomSetting)
        {
            dhslaDGStatus.add(dshsla.DG_Status__c);
        }

        for(ConversionWarmSLA__c cwsla : cwSLACustomSetting)
        {
            cwslaDGStatus.add(cwsla.DG_Status__c);
        }
 
        for(ConversionHotSLA__c chsla : chSLACustomSetting)
        {
            chslaDGStatus.add(chsla.DG_Status__c);
        }

        for(Contact c : contactRecords)
        {
            //Sergio Flores
            //Date: 01/06/2020
            //W-013773
           String startDate = System.label.PDGGoLiveDate;
            Date goliveDate = Date.valueOf(startDate); 
            system.debug('goLiveDate ' + goLiveDate + ' Hot_SLA_Date__c ' + c.Hot_SLA_Date__c);

            if( (c.Hot_SLA_Date__c >= goliveDate) || (c.Warm_SLA_Date__c >= goliveDate))
            {
                if(c.Dispensation_SLA_QL__c  == 'Warm SLA In-policy' && c.Business_Days_Since_Warm_SLA__c >= 2 && !dwslaDGStatus.contains(c.DG_Lead_Status__C)) 
                {
                    c.Dispensation_SLA_QL__c = 'Warm SLA Out-of-policy';
                    contactsToUpdateList.add(c);
                }
                else if (c.Dispensation_SLA_QL__c == 'Hot SLA In-Policy' && c.Business_Days_Since_Hot_SLA__c >= 1 && !dhslaDGStatus.contains(c.DG_Lead_Status__C))
                {
                    c.Dispensation_SLA_QL__c = 'Hot SLA Out-of-policy';
                    contactsToUpdateList.add(c);
                }
                else if (c.Conversion_SLA_QL__c == 'Warm SLA In-policy' && c.Business_Days_Since_Warm_SLA__c >= 21 && !cwslaDGStatus.contains(c.DG_Lead_Status__C))
                {
                    c.Conversion_SLA_QL__c = 'Warm SLA Out-of-policy';
                    contactsToUpdateList.add(c); 
                }
                else if (c.Conversion_SLA_QL__c == 'Hot SLA In-Policy' && c.Business_Days_Since_Hot_SLA__c >= 14 && !chslaDGStatus.contains(c.DG_Lead_Status__C))
                {
                    c.Conversion_SLA_QL__c = 'Hot SLA Out-of-policy';
                    contactsToUpdateList.add(c);
                }
            }
        }

        if(!contactsToUpdateList.isEmpty())
        {
            try {
                    update contactsToUpdateList;
                } catch(Exception ex){
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
                }  
        }
        
        
        
    }
    
    global void finish(Database.BatchableContext bc) {
        
        
        
        
    }

}