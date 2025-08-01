// Remove Read access to Purchase_Request__c from specific profiles that still have access
// This targets the profiles you identified with current Read access

System.debug('🔒 REMOVING READ ACCESS TO Purchase_Request__c FROM SPECIFIC PROFILES');
System.debug('');

// Target profiles that you identified as still having Read access
List<String> targetProfileNames = new List<String>{
    'WD - Exec Profile (New)',
    'WD - Field Manager - Camp (New)', 
    'WD - Field Manager - Rig (New)',
    'WD - Ops Manager - Rig (New)',
    'WD - Purchase Request – Store Kiosk',
    'WD - Purchasing Officer 2.0',
    'WD - Rural',
    'WD - Rural Admin',
    'WD - Supervisory',
    'WD - Supervisory Elec'
};

// Step 1: Get the specific profiles
List<Profile> targetProfiles = [
    SELECT Id, Name
    FROM Profile 
    WHERE Name IN :targetProfileNames
    ORDER BY Name
];

System.debug('📋 FOUND ' + targetProfiles.size() + ' TARGET PROFILES:');
for (Profile p : targetProfiles) {
    System.debug('- ' + p.Name + ' (ID: ' + p.Id + ')');
}
System.debug('');

if (targetProfiles.isEmpty()) {
    System.debug('❌ No target profiles found');
    return;
}

// Step 2: Get ObjectPermissions for Purchase_Request__c on these profiles
Set<Id> profileIds = new Set<Id>();
for (Profile p : targetProfiles) {
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

System.debug('🔍 CURRENT Purchase_Request__c PERMISSIONS ON TARGET PROFILES:');
if (existingPerms.isEmpty()) {
    System.debug('❌ No ObjectPermissions records found for Purchase_Request__c');
    System.debug('This suggests permissions are defined in Profile metadata, not ObjectPermissions');
    System.debug('');
    
    // Create ObjectPermissions records to explicitly deny Read access
    System.debug('💡 Creating ObjectPermissions records to explicitly remove Read access...');
    
    List<ObjectPermissions> newPerms = new List<ObjectPermissions>();
    for (Profile p : targetProfiles) {
        ObjectPermissions objPerm = new ObjectPermissions();
        objPerm.ParentId = p.Id;
        objPerm.SobjectType = 'Purchase_Request__c';
        objPerm.PermissionsRead = false;
        objPerm.PermissionsCreate = false;
        objPerm.PermissionsEdit = false;
        objPerm.PermissionsDelete = false;
        objPerm.PermissionsViewAllRecords = false;
        objPerm.PermissionsModifyAllRecords = false;
        newPerms.add(objPerm);
    }
    
    try {
        insert newPerms;
        System.debug('✅ Created ' + newPerms.size() + ' ObjectPermissions records with Read = false');
        System.debug('');
        System.debug('🎉 READ ACCESS REMOVAL COMPLETE!');
        System.debug('All target profiles now have explicit Read = false for Purchase_Request__c');
    } catch (Exception e) {
        System.debug('❌ ERROR creating ObjectPermissions: ' + e.getMessage());
        System.debug('This might be because profiles already have explicit permissions defined');
        System.debug('Stack trace: ' + e.getStackTraceString());
    }
    
    return;
}

// Step 3: Show current permissions and update them
System.debug('Found ' + existingPerms.size() + ' existing ObjectPermissions records:');
for (ObjectPermissions perm : existingPerms) {
    System.debug('Profile: ' + perm.Parent.Name);
    System.debug('  Read: ' + perm.PermissionsRead + 
                 ', Create: ' + perm.PermissionsCreate + 
                 ', Edit: ' + perm.PermissionsEdit + 
                 ', Delete: ' + perm.PermissionsDelete);
    System.debug('  View All: ' + perm.PermissionsViewAllRecords + 
                 ', Modify All: ' + perm.PermissionsModifyAllRecords);
    System.debug('');
}

// Step 4: Update permissions to remove Read access
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
            // Set all permissions to false instead of deleting
            perm.PermissionsRead = false;
            perm.PermissionsCreate = false;
            perm.PermissionsEdit = false;
            perm.PermissionsDelete = false;
            perm.PermissionsViewAllRecords = false;
            perm.PermissionsModifyAllRecords = false;
            permsToUpdate.add(perm);
        }
    }
}

System.debug('🔄 EXECUTING PERMISSION UPDATES...');
System.debug('Permissions to update: ' + permsToUpdate.size());
System.debug('');

try {
    if (!permsToUpdate.isEmpty()) {
        update permsToUpdate;
        System.debug('✅ Updated ' + permsToUpdate.size() + ' ObjectPermissions (removed Read access)');
    }
    
    System.debug('');
    System.debug('🎉 READ ACCESS REMOVAL COMPLETE!');
    System.debug('');
    System.debug('📊 SUMMARY:');
    System.debug('- Target profiles processed: ' + targetProfiles.size());
    System.debug('- ObjectPermissions updated: ' + permsToUpdate.size());
    System.debug('');
    System.debug('🔒 All target profiles should now have NO READ ACCESS to Purchase_Request__c');
    
} catch (Exception e) {
    System.debug('❌ ERROR updating permissions: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
