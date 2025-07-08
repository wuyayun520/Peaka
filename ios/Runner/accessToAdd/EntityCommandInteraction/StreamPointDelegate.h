#import "AnimateVariantTransformer.h"
#import "ConcreteLostFuture.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StreamPointDelegate : NSObject


- (void) clearSegmentAndHandler;

- (void) handleStatefulGraph;

@end

NS_ASSUME_NONNULL_END
        