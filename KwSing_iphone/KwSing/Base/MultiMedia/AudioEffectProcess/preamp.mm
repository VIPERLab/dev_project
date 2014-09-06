/***********************************************************************************************************
File:	preamp.cpp
Desc:	用于放大16 bit wav信号的类PreAmp的实现文件，可以把wav信号按照要求的db数进行放大和缩小
Author:	Wang Lei
Date:	May, 2008
***********************************************************************************************************/

#include "preamp.h"
#include "math.h"

#ifndef NULL
#define NULL (0)
#endif

PreAmp::PreAmp():m_table(NULL),
				m_db(0)
{
}

PreAmp::~PreAmp()
{
	if(m_table)
		delete[] m_table;
}

#pragma optimize("", off)
void PreAmp::make_table(float ratio) 
{
	unsigned short	i = 0;
	do {
		if (((signed short)i * ratio) > 32767)
			m_table[i] = 32767;
		else if (((signed short)i * ratio) < -32767)
			m_table[i] = -32767;
		else
			m_table[i] = (signed short)(((signed short)i) * ratio);
	} while (++i);
}
#pragma optimize("", on)


bool PreAmp::process(void * pWav, int nLen, int nDB)
{
	if(m_db == 0 && nDB != 0)
	{
		m_db = nDB;
		m_table = new signed short[table_size];
		if(m_table == NULL)
			return false;
		float ratio = pow((float)10., (float)m_db / 20);
		make_table(ratio);
	}
	else if(m_db != 0 && nDB == 0)
	{
		m_db = 0;
		delete[] m_table;
		m_table = NULL;
		return true;
	}
	else if(m_db != nDB)
	{
		m_db = nDB;
		float ratio = pow((float)10., (float)m_db / 20);
		make_table(ratio);
	}
	unsigned short * pBuf = (unsigned short *)pWav;
	for(int i = 0; i < nLen; i ++)
	{
		pBuf[i] = m_table[pBuf[i]];
	}
	return true;
}
