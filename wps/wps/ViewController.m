//
//  ViewController.m
//  SocketB
//
//  Created by 於林涛 on 8/18/16.
//  Copyright © 2016 jft0m. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocket.h"

static CGFloat const width = 300;
static CGFloat const height = 100;

@interface ViewController ()<GCDAsyncSocketDelegate>
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) GCDAsyncSocket *connectedSocket;
@property (nonatomic, strong) UIView *picView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor redColor];
    self.label = [UILabel new];
    self.label.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.label];
    self.label.frame = CGRectMake((self.view.frame.size.width - width) /2, (self.view.frame.size.height - height) /2, width, height);
    
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
    NSError *error = nil;

    [self.socket acceptOnPort:11111 error:&error];
}

- (UIView *)picView {
    if (!_picView) {
        _picView = [UIView new];
        _picView.backgroundColor = [UIColor greenColor];
        [self.view addSubview:_picView];
    }
    return _picView;
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.label.frame = CGRectMake((self.view.frame.size.width - width) /2, (self.view.frame.size.height - height) /2, width, height);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"wps didConnectToHost");
}
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"wps didAcceptNewSocket");
    self.connectedSocket = newSocket;
    [self.connectedSocket readDataWithTimeout:-1 tag:1000];
}
- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    
    NSDictionary *dic = [self decodeData:data];
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect rect = ((NSValue *)dic[@"rect"]).CGRectValue;
        rect = [self viewRect:rect];
        self.label.text = [NSString stringWithFormat:@"x:%lf,y:%lf",rect.origin.x,rect.origin.y];
        self.picView.frame = rect;
    });
    
    [self.connectedSocket readDataWithTimeout:-1 tag:1000];
}

- (NSDictionary *)decodeData:(NSData *)data {
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    NSDictionary *dic = [unarchiver decodeObjectForKey:@"ViewInfo"];
    [unarchiver finishDecoding];
    return dic;
}
- (CGRect)viewRect:(CGRect)rectInScreen {
    CGRect rect = CGRectZero;
    rect.size = rectInScreen.size;
    rect.origin.y = rectInScreen.origin.y;
    if ([self isLeft]) {
        rect.origin.x = rectInScreen.origin.x;
    }else{
        rect.origin.x = rectInScreen.origin.x - [UIScreen mainScreen].bounds.size.width + self.view.frame.size.width;
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
