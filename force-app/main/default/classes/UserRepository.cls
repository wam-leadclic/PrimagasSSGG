public inherited sharing class UserRepository {

    public static final String USER_TYPE_INTERNAL = 'Standard';

    public static List<User> getInternalActiveUsers() {
        return [
            SELECT
                Id, Name, UserRoleId
            FROM
                User
            WHERE
                IsActive = true
            AND
                UserType = :USER_TYPE_INTERNAL
            ORDER BY
                CreatedDate ASC
        ];
    }

    public static List<User> getUsersWithDelegatedApprovers() {
        return [
            SELECT 
                Id, DelegatedApproverId
            FROM
                User
            WHERE 
                DelegatedApproverId != null
            AND
                IsActive = true
        ];
    }

    public static List<User> getUsersByIds(List<Id> userIds) {
        return [
            SELECT 
                Id, UserRoleId 
            FROM 
                User 
            WHERE 
                Id IN :userIds
        ];
    }
}