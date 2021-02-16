global without sharing class  BatchLeadSLAOutOfPolicy implements Database.Batchable<sObject>, Database.Stateful {
    
    global BatchLeadSLAOutOfPolicy() {
    }
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        String converted = '4 - Converted';
        
        String query = 'Select Id, OwnerId, LastModifiedDate, DG_Lead_Status__C, Warm_SLA_Date__c, Hot_SLA_Date__c, Dispensation_SLA_QL__c, Conversion_SLA_QL__c, Business_Days_Since_Warm_SLA__c, Business_Days_Since_Hot_SLA__c FROM Lead'
            +  ' Where (Hot_SLA_Date__c >= 2020-02-19 OR Warm_SLA_Date__c >= 2020-02-19) AND ((Business_Days_Since_Warm_SLA__c > 0 AND Business_Days_Since_Warm_SLA__c <= 22) OR (Business_Days_Since_Hot_SLA__c > 0 AND Business_Days_Since_Hot_SLA__c <= 22)) AND (Status !=: converted OR isconverted = false) limit 50000';
        return Database.getQueryLocator(query);
        
    }
    
    global void execute(Database.BatchableContext bc, List<Lead> leadRecords) {
        system.debug('BatchLeadSLAOutOfPolicy leadRecords ' + leadRecords);
        List<Lead> leadsToUpdateList = new List<Lead>();
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
       

        for(Lead l : leadRecords)
        {
            //Sergio Flores
            //Date: 01/06/2020
            //W-013773
            String startDate = System.label.PDGGoLiveDate;
            Date goliveDate = Date.valueOf(startDate); 
            system.debug('goLiveDate ' + goLiveDate + ' Hot_SLA_Date__c ' + l.Hot_SLA_Date__c);

            if( (l.Hot_SLA_Date__c >= goliveDate) || (l.Warm_SLA_Date__c >= goliveDate) )
            {
                system.debug('inside go live date');
                if(l.Dispensation_SLA_QL__c  == 'Warm SLA In-policy' && l.Business_Days_Since_Warm_SLA__c >= 2 && !dwslaDGStatus.contains(l.DG_Lead_Status__C))
                {
                    l.Dispensation_SLA_QL__c = 'Warm SLA Out-of-policy';
                    leadsToUpdateList.add(l); 
                }
                else if (l.Dispensation_SLA_QL__c == 'Hot SLA In-Policy' && l.Business_Days_Since_Hot_SLA__c >= 1 && !dhslaDGStatus.contains(l.DG_Lead_Status__C))
                {               
                    l.Dispensation_SLA_QL__c = 'Hot SLA Out-of-policy';
                    leadsToUpdateList.add(l);
                }
                else if (l.Conversion_SLA_QL__c == 'Warm SLA In-policy' && l.Business_Days_Since_Warm_SLA__c >= 21 && !cwslaDGStatus.contains(l.DG_Lead_Status__C))
                {
                    l.Conversion_SLA_QL__c = 'Warm SLA Out-of-policy';
                    leadsToUpdateList.add(l);
                }
                else if (l.Conversion_SLA_QL__c == 'Hot SLA In-Policy' && l.Business_Days_Since_Hot_SLA__c >= 14 && !chslaDGStatus.contains(l.DG_Lead_Status__C))
                {
                    l.Conversion_SLA_QL__c = 'Hot SLA Out-of-policy';
                    leadsToUpdateList.add(l);
                }
            }
            
        }

        if(!leadsToUpdateList.isEmpty())
        {
            try {
                    update leadsToUpdateList;
                } catch(Exception ex){
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());
                }  
        }
        
        
        
    }
    
    global void finish(Database.BatchableContext bc) {
        
        
        
        
    }

}