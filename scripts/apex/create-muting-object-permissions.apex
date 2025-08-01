// Create ObjectPermissions to deny Read access on Purchase_Request__c
// for each muting Permission Set

List<ObjectPermissions> objectPermissions = new List<ObjectPermissions>();

// Permission Set IDs from previous creation
Map<String, String> mutingPermissionSets = new Map<String, String>{
    '0PSOn0000006aGvOAI' => 'Purchase_Order_Send_Muting',
    '0PSOn0000006aGwOAI' => 'Purchase_Request_Admin_Muting', 
    '0PSOn0000006aGxOAI' => 'Transport_Driver_Muting'
};

// Create ObjectPermissions for Purchase_Request__c with Read = false
for (String permissionSetId : mutingPermissionSets.keySet()) {
    ObjectPermissions objPerm = new ObjectPermissions();
    objPerm.ParentId = permissionSetId;
    objPerm.SObjectType = 'Purchase_Request__c';
    objPerm.PermissionsRead = false;  // This is the muting - explicitly deny Read
    objPerm.PermissionsCreate = false;
    objPerm.PermissionsEdit = false;
    objPerm.PermissionsDelete = false;
    objPerm.PermissionsViewAllRecords = false;
    objPerm.PermissionsModifyAllRecords = false;
    
    objectPermissions.add(objPerm);
}

try {
    insert objectPermissions;
    System.debug('Successfully created ' + objectPermissions.size() + ' ObjectPermissions for Purchase_Request__c muting:');
    
    // Query to verify the permissions were created
    List<ObjectPermissions> verifyPerms = [
        SELECT Id, Parent.Name, SObjectType, PermissionsRead, PermissionsCreate, PermissionsEdit
        FROM ObjectPermissions 
        WHERE Id IN :objectPermissions
    ];
    
    for (ObjectPermissions op : verifyPerms) {
        System.debug('Created: ' + op.Parent.Name + ' -> ' + op.SObjectType + 
                    ' (Read: ' + op.PermissionsRead + ', Create: ' + op.PermissionsCreate + 
                    ', Edit: ' + op.PermissionsEdit + ')');
    }
    
} catch (Exception e) {
    System.debug('Error creating ObjectPermissions: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
