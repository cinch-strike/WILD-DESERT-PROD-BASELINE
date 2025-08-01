// Create Permission Set Groups for each Permission Set
List<PermissionSetGroup> permissionSetGroups = new List<PermissionSetGroup>();

// 1. Purchase Order Send Group
PermissionSetGroup purchaseOrderGroup = new PermissionSetGroup();
purchaseOrderGroup.DeveloperName = 'Purchase_Order_Send_Group';
purchaseOrderGroup.MasterLabel = 'Purchase Order - Send Group';
purchaseOrderGroup.Description = 'Permission Set Group for Purchase Order Send functionality';
permissionSetGroups.add(purchaseOrderGroup);

// 2. Purchase Request Administrator Group  
PermissionSetGroup purchaseRequestAdminGroup = new PermissionSetGroup();
purchaseRequestAdminGroup.DeveloperName = 'Purchase_Request_Administrator_Group';
purchaseRequestAdminGroup.MasterLabel = 'Purchase Request Administrator Group';
purchaseRequestAdminGroup.Description = 'Permission Set Group for Purchase Request Administrator permissions';
permissionSetGroups.add(purchaseRequestAdminGroup);

// 3. Transport Driver Full Access Group
PermissionSetGroup transportDriverGroup = new PermissionSetGroup();
transportDriverGroup.DeveloperName = 'Transport_Driver_Full_Access_Group';
transportDriverGroup.MasterLabel = 'Transport & Driver Full Access Group';
transportDriverGroup.Description = 'Permission Set Group for Transport and Driver full access permissions';
permissionSetGroups.add(transportDriverGroup);

try {
    insert permissionSetGroups;
    System.debug('Successfully created ' + permissionSetGroups.size() + ' Permission Set Groups:');
    for (PermissionSetGroup psg : permissionSetGroups) {
        System.debug('Created PSG: ' + psg.Id + ' - ' + psg.DeveloperName + ' - ' + psg.MasterLabel);
    }
} catch (Exception e) {
    System.debug('Error creating Permission Set Groups: ' + e.getMessage());
}
