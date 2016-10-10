//
//  ViewController.m
//  QQ
//
//  Created by 於林涛 on 8/18/16.
//  Copyright © 2016 jft0m. All rights reserved.
//


#import "ViewController.h"
#import "GCDAsyncSocket.h"

static CGFloat const width = 300;
static CGFloat const height = 100;
@interface ViewController ()<UIGestureRecognizerDelegate, GCDAsyncSocketDelegate>
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) GCDAsyncSocket *connectedSocket;
@property (nonatomic, strong) UIView *picView;
@property (nonatomic, strong) NSMutableDictionary *viewInfo;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewInfo = @{}.mutableCopy;
    self.label = [UILabel new];
    
    self.label.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.label];
    self.label.frame = CGRectMake((self.view.frame.size.width - width) /2, (self.view.frame.size.height - height) /2, width, height);
    UILongPressGestureRecognizer *longPress = [UILongPressGestureRecognizer new];
    [longPress addTarget:self action:@selector(gesture:)];
    [self.view addGestureRecognizer:longPress];
    
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
    NSError *error = nil;
    [self.socket connectToHost:@"localhost" onPort:11111 error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.label.frame = CGRectMake((self.view.frame.size.width - width) /2, (self.view.frame.size.height - height) /2, width, height);
    
}
- (UIView *)picView {
    if (!_picView) {
        _picView = [UIView new];
        _picView.backgroundColor = [UIColor greenColor];
        [self.view addSubview:_picView];
    }
    return _picView;
}
- (void)gesture:(UILongPressGestureRecognizer *)gesture {
    
    CGPoint point = [gesture locationInView:self.view];
    
    if (gesture.state == UIGestureRecognizerStateEnded ) {
        self.picView.hidden = YES;
        return;
    } else if (gesture.state == UIGestureRecognizerStateBegan ) {
        self.picView.hidden = NO;
        [self.view bringSubviewToFront:self.picView];
        self.picView.frame = CGRectMake(point.x - self.picView.frame.size.width / 2, (self.view.frame.size.height - height) /2, width, height);
    }
    
    
    CGRect picRect = [self rectConvertor:self.picView];
//    NSLog(@"%@",[NSValue valueWithCGRect:picRect]);
    self.label.text = [NSString stringWithFormat:@"x:%lf,y:%lf",picRect.origin.x,picRect.origin.y];
    
    self.picView.center = point;
    
    self.viewInfo[@"rect"] = [NSValue valueWithCGRect:picRect];
    [self.socket writeData:[self dicToData:self.viewInfo] withTimeout:-1 tag:1000];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    return;
}
- (NSData *)dicToData:(NSDictionary *)dic {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:dic forKey:@"ViewInfo"];
    [archiver finishEncoding];
    return data;
}
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"QQ didAcceptNewSocket");
    self.connectedSocket = newSocket;

}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    CGPoint point;
    [data getBytes:&point length:sizeof(point)];
    self.label.text = [NSString stringWithFormat:@"x:%lf,y:%lf",point.x,point.y];
    
}

- (CGRect)rectConvertor:(UIView *)view {
    CGRect rect = CGRectZero;
    rect.size = view.frame.size;
    rect.origin.y = view.frame.origin.y;
    if ([self isLeft]) {
        rect.origin.x = view.frame.origin.x;
    }else{
        rect.origin.x = [UIScreen mainScreen].bounds.size.width - self.view.frame.size.width + view.frame.origin.x;
    }
    return rect;
}
- (BOOL)isLeft {
    CGRect rect =  [self.view convertRect:self.view.frame toCoordinateSpace:[UIScreen mainScreen].coordinateSpace];
    if (rect.origin.x > 0) {
        return NO;
    }else{
        return YES;
    }
}


@end
