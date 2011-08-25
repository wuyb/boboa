//
//  BBParser.h
//  boboa
//
//  Created by Yanbo Wu on 4/2/11.
//

#import <Foundation/Foundation.h>

// This is a silly JSON parser for Sina Weibo services.
// It is NOT compatible with JSON standard!
@interface BBParser : NSObject {
@private
    NSDictionary *classes;
    NSDateFormatter *dateFormatter;
}

+(BBParser *)defaultInstance;

-(id)initWithClasses:(NSDictionary *)cs dateFormat:(NSString *)dateFormat;

// If the data is a map, it will be decoded as the class.
// If it is an array, it will be decoded as an array of the given class.
-(id)decode:(id) data as:(Class)clazz;

@end
