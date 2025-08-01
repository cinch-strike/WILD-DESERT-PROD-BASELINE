// Query to get Permission Set Assignment IDs for users assigned to specific Permission Set
// This will get the actual PermissionSetAssignment record IDs that can be deleted

String permissionSetId = '0PS0o000003DZmOGAW';

// Get all PermissionSetAssignment records for the specific Permission Set
List<PermissionSetAssignment> assignments = [
    SELECT Id, AssigneeId, Assignee.Name, Assignee.Email, Assignee.IsActive 
    FROM PermissionSetAssignment 
    WHERE PermissionSetId = :permissionSetId 
    AND Assignee.IsActive = true
    ORDER BY Assignee.Name
];

System.debug('Found ' + assignments.size() + ' Permission Set Assignments to delete:');
System.debug('Assignment ID,User ID,User Name,User Email');

for (PermissionSetAssignment psa : assignments) {
    System.debug(psa.Id + ',' + psa.AssigneeId + ',' + psa.Assignee.Name + ',' + psa.Assignee.Email);
}
