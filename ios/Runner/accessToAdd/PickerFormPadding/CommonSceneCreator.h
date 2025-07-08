#import "ResponseShapeBase.h"
#import "ListenSwiftScene.h"
#import "LocalNativeCompleter.h"
#import "PlayActivitySprite.h"

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CommonSceneCreator : NSObject


- (void) addForFutureScope;

- (void) removeCurrentNavigator;

@end

NS_ASSUME_NONNULL_END
        