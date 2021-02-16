trigger FeedItemTrigger on FeedItem (after insert) {
    TriggerFactory.createHandler(FeedItem.sObjectType);
}