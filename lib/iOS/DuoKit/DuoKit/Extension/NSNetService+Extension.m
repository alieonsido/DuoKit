//
//  NSNetService+Extension.m
//  DuoKit
//
//  The MIT License (MIT)
//
//  Copyright © 2017 MediaTek Inc. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

#import "NSNetService+Extension.h"
#include <arpa/inet.h>

@implementation NSNetService (Extension)

typedef union {
    struct sockaddr     sa;
    struct sockaddr_in  ipv4;
    struct sockaddr_in6 ipv6;
} isa;

- (NSComparisonResult)localizedCaseInsensitiveCompareByName:(NSNetService *)aService
{
    return [[self name] localizedCaseInsensitiveCompare:[aService name]];
}

- (NSArray<NSString *> *)addressStrings
{
    char buf[INET6_ADDRSTRLEN];
    
    NSMutableArray *results = [NSMutableArray new];
    
    for (NSData *data in [self addresses]) {
        
        memset(buf, 0, INET6_ADDRSTRLEN);
        
        isa *socAddr = (isa *)[data bytes];
        
        if (socAddr &&
            (socAddr->sa.sa_family == AF_INET ||
             socAddr->sa.sa_family == AF_INET6)) {
                
                const char *addr = inet_ntop(socAddr->sa.sa_family,
                                             (socAddr->sa.sa_family ==
                                              AF_INET ?
                                              (void *)&(socAddr->ipv4.sin_addr) :
                                              (void *)&(socAddr->ipv6.sin6_addr)),
                                             buf,
                                             sizeof(buf));
                
                int port = ntohs(socAddr->sa.sa_family ==
                                 AF_INET ?
                                 socAddr->ipv4.sin_port :
                                 socAddr->ipv6.sin6_port);
                
                if (addr && port) {
                    [results addObject:[NSString stringWithUTF8String:addr]];
                }
            }
    }
    return results;
}

- (NSArray<NSString *> *)v4AddressStrings
{
    char buf[INET_ADDRSTRLEN];
    
    NSMutableArray *results = [NSMutableArray new];
    
    for (NSData *data in [self addresses]) {
        
        memset(buf, 0, INET_ADDRSTRLEN);
        
        isa *socAddr = (isa *)[data bytes];
        
        if (socAddr &&
            socAddr->sa.sa_family == AF_INET) {
            
            const char *addr = inet_ntop(socAddr->sa.sa_family,
                                         (void *)&(socAddr->ipv4.sin_addr),
                                         buf,
                                         sizeof(buf));
            
            int port = ntohs(socAddr->ipv4.sin_port);
            
            if (addr && port) {
                [results addObject:[NSString stringWithUTF8String:addr]];
            }
        }
    }
    return results;
}

- (NSArray<NSString *> *)v6AddressStrings
{
    char buf[INET6_ADDRSTRLEN];
    
    NSMutableArray *results = [NSMutableArray new];
    
    for (NSData *data in [self addresses]) {
        
        memset(buf, 0, INET6_ADDRSTRLEN);
        
        isa *socAddr = (isa *)[data bytes];
        
        if (socAddr &&
            socAddr->sa.sa_family == AF_INET6) {
            
            const char *addr = inet_ntop(socAddr->sa.sa_family,
                                         (void *)&(socAddr->ipv6.sin6_addr),
                                         buf,
                                         sizeof(buf));
            
            int port = ntohs(socAddr->ipv6.sin6_port);
            
            if (addr && port) {
                [results addObject:[NSString stringWithUTF8String:addr]];
            }
        }
    }
    return results;
}

@end

