#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoordinatorDataDelegate : NSObject

@property (nonatomic) NSMutableSet * curveChainHue;

+ (instancetype) coordinatorDataDelegateWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) futureForScope;

- (NSMutableDictionary *) signatureInNumber;

- (int) activeTangentDirection;

- (NSMutableSet *) eventIncludeStage;

- (NSMutableArray *) resolverAsObserver;

@end

NS_ASSUME_NONNULL_END
        