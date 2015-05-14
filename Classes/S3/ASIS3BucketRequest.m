//
//  ASIS3BucketRequest.m
//  Part of ASIHTTPRequest -> http://allseeing-i.com/ASIHTTPRequest
//
//  Created by Ben Copsey on 16/03/2010.
//  Copyright 2010 All-Seeing Interactive. All rights reserved.
//

#import "ASIS3BucketRequest.h"
#import "ASIS3BucketObject.h"


// Private stuff
@interface ASIS3BucketRequest ()
@property (retain, nonatomic) ASIS3BucketObject *currentObject;
@property (retain) NSMutableArray *objects;
@property (retain) NSMutableArray *commonPrefixes;
@property (assign) BOOL isTruncated;
@end

@implementation ASIS3BucketRequest

- (id)initWithURL:(NSURL *)newURL
{
	self = [super initWithURL:newURL];
	[self setObjects:[[[NSMutableArray alloc] init] autorelease]];
	[self setCommonPrefixes:[[[NSMutableArray alloc] init] autorelease]];
	return self;
}

+ (id)requestWithBucket:(NSString *)theBucket
{
	ASIS3BucketRequest *request = [[[self alloc] initWithURL:nil] autorelease];
	[request setBucket:theBucket];
	return request;
}

+ (id)requestWithBucket:(NSString *)theBucket subResource:(NSString *)theSubResource
{
	ASIS3BucketRequest *request = [[[self alloc] initWithURL:nil] autorelease];
	[request setBucket:theBucket];
	[request setSubResource:theSubResource];
	return request;
}

- (id)requestForNextChunk {
    
    if (![self isTruncated]) {
        return nil;
    }
    
    if (![self nextMarker]) {
        return nil;
    }
    
    ASIS3BucketRequest *listRequest = [[[ASIS3BucketRequest alloc] initWithURL:nil] autorelease];
    
    [listRequest setBucket:[self bucket]];
	[listRequest setSubResource:[self subResource]];
	[listRequest setPrefix:[self prefix]];
	[listRequest setMaxResultCount:[self maxResultCount]];
	[listRequest setDelimiter:[self delimiter]];
    [listRequest setMarker:[self nextMarker]];
    
    return listRequest;
}

+ (id)PUTRequestWithBucket:(NSString *)theBucket
{
	ASIS3BucketRequest *request = [self requestWithBucket:theBucket];
	[request setRequestMethod:@"PUT"];
	return request;
}


+ (id)DELETERequestWithBucket:(NSString *)theBucket
{
	ASIS3BucketRequest *request = [self requestWithBucket:theBucket];
	[request setRequestMethod:@"DELETE"];
	return request;
}

+ (id)requestForAclWithBucket:(NSString *)bucket {
    
    ASIS3BucketRequest *newRequest = [self requestWithBucket:bucket subResource:@"acl"];
    [newRequest setRequestMethod:@"GET"];
    return newRequest;
}

+ (id)PUTRequestWithBucket:(NSString *)bucket acl:(NSDictionary *)acl {
    
    ASIS3BucketRequest *newRequest = [self requestForAclWithBucket:bucket];
    [newRequest setRequestMethod:@"PUT"];
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:acl options:kNilOptions error:&error];
    
    [newRequest setPostBody:(NSMutableData *)jsonData];
    return newRequest;
}

+ (id)requestForMetaWithBucket:(NSString *)bucket {
    
    ASIS3BucketRequest *request = [self requestWithBucket:bucket subResource:@"meta"];
    [request setRequestMethod:@"GET"];
    return request;
}

//+ (id)PUTRequestWithBucket:(NSString *)bucket meta:(NSDictionary *)meta {
//    
//    ASIS3BucketRequest *request = [self requestWithBucket:bucket subResource:@"meta"];
//    [request setRequestMethod:@"PUT"];
//    [request setUserMeta:meta];
//    return request;
//}

- (void)dealloc
{
	[currentObject release];
	[objects release];
	[commonPrefixes release];
	[prefix release];
	[marker release];
	[delimiter release];
	[subResource release];
	[bucket release];
    [nextMarker release];
	[super dealloc];
}

- (NSString *)canonicalizedResource
{
	if ([self subResource]) {
		return [NSString stringWithFormat:@"/%@/?%@",[self bucket],[self subResource]];
	} 
	return [NSString stringWithFormat:@"/%@/",[self bucket]];
}

- (void)buildURL
{
	NSString *baseURL;
    NSString *urlString;
	if ([self subResource]) {
		baseURL = [NSString stringWithFormat:@"%@://%@.%@/?%@",[self requestScheme],[self bucket],[[self class] S3Host],[self subResource]];
	} else {
		baseURL = [NSString stringWithFormat:@"%@://%@.%@",[self requestScheme],[self bucket],[[self class] S3Host]];
	}
	NSMutableArray *queryParts = [[[NSMutableArray alloc] init] autorelease];
	if ([self prefix]) {
		[queryParts addObject:[NSString stringWithFormat:@"prefix=%@",[[self prefix] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
	if ([self marker]) {
		[queryParts addObject:[NSString stringWithFormat:@"marker=%@",[[self marker] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
	if ([self delimiter]) {
		[queryParts addObject:[NSString stringWithFormat:@"delimiter=%@",[[self delimiter] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	}
	if ([self maxResultCount] > 0) {
		[queryParts addObject:[NSString stringWithFormat:@"max-keys=%i",[self maxResultCount]]];
	}
	if ([queryParts count]) {
		NSString* template = @"%@?%@";
		if ([[self subResource] length] > 0) {
			template = @"%@&%@";
		}
        urlString = [NSString stringWithFormat:template,baseURL,[queryParts componentsJoinedByString:@"&"]];
	} else {
        urlString = baseURL;
	}
    
    if ([[self subResource] isEqualToString:@"acl"] || [[self subResource] isEqualToString:@"meta"]) {
        urlString = [urlString stringByAppendingString:@"&formatter=json"];
    }
    
    [self setURL:[NSURL URLWithString:urlString]];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	if ([elementName isEqualToString:@"Contents"]) {
		[self setCurrentObject:[ASIS3BucketObject objectWithBucket:[self bucket]]];
	}
	[super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"Contents"]) {
		[objects addObject:currentObject];
		[self setCurrentObject:nil];
	} else if ([elementName isEqualToString:@"Key"]) {
		[[self currentObject] setKey:[self currentXMLElementContent]];
	} else if ([elementName isEqualToString:@"LastModified"]) {
		//[[self currentObject] setLastModified:[[ASIS3Request S3ResponseDateFormatter] dateFromString:[self currentXMLElementContent]]];
		[[self currentObject] setLastModified:[[ASIS3Request S3RequestDateFormatter] dateFromString:[self currentXMLElementContent]]];
	} else if ([elementName isEqualToString:@"ETag"]) {
		[[self currentObject] setETag:[self currentXMLElementContent]];
	} else if ([elementName isEqualToString:@"Size"]) {
		[[self currentObject] setSize:(unsigned long long)[[self currentXMLElementContent] longLongValue]];
	} else if ([elementName isEqualToString:@"ID"]) {
		[[self currentObject] setOwnerID:[self currentXMLElementContent]];
	} else if ([elementName isEqualToString:@"DisplayName"]) {
		[[self currentObject] setOwnerName:[self currentXMLElementContent]];
	} else if ([elementName isEqualToString:@"Prefix"] && [[self currentXMLElementStack] count] > 2 && [[[self currentXMLElementStack] objectAtIndex:[[self currentXMLElementStack] count]-2] isEqualToString:@"CommonPrefixes"]) {
		[[self commonPrefixes] addObject:[self currentXMLElementContent]];
	} else if ([elementName isEqualToString:@"IsTruncated"]) {
		[self setIsTruncated:[[self currentXMLElementContent] isEqualToString:@"True"]];
	} else if ([elementName isEqualToString:@"Marker"]) {
		[self setMarker:[self currentXMLElementContent]];
	} else if ([elementName isEqualToString:@"NextMarker"]) {
		[self setNextMarker:[self currentXMLElementContent]];
	} else {
		// Let ASIS3Request look for error messages
		[super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
	}
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone
{
	ASIS3BucketRequest *newRequest = [super copyWithZone:zone];
	[newRequest setBucket:[self bucket]];
	[newRequest setSubResource:[self subResource]];
	[newRequest setPrefix:[self prefix]];
	[newRequest setMarker:[self marker]];
    [newRequest setNextMarker:[self nextMarker]];
	[newRequest setMaxResultCount:[self maxResultCount]];
	[newRequest setDelimiter:[self delimiter]];
	return newRequest;
}

@synthesize bucket;
@synthesize subResource;
@synthesize currentObject;
@synthesize objects;
@synthesize commonPrefixes;
@synthesize prefix;
@synthesize marker;
@synthesize nextMarker;
@synthesize maxResultCount;
@synthesize delimiter;
@synthesize isTruncated;

@end
