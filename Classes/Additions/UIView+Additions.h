#import <UIKit/UIKit.h>

@interface UIView (Additions)

@property(nonatomic) CGFloat left;
@property(nonatomic) CGFloat top;
@property(nonatomic) CGFloat right;
@property(nonatomic) CGFloat bottom;

@property(nonatomic) CGFloat width;
@property(nonatomic) CGFloat height;

- (UIScrollView*) findFirstScrollView;
- (UIView*) firstViewOfClass:(Class)cls;
- (UIView*) firstParentOfClass:(Class)cls;
- (UIView*) findChildWithDescendant:(UIView*)descendant;

- (BOOL) findAndResignFirstResponder;
- (id) firstResponder;

@end