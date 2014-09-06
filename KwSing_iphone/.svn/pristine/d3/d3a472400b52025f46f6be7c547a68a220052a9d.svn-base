/***********************************************************************************************************
File:	preamp.h
Desc:	用于放大16 bit wav信号的类PreAmp的定义文件，可以把wav信号按照要求的db数进行放大和缩小
Author:	Wang Lei
Date:	May, 2008
***********************************************************************************************************/

#ifndef PREAMP_H
#define PREAMP_H

class PreAmp
{
public:
	PreAmp();
	~PreAmp();	
	bool process(void * pWav, int nLen, int nDB);
	static const unsigned long table_size = 65536;
private:
	void make_table(float ratio);
	signed short * m_table;
	int m_db;
};

#endif