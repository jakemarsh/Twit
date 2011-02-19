#import "UIView+Additions.h"

@implementation UIView (Additions)

- (CGFloat) left {
  return self.frame.origin.x;
}
- (void) setLeft:(CGFloat)x {
  CGRect frame = self.frame;
  frame.origin.x = x;
  self.frame = frame;
}
- (CGFloat) top {
  return self.frame.origin.y;
}
- (void) setTop:(CGFloat)y {
  CGRect frame = self.frame;
  frame.origin.y = y;
  self.frame = frame;
}
- (CGFloat) right {
  return self.frame.origin.x + self.frame.size.width;
}
- (void) setRight:(CGFloat)r {
  CGRect frame = self.frame;
  frame.origin.x = r - self.width;
  self.frame = frame;
}
- (CGFloat) bottom {
  return self.frame.origin.y + self.frame.size.height;
}
- (void) setBottom:(CGFloat)b {
	CGRect frame = self.frame;
	frame.origin.y = b - self.height;
	self.frame = frame;
}
- (CGFloat) width {
  return self.frame.size.width;
}
- (void) setWidth:(CGFloat)width {
  CGRect frame = self.frame;
  frame.size.width = width;
  self.frame = frame;
}
- (CGFloat) height {
  return self.frame.size.height;
}
- (void) setHeight:(CGFloat)height {
  CGRect frame = self.frame;
  frame.size.height = height;
  self.frame = frame;
}

- (UIScrollView*) findFirstScrollView {
  if ([self isKindOfClass:[UIScrollView class]])
    return (UIScrollView*)self;
  
  for (UIView* child in self.subviews) {
    UIScrollView* it = [child findFirstScrollView];
    if (it)
      return it;
  }
  
  return nil;
}
- (UIView*) firstViewOfClass:(Class)cls {
  if ([self isKindOfClass:cls])
    return self;
  
  for (UIView* child in self.subviews) {
    UIView* it = [child firstViewOfClass:cls];
    if (it)
      return it;
  }
  
  return nil;
}
- (UIView*) firstParentOfClass:(Class)cls {
  if ([self isKindOfClass:cls]) {
    return self;
  } else if (self.superview) {
    return [self.superview firstParentOfClass:cls];
  } else {
    return nil;
  }
}
- (UIView*) findChildWithDescendant:(UIView*)descendant {
  for (UIView* view = descendant; view && view != self; view = view.superview) {
    if (view.superview == self) {
      return view;
    }
  }
  
  return nil;
}

- (BOOL) findAndResignFirstResponder {
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;     
    }

    for (UIView *subView in self.subviews) {
        if ([subView findAndResignFirstResponder])
            return YES;
    }

    return NO;
}
- (id) firstResponder {
    if (self.isFirstResponder) return self;
    for (id subView in self.subviews) if ([(UIView *)subView firstResponder]) return self;

    return nil;
}

@end