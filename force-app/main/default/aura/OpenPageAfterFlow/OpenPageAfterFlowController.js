({    invoke : function(component, event, helper) {
    // Get the record ID attribute
    var record = component.get("v.recordId");
    var vfpage = component.get("v.vfpage");
    var urlpage = '/apex/' + vfpage + '?id=' + record;
    
    // Get the Lightning event that opens a record in a new tab
    var redirect = $A.get("e.force:navigateToURL");
    
    // Pass the record ID to the event
    redirect.setParams({
       "url": urlpage
    });
         
    // Open the record
    redirect.fire();
 }})