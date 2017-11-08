//
//  XIOrganizationInfoRestCallProvider.h
//  common-iOS
//
//  Created by tkorodi on 17/08/16.
//  Copyright © 2016 LogMeIn Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XIEndUserInfoCallProvider.h"
#import <Internals/SessionServices/XISessionServicesCallProvider.h>

@interface XIEndUserInfoRestCallProvider : NSObject <XIEndUserInfoCallProvider, XISessionServicesCallProvider>

@end
