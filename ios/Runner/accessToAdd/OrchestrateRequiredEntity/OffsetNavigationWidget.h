#import "NotifyViewShader.h"
#import "AssociatedAccessoryTransition.h"
#import "SubscriberPhaseIndex.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OffsetNavigationWidget : NSObject


- (void) receiveAnimationDuringGrain;

- (void) finishNavigatorWithCubit;

@end

NS_ASSUME_NONNULL_END
        