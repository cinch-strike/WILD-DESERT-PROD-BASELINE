// Check the muting Permission Set for Permission Set Group 0PGOn0000000vO7OAI
// and verify its current object permissions for Purchase_Request__c

String targetGroupId = '0PGOn0000000vO7OAI';

// Find the Permission Set Group and its components
PermissionSetGroup psg = [
    SELECT Id, DeveloperName, MasterLabel 
    FROM PermissionSetGroup 
    WHERE Id = :targetGroupId
];

System.debug('Permission Set Group: ' + psg.DeveloperName + ' (' + psg.MasterLabel + ')');
System.debug('');

// Get all Permission Sets in this group
List<PermissionSetGroupComponent> components = [
    SELECT Id, PermissionSetId, PermissionSet.Name, PermissionSet.Label, PermissionSet.Type
    FROM PermissionSetGroupComponent 
    WHERE PermissionSetGroupId = :targetGroupId
];

String mutingPermissionSetId = null;

System.debug('Permission Sets in Group:');
for (PermissionSetGroupComponent comp : components) {
    System.debug('- ' + comp.PermissionSet.Name + ' (' + comp.PermissionSet.Label + ') - Type: ' + comp.PermissionSet.Type);
    
    // Find the muting Permission Set (should contain "Muting" in the name)
    if (comp.PermissionSet.Name.contains('Muting')) {
        mutingPermissionSetId = comp.PermissionSetId;
        System.debug('  → This is the MUTING Permission Set');
    }
}

System.debug('');

if (mutingPermissionSetId != null) {
    System.debug('Checking object permissions for Purchase_Request__c in muting Permission Set...');
    
    // Check if ObjectPermissions exist for Purchase_Request__c
    List<ObjectPermissions> existingPerms = [
        SELECT Id, ParentId, SobjectType, PermissionsRead, PermissionsCreate, 
               PermissionsEdit, PermissionsDelete, PermissionsViewAllRecords, PermissionsModifyAllRecords
        FROM ObjectPermissions 
        WHERE ParentId = :mutingPermissionSetId 
        AND SobjectType = 'Purchase_Request__c'
    ];
    
    if (existingPerms.isEmpty()) {
        System.debug('❌ NO ObjectPermissions found for Purchase_Request__c in muting Permission Set');
        System.debug('Muting Permission Set ID: ' + mutingPermissionSetId);
        System.debug('Need to create ObjectPermissions to mute Purchase_Request__c access');
    } else {
        System.debug('✅ ObjectPermissions found for Purchase_Request__c:');
        for (ObjectPermissions perm : existingPerms) {
            System.debug('- Read: ' + perm.PermissionsRead);
            System.debug('- Create: ' + perm.PermissionsCreate);
            System.debug('- Edit: ' + perm.PermissionsEdit);
            System.debug('- Delete: ' + perm.PermissionsDelete);
            System.debug('- View All: ' + perm.PermissionsViewAllRecords);
            System.debug('- Modify All: ' + perm.PermissionsModifyAllRecords);
        }
    }
} else {
    System.debug('❌ No muting Permission Set found in this group!');
}
