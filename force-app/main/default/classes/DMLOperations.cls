/**
 * The DMLOperations class serves as a deep dive into Data Manipulation Language (DML) in Apex.
 * It covers fundamental DML operations such as insert, update, upsert, and delete.
 *
 * This class introduces developers to the concept of manipulating Salesforce records in Apex.
 * It discusses how to use DML operations to create, update, and delete records.
 * This class uses standard Salesforce objects like Account, Contact, and Opportunity for demonstration.
 *
 * Topics covered in this class include:
 * - Understanding how to use insert DML operation to create records in Salesforce.
 * - Understanding how to use update and upsert DML operations to update existing records in Salesforce.
 * - Understanding how to use delete DML operation to remove records from Salesforce.
 *
 * Users of this class can expect to gain a strong understanding of DML operations in Apex and
 * be prepared for more advanced topics in Salesforce development.
 *
 * The methods within this class serve as practical examples of different DML operations,
 * allowing developers to learn through practice and examples.
 *
 * @author Shaman McLean
 */


public with sharing class DMLOperations {

    /**
     * Question 1
     * Create a new Account object and inserts it into the database.
     * The Account will have a random name for uniqueness.
     * @return The Id of the newly created Account.
     */
    public static Id insertNewAccount() {
        // Create a new Account instance
        Account acc = new Account(Name = 'Example', Website = 'website.com');

        // Set some fields on the Account

        // Insert the Account into the database
        insert acc;
        // Return the Id of the newly created Account
        return acc.id;
    }

    /**
     * Question 2
     * Create a new Account with the specified name and industry provided.
     * @param name The name of the account to be created.
     * @param industry The industry of the account to be created.
     */
    public static void createAccount(String name, String industry) {
        // Create a new Account and set the fields inline
        Account acc = new Account(Name = name, Industry = industry);
        // Insert the Account
        insert acc;
    }

    
    /**
     * Question 3
     * Create a new Contact and link it to the Account id provided then inserts it into the database.
     * @param accountId The Id of the Account to link the Contact to.
     * @return The Id of the newly created Contact.
     */
    public static Id insertNewContact(Id accountId) {
        // Create a new Contact instance
        Contact cont = new Contact(FirstName = 'John', LastName = 'Smith', accountId = accountId);

        // Set some fields on the Contact
        // Set the AccountId field to the given accountId

        // Insert the Contact into the database
        insert cont;
        // Return the Id of the newly created Contact
        return cont.id;
    }

    /**
     * Question 4
     * Update the last name of a Contact in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param contactId The Id of the Contact to update.
     * @param newLastName The new last name for the Contact.
     */
    public static void updateContactLastName(Id contactId, String newLastName) {
        // Retrieve the Contact from the database
        Contact cont = [SELECT Id FROM Contact WHERE Id = :contactId];

        // Update the Contact's last name
        cont.LastName = newLastName;

        // Update the Contact in the database
        update cont;
    }

    /**
     * Question 5
     * Update the stage of an Opportunity in the database.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param oppId The Id of the Opportunity to update.
     * @param newStage The new stage for the Opportunity.
     */
    public static void updateOpportunityStage(Id oppId, String newStage) {
        // Retrieve the Opportunity from the database
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Id = :oppId];

        // Update the Opportunity's stage
        opp.stagename = 'Closed Won';

        // Update the Opportunity in the database
        update opp;
    }

    /**
     * Question 6
     * Update the Account's Name and Industry given an Account Id.
     * Resource: https://developer.salesforce.com/docs/atlas.en-us.soql_sosl.meta/soql_sosl/sforce_api_calls_soql.htm
     * @param accountId The Id of the account to be updated.
     * @param newName The new name for the account.
     * @param newIndustry The new industry for the account.
     */
    public static void updateAccountFields(Id accountId, String newName, String newIndustry) {
        // Query the account
        Account acc = [SELECT Id FROM Account WHERE Id = :accountId];

        // Update the Account with the given Id with the new name and industry
        acc.Name = newName;
        acc.Industry = newIndustry;
        update acc;
    }


    /**
     * Question 7
     * Create or updates an Opportunities
     * The Opportunity's Stage is set to Qualification.
     * The Opportunity's Close Date is set to 3 months from today.
     * The Opportunity's Amount is set to 50000.
     * @param list of Opportunities to be changed then upserted.
     */
    public static void upsertOpportunityList(List<Opportunity> opportunities) {
        // Loop through each Opportunity in the list
        for ( Opportunity opp : opportunities) {
            opp.StageName = 'Qualification';
            opp.CloseDate = Date.today().addMonths(3);
            opp.Amount = 50000;
        
            // Set the Opportunity's Stage to Qualification
            // Set the Opportunity's Close Date to 3 months from today
            // Set the Opportunity's Amount to 50000
        }
        // Upsert the opportunities List so that records are either updated or created
        upsert opportunities;
    }

    /**
     * Question 8
     * Insert or updates opportunities from list of names.
     * Associate the Opportunities with account that has the name accountName.
     * There should be an Opportunity for each name provided in the list.
     * @param accountName The name of the Account.
     * @param oppNames The list of Opportunity names.
     */
    public static void upsertOpportunities(String accountName, List<String> oppNames) {
        // Loop through each Opportunity name

        //I was entirely unable to pass this question myself. 

        List<Opportunity> oppList = new List<Opportunity>();

        if (oppNames != null && !oppNames.isEmpty()) {
            List<Account> accList = [SELECT Id FROM Account WHERE Name = :accountName LIMIT 1];
            
            Account acc;
            if (accList.isEmpty()) {
                // new account
                acc = new Account(Name = accountName);
                insert acc;
            } else {
                acc = accList[0];
            }
            
            //existing opp
            List<Opportunity> existingOpps = [SELECT Name FROM Opportunity WHERE AccountId = :acc.Id AND Name IN :oppNames];
            Set<String> existingOppNames = new Set<String>();
            for (Opportunity existingOpp : existingOpps) {
                existingOppNames.add(existingOpp.Name);
            }
            
            for (String name : oppNames) {
                // Only create a new Opportunity if it doesn't already exist
                if (!existingOppNames.contains(name)) {
                    Opportunity opp = new Opportunity();
                    opp.Name = name;
                    opp.AccountId = acc.Id;
                    opp.StageName = 'Qualification';
                    opp.CloseDate = Date.today();
                    // Add the Opportunity to the list
                    oppList.add(opp);
                }
            }
            
            if (!oppList.isEmpty()) {
                upsert oppList;
            }
        }
        
        
        
     }
         
        
    
    
    /**
     * Question 9
	 * Upserts an Account with the specified name.
	 * If an Account with the given name already exists, update the description to "Updated Account".
	 * If no such Account exists, it creates a new one and sets the description to "New Account".
	 * @param accountName The name of the Account to be upserted.
	 * @return The Account that was upserted.
	 */
	public static Account upsertAccount(String accountName) {
		// Query for the Account
		List<Account> accounts = [SELECT Id FROM Account WHERE Name = :accountName];

		// if the Account exists, update the description
        // otherwise, create a new Account and set the description
        
        if (!accounts.isEmpty()) {
            //existing account
            for ( Account acc : accounts ){
                acc.Description = 'Updated Account';
            } 
        }    

        if ( accounts.isEmpty() ){
                //no existing account
                Account acc = new Account (Name = accountName, Description = 'New Account');
                accounts.add(acc);
            } 

		// Upsert the Account
        upsert accounts;   
        return accounts[0];
	}

    /**
     * Question 10
	 * Manage the association between Contacts and Accounts
	 * Ensure that for each Contact in the provided list, there is a corresponding Account Name that matches the Contact's last name.
	 * If such an Account does not exist, the method creates it; if it does, the method ensures the Contact is associated with it. (Hint: use previous upsertAccount method - this may cause bad practices but for learning purposes it's okay.)
     * Example Contact.LastName = 'Doe' Link to Account.Name = 'Doe' 
     * Example Contact.LastName = 'Jane' Link to Account.Name = 'Jane'
	 * @param contactsToUpsert List of Contacts to be upserted and linked to accounts.
	 */
	public static void upsertAccountsWithContacts(List<Contact> contactsToUpsert) {
		// Loop through each Contact

        //i was unable to do this question myself

            if (contactsToUpsert.isEmpty()) {
                System.debug('Error: List is empty');
                return; // Exit the method if the list is empty
            }
        
            // Extract the last names from the contacts
            Set<String> contLastNameSet = new Set<String>();
            for (Contact cont : contactsToUpsert) {
                contLastNameSet.add(cont.LastName);
            }
        
            // Query existing Accounts with names that match the contact last names
            List<Account> existingAccounts = [SELECT Id, Name FROM Account WHERE Name IN :contLastNameSet];
        
            // Map to hold the existing account names for quick lookup
            Map<String, Account> accountMap = new Map<String, Account>();
            for (Account acc : existingAccounts) {
                accountMap.put(acc.Name, acc);
            }
        
            // List to hold new accounts to be created
            List<Account> accountsToInsert = new List<Account>();
        
            // Loop through the contact list to ensure each has a corresponding account
            for (Contact cont : contactsToUpsert) {
                if (!accountMap.containsKey(cont.LastName)) {
                    // Account does not exist, create a new one
                    Account newAcc = new Account(Name = cont.LastName);
                    accountsToInsert.add(newAcc);
                    accountMap.put(cont.LastName, newAcc); // Add to map to link later
                }
            }
        
            // Insert the new accounts
            if (!accountsToInsert.isEmpty()) {
                insert accountsToInsert;
        
                // Update the account map with the newly inserted accounts
                for (Account acc : accountsToInsert) {
                    accountMap.put(acc.Name, acc);
                }
            }
        
            // Link the contacts to the newly created or existing accounts
            for (Contact cont : contactsToUpsert) {
                if (accountMap.containsKey(cont.LastName)) {
                    cont.AccountId = accountMap.get(cont.LastName).Id;
                }
            }
        
            // Upsert the contacts with the associated account IDs
            upsert contactsToUpsert;
        }
        
	
	

    /**
     * Question 11
     * Insert a list of Leads and then deletes them.
     * @param leadNames The list of Lead names to be inserted.
     */
    public static void insertAndDeleteLeads(List<String> leadNames) {
        // Loop through each Lead name
        List<Lead> leadsToInsert = new List<Lead>();
       
        
        for (String name : leadNames ) {
            if (name != '') {
                Lead newLead = new Lead();
                newLead.lastname = name;
                newLead.company = 'Example';
                leadsToInsert.add(newLead);
            }
       }
       insert leadsToInsert;
       delete leadsToInsert;

        // Insert the Leads

        // Delete the Leads
    }


    /**
     * Question 12
     * Dynamically create the number of cases and relate it to the accountId, then deletes them.
     * @param accountId The account for which the cases will be created and then deleted.
     * @param numOfCases The number of cases to create.
     */
    public static void createAndDeleteCases(String accountId, Integer numOfCases) {
        // Insert the cases
        List<Case> caseInsert = new List<Case>();
        for (Integer i = 0; i <= numOfCases; i++){
            Case c = new Case();
            c.accountId = accountId;
            c.Origin = 'Phone';
            c.Status = 'New';
            caseInsert.add(c);
        }
        insert caseInsert;
        delete caseInsert;

        // Delete the cases
    }
}