//
//  BBAuthController.h
//  boboa
//
//  Created by Yanbo Wu on 9/7/11.
//

#import <Foundation/Foundation.h>

#import "BBAuthorizer.h"

@interface BBAuthController : NSObject<BBAuthorizerDelegate> {
@private
    BBAuthorizer *authorizer;
}

@property (retain) IBOutlet NSWindow *window;

- (IBAction)auth:(id)sender;
- (IBAction)signup:(id)sender;

@end
