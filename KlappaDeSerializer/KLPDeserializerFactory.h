//
//  KLPDeserializerFactory.h
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/25/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KLPDeserializable.h"
#import "KLPDeserializer.h"

@interface KLPDeserializerFactory : NSObject
+ (id) deserializeWithString:(Class<KLPDeserializable>) deserializationClass jsonString:(NSString*) json;
+ (NSArray*) deserializeWithArray:(Class<KLPDeserializable>) deserializationClass array:(NSArray*) json;

+ (id) deserializeWithDictionary:(Class<KLPDeserializable>) deserializationClass jsonDictionary:(NSDictionary*) json;
+ (id) deserializeWithDictionaryForField:(Class<KLPDeserializable>) deserializationClass jsonDictionary:(NSDictionary*) json field:(NSString*) fieldName context:(Class*) context;

+ (void) setDefaultDeserializer:(id<KLPDeserializer>) defaultDeserializer;
+ (void) registerDeserializer:(id<KLPDeserializer>) deserializer name:(NSString*) fieldName context:(Class<KLPDeserializer>*) context;
@end
