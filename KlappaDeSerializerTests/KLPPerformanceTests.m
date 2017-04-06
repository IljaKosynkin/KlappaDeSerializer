//
//  KLPPerformanceTests.m
//  KlappaDeSerializer
//
//  Created by Ilja Kosynkin on 3/28/17.
//  Copyright © 2017 Ilja Kosynkin. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KLPStandardDeserializer.h"
#import "KLPExplicitNamingStrategy.h"
#import "KLPDeserializer.h"
#import "KLPAncestor.h"

@interface ArtworkInfo : KLPAncestor

@property NSString* StorageGroup;
@property NSString*  URL;
@property NSString*  Type;
@property NSString*  FileName;

@end

@implementation ArtworkInfo

@end

@interface Artwork : KLPAncestor

@property NSArray* ArtworkInfos;

@end

@implementation Artwork

+ (NSDictionary*) getFieldsToClassMap {
    return @{@"ArtworkInfos": [ArtworkInfo class]};
}

@end

@interface Channel : KLPAncestor

@property NSString* ServiceId;
@property NSString* ChanNum;
@property NSString* TransportId;
@property NSString* SourceId;
@property NSString* FrequencyId;
@property NSString* CommFree;
@property NSString* UseEIT;
@property NSString* DefaultAuth;
@property NSString* ChannelName;
@property NSString* SIStandard;
@property NSString* ATSCMinorChan;
@property NSString* Visible;
@property NSString* Format;
@property NSArray* Programs;
@property NSString* ATSCMajorChan;
@property NSString* FrequencyTable;
@property NSString* ChanId;
@property NSString* Frequency;
@property NSString* InputId;
@property NSString* CallSign;
@property NSString* IconURL;
@property NSString* MplexId;
@property NSString* NetworkId;
@property NSString* Modulation;
@property NSString* FineTune;
@property NSString* ChanFilters;
@property NSString* XMLTVID;

@end

@implementation Channel

+ (NSDictionary*) getFieldsToClassMap {
    return @{@"Programs": [NSString class]};
}

@end

@interface Recording : KLPAncestor

@property NSString* RecType;
@property NSString* DupMethod;
@property NSString* DupInType;
@property NSString* Profile;
@property NSString* Priority;
@property NSString* EndTs;
@property NSString* RecGroup;
@property NSString* StorageGroup;
@property NSString* StartTs;
@property NSString* RecordId;
@property NSString* EncoderId;
@property NSString* PlayGroup;
@property NSString* Status;

@end

@implementation Recording

@end

@interface Program : KLPAncestor

@property NSString* Stars;
@property NSString* Title;
@property NSString* HostName;
@property Artwork* Artwork;
@property NSString* Repeat;
@property NSString* Inetref;
@property NSString* LastModified;
@property NSString* SubTitle;
@property NSString* AudioProps;
@property NSString* FileSize;
@property NSString* VideoProps;
@property NSString* SeriesId;
@property NSString* Season;
@property NSString* ProgramFlags;
@property NSString* Episode;
@property NSString* Airdate;
@property NSString* StartTime;
@property Recording* Recording;
@property NSString* Description;
@property Channel* Channel;
@property NSString* Category;
@property NSString* EndTime;
@property NSString* FileName;
@property NSString* SubProps;
@property NSString* ProgramId;
@property NSString* CatType;

@end

@implementation Program

@end

@interface ProgramList : KLPAncestor

@property NSString* Version;
@property NSString* StartIndex;
@property NSString* ProtoVer;
@property NSString* TotalAvailable;
@property NSString* AsOf;
@property NSArray* Programs;
@property NSString* Count;

@end

@implementation ProgramList

+ (NSDictionary*) getFieldsToClassMap {
    return @{@"Programs": [Program class]};
}

@end

@interface Large : KLPAncestor

@property ProgramList* ProgramList;

@end

@implementation Large

@end


@interface KLPPerformanceTests : XCTestCase

@end

@implementation KLPPerformanceTests

- (NSDictionary*) getJsonFile:(NSString*) name {
    NSString* filepath = [[NSBundle bundleForClass:[self class]] pathForResource:name ofType:@"json"];
    NSString *jsonString = [[NSString alloc] initWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    NSData* data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSDictionary* dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    return dictionary;
}

- (void) testLargeFileIsParsedCorrectly {
    [KLPDeserializer setGlobalNamingStrategy:[[KLPExplicitNamingStrategy alloc] init]];
    
    NSDictionary* dict = [self getJsonFile:@"Large"];
    
    Large* obj = [KLPDeserializer deserializeWithDictionary:[Large class] jsonDictionary:dict];
    XCTAssertNotNil(obj);
    XCTAssertNotNil(obj.ProgramList);
    
    XCTAssertTrue([obj.ProgramList.Version isEqualToString:@"0.27.20151025-1"]);
    XCTAssertTrue([obj.ProgramList.StartIndex isEqualToString:@"0"]);
    XCTAssertTrue([obj.ProgramList.ProtoVer isEqualToString:@"77"]);
    XCTAssertTrue([obj.ProgramList.TotalAvailable isEqualToString:@"785"]);
    XCTAssertTrue([obj.ProgramList.AsOf isEqualToString:@"2015-12-13T18:52:01Z"]);
    
    XCTAssertEqual(obj.ProgramList.Programs.count, 4710);
    
    Program* program = obj.ProgramList.Programs[0];
    XCTAssertTrue([program.Stars isEqualToString:@"0"]);
    XCTAssertTrue([program.Title isEqualToString:@"Arthur"]);
    XCTAssertTrue([program.HostName isEqualToString:@"mythtv"]);
    XCTAssertTrue([program.Repeat isEqualToString:@"true"]);
    XCTAssertTrue([program.Inetref isEqualToString:@""]);
    XCTAssertTrue([program.LastModified isEqualToString:@"2015-12-13T16:30:04Z"]);
    XCTAssertTrue([program.SubTitle isEqualToString:@"Shelter From the Storm (Part 1 & 2)"]);
    XCTAssertTrue([program.AudioProps isEqualToString:@"1"]);
    XCTAssertTrue([program.FileSize isEqualToString:@"2913590724"]);
    XCTAssertTrue([program.VideoProps isEqualToString:@"19"]);
    XCTAssertTrue([program.SeriesId isEqualToString:@"EP00044107"]);
    XCTAssertTrue([program.Season isEqualToString:@"0"]);
    XCTAssertTrue([program.ProgramFlags isEqualToString:@"4101"]);
    XCTAssertTrue([program.Episode isEqualToString:@"0"]);
    XCTAssertTrue([program.Airdate isEqualToString:@"2015-09-08"]);
    XCTAssertTrue([program.StartTime isEqualToString:@"2015-12-13T16:00:00Z"]);
    XCTAssertTrue([program.Description isEqualToString:@"Everyone is affected when a powerful hurricane hits Elwood City."]);
    XCTAssertTrue([program.Category isEqualToString:@"Children"]);
    XCTAssertTrue([program.EndTime isEqualToString:@"2015-12-13T16:30:00Z"]);
    XCTAssertTrue([program.FileName isEqualToString:@"1071_20151213160000.mpg"]);
    XCTAssertTrue([program.SubProps isEqualToString:@"1"]);
    XCTAssertTrue([program.ProgramId isEqualToString:@"EP000441070779"]);
    XCTAssertTrue([program.CatType isEqualToString:@""]);
    
    XCTAssertNotNil(program.Artwork);
    
    XCTAssertNotNil(program.Recording);
    XCTAssertTrue([program.Recording.RecType isEqualToString:@"0"]);
    XCTAssertTrue([program.Recording.DupMethod isEqualToString:@"6"]);
    XCTAssertTrue([program.Recording.DupInType isEqualToString:@"15"]);
    XCTAssertTrue([program.Recording.Profile isEqualToString:@"Default"]);
    XCTAssertTrue([program.Recording.Priority isEqualToString:@"-5"]);
    XCTAssertTrue([program.Recording.EndTs isEqualToString:@"2015-12-13T16:30:00Z"]);
    XCTAssertTrue([program.Recording.RecGroup isEqualToString:@"Default"]);
    XCTAssertTrue([program.Recording.StorageGroup isEqualToString:@"Default"]);
    XCTAssertTrue([program.Recording.StartTs isEqualToString:@"2015-12-13T16:00:00Z"]);
    XCTAssertTrue([program.Recording.RecordId isEqualToString:@"347"]);
    XCTAssertTrue([program.Recording.EncoderId isEqualToString:@"0"]);
    XCTAssertTrue([program.Recording.PlayGroup isEqualToString:@"Default"]);
    XCTAssertTrue([program.Recording.Status isEqualToString:@"-3"]);
    
    
    
    XCTAssertNotNil(program.Channel);
    XCTAssertTrue([program.Channel.ServiceId isEqualToString:@"0"]);
    XCTAssertTrue([program.Channel.ChanNum isEqualToString:@"7_1"]);
    XCTAssertTrue([program.Channel.TransportId isEqualToString:@"0"]);
    XCTAssertTrue([program.Channel.SourceId isEqualToString:@"0"]);
    XCTAssertTrue([program.Channel.FrequencyId isEqualToString:@""]);
    XCTAssertTrue([program.Channel.CommFree isEqualToString:@"0"]);
    XCTAssertTrue([program.Channel.UseEIT isEqualToString:@"false"]);
    XCTAssertTrue([program.Channel.DefaultAuth isEqualToString:@""]);
    XCTAssertTrue([program.Channel.ChannelName isEqualToString:@"KUEDDT (KUED-DT)"]);
    XCTAssertTrue([program.Channel.SIStandard isEqualToString:@""]);
    XCTAssertTrue([program.Channel.ATSCMinorChan isEqualToString:@"0"]);
    XCTAssertTrue([program.Channel.Visible isEqualToString:@"true"]);
    XCTAssertTrue([program.Channel.Format isEqualToString:@""]);
    XCTAssertTrue([program.Channel.ATSCMajorChan isEqualToString:@"0"]);
    XCTAssertTrue([program.Channel.FrequencyTable isEqualToString:@""]);
    XCTAssertTrue([program.Channel.ChanId isEqualToString:@"1071"]);
    XCTAssertTrue([program.Channel.Frequency isEqualToString:@"0"]);
    XCTAssertTrue([program.Channel.InputId isEqualToString:@"0"]);
    XCTAssertTrue([program.Channel.IconURL isEqualToString:@""]);
    XCTAssertTrue([program.Channel.MplexId isEqualToString:@"0"]);
    XCTAssertTrue([program.Channel.NetworkId isEqualToString:@"0"]);
    XCTAssertTrue([program.Channel.Modulation isEqualToString:@""]);
    XCTAssertTrue([program.Channel.FineTune isEqualToString:@"0"]);
    XCTAssertTrue([program.Channel.ChanFilters isEqualToString:@""]);
    XCTAssertTrue([program.Channel.XMLTVID isEqualToString:@""]);
}

- (void)testPerformanceExample {
    [KLPDeserializer setGlobalNamingStrategy:[[KLPExplicitNamingStrategy alloc] init]];
    
    NSDictionary* dict = [self getJsonFile:@"Large"];

    [self measureBlock:^{
        [KLPDeserializer deserializeWithDictionary:[Large class] jsonDictionary:dict];
    }];
}

@end
