// Add the muting Permission Sets to their corresponding Permission Set Groups
// This will create the muting effect when the muting Permission Sets are activated

List<PermissionSetGroupComponent> mutingComponents = new List<PermissionSetGroupComponent>();

// Mapping: Muting Permission Set ID -> Permission Set Group ID
Map<String, String> mutingToGroupMap = new Map<String, String>{
    '0PSOn0000006aGvOAI' => '0PGOn0000000vO5OAI', // Purchase_Order_Send_Muting -> Purchase_Order_Send_Group
    '0PSOn0000006aGwOAI' => '0PGOn0000000vO6OAI', // Purchase_Request_Admin_Muting -> Purchase_Request_Administrator_Group
    '0PSOn0000006aGxOAI' => '0PGOn0000000vO7OAI'  // Transport_Driver_Muting -> Transport_Driver_Full_Access_Group
};

// Create Permission Set Group Components for muting Permission Sets
for (String mutingPermissionSetId : mutingToGroupMap.keySet()) {
    PermissionSetGroupComponent component = new PermissionSetGroupComponent();
    component.PermissionSetGroupId = mutingToGroupMap.get(mutingPermissionSetId);
    component.PermissionSetId = mutingPermissionSetId;
    mutingComponents.add(component);
}

try {
    insert mutingComponents;
    System.debug('Successfully added ' + mutingComponents.size() + ' muting Permission Sets to Permission Set Groups:');
    
    // Query to verify the relationships
    List<PermissionSetGroupComponent> verifyComponents = [
        SELECT Id, PermissionSetGroup.DeveloperName, PermissionSetGroup.MasterLabel, 
               PermissionSet.Name, PermissionSet.Label
        FROM PermissionSetGroupComponent 
        WHERE Id IN :mutingComponents
    ];
    
    for (PermissionSetGroupComponent comp : verifyComponents) {
        System.debug('Added Muting PS: ' + comp.PermissionSet.Name + ' (' + comp.PermissionSet.Label + ') -> ' + 
                    comp.PermissionSetGroup.DeveloperName + ' (' + comp.PermissionSetGroup.MasterLabel + ')');
    }
    
    System.debug('');
    System.debug('🔇 MUTING SETUP COMPLETE!');
    System.debug('To mute Purchase_Request__c Read permissions:');
    System.debug('1. Navigate to Setup → Permission Sets');
    System.debug('2. Find the muting Permission Sets and grant them minimal Read access to Purchase_Request__c');
    System.debug('3. The Permission Set Groups will now have conflicting permissions');
    System.debug('4. Salesforce will apply the most restrictive permission (Read = false)');
    
} catch (Exception e) {
    System.debug('Error adding muting Permission Sets to groups: ' + e.getMessage());
}
