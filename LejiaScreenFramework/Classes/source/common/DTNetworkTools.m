//
//  DTNetworkTools.m
//  LejiaSDKFramework_Example
//
//  Created by sos1a2a3a on 2019/3/26.
//  Copyright © 2019 sawrysc@163.com. All rights reserved.
//

#import "DTNetworkTools.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@implementation DTNetworkTools
+(NSString *)getBroadcastIp
{
    
    NSDictionary *dicAddress = [self getBroadcastIps];
    NSString *strIP = @"";
    //    //en0/ipv4
    //
    //    if (!strIP) {
    //
    //    AILogInfo(@"getWifiName:%@",[Tool getWifiName]);
    //        if ([[Tool getWifiName] rangeOfString:@"LITE"].location !=NSNotFound) {
    strIP = [dicAddress objectForKey:@"en0/ipv4"];
    //        }
    
    //    }
    //   if (strIP) {
    
    //        NSMutableArray *arrmut = [NSMutableArray arrayWithArray:[strIP componentsSeparatedByString:@"."]];
    //        if (arrmut) {
    //            [arrmut removeLastObject];
    //            if (arrmut) {
    //                strIP = [arrmut componentsJoinedByString:@"."];
    //                strIP = [strIP stringByAppendingString:@".15"];
    //            }
    //        }
    //    }
    return strIP;
}
+ (NSDictionary *)getBroadcastIps
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_dstaddr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_dstaddr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}
@end
