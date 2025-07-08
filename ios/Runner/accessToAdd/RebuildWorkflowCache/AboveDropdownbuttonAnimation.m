#import "AboveDropdownbuttonAnimation.h"
    
@interface AboveDropdownbuttonAnimation ()

@end

@implementation AboveDropdownbuttonAnimation

- (instancetype) init
{
	NSNotificationCenter *featureTierType = [NSNotificationCenter defaultCenter];
	[featureTierType addObserver:self selector:@selector(queueThanVar:) name:UIKeyboardWillHideNotification object:nil];
	return self;
}

- (void) unscheduleBetweenStoreInterpreter: (NSMutableDictionary *)usecasePrototypeCoord
{
	dispatch_async(dispatch_get_main_queue(), ^{
		//NSLog(@"sets= bussiness2 gen_dic %@", bussiness2);
	});
}

- (void) queueThanVar: (NSNotification *)giftEnvironmentBorder
{
	//NSLog(@"userInfo=%@", [giftEnvironmentBorder userInfo]);
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
        