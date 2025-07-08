#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface StorageModelDelegate : NSObject

@property (nonatomic) NSString * observerDecoratorCoord;

@property (nonatomic) int zoneJobCount;

@property (nonatomic) int indicatorIncludePattern;

@property (nonatomic) int stepStructureDirection;

+ (instancetype) storageModelDelegateWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) indicatorParamAppearance;

- (NSMutableDictionary *) parallelPlaybackDelay;

- (int) sophisticatedQueryInset;

- (NSMutableSet *) curveLevelSize;

- (NSMutableArray *) publicObserverInset;

@end

NS_ASSUME_NONNULL_END
        