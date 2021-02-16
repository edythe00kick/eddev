public without sharing class QuoteUtilityClass {

    public static void stampOrderGroupSupport(Set<Id> acceptedQuoteIds, List<SBQQ__Quote__c> acceptedQuotes)
    {
        //Author: Sergio Flores
        //Date: 11/27/2018
        //W-010668
        //New CPQ : W-011742
        //Refactored Date: 04/22/2019
        List<SBQQ__QuoteLine__c> quoteLineItemList = [Select Id, SBQQ__ProductCode__c, CustomEndDate__c, SBQQ__Quote__c
                                                          From SBQQ__QuoteLine__c 
                                                          Where SBQQ__Quote__c  IN : acceptedQuoteIds];
         system.debug('PropList for Support Level ' + quoteLineItemList);
         //Need to create map of Quote to Quote line items associated
         //so we don't have to iterate through all the quote line items in the for loops below/ this will map
         //our looping more efficent 

        Map<Id, List<SBQQ__QuoteLine__c>> quoteToLineItemsMap = new Map<Id, List<SBQQ__QuoteLine__c>>();

        for(SBQQ__QuoteLine__c qli : quoteLineItemList)
        {
            if(quoteToLineItemsMap.containsKey(qli.SBQQ__Quote__c))
            {
                List<SBQQ__QuoteLine__c> qliList = quoteToLineItemsMap.get(qli.SBQQ__Quote__c);
                qliList.add(qli);
            }
            else
            {
                List<SBQQ__QuoteLine__c> qliList = new List<SBQQ__QuoteLine__c>();
                qliList.add(qli);
                quoteToLineItemsMap.put(qli.SBQQ__Quote__c, qliList);
            }
        }

        //Need Order Group Support Levels
        Map<Id,SBQQ__Quote__c> propId2PropSupportLevelMap = new Map<Id,SBQQ__Quote__c>([Select Id, Order_Group__r.Support_Level__c, Order_Group__r.Support_Expiration_Date__c, SBQQ__Account__r.Account_ID__c 
                                                                    From SBQQ__Quote__c 
                                                                    Where Id IN : acceptedQuoteIds ]);

        List<Order_Group__c> ogToUpdateList = new List<Order_Group__c>(); 
        List<Entitlement> Ent2InsertList = new List<Entitlement>(); //Sergio Flores 07/02/2019

        if(!quoteLineItemList.isEmpty())
        {
            for(SBQQ__Quote__c quote : acceptedQuotes)
            {
                boolean support = false;
                String supportLevel;
                Date supportEndDate;
                boolean expired = false;
                SBQQ__Quote__c oldQuote = new SBQQ__Quote__c();
                //Get the current support level of this proposal
                oldQuote = propId2PropSupportLevelMap.get(quote.Id);
                
                List<SBQQ__QuoteLine__c> qliList = quoteToLineItemsMap.get(quote.Id);
                system.debug('inside stampOrderGroupSupport qliList ' + qliList);
                //Loop through the list, check to see if the product code matches any of the custom settings product code levels
                //If there is a match, grab the custom setting name and that would be the support level for the order group, update the order group
                for(SBQQ__QuoteLine__c qli : qliList)
                {
                    List<Support_Level__c> slCustomSetting = Support_Level__c.getall().values();
                    system.debug('inside stampOrderGroupSupport ql loop ' + slCustomSetting);
                    for(Support_Level__c sl : slCustomSetting)
                    {
                        system.debug('Inside Support Level Loop' + sl.Product_Code__c + ' ' + qli.SBQQ__ProductCode__c );
                        if(sl.Product_Code__c.Contains(qli.SBQQ__ProductCode__c))
                        {
                            //First check to see if the proposal line item support product or proposal
                            //has an expiration date less than today, if so then udpate the Order Group
                            if(oldQuote.Order_Group__r.Support_Expiration_Date__c < date.today())
                            {
                                support = true;
                                supportLevel = sl.Name;
                                supportEndDate = qli.CustomEndDate__c;
                            }
                            else if(sl.Name == 'Advanced Support' && oldQuote.Order_Group__r.Support_Level__c =='Standard Support' )
                            {
                                system.debug('Inside Updating OG to Advance');  
                                support = true;
                                supportLevel = sl.Name; 
                                supportEndDate = qli.CustomEndDate__c;
                            }
                            else if(sl.Name == 'Premium Support' && oldQuote.Order_Group__r.Support_Level__c !='Premium Support')
                            {
                                system.debug('Inside Updating OG to Premium'); 
                                support = true;
                                supportLevel = sl.Name; 
                                supportEndDate = qli.CustomEndDate__c;
                            }
                            else if(oldQuote.Order_Group__r.Support_Level__c == null)
                            {
                                system.debug('Inside Updating OG'); 
                                support = true;
                                supportLevel = sl.Name;
                                supportEndDate = qli.CustomEndDate__c;
                            }
                            //Sergio Flores
                            //Date 01/14/2020
                            //W-000003
                            //Need to check if the support exiration date got updated
                            else if(oldQuote.Order_Group__r.Support_Expiration_Date__c < qli.CustomEndDate__c && support == false)
                            {
                                system.debug('Inside Updating OG expiration date'); 
                                support = true;
                                supportLevel = sl.Name;
                                supportEndDate = qli.CustomEndDate__c;
                            }
                        } 
                    }
                    //Need to check if it expired, if it expired then need to update to Salesforce  
                    if(oldQuote.Order_Group__r.Support_Expiration_Date__c < date.today() && support == false)
                    {
                         expired = true;
                        system.debug('Expiration Date ' + oldQuote.Order_Group__r.Support_Expiration_Date__c);
                    }
                }
                Order_Group__c og = new Order_Group__c();
                //If any of the proposal line items have a support level, then we need to update the Order Group with 
                //the support level //if standard, then nullify expiration date
                if(support == true)
                {
                    og.Id = quote.Order_Group__c; 
                    og.Support_Level__c = supportLevel; 
                    og.Support_Expiration_Date__c = supportEndDate;
                    ogToUpdateList.add(og);
                }
                else //the order group will have to be updated to standard support
                {
                    if(oldQuote.Order_Group__r.Support_Level__c == null || expired == true)
                    {
                        system.debug('Old Order Gorup Support Level ' + oldQuote.Order_Group__r.Support_Level__c + ' Expired ' + expired);
                        og.Id = quote.Order_Group__c;
                        og.Support_Level__c = 'Standard Support';
                        og.Support_Expiration_Date__c = null;  
                        ogToUpdateList.add(og);
                    }
                }
                
                //Sergio Flores
                //Date 07/02/2019
                //Need to Create Entitlment
                //SMB_SupportID = 55244000000LWxe
                if(!ogToUpdateList.isEmpty())
                {
                    system.debug('inside entitlement process ');
                    Entitlement ent = new Entitlement();
                    ent.Name = support  ? supportLevel + ' - ' + oldQuote.SBQQ__Account__r.Account_ID__c : 'Standard Support - ' + oldQuote.SBQQ__Account__r.Account_ID__c;
                    ent.StartDate = quote.SBQQ__StartDate__c;
                    ent.EndDate = quote.CustomEndDate__c;
                    ent.SlaProcessId = label.SMB_SupportID;
                    ent.Quote__c = quote.Id;
                    ent.AccountId = quote.SBQQ__Account__c;
                    Ent2InsertList.add(ent);

                }
            }
            try
            {
                update ogToUpdateList;
                insert Ent2InsertList; //Sergio Flores 07/02/2019
                system.debug('ogToUpdateList' + ogToUpdateList);
            }
            catch(Exception ex) 
            {
                system.debug('inside catch exception');
                trigger.new[0].addError(ex.getMessage());                       
            }
        }
    }

}