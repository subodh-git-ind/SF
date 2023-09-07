public with sharing class AccountTriggerService {
    @TestVisible
    private static final String ACCOUNT_ADMIN_PS = 'Account_Admin';
    @TestVisible
    private static final String HR_Type = 'HR';
    @TestVisible
    private static final String Admin_Type = 'Admin';
    
    public static void isAccountActivated(List<Account> accounts){
        for(Account account: accounts){
            if(account.Active__c){
                account.Active__c.addError(Label.ActiveAccountErrorLbl);
            }
        }
    }
    
    public static void createTeamMember(List<Account> accounts){
        List<SQX_Team_Members__c> teamMembers = new List<SQX_Team_Members__c>();
        for(Account account: accounts){
            teamMembers.addAll(getTwoTeamMember(account.Id));
        }
        
        if(!teamMembers.isEmpty()){
            insert teamMembers;
        }
        
	}
    
    public static void checkActivatedAccount(List<Account> accounts){
        Boolean haveHrAdminMembers = checkForHrAndAdminTeamMembers(accounts);
        Boolean isCurrentUserAccountAdmin = isAccountAdmin();
        for(Account account: accounts){
            if(account.Active__c && !haveHrAdminMembers && !isCurrentUserAccountAdmin){
                System.debug('inside this');
                account.addError(Label.AccountAdminErrorLbl);
            }
        }    
    }
    
    private static List<SQX_Team_Members__c> getTwoTeamMember(Id accountId){
        return new List<SQX_Team_Members__c>{
            new SQX_Team_Members__c(Name = 'Team Member1', Account__c = accountId),
            new SQX_Team_Members__c(Name = 'Team Member2', Account__c = accountId)
         };
    }
    
    private static Boolean isAccountAdmin(){
        return [SELECT Id
                FROM PermissionSetAssignment
                WHERE AssigneeId = :UserInfo.getUserId() AND
                PermissionSet.Name = :ACCOUNT_ADMIN_PS]?.size() > 0;
    }
	
    private static Boolean checkForHrAndAdminTeamMembers(List<Account> accounts){
        return [SELECT Id 
                FROM SQX_Team_Members__c
                WHERE Account__c IN :accounts AND Member_Type__c IN (:HR_Type, :ADMIN_TYPE)]?.size() > 0;
    }
    
}