#ifndef ALLOC_H
#define ALLOC_H

///////////////////////////////////////////////////////////////////////////////////////////////////////////
#ifndef NULL
#define NULL 0
#endif

#define CACHE_LINE 32

//mem_alignµÄº¯Êý
void *aligned_malloc(size_t size,size_t alignment=0);
void *aligned_calloc(size_t size1,size_t size2,size_t alignment=0);
void *aligned_realloc(void *memblock,size_t size,size_t alignment=0);
void aligned_free(void *mem_ptr);

#endif