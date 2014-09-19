#pragma once
#include "Resample\samplerate.h"
#include "wav_operation.h"

#define DOWN_SAMPLERATE (16000)			//��������Ĳ����ʣ�Ϊ�˼���Ƶ��������Ҫ������

//Ϊ�˼���Ƶ�������õ�buffer�ռ�
class spectral_buf
{
private:
	short * m_pWavIn;	//�����ԭʼ�����ʵ�wav����
	short * m_pWavOut;	//������ز���֮���wav����
	int m_nWavInTotalLen;	//�����ԭʼ�����ʵ�wav�ĳ���
	int m_nWavOutTotalLen;	//�ز���֮���wav���ݵĳ���
	int m_nFeedLen;			//�Ѿ������wav���ݵĳ���
	int m_nInSR;		//�����wav�Ĳ�����
	int m_nOutSR;		//�����wav�Ĳ�����
	int m_nInWavChanNum;	//�����wav��������
	int m_nResampleOutNum;	//resample�Ѿ���ɵĲ�������
	int m_nResampleDoneLen;	//������ز����ĳ���

	const static int m_nOutWavChanNum = 1;	//�����wav���������̶�Ϊ1��Ҳ���ǵ�����
	const static int m_nResampleBufLen = 1 << 10;	//�ز������õ�buf���ȹ̶�Ϊ1k byte

	double m_fRatio;	//��������ʺ���������ʵı�ֵ
	short * m_pMonoWav;	//���δ�ز����ĵ�������wav
	char * m_pResampleData;	//�ز������õ���buffer������Ϊm_nResampleBufLen
	SRC_STATE * m_srcState;	//�ز�������Ҫ�Ľṹ
	SRC_DATA m_srcData;		//�ز�������Ҫ�Ľṹ
	float * m_srcInput;		//�ز���������buffer
	float * m_srcOutput;	//�ز�����������buffer

	const static int m_FFT_N = 1024;	//����FFT��ʹ�õĵ���
	int m_nSpecDoneLen;		//�������Ƶ�������ĳ���
	int m_nSpecFeaCount;	//Ƶ������������
	double * m_win;			//����FFT��ʹ�õĴ�����
	double * sig_real;		//ʱ���źŵ�ʵ��
	double * sig_imag;		//ʱ���źŵ��鲿
	double * pwr_real;		//Ƶ���źŵ�ʵ��
	double * pwr_imag;		//Ƶ���źŵ��鲿
	double * pwr;			//�ź���Ƶ�������
public:
	double * m_pSpecFea;	//Ƶ�������Ĵ�ſռ�
	double * m_pAcr;		//ÿһ֡������غ��������ֵ����������Ƿ�������
	int m_nSpecFeaDoneNum;	// �Ѿ�������������ĸ���
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