#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OutGraphicVector : NSObject

@property (nonatomic) NSMutableDictionary * spriteDecoratorValidation;

+ (instancetype) outGraphicVectorWithDictionary: (NSDictionary *)dict;

- (instancetype) initWithDictionary: (NSDictionary *)dict;

- (NSString *) entityCycleStatus;

- (NSMutableDictionary *) assetVarCoord;

- (int) switchPlatformMargin;

- (NSMutableSet *) touchLayerBorder;

- (NSMutableArray *) loopJobFrequency;

@end

NS_ASSUME_NONNULL_END
        