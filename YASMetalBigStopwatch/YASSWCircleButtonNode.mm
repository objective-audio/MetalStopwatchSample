//
//  YASSWCircleButtonNode.m
//
//  Copyright (c) 2014 Yuki Yasoshima.
//  This software is released under the MIT License.
//

#import "YASSWCircleButtonNode.h"
#import "YAS2DSquareNode.h"
#import "YAS2DImage.h"
#import "YAS2DTouch.h"
#import "YAS2DTexture.h"
#import "YAS2DAction.h"
#import "YAS2DRenderer.h"
#import <UIKit/UIKit.h>

@interface YASSWCircleButtonNode ()

@property (nonatomic) YAS2DSquareNode *titleNode;

@end

@implementation YASSWCircleButtonNode

- (instancetype)initWithRadius:(float)radius texture:(YAS2DTexture *)texture titles:(NSArray *)titles fontSize:(CGFloat)fontSize lineWidth:(CGFloat)lineWidth
{
    self = [super initWithFrame:CGRectMake(-radius, -radius, radius * 2.0, radius * 2.0)];
    if (self) {
        _radius = radius;
        
        self.baseNode.mesh.texture = texture;
        self.selectedNode.mesh.texture = texture;
        self.flashNode.mesh.texture = texture;
        
        const CGRect buttonFrame = self.frame;
        CGRect circleFrame = buttonFrame;
        circleFrame.origin = CGPointZero;
        circleFrame = CGRectInset(circleFrame, lineWidth * 0.5, lineWidth * 0.5);
        
        YAS2DImage *buttonImage = [[YAS2DImage alloc] initWithPointSize:MTLSizeMake(CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame), 1)];
        
        [buttonImage draw:^(CGContextRef context) {
            CGContextSetLineWidth(context, lineWidth);
            CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:0.0 alpha:0.5].CGColor);
            CGContextFillEllipseInRect(context, circleFrame);
            CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextStrokeEllipseInRect(context, circleFrame);
        }];
        
        [self.baseNode.mesh setTexCoordsWithRegion:[texture copyImage:buttonImage] atSquareIndex:0];
        
        [buttonImage clearBuffer];
        [buttonImage draw:^(CGContextRef context) {
            CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
            CGContextFillEllipseInRect(context, circleFrame);
        }];
        
        const MTLRegion region = [texture copyImage:buttonImage];
        [self.selectedNode.mesh setTexCoordsWithRegion:region atSquareIndex:0];
        [self.flashNode.mesh setTexCoordsWithRegion:region atSquareIndex:0];
        
        YAS2DSquareNode *titleNode = [[YAS2DSquareNode alloc] initWithSquareCount:titles.count dynamic:YES];
        titleNode.mesh.texture = texture;
        self.titleNode = titleNode;
        [self addSubNode:titleNode];
        
        for (NSInteger i = 0; i < titles.count; i++) {
            [titleNode.mesh setVertexWithRect:buttonFrame atSquareIndex:i];
            [buttonImage clearBuffer];
            [buttonImage draw:^(CGContextRef context) {
                NSString *title = titles[i];
                if (title) {
                    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:fontSize];
                    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                    paragraphStyle.alignment = NSTextAlignmentCenter;
                    NSDictionary *attributes = @{NSFontAttributeName : font,
                                                 NSParagraphStyleAttributeName : paragraphStyle,
                                                 NSForegroundColorAttributeName : [UIColor whiteColor]};
                    UIGraphicsPushContext(context);
                    
                    CGRect drawRect = [title boundingRectWithSize:circleFrame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
                    drawRect.origin.x = (circleFrame.size.width - drawRect.size.width) * 0.5;
                    drawRect.origin.y = (circleFrame.size.height - drawRect.size.height) * 0.5;
                    
                    [title drawWithRect:drawRect options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
                    UIGraphicsPopContext();
                }
            }];
            [titleNode.mesh setTexCoordsWithRegion:[texture copyImage:buttonImage] atSquareIndex:i];
        }
        
        self.titleNode.mesh.indexCount = 6;
        self.titleIndex = 0;
    }
    return self;
}

- (void)setTitleIndex:(NSUInteger)titleIndex
{
    _titleIndex = titleIndex;
    
    [self.titleNode.mesh setSquareIndex:titleIndex toElementIndex:0];
}

- (void)rotate
{
    [self.renderer removeActionForTarget:self];
    
    YAS2DRotateAction *action = [[YAS2DRotateAction alloc] init];
    action.target = self;
    action.startAngle = 360.0f;
    action.endAngle = 0.0f;
    action.duration = 0.2f;
    action.curve = YAS2DActionCurveEaseOut;
    [self.renderer addAction:action];
}

@end
