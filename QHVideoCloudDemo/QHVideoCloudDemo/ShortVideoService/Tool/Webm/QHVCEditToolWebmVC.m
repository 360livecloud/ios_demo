//
//  QHVCEditToolWebmVC.m
//  QHVideoCloudEdit
//
//  Created by liyue-g on 2019/4/24.
//  Copyright © 2019 yangkui. All rights reserved.
//

#import "QHVCEditToolWebmVC.h"
#import "QHVCShortVideoToolTableCell.h"
#import "UIView+Toast.h"
#import <QHVCEditKit/QHVCEditKit.h>
#import "QHVCShortVideoMacroDefs.h"

static NSString *const itemCellIdentifier = @"QHVCShortVideoToolTableCell";

@interface QHVCEditToolWebmVC ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *urlView;
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;

@property (nonatomic, retain) NSString* outputPath;
@property (atomic,    assign) BOOL stopRunning;
@property (atomic,    assign) NSInteger runningIndex;
@property (nonatomic, retain) NSArray* dataSource;
@property (nonatomic, retain) CIContext* context;
@property (nonatomic, retain) QHVCEditWebmProducer* producer;
@property (nonatomic, retain) QHVCShortVideoToolTableCell* runningCell;

@end

@implementation QHVCEditToolWebmVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTitle:@"webm合成"];
    [self.nextBtn setHidden:YES];
    [self.tableViewTopConstraint setConstant:[self topBarHeight]];
    
    NSMutableArray* array1 = [NSMutableArray array];
    for (int i = 0; i <= 50; i++)
    {
        NSString* index = [NSString stringWithFormat:@"%d", i];
        if (i < 10)
        {
            index = [@"0" stringByAppendingString:index];
        }
        NSString* name = [NSString stringWithFormat:@"铲屎官_000%@", index];
        [array1 addObject:name];
    }
    
    [_tableView registerNib:[UINib nibWithNibName:itemCellIdentifier bundle:nil] forCellReuseIdentifier:itemCellIdentifier];
    _dataSource = @[@{@"name":@"铲屎官", @"data":array1}];
    self.runningIndex = -1;
    self.stopRunning = NO;
    self.runningCell = nil;
}

- (IBAction)onUrlViewCloseAction:(id)sender
{
    [self.urlView setHidden:YES];
}


#pragma mark - TableView Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QHVCShortVideoToolTableCell *cell = [tableView dequeueReusableCellWithIdentifier:itemCellIdentifier];
    NSDictionary* item = [_dataSource objectAtIndex:indexPath.row];
    NSString* title = [item objectForKey:@"name"];
    [cell setCellTitle:title];
    [cell setStateButtonTitle:(self.runningIndex != indexPath.row) ? @"开始":@"停止"];
    
    WEAK_SELF
    __weak typeof(cell) weakCell = cell;
    [cell setStateChangedAction:^{
        STRONG_SELF
        [self updateCellState:indexPath.row cell:weakCell];
    }];
    
    return cell;
}

- (void)updateCellState:(NSInteger)index cell:(QHVCShortVideoToolTableCell *)cell
{
    if (self.runningIndex == -1)
    {
        //开始合成
        self.stopRunning = NO;
        self.runningCell = cell;
        self.runningIndex = index;
        [self startProducer];
        
        __weak typeof(cell) weakCell = cell;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakCell setStateButtonTitle:@"停止"];
        });
    }
    else if (self.runningIndex == index)
    {
        //停止合成
        self.stopRunning = YES;
        self.runningCell = nil;
        self.runningIndex = -1;
        
        __weak typeof(cell) weakCell = cell;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakCell setStateButtonTitle:@"开始"];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view makeToast:@"开始合成前请先停止其他合成任务"];
        });
    }
}

- (void)showUrlView
{
    WEAK_SELF
    dispatch_async(dispatch_get_main_queue(), ^{
        STRONG_SELF
        [self.urlView setHidden:NO];
        [self.urlTextView setText:self.outputPath];
    });
}

#pragma mark - Edit Methods

- (void)startProducer
{
    WEAK_SELF
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        STRONG_SELF
        if (!self.producer)
        {
            self.producer = [QHVCEditWebmProducer new];
            [self.producer setOutputWidth:400];
            [self.producer setOutputHeight:400];
        }
        
        self.outputPath = [NSTemporaryDirectory() stringByAppendingString:@"output.webm"];
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:self.outputPath])
        {
            [fileMgr removeItemAtPath:self.outputPath error:nil];
        }
        [self.producer startWithOutputFilePath:self.outputPath];
        
        __block BOOL finish = YES;
        NSArray* data = [[self.dataSource objectAtIndex:self.runningIndex] objectForKey:@"data"];
        [data enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             if (self.stopRunning)
             {
                 [self.producer stop];
                 finish = NO;
                 *stop = YES;
             }
             
             [self sendDataOfName:obj index:idx];
         }];
        
        if (finish)
        {
            //合成完成
            [self updateCellState:self.runningIndex cell:self.runningCell];
            [self.producer stop];
            [self showUrlView];
        }
    });
}

- (void)sendDataOfName:(NSString *)name index:(NSInteger)index
{
    UIImage* image = [UIImage imageNamed:name];
    CIImage* ciImage = [CIImage imageWithCGImage:image.CGImage];
    
    if (!self.context)
    {
        self.context = [CIContext contextWithOptions:nil];
    }
    
    NSInteger width = CGRectGetWidth(ciImage.extent);
    NSInteger height = CGRectGetHeight(ciImage.extent);
    NSInteger len = width * height * 4;
    void* buffer = (void *)malloc(len);
    memset(buffer, 0, len);
    [self.context render:ciImage
                toBitmap:buffer
                rowBytes:width * 4
                  bounds:ciImage.extent
                  format:kCIFormatRGBA8
              colorSpace:NULL];
    
    NSData* data = [[NSData alloc] initWithBytes:buffer length:len];
    QHVCEditWebmFrame* frame = [QHVCEditWebmFrame new];
    frame.data = data;
    frame.width = width;
    frame.height = height;
    frame.pts = index * 40; //25fps
    [self.producer sendFrame:frame];
    free(buffer);
}

@end
