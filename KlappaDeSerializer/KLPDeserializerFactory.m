//
//  KLPDeserializerFactory.m
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/25/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import "KLPDeserializerFactory.h"
#import "KLPStandardDeserializer.h"
#import <UIKit/UIKit.h>

static id<KLPDeserializer> defaultDeserializer;
static NSMutableDictionary* fieldsDeserializers;

@implementation KLPDeserializerFactory

- (instancetype)init {
    [NSException raise:@"This object is not supposed to be created" format:@""];
    return nil;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    [NSException raise:@"This object is not supposed to be created" format:@""];
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    [NSException raise:@"This object is not supposed to be created" format:@""];
    return nil;
}

+ (id) deserializeWithString:(Class<KLPDeserializable>) deserializationClass jsonString:(NSString*) json {
    if (defaultDeserializer == nil) defaultDeserializer = [[KLPStandardDeserializer alloc] init];
    if (fieldsDeserializers == nil) fieldsDeserializers = [[NSMutableDictionary alloc] init];
    
    NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    id object;
    if ([json hasPrefix:@"{"]) {
        NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        object = [KLPDeserializerFactory deserializeWithDictionary:deserializationClass jsonDictionary:dictionary];
    } else {
        NSArray* array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        object = [KLPDeserializerFactory deserializeWithArray:deserializationClass array:array];
    }
    
    if (error != nil) {
        @throw error;
    }
    
    return object;
}

+ (NSArray*) deserializeWithArray:(Class<KLPDeserializable>) deserializationClass array:(NSArray*) json {
    if (defaultDeserializer == nil) defaultDeserializer = [[KLPStandardDeserializer alloc] init];
    if (fieldsDeserializers == nil) fieldsDeserializers = [[NSMutableDictionary alloc] init];
    
    NSMutableArray* objects = [[NSMutableArray alloc] init];
    
    for (id object in json) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            [objects addObject:[KLPDeserializerFactory deserializeWithDictionary:deserializationClass jsonDictionary:object]];
        } else if ([object isKindOfClass:[NSArray class]]) {
            [NSException raise:@"Nested arrays are not supported" format:@"[[], [], []] JSONs of such format are not suported"];
        } else {
            [objects addObject:object];
        }
    }
    
    return objects;
}

+ (id) deserializeWithDictionary:(Class<KLPDeserializable>) deserializationClass jsonDictionary:(NSDictionary*) json {
    if (defaultDeserializer == nil) defaultDeserializer = [[KLPStandardDeserializer alloc] init];
    if (fieldsDeserializers == nil) fieldsDeserializers = [[NSMutableDictionary alloc] init];
    
    return [defaultDeserializer deserialize:deserializationClass json:json];
}

+ (id) deserializeWithDictionaryForField:(Class<KLPDeserializable>) deserializationClass jsonDictionary:(NSDictionary*) json field:(NSString*) fieldName context:(Class*) context {
    if (defaultDeserializer == nil) defaultDeserializer = [[KLPStandardDeserializer alloc] init];
    if (fieldsDeserializers == nil) fieldsDeserializers = [[NSMutableDictionary alloc] init];
    
    NSString* key = [fieldName stringByAppendingString: (context != nil ? NSStringFromClass(*context) : @"")];
    id<KLPDeserializer> deserializer = fieldsDeserializers[key];
    if (deserializer == nil) {
        deserializer = fieldsDeserializers[fieldName];
    }
    return deserializer == nil ? [defaultDeserializer deserialize:deserializationClass json:json] : [deserializer deserialize:deserializationClass json:json];
}

+ (void) setDefaultDeserializer:(id<KLPDeserializer>) deserializer {
    if (defaultDeserializer == nil) defaultDeserializer = [[KLPStandardDeserializer alloc] init];
    if (fieldsDeserializers == nil) fieldsDeserializers = [[NSMutableDictionary alloc] init];
    
    defaultDeserializer = deserializer;
}

+ (void) registerDeserializer:(id<KLPDeserializer>) deserializer name:(NSString*) fieldName context:(Class<KLPDeserializer>*) context {
    if (defaultDeserializer == nil) defaultDeserializer = [[KLPStandardDeserializer alloc] init];
    if (fieldsDeserializers == nil) fieldsDeserializers = [[NSMutableDictionary alloc] init];
    
    NSString* type = context == nil ? @"" : NSStringFromClass(*context);
    NSString* key = [fieldName stringByAppendingString:type];
    fieldsDeserializers[key] = deserializer;
}

@end
