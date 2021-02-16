/**
 * Created by csalgado on 10/10/2019.
 */

trigger AssetTrigger on Asset (before insert) {
    AssetHandler handler = new AssetHandler();

    if(Trigger.isBefore && Trigger.isInsert)
    {
        handler.onBeforeInsert(Trigger.new);
    }
}