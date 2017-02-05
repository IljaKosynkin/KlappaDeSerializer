//
//  KLPDefaultNamingStrategy.m
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 1/24/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import "KLPDefaultNamingStrategy.h"

@implementation KLPDefaultNamingStrategy

- (NSString *)stringByReplacingSnakeCaseWithCamelCase:(NSString*) originalString {
    NSArray *components = [originalString componentsSeparatedByString:@"_"];
    NSMutableString *output = [NSMutableString string];
    
    for (NSUInteger i = 0; i < components.count; i++) {
        if (i == 0) {
            if (components.count == 1) {
                NSString* fullString = components[i];
                NSString* firstLetter = [[fullString substringToIndex:1] lowercaseString];
                [output appendString:firstLetter];
                [output appendString:[fullString substringFromIndex:1]];
            } else {
                [output appendString:[components[i] lowercaseString]];
            }
        } else {
            [output appendString:[components[i] capitalizedString]];
        }
    }
    
    return [NSString stringWithString:output];
}

- (NSString*) convertName:(NSString*) originalName {
    return [self stringByReplacingSnakeCaseWithCamelCase:originalName];
}

@end
