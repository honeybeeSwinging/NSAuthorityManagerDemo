//
//  ViewController.m
//  NSAuthorityManagerDemo
//
//  Created by BANYAN on 2017/5/21.
//  Copyright © 2017年 GREEN BANYAN. All rights reserved.
//

#import "ViewController.h"
#import "NSAuthorityManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self authorityPromopt];
    });
}

-(void)authorityPromopt{
    CGFloat marin = 20;
    NSArray *titleArray = @[@"开启相机权限",@"开启相册权限",@"开启媒体资料库",@"开启通讯录权限"];
    
    for (NSInteger i = 0; i < titleArray.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(100, 150 + (marin + 50) * i, self.view.frame.size.width - 200, 50);
        [button setTitle:titleArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor lightGrayColor]];
        button.tag = i;
        [button addTarget:self action:@selector(buttonTarget:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

-(void)buttonTarget:(UIButton *)button{
    switch (button.tag) {
        case 0:{
            if ([NSAuthorityManager isObtainAVVideoAuthority]) {
                NSLog(@"已经开启相机权限");
            }else{
                [[NSAuthorityManager sharedInstance]obtainAVMediaVideoAuthorizedStatus];
            }
        }break;
            
        case 1:{
            if ([NSAuthorityManager isObtainPhPhotoAuthority]) {
                NSLog(@"已经开启相机权限");
            }else{
                [[NSAuthorityManager sharedInstance]obtainPHPhotoAuthorizedStaus];
            }
        }break;
            
        case 2:{
            if ([NSAuthorityManager isObtainMediaAuthority]) {
                NSLog(@"已经开启相机权限");
            }else{
                [[NSAuthorityManager sharedInstance]obtainMPMediaAuthorizedStatus];
            }
        }break;
            
        case 3:{
            if ([NSAuthorityManager isObtainCNContactAuthority]) {
                NSLog(@"已经开启相机权限");
            }else{
                [[NSAuthorityManager sharedInstance]obtainCNContactAuthorizedStatus
                 ];
            }
        }break;
            
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
