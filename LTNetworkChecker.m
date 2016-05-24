//
//  NetworkAnalyser.m
//  
//
//  Created by Sergey Koldaev on 18/04/14.
//
//

#import "LTNetworkChecker.h"

#import <sys/socket.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <netdb.h>

const static float timeSinceLastNetworkUpdate = 2.0;

@implementation LTNetworkChecker

- (id)init{
    self = [super init];
    if (self){
        _hosts = @[@"www.ya.ru", @"www.google.com", @"www.yahoo.com", @"www.bing.com", @"www.apple.com"];
        _cellNames = @[@"pdp_ip0", @"pdp_ip1", @"pdp_ip2", @"pdp_ip3", @"pdp_ip4"];
        _wifiNames = @[@"en0", @"en1", @"en2", @"en3", @"en4"];
        [self checkConnections];
    }
    return self;
}

- (void)checkConnections{
    struct ifreq ifr;
    
    int dummy_fd = socket( AF_INET, SOCK_DGRAM, 0 );
    
    _networkConnectionStatus.connectionAvailable = NO;
    _networkConnectionStatus.cellularDataAvailable = NO;
    _networkConnectionStatus.wifiAvailable = NO;
    
    //Проверяем на наличие интернета в общем
    for (NSString* hostName in _hosts){
        if (gethostbyname([hostName UTF8String])){
            _networkConnectionStatus.connectionAvailable = YES;
            break;
        }
    }
    
    //Если интернет доступен
    if (_networkConnectionStatus.connectionAvailable){

        //Проверяем доступность Сотовых данных
        for (NSString* cellName in _cellNames){
            memset(&ifr, 0, sizeof(ifr));
            strcpy(ifr.ifr_name, [cellName UTF8String]);
            if (ioctl(dummy_fd, SIOCGIFFLAGS, &ifr) != -1){
                if ((ifr.ifr_flags & ( IFF_UP | IFF_RUNNING )) == ( IFF_UP | IFF_RUNNING )){
                    _networkConnectionStatus.cellularDataAvailable = YES;
                    break;
                }
            }
        }
        
        //Проверяем на доступность wifi
        for (NSString* wifiName in _wifiNames){
            memset(&ifr, 0, sizeof(ifr));
            strcpy(ifr.ifr_name, [wifiName UTF8String]);
            if (ioctl(dummy_fd, SIOCGIFFLAGS, &ifr) != -1){
                if ((ifr.ifr_flags & ( IFF_UP | IFF_RUNNING )) == ( IFF_UP | IFF_RUNNING )){
                    _networkConnectionStatus.wifiAvailable = YES;
                    break;
                }
            }
        }
        
    }
    _lastUpdate = CFAbsoluteTimeGetCurrent();
}

- (BOOL)isNetworkConnectionAvailable{
    if (CFAbsoluteTimeGetCurrent() - _lastUpdate > timeSinceLastNetworkUpdate){
        [self checkConnections];
    }
    return _networkConnectionStatus.connectionAvailable;
}

- (BOOL)isCellularDataAvailable{
    if (CFAbsoluteTimeGetCurrent() - _lastUpdate > timeSinceLastNetworkUpdate){
        [self checkConnections];
    }
    return _networkConnectionStatus.cellularDataAvailable;
}

- (BOOL)isWifiAvailable{
    if (CFAbsoluteTimeGetCurrent() - _lastUpdate > timeSinceLastNetworkUpdate){
        [self checkConnections];
    }
    return _networkConnectionStatus.wifiAvailable;
}

- (NetworkConnectionStatus)networkStatus{
    if (CFAbsoluteTimeGetCurrent() - _lastUpdate > timeSinceLastNetworkUpdate){
        [self checkConnections];
    }
    return _networkConnectionStatus;
}

- (BOOL)canGetHostByName:(NSString*) name{
    if (gethostbyname([name UTF8String])){
        _networkConnectionStatus.connectionAvailable = YES;
        return true;
    }
    return false;
}

+ (instancetype)shared{
    static LTNetworkChecker * shared_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once (&onceToken, ^
                   {
                       shared_instance = [[self alloc] init];
                   });
    return shared_instance;
}

@end

