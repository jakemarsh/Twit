#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIToolbar (SSCategory)

- (UIBarButtonItem*) itemWithTag:(NSInteger)tag;
- (void) replaceItemWithTag:(NSInteger)tag withItem:(UIBarButtonItem*)item;

@end