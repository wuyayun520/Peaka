#import "SecondSliderQueue.h"
#import "GlobalEagerTicker.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RefreshLogIntegration : NSObject


- (void) transitionExecuteBeforeCertificate;

- (void) processGateCallback;

@end

NS_ASSUME_NONNULL_END
        