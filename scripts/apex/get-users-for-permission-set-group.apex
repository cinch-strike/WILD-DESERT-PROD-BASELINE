// Emergency Deployment Script: Get Users from Permission Set for Manual PSG Assignment
// Purpose: Get all users assigned to Permission Set ID '0PS0o000003DZmOGAW' 
//          so they can be manually added to Permission Set Group '0PGOn0000000vMTOAY'
// Date: August 1, 2025
// Deployment: WILDDESERTPROD

try {
    // Get the Permission Set by ID
    PermissionSet ps = [SELECT Id, Name 
                       FROM PermissionSet 
                       WHERE Id = '0PS0o000003DZmOGAW' 
                       LIMIT 1];
    
    // Get all users currently assigned to the Permission Set
    List<PermissionSetAssignment> psAssignments = [SELECT Id, AssigneeId, Assignee.Username, Assignee.Name, Assignee.Email 
                                                  FROM PermissionSetAssignment 
                                                  WHERE PermissionSetId = '0PS0o000003DZmOGAW' 
                                                  AND Assignee.IsActive = true
                                                  ORDER BY Assignee.Username];
    
    System.debug('=== PERMISSION SET INFORMATION ===');
    System.debug('Permission Set: ' + ps.Name);
    System.debug('Permission Set ID: ' + ps.Id);
    System.debug('Target Permission Set Group ID: 0PGOn0000000vMTOAY');
    System.debug('');
    
    System.debug('=== USERS TO ADD TO PERMISSION SET GROUP ===');
    System.debug('Total users found: ' + psAssignments.size());
    System.debug('');
    
    List<String> userIds = new List<String>();
    List<String> usernames = new List<String>();
    
    for (PermissionSetAssignment psa : psAssignments) {
        System.debug('User: ' + psa.Assignee.Username + ' | Name: ' + psa.Assignee.Name + ' | Email: ' + psa.Assignee.Email + ' | ID: ' + psa.AssigneeId);
        userIds.add(psa.AssigneeId);
        usernames.add(psa.Assignee.Username);
    }
    
    System.debug('');
    System.debug('=== USER IDS (for bulk operations) ===');
    System.debug(String.join(userIds, ','));
    
    System.debug('');
    System.debug('=== SUMMARY ===');
    System.debug('✅ Found ' + psAssignments.size() + ' active users in Permission Set');
    System.debug('📋 Next step: Manually add these users to Permission Set Group ID: 0PGOn0000000vMTOAY');
    System.debug('🔧 Or use the User IDs above for bulk assignment via Data Loader or Workbench');
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('Stack Trace: ' + e.getStackTraceString());
    throw e;
}
