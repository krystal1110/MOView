//
//  CapstoneHelper.m
//  mocha (macOS)
//
//  Created by white on 2022/2/7.
//

#import "CapStoneHelper.h"
 

@implementation CapStoneInstruction

@end

@implementation CapStoneHelper

+ (cs_insn *)instructions:(NSData *)fileData  from:(unsigned long long)begin length:(unsigned long long )size{
    
    
 
    
    // Get compilation.
    csh cs_handle = 0;
    cs_err cserr;
    if ((cserr = cs_open(CS_ARCH_ARM64, CS_MODE_ARM, &cs_handle)) != CS_ERR_OK ) {
        
        NSLog(@"Failed to initialize Capstone: %d, %s.", cserr, cs_strerror(cs_errno(cs_handle)));
        return NULL;
    }
    // Set the parsing mode.
    cs_option(cs_handle, CS_OPT_MODE, CS_MODE_ARM);
    //        cs_option(cs_handle, CS_OPT_DETAIL, CS_OPT_ON);
    cs_option(cs_handle, CS_OPT_SKIPDATA, CS_OPT_ON);
    
    unsigned long long ins_count = size / 4;
    unsigned long long step = ins_count / 8;
    
    static cs_insn* tmp[8];
    static size_t tmp_count[8];
    dispatch_apply(8, dispatch_get_global_queue(0, 0), ^(size_t index) {
        cs_insn *cs_insn = NULL;
        char *ot_sect = (char *)[fileData bytes] + begin + index * step * 4;
        uint64_t ot_addr = begin + index * step * 4;
        unsigned long long ins_size = (index < 7)?step*4:(size - step * 7 * 4);
        // Disassemble
        size_t disasm_count = cs_disasm(cs_handle, (const uint8_t *)ot_sect, ins_size, ot_addr, 0, &cs_insn);
        if (disasm_count > 1 ) {
            tmp[index] = cs_insn;
            tmp_count[index] = disasm_count;
        }else{
            NSLog(@"cs_disasm error");
        }
    });
    cs_insn *all = NULL;
    size_t count = 0;
    for (int i = 0; i < 8; i++) {
        count += tmp_count[i] * sizeof(cs_insn);
    }
    all = (cs_insn *)realloc(tmp[0],count);
    cs_insn *start = all;
    for (int i = 0; i < 7; i++) {
        start += tmp_count[i];
        memmove(start, tmp[i+1], tmp_count[i+1] * sizeof(cs_insn));
        free(tmp[i+1]);
    }
    
    
    return all;
    
}

@end
