({
    doInit : function(component, event, helper) {
        var action = component.get("c.getAvailableArticlesType");
        action.setCallback(this, function(a){
            var result = a.getReturnValue();
            component.set("v.articlesType", result);
        });
        $A.enqueueAction(action);
    },
    getArticleValue : function(component, event, helper) {
        var articleType = event.target.id;
        component.set("v.selectedArt", articleType);
        var ArticleTypeEvent = $A.get("e.c:Altx_ArticleTypesEvent");
        ArticleTypeEvent.setParams({
            "ArticleType": articleType
            
        });
        ArticleTypeEvent.fire();
    }
})