// This trigger is to update all related Assets of the current Unit, so that Owner is same for Unit and Assets
trigger UpdateAssetOwner on Unit__c (after insert, after update) {
    List<Asset__c> lstRelatedAssets = [select OwnerId,Unit__c from Asset__c where Unit__c IN: Trigger.newMap.keySet()];
    System.debug('---------lstRelatedAssets  just retrived :'+lstRelatedAssets);
    System.debug('---------Trigger.new.size :'+Trigger.new.size());
    
    for(Unit__c unt : Trigger.new) {
        for(Asset__c ast : lstRelatedAssets) {
            if(ast.Unit__c == unt.Id) {
                ast.OwnerId = unt.OwnerId;
            }
        }
    }
    System.debug('---------lstRelatedAssets  before Update :'+lstRelatedAssets);
    update lstRelatedAssets;
}