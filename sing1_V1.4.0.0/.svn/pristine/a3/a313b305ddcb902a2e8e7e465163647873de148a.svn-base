//#include "stdafx.h"
#include "wav_buf.h"
#include "string.h"

//wav_buf的实现
wav_buf::wav_buf()
{
	first = NULL;
	last = NULL;
	total_node_num = 0;
	total_data_len = 0;
	record_pos = 0;
}

wav_buf::~wav_buf()
{
	while(first != NULL)
	{
		delete[] first->data;
		node * temp = first;
		first = first->next;
		delete temp;
	}
}

int wav_buf::add(short * adddata, int len)
{
	//ASSERT(len > 0);
	node * pnode = new node;
	pnode->begin_pos = 0;
	pnode->data = new sample_t[len];
	if (pnode && pnode->data)
	{
		memcpy(pnode->data, adddata, sizeof(sample_t) * len);
		pnode->data_len = len;
		pnode->next = NULL;
	}
	if(first == NULL && last == NULL)
	{
		first = pnode;
		last = pnode;
	}
	else
	{
		last->next = pnode;
		last = pnode;
	}
	total_node_num ++;
	total_data_len += len;
	return 0;
}

//删除缓存中的所有数据
void wav_buf::remove_all()
{
	while(first)
	{
		node * temp = first;
		first = first->next;
		delete[] temp->data;
		delete[] temp;
	}
	first = NULL;
	last = NULL;
	total_data_len = 0;
	total_node_num = 0;
	record_pos = 0;
}

//从buffer的开头处读取长度为len的数据，并存放在名为out的内存空间中，out由调用者自己分配好
int wav_buf::get_from_head(sample_t * out, int len)
{
	if (total_data_len < len)
	{
		return 1;
	}
	node * ptemp = first;
	while(ptemp != NULL && ptemp->data_len - ptemp->begin_pos <= len)
	{
		len -= (ptemp->data_len - ptemp->begin_pos);
		memcpy(out, &(ptemp->data[ptemp->begin_pos]), sizeof(sample_t) * (ptemp->data_len - ptemp->begin_pos));
		out += (ptemp->data_len - ptemp->begin_pos);
		ptemp = ptemp->next;
	}
	if (len > 0 && ptemp)
	{
		//ASSERT(ptemp);
		memcpy(out, &(ptemp->data[ptemp->begin_pos]), sizeof(sample_t) * len);
	}
	return 0;
}

//从buffer的开头处取走长度为len的数据，并存放在名为out的内存空间中，out
//必须在调用该函数之前由调用者自己开辟好
int wav_buf::remove_from_head(sample_t * out, int len)
{
	if(total_data_len < len)
		return 1;
	record_pos += len;
	total_data_len -= len;
	while(first != NULL && first->data_len - first->begin_pos <= len)
	{
		len -= (first->data_len - first->begin_pos);
		node * temp = first->next;
		memcpy(out, &(first->data[first->begin_pos]), sizeof(sample_t) * (first->data_len - first->begin_pos));
		out += (first->data_len - first->begin_pos);
		delete[] first->data;
		delete first;
		first = temp;
		total_node_num --;
	}
	if(first == NULL)
	{
		last = NULL;
		return 1;
	}
	if(len > 0)
	{
		memcpy(out, &(first->data[first->begin_pos]), sizeof(sample_t) * len);
		first->begin_pos += len;
	}
	return 0;
}