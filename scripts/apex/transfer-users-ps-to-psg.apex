// Transfer users from Permission Set 0PSOn000000382f to Permission Set Group 0PGOn0000000vO5OAI

String sourcePermissionSetId = '0PS0o000001vz5C';
String targetPermissionSetGroupId = '0PGOn0000000vO7';

// Step 1: Get details about the Permission Set and Permission Set Group
PermissionSet sourcePS = [SELECT Id, Name, Label FROM PermissionSet WHERE Id = :sourcePermissionSetId];
PermissionSetGroup targetPSG = [SELECT Id, DeveloperName, MasterLabel FROM PermissionSetGroup WHERE Id = :targetPermissionSetGroupId];

System.debug('🔄 USER TRANSFER OPERATION');
System.debug('FROM: Permission Set "' + sourcePS.Name + '" (' + sourcePS.Label + ')');
System.debug('TO: Permission Set Group "' + targetPSG.DeveloperName + '" (' + targetPSG.MasterLabel + ')');
System.debug('');

// Step 2: Get all current user assignments for the source Permission Set
List<PermissionSetAssignment> currentAssignments = [
    SELECT Id, AssigneeId, Assignee.Name, Assignee.Username, Assignee.Email, Assignee.IsActive
    FROM PermissionSetAssignment 
    WHERE PermissionSetId = :sourcePermissionSetId
    AND Assignee.IsActive = true
    ORDER BY Assignee.Name
];

System.debug('📊 CURRENT USER ASSIGNMENTS: ' + currentAssignments.size() + ' users found');
System.debug('');

if (currentAssignments.isEmpty()) {
    System.debug('❌ No active users found assigned to this Permission Set');
    return;
}

// List all users
System.debug('👥 USERS TO TRANSFER:');
for (Integer i = 0; i < currentAssignments.size(); i++) {
    PermissionSetAssignment psa = currentAssignments[i];
    System.debug((i + 1) + '. ' + psa.Assignee.Name + ' (' + psa.Assignee.Username + ')');
}
System.debug('');

// Step 3: Check if any users are already assigned to the target Permission Set Group
Set<Id> currentUserIds = new Set<Id>();
for (PermissionSetAssignment psa : currentAssignments) {
    currentUserIds.add(psa.AssigneeId);
}

List<PermissionSetAssignment> existingGroupAssignments = [
    SELECT Id, AssigneeId, Assignee.Name
    FROM PermissionSetAssignment 
    WHERE PermissionSetGroupId = :targetPermissionSetGroupId
    AND AssigneeId IN :currentUserIds
];

if (!existingGroupAssignments.isEmpty()) {
    System.debug('⚠️  WARNING: ' + existingGroupAssignments.size() + ' users already assigned to target Permission Set Group:');
    for (PermissionSetAssignment psa : existingGroupAssignments) {
        System.debug('- ' + psa.Assignee.Name);
    }
    System.debug('');
}

// Step 4: Create new Permission Set Group assignments
List<PermissionSetAssignment> newGroupAssignments = new List<PermissionSetAssignment>();
Set<Id> userIdsToTransfer = new Set<Id>();

for (PermissionSetAssignment currentPSA : currentAssignments) {
    // Check if user is not already assigned to the group
    Boolean alreadyAssigned = false;
    for (PermissionSetAssignment existingPSA : existingGroupAssignments) {
        if (existingPSA.AssigneeId == currentPSA.AssigneeId) {
            alreadyAssigned = true;
            break;
        }
    }
    
    if (!alreadyAssigned) {
        PermissionSetAssignment newPSA = new PermissionSetAssignment();
        newPSA.AssigneeId = currentPSA.AssigneeId;
        newPSA.PermissionSetGroupId = targetPermissionSetGroupId;
        newGroupAssignments.add(newPSA);
        userIdsToTransfer.add(currentPSA.AssigneeId);
    }
}

System.debug('🔄 EXECUTING TRANSFER...');
System.debug('Users to add to Permission Set Group: ' + newGroupAssignments.size());
System.debug('Users to remove from Permission Set: ' + currentAssignments.size());
System.debug('');

try {
    // Step 5: Insert new Permission Set Group assignments
    if (!newGroupAssignments.isEmpty()) {
        insert newGroupAssignments;
        System.debug('✅ Successfully added ' + newGroupAssignments.size() + ' users to Permission Set Group');
    }
    
    // Step 6: Remove old Permission Set assignments
    delete currentAssignments;
    System.debug('✅ Successfully removed ' + currentAssignments.size() + ' users from Permission Set');
    
    System.debug('');
    System.debug('🎉 TRANSFER COMPLETE!');
    System.debug('Summary:');
    System.debug('- ' + currentAssignments.size() + ' users transferred from Permission Set to Permission Set Group');
    System.debug('- Permission Set "' + sourcePS.Name + '" now has 0 user assignments');
    System.debug('- Permission Set Group "' + targetPSG.DeveloperName + '" gained ' + newGroupAssignments.size() + ' new users');
    
} catch (Exception e) {
    System.debug('❌ ERROR during transfer: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
}
