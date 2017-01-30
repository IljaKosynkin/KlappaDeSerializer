//
//  KLPFieldsRetriever.m
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/22/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import "KLPFieldsRetriever.h"
#import <objc/runtime.h>

@implementation KLPFieldsRetriever

+(NSString*) extractSwiftRepresentation:(NSString*) type {
    NSString* projectName = [NSString stringWithUTF8String:getprogname()];
    NSRange range = [type rangeOfString:projectName];
    NSString* secondPart = [type substringFromIndex:range.location + range.length];
    NSRange projectOccurence = [secondPart rangeOfString:projectName];
    
    NSString* stringWithNumber;
    if (projectOccurence.location != NSNotFound) {
        stringWithNumber = [secondPart substringToIndex:projectOccurence.location];
    } else {
        stringWithNumber = secondPart;
    }
    
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"([0-9]+).*" options:0 error:NULL];
    NSTextCheckingResult* match = [regex firstMatchInString:stringWithNumber options:0 range:NSMakeRange(0, [stringWithNumber length])];
    NSString* extractedNumber = [stringWithNumber substringWithRange:[match rangeAtIndex:1]];
    int parsedValue = [extractedNumber intValue];
    
    NSString* className = [secondPart substringWithRange:NSMakeRange([extractedNumber length], parsedValue)];
    return [[projectName stringByAppendingString:@"."] stringByAppendingString:className];
}

+(void) getFieldsOfClass:(Class)class fields:(NSMutableDictionary**) fieldsMap {
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
            parsedType = [KLPFieldsRetriever extractSwiftRepresentation:parsedType];
        }
        
        (*fieldsMap)[name] = parsedType;
    }
    
    free(props);
}

+(void) getFieldsOfObject:(id)object fields:(NSDictionary**) fieldsMap {
    NSMutableDictionary* fields = [[NSMutableDictionary alloc] init];
    
    Class currentClass = [object class];
    while (YES) {
        [KLPFieldsRetriever getFieldsOfClass:currentClass fields:&fields];
        currentClass = [currentClass superclass];
        if (currentClass == [NSObject class]) {
            break;
        }
    }
    
    *fieldsMap = fields;
}

@end
