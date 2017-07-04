//
//  ViewController.m
//  BLEDemo
//
//  Created by ios on 2017/6/30.
//  Copyright © 2017年 swiftHPRT. All rights reserved.
//

#import "ViewController.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "LWSendDataCtl.h"

#define UUID_WRITE            @"49535343-8841-43F4-A8D4-ECBE34729BB3"

@interface ViewController ()<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

//中心处理器
@property(strong,nonatomic,readwrite) CBCentralManager *centralManager;
//外设的数据源
@property(strong,nonatomic,readwrite) NSMutableArray *bleDataSources;
//外设
@property(strong,nonatomic,readwrite) CBPeripheral *cbPeripheral;
@property (weak, nonatomic) IBOutlet  UITableView *tableView;
//外设的特征
@property(strong,nonatomic,readwrite) CBCharacteristic *characteristic;
@property(strong,nonatomic,readwrite) NSData *bleDatas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];//创建CBCentralManager对象
    
}

//创建CBCentralManager对象
- (CBCentralManager *)centralManager {
    
    if (!_centralManager) {
        _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return _centralManager;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bleDataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *const identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    CBPeripheral *per = self.bleDataSources[indexPath.row];
    NSLog(@"%@ == %@",per.name,per.identifier.UUIDString);
    if (per.name.length == 0) {
        cell.textLabel.text = @"设备名称 ：Unkonwn";
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"设备名称 ：%@",per.name];
    }
    
    if (per.identifier.UUIDString.length == 0) {
        cell.detailTextLabel.text = @"UUID ：Unkonwn";
    }else{
        cell.detailTextLabel.text = [NSString stringWithFormat:@"UUID ：%@",per.identifier.UUIDString];
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *CBP = self.bleDataSources[indexPath.row];
    _cbPeripheral = CBP;
    [_centralManager connectPeripheral:_cbPeripheral options:nil];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


//开始扫描
- (IBAction)beginScan:(id)sender {
    
    [self scanBluetooth];
    
    
}

- (void)scanBluetooth
{
    NSLog(@"开始扫描蓝牙");
    NSDictionary *optionDic = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [self.centralManager scanForPeripheralsWithServices:nil options:optionDic]; // 将第一个参数设置为nil，Central Manager就会开始寻找所有的服务。
    
}

//断开连接
- (IBAction)disConnect:(id)sender {
    
    //只有当外设已经连接成功后才能断开
    if (_cbPeripheral) {
        [self.centralManager cancelPeripheralConnection:_cbPeripheral];
    }
    
    
}

//懒加载数据
- (NSMutableArray *)bleDataSources
{
    if (!_bleDataSources) {
        _bleDataSources = [NSMutableArray array];
    }
    return _bleDataSources;
}

#pragma mark CBCentralManagerDelegate
//蓝牙打开就会调用，检测蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CBCentralStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CBCentralStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CBCentralStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
            //蓝牙打开，开始扫描。
            [self scanBluetooth];
            break;
        default:
            NSLog(@"蓝牙未工作在正确状态");
            break;
    }
}

//扫描到外设，停止扫描，连接设备(每扫描到一个外设都会调用一次这个函数，若要展示搜索到的蓝牙，可以逐一保存 peripheral 并展示)
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    /*
     一个主设备最多能连7个外设，每个外设最多只能给一个主设备连接,连接成功，失败，断开会进入各自的委托
     接下连接我们的测试设备，如果你没有设备，可以下载一个app叫lightbule的app去模拟一个设备
     找到的设备必须持有它，否则CBCentralManager中也不会保存peripheral，那么CBPeripheralDelegate中的方法也不会被调用！！
     */
    BOOL isExited = NO;
//    self.peripheral = peripheral;
    
    for (CBPeripheral *p in self.bleDataSources) {
        if (p.identifier == peripheral.identifier) {
            isExited = YES;
        }
        
    }
    
    if (!isExited) {
        NSLog(@"isExited == %zd",isExited);
        [self.bleDataSources addObject:peripheral];
        NSLog(@"bleDataSources == %@",self.bleDataSources);
    }
    
    [self.tableView reloadData];
    
}

//连接外设成功，扫描外设中的服务和特征
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    
    NSLog(@"已经连接外设 didConnectPeripheral");
    _cbPeripheral = peripheral;
    _cbPeripheral.delegate = self;
    
    //连接成功后停止扫描
    [self.centralManager stopScan];
    
    [peripheral discoverServices:nil];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"蓝牙已经连上，是否需要发送数据测试" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
    
}

//alertView的代理方法
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        //点击取消
        NSLog(@"取消");
        
    }else if (buttonIndex == 1){
        //点击确定
        NSLog(@"确定");
        LWSendDataCtl *lw = [[LWSendDataCtl alloc] init];
        [self.navigationController pushViewController:lw animated:YES];
        
        __weak ViewController *weakSelf = self;
        lw.sendBlock = ^(NSString *sendStr){
            NSLog(@"sendStr == %@",sendStr);
            NSData *data = [sendStr dataUsingEncoding:NSUTF8StringEncoding];
            weakSelf.bleDatas = data;
            
            if (_characteristic.properties & CBCharacteristicPropertyWrite) {
                //
                [self.cbPeripheral writeValue:weakSelf.bleDatas forCharacteristic:_characteristic type:CBCharacteristicWriteWithResponse];
            }else{
                NSLog(@"该数据不可写");
            }
            
        };
    }
}

//断开连接
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"%s, line = %d, %@=断开连接", __FUNCTION__, __LINE__, peripheral.name);
    _cbPeripheral= nil;
}

//连接外设失败
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    NSLog(@"%s, line = %d, %@=连接失败", __FUNCTION__, __LINE__, peripheral.name);
    
}

#pragma mark CBPeripheralDelegated
//扫描到Services
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    if (error) {
        NSLog(@"扫描到Services error == %@",error.localizedDescription);
        return;
    }
    for (CBService *service in peripheral.services) {
        //发现特征，成功后执行：peripheral:didDiscoverCharacteristicsForService:error委托方法
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

//扫描到Characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        NSLog(@"扫描到Characteristics error == %@",error.localizedDescription);
        return;
    }
    
    for (CBCharacteristic *characters in service.characteristics) {
        
        //每个服务下有多个特征，当特征值为UUID_WRITE时，进行写入数据 设置通知
        if ([characters.UUID.UUIDString isEqualToString:UUID_WRITE]) {
            [peripheral readValueForCharacteristic:characters];
            [service.peripheral setNotifyValue:YES forCharacteristic:characters];
            _characteristic = characters;
        }
    }
}

//获取的charateristic的值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"charateristic的值 error == %@",error.localizedDescription);
        return;
    }
    
    NSLog(@"characteristic : %@",characteristic.value);
    
    
    if ([characteristic.value isEqualToData:[NSData dataWithBytes:"\xcc\x00" length:2]]) {
        NSLog(@"成功");
    } else if ([characteristic.value isEqualToData:[NSData dataWithBytes:"\xcc\x01" length:2]]) {
        NSLog(@"缺纸");
    } else if ([characteristic.value isEqualToData:[NSData dataWithBytes:"\xcc\x02" length:2]]) {
        NSLog(@"开盖");
    }
    
}


#pragma mark 写数据后回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"写入%@成功",characteristic);
//
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"写入成功" message:[NSString stringWithFormat:@"写入%@成功",characteristic] delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil];
//    [alertView show];
    NSLog(@"bleDatas == %@",self.bleDatas);
    
}




@end










