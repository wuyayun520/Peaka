#import "FlexibleExtensionIntegration.h"
#import "PainterViewObserver.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RowHandlerGroup : NSObject


- (void) decodeMissedRequest;

- (void) awaitLostPreview;

@end

NS_ASSUME_NONNULL_END
        