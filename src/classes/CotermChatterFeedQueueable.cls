/**
 * Created by ewong on 10/7/2020.
 */

public with sharing class CotermChatterFeedQueueable implements Queueable{

    public Set<Id> oppIdToQuoteMap;

    public CotermChatterFeedQueueable(Set<Id> oppIdToQuoteMap) {
        this.oppIdToQuoteMap = oppIdToQuoteMap;
    }

    public void execute(QueueableContext context) {
        System.debug('inside CotermChatterFeedQueueable = ' + oppIdToQuoteMap);
        //System.debug('inside CotermChatterFeedQueueable = ' + oppIdToQuoteMap.values());

        String strQuoteId;

        for (Id id : oppIdToQuoteMap) {
            strQuoteId = id;
        }

        ConnectApi.FeedElement feedElement = ConnectAPi.ChatterFeeds.postFeedElement(null,strQuoteId, ConnectApi.FeedElementType.FeedItem,'Test Chatter');
/*
        for (SBQQ__Quote__c quote : oppIdToQuoteMap.values()){
            ConnectApi.FeedElement feedElement = ConnectAPi.ChatterFeeds.postFeedElement(null,quote.Id, ConnectApi.FeedElementType.FeedItem,'Test Chatter');
        }
  */
    }

}