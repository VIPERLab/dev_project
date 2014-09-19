#ifndef FREEVERB_H
#define FREEVERB_H

#include "revmodel/revmodel.h"

struct RevSettings
{
	int roomsize;
	int damp;
	int wet;
	int dry;
	int width;
	int mode;
};

const RevSettings rs[] = 
{
	//roomsize, damp, wet, dry, width, mode
	{250, 100, 333, 750, 250, 0},  //小房间
	{ 500, 250, 333, 750, 500, 0}, //中等房间
	{ 700, 250, 333, 750, 700, 0}, //大房间
	{ 900, 500, 333, 750, 1000, 0},	//大厅
};

enum room_size{
	no_room = 0,
	small_room,
	middle_room,
	big_room,
	hall
};

class freeverb
{
public:
	freeverb();
	~freeverb();
public:

	/************************************************************************/
	/* 
	说明：对一段wav添加混音效果，输出的wav数据也放在samples 指向的buffer里。
	param:
	samp_freq : 采样率
	sf:	PCM类型，传固定值 1
	nchannels: 声道数
	samples: wav数组
	【in/out】 numsamples: wav数据 short值的个数
	*/
	/************************************************************************/
	void process(int samp_freq, int sf, int nchannels, short *samples0, size_t numsamples);

	/************************************************************************/
	/*
	说明：设置混音效果
	param：
	rSize：房间大小
	*/
	/************************************************************************/
	void setRev(room_size rSize);

public:
	static const int scalewet=3;
	static const int initialroom =int(1000*0.5f);
	static const int initialdamp =int(1000*0.25f);
	static const int initialwet  =int(1000*(1.0f/scalewet));
	static const int initialdry  =int(1000*0.75);
	static const int initialwidth=int(1000*1);
	static const int initialmode =int(1000*0);
private:
	revmodel * m_rev;
	RevSettings * m_rs;
	room_size m_roomSize;

};

#endif