public inherited sharing class UserRoleService {

    public static Map<Id, UserRole> userRoles {
        get {
            if (userRoles == null) {
                userRoles = new Map<Id, UserRole>([
                    SELECT 
                        Id, DeveloperName, ParentRoleId 
                    FROM 
                        UserRole 
                    ORDER BY 
                        ParentRoleId NULLS FIRST
                ]);
            }
            return userRoles;
        }
        set;
    }

    public static Map<String, UserRole> userRolesByDeveloperName {
        get {
            if (userRolesByDeveloperName == null) {
                userRolesByDeveloperName = new Map<String, UserRole>();
                for (UserRole userRole : userRoles.values()) {
                    userRolesByDeveloperName.put(userRole.DeveloperName, userRole);
                }
            }
            return userRolesByDeveloperName;
        }
        set;
    }

    public static Map<Id, List<User>> usersByUserRoleId {
        get {
            if (usersByUserRoleId == null) {
                usersByUserRoleId = new Map<Id, List<User>>();
                for (User user : UserRepository.getInternalActiveUsers()) {
                    if (!usersByUserRoleId.containsKey(user.UserRoleId)) {
                        usersByUserRoleId.put(user.UserRoleId, new List<User>());
                    }
                    usersByUserRoleId.get(user.UserRoleId).add(user);
                }
            }
            return usersByUserRoleId;
        }
        set;
    }

    private static Map<Id, UserRoleDepth> roleDepths {
        get {
            if (roleDepths == null) {
                roleDepths = new Map<Id, UserRoleDepth>();
                List<UserRole> roles = userRoles.values();
                Integer index = 0;
                UserRole role;
                while (!roles.isEmpty()) {
                    role = roles[index];
                    if (role.ParentRoleId == null) {
                        roleDepths.put(role.Id, new UserRoleDepth(role, 0));
                        roles.remove(index);
                    } else if (roleDepths.containsKey(role.ParentRoleId)) {
                        roleDepths.put(role.Id, new UserRoleDepth(role, roleDepths.get(role.ParentRoleId).depth + 1));
                        roles.remove(index);
                    } else {
                        index++;
                    }
                    if (index >= roles.size()) {
                        index = 0;
                    }
                }
            }
            return roleDepths;
        }
        set;
    }

    public static User getSampleUserByUserRoleId(Id userRoleId) {
        if (usersByUserRoleId.containsKey(userRoleId) && !usersByUserRoleId.get(userRoleId).isEmpty()) {
            return usersByUserRoleId.get(userRoleId)[0];
        }
        return null;
    }

    public static UserRoleDepth getUserRoleDepth(Id userRoleId) {
        return roleDepths.get(userRoleId);
    }

    public class UserRoleDepth {

        public Integer depth;
        public UserRole role;

        public UserRoleDepth(UserRole role, Integer depth) {
            this.role = role;
            this.depth = depth;
        }
    }
}