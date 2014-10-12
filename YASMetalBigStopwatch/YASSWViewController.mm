//
//  YASSWViewController.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASSWViewController.h"
#import "YAS2DRenderer.h"
#import "YAS2DSquareNode.h"
#import "YAS2DStringsNode.h"
#import "YAS2DTexture.h"
#import "YAS2DImage.h"
#import "YAS2DTouch.h"
#import "YASSWButtonNode.h"
#import "YASSWTimeNode.h"
#import "YASSWLineCircleNode.h"
#import "YASSWCircleButtonNode.h"
#import "YAS2DAction.h"
#import "YASSWTimeController.h"
#import "YASSWState.h"
#import "YAS2DBlurNode.h"

typedef NS_ENUM(NSUInteger, YASSWSubCircleTitle) {
    YASSWSubCircleTitleReset,
    YASSWSubCircleTitleSplit,
    YASSWSubCircleTitleCountdown,
    YASSWSubCircleTitleDisable,
    YASSWSubCircleTitleCount,
};

@interface YASSWViewController () <YASSWTimeControllerDelegate>

@property (nonatomic) YASSWTimeController *controller;
@property (nonatomic) YAS2DRenderer *renderer;
@property (nonatomic) YAS2DTexture *texture;

@property (nonatomic) YASSWButtonNode *clearNode;
@property (nonatomic) YASSWTimeNode *timeNode;
@property (nonatomic) YAS2DBlurNode *timeBlurNode;
@property (nonatomic) YAS2DStringsNode *countdownTimeNode;
@property (nonatomic) YASSWTimeNode *splitTimeNode;
@property (nonatomic) YAS2DStringsNode *splitCountNode;
@property (nonatomic) YASSWLineCircleNode *secondsCircleNode;
@property (nonatomic) YASSWLineCircleNode *minutesCircleNode;
@property (nonatomic) YASSWCircleButtonNode *subCircleNode;
@property (nonatomic) YASSWCircleButtonNode *nextButtonNode;
@property (nonatomic) YASSWCircleButtonNode *backButtonNode;
@property (nonatomic) YAS2DBlurNode *nextBlurNode;
@property (nonatomic) YAS2DBlurNode *backBlurNode;

@end

@implementation YASSWViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (void)initCommon
{
    self.controller = [[YASSWTimeController alloc] initWithDelegate:self];
}

- (void)dealloc
{
    [self stopRender];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.renderer = [[YAS2DRenderer alloc] initWithView:(YASMetalView *)self.view];
    
    [self setupNodes];
    [self startRender];
}

- (void)setupNodes
{
    YASSWTimeController *controller = self.controller;
    
    CGSize viewSize = self.view.bounds.size;
    CGFloat viewWidth = MIN(viewSize.width, viewSize.height);
    CGFloat halfViewWidth = viewWidth * 0.5;
    float sizeRate = viewWidth / 768.0;
    NSUInteger secondsRadius = halfViewWidth - 30 * sizeRate;
    NSUInteger minutesRadius = secondsRadius * 0.8;
    
    YAS2DNode *rootNode = self.renderer.rootNode;
    
    CGFloat clearRadius = sqrtf(powf(viewSize.width, 2) + powf(viewSize.height, 2));
    YASSWButtonNode *clearNode = [[YASSWButtonNode alloc] initWithFrame:CGRectMake(- clearRadius, - clearRadius, clearRadius * 2.0, clearRadius * 2.0)];
    clearNode.baseColor = 0.0f;
    clearNode.touch.touchType = YAS2DTouchTypeSquare;
    clearNode.touchEnded = ^{
        [controller main];
    };
    [rootNode addSubNode:clearNode];
    self.clearNode = clearNode;
    
    MTLSize textureSize = MTLSizeMake(1024, 1024, 1);
    
    YAS2DTexture *texture = [[YAS2DTexture alloc] initWithPointSize:textureSize scaleFactor:self.view.contentScaleFactor];
    self.texture = texture;
    [texture setupMetalBuffer:self.renderer.device];
    
    // blur node
    
    NSInteger timeBlurTextureWidth = 400;
    NSInteger timeBlurTextureHeight = 400 * 0.6f;
    float timeBlurWRadius = ceilf(timeBlurTextureWidth * 0.5f * sizeRate);
    float timeBlurHRadius = ceilf(timeBlurTextureHeight * 0.5f * sizeRate);
    float2 offset = (float2){0.0f, 90.0f * sizeRate};
    CGRect timeBlurFrame = CGRectMake(-timeBlurWRadius + offset.x, -timeBlurHRadius + offset.y, timeBlurWRadius * 2, timeBlurHRadius * 2);
    MTLSize timeBlurTextureSize = MTLSizeMake(timeBlurTextureWidth, timeBlurTextureHeight, 1);
    YAS2DBlurNode *timeBlurNode = [[YAS2DBlurNode alloc] initWithFrame:timeBlurFrame textureSize:timeBlurTextureSize];
    self.timeBlurNode = timeBlurNode;
    [rootNode addSubNode:timeBlurNode];
    
    // sub circle node
    
    YASSWCircleButtonNode *subCircleNode = [[YASSWCircleButtonNode alloc] initWithRadius:ceilf(100.0f * sizeRate) 
                                                                                 texture:texture 
                                                                                  titles:@[@"RESET", 
                                                                                           @"SPLIT", 
                                                                                           @"COUNT\nDOWN",
                                                                                           @""]
                                                                                fontSize:26.0 * sizeRate
                                                                               lineWidth:sizeRate];
    subCircleNode.position = (float2){0.0f, -roundf(140.0f * sizeRate)};
    [rootNode addSubNode:subCircleNode];
    self.subCircleNode = subCircleNode;
    self.subCircleNode.touchEnded = ^{
        [controller sub];
    };
    
    [self updateSubCircleNode];
    
    // circle nodes
    
    YASSWCircleDescription *circleDescription = [[YASSWCircleDescription alloc] init];
    circleDescription.fatLineColor = 1.0f;
    circleDescription.thinLineColor = 0.75f;
    circleDescription.fatLineSize = CGSizeMake((float)secondsRadius / 260, (float)secondsRadius / 50);
    circleDescription.thinLineSize = CGSizeMake((float)secondsRadius / 380, (float)secondsRadius / 60);
    circleDescription.numberFontSize = 18.0 * sizeRate;
    circleDescription.needleSize = MTLSizeMake(ceilf((float)secondsRadius / 80), ceilf((float)secondsRadius / 30), 1);
    circleDescription.strokeNeedleLineWidth = 1.0f * sizeRate;
    
    // sec circle node
    
    circleDescription.lineRadius = secondsRadius;
    circleDescription.thinDivideCount = 10;
    circleDescription.numberRadius = secondsRadius - 23 * sizeRate;
    circleDescription.needleRadius = secondsRadius + 6 * sizeRate;
    circleDescription.needleColor = (float4){0.0f, 1.0f, 0.0f, 1.0f};
    
    YASSWLineCircleNode *secondsCircleNode = [[YASSWLineCircleNode alloc] initWithCircleDescription:circleDescription texture:texture];
    [rootNode addSubNode:secondsCircleNode];
    self.secondsCircleNode = secondsCircleNode;
    
    // min circle node
    
    circleDescription.lineRadius = minutesRadius;
    circleDescription.thinDivideCount = 6;
    circleDescription.numberRadius = minutesRadius + 10 * sizeRate;
    circleDescription.needleRadius = minutesRadius - 6 * sizeRate;
    circleDescription.needleColor = (float4){1.0f, 0.0f, 0.0f, 1.0f};
    circleDescription.needleAngle = 180.0f;
    circleDescription.strokeNeedleAngle = 180.0f;
    
    YASSWLineCircleNode *minutesCircleNode = [[YASSWLineCircleNode alloc] initWithCircleDescription:circleDescription texture:texture];
    [rootNode addSubNode:minutesCircleNode];
    self.minutesCircleNode = minutesCircleNode;
    
    // time node
    
    YASSWTimeNode *timeNode = [[YASSWTimeNode alloc] initWithTexture:texture fontName:@"HelveticaNeue-Thin" fontSize:ceilf(76.0f * sizeRate)];
    timeNode.position = (float2){0.0f, roundf(110.0f * sizeRate)};
    self.timeNode = timeNode;
    [timeBlurNode addSubNode:timeNode];
    
    // split time node
    
    YASSWTimeNode *splitTimeNode = [[YASSWTimeNode alloc] initWithTexture:texture fontName:@"HelveticaNeue-Thin" fontSize:ceilf(36.0f * sizeRate)];
    splitTimeNode.position = (float2){0.0f, roundf(30.0f * sizeRate)};
    splitTimeNode.color = (float4){1.0f, 0.6f, 0.0f, 1.0f};
    self.splitTimeNode = splitTimeNode;
    [timeBlurNode addSubNode:splitTimeNode];
    
    // split count node
    
    YAS2DStringsData *stringsData = [[YAS2DStringsData alloc] initWithFontName:@"HelveticaNeue-Thin" fontSize:ceilf(24.0f * sizeRate) words:@"0123456789/" texture:texture];
    YAS2DStringsNode *splitCountNode = [[YAS2DStringsNode alloc] initWithStringsData:stringsData];
    splitCountNode.pivot = YAS2DStringsPivotCenter;
    splitCountNode.color = (float4){1.0f, 0.6f, 0.0f, 1.0f};
    self.splitCountNode = splitCountNode;
    [timeBlurNode addSubNode:splitCountNode];
    
    // countdown time node
    
    YAS2DStringsData *countdownStringsData = [[YAS2DStringsData alloc] initWithFontName:@"HelveticaNeue-Thin" fontSize:ceilf(120.0f * sizeRate) words:@"0123456789" texture:texture];
    YAS2DStringsNode *countdownTimeNode = [[YAS2DStringsNode alloc] initWithStringsData:countdownStringsData];
    countdownTimeNode.position = (float2){0.0f, roundf(100.0f * sizeRate)};
    countdownTimeNode.pivot = YAS2DStringsPivotCenter;
    self.countdownTimeNode = countdownTimeNode;
    [rootNode addSubNode:countdownTimeNode];
    
    // next node
    
    NSInteger splitButtonWidth = 60;
    float splitButtonEdgeOffset = 70.0f * sizeRate;
    NSInteger splitButtonRadius = ceilf(splitButtonWidth * sizeRate);
    NSInteger blurRadius = ceilf(splitButtonRadius * 1.5);
    CGRect blurFrame = CGRectMake(-blurRadius, -blurRadius, blurRadius * 2, blurRadius * 2);
    MTLSize blurTextureSize = MTLSizeMake(splitButtonWidth * 1.5 * 2, splitButtonWidth * 1.5 * 2, 1);
    
    YASSWCircleButtonNode *nextButtonNode = [[YASSWCircleButtonNode alloc] initWithRadius:splitButtonRadius texture:texture titles:@[@"NEXT"] fontSize:26.0 * sizeRate lineWidth:sizeRate];
    self.nextButtonNode = nextButtonNode;
    nextButtonNode.touchEnded = ^{
        [controller next];
    };
    
    YAS2DBlurNode *nextBlurNode = [[YAS2DBlurNode alloc] initWithFrame:blurFrame textureSize:blurTextureSize];
    nextBlurNode.position = (float2){roundf(halfViewWidth - splitButtonEdgeOffset), -roundf(halfViewWidth - splitButtonEdgeOffset)};
    nextBlurNode.coef = 1.0f;
    [rootNode addSubNode:nextBlurNode];
    [nextBlurNode addSubNode:nextButtonNode];
    self.nextBlurNode = nextBlurNode;
    
    // back node
    
    YASSWCircleButtonNode *backButtonNode = [[YASSWCircleButtonNode alloc] initWithRadius:splitButtonRadius texture:texture titles:@[@"BACK"] fontSize:26.0 * sizeRate lineWidth:sizeRate];
    self.backButtonNode = backButtonNode;
    backButtonNode.touchEnded = ^{
        [controller back];
    };
    
    YAS2DBlurNode *backBlurNode = [[YAS2DBlurNode alloc] initWithFrame:blurFrame textureSize:blurTextureSize];
    backBlurNode.position = (float2){-roundf(halfViewWidth - splitButtonEdgeOffset), -roundf(halfViewWidth - splitButtonEdgeOffset)};
    backBlurNode.coef = 1.0f;
    [rootNode addSubNode:backBlurNode];
    [backBlurNode addSubNode:backButtonNode];
    self.backBlurNode = backBlurNode;
    
    [self updateNextAndBackButtonsWithAnimation:NO];
    [self updateTimeNodeWithAnimation:NO];
    [self updateCountdownTimeNodeWithAnimation:NO];
    [self timeControllerDidChangeLap:self.controller];
    
    [self.renderer setupMetalBuffer];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark -

- (void)updateSubCircleNode
{
    Class state = [self.controller.state class];
    BOOL enabled = YES;
    
    if ([state isSubclassOfClass:[YASSWZeroState class]]) {
        self.subCircleNode.titleIndex = YASSWSubCircleTitleCountdown;
    } else if ([state isSubclassOfClass:[YASSWCountdownState class]]) {
        self.subCircleNode.titleIndex = YASSWSubCircleTitleReset;
    } else if ([state isSubclassOfClass:[YASSWPlayState class]]) {
        if (self.controller.time < 0) {
            self.subCircleNode.titleIndex = YASSWSubCircleTitleDisable;
            enabled = NO;
        } else {
            self.subCircleNode.titleIndex = YASSWSubCircleTitleSplit;
        }
    } else if ([state isSubclassOfClass:[YASSWStopState class]]) {
        self.subCircleNode.titleIndex = YASSWSubCircleTitleReset;
    }
    
    self.subCircleNode.enabled = enabled;
}

- (void)updateTimeNodeWithAnimation:(BOOL)anim
{
    const BOOL blurEnabled = self.controller.time < 0;
    const float coef = blurEnabled ? 12.0f : 1.0f;
    const float duration = 0.2f;
    
    if (anim) {
        [self.renderer removeActionForTarget:self.timeBlurNode];
        
        YAS2DBlurAction *blurAction = [[YAS2DBlurAction alloc] init];
        blurAction.duration = duration;
        blurAction.target = self.timeBlurNode;
        blurAction.startCoef = self.timeBlurNode.coef;
        blurAction.endCoef = coef;
        [self.renderer addAction:blurAction];
    } else {
        self.timeBlurNode.coef = coef;
    }
}

- (void)updateCountdownTimeNodeWithAnimation:(BOOL)anim
{
    BOOL enabled = self.controller.time < 0;
    float alpha = enabled ? 1.0f : 0.0f;
    const float duration = 0.3f;
    
    if (anim) {
        [self.renderer removeActionForTarget:self.countdownTimeNode];
        
        YAS2DColorAction *colorAction = [[YAS2DColorAction alloc] init];
        colorAction.duration = duration;
        colorAction.target = self.countdownTimeNode;
        colorAction.curve = enabled ? YAS2DActionCurveEaseOut : YAS2DActionCurveEaseIn;
        colorAction.startColor = self.countdownTimeNode.color;
        colorAction.endColor = alpha;
        
        [self.renderer addAction:colorAction];
    } else {
        self.countdownTimeNode.color = alpha;
    }
}

- (void)updateNextAndBackButtonsWithAnimation:(BOOL)anim
{
    const BOOL enabled = [self.controller.state isKindOfClass:[YASSWStopState class]] && self.controller.time > 0;
    const float coef = enabled ? 1.0f : 15.0f;
    const float duration = 0.3f;
    
    for (YAS2DBlurNode *node in @[self.backBlurNode, self.nextBlurNode]) {
        [self.renderer removeActionForTarget:node];
        if (anim) {
            YAS2DBlurAction *blurAction = [[YAS2DBlurAction alloc] init];
            blurAction.duration = duration;
            blurAction.target = node;
            blurAction.startCoef = node.coef;
            blurAction.endCoef = coef;
            [self.renderer addAction:blurAction];
        } else {
            node.coef = coef;
        }
    }
    
    for (YASSWButtonNode *node in @[self.backButtonNode, self.nextButtonNode]) {
        node.touch.enabled = enabled;
    }
}

#pragma mark - YASMetalViewController SubClass

- (void)viewWillRender
{
    NSTimeInterval time = self.controller.time;
    
    self.timeNode.time = time;
    float secAngle = fmod(time / 60.0, 1.0) * 360.0;
    [self.secondsCircleNode setCircleAngle:secAngle withAnimation:NO];
    [self.secondsCircleNode setNeedleAngle:- secAngle withAnimation:NO];
    float minAngle = fmod(time / 3600.0, 1.0) * 360.0;
    [self.minutesCircleNode setCircleAngle:minAngle withAnimation:NO];
    [self.minutesCircleNode setNeedleAngle:- minAngle withAnimation:NO];
    
    if (time < 0.0) {
        NSInteger countdownTime = ceil(fabs(self.controller.time));
        self.countdownTimeNode.text = @(countdownTime % 60).stringValue;
    } else {
        self.countdownTimeNode.text = @"0";
    }
}

#pragma mark - YASSWTimeControllerDelegate

- (void)timeController:(YASSWTimeController *)controller didChangeStateFrom:(Class)fromState
{
    Class toState = [controller.state class];
    
    if ([toState isSubclassOfClass:[YASSWZeroState class]]) {
        [self.secondsCircleNode setCircleAngle:0.0f withAnimation:YES];
        [self.minutesCircleNode setCircleAngle:0.0f withAnimation:YES];
        [self.secondsCircleNode setNeedleAngle:0.0f withAnimation:YES];
        [self.minutesCircleNode setNeedleAngle:0.0f withAnimation:YES];
    } else if ([toState isSubclassOfClass:[YASSWCountdownState class]]) {
        NSTimeInterval time = controller.countdownTime;
        float secAngle = fmod(time / 60.0, 1.0) * 360.0;
        float minAngle = fmod(time / 3600.0, 1.0) * 360.0;
        [self.secondsCircleNode setCircleAngle:secAngle withAnimation:YES];
        [self.minutesCircleNode setCircleAngle:minAngle withAnimation:YES];
        [self.secondsCircleNode setNeedleAngle:-secAngle withAnimation:YES];
        [self.minutesCircleNode setNeedleAngle:-minAngle withAnimation:YES];
    } else if ([toState isSubclassOfClass:[YASSWPlayState class]]) {
        [self.renderer removeActionForTarget:self.backBlurNode];
        [self.renderer removeActionForTarget:self.nextBlurNode];
    } else if ([toState isSubclassOfClass:[YASSWStopState class]]) {
        [self.renderer removeActionForTarget:self.backBlurNode];
        [self.renderer removeActionForTarget:self.nextBlurNode];
    }
    
    [self updateSubCircleNode];
    [self.subCircleNode rotate];
    [self updateNextAndBackButtonsWithAnimation:YES];
    [self updateTimeNodeWithAnimation:YES];
    [self updateCountdownTimeNodeWithAnimation:YES];
}

- (void)timeControllerDidChangeLap:(YASSWTimeController *)controller
{
    NSNumber *currentLap = controller.laps[controller.lapIndex];
    NSTimeInterval time = currentLap.doubleValue;
    self.splitTimeNode.time = time;
    
    self.splitCountNode.text = [[NSString alloc] initWithFormat:@"%@ / %@", @(controller.lapIndex), @(controller.laps.count - 1)];
    
    float secAngle = fmod(time / 60.0, 1.0) * 360.0;
    [self.secondsCircleNode setStrokeNeedleAngle:- secAngle withAnimation:YES];
    float minAngle = fmod(time / 3600.0, 1.0) * 360.0;
    [self.minutesCircleNode setStrokeNeedleAngle:- minAngle withAnimation:YES];
}

- (void)timeControllerDidOverZero:(YASSWTimeController *)controller
{
    [self updateSubCircleNode];
    [self.subCircleNode rotate];
    [self updateTimeNodeWithAnimation:YES];
    [self updateCountdownTimeNodeWithAnimation:YES];
}

@end
