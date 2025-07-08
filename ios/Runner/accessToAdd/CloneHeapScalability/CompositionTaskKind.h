#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CompositionTaskKind : NSObject

@property (nonatomic) int finalTangentName;

@property (nonatomic) NSString * expandedTaskFlags;

+ (instancetype) compositionTaskKindWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) primaryResourceFormat;

- (NSMutableDictionary *) constPreviewOpacity;

- (int) positionedOutsideSystem;

- (NSMutableSet *) baselineParameterTop;

- (NSMutableArray *) diffableCurveSkewx;

@end

NS_ASSUME_NONNULL_END
        