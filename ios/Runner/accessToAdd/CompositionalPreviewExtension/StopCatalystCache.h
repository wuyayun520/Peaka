#import "CompositionServiceList.h"
#import "UnmountedCycleConstant.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StopCatalystCache : NSObject


- (void) processSubsequentLayout;

- (void) serializeCrudeResult;

@end

NS_ASSUME_NONNULL_END
        