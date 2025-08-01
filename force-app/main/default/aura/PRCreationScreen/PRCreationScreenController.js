({
    doInit : function(component, event, helper) {
        var actions = [
            {label: 'Delete', name: 'delete'}
        ];
        console.log('## record ID: ' + component.get("v.recordId"));
        //UPDATED BY JOAL - FIELD TYPE FOR ITEM NAME COLUMN CHANGED TO URL AND ADDED ATTRIBUTES
        //{label: 'Item Name', fieldName: 'Item_Name_URL__c', type: 'url', typeAttributes: {label: { fieldName: 'itemName' }, target: '_blank'}, cellAttributes: { class: { fieldName: 'customCSS' }}},
        component.set('v.prcolumns', [
            {label: 'PR No.', fieldName: 'linkName', type: 'url', initialWidth: 110,
             typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Item Name', fieldName: 'Item_Name_Formula__c', type: 'text', initialWidth: 600},
            {label: 'Status', fieldName: 'Status__c', type: 'text', initialWidth: 110},
            {label: 'Cost Price (GST exc) ', fieldName: 'Cost_Price_GST_exc__c', type: 'currency'}, //01 DEC 2022: Remove code for new Cost Price
            //01 DEC 2022: Code for new Cost Price --> {label: 'PR Cost Price', fieldName: 'PR_Cost_Price_GST_exc__c', type: 'currency',editable:true},
            {label: 'Quantity Requested', fieldName: 'Quantity__c', type: 'number',editable:true},
            {label: 'Total Cost Price', fieldName: 'Total_Cost_Price_GST_exc__c', type: 'currency'},
            {type: 'action', typeAttributes: { rowActions: actions } } 
        ]);

        var action = component.get("c.getValidUnits");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.unitList',result);
                if (result.length == 1){
                    component.set("v.assetFilter", 'Unit__c=\'' + result[0].Id + '\'');
                    component.set("v.workOrderFilter", 'Unit__c=\'' + result[0].Id + '\'');
                    component.set("v.selectedDestinationUnit",result[0].Id);
                    component.set("v.hasAssignedUnit", true);
                    component.set("v.destinationUnitName", result[0].Name);
                }
                else {
                    component.set("v.hasAssignedUnit", false);
                }
            }
        });
        $A.enqueueAction(action);

        var plistDepartment = component.get("c.getDepartmentplist");
        plistDepartment.setCallback(this, function(response){
            var state = response.getState();
            if(state === 'SUCCESS'){
                var department = response.getReturnValue();
                component.set("v.departmentpvalue",department);
            }
        });
        $A.enqueueAction(plistDepartment);

        //var plistSubDepartment = component.get("c.getSubDepartmentplist");
        //plistSubDepartment.setCallback(this, function(response){
            //var state = response.getState();
            //if(state === 'SUCCESS'){
                //var subdepartment = response.getReturnValue();
                //component.set("v.subdepartmentpvaluemap",subdepartment);

                //var listOfkeys = []; // for store all map keys (controller picklist values)
                //var ControllerField = []; // for store controller picklist value to set on lightning:select. 

                // play a for loop on Return map 
                // and fill the all map key on listOfkeys variable.
                //for (var singlekey in subdepartment) {
                    //listOfkeys.push(singlekey);
                //}
                            
                //for (var i = 0; i < listOfkeys.length; i++) {
                    //ControllerField.push(listOfkeys[i]);
                //}  
                // set the ControllerField variable values to country(controller picklist field)
                //component.set("v.listControllingValues", ControllerField);

            //}
        //});
        //$A.enqueueAction(plistSubDepartment);
		helper.fetchPR(component,event);
        

        var woId = component.get("v.recordId");
        if (woId != null){
            var workOrderAction = component.get("c.setWorkOrderAssetId");
            workOrderAction.setParams({
                "woId" : component.get("v.recordId")
            });
            workOrderAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var workOrder = response.getReturnValue();
                    if (workOrder != null){
                        component.set('v.selectedWorkOrderId', workOrder.Id);
                        component.set('v.selectedAssetId', workOrder.WD_Asset__c);
                        component.set('v.launchedFromWO', true);
                        console.log('@@ selectedWorkOrderId: ' + workOrder.Id);
                        console.log('## selectedAssetId : ' + component.get("v.selectedAssetId"));
                        console.log('## selectedWorkOrderId : ' + component.get("v.selectedWorkOrderId"));
                    }
                }
            });
            $A.enqueueAction(workOrderAction);
        }
        else {
            component.set("v.selectedAssetId", null);
            component.set("v.selectedWorkOrderId", null);
            console.log('## selectedAssetId : ' + component.get("v.selectedAssetId"));
            console.log('## selectedWorkOrderId : ' + component.get("v.selectedWorkOrderId"));
        }
    },
    
    searchField : function(component, event, helper) {
        var currentText = event.getSource().get("v.value");
        var resultBox = component.find('resultBox');
        component.set("v.LoadingText", true);
        if(currentText.length > 0) {
            $A.util.addClass(resultBox, 'slds-is-open');
        }
        else {
            $A.util.removeClass(resultBox, 'slds-is-open');
        }
        if(currentText.length > 2) {
            var action = component.get("c.getFullItemMasterList");
            action.setParams({
                "value" : currentText
            });
            
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    component.set("v.searchItemMasterRecords", response.getReturnValue());
                    
                }
                else if (STATE === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } 
                    else {
                        console.log("Unknown error");
                    }
                }
                component.set("v.LoadingText", false);
            });
            
            $A.enqueueAction(action);
        }
    },

    onDestinationChange : function(component,event,helper){
        component.set("v.selectedDestinationUnit",component.find('selectedDestinationUnit').get('v.value') );
        component.set("v.assetFilter", 'Unit__c=\'' + component.get("v.selectedDestinationUnit") + '\'');
        component.set("v.workOrderFilter", 'Unit__c=\'' + component.get("v.selectedDestinationUnit") + '\'');

        var action = component.get("c.checkItemData");
        action.setParams({
            "itemMasterId" : component.get("v.selectItemMasterId"),
            "destinationUnitId" : component.get("v.selectedDestinationUnit")
        });
        
        action.setCallback(this, function(response){
            var STATE = response.getState();
            
            if(STATE === "SUCCESS") {
                var itemReturned = response.getReturnValue();
                component.set("v.showSwitch", true);
                component.set("v.inventoryItemRecord", itemReturned.inventoryItem);
                if (itemReturned.inventoryItem == null){
                    component.set("v.isNonIventoryItem", true);
                }
                else {
                    component.set("v.isNonIventoryItem", false);
                    component.set("v.destinationUnitName", itemReturned.inventoryItem.Store_Unit__r.Name);
                    if (itemReturned.inventoryItem.Send_Directly_To_Order__c){
                        component.set("v.sendDirectToOrder", 'Yes');
                    }
                    else {
                        component.set("v.sendDirectToOrder", 'No');
                    }
                }
            }
        });
        
        $A.enqueueAction(action);
    },

    /*onDepartmentPicklistChange: function(component, event, helper) {
        // get the value of select option

        var controllerValueKey = component.find('selectedDepartment').get('v.value');
        var dependentFields = [];
        var subdepartmentpvaluemap = component.get("v.subdepartmentpvaluemap");
        var ListOfDependentFields = subdepartmentpvaluemap[controllerValueKey];

        if ((controllerValueKey != '') && (typeof ListOfDependentFields !== 'undefined')) {
            
            if(ListOfDependentFields.length > 0) {
                for (var i = 0; i < ListOfDependentFields.length; i++) {
                    dependentFields.push(ListOfDependentFields[i]);
                }    
            }  
            
        }

        component.set("v.listDependingValues", dependentFields);

    },*/


    setNoItem : function(component, event, helper){
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBox');
        $A.util.removeClass(resultBox, 'slds-is-open');
        component.set("v.selectItemMasterId", currentText);
        component.set("v.showNoItem",true);
        component.set("v.disableCostPrice",false); //01 DEC 2022: Remove code for new Cost Price
        component.find('userinput').set("v.readonly", true);
        component.set("v.showSwitch", true);
        component.set("v.newItem", true);
        component.set("v.isNonIventoryItem", true);
        component.set("v.selectItemCode", '');
        component.set("v.selectItemPartNumber", '');
        component.set("v.selectItemCostPrice", '');
        component.set("v.prCostPrice", '');
        component.set("v.prTotalCostPrice", '');
    },

    setSelectedItem : function(component, event, helper) {
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBox');
        $A.util.removeClass(resultBox, 'slds-is-open');
        component.set("v.selectItemMasterName", event.currentTarget.dataset.name);
        component.set("v.selectItemMasterId", currentText);

        var itemMasterId = component.get("v.selectItemMasterId"); 
        var searchItemMasterRecords = component.get("v.searchItemMasterRecords");
        var recordIndex = event.currentTarget.dataset.id;

        component.set("v.selectItemMasterId", searchItemMasterRecords[recordIndex].Id);
        component.set("v.selectItemCode", searchItemMasterRecords[recordIndex].Store_Item_Code__c);
        component.set("v.selectItemPartNumber", searchItemMasterRecords[recordIndex].Supplier_Part_Number__c);
        component.set("v.selectItemCostPrice", searchItemMasterRecords[recordIndex].Cost_Price_formula__c);
        component.set("v.prCostPrice", searchItemMasterRecords[recordIndex].Cost_Price__c);

        component.find('userinput').set("v.readonly", true);
        
        var action = component.get("c.checkItemData");
        action.setParams({
            "itemMasterId" : component.get("v.selectItemMasterId"),
            "destinationUnitId" : component.get("v.selectedDestinationUnit")
        });
        
        action.setCallback(this, function(response){
            var STATE = response.getState();
            
            if(STATE === "SUCCESS") {
                var itemReturned = response.getReturnValue();
                component.set("v.showSwitch", true);
                component.set("v.inventoryItemRecord", itemReturned.inventoryItem);
                component.set("v.hasOpenedPRs", itemReturned.hasOpenPRsForSameItem);
                if (itemReturned.inventoryItem == null){
                    component.set("v.isNonIventoryItem", true);
                }
                else {
                    component.set("v.isNonIventoryItem", false);
                    if (itemReturned.inventoryItem.Send_Directly_To_Order__c){
                        component.set("v.sendDirectToOrder", 'Yes');
                    }
                    else {
                        component.set("v.sendDirectToOrder", 'No');
                    }
                }
            }
        });
        
        $A.enqueueAction(action);
        
    },

    resetDataNow : function(component, event, helper) {
        component.set("v.showSwitch",false);
        component.set("v.showNoItem",false);
        component.set("v.quantity", "");
        component.set("v.prTotalCostPrice", "");
        component.set("v.disableCostPrice",true); //01 DEC 2022: Remove code for new Cost Price
        helper.resetData(component,event, helper);
    },

    
    createPurchaseRequest : function(component, event, helper) {
        var destinationUnit = component.get("v.selectedDestinationUnit");
        
        
        var whichButtonClicked = event.getSource().getLocalId();
        console.log(whichButtonClicked);
        if(whichButtonClicked == 'createPRAddAnotherBtn'){
           component.set("v.createPRAddAnother", true);
        }
        event.getSource().set("v.disabled", true);
        var quantity = component.get("v.quantity");
        var staffName = component.get("v.staffName");
        var costAllocId = component.get("v.selectedCostAllocationId");
        var nonInventory = component.get("v.isNonIventoryItem");
        var avlStocks = component.get("v.inventoryItemRecord.Stock_Available_formula__c");
        var hasAssignedUnit = component.get("v.hasAssignedUnit");
        var hasOpenedPRs = component.get("v.hasOpenedPRs");
        var department = component.find('selectedDepartment').get('v.value');
        //var subdepartment = component.find('selectedsubDepartment').get('v.value');
        var itemname = component.get("v.selectItemMasterName");
        var notes = (component.get('v.notes') == null) ? '' : component.get('v.notes');
        var hasFileUploaded = component.get("v.hasFileUploaded");
        var prcostprice = component.get('v.prCostPrice'); 
        var hasErrors = false;

        if(staffName == null){
            var toastEvent = $A.get("e.force:showToast");
            hasErrors = true;
            toastEvent.setParams({
                title : 'Error',
                message:'Staff name is required.',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            event.getSource().set("v.disabled", false);
        } 
        if (costAllocId == null){
            var toastEvent = $A.get("e.force:showToast");
            hasErrors = true;
            toastEvent.setParams({
                title : 'Error',
                message:'Cost Allocation Unit is required',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            event.getSource().set("v.disabled", false);
        } 
        if(quantity == null){
            var toastEvent = $A.get("e.force:showToast");
            hasErrors = true;
            toastEvent.setParams({
                title : 'Error',
                message:'Quantity is required.',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            event.getSource().set("v.disabled", false);
        }
        else if (quantity == 0){ 
            var toastEvent = $A.get("e.force:showToast");
            hasErrors = true;
            toastEvent.setParams({
                title : 'Error',
                message:'Quantity entered cannot be zero',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            event.getSource().set("v.disabled", false);
        }
        else if (!nonInventory && quantity > avlStocks){ // if inventory item and quantity is greater than available stock
            var toastEvent = $A.get("e.force:showToast");
            hasErrors = true;
            toastEvent.setParams({
                title : 'Error',
                message:'Quantity entered is greater than available stocks. Please check and try again.',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            event.getSource().set("v.disabled", false);
        }
        /*if (prcostprice == ''){ // PR Cost Price is required 01 DEC 2022: Code for new Cost Price
            var toastEvent = $A.get("e.force:showToast");
            hasErrors = true;
            toastEvent.setParams({
                title : 'Error',
                message:'PR Cost Price is required.',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            event.getSource().set("v.disabled", false);
        }*/
        if (itemname.length > 80){ // if Item Name is more than 80 characters
            var toastEvent = $A.get("e.force:showToast");
            hasErrors = true;
            toastEvent.setParams({
                title : 'Error',
                message:'Item Name is more than 80 characters.',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            event.getSource().set("v.disabled", false);
        }
        if (notes.length > 255){ // if Notes is more than 255 characters
            var toastEvent = $A.get("e.force:showToast");
            hasErrors = true;
            toastEvent.setParams({
                title : 'Error',
                message:'Notes should be less than 256 characters.',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            event.getSource().set("v.disabled", false);
        }

        if (!destinationUnit){ // if destination unit is blank null or undefined
            var toastEvent = $A.get("e.force:showToast");
            hasErrors = true;
            toastEvent.setParams({
                title : 'Error',
                message:'Please enter a Destination Unit',
                duration:' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            event.getSource().set("v.disabled", false);
        }

        if (!hasErrors){
            helper.createPRRecords(component,event,helper); 
        }
        
    },
    
    handleSelect : function(component, event, helper) {
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            
            setRows.push(selectedRows[i]);
        }
        component.set("v.selectedPRs", setRows);
    },

    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        switch (action.name) {
            case 'delete':
                helper.deleteRecord(component, event);
                break;
        }
    },

    sendForApproval : function(component, event, helper) {
        event.getSource().set("v.disabled", true);
        var draftListToSubmit = component.get("v.selectedPRs");
        if(draftListToSubmit.length == 0){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Please select at least 1 Purchase Request',
                    duration:' 3000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
        }
        else if(draftListToSubmit.length > 0 ){
            var action = component.get("c.submitForApproval");
            action.setParams({
                "prsToSubmit" : draftListToSubmit
            });
            
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Selected purchase requests submited for approval',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    $A.get('e.force:refreshView').fire();
                }
                else{
                    var errorMsg = response.getError();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'There is an error submitting your PR\'s for approval. Please try again later or contact your administrator.',
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
    },

    handleSavePRs: function (component, event, helper) {
        var draftValues = event.getParam('draftValues');
        console.log('draftValues-> ' + JSON.stringify(draftValues));
        var action = component.get('c.updatePRs');
        action.setParams({"prList": draftValues});
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Purchase requests updated',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            } else if (state === "ERROR") {
                var errorMsg = response.getError();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'There is an error updating your Purchase requests: ' + errorMsg,
                    message: errorMsg,
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

    handleUploadFinished: function (component, event, helper) {
        // Get the list of uploaded files
        var uploadedFiles = event.getParam("files");
        var listuploaded = [];

        if (uploadedFiles.length > 0){
            component.set("v.hasFileUploaded", true);

            // Get the file name
            uploadedFiles.forEach(file => listuploaded.push(file.documentId));
            component.set("v.listUploadedFiles", listuploaded);

        }
    },

    computeTotalCostPrice: function (component, event, helper) {

		var prcostprice = component.get('v.prCostPrice'); 
        var quantity = component.get('v.quantity'); 
        var prtotalcostprice = prcostprice * quantity;

        component.set("v.prTotalCostPrice", prtotalcostprice);
    }
})