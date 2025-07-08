#import "SmartAspectZone.h"
#import "AcrossSliderReducer.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SessionModelDecorator : NSObject


- (void) detachUnactivatedAxis;

- (void) initializeDownRowObserver;

@end

NS_ASSUME_NONNULL_END
        