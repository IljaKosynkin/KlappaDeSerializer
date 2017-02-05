//
//  KLPFieldsRetriever.m
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/22/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import "KLPDefaultFieldsRetriever.h"
#import <objc/runtime.h>

@implementation KLPDefaultFieldsRetriever

- (NSString*) extractSwiftRepresentation:(NSString*) type {
    NSString* regString = @"_Tt.[0-9]+(.+)[0-9]+(.+)";
    NSRegularExpression* extraction = [NSRegularExpression regularExpressionWithPattern:regString options:0 error:NULL];
    
    NSArray* matches = [extraction matchesInString:type options:0 range:NSMakeRange(0, [type length])];
    NSTextCheckingResult* matchesResult = [matches objectAtIndex:0];
    
    NSRange nameRange = [matchesResult rangeAtIndex:1];
    NSRange classRange = [matchesResult rangeAtIndex:2];
    
    NSString* projectName = [type substringWithRange:nameRange];
    NSString* className = [type substringWithRange:classRange];
    
    return [[projectName stringByAppendingString:@"."] stringByAppendingString:className];
}

- (void) getFieldsOfClass:(Class)class fields:(NSMutableDictionary**) fieldsMap {
    unsigned int count;
    
    objc_property_t* props = class_copyPropertyList(class, &count);
    for (int i = 0; i < count; i++) {
        objc_property_t property = props[i];
        
        NSString * name = [NSString stringWithUTF8String: property_getName(property)];
        NSString * type = [NSString stringWithUTF8String: property_getAttributes(property)];
            
        NSArray * attributes = [type componentsSeparatedByString:@"\""];
        NSString * parsedType;
        if ([attributes count] > 1) {
            parsedType = [attributes objectAtIndex:1];
            parsedType = [[parsedType componentsSeparatedByString:@"\""] objectAtIndex:0];
        } else {
            attributes = [type componentsSeparatedByString:@","];
            parsedType = [attributes objectAtIndex:0];
            parsedType = [parsedType substringFromIndex:1];
        }
        
        NSRegularExpression* protocolCheck = [NSRegularExpression regularExpressionWithPattern:@".*<(.*)>.*" options:NSRegularExpressionCaseInsensitive error:nil];
        NSTextCheckingResult *result = [protocolCheck firstMatchInString:parsedType options:NSMatchingReportCompletion range:NSMakeRange(0, parsedType.length)];
        if ([result numberOfRanges] > 0) {
            parsedType = [parsedType substringWithRange:[result rangeAtIndex:1]];
        }
            
        if ([parsedType hasPrefix:@"_Tt"]) {
            parsedType = [self extractSwiftRepresentation:parsedType];
        }
        
        (*fieldsMap)[name] = parsedType;
    }
    
    free(props);
}

- (NSDictionary*) getFields:(id) object; {
    NSMutableDictionary* fields = [[NSMutableDictionary alloc] init];
    
    Class currentClass = [object class];
    while (YES) {
        [self getFieldsOfClass:currentClass fields:&fields];
        currentClass = [currentClass superclass];
        if (currentClass == [NSObject class]) {
            break;
        }
    }
    
    return fields;
}

@end
