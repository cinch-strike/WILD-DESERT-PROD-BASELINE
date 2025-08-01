({
	doInit : function(component, event, helper) {
        var unitIdAction = component.get("c.getUnitId");
        unitIdAction.setCallback(this, function(data) {
          	var unitId = data.getReturnValue();
            if (unitId != null){
            	component.set("v.unitPath", "/lightning/r/Unit__c/" + unitId + "/view"); 
                component.set("v.unitEmployeesPath", "/lightning/r/" + unitId + "/related/Employees__r/view");
            }
            else {
                component.set("v.unitPath", "#");    
            }
        });
        $A.enqueueAction(unitIdAction);
        
        var unitNameAction = component.get("c.getUnitName");
        unitNameAction.setCallback(this, function(data) {
          	var unitName = data.getReturnValue();
            if (unitName != null){
            	component.set("v.unitName", unitName); 
            }
            else {
                component.set("v.unitName", "Click to View Unit");    
            }
        });
        $A.enqueueAction(unitNameAction);
        
        var activeEmAction = component.get("c.getActiveOnshiftEmployees");
        activeEmAction.setCallback(this, function(data) {
          	var activeEmMsg = data.getReturnValue() + ' total active on-shift employees';
            component.set("v.activeEmployees", activeEmMsg);  
        });
        $A.enqueueAction(activeEmAction);
        
	}
})