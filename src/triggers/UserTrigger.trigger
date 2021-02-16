trigger UserTrigger on User (after insert) {
    TriggerFactory.createHandler(User.sObjectType);
}