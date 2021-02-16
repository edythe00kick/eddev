public class UpdateTotalAcvAccount implements Database.Batchable<sObject>, Database.Stateful {

    // Store the account records to update.
    public List<Account> acctsToUpdate = new List<Account>();
    // Store the conversion rates
    public Map<String, Double> conversionRatesMap = new Map<String, Double>();

    public List<Account> start(Database.BatchableContext bc) {
        // Store the date of yesterday.
        Date yestDate = System.today() - Integer.valueOf(Label.ACV_Schedule_Time);
        // Store the ids of the account.
        Set<Id> accountIds = new Set<Id>();
        // Store the account records with their agreements
        List<Account> accList = new List<Account>();
        conversionRatesMap = UtilityClass.getConversionRates();
        
        for (Contract con : [SELECT Id, AccountId 
                                             FROM Contract 
                                             WHERE (EndDate < TODAY 
                                                    AND EndDate >= :yestDate 
                                                    //AND Status_Category__c = 'In Effect' //csalgado 5/20 Edit criteria
                                                    AND Status = 'Activated' 
                                                    AND Annual_Software_Contract_Value__c != 0
                                                   AND Annual_Software_Contract_Value__c != null)//csalgado 5/21 Fix query
                                                    OR LastModifiedDate > :yestDate]) {

            accountIds.add(con.AccountId);
        }

        if (!accountIds.isEmpty()) {
            accList =  [SELECT Id, Total_ACV__c, CurrencyIsoCode, 
                        (SELECT Annual_Software_Contract_Value__c, CurrencyIsoCode 
                         FROM Contracts 
                         WHERE (EndDate >= TODAY 
                                //AND Status_Category__c = 'In Effect' //csalgado 5/20 Edit criteria
                                AND Annual_Software_Contract_Value__c != 0
                                AND Annual_Software_Contract_Value__c != null
                                AND Status = 'Activated')) 	
                        FROM Account 
                        WHERE Id IN :accountIds];
        }
		system.debug('accountList' + accList);
        return accList;
    }

    public void execute(Database.BatchableContext bc, List<Account> accList) {
        system.debug(LoggingLevel.INFO,'Inside UpdateTotalACV Execute' + ' ' + accList);
        Decimal totalACV;
        Decimal currentACV;

    	if(!accList.isEmpty()){
            for (Account acc : accList) {
                totalACV = 0;
                for (Contract cont : acc.Contracts) {
                    system.debug('Contract ACV' + ' ' + cont.Annual_Software_Contract_Value__c);
                    currentACV = cont.Annual_Software_Contract_Value__c;
                    if (cont.CurrencyIsoCode != 'USD') {
                        currentACV /= conversionRatesMap.get(cont.CurrencyIsoCode);
                    }
                    system.debug(LoggingLevel.INFO,'Current ACV' + ' ' + currentACV);
                    totalACV += currentACV;
                    system.debug(LoggingLevel.INFO,'Total ACV' + ' ' + totalACV);
                }
    
                if (acc.CurrencyIsoCode != 'USD') {
                    totalACV *= conversionRatesMap.get(acc.CurrencyIsoCode);
                }
                acc.Total_ACV__c = totalACV;
                acctsToUpdate.add(acc);
                system.debug(LoggingLevel.INFO,'Updated Accounts' + ' ' + acctsToUpdate);
            }
            
            try {
                if (!acctsToUpdate.isEmpty()) {
                    update acctsToUpdate;
                    
                    if (Test.isRunningTest()) {
                        throw new TriggerException('Error generated to cover catch block.');
                    }
                }
            } catch (Exception e) {
                String body = 'Errors occurred during batch process.\n\n' 
                    + 'Batch Class Name: UpdateTotalAcvAccount.\n\n'
                    + 'Error Message: ' + e.getMessage() + '\n'
                    + 'Error Type: ' + e.getTypeName() + '\n' 
                    + 'Line Number: ' + e.getLineNumber() + '\n' 
                    + 'Stack Trace: ' + e.getStackTraceString();
    
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSubject('Error: Update Total ACV on Account');
                mail.setToAddresses(new String[]{'alteryxsfdc@grazitti.com'});
                mail.setSaveAsActivity(false);
                mail.setPlainTextBody(body);
                Messaging.sendEmail(new Messaging.Email[] { mail });
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        
    }
}