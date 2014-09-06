/*
 *  debug.h
 *  KwSing
 *
 *  Created by mistyzyq on 11-5-20.
 *  Copyright 2011 Kuwo Beijing Co., Ltd. All rights reserved.
 *
 */
#include <assert.h>

#ifndef __KUWO_DEBUG_H_
#define __KUWO_DEBUG_H_

// ASSERT macro
#if (defined DEBUG) || (defined _DEBUG)

#if TARGET_IPHONE_SIMULATOR
#define ASSERT(exp) {   \
    if (!(exp)) {   \
        fprintf(stderr, "ASSERT failed: %s \n\t%s: %d \n", #exp, __FILE__, __LINE__);  \
       /* __asm { int 3 } */\
    }   \
}
#else
#define ASSERT(exp) assert(exp)
#endif

#else

#define ASSERT(exp)

#endif


// VERIFY macro
#if (defined DEBUG) || (defined _DEBUG)
#define VERIFY(exp) ASSERT(exp)
#else
#define VERIFY(exp) exp;
#endif

#endif  // __KUWO_DEBUG_H_