//
//  KLPStandardDeserializer.m
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/22/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import "KLPStandardDeserializer.h"
#import "KLPDeserializer.h"
#import "KLPDefaultNamingStrategy.h"
#import "KLPDefaultFieldsRetriever.h"
#import "KLPDefaultArrayTypeExtractor.h"
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
    _retriever = [[KLPDefaultFieldsRetriever alloc] init];
    _extractor = [[KLPDefaultArrayTypeExtractor alloc] init];
    return self;
}

- (void) setGlobalNamingStrategy:(id<KLPNamingStrategy>) strategy {
    globalStrategy = strategy;
}

- (id<KLPDeserializable>) deserialize:(Class<KLPDeserializable>) classToDeserialize json:(NSDictionary*) jsonToDeserialize {
    NSObject<KLPDeserializable>* object = [[classToDeserialize alloc] init];
    
    NSDictionary* fields = [_retriever getFields:object];
    
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
            [object setValue:[KLPDeserializer deserializeWithDictionaryForField:expectedClass jsonDictionary:value field:key context: &classToDeserialize] forKey:translatedKey];
            
        } else if ([value isKindOfClass:[NSArray class]]) {
            Class<KLPDeserializable> expectedClass = [self.extractor getType:object forField:key];
            if (expectedClass == nil) {
                [NSException raise:@"Class for field not found." format:@"Couldn't find class mapping for field %@", translatedKey];
            }
            [object setValue:[KLPDeserializer deserializeWithArray:expectedClass array:value] forKey:translatedKey];
        } else {
            NSString* extendedKey = [key stringByAppendingString:[separator stringByAppendingString:NSStringFromClass([value class])]];
            NSString* fullKey = [extendedKey stringByAppendingString:[separator stringByAppendingString:type]];
            NSString* globalKey = [separator stringByAppendingString:NSStringFromClass([value class])];
            globalKey = [globalKey stringByAppendingString:[separator stringByAppendingString:type]];
            id<KLPValueConverter> converter = converters[fullKey];
            if (converter == nil) {
                converter = converters[extendedKey];
            }
            if (converter == nil) {
                converter = converters[key];
            }
            if (converter == nil) {
                converter = converters[globalKey];
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
    if (fieldName == nil && output == nil) {
        [NSException raise:@"You didn't provide enough data for registration." format:@""];
    }
    
    NSArray* types = [self getValueOfType:type];
    for (NSString* type in types) {
        NSString* field = fieldName == nil ? @"" : fieldName;
        NSString* key = [field stringByAppendingString:[separator stringByAppendingString: type]];
        NSString* outputType = output == nil ? @"" : [separator stringByAppendingString: NSStringFromClass(*output)];
        key = [key stringByAppendingString: outputType];
        converters[key] = converter;
    }
}

- (void) addValueConverterForCustomClass:(id<KLPValueConverter>) converter forField:(NSString*) fieldName forCustomClass:(Class*) type forOutputClass:(Class*) output {
    NSString* field = fieldName == nil ? @"" : fieldName;
    NSString* inputType = type == nil ? @"" : [separator stringByAppendingString: NSStringFromClass(*type)];
    NSString* outputType = output == nil ? @"" : [separator stringByAppendingString: NSStringFromClass(*output)];
    
    NSString* key = [field stringByAppendingString:inputType];
    key = [key stringByAppendingString: outputType];
    if ([key length] == 0) {
        [NSException raise:@"You didn't provide any data for registration. Give either fieldName or input and output class or both" format:@""];
    }
    
    converters[key] = converter;
}

@end
