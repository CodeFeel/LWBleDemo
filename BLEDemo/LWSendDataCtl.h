//
//  LWSendDataCtl.h
//  BLEDemo
//
//  Created by ios on 2017/7/3.
//  Copyright © 2017年 swiftHPRT. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^Sendbledatas)(NSString *sendStr);

@interface LWSendDataCtl : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *sendTF;

@property(copy,nonatomic,readwrite) Sendbledatas sendBlock;

@end
