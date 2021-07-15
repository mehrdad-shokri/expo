#import <UMCore/UMDefines.h>

#import "EXAppLoadingProgressWindowController.h"
#import "EXUtil.h"

@interface EXAppLoadingProgressWindowController ()

@property (nonatomic, assign) BOOL enabled;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation EXAppLoadingProgressWindowController

- (instancetype)initWithEnabled:(BOOL)enabled
{
  if (self = [super init]) {
    _enabled = enabled;
  }
  return self;
}

- (void)show
{
  if (!_enabled) {
    return;
  }
  
  UM_WEAKIFY(self);
  dispatch_async(dispatch_get_main_queue(), ^{
    UM_ENSURE_STRONGIFY(self);
    if (!self.window) {
      CGSize screenSize = [UIScreen mainScreen].bounds.size;
      
      int bottomInsets = 0;
      if (@available(iOS 11.0, *)) {
        bottomInsets = UMSharedApplication().keyWindow.safeAreaInsets.bottom;
      }
      self.window = [[UIWindow alloc] initWithFrame:CGRectMake(0,
                                                               screenSize.height - 36 - bottomInsets,
                                                               screenSize.width,
                                                               36 + bottomInsets)];
      self.window.windowLevel = UIWindowLevelStatusBar + 1;
      // set a root VC so rotation is supported
      self.window.rootViewController = [UIViewController new];
      self.window.backgroundColor = [EXUtil colorWithRGB:0xfafafa];

      UIView *containerView = [UIView new];
      [self.window addSubview:containerView];
      
      CALayer *topBorderLayer = [CALayer layer];
      topBorderLayer.frame = CGRectMake(0, 0, screenSize.width, 1);
      topBorderLayer.backgroundColor = [EXUtil colorWithRGB:0xe3e3e3].CGColor;
      [containerView.layer addSublayer:topBorderLayer];

      self.textLabel = [UILabel new];
      self.textLabel.frame = CGRectMake(10, 0, screenSize.width - 20, 36);
      self.textLabel.font = [UIFont systemFontOfSize:12];
      self.textLabel.textAlignment = NSTextAlignmentLeft;
      self.textLabel.textColor = [EXUtil colorWithRGB:0xa7a7a7];
      [containerView addSubview:self.textLabel];
    }
    self.textLabel.text =  @"Waiting for server ...";
    self.window.hidden = NO;
  });
}

- (void)hide
{
  if (!_enabled) {
    return;
  }

  UM_WEAKIFY(self);
  dispatch_async(dispatch_get_main_queue(), ^{
    UM_ENSURE_STRONGIFY(self);
    if (self.window) {
      self.window.hidden = YES;
    }
  });
}

- (void)updateStatusWithProgress:(EXLoadingProgress *)progress
{
  if (!_enabled) {
    return;
  }
  
  [self show];
  
  UM_WEAKIFY(self);
  dispatch_async(dispatch_get_main_queue(), ^{
    UM_ENSURE_STRONGIFY(self);
    float progressPercent = ([progress.done floatValue] / [progress.total floatValue]);
    self.textLabel.text = [NSString stringWithFormat:@"%@ %.2f%%", progress.status, progressPercent * 100];
    [self.textLabel setNeedsDisplay];
    
    // TODO: (@bbarthec) maybe it's better to show/hide this based on other thing than progress status reported by the fetcher?
    self.window.hidden = !(progress.total.floatValue > 0);
  });
}

- (void)updateStatus:(EXAppLoaderRemoteUpdateStatus)status
{
  if (!_enabled) {
    return;
  }

  NSString *statusText = [[self class] _loadingViewTextForStatus:status];
  if (!statusText) {
    return;
  }

  [self show];

  UM_WEAKIFY(self);
  dispatch_async(dispatch_get_main_queue(), ^{
    UM_ENSURE_STRONGIFY(self);
    self.textLabel.text = statusText;
    [self.textLabel setNeedsDisplay];
  });
}

+ (nullable NSString *)_loadingViewTextForStatus:(EXAppLoaderRemoteUpdateStatus)status
{
  if (status == kEXAppLoaderRemoteUpdateStatusChecking) {
    return @"Checking for new update...";
  } else if (status == kEXAppLoaderRemoteUpdateStatusDownloading) {
    return @"New update available, downloading...";
  } else {
    return nil;
  }
}

@end
