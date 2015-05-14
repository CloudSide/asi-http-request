//
//  ASIS3ObjectRequest.m
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 16/03/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "ASIS3ObjectRequest.h"

NSString *const ASIS3StorageClassStandard = @"STANDARD";
NSString *const ASIS3StorageClassReducedRedundancy = @"REDUCED_REDUNDANCY";

@implementation ASIS3ObjectRequest

- (ASIHTTPRequest *)HEADRequest
{
	ASIS3ObjectRequest *headRequest = (ASIS3ObjectRequest *)[super HEADRequest];
	[headRequest setKey:[self key]];
	[headRequest setBucket:[self bucket]];
	return headRequest;
}

+ (id)requestWithBucket:(NSString *)theBucket key:(NSString *)theKey
{
	ASIS3ObjectRequest *newRequest = [[[self alloc] initWithURL:nil] autorelease];
	[newRequest setBucket:theBucket];
	[newRequest setKey:theKey];
	return newRequest;
}

+ (id)requestWithBucket:(NSString *)theBucket key:(NSString *)theKey subResource:(NSString *)theSubResource
{
	ASIS3ObjectRequest *newRequest = [[[self alloc] initWithURL:nil] autorelease];
	[newRequest setSubResource:theSubResource];
	[newRequest setBucket:theBucket];
	[newRequest setKey:theKey];
	return newRequest;
}

+ (id)PUTRequestForData:(NSData *)data withBucket:(NSString *)theBucket key:(NSString *)theKey
{
	ASIS3ObjectRequest *newRequest = [self requestWithBucket:theBucket key:theKey];
	[newRequest appendPostData:data];
	[newRequest setRequestMethod:@"PUT"];
	return newRequest;
}

+ (id)PUTRequestForFile:(NSString *)filePath withBucket:(NSString *)theBucket key:(NSString *)theKey
{
	ASIS3ObjectRequest *newRequest = [self requestWithBucket:theBucket key:theKey];
	[newRequest setPostBodyFilePath:filePath];
	[newRequest setShouldStreamPostDataFromDisk:YES];
	[newRequest setRequestMethod:@"PUT"];
	[newRequest setMimeType:[ASIHTTPRequest mimeTypeForFileAtPath:filePath]];
	return newRequest;
}

+ (id)DELETERequestWithBucket:(NSString *)theBucket key:(NSString *)theKey
{
	ASIS3ObjectRequest *newRequest = [self requestWithBucket:theBucket key:theKey];
	[newRequest setRequestMethod:@"DELETE"];
	return newRequest;
}

+ (id)COPYRequestFromBucket:(NSString *)theSourceBucket key:(NSString *)theSourceKey toBucket:(NSString *)theBucket key:(NSString *)theKey
{
	ASIS3ObjectRequest *newRequest = [self requestWithBucket:theBucket key:theKey];
	[newRequest setRequestMethod:@"PUT"];
	[newRequest setSourceBucket:theSourceBucket];
	[newRequest setSourceKey:theSourceKey];
	return newRequest;
}

+ (id)HEADRequestWithBucket:(NSString *)theBucket key:(NSString *)theKey
{
	ASIS3ObjectRequest *newRequest = [self requestWithBucket:theBucket key:theKey];
	[newRequest setRequestMethod:@"HEAD"];
	return newRequest;
}

+ (id)requestForAclWithBucket:(NSString *)bucket key:(NSString *)key {
    
    ASIS3ObjectRequest *newRequest = [self requestWithBucket:bucket key:key subResource:@"acl"];
    [newRequest setRequestMethod:@"GET"];
    return newRequest;
}

+ (id)PUTRequestWithBucket:(NSString *)bucket key:(NSString *)key acl:(NSDictionary *)acl {
    
    ASIS3ObjectRequest *newRequest = [self requestForAclWithBucket:bucket key:key];
    [newRequest setRequestMethod:@"PUT"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:acl options:kNilOptions error:&error];
    
    [newRequest setPostBody:(NSMutableData *)jsonData];
    return newRequest;
}

+ (id)requestForMetaWithBucket:(NSString *)bucket key:(NSString *)key {
    
    ASIS3ObjectRequest *request = [self requestWithBucket:bucket key:key subResource:@"meta"];
    [request setRequestMethod:@"GET"];
    return request;
}

+ (id)PUTRequestWithBucket:(NSString *)bucket key:(NSString *)key meta:(NSDictionary *)meta {
    
    ASIS3ObjectRequest *request = [self requestWithBucket:bucket key:key subResource:@"meta"];
    [request setRequestMethod:@"PUT"];
    [request setUserMeta:meta];
    return request;
}

- (id)copyWithZone:(NSZone *)zone
{
	ASIS3ObjectRequest *newRequest = [super copyWithZone:zone];
	[newRequest setBucket:[self bucket]];
	[newRequest setKey:[self key]];
	[newRequest setSourceBucket:[self sourceBucket]];
	[newRequest setSourceKey:[self sourceKey]];
	[newRequest setMimeType:[self mimeType]];
	[newRequest setSubResource:[self subResource]];
	[newRequest setStorageClass:[self storageClass]];
	return newRequest;
}

- (void)dealloc
{
	[bucket release];
	[key release];
	[mimeType release];
	[sourceKey release];
	[sourceBucket release];
	[subResource release];
	[storageClass release];
	[super dealloc];
}

- (void)buildURL
{
    NSString *urlString = nil;
    
	if ([self subResource]) {
        urlString = [NSString stringWithFormat:@"%@://%@.%@%@?%@",[self requestScheme],[self bucket],[[self class] S3Host],[ASIS3Request stringByURLEncodingForS3Path:[self key]],[self subResource]];
	} else {
        urlString = [NSString stringWithFormat:@"%@://%@.%@%@",[self requestScheme],[self bucket],[[self class] S3Host],[ASIS3Request stringByURLEncodingForS3Path:[self key]]];
		
	}
    
    if ([[self subResource] isEqualToString:@"acl"] || [[self subResource] isEqualToString:@"meta"]) {
        urlString = [urlString stringByAppendingString:@"&formatter=json"];
    }
    
    [self setURL:[NSURL URLWithString:urlString]];
}

- (NSString *)mimeType
{
	if (mimeType) {
		return mimeType;
	} else if ([self postBodyFilePath]) {
		return [ASIHTTPRequest mimeTypeForFileAtPath:[self postBodyFilePath]];
	} else {
		return @"application/octet-stream";
	}
}

- (NSString *)canonicalizedResource
{
	if ([[self subResource] length] > 0) {
		return [NSString stringWithFormat:@"/%@%@?%@",[self bucket],[ASIS3Request stringByURLEncodingForS3Path:[self key]], [self subResource]];
	}
	return [NSString stringWithFormat:@"/%@%@",[self bucket],[ASIS3Request stringByURLEncodingForS3Path:[self key]]];
}

- (NSMutableDictionary *)S3Headers
{
	NSMutableDictionary *headers = [super S3Headers];
	if ([self sourceKey]) {
		NSString *path = [ASIS3Request stringByURLEncodingForS3Path:[self sourceKey]];
        NSString *copySource = [NSString stringWithFormat:@"/%@%@", [self sourceBucket], path];
		[headers setObject:copySource forKey:@"x-amz-copy-source"];
		//[headers setObject:[[self sourceBucket] stringByAppendingString:path] forKey:@"x-amz-copy-source"];
	}
	if ([self storageClass]) {
		[headers setObject:[self storageClass] forKey:@"x-amz-storage-class"];
	}
	return headers;
}

- (NSString *)stringToSignForHeaders:(NSString *)canonicalizedAmzHeaders resource:(NSString *)canonicalizedResource
{
	if ([[self requestMethod] isEqualToString:@"PUT"] && ![self sourceKey]) {
		[self addRequestHeader:@"Content-Type" value:[self mimeType]];
		return [NSString stringWithFormat:@"PUT\n\n%@\n%@\n%@%@",[self mimeType],dateString,canonicalizedAmzHeaders,canonicalizedResource];
	} 
	return [super stringToSignForHeaders:canonicalizedAmzHeaders resource:canonicalizedResource];
}

@synthesize bucket;
@synthesize key;
@synthesize sourceBucket;
@synthesize sourceKey;
@synthesize mimeType;
@synthesize subResource;
@synthesize storageClass;
@end
