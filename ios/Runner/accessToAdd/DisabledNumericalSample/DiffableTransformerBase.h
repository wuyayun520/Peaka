#import "StandaloneTransitionInstance.h"
#import "ReplaceOpaqueLayer.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DiffableTransformerBase : NSObject


- (void) endChannelsFuture;

- (void) prepareToConsumerComposite;

@end

NS_ASSUME_NONNULL_END
        