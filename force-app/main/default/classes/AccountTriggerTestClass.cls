@IsTest
private class AccountTriggerTestClass {
	
    @IsTest
    static void userShouldGetErrorIfActivatedAccountCreated(){
        System.runAs(makeStandardUser()){
            String exceptionMsg;
            Boolean isExceptionCaught = false;
            Test.startTest();
            try{
                insert makeAccount(true);
            }
            Catch(Exception e){
                isExceptionCaught = true;
                exceptionMsg = e.getMessage();
            }
            Test.stopTest();
            
            System.assertEquals(true, isExceptionCaught, 'Should throw error since creating activated account');
            System.assertEquals(true, exceptionMsg.contains(Label.ActiveAccountErrorLbl), 'Should throw error since creating activated account');
            System.assertEquals(true, [SELECT Id FROM Account].size() == 0, 'No Account Inserted');
        }
    }
    
    @IsTest
    static void deactivatedAccountShouldGetInsertedWithTwoTeamMembers(){
        System.runAs(makeStandardUser()){
            Test.startTest();
            Account acc = makeAccount(false);
            insert acc;
            Test.stopTest();
            
            System.assertEquals(true, [SELECT Id FROM Account].size() ==1, 'Account get inserted');
            System.assertEquals(true, [SELECT Id FROM SQX_Team_Members__c WHERE Account__c = :acc.Id].size() == 2, 'Two team members get inserted');
        }
    }
    
    @IsTest
    static void updatingAccountAsActivatedShouldThrowErrorIfAccountAdminPermissionNotGiven(){
        String exceptionMsg;
        Boolean isExceptionCaught = false;
        Account acc = makeAccount(false);
        System.runAs(makeStandardUser()){
            Test.startTest();
            try{
                insert acc;
                acc.Active__c = true;
                update acc;
            }
            Catch(Exception e){
                isExceptionCaught = true;
                exceptionMsg = e.getMessage();
            }
            Test.stopTest();
            
            System.assertEquals(true, [SELECT Id FROM Account].size() ==1, 'Account get inserted');
            System.assertEquals(true, [SELECT Id FROM SQX_Team_Members__c WHERE Account__c = :acc.Id].size() == 2, 'Two team members get inserted');
            System.assertEquals(false, [SELECT Id,Active__c FROM Account WHERE Id = :acc.Id]?.Active__c, 'Account is still inactive');
            System.assertEquals(true, isExceptionCaught, 'User should have got the error while updatin account as Active since do not have required member type and account admin permission set');
            System.assertEquals(true, exceptionMsg.contains(Label.AccountAdminErrorLbl), 'Should throw error since creating activated account');
        }
    }
    
    @IsTest
    static void accountShouldGetActivatedAsHaveAdminTeamMemberAndAccountAdminPermissionSet(){
        User stdUser = makeStandardUser();
        assignAccountAdminPermissionSet(stdUser);
        System.runAs(stdUser){
            Account acc = makeAccount(false);
            Test.startTest();
                insert acc;
                insert new SQX_Team_Members__c(Account__c = acc.Id, Name = 'HR Team Member');
                acc.Active__c = true;
                update acc;
            Test.stopTest();
            
            System.assertEquals(true, [SELECT Id FROM Account].size() ==1, 'Account get inserted');
            System.assertEquals(true, [SELECT Id FROM SQX_Team_Members__c WHERE Account__c = :acc.Id].size() == 3, 'Three team members get inserted with one as HR');
            System.assertEquals(true, [SELECT Id,Active__c FROM Account WHERE Id = :acc.Id]?.Active__c, 'Account is still inactive');
        }
    }
    
    static User makeStandardUser(){
        User stdUser = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard Platform User']?.Id,
            LastName = 'last',
            Email = 'test.user@cq.com',
            Username = 'test.user@cq.com',
            CompanyName = 'CQ_Test',
            Title = 'testUser',
            Alias = 'testUser',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        
        insert stdUser;
        return stdUser;
    }
    
    static void assignAccountAdminPermissionSet(User user){
        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = :AccountTriggerService.ACCOUNT_ADMIN_PS];
        insert new PermissionSetAssignment(AssigneeId = user.id, PermissionSetId = ps.Id);
    }
    
    static Account makeAccount(Boolean isActive){
        return new Account(Name = 'Test Account', Active__c = isActive);
    }
}