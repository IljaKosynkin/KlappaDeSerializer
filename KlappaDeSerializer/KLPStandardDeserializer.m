//
//  KLPStandardDeserializer.m
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/22/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import "KLPStandardDeserializer.h"
#import "KLPDeserializerFactory.h"
#import "KLPFieldsRetriever.h"
#import "KLPDefaultNamingStrategy.h"
#import <objc/runtime.h>

static NSString* separator = @"|\\o/|";

@implementation KLPStandardDeserializer {
    id<KLPNamingStrategy> globalStrategy;
    NSMutableDictionary* converters;
}

- (id) init {
    self = [super init];
    globalStrategy = [[KLPDefaultNamingStrategy alloc] init];
    converters = [[NSMutableDictionary alloc] init];
    return self;
}

- (void) setGlobalNamingStrategy:(id<KLPNamingStrategy>) strategy {
    globalStrategy = strategy;
}

- (id) deserialize:(Class<KLPDeserializable>) classToDeserialize json:(NSDictionary*) jsonToDeserialize {
    NSDictionary* fieldsMap = [classToDeserialize getFieldsToClassMap];
    id object = [[classToDeserialize alloc] init];
    
    NSDictionary* fields;
    [KLPFieldsRetriever getFieldsOfObject:object fields:&fields];
    
    for (NSString* key in jsonToDeserialize) {
        NSString* translatedKey = [globalStrategy convertName:key];
        if (fields[translatedKey] == nil) {
            continue;
        }
        
        id value = jsonToDeserialize[key];
        NSString* type = fields[translatedKey];
        if ([value isKindOfClass:[NSDictionary class]]) {
            Class<KLPDeserializable> expectedClass = NSClassFromString(type);
            if (expectedClass == nil) {
                [NSException raise:@"Class for field not found." format:@"Couldn't find class mapping for field %@", translatedKey];
            }
            [object setValue:[KLPDeserializerFactory deserializeWithDictionaryForField:expectedClass jsonDictionary:value field:key context: &classToDeserialize] forKey:translatedKey];
            
        } else if ([value isKindOfClass:[NSArray class]]) {
            Class<KLPDeserializable> expectedClass = fieldsMap[translatedKey];
            if (expectedClass == nil) {
                [NSException raise:@"Class for field not found." format:@"Couldn't find class mapping for field %@", translatedKey];
            }
            [object setValue:[KLPDeserializerFactory deserializeWithArray:expectedClass array:value] forKey:translatedKey];
        } else {
            NSString* extendedKey = [key stringByAppendingString:[separator stringByAppendingString:NSStringFromClass([value class])]];
            NSString* fullKey = [extendedKey stringByAppendingString:[separator stringByAppendingString:type]];
            id<KLPValueConverter> converter = converters[fullKey];
            if (converter == nil) {
                converter = converters[extendedKey];
            }
            if (converter == nil) {
                converter = converters[key];
            }
            value = converter == nil ? value : [converter convert:value];
            [object setValue:value forKey:translatedKey];
        }
    }
    
    return object;
}

- (NSArray*) getValueOfType:(Type) type {
    switch (type) {
        case Integer:
            return @[@"__NSCFNumber"];
        case Double:
            return @[@"NSDecimalNumber"];
        case String:
            return @[@"__NSCFString", @"NSTaggedPointerString"];
        case Null:
            return @[@"NSNull"];
    }
}

- (void) addValueConverter:(id<KLPValueConverter>) converter forField:(NSString*) fieldName forInputType:(Type) type forOutputClass:(Class*) output {
    NSArray* types = [self getValueOfType:type];
    for (NSString* type in types) {
        NSString* key = [fieldName stringByAppendingString:[separator stringByAppendingString: type]];
        NSString* outputType = output == nil ? @"" : [separator stringByAppendingString: NSStringFromClass(*output)];
        key = [key stringByAppendingString: outputType];
        converters[key] = converter;
    }
}

- (void) addValueConverterForCustomClass:(id<KLPValueConverter>) converter forField:(NSString*) fieldName forCustomClass:(Class*) type forOutputClass:(Class*) output {
    NSString* inputType = type == nil ? @"" : [separator stringByAppendingString: NSStringFromClass(*type)];
    NSString* outputType = output == nil ? @"" : [separator stringByAppendingString: NSStringFromClass(*output)];
    
    NSString* key = [fieldName stringByAppendingString:inputType];
    key = [key stringByAppendingString: outputType];
    converters[key] = converter;
}

@end
