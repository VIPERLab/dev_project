#pragma once

#include "spectral_buf.h"
#include "wav_buf.h"
#include "wav_operation.h"

class CScore
{
private:
	CScore(void);
	~CScore(void);
    
public:
    static CScore* GetInstance();

public:
	/************************************************************************/
	/*
	说明：有新的wav数据到达时调用
	param：
		pWavData:数据
		nLen:short数组长度
	有新的自唱wav数据到达，要求参数：44100hz，2 channel， 16位采样位数
	44.1K采样，双声道，16位采样深度，1秒钟数据=44100*2*sizeof(short);
	*/
	/************************************************************************/
	
	void OnWavNewDataComing(short * pWavData, int nLen);

	/************************************************************************/
	/* 
	 初始化Score对象时调用
	prarm:
		nRecWavSampleRate:录制音频的采样率
		nChannel：录制音频的声道数
		dEnvMax: 原唱包络归一化所用的值
	*/
	/************************************************************************/
	void Init( double dbEnvRate, int nRecWavSampleRate=44100, int nChannel=2);
    
    void UnInit();

	/************************************************************************/
	/*
	说明：一句歌开始唱的时候调用
	param：
		pdbSpec:该句频谱数组
		pdbEnv：该句包络数组
		nSpecLen:数组长度
		nEnvLen: 数组长度
	*/
	/************************************************************************/
	void SentenceStart( double * pdbSpec, int nSpecNum, double * pdbEnv, int nEnvNum);

	/************************************************************************/
	/*
	说明：一句歌结束的时候调用
	返回值：
		得分
	*/
	/************************************************************************/
	int SentenceEnd();
    
    bool IsInitFinish()const;
    
private:
    bool m_bInitFinish;

private:

	int GetSentenceScore();


	double * m_pdbArtistSpecData;		//原唱频谱
	double * m_pdbArtistEnvData;		//原唱包络
	double * m_pdbSingerEnvData;		//自唱包络
	int m_nSpecLen;						//原唱频谱长度
	int m_nEnvLen;						//原唱包络长度
	spectral_buf *m_sb;						    //计算自唱频谱特征所设置的buffer

	
	int      m_nCurrentSingerEnvNum;			// 当前已经计算的演唱者（自唱）的包络值的个数
	double   m_fArtistEnvNormRatio;			    // 原唱的包络图进行归一化时所用的系数，也就是包络图的最大值
	int		 m_nRecSampleRate;
	wav_buf  m_RecordWavBuf;					//存放录制的自唱声音的buffer
	
};
