//
//  CapstoneHelper.h
//  mocha (macOS)
//
//  Created by white on 2022/2/7.
//

#import <Foundation/Foundation.h>
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Weverything" // ignoring all warnings from capstore
#import "capstone.h"
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, CapStoneArchType) {
    CapStoneArchTypeI386,
    CapStoneArchTypeX8664,
    CapStoneArchTypeThumb,
    CapStoneArchTypeARM,
    CapStoneArchTypeARM64
};

@interface CapStoneInstruction: NSObject

@property (nonatomic, strong) NSString *mnemonic;
@property (nonatomic, strong) NSString * operand;
@property (nonatomic, assign) NSInteger startOffset;
@property (nonatomic, assign) NSInteger length;

@end

@interface CapStoneHelper : NSObject

+ (cs_insn *)instructions:(NSData *)fileData  from:(unsigned long long)begin length:(unsigned long long )size;

@end

NS_ASSUME_NONNULL_END
