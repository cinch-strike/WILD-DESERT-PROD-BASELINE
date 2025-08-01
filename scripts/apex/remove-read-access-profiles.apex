// Remove Read access to Purchase_Request__c object from all custom profiles
// This will help control access during deployments while keeping QA backup for rollback

System.debug('🔒 REMOVING READ ACCESS TO Purchase_Request__c FROM ALL CUSTOM PROFILES');
System.debug('');

// Step 1: Get all custom profiles (excluding standard Salesforce profiles)
List<Profile> customProfiles = [
    SELECT Id, Name, UserType
    FROM Profile 
    WHERE UserType = 'Standard'
    AND Name NOT IN (
        'System Administrator',
        'Standard User', 
        'Marketing User',
        'Contract Manager',
        'Solution Manager',
        'Read Only',
        'Standard Platform User',
        'Minimum Access - Salesforce',
        'Chatter Free User',
        'Chatter Moderator User',
        'Customer Portal Manager Standard',
        'Customer Portal Manager Custom',
        'High Volume Customer Portal',
        'Authenticated Website',
        'Guest License User'
    )
    ORDER BY Name
];

System.debug('📋 FOUND ' + customProfiles.size() + ' CUSTOM PROFILES:');
for (Profile p : customProfiles) {
    System.debug('- ' + p.Name + ' (ID: ' + p.Id + ')');
}
System.debug('');

if (customProfiles.isEmpty()) {
    System.debug('❌ No custom profiles found to update');
    return;
}

// Step 2: Get current ObjectPermissions for Purchase_Request__c on these profiles
Set<Id> profileIds = new Set<Id>();
for (Profile p : customProfiles) {
    profileIds.add(p.Id);
}

List<ObjectPermissions> existingPerms = [
    SELECT Id, ParentId, Parent.Name, SobjectType, 
           PermissionsRead, PermissionsCreate, PermissionsEdit, PermissionsDelete,
           PermissionsViewAllRecords, PermissionsModifyAllRecords
    FROM ObjectPermissions 
    WHERE ParentId IN :profileIds
    AND SobjectType = 'Purchase_Request__c'
    ORDER BY Parent.Name
];

System.debug('🔍 CURRENT Purchase_Request__c PERMISSIONS ON PROFILES:');
if (existingPerms.isEmpty()) {
    System.debug('❌ No existing ObjectPermissions found for Purchase_Request__c on custom profiles');
    System.debug('This means profiles already have no explicit permissions for this object');
    return;
}

// Show current permissions
Map<Id, ObjectPermissions> profileToPermissionMap = new Map<Id, ObjectPermissions>();
for (ObjectPermissions perm : existingPerms) {
    profileToPermissionMap.put(perm.ParentId, perm);
    System.debug('Profile: ' + perm.Parent.Name);
    System.debug('  Read: ' + perm.PermissionsRead + 
                 ', Create: ' + perm.PermissionsCreate + 
                 ', Edit: ' + perm.PermissionsEdit + 
                 ', Delete: ' + perm.PermissionsDelete);
    System.debug('  View All: ' + perm.PermissionsViewAllRecords + 
                 ', Modify All: ' + perm.PermissionsModifyAllRecords);
    System.debug('');
}

// Step 3: Update permissions to remove Read access
List<ObjectPermissions> permsToUpdate = new List<ObjectPermissions>();
List<ObjectPermissions> permsToDelete = new List<ObjectPermissions>();

for (ObjectPermissions perm : existingPerms) {
    if (perm.PermissionsRead) {
        // Check if removing Read would leave any other permissions
        Boolean hasOtherPermissions = perm.PermissionsCreate || 
                                     perm.PermissionsEdit || 
                                     perm.PermissionsDelete || 
                                     perm.PermissionsViewAllRecords || 
                                     perm.PermissionsModifyAllRecords;
        
        if (hasOtherPermissions) {
            // Update to remove only Read permission
            perm.PermissionsRead = false;
            permsToUpdate.add(perm);
        } else {
            // If only Read permission exists, delete the entire ObjectPermissions record
            permsToDelete.add(perm);
        }
    }
}

System.debug('🔄 EXECUTING PERMISSION UPDATES...');
System.debug('Permissions to update (remove Read only): ' + permsToUpdate.size());
System.debug('Permissions to delete (Read was only permission): ' + permsToDelete.size());
System.debug('');

try {
    // Update permissions where other permissions remain
    if (!permsToUpdate.isEmpty()) {
        update permsToUpdate;
        System.debug('✅ Updated ' + permsToUpdate.size() + ' ObjectPermissions (removed Read access)');
    }
    
    // Delete permissions where Read was the only permission
    if (!permsToDelete.isEmpty()) {
        delete permsToDelete;
        System.debug('✅ Deleted ' + permsToDelete.size() + ' ObjectPermissions (Read was only permission)');
    }
    
    System.debug('');
    System.debug('🎉 READ ACCESS REMOVAL COMPLETE!');
    System.debug('');
    System.debug('📊 SUMMARY:');
    System.debug('- Total custom profiles checked: ' + customProfiles.size());
    System.debug('- Profiles with Purchase_Request__c permissions: ' + existingPerms.size());
    System.debug('- ObjectPermissions updated: ' + permsToUpdate.size());
    System.debug('- ObjectPermissions deleted: ' + permsToDelete.size());
    System.debug('');
    System.debug('🔒 All custom profiles now have NO READ ACCESS to Purchase_Request__c');
    System.debug('💾 Remember: QA backup available for rollback if needed');
    
} catch (Exception e) {
    System.debug('❌ ERROR updating permissions: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
