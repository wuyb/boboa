//
//  BBParser.m
//  boboa
//
//  Created by Yanbo Wu on 4/2/11.
//

#import "BBParser.h"
#import "BBStatus.h"
#import "BBComment.h"

static BBParser *sharedInstance;

@implementation BBParser

+(BBParser *)defaultInstance
{
    if (!sharedInstance) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [dict setObject:[BBStatus class] forKey:@"retweeted_status"];
        [dict setObject:[BBUser class] forKey:@"user"];
        [dict setObject:[NSDate class] forKey:@"created_at"];
        [dict setObject:[NSArray class] forKey:@"annotations"];
        [dict setObject:[BBStatus class] forKey:@"status"];
        [dict setObject:[BBComment class] forKey:@"reply_comment"];
        sharedInstance = [[BBParser alloc] initWithClasses:dict dateFormat:@"EEE MMM dd HH:mm:ss ZZZ yyyy"];
        [dict release];
    }
    return sharedInstance;
}


-(id)initWithClasses:(NSDictionary *)cs dateFormat:(NSString *)dateFormat
{
    self = [super init];
    if (self) {
        classes = [cs retain];
        dateFormatter = [[NSDateFormatter alloc] initWithDateFormat:dateFormat allowNaturalLanguage:YES];
    }
    return self;
}

-(void)dealloc
{
    [dateFormatter release];
    [classes release];
    [super dealloc];
}


-(NSString*) underscoreToCaptialized:(NSString *)str
{
    NSArray * comps = [str componentsSeparatedByString:@"_"];
    if ([comps count] <= 1) {
        return str;
    }
    NSMutableString *converted = [NSMutableString string];
    int i = 0;
    for (NSString * s in comps) {
        if (i == 0) {
            [converted appendString:s];
        } else {
            [converted appendString:[s capitalizedString]];
        }
        i++;
    }
    return converted;
}

-(id)decode:(id) data as:(Class)clazz
{
    if (!clazz) {
        return data;
    }

    if (data) {
        if ([data isKindOfClass:[NSDictionary class]]) {
            NSObject *obj = [[[clazz alloc] init] autorelease];
            
            // parse it as a dictionary to the given class
            NSDictionary *dict = (NSDictionary *) data;
            for (NSString *key in [dict allKeys]) {
                id value = [dict objectForKey:key];
                key = [self underscoreToCaptialized:key];
                if (value != [NSNull null]) {
                    [obj setValue:[self decode:value as:[classes objectForKey:key]] forKey:key];
                }
            }
            return obj;
        } else if ([data isKindOfClass:[NSArray class]] && clazz != [NSArray class]) {
            // parse it as an array of the given class
            NSMutableArray *array = [NSMutableArray array];
            NSArray *rawArray = (NSArray *)data;
            for (id obj in rawArray) {
                [array addObject:[self decode:obj as:clazz]];
            }
            return array;
        } else {
            if (clazz == [NSDate class]) {
                return [dateFormatter dateFromString:data];
            }
            if (clazz == [NSArray class]) {
                if ([data isKindOfClass:[NSArray class]]) {
                    return data;
                }
                return nil;
            }
            return data;
        }
    }
    return nil;
}


@end
