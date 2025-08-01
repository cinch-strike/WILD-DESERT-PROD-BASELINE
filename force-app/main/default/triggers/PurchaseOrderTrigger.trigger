trigger PurchaseOrderTrigger on biz3__Purchase_Order__c (before insert) {
	Set< Id > accountIds = new Set< Id >();
	for ( biz3__Purchase_Order__c po : Trigger.new )
		accountIds.add( po.biz3__Account__c );
		
	Map< Id, Account > accounts = new Map< Id, Account >(
			[ SELECT Id, ( SELECT Id, Billing_Contact__c FROM Contacts ) FROM Account WHERE Id IN :accountIds ] );
	
	for ( biz3__Purchase_Order__c po : Trigger.new ) {
		Contact[] contacts = accounts.get( po.biz3__Account__c ).Contacts;
		if ( contacts.size() == 1 )
			po.biz3__Contact__c = contacts[0].Id;
		else if ( contacts.size() > 1 )
			for ( Contact c : contacts ) {
				if ( c.Billing_Contact__c == true ) {
					po.biz3__Contact__c = c.Id;
					break;
				}
			}
	}
}