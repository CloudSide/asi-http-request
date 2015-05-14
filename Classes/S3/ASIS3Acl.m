//
//  ASIS3Acl.m
//  Mac
//
//  Created by Littlebox222 on 14-10-20.
//
//

#import "ASIS3Acl.h"

NSString *kASIS3AclPermissionRead = @"read";
NSString *kASIS3AclPermissionWrite = @"write";
NSString *kASIS3AclPermissionReadAcp = @"read_acp";
NSString *kASIS3AclPermissionWriteAcp = @"write_acp";


@implementation ASIS3Grantee

- (void)dealloc {
    [_userId release];
    [_displayName release];
    [super dealloc];
}

- (ASIS3Grantee *)initWithUserId:(NSString *)userId displayName:(NSString *)displayName {
    
    if (self = [super init]) {
        _userId = [userId retain];
        _displayName = [displayName retain];
    }
    
    return self;
}

- (void)setDisplayName:(NSString *)displayName {
    _displayName = [displayName retain];
}

- (void)setUserId:(NSString *)userId {
    _userId = [userId retain];
}

- (NSString *)userId {
    return _userId;
}

- (NSString *)displayName {
    return _displayName;
}

@end


@implementation ASIS3Grant

- (void)dealloc {
    [_grantee release];
    [_permissions removeAllObjects];
    [_permissions release];
    [super dealloc];
}

- (ASIS3Grant *)init {
    
    if (self = [super init]) {
        _permissions = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (ASIS3Grant *)initWithGrantee:(ASIS3Grantee *)grantee permissions:(NSArray *)permissions {
    
    if (self = [super init]) {
        _grantee = [_grantee retain];
        _permissions = [[NSMutableArray alloc] init];
        [_permissions addObjectsFromArray:permissions];
    }
    
    return self;
}

- (void)setGrantee:(ASIS3Grantee *)grantee {
    _grantee = [grantee retain];
}

- (void)setPermissions:(NSArray *)permissions {
    
    if (_permissions) {
        [_permissions removeAllObjects];
        [_permissions release];
    }
    _permissions = [[NSMutableArray alloc] init];
    [_permissions addObjectsFromArray:permissions];
}

- (ASIS3Grantee *)grantee {
    return _grantee;
}

- (NSArray *)permissions {
    return _permissions;
}

@end


@implementation ASIS3Acl

- (void)dealloc {
    
    [_accessList removeAllObjects];
    [_accessList release];
    [_owner release];
    [super dealloc];
}

- (ASIS3Acl *)initWithDict:(NSDictionary *)dict {
    return [self initWithDict:dict owner:nil];
}

- (ASIS3Acl *)initWithDict:(NSDictionary *)dict owner:(NSString *)owner {
    
    if (dict && (self = [super init])) {
        
        _owner = [owner retain];
        _accessList = [[NSMutableArray alloc] init];
        
        for (NSString *key in [dict allKeys]) {
            
            ASIS3Grantee *grantee = [[[ASIS3Grantee alloc] initWithUserId:key displayName:nil] autorelease];
            
            ASIS3Grant *grant = [[[ASIS3Grant alloc] initWithGrantee:grantee permissions:[dict objectForKey:key]] autorelease];
            
            [_accessList addObject:grant];
        }
    }
    
    return self;
}

- (NSArray *)accessList {
    
    return _accessList;
}

- (NSString *)owner {
    
    return _owner;
}

@end
