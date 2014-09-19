#pragma once
#include "Resample\samplerate.h"
#include "wav_operation.h"

#define DOWN_SAMPLERATE (16000)			//降采样后的采样率，为了计算频谱特征需要降采样

//为了计算频谱所设置的buffer空间
class spectral_buf
{
private:
	short * m_pWavIn;	//进入的原始采样率的wav数据
	short * m_pWavOut;	//输出的重采样之后的wav数据
	int m_nWavInTotalLen;	//进入的原始采样率的wav的长度
	int m_nWavOutTotalLen;	//重采样之后的wav数据的长度
	int m_nFeedLen;			//已经输入的wav数据的长度
	int m_nInSR;		//输入的wav的采样率
	int m_nOutSR;		//输出的wav的采样率
	int m_nInWavChanNum;	//输入的wav的声道数
	int m_nResampleOutNum;	//resample已经完成的采样点数
	int m_nResampleDoneLen;	//已完成重采样的长度

	const static int m_nOutWavChanNum = 1;	//输出的wav的声道数固定为1，也就是单声道
	const static int m_nResampleBufLen = 1 << 10;	//重采样所用的buf长度固定为1k byte

	double m_fRatio;	//输出采样率和输入采样率的比值
	short * m_pMonoWav;	//存放未重采样的单声道的wav
	char * m_pResampleData;	//重采样所用到的buffer，长度为m_nResampleBufLen
	SRC_STATE * m_srcState;	//重采样所需要的结构
	SRC_DATA m_srcData;		//重采样所需要的结构
	float * m_srcInput;		//重采样的输入buffer
	float * m_srcOutput;	//重采样所需的输出buffer

	const static int m_FFT_N = 1024;	//计算FFT所使用的点数
	int m_nSpecDoneLen;		//已完成求频谱特征的长度
	int m_nSpecFeaCount;	//频谱特征的数量
	double * m_win;			//计算FFT所使用的窗函数
	double * sig_real;		//时域信号的实部
	double * sig_imag;		//时域信号的虚部
	double * pwr_real;		//频域信号的实部
	double * pwr_imag;		//频域信号的虚部
	double * pwr;			//信号在频域的能量
public:
	double * m_pSpecFea;	//频谱特征的存放空间
	double * m_pAcr;		//每一帧的自相关函数的最大值，用来检测是否是噪音
	int m_nSpecFeaDoneNum;	// 已经计算出的特征的个数
	spectral_buf(int nLen, int in_sr, int out_sr, int in_chan_num, int spec_fea_num);
	~spectral_buf();
	void feed_data(short * pWav, int len);
private:
	void initialize_resample();
	bool resample();
	void get_spec_fea();
public:
	int m_nTraceNum;
};