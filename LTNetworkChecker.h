//
//  NetworkAnalyser.h
//  
//
//  Created by Sergey Koldaev on 18/04/14.
//
//

#import <Foundation/Foundation.h>

typedef struct {
    BOOL connectionAvailable;
    BOOL wifiAvailable;
    BOOL cellularDataAvailable;
}NetworkConnectionStatus;

@interface LTNetworkChecker : NSObject{
@private
    NetworkConnectionStatus _networkConnectionStatus;
    
    NSArray* _hosts;
    NSArray* _cellNames;
    NSArray* _wifiNames;
    
    CFAbsoluteTime _lastUpdate;
}

- (BOOL)isNetworkConnectionAvailable;
- (BOOL)isCellularDataAvailable;
- (BOOL)isWifiAvailable;
- (NetworkConnectionStatus)networkStatus;

- (BOOL)canGetHostByName:(NSString*) name;

+ (instancetype)shared;

@end
