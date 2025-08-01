// Get Permission Set names for the provided IDs
List<String> permissionSetIds = new List<String>{
    '0PSOn000000382fOAA',
    '0PS0o000003DZmJGAW', 
    '0PS0o000001vz5CGAQ'
};

List<PermissionSet> permissionSets = [
    SELECT Id, Name, Label, Description
    FROM PermissionSet 
    WHERE Id IN :permissionSetIds
    ORDER BY Name
];

System.debug('Found ' + permissionSets.size() + ' Permission Sets:');
System.debug('ID,Name,Label,Description');

for (PermissionSet ps : permissionSets) {
    String description = ps.Description != null ? ps.Description : '';
    System.debug(ps.Id + ',' + ps.Name + ',' + ps.Label + ',' + description);
}
