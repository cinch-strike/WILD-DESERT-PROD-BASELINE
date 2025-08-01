// Add Permission Sets to their corresponding Permission Set Groups
List<PermissionSetGroupComponent> components = new List<PermissionSetGroupComponent>();

// Mapping: Permission Set ID -> Permission Set Group ID
Map<String, String> permissionSetToGroupMap = new Map<String, String>{
    '0PSOn000000382fOAA' => '0PGOn0000000vO5OAI', // Purchase_Order_Send -> Purchase_Order_Send_Group
    '0PS0o000003DZmJGAW' => '0PGOn0000000vO6OAI', // Purchase_Request_Administrator -> Purchase_Request_Administrator_Group  
    '0PS0o000001vz5CGAQ' => '0PGOn0000000vO7OAI'  // Transport_Driver_Full_Access -> Transport_Driver_Full_Access_Group
};

// Create Permission Set Group Components (relationships)
for (String permissionSetId : permissionSetToGroupMap.keySet()) {
    PermissionSetGroupComponent component = new PermissionSetGroupComponent();
    component.PermissionSetGroupId = permissionSetToGroupMap.get(permissionSetId);
    component.PermissionSetId = permissionSetId;
    components.add(component);
}

try {
    insert components;
    System.debug('Successfully added ' + components.size() + ' Permission Sets to their Permission Set Groups:');
    
    // Query to verify the relationships
    List<PermissionSetGroupComponent> verifyComponents = [
        SELECT Id, PermissionSetGroup.DeveloperName, PermissionSetGroup.MasterLabel, 
               PermissionSet.Name, PermissionSet.Label
        FROM PermissionSetGroupComponent 
        WHERE Id IN :components
    ];
    
    for (PermissionSetGroupComponent comp : verifyComponents) {
        System.debug('Added: ' + comp.PermissionSet.Name + ' (' + comp.PermissionSet.Label + ') -> ' + 
                    comp.PermissionSetGroup.DeveloperName + ' (' + comp.PermissionSetGroup.MasterLabel + ')');
    }
    
} catch (Exception e) {
    System.debug('Error adding Permission Sets to Groups: ' + e.getMessage());
}
