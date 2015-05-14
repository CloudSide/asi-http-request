//
//  ASIS3Acl.h
//  Mac
//
//  Created by Littlebox222 on 14-10-20.
//
//

#import <Foundation/Foundation.h>

extern NSString *kASIS3AclPermissionRead;
extern NSString *kASIS3AclPermissionWrite;
extern NSString *kASIS3AclPermissionReadAcp;
extern NSString *kASIS3AclPermissionWriteAcp;


@interface ASIS3Grantee : NSObject {
    NSString *_displayName;
    NSString *_userId;
}
- (ASIS3Grantee *)initWithUserId:(NSString *)userId displayName:(NSString *)displayName;
- (void)setDisplayName:(NSString *)displayName;
- (void)setUserId:(NSString *)userId;
- (NSString *)userId;
- (NSString *)displayName;
@end


@interface ASIS3Grant : NSObject {
    ASIS3Grantee* _grantee;
    NSMutableArray *_permissions;
}
- (ASIS3Grant *)init;
- (ASIS3Grant *)initWithGrantee:(ASIS3Grantee *)grantee permissions:(NSArray *)permissions;
- (void)setGrantee:(ASIS3Grantee *)grantee;
- (void)setPermissions:(NSArray *)permissions;
- (ASIS3Grantee *)grantee;
- (NSArray *)permissions;
@end


@interface ASIS3Acl : NSObject {
    NSString* _owner;
    NSMutableArray* _accessList;
}

- (ASIS3Acl *)initWithDict:(NSDictionary *)dict;
- (ASIS3Acl *)initWithDict:(NSDictionary *)dict owner:(NSString *)owner;
- (NSArray *)accessList;
- (NSString *)owner;

@end