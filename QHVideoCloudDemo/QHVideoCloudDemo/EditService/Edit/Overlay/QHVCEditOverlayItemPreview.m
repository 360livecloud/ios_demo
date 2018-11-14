//
//  QHVCEditOverlayItemPreview.m
//  QHVideoCloudToolSet
//
//  Created by liyue-g on 2018/2/28.
//  Copyright © 2018年 yangkui. All rights reserved.
//

#import "QHVCEditOverlayItemPreview.h"
#import "QHVCEditCropRectView.h"
#import "QHVCEditPrefs.h"
#import "QHVCEditCommandManager.h"

#define kCropOffsetScale 0.1
#define kCropMinWidth 50
#define kCropMinHeight 50

@interface QHVCEditOverlayItemPreview ()

@property (nonatomic, readwrite, assign) NSInteger overlayCommandId;
@property (nonatomic, retain) QHVCEditCropRectView* cropImageView;
@property (nonatomic, assign) CGSize cropMaxSize;
@property (nonatomic, assign) CGRect cropRect;
@property (nonatomic, assign) BOOL isCroping;

@property (nonatomic, assign) BOOL addedColorPickerCmd;
@property (nonatomic, retain) UIView* colorPicker;
@property (nonatomic, assign) BOOL isColorPicking;
@property (nonatomic, retain) UIImage* contextImage;
@property (nonatomic, retain) UIColor* curColor;
@property (nonatomic, assign) int threshold;
@property (nonatomic, assign) int extend;

@end

@implementation QHVCEditOverlayItemPreview

- (instancetype)initWithFrame:(CGRect)frame overlayCommandId:(NSInteger)overlayCommandId
{
    if (!(self = [super initWithFrame:frame]))
    {
        return nil;
    }
    
    self.overlayCommandId = overlayCommandId;
    self.backgroundColor = [UIColor clearColor];
    [self initUIParams];
    [self addGesture];
    return self;
}

- (void)initUIParams
{
    if (!self.cropImageView)
    {
        self.cropImageView = [[QHVCEditCropRectView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        [self.cropImageView setHidden:YES];
        [self addSubview:self.cropImageView];
    }
    
    if (!self.colorPicker)
    {
        self.colorPicker = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 12, 12)];
        [self.colorPicker.layer setCornerRadius:6];
        [self.colorPicker.layer setMasksToBounds:YES];
        [self.colorPicker setHidden:YES];
        [self.colorPicker.layer setBorderColor:[QHVCEditPrefs colorHighlight].CGColor];
        [self.colorPicker.layer setBorderWidth:2.0];
        [self addSubview:self.colorPicker];
        
        UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(colorPickerMoveGesture:)];
        [self.colorPicker addGestureRecognizer:moveGesture];
    }
    
//    if (self.overlayCommandId != kMainTrackId)
//    {
//        self.layer.compositingFilter = @"overlayBlendMode";
//    }
}

- (UIView *)overlay
{
    return self;
}

#pragma mark - Main View State

- (void)setRadian:(CGFloat)radian
{
    _radian = radian;
    CGRect rect = self.frame;
    [self setTransform:CGAffineTransformMakeRotation(radian)];
    self.frame = CGRectMake(rect.origin.x, rect.origin.y, self.frame.size.width, self.frame.size.height);
    self.bounds = CGRectMake(0, 0, rect.size.width, rect.size.height);
}

- (void)addGesture
{
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGesture:)];
    [self addGestureRecognizer:rotateGesture];
    
    UIPanGestureRecognizer *moveGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveGesture:)];
    [self addGestureRecognizer:moveGesture];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tapGesture];
}

- (void)removeGesture
{
    
}

- (void)rotateGesture:(UIRotationGestureRecognizer *)recognizer
{
    if (self.isCroping || self.isColorPicking)
    {
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
    {
        _radian += [recognizer rotation];
        [recognizer view].transform = CGAffineTransformRotate([[recognizer view] transform], [recognizer rotation]);
        [recognizer setRotation:0];
        SAFE_BLOCK(self.rotateGestureAction, NO);
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        SAFE_BLOCK(self.rotateGestureAction, YES);
    }
}

-(void)moveGesture:(UIPanGestureRecognizer *)recognizer
{
    if (self.isCroping || self.isColorPicking)
    {
        return;
    }
    
    UIView *piece = [recognizer view];
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:[piece superview]];
        CGFloat halfx = self.frame.size.width/2;
        CGFloat halfy = CGRectGetHeight(self.frame)/2;
        CGFloat x = [piece center].x + translation.x;
        CGFloat y = [piece center].y + translation.y;
        
        if (translation.x < 0)
        {
            //left
            x = MAX(halfx, x);
        }
        else
        {
            //right
            x = MIN(self.superview.bounds.size.width - halfx, x);
        }
        
        if(translation.y < 0)
        {
            //up
            y = MAX(y, halfy);
        }
        else
        {
            //down
            y = MIN(y, self.superview.bounds.size.height - halfy);
        }
        
        [piece setCenter:CGPointMake(x, y)];
        [recognizer setTranslation:CGPointZero inView:[piece superview]];
        SAFE_BLOCK(self.moveGestureAction, NO);
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        SAFE_BLOCK(self.moveGestureAction, YES);
    }
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer
{
    if (self.isCroping || self.isColorPicking)
    {
        return;
    }
    
    UIView *piece = [recognizer view];
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGFloat newW = piece.frame.size.width * [recognizer scale];
        CGFloat newH = piece.frame.size.height * [recognizer scale];
        CGFloat superW = piece.superview.frame.size.width;
        CGFloat superH = piece.superview.frame.size.height;
        if (newW <= superW && newH <= superH)
        {
            [recognizer view].transform = CGAffineTransformScale([[recognizer view] transform], [recognizer scale], [recognizer scale]);
            [recognizer setScale:1];
        }
        
        self.contextImage = [QHVCEditPrefs convertViewToImage:self];
        SAFE_BLOCK(self.pinchGestureAction, NO);
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        SAFE_BLOCK(self.pinchGestureAction, YES);
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer
{
    if (self.isCroping)
    {
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        if (self.tapAction)
        {
            self.tapAction();
        }
    }
}

- (void)setSelect:(BOOL)select
{
    if (select)
    {
        [self.layer setBorderWidth:2.0];
        [self.layer setBorderColor:[UIColor redColor].CGColor];
    }
    else
    {
        [self.layer setBorderWidth:0];
        if (self.isCroping)
        {
            [self setIsCroping:NO];
        }
    }
}

#pragma mark - Corp Methods

- (void)startCrop
{
    self.isCroping = YES;
    self.cropMaxSize = CGSizeMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    [self.cropImageView setFrame:CGRectMake(0, 0, self.cropMaxSize.width, self.cropMaxSize.height)];
    [self.cropImageView setHidden:NO];
    [self bringSubviewToFront:self.cropImageView];
    [self.layer setBorderWidth:0];
    self.cropRect = self.cropImageView.frame;
}

- (void)stopCrop:(BOOL)confirm
{
    self.isCroping = NO;
    [self.cropImageView setHidden:YES];
    if (confirm)
    {
        self.cropRect = self.cropImageView.frame;
        [self setFrame:CGRectMake(CGRectGetMinX(self.frame) + CGRectGetMinX(self.cropImageView.frame),
                                  CGRectGetMinY(self.frame) + CGRectGetMinY(self.cropImageView.frame),
                                  CGRectGetWidth(self.cropImageView.frame),
                                  CGRectGetHeight(self.cropImageView.frame))];
    }
}

- (void)updateCropImageView:(CGRect)rect
{
    [self.cropImageView setFrame:CGRectMake(rect.origin.x, rect.origin.y, CGRectGetWidth(rect), CGRectGetHeight(rect))];
}

#pragma mark - Color Picker Methods

- (void)showColorPicker
{
    if (!self.contextImage)
    {
        self.contextImage = [QHVCEditPrefs convertViewToImage:self];
        self.extend = 0;
        self.threshold = 25;
    }
    
    CGPoint center = self.colorPicker.center;
    self.curColor = [self getPixelColorAtLocation:center];
    [self bringSubviewToFront:self.colorPicker];
    [self.colorPicker setHidden:NO];
    self.isColorPicking = YES;
    [self updateChromakeyCommand];
}

- (void)hideColorPicker
{
    [self.colorPicker setHidden:YES];
    self.isColorPicking = NO;
}

- (void)updateChromakey:(int)threshlod extend:(int)extend
{
    self.threshold = threshlod;
    self.extend = extend;
    [self updateChromakeyCommand];
}

- (void)updateChromakeyCommand
{
    NSString* argb = [QHVCEditPrefs hexStringFromColor:self.curColor];
    if (!self.addedColorPickerCmd)
    {
        [[QHVCEditCommandManager manager] addChromakeyWithColor:argb
                                                      threshold:self.threshold
                                                         extend:self.extend
                                               overlayCommandId:self.overlayCommandId
                                               startTimestampMs:self.startTimestampMs
                                                 endTimestampMs:self.endTimestampMs];
        self.addedColorPickerCmd = YES;
    }
    else
    {
        [[QHVCEditCommandManager manager] updateChromakeyWithColor:argb
                                                         threshold:self.threshold
                                                            extend:self.extend
                                                  overlayCommandId:self.overlayCommandId];
    }
    
    SAFE_BLOCK(self.playerNeedRefreshAction, YES);
}

-(void)colorPickerMoveGesture:(UIPanGestureRecognizer *)recognizer
{
    if (!self.isColorPicking)
    {
        return;
    }
    
    UIView *piece = [recognizer view];
    if ([recognizer state] == UIGestureRecognizerStateBegan || [recognizer state] == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [recognizer translationInView:[piece superview]];
        CGFloat halfx = self.colorPicker.frame.size.width/2;
        CGFloat halfy = CGRectGetHeight(self.colorPicker.frame)/2;
        CGFloat x = [piece center].x + translation.x;
        CGFloat y = [piece center].y + translation.y;
        
        if (translation.x < 0)
        {
            //left
            x = MAX(halfx, x);
        }
        else
        {
            //right
            x = MIN(self.bounds.size.width - halfx, x);
        }
        
        if(translation.y < 0)
        {
            //up
            y = MAX(y, halfy);
        }
        else
        {
            //down
            y = MIN(y, self.bounds.size.height - halfy);
        }
        
        CGPoint newCenter = CGPointMake(x, y);
        [piece setCenter:newCenter];
        [recognizer setTranslation:CGPointZero inView:[piece superview]];
    }
    else if ([recognizer state] == UIGestureRecognizerStateEnded)
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGPoint newCenter = CGPointMake(piece.center.x * scale, piece.center.y * scale);
        self.curColor = [self getPixelColorAtLocation:newCenter];
        [self updateChromakeyCommand];
    }
}

- (UIColor *)getPixelColorAtLocation:(CGPoint)point
{
    UIColor* color = nil;
    CGImageRef inImage = self.contextImage.CGImage;
    
    // Create off screen bitmap context to draw the image into. Format ARGB is 4 bytes for each pixel: Alpa, Red, Green, Blue
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    if (cgctx == NULL) {
        return nil; /* error */
    }
    
    size_t w = CGImageGetWidth(inImage);
    size_t h = CGImageGetHeight(inImage);
    CGRect rect = {{0,0},{w,h}};
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap
    // context.
    unsigned char* data = CGBitmapContextGetData (cgctx);
    if (data != NULL) {
        //offset locates the pixel in the data from x,y.
        //4 for 4 bytes of data per pixel, w is width of one row of data.
        int offset = 4*((w*round(point.y))+round(point.x));
        int alpha =  data[offset];
        int red = data[offset+1];
        int green = data[offset+2];
        int blue = data[offset+3];
        //NSLog(@"offset: %i colors: RGB A %i %i %i  %i",offset,red,green,blue,alpha);
        color = [UIColor colorWithRed:(red/255.0f) green:(green/255.0f) blue:(blue/255.0f) alpha:(alpha/255.0f)];
        
    }
    
    // When finished, release the context
    CGContextRelease(cgctx);
    // Free image data memory for the context
    if (data) { free(data); }
    return color;
}

- (CGContextRef)createARGBBitmapContextFromImage:(CGImageRef)inImage
{
    
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    bitmapBytesPerRow   = (int)(pixelsWide * 4);
    bitmapByteCount     = (int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        fprintf (stderr, "Memory not allocated!");
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,      // bits per component
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
        fprintf (stderr, "Context not created!");
    }
    
    // Make sure and release colorspace before returning
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

@end
