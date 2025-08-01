({
    resetData : function(component, event,helper) {
        component.set("v.selectItemMasterName", "");
        component.set("v.selectItemMasterId", "");
        component.find('userinput').set("v.readonly", false);
        component.set("v.qty","");
    },
    createPRRecords : function(component, event,helper) {
        var action = component.get("c.createPurchaseOrder");
        var hasFileUploaded = component.get("v.hasFileUploaded");
        var listuploaded = component.get("v.listUploadedFiles");
        if($A.util.isEmpty(component.get('v.prCostPrice')))
           {
             component.set("v.prCostPrice", null);
           }
        //var prCostPrice = component.get('v.prCostPrice'); //01 DEC 2022: Code for new Cost Price
        var prCostPrice = (component.get('v.disableCostPrice') == true) ? null : component.get('v.prCostPrice'); //01 DEC 2022: Remove code for new Cost Price

        action.setParams({
            "itemMasterId" : component.get("v.selectItemMasterId"),
            "newItemName" : component.get("v.selectItemMasterName"),
            "nonInventoryItem" : component.get("v.isNonIventoryItem"),
            "newItem" : component.get("v.showNoItem"),
            "destinationUnitId" : component.get("v.selectedDestinationUnit"),
            "quantity" : component.get("v.quantity"),
            "staffName" : component.get("v.staffName"),
            "assetId" : component.get("v.selectedAssetId"),
            "workOrderId" : component.get("v.selectedWorkOrderId"),
            "department" : component.find('selectedDepartment').get('v.value'),
            "notes" : component.get('v.notes'),
            "detailsforsupplier" : component.get('v.detailsforsupplier'),
            "prCostPrice" : prCostPrice,  
            "costAllocationId" : component.get("v.selectedCostAllocationId")
        });

        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);            
            if (response.getState() === "SUCCESS" ) {
                var purchaseRequestCreated = response.getReturnValue();
                //ADDED BY JOAL - UPDATED TO INCLUDE THE ITEM NAME NEW LOGIC
                /*
                purchaseRequestCreated.customCSS = purchaseRequestCreated.Item_Name_URL__c.includes('https') ? 'withLink' : 'withoutLink';
                purchaseRequestCreated.itemName = (purchaseRequestCreated.Item_Name_URL__c.includes('https') && purchaseRequestCreated.Item__c != null) ? purchaseRequestCreated.Item__r.Name : purchaseRequestCreated.New_Item_Name__c;
                */
                var finalMsg = '';
                // Set the created Record Id
                component.set("v.createdRecordId", purchaseRequestCreated.Id);
                purchaseRequestCreated.linkName = '/'+purchaseRequestCreated.Id;
                if (purchaseRequestCreated.Status__c == 'Completed'){
                    finalMsg = 'Purchase request completed. Stock availability updated.';
                }
                else {
                    finalMsg = 'Draft purchase request created.';
                }
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success!',
                    message: finalMsg,
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'There is a problem creating the purchase request: ' + JSON.stringify(response.getError()),
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            if(component.get("v.createPRAddAnother") == true){
                var draftPrs = component.get('v.prList');
                
                draftPrs.push(purchaseRequestCreated);
                component.set("v.prList",draftPrs);
                //Update fields value as null
                component.set('v.selectItemMasterName', '');
                component.set('v.selectItemMasterId', '');
                component.find('userinput').set("v.readonly", false);
                component.set("v.quantity", "");
                component.set("v.prCostPrice","");
                component.set("v.selectItemCode","");
                component.set("v.selectItemPartNumber","");
                component.set("v.selectItemCostPrice","");
                component.set("v.showSwitch",true);
                component.set('v.isButtonActive',false);
                component.set('v.showNoItem',false);
                component.set("v.prTotalCostPrice", "");
                component.set('v.disableCostPrice',true); //01 DEC 2022: Remove code for new Cost Price
                if(draftPrs.length>0){
                    component.set('v.hasDraftPRs', draftPrs.length>0);
                    component.set("v.createPRAddAnother",false);
                }
                
            } else {
                component.set("v.showSwitch",false);
                helper.resetData(component,event,helper);
                $A.get('e.force:refreshView').fire();
            }
            //Check if file uploaded
            var createdPR = purchaseRequestCreated.Id;
            if((hasFileUploaded) && (response.getState() === "SUCCESS" )){
                //alert("Files uploaded: " + listuploaded);
                //alert("PR: " + createdPR);
                var action = component.get("c.linkUploadedFiles");
                action.setParams({
                    "createdPR" : createdPR,
                    "uploadedFiles" : listuploaded
                });
                action.setCallback(this, function(response){
                    var STATE = response.getState();
                    if(STATE === "SUCCESS") {
                    }
                    else{
                        var errorMsg = response.getError();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            title : 'There is an error uploading the file/s. ' + response.getError(),
                            message: errorMsg,
                            duration:' 5000',
                            key: 'info_alt',
                            type: 'error',
                            mode: 'pester'
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);
            }
        });
        $A.enqueueAction(action);
    },
    
    deleteRecord : function(component, event) {
        var purchaseRequestRec = event.getParam('row');        
        var action = component.get("c.delPR");
        action.setParams({
            "purchaseRequestRec": purchaseRequestRec
        });
        action.setCallback(this, function(response) {
            component.set("v.isLoading", false);            
            if (response.getState() === "SUCCESS" ) {
                var rows = component.get('v.prList');
                var rowIndex = rows.indexOf(purchaseRequestRec);
                rows.splice(rowIndex, 1);
                component.set('v.prList', rows);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success!',
                    message: 'The record has been deleted successfully.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'There is a problem deleting your record: ' + response.getError(),
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchPR : function(component, event) {
        var draftPRAction = component.get("c.fetchDraftPRs");
        draftPRAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var records = response.getReturnValue();
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                    //ADDED BY JOAL - UPDATED TO INCLUDE THE ITEM NAME NEW LOGIC
                    /*
                    record.customCSS = record.Item_Name_URL__c.includes('https') ? 'withLink' : 'withoutLink';
                    record.itemName = (record.Item_Name_URL__c.includes('https') && record.Item__c != null) ? record.Item__r.Name : record.New_Item_Name__c;*/
                });
                component.set('v.prList',records);
                console.log('value in the length ' + records.length);
                component.set('v.hasDraftPRs', records.length>0);
			}
        });
        $A.enqueueAction(draftPRAction);
    }
    
})