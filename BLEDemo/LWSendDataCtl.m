//
//  LWSendDataCtl.m
//  BLEDemo
//
//  Created by ios on 2017/7/3.
//  Copyright © 2017年 swiftHPRT. All rights reserved.
//

#import "LWSendDataCtl.h"

@interface LWSendDataCtl ()



@end

@implementation LWSendDataCtl

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    
    
    
    
}

- (IBAction)sendData:(id)sender {
    
    [self.view endEditing:YES];
    if (self.sendBlock) {
          //走纸命令
//        NSData *data = [NSData dataWithBytes:@"\x0d\x0a" length:2];
        self.sendBlock(self.sendTF.text);
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
