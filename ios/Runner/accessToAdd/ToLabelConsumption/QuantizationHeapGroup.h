#import "SpotAmortizationProtocol.h"
#import "ResizablePointStatus.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface QuantizationHeapGroup : NSObject


- (void) requestMarginAndTimer;

- (void) yieldBelowBatchVar;

@end

NS_ASSUME_NONNULL_END
        