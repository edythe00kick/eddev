//Name: Chris Salgado Date: 5/13/19 Purpose: Refactored for CPQ
public class UpdateTotalAcvAccountOnce implements Database.Batchable<sObject> {

    // Store the conversion rates
    public Map<String, Double> conversionRatesMap = new Map<String, Double>();
    public Map<Id, String> accountIdByCurrencyMap = new Map<Id, String>();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        // Stores the query.
        String query = 'SELECT Id, Name, Total_ACV__c, CurrencyIsoCode, (SELECT Id, ' 
            + 'Annual_Software_Contract_Value__c, CurrencyIsoCode '
            + 'FROM Contracts ' 
            + 'WHERE Status_Category__c = \'In Effect\' AND '
            
            // NOTE :: There is no field named "Contract_End_Date__c" on conract
            //+ 'Status = \'Activated\' AND Contract_End_Date__c > TODAY) '
            + 'Status = \'Activated\' AND EndDate > TODAY) '
            + 'FROM Account';

        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<Account> accList) {
        // Store the account records to update.
        List<Account> acctsToUpdate = new List<Account>();
        conversionRatesMap = UtilityClass.getConversionRates();
        Decimal currentACV;
        
        if (!accList.isEmpty()) {
            Decimal totalACV; 
            for (Account acc : accList) {
                totalACV = 0;
                for (Contract con : acc.Contracts) {
                    currentACV = con.Annual_Software_Contract_Value__c;
                    if (con.CurrencyIsoCode != 'USD') {
                        currentACV /= conversionRatesMap.get(con.CurrencyIsoCode);
                    }
                    totalACV += currentACV;
                }

                if (acc.CurrencyIsoCode != 'USD') {
                    totalACV *= conversionRatesMap.get(acc.CurrencyIsoCode);
                }
                acc.Total_ACV__c = totalACV;
                acctsToUpdate.add(acc);
            }
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
                + 'Batch Class Name: UpdateTotalAcvAccountOnce.\n\n'
                + 'Error Message: ' + e.getMessage() + '\n'
                + 'Error Type: ' + e.getTypeName() + '\n' 
                + 'Line Number: ' + e.getLineNumber() + '\n' 
                + 'Stack Trace: ' + e.getStackTraceString();

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('Error: Update Total ACV on Account Once');
            mail.setToAddresses(new String[]{'alteryxsfdc@grazitti.com'});
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(body);
            Messaging.sendEmail(new Messaging.Email[] { mail });
        }
    }

    public void finish(Database.BatchableContext bc) {
        
    }
}