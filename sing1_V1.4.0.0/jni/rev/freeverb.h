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
	{250, 100, 333, 750, 250, 0},  //С����
	{ 500, 250, 333, 750, 500, 0}, //�еȷ���
	{ 700, 250, 333, 750, 700, 0}, //�󷿼�
	{ 900, 500, 333, 750, 1000, 0},	//����
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
	˵������һ��wav��ӻ���Ч���������wav����Ҳ����samples ָ���buffer�
	param:
	samp_freq : ������
	sf:	PCM���ͣ����̶�ֵ 1
	nchannels: ������
	samples: wav����
	��in/out�� numsamples: wav���� shortֵ�ĸ���
	*/
	/************************************************************************/
	void process(int samp_freq, int sf, int nchannels, short *samples0, size_t numsamples);

	/************************************************************************/
	/*
	˵�������û���Ч��
	param��
	rSize�������С
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