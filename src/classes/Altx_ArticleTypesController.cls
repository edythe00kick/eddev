public class Altx_ArticleTypesController {
    @AuraEnabled
    public static List<ArticleTypes> getAvailableArticlesType(){
        list<ArticleTypes> artTypes = new list<ArticleTypes>();
        Map<String, Schema.SObjectType> globalMap = Schema.getGlobalDescribe();
        Set<String> keySet = globalMap.keySet();
        for (String key : keySet) {
            Schema.SObjectType objectType = globalMap.get(key);            
            if (key.endsWith('ka') || key.endsWith('kb')) {
                if (objectType.getDescribe().isAccessible()) {
                    ArticleTypes art = new ArticleTypes();
                    art.value = objectType.getDescribe().getName()+'v';
                    art.label = objectType.getDescribe().getLabel();
                    artTypes.add(art);
                }
            }
        }
        system.debug('artTypes '+artTypes);
        return artTypes;
    }
    public class ArticleTypes{
        @AuraEnabled
        public string value;
        
        @AuraEnabled
        public string label;
    }
}