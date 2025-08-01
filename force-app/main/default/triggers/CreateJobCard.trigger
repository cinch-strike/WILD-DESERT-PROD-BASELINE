//trigger to create "Job Card" record based upon the record type of "Asset" record type and data.
trigger CreateJobCard on Asset__c (before insert,before update,after update) {
    
    if(Trigger.isBefore && Trigger.isUpdate) {
        //get "Asset" record type id by passing "Asset" record type name.
        Schema.DescribeSObjectResult assetSchema = Schema.SObjectType.Asset__c; 
        Map<String,Schema.RecordTypeInfo> AssetRecordTypeInfo = assetSchema.getRecordTypeInfosByName();

        //Assigning the record type id of various record type to string variables.
        string Light_vehicles = AssetRecordTypeInfo.get('Light Vehicles').getRecordTypeId();

        string Cranes = AssetRecordTypeInfo.get('Cranes').getRecordTypeId();
        string Non_vehicles_assets = AssetRecordTypeInfo.get('Non-Vehicle Engine').getRecordTypeId();
        string rigs = AssetRecordTypeInfo.get('Rigs').getRecordTypeId();

        string dollies = AssetRecordTypeInfo.get('Dollies').getRecordTypeId();
        string forklifts =AssetRecordTypeInfo.get('Forklifts').getRecordTypeId();
        string loaders = AssetRecordTypeInfo.get('Loaders').getRecordTypeId();
        string prime_mover = AssetRecordTypeInfo.get('Prime Mover').getRecordTypeId();
        string trailer = AssetRecordTypeInfo.get('Trailer').getRecordTypeId();

        for(Asset__c asset:trigger.new){
            Integer count = 0;
            String status='';
            
            //check the record type of asset record is equal to "light Vehicle" and call utility class method to create "Job Card" Record.
         
            if(asset.RecordTypeId == Light_vehicles && (asset.Current_Odometer_Reading__c != Trigger.oldMap.get(asset.Id).Current_Odometer_Reading__c)){
                status = CreateJobCardUtility.createJobCardForLightVechiles(trigger.new[count],trigger.old[count],asset.ID);  
                if(status == 'Yes') {
                    asset.Next_Job_Card_creation_reading__c += 10000;
                    asset.Next_Service_Due_km__c = asset.Next_Job_Card_creation_reading__c + 0;
                }
            }
            //check the record type of asset record is equal to "Cranes","Non-Vehicle Assets" "Rigs","Forklifts","Loaders" and call utility class method to create "Job Card" Record.
         
            if(asset.RecordTypeId == Cranes || asset.RecordTypeId == Non_vehicles_assets || asset.RecordTypeId == rigs || asset.RecordTypeId == forklifts || asset.RecordTypeId == loaders){
                status = CreateJobCardUtility.createJobCardForCrenes(trigger.new[count],trigger.old[count],asset.ID);
                if(status == 'Yes') {
                    asset.Next_Job_Card_creation_reading__c += 250;
                    asset.Next_Service_Due_Hrs__c = asset.Next_Job_Card_creation_reading__c + 0;
                }
            }
            //check the record type of asset record is equal to "Dollies","Prime Movers","Trailer" and call utility class method to create "Job Card" Record.
        
            if(asset.RecordTypeId == dollies || asset.RecordTypeId == prime_mover || asset.RecordTypeId == trailer){
                status =CreateJobCardUtility.createJobCardForDollies(trigger.new[count],trigger.old[count],asset.ID);
                if(status == 'Yes') {
                    asset.Next_Job_Card_creation_reading__c += 20000;
                    asset.Next_Service_Due_km__c = asset.Next_Job_Card_creation_reading__c;
                }
            }
            count++;
        }
    }
       
    // This is related to Parent-Child Assets
    Set<Id> parentAssetIds = new Set<Id> ();
        if(Trigger.isBefore) {
            for(Asset__c ast : Trigger.New) {
                if(ast.Parent_Asset__c != null) {
                    parentAssetIds.add(ast.Parent_Asset__c);
                }
            }
            Map<Id,Asset__c> mapParentAsset = new Map<Id,Asset__c>([select Id,Unit__c,ownerId from Asset__c where Id 
                                                                IN: parentAssetIds]);
            for(Asset__c ast : Trigger.New) {
                if(ast.Parent_Asset__c != null) {
                    ast.Unit__c = mapParentAsset.get(ast.Parent_Asset__c).Unit__c;
                    ast.OwnerId =mapParentAsset.get(ast.Parent_Asset__c).OwnerId;  
                }
            }
        }
         
    if(Trigger.isUpdate) {
    
        List<Asset__c> listChildAsset = new List<Asset__c> ([select Id,ownerId,Unit__c,Parent_Asset__c from Asset__c where 
                                                                Parent_Asset__c IN: Trigger.newMap.keySet()]);
            for(Asset__c parentAst : Trigger.New) {
                //if unit is changed in parent record
                if(parentAst.Unit__c != Trigger.oldMap.get(parentAst.Id).Unit__c) {
                    for(Asset__c childAst : listChildAsset) {
                        if(childAst.Parent_Asset__c == parentAst.Id) {
                            childAst.Unit__c = parentAst.Unit__c;
                        }
                    }
                }
                //if owner is changed in parent record
                if(parentAst.OwnerId!=Trigger.oldMap.get(parentAst.Id).OwnerId){
                     for(Asset__c childAst : listChildAsset) {
                        if(childAst.Parent_Asset__c == parentAst.Id) {
                            childAst.OwnerId = parentAst.OwnerId;
                        }
                    }
                
                }
            }
            update listChildAsset;
    }
    
    // Following to make sure that current Asset's Owner = Unit's Owner
    Set<Id> unitIds = new Set<Id> ();
    Map<Id,Unit__c> mapUnitInAsset;
    if(Trigger.isBefore) {
        for(Asset__c ast : Trigger.New) {
            unitIds.add(ast.Unit__c);
        }
        mapUnitInAsset = new Map<Id,Unit__c> ([select Id, OwnerId from Unit__c where Id IN: unitIds]);
        for(Asset__c ast : Trigger.New) {
            if(ast.Unit__c != null) {
                // Following 'if' can be written inside above 'if' by using AND, but if Unit lookup is blank then map wont
                // return anything, hence trigger will throw NullPointerException
                if(ast.OwnerId != mapUnitInAsset.get(ast.Unit__c).OwnerId) {
                    ast.OwnerId = mapUnitInAsset.get(ast.Unit__c).OwnerId;
                }
            }
        }
    }
}