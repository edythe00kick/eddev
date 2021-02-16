/*
 * Class Name - LeadConvertOptimizedHelper.
 * 
 * %W% %E% Grazitti Team
 * This is the helper class for "LeadConvertOptimizedController" class.
 */

/**
 * This class contains different methods to help the functionality of 
 * LeadConvertOptimizedController class.
 * 
 * @author Grazitti Team
 * @version 1.0 March 15, 2018
 */
public class LeadConvertOptimizedHelper {

    /**
     * Validates values on vf page before converting lead.
     * 
     * @param SelectedAccount Account to which lead is to be converted.
     * @param selectedContact Contact to which lead is to be converted.
     * @param OwnerId Owner of lead.
     * @param oppname Name of the opportunity to which lead is to be converted.
     * @param createOpp True or false depending on whether or not opportunity 
     *        is to be created on lead conversion.
     * @param OppType "Class of Business" value of opportunity to which lead is 
     *        to be converted.
     * @param HasContact True or false depending on whether or not account to 
     *        which lead is to be converted has related contacts.
     * @return True or False depending on whether validation was successful 
     *         or not. 
     */
    public static Boolean Validate(String SelectedAccount, Id OwnerId, 
                                   String oppname, Boolean createOpp, 
                                   String OppType, Boolean HasContact, 
                                   String selectedContact, Date closeDate, 
                                   String leadConvertReason, Boolean isPartner,
                                   Decimal forecastAmount, Decimal termInMonths
                                   //, Decimal bestTerm, Decimal upsideForecastAmount //Sergio Flores W-013410 : Sergio Flores 02/21/2020 W-004548
                                   ) {

        if (leadConvertReason == null) {
            return ErrorMessage('Please Select the Lead Outcome Reason');
        }
        if (SelectedAccount == 'NONE') {
            return ErrorMessage('Please Select the Account');
        }
        if ((SelectedAccount == 'NEW' || SelectedAccount == 'NONE') 
          && createOpp && OppType == 'NBEC') {
          
          return ErrorMessage('You can only create NBEC opportunities ' 
                                + 'for existing customers. '
                                + 'Please select NB.');
        }
        if ((SelectedAccount != 'NEW' && SelectedAccount != 'NONE')
            && createOpp) {

            Account a = [SELECT Id, Type 
                         FROM Account 
                         WHERE Id = :SelectedAccount];

            if (a.type != 'Customer' && OppType == 'NBEC') {
                return ErrorMessage('You can only create NBEC opportunities ' 
                                    + 'for existing customers. '
                                    + 'Please select NB.');
            }
        }
        if ((SelectedAccount != 'NEW' && SelectedAccount != 'NONE')
            && createOpp) {

            Account a = [SELECT Id, Type 
                         FROM Account 
                         WHERE Id = :SelectedAccount];

            if (a.type == 'Customer' && OppType == 'NB') {
                return ErrorMessage('You can only create NB opportunities ' 
                                    + 'for new customers. '
                                    + 'Please select NBEC.');
            }
        }
        if (HasContact && selectedContact == 'NONE') {
            return ErrorMessage('Please Select the Contact');
        }
        if (OwnerId == null) {
            return ErrorMessage('Please Select the Owner');
        }
        if (oppname == '' && createOpp) {
            return ErrorMessage('Please enter the name of opportunity');
        }
        if (createOpp && closeDate == null) {
            return ErrorMessage('Please Enter Close Date');
        }
        system.debug('inside checking validation ' + createOpp + ' termINMonths ' +termInMonths );
        if (createOpp && (forecastAmount == null || forecastAmount == 0)) {
            return ErrorMessage('Please enter the Forecast Amount or enter 0 if no Forecast Amount.');
        }
        /*//Sergio Flores W-013410 : Sergio Flores 02/21/2020 W-004548
        if (createOpp && (upsideForecastAmount == null || upsideForecastAmount == 0)) {
            return ErrorMessage('Please populate "Upside Forecast Amount (ACV)". If there is no additional upside to this deal, please populate it with the value in the "Forecast Amount (ACV)" field.'); 
        }
        if (createOpp && (termInMonths != null && bestTerm !=null && termInMonths > bestTerm)) {
            return ErrorMessage('Best Case Term must be equal or greater than Term In Months.');
        }*/
        if (createOpp && termInMonths == null ) {
            
            if(termInMonths == null)
            {
                termInMonths = 12.00;
            }
            
            /*//Sergio Flores W-013410 : Sergio Flores 02/21/2020 W-004548
            if(bestTerm == null)
            {
                bestTerm = 12;
            }
            
            if(termInMonths > bestTerm)
            return ErrorMessage('Best Case Term must be equal or greater than Term In Months.');*/
        }
        /*if (createOpp && isPartner && (amount == null || amount == 0)) {
            return ErrorMessage('Please enter the amount for Partner Deal');
        } Commenting this out and added the above if statment for checking amount when opp is created*/
        return false;
    }

    /**
     * Set the lead record owner on basis of profile.
     * 
     * @param ProfileName Profile name of the current user.
     * @param ownerid Current ownerid of the record
     * 
     * @return NewOwnerID according to profiles.
     */
    public static String SetLeadOwner(String ProfileName, String Ownerid) {
        String NewOwnerID;
        if (ProfileName == 'Alteryx - ANZ - Customer Support' 
            || ProfileName == 'Alteryx - Sales - ANZ Account Executives') {

            User u = [SELECT Id, Name, isActive 
                      FROM User 
                      WHERE (Id = :Label.RobbinJangUserId AND isActive = TRUE) 
                      LIMIT 1];

            if (u != null) {
                NewOwnerID = u.id;
            }
            else {
                NewOwnerID = Ownerid;
            }
        } else if (ProfileName == 'Alteryx - Denmark - Partner Sales Rep') {
            User u = [SELECT Id, Name, isActive 
                      FROM User 
                      WHERE Id = :Label.JoshToddUserId AND isActive = TRUE 
                      LIMIT 1];

            if (u != null) {
                NewOwnerID = u.id;
            }
            else {
                NewOwnerID = Ownerid;
            }
        } else {
            NewOwnerID = Ownerid;
        }
        return NewOwnerID;
    }

    /**
     * Update the lead values 
     * @param leadid Id of the lead to be converted.
     * @param mqlvalue Paramerter value from url.
     */
    public static void UpdateMqlLeadStatus(Id leadid, String mqlValue) {
        Lead leadToConvert = [SELECT Id, Country, Email, RLM_Status_Field__c, 
                              Do_Not_Call_SAO_Conversion__c, Status, OwnerId,
                              Name, Company, RecordTypeId 
                              FROM Lead 
                              WHERE Id = :leadId];

        if (mqlValue == 'Yes') {
            if (leadToConvert.RLM_Status_Field__c == 'Responder') {
                leadToConvert.MQL_Date__c = Date.Today();
                leadToConvert.Responder_to_SAO__c = True;
                if (leadToConvert.Do_Not_Call_SAO_Conversion__c == FALSE) {
                    leadToConvert.Do_Not_Call_SAO_Conversion__c = TRUE;
                }
            }
            else if (leadToConvert.RLM_Status_Field__c == 'MQL') {
                leadToConvert.MQL_Date__c = Date.Today();
                leadToConvert.MQL_to_SAO__c = True;
                if (leadToConvert.Do_Not_Call_SAO_Conversion__c == FALSE) {
                    leadToConvert.Do_Not_Call_SAO_Conversion__c = TRUE;
                }
            }
            else if (leadToConvert.Do_Not_Call_SAO_Conversion__c == FALSE) {
                leadToConvert.Do_Not_Call_SAO_Conversion__c = TRUE;
            }
        }
        else {
            if (leadToConvert.Do_Not_Call_SAO_Conversion__c == FALSE) {
                leadToConvert.Do_Not_Call_SAO_Conversion__c = TRUE;
            }
        }
        update leadToConvert;
    }

    /**
     * Update the class of buisness of opportunity 
     * 
     * @param ConvertedOppid  Opportunity to which lead is to be converted.
     * @param ConvertedContactid  Contact to which lead is to be converted.
     * @param OppType  Class of business of opportunity.
     * @param profileName  Profile name of current user.Will be removed if 
     *        future is not required. 
     * 
     */
    public static void UpdateOpportunityType(String ConvertedOppid, 
                                             String ConvertedContactid, 
                                             String OppType, 
                                             String profileName,
                                             Date closeDate,
                                             Decimal termInMonths, //Sergio Flores W-011118
                                             Decimal forecastAmount
                                             // Decimal bestTerm, Decimal upsideForecastAmount Sergio Flores 02/21/2020 W-004548
                                              ) { //Sergio Flores W-012297

        Opportunity ConvertedOpp = new Opportunity(id = ConvertedOppid);
        Contact Convertedcontact = new Contact(id = ConvertedContactid);
        if (ConvertedOpp != Null) {
            ConvertedOpp.Primary_Contact__c = ConvertedContact.id;
            ConvertedOpp.Type = OppType;
            ConvertedOpp.CloseDate = closeDate;
            ConvertedOpp.Forecast_Amount__c = forecastAmount; 
            ConvertedOpp.Annual_Contract_Value_Amount__c = forecastAmount;
            //ConvertedOpp.Upside_Forecast_Amount_ACV__c = upsideForecastAmount; //Sergio Flores W-013410 : Sergio Flores 02/21/2020 W-004548
            ConvertedOpp.Term_in_Months__c = termInMonths;
           // ConvertedOpp.Best_Case_Term__c = bestTerm; : Sergio Flores 02/21/2020 W-004548

            //Sergio Flores
            //Date: 06/11/2019
            //W-012192
            //Standard Opp Creation
            if( (ConvertedOpp.Type == 'NB' || ConvertedOpp.Type == 'NBEC'))
            {
                system.debug('inside standard converted opp contract dates ' + ConvertedOpp);
                ConvertedOpp.Contract_Start_Date__c = ConvertedOpp.CloseDate.addDays(1);
                ConvertedOpp.Contract_End_Date__c = ConvertedOpp.Contract_Start_Date__c.addMonths(integer.valueOf(ConvertedOpp.Term_In_Months__c));
                ConvertedOpp.Contract_End_Date__c = ConvertedOpp.Contract_End_Date__c.addDays(-1);
            }

            try {
                update Convertedopp;
            } catch(Exception e) {
                ApexPages.Message msg 
                    = new ApexPages.Message(Apexpages.Severity.ERROR, 
                                            e.getMessage());

                ApexPages.addMessage(msg);
            }
        }
    }

    /**
     * Update the status of new/merged contact.
     * 
     * @param ConvertedContactid  new/merged  contact from lead to be converted 
     * conversion process.
     * @param createOpp True or false depending on whether or not opportunity 
     *        is to be created on lead conversion.
     * Status of Convertedcontact depend of it. 
     * 
     */
    public static void UpdateContactStatus(String ConvertedContactid, 
                                           Boolean createOpp) {

        Contact Convertedcontact = new Contact(id = ConvertedContactid);
        if (Convertedcontact != Null) {
            if (createOpp) {
                Convertedcontact.Contact_Status__c = '3 - In Conversation';
                ConvertedContact.DG_Lead_Status__c = 'Converted to Opportunity'; //W-011107
                ConvertedContact.Contact_Outcome_Reason__c = 'Converted'; //SF 1/07/2020 W-013774
            } else {
                Convertedcontact.Contact_Status__c = '4 - Converted';
            }
            try {
                update Convertedcontact;
            } catch(Exception e) {
                ApexPages.Message msg = new ApexPages.Message(
                Apexpages.Severity.ERROR, e.getMessage());
                ApexPages.addMessage(msg);
            }
        }
    }

    /**
     * Diplays the related error on visualforce page
     * 
     * @param Error Conatins the error message. 
     */
    public static Boolean ErrorMessage(String Error) {
        ApexPages.Message msg 
            = new ApexPages.Message(Apexpages.Severity.ERROR, Error);

        ApexPages.addMessage(msg);
        return true;
    }    
}