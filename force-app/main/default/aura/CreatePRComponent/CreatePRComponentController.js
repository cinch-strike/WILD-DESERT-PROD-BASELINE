({
    doInit : function(component, event, helper) {
        var actions = [
            {label: 'Delete', name: 'delete'}
        ];
        
        component.set('v.prcolumns', [
            {label: 'PR No.', fieldName: 'linkName', type: 'url', 
             typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'}},
            {label: 'Item Name', fieldName: 'Item_Name_URL__c', type: 'text'},
            {label: 'Status', fieldName: 'Status__c', type: 'text'},
            {label: 'Requested Quantity', fieldName: 'Quantity__c', type: 'number',editable:true},
            {type: 'action', typeAttributes: { rowActions: actions } } 
        ]);
        
        var action = component.get("c.fetchDraftPRs");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                var unitRecs = result.allUnitList;
                var records = result.prList;
                records.forEach(function(record){
                    record.linkName = '/'+record.Id;
                });
                component.set('v.prList',records);
				component.set('v.unitList',unitRecs);                
            }
        });
        $A.enqueueAction(action);
    },
    
    handleRowAction: function (component, event, helper) {
        var action = event.getParam('action');
        switch (action.name) {
            case 'delete':
                helper.deleteRecord(component, event);
                break;
        }
    },
    
    closeModel : function(component, event, helper) {
        component.set('v.showSwitch',false);
    },
    
    startPRCreate : function(component,event,helper){
        event.getSource().set("v.disabled", true);
        var destinationPresent = component.get("v.unitList");
        var qty = component.get("v.qty");
        var staff = component.get("v.staffName");
        var avlStocks = component.get("v.unitRecords.Stock_Available_formula__c");
        var storeName = component.get("v.unitRecords.Store_Unit__r.Name");
        
        //[VP 19/11]: Added logic for non-inventory items
        if(storeName != null && avlStocks != null) {
            if(avlStocks < qty && storeName != 'Roma Base Camp' ) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Entered Quantity cannot be greater than Available Quantity',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                event.getSource().set("v.disabled", false);
            }else if(qty == null || staff == null){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Please fill Requested Quantity and Staff Name Fields',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                event.getSource().set("v.disabled", false);
            }else if( destinationPresent.length > 0 && component.get("v.unitList") != null &&  component.find('selectedDestinationUnit').get('v.value') == 'x'){ 
            
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message:'Please select Destination store.',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire(); 
                    event.getSource().set("v.disabled", false);
                
            }else if(qty == 0){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Entered Quantity cannot be Zero',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                event.getSource().set("v.disabled", false);
            }else if(avlStocks < qty && storeName == 'Roma Base Camp'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Warning',
                        message:'Not enough stocks. Once Purchase Request is approved, some of the stocks will be requested for ordering',
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    helper.createPRRecords(component,event,helper);
                }else{
                    helper.createPRRecords(component,event,helper);
                }
        }else if(storeName == null && avlStocks == null){
            if(qty == null || staff == null){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Please fill Requested Quantity and Staff Name Fields',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                event.getSource().set("v.disabled", false);
            }else if(qty == 0){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message:'Entered Quantity cannot be Zero',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                event.getSource().set("v.disabled", false);
            }else{
                helper.createPRRecords(component,event,helper);
            }
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
            var action = component.get("c.getResults");
            action.setParams({
                "ObjectName" : component.get("v.objectName"),
                "fieldName" : component.get("v.fieldName"),
                "value" : currentText
            });
            
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    component.set("v.searchRecords", response.getReturnValue());
                    if(component.get("v.searchRecords").length == 0) {
                        console.log('000000');
                    }
                }
                else if (STATE === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
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
    },
    
    searchAssetField : function(component, event, helper) {
        var currentText = event.getSource().get("v.value");
        var resultBox = component.find('resultBoxAsset');
        component.set("v.LoadingText", true);
        
        if(currentText.length > 0) {
            $A.util.addClass(resultBox, 'slds-is-open');
        }
        else {
            $A.util.removeClass(resultBox, 'slds-is-open');
        }
        
        var unitForComparison ; 
        if(component.get("v.selectedDestinationUnit") != null){
            unitForComparison = component.get("v.selectedDestinationUnit");
        }else{
            unitForComparison = component.get("v.selectRecordId");
        }
        
        console.log('objectName == '+component.get("v.objectName"));
        console.log('fieldName == '+component.get("v.fieldName"));
        console.log('currentText == '+currentText);
        console.log('selectRecordId == '+component.get("v.selectRecordId"));
        
        if(currentText.length > 2) {
            var action = component.get("c.getAssetResults");
            action.setParams({
                "ObjectName" : component.get("v.objectName"),
                "fieldName" : component.get("v.fieldName"),
                "value" : currentText,
                "unit" : unitForComparison
            });
            
            action.setCallback(this, function(response){
                console.log('response == '+response);
                var STATE = response.getState();
                console.log('STATE == '+STATE);
                console.log('response 2 == '+response.getReturnValue());
                if(STATE === "SUCCESS") {
                    component.set("v.searchAssetRecords", response.getReturnValue());
                    if(component.get("v.searchAssetRecords").length == 0) {
                        console.log('000000');
                    }
                }
                else if (STATE === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: errors[0].message,
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                            //alert(" 11Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                component.set("v.LoadingText", false);
            });
            
            $A.enqueueAction(action);
        }
    },
    
    searchWorkOrder : function(component, event, helper) {
        var currentText = event.getSource().get("v.value");
        var resultBox = component.find('resultBoxWorkOrder');
        component.set("v.LoadingText", true);
        
        if(currentText.length > 0) {
            $A.util.addClass(resultBox, 'slds-is-open');
        }
        else {
            $A.util.removeClass(resultBox, 'slds-is-open');
        }
        
        var unitForComparison ; 
        if(component.get("v.selectedDestinationUnit") != null){
            unitForComparison = component.get("v.selectedDestinationUnit");
        }else{
            unitForComparison = component.get("v.selectRecordId");
        }
        
        console.log('objectName == '+component.get("v.objectName"));
        console.log('fieldName == '+component.get("v.fieldName"));
        console.log('currentText == '+currentText);
        console.log('selectRecordId == '+component.get("v.selectRecordId"));
        
        if(currentText.length > 2) {
            var action = component.get("c.getWorkOrderResults");
            action.setParams({
                "ObjectName" : component.get("v.objectName"),
                "fieldName" : component.get("v.fieldName"),
                "value" : currentText,
                "unit" : unitForComparison
            });
            
            action.setCallback(this, function(response){
                console.log('response == '+response);
                var STATE = response.getState();
                console.log('STATE == '+STATE);
                console.log('response 2 == '+response.getReturnValue());
                if(STATE === "SUCCESS") {
                    component.set("v.searchWorkOrderRecords", response.getReturnValue());
                    if(component.get("v.searchWorkOrderRecords").length == 0) {
                        console.log('000000');
                    }
                }
                else if (STATE === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                title : 'Error',
                                message: errors[0].message,
                                duration:' 5000',
                                key: 'info_alt',
                                type: 'error',
                                mode: 'pester'
                            });
                            toastEvent.fire();
                            //alert("Error message: " + errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
                component.set("v.LoadingText", false);
            });
            
            $A.enqueueAction(action);
        }
    },
    
    
    setSelectedRecord : function(component, event, helper) {
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBox');
        $A.util.removeClass(resultBox, 'slds-is-open');
        component.set("v.selectRecordName", event.currentTarget.dataset.name);
        component.set("v.selectRecordId", currentText);
        component.find('userinput').set("v.readonly", true);
        
        var action = component.get("c.checkOthers");
        action.setParams({
            "recId" : component.get("v.selectRecordId"),
        });
        
        action.setCallback(this, function(response){
            var STATE = response.getState();
            
            if(STATE === "SUCCESS") {
                //alert(response.getReturnValue());
                component.set("v.showSwitch", true);
                if(JSON.stringify(response.getReturnValue()) != '{}'){
                    component.set("v.unitRecords", response.getReturnValue());
                    component.set("v.isNonIventoryItem",false);
                    
                    if(response.getReturnValue().Store_Unit__r.Name == 'Roma Base Camp'){
                        component.set("v.isCreatePR",true);
                    }
                    
                } else {
                    component.set("v.unitRecords", "");
                    component.set("v.isNonIventoryItem",true);
                }
            }
        });
        
        $A.enqueueAction(action);
    }, 
    
    setSelectedAssetRecord : function(component, event, helper) {
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBoxAsset');
        $A.util.removeClass(resultBox, 'slds-is-open');
        component.set("v.selectAssetName", event.currentTarget.dataset.name);
        component.set("v.selectAssetId", currentText);
        component.find('userinputAsset').set("v.readonly", true);
        
        /*var action = component.get("c.checkOthers");
        action.setParams({
            "recId" : component.get("v.selectRecordId"),
        });
        
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                //alert(response.getReturnValue());
                component.set("v.unitRecords", response.getReturnValue());
                component.set("v.showSwitch", true);
                if(response.getReturnValue().Store_Unit__r.Name == 'Roma Base Camp'){
                    component.set("v.isCreatePR",true);
                }
            }
        });
        
        $A.enqueueAction(action);*/
    }, 
    
    setSelectedWorkOrderRecord : function(component, event, helper) {
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBoxWorkOrder');
        $A.util.removeClass(resultBox, 'slds-is-open');
        component.set("v.selectWorkOrderName", event.currentTarget.dataset.name);
        component.set("v.selectWorkOrderId", currentText);
        component.find('userinputWorkOrder').set("v.readonly", true);
        
        /*var action = component.get("c.checkOthers");
        action.setParams({
            "recId" : component.get("v.selectRecordId"),
        });
        
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                //alert(response.getReturnValue());
                component.set("v.unitRecords", response.getReturnValue());
                component.set("v.showSwitch", true);
                if(response.getReturnValue().Store_Unit__r.Name == 'Roma Base Camp'){
                    component.set("v.isCreatePR",true);
                }
            }
        });
        
        $A.enqueueAction(action);*/
    }, 
    
    resetDataNow : function(component, event, helper) {
        component.set("v.showSwitch",false);
        component.set("v.showNoItem",false);
        helper.resetData(component,event, helper);
    },
    
    assetResetDataNow : function(component, event, helper) {
        component.set("v.selectAssetName", "");
        component.set("v.selectAssetId", "");
        component.find('userinputAsset').set("v.readonly", false);
    },
    
    workorderResetDataNow : function(component, event, helper) {
        component.set("v.selectWorkOrderName", "");
        component.set("v.selectWorkOrderId", "");
        component.find('userinputWorkOrder').set("v.readonly", false);
    },
    
    setNoItem : function(component, event, helper){
        var currentText = event.currentTarget.id;
        var resultBox = component.find('resultBox');
        $A.util.removeClass(resultBox, 'slds-is-open');
        //component.set("v.selectRecordName", event.currentTarget.dataset.name);
        component.set("v.selectRecordId", currentText);
        component.set("v.showNoItem",true);
        component.find('userinput').set("v.readonly", true);
    },
    
    createNoItemPR : function(component, event, helper){
        event.getSource().set("v.disabled", true);
        console.log('## no item pr');
        var Qty = component.get("v.noItemQty");
        var Staff = component.get("v.staffName");

        //[VP 19/11] Added validation for undefined quantity or staff name
        if (Qty == undefined || Staff == undefined){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Please fill Requested Quantity and Staff Name Fields',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            event.getSource().set("v.disabled", false);
        }else if(Qty == 0){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Error',
                message:'Entered Quantity cannot be Zero',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            event.getSource().set("v.disabled", false);
        }else{
            var action = component.get("c.noItemPRCreate");
            action.setParams({
                "Qty" : component.get("v.noItemQty"),
                "itemName" : component.get("v.selectRecordName"),
                "staffName" : component.get("v.staffName"),
                "DestinationStore" : component.get("v.selectedDestinationUnit")
            });
            
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    console.log('## SUCCESS');
                    
                    var prRec = response.getReturnValue();
                    var draftPRList = component.get("v.draftPRList");
                    draftPRList.push(prRec);
                    component.set("v.draftPRList",draftPRList);
                    component.set("v.showSwitch",false);
                    component.set("v.showNoItem",false);
                    component.set("v.noItemQty",null);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Draft PR added',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    helper.resetData(component,event, helper);
                    $A.get('e.force:refreshView').fire();
                    
                    
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    checkAll : function(component,event,helper){
        var checkval = component.get("v.checkAllCheckBox");
        console.log('###'+checkval);
        var recordCount = component.get("v.draftPRList");
        for (var i = 0; i < recordCount.length; i++) {
            if(!checkval){
                recordCount[i].selected = true;
            } else {
                recordCount[i].selected = false;
            }
            console.log('@@@@'+recordCount[i].selected);
        }
        component.set("v.draftPRList",recordCount);
        component.set("v.checkAllCheckBox",!checkval);
    },
    
    removeRow : function(component,event,helper){
        var target = event.target;
        var rowIndex = target.getAttribute("data-row-index");
        var draftList = component.get("v.draftPRList");
        draftList.splice(rowIndex,1);
        component.set("v.draftPRList",draftList);
    },
    
    approve : function(component,event,helper){
        var draftList = component.get("v.draftPRList");
        var draftListToSave = [];
        for(var i = 0; i < draftList.length; i++){
            if(draftList[i].selected){
                draftListToSave.push(draftList[i].pr);
            }
        }
        console.log('@@@'+JSON.stringify(draftListToSave));
        var action = component.get("c.createPrDraft");
        action.setParams({
            "draftPRToCreate" : draftListToSave
        });
        
        action.setCallback(this, function(response){
            var STATE = response.getState();
            if(STATE === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Success',
                    message: 'Purchase Request Created',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    },
    
    handleSelect : function(component, event, helper) {
        
        var selectedRows = event.getParam('selectedRows'); 
        var setRows = [];
        for ( var i = 0; i < selectedRows.length; i++ ) {
            
            setRows.push(selectedRows[i]);
            
        }
        component.set("v.selectedPRs", setRows);
        
    },
    
    sendForApproval : function(component, event, helper) {
        event.getSource().set("v.disabled", true);
        var draftListToSubmit = component.get("v.selectedPRs");
        console.log('@@@'+JSON.stringify(draftListToSubmit));
        if(draftListToSubmit.length == 0){
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: 'Please Select a Purchase Request First',
                    duration:' 5000',
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
                        message: 'PRs submited for approval',
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
                        title : 'Error',
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
    }
    
})