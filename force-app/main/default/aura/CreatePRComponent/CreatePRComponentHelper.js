({
    resetData : function(component, event,helper) {
        component.set("v.selectRecordName", "");
        component.set("v.selectRecordId", "");
        component.find('userinput').set("v.readonly", false);
        component.set("v.qty","");
    },
    
    createPRRecords : function(component,event,helper){
        var qty = component.get("v.qty");
        console.log('## qty in helper: ' + qty);
        var storeName = component.get("v.unitRecords.Store_Unit__r.Name");
        var action = component.get("c.createPR");
        
        //[VP 19/11] Added logic for Non-inventory Item
        if(storeName != undefined){
            action.setParams({
                "Qty" : qty,
                "unitRecords" : component.get("v.unitRecords"),
                "storeName" : storeName,
                "staffName" : component.get("v.staffName"),
                "DestinationStore" : component.get("v.selectedDestinationUnit"),
                "itemName" : component.get("v.selectRecordName")
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    console.log('## SUCCESS create PR records');
                    var prRec = response.getReturnValue();
                    if(prRec.created){
                        console.log('## prre created');                    
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
                        component.set("v.showSwitch",false);
                        helper.resetData(component,event,helper);
                    }
                    else{
                        var draftPRList = component.get("v.draftPRList");
                        draftPRList.push(prRec);
                        component.set("v.draftPRList",draftPRList);
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
                        component.set("v.showSwitch",false);
                        helper.resetData(component,event,helper);
                    }
                    $A.get('e.force:refreshView').fire();
                    
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: response.getError(),
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    event.getSource().set("v.disabled", false);
                }
            });
        } else {

            action.setParams({
                "Qty" : qty,
                "unitRecords" : component.get("v.unitRecords"),
                "storeName" : "undefined",
                "staffName" : component.get("v.staffName"),
                "DestinationStore" : component.get("v.selectedDestinationUnit"),
                "itemName" : component.get("v.selectRecordName")
            });
            action.setCallback(this, function(response){
                var STATE = response.getState();
                if(STATE === "SUCCESS") {
                    console.log('## SUCCESS create PR records');
                    var prRec = response.getReturnValue();
                    if(prRec.created){
                        console.log('## prre created');                    
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
                        component.set("v.showSwitch",false);
                        helper.resetData(component,event,helper);
                    }
                    else{
                        var draftPRList = component.get("v.draftPRList");
                        draftPRList.push(prRec);
                        component.set("v.draftPRList",draftPRList);
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
                        component.set("v.showSwitch",false);
                        helper.resetData(component,event,helper);
                    }
                    $A.get('e.force:refreshView').fire();
                    
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: response.getError(),
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    event.getSource().set("v.disabled", false);
                }
            });
        }
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
                    message: 'The record has been delete successfully.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'success',
                    mode: 'pester'
                });
                toastEvent.fire();
                ///this.showToast("Success!","success","The record has been delete successfully.");
            }
            else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title : 'Error',
                    message: response.getError(),
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },
})