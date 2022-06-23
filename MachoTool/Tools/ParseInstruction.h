//
//  ParseInstruction.h
//  MachoTool
//
//  Created by karthrine on 2022/6/20.
//

#import <Foundation/Foundation.h>
#import "capstone.h"
NS_ASSUME_NONNULL_BEGIN

@interface ParseInstruction : NSObject

+ (cs_insn *)disassemWithMachOFile:(NSData *)fileData  from:(unsigned long long)begin length:(unsigned long long )size;

@end

NS_ASSUME_NONNULL_END
