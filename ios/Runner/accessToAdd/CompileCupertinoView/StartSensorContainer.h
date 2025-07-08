#import "EmbraceActivatedRoute.h"
#import "ControllerLoaderManager.h"
#import "AugmentWorkflowError.h"
#import "GrainFormStatus.h"
#import "ConsumeResilientError.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StartSensorContainer : NSObject


- (void) updateDialogsCubit;

- (void) resumeTransformWithinMission;

@end

NS_ASSUME_NONNULL_END
        