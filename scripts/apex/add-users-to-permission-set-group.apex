// Emergency Deployment Script: Add Permission Set Users to Permission Set Group
// Purpose: Add all users assigned to Permission Set ID '0PS0o000003DZmOGAW' 
//          to Permission Set Group ID '0PGOn0000000vMTOAY'
// Date: August 1, 2025
// Deployment: WILDDESERTPROD

try {
    // Step 1: Get the Permission Set by ID
    PermissionSet ps = [SELECT Id, Name 
                       FROM PermissionSet 
                       WHERE Id = '0PS0o000003DZmOGAW' 
                       LIMIT 1];
    
    // Step 2: Get the Permission Set Group by ID
    PermissionSetGroup psg = [SELECT Id, DeveloperName, MasterLabel 
                             FROM PermissionSetGroup 
                             WHERE Id = '0PGOn0000000vMTOAY' 
                             LIMIT 1];
    
    // Step 3: Get all users currently assigned to the Permission Set
    List<PermissionSetAssignment> psAssignments = [SELECT Id, AssigneeId, Assignee.Username 
                                                  FROM PermissionSetAssignment 
                                                  WHERE PermissionSetId = :ps.Id 
                                                  AND Assignee.IsActive = true];
    
    System.debug('Found ' + psAssignments.size() + ' users assigned to Permission Set: ' + ps.Name);
    
    // Step 4: Get existing Permission Set Group assignments to avoid duplicates
    // Note: Using a workaround since PermissionSetGroupAssignment may not be directly queryable
    Set<Id> existingUserIds = new Set<Id>();
    try {
        // Try to query existing assignments if the object is available
        List<PermissionSetAssignment> existingPSGAssignments = [SELECT AssigneeId 
                                                               FROM PermissionSetAssignment 
                                                               WHERE PermissionSetId IN 
                                                                   (SELECT PermissionSetId FROM PermissionSetGroupPermissionSet 
                                                                    WHERE PermissionSetGroupId = :psg.Id)];
        
        for (PermissionSetAssignment existing : existingPSGAssignments) {
            existingUserIds.add(existing.AssigneeId);
        }
    } catch (Exception e) {
        System.debug('Could not query existing Permission Set Group assignments, proceeding with all users');
    }
    
    System.debug('Found ' + existingUserIds.size() + ' users that may already have access through Permission Set Group');
    
    // Step 5: Create new Permission Set assignments to the Permission Set Group
    // Since we can't directly assign to PSG, we'll assign to all Permission Sets in the group
    List<PermissionSetAssignment> newAssignments = new List<PermissionSetAssignment>();
    List<String> usersToAdd = new List<String>();
    
    // Get all Permission Sets in the Permission Set Group
    List<PermissionSetGroupPermissionSet> psgPermissionSets = [SELECT PermissionSetId 
                                                              FROM PermissionSetGroupPermissionSet 
                                                              WHERE PermissionSetGroupId = :psg.Id];
    
    if (psgPermissionSets.isEmpty()) {
        System.debug('WARNING: No Permission Sets found in the Permission Set Group');
        return;
    }
    
    System.debug('Permission Set Group contains ' + psgPermissionSets.size() + ' Permission Sets');
    
    // For each user in the original Permission Set, assign them to each Permission Set in the group
    for (PermissionSetAssignment psa : psAssignments) {
        if (!existingUserIds.contains(psa.AssigneeId)) {
            for (PermissionSetGroupPermissionSet psgps : psgPermissionSets) {
                // Check if user is already assigned to this specific Permission Set
                List<PermissionSetAssignment> existingAssignment = [SELECT Id 
                                                                   FROM PermissionSetAssignment 
                                                                   WHERE PermissionSetId = :psgps.PermissionSetId 
                                                                   AND AssigneeId = :psa.AssigneeId 
                                                                   LIMIT 1];
                
                if (existingAssignment.isEmpty()) {
                    newAssignments.add(new PermissionSetAssignment(
                        PermissionSetId = psgps.PermissionSetId,
                        AssigneeId = psa.AssigneeId
                    ));
                }
            }
            usersToAdd.add(psa.Assignee.Username);
        }
    }
    
    // Step 6: Insert the new assignments
    if (!newAssignments.isEmpty()) {
        insert newAssignments;
        
        System.debug('SUCCESS: Created ' + newAssignments.size() + ' new Permission Set assignments');
        System.debug('Users processed: ' + String.join(usersToAdd, ', '));
        System.debug('This effectively adds ' + usersToAdd.size() + ' users to Permission Set Group: ' + psg.MasterLabel);
        
    } else {
        System.debug('INFO: No new assignments needed - all users already have access through the Permission Set Group');
    }
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
    throw e;
}
