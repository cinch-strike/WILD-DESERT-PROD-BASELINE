// Create muting Permission Sets to disable Read access on Purchase_Request__c object
// These will be added to the Permission Set Groups to mute specific permissions

List<PermissionSet> mutingPermissionSets = new List<PermissionSet>();

// 1. Muting Permission Set for Purchase Order Send Group
PermissionSet purchaseOrderMuting = new PermissionSet();
purchaseOrderMuting.Name = 'Purchase_Order_Send_Muting';
purchaseOrderMuting.Label = 'Purchase Order Send - Muting Permissions';
purchaseOrderMuting.Description = 'Muting permission set to disable Read access on Purchase_Request__c for Purchase Order Send users';
mutingPermissionSets.add(purchaseOrderMuting);

// 2. Muting Permission Set for Purchase Request Administrator Group
PermissionSet purchaseRequestAdminMuting = new PermissionSet();
purchaseRequestAdminMuting.Name = 'Purchase_Request_Admin_Muting';
purchaseRequestAdminMuting.Label = 'Purchase Request Admin - Muting Permissions';
purchaseRequestAdminMuting.Description = 'Muting permission set to disable Read access on Purchase_Request__c for Purchase Request Admin users';
mutingPermissionSets.add(purchaseRequestAdminMuting);

// 3. Muting Permission Set for Transport Driver Group
PermissionSet transportDriverMuting = new PermissionSet();
transportDriverMuting.Name = 'Transport_Driver_Muting';
transportDriverMuting.Label = 'Transport Driver - Muting Permissions';
transportDriverMuting.Description = 'Muting permission set to disable Read access on Purchase_Request__c for Transport Driver users';
mutingPermissionSets.add(transportDriverMuting);

try {
    insert mutingPermissionSets;
    System.debug('Successfully created ' + mutingPermissionSets.size() + ' muting Permission Sets:');
    for (PermissionSet ps : mutingPermissionSets) {
        System.debug('Created Muting PS: ' + ps.Id + ' - ' + ps.Name + ' - ' + ps.Label);
    }
} catch (Exception e) {
    System.debug('Error creating muting Permission Sets: ' + e.getMessage());
}
