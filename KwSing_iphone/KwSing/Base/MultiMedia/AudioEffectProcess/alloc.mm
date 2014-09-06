#include "alloc.h"
#include "memory.h"

void* aligned_malloc(size_t size, size_t alignment)
{
	return malloc(size);
}


void aligned_free(void *mem_ptr)
{
	free(mem_ptr);
}

void* aligned_realloc(void *ptr,size_t size,size_t alignment)
{
	if (!ptr)
		return aligned_malloc(size,alignment);  
	else
		if (size==0)
		{
			aligned_free(ptr);
			return NULL;
		}
		else
			return realloc(ptr,size);
}

void* aligned_calloc(size_t size1, size_t size2, size_t alignment)
{
	size_t size=size1*size2;
	void *ret=aligned_malloc(size,alignment);
	if (ret) memset(ret,0,size);
	return ret;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
