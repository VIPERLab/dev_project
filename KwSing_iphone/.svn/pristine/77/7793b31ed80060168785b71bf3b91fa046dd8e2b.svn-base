#include "StdAfx.h"
#include "Score.h"
#include "log.h"
#include "globalm.h"
#include <math.h>
#include "AutoLock.h"

#define RECORD_CHANEL_NUM (2)

#define POPULARITY_START_POINT (70)		//ø™ ºº∆»À∆¯÷µµƒ∆µ„∑÷ ˝
#define MAX_LOG_SINGING_ENV (9)			//◊‘≥™µƒƒ‹¡ø±£¬Áµƒ◊Ó¥Û÷µŒ™ 10 ^ 9
#define TOO_LOUD_TH1 (8.47)				//”√ªß≥™µƒ…˘“Ùπ˝œÏµƒ„–÷µ:log10(3 * 10 ^8)
#define TOO_LOUD_TH2 (8.3)				//”√ªß≥™µƒ…˘“Ù”––©œÏ£∫log10(2 * 10^8)
#define TOO_SILENT_TH1 (5.78)			//”√ªß≥™µƒ…˘“Ùπ˝”⁄∞≤æ≤µƒ„–÷µ1£∫ log10(6 * 10^5)
#define TOO_SILENT_TH2 (6)				//”√ªß≥™µƒ…˘“Ùπ˝”⁄∞≤æ≤µƒ„–÷µ2£∫ log10(1 * 10^6)
#define CENTROID_LOW_TH1 (10)			//∆µ∆◊Ãÿ’˜µƒ◊ÓµÕµƒ„–÷µ£¨µ±µÕ”⁄’‚∏ˆ÷µ£¨±Ì æ∏Ë≥™∫‹”–ø…ƒ‹√ª”–≥™£¨ªÚ’ﬂ∫‹”–ø…ƒ‹‘⁄∫ﬂ∫ﬂ
#define CENTROID_LOW_TH2 (15)			//∆µ∆◊Ãÿ’˜…‘œ”µÕ£¨µ±µÕ”⁄’‚∏ˆ÷µ ±£¨º”“‘  µ±µƒ≥Õ∑£
#define MAX_SCORE (100)					//◊Ó¥Û∑÷ ˝

static KwTools::CLock s_score_lock;

CScore::CScore(void)
:m_pdbArtistEnvData(NULL)
,m_pdbArtistSpecData(NULL)
,m_pdbSingerEnvData(NULL)
{
	m_fArtistEnvNormRatio = 0;
    m_bInitFinish = false;
	//m_sb = 0;
}

CScore::~CScore(void)
{
    m_bInitFinish = false;
    UnInit();
}

CScore* CScore::GetInstance(){
    static CScore s_score;
    
    return &s_score;
}

bool CScore::IsInitFinish()const{
//    KwTools::CAutoLock auto_lock(&s_score_lock);
    return m_bInitFinish;
}

void CScore::OnWavNewDataComing( short * pWavData, int nLen )
{
//    return;
    KwTools::CAutoLock auto_lock(&s_score_lock);
    
    if (!m_bInitFinish) {
        return;
    }
    
//    s_score_lock.Lock();
    
	if (pWavData == NULL){
//        s_score_lock.UnLock();
        return;
    }
    
    if (m_nCurrentSingerEnvNum>m_nEnvLen-1) {
//        s_score_lock.UnLock();
        return;
    }

    m_RecordWavBuf.add(pWavData, nLen);
	int nFrameLen = ENV_FRAME_LEN * m_nRecSampleRate / 1000 * RECORD_CHANEL_NUM;
	int nFrameStep = ENV_FRAME_STEP * m_nRecSampleRate / 1000 * RECORD_CHANEL_NUM;
    
    //c_KuwoDebugLog("SCORE On Data Come", DEBUG_LOG, [GetCurTimeToString() UTF8String]);
	while(m_RecordWavBuf.get_data_len() > nFrameLen)
	{
        
        if (m_nCurrentSingerEnvNum>m_nEnvLen-1) {
//            s_score_lock.UnLock();
            return;
        }
        
		short * out = new short[nFrameLen];

		m_RecordWavBuf.get_from_head(out, nFrameLen);
		double temp_env = 0.;
		for (int i = 0; i < nFrameLen; i += RECORD_CHANEL_NUM)
		{
			double frame_amp = 0.;

			for(int j = i; j < i + RECORD_CHANEL_NUM; j ++)
			{
				frame_amp += out[i];
			}

			frame_amp /= RECORD_CHANEL_NUM;
			temp_env += frame_amp * frame_amp;
		}

		temp_env /= (nFrameLen / RECORD_CHANEL_NUM);

        if (NULL != m_pdbArtistEnvData) {
            m_pdbSingerEnvData[m_nCurrentSingerEnvNum] = (temp_env > 1 ? log10(temp_env) : 0.) / MAX_LOG_SINGING_ENV;
            m_RecordWavBuf.remove_from_head(out, nFrameStep);
        }
    
        if (out) {
            delete[] out;
            out = NULL;
        }
		
		m_nCurrentSingerEnvNum ++;
	}
	//c_KuwoDebugLog("SCORE Data Come Ends", DEBUG_LOG, [GetCurTimeToString() UTF8String]);
	//±£¥Êwav ˝æ›£¨”√ªßΩµ≤…—˘°¢º∆À„∆µ∆◊µ»π§◊˜
	
	//if( m_sb )
	//	m_sb->feed_data(pWavData, nLen);
//	s_score_lock.UnLock();
}

void CScore::SentenceStart( double * pdbSpec, int nSpecNum, double * pdbEnv, int nEnvNum)
{
    KwTools::CAutoLock auto_lock(s_score_lock);
    assert(!m_pdbArtistSpecData);
    
	if(pdbSpec == NULL || pdbEnv == NULL) return;
    
    //c_KuwoDebugLog("Sentence start", DEBUG_LOG, [GetCurTimeToString() UTF8String]);

	//copy the spec and env data
	m_pdbArtistSpecData = new double[nSpecNum];
	m_pdbArtistEnvData = new double[nEnvNum];
	m_pdbSingerEnvData = new double[nEnvNum];
	memcpy(m_pdbArtistEnvData, pdbEnv, nEnvNum*sizeof(double));
	memcpy(m_pdbArtistSpecData, pdbSpec, nSpecNum*sizeof(double));
	memset(m_pdbSingerEnvData, 0, nEnvNum*sizeof(double));
	m_nEnvLen = nEnvNum;
	m_nSpecLen = nSpecNum;


	//Ω®¡¢“ª∏ˆ–¬µƒº∆À„∆µ∆◊Ãÿ’˜µƒbuffer

	/*
	if (m_sb)
	{
		delete m_sb;
		m_sb = NULL;
	}

	m_sb = new spectral_buf(
		(int)( nEnvNum * 100 * (m_nRecSampleRate / 1000.) * RECORD_CHANEL_NUM ), //∏√æ‰ ‰»Î‘≠ ºwav≥§∂»
		m_nRecSampleRate,	//≤…—˘¬ 
		DOWN_SAMPLERATE,	//º∆À„∆µ∆◊µƒΩµ≤…—˘∆µ∆◊
		RECORD_CHANEL_NUM,  //…˘µ¿
		nSpecNum);			//∏√æ‰∆µ∆◊≥§∂»
     
	*/
    m_bInitFinish = true;
}

int CScore::SentenceEnd()
{
    KwTools::CAutoLock auto_lock(s_score_lock);
    
    m_bInitFinish = false;
	
	int nScore = 0;
	//if(m_sb)
	{
		nScore = GetSentenceScore();
		//delete m_sb;
		//m_sb = NULL;
	}
    
    if (m_pdbArtistEnvData) {
        delete [] m_pdbArtistEnvData;
        m_pdbArtistEnvData=NULL;
    }
	
    if (m_pdbArtistSpecData) {
        delete [] m_pdbArtistSpecData;
        m_pdbArtistSpecData=NULL;
    }
	if (m_pdbSingerEnvData) {
        delete [] m_pdbSingerEnvData;
        m_pdbSingerEnvData=NULL;
    }
	
    m_nCurrentSingerEnvNum = 0;

    //c_KuwoDebugLog("Sentence End end", DEBUG_LOG, [GetCurTimeToString() UTF8String]);
	return nScore;
}

int CScore::GetSentenceScore()
{
    //c_KuwoDebugLog("Get Score start", DEBUG_LOG, [GetCurTimeToString() UTF8String]);
	//’“µΩ’‚“ª∂Œ∞¸¬Áµƒ◊Ó¥Ûµƒ ˝÷µ≤¢÷ÿ–¬πÈ“ªªØ
	double fAvgSingerEnv = 0.;		//’‚“ª∂Œ”√ªß—›≥™∞¸¬Áµƒ∆Ωæ˘÷µ£¨»Áπ˚≥¨π˝“ª∏ˆ„–÷µ£¨‘Ú»œŒ™Ã´œÏ¡À£¨—œ÷ÿºı∑÷
	double fPunishCoef = 1.0;		//ºÏ≤‚≥ˆ—œ÷ÿ≤ª∫√µƒµÿ∑Ωµƒ¥Ú∑÷±Í◊º
	double fEnvPunish = 1.0;
//	double fSpecPunish = 1.0;

    if (!m_pdbSingerEnvData || !m_pdbArtistEnvData) {
        return 73;
    }

	for(int i = 0; i < m_nEnvLen; i ++)
	{
		m_pdbSingerEnvData[i] *= MAX_LOG_SINGING_ENV;
		fAvgSingerEnv += m_pdbSingerEnvData[i];
		m_pdbArtistEnvData[i] *= m_fArtistEnvNormRatio;
	}


	if(m_nEnvLen > 0)
		fAvgSingerEnv /= (m_nEnvLen);

	if(fAvgSingerEnv > TOO_LOUD_TH1 || fAvgSingerEnv < TOO_SILENT_TH1)	//Ã´œÏ¡ÀªÚ’ﬂÃ´∞≤æ≤¡À
	{
		//º”“ª∏ˆ¥Ú∑÷µƒ≥Õ∑£œµ ˝
		fPunishCoef = 0.3;
	}
	else if(fAvgSingerEnv > TOO_LOUD_TH2 || fAvgSingerEnv < TOO_SILENT_TH2)	//”––©œÏªÚ’ﬂ”––©∞≤æ≤
	{
		fEnvPunish = 0.5;
	}

	for(int i = 0; i < m_nEnvLen; i ++)
	{
		m_pdbSingerEnvData[i] = pow(10., m_pdbSingerEnvData[i]);
		m_pdbArtistEnvData[i] = pow(10., m_pdbArtistEnvData[i]);
	}

	double fEnvScore = ComputeScore1(m_pdbSingerEnvData, m_pdbArtistEnvData, m_nEnvLen);
    
    /*
	int nSpecFeaLen = m_sb->m_nSpecFeaDoneNum < m_nSpecLen ? m_sb->m_nSpecFeaDoneNum : m_nSpecLen;
	//double * pArtistSpec = m_pdbArtistSpecData;
	//double * pSingerSpec = m_sb->m_pSpecFea;
	double fAvgSingerSpecFea = 0., fAvgArtistSpecFea = 0.;
	for(int i = 0; i < nSpecFeaLen; i ++)
	{
		fAvgSingerSpecFea += m_sb->m_pSpecFea[i];
		fAvgArtistSpecFea += m_pdbArtistSpecData[i];
	}

	if(nSpecFeaLen > 0)
	{
		fAvgSingerSpecFea /= nSpecFeaLen;
		fAvgArtistSpecFea /= nSpecFeaLen;
	}

	if(fAvgSingerSpecFea < CENTROID_LOW_TH1)
	{
		//º”“ª∏ˆ¥Ú∑÷µƒ≥Õ∑£œµ ˝
		if(fabs(fPunishCoef - 1) < 1e-6)
			fPunishCoef = 0.3;
		else
			fPunishCoef = 0.1;
	}
	else if(fAvgSingerSpecFea < CENTROID_LOW_TH2)
	{
		fSpecPunish = 0.7;
	}


	double fSpecScore = ComputeScore1(m_pdbArtistSpecData, m_sb->m_pSpecFea, nSpecFeaLen);	//∆µ∆◊÷––ƒµ√∑÷

	//¿˚”√◊‘œ‡πÿ∫Ø ˝µƒ◊Ó¥Û÷µµƒ¡¨–¯–‘£¨¿¥≈–∂œ «∑Ò «‘Î“Ù
	double * acr = m_sb->m_pAcr;
	int nTotalVoicedLen = 0;
	for(int i = 0; i < nSpecFeaLen; i ++)
	{
		if(acr[i] > 0.5)
			nTotalVoicedLen ++;
	}

	if((double)nTotalVoicedLen / nSpecFeaLen < 0.1)	//»œŒ™ «‘Î…˘∆¨∂Œ
	{
		fPunishCoef = 0.1;
	}

	//∆µ∆◊µ√∑÷µƒ÷√–≈∂»£¨”√¿¥»•≥˝∫ﬂ∫ﬂµƒ…˘“Ù
	double fKeyScore = fAvgSingerSpecFea > 70 ? 100 : (sqrt(fAvgSingerSpecFea / 70 * 100) * 10);	//“Ù∏ﬂµ√∑÷
    */

    //c_KuwoDebugLog("Get Score end", DEBUG_LOG, [GetCurTimeToString() UTF8String]);
	return (int)((sqrt((fEnvScore * fEnvPunish) * MAX_SCORE) * 10.)* fPunishCoef);
	//return (int)((sqrt((0.25 * fEnvScore * fEnvPunish + 0.5 * fSpecScore * fSpecPunish) * MAX_SCORE + fKeyScore * 0.25) * 10.)* fPunishCoef);
}

void CScore::Init( double dbEnvRate,int nRecWavSampleRate, int nChannel )
{
	m_fArtistEnvNormRatio = dbEnvRate;
	m_nRecSampleRate = nRecWavSampleRate;
}

void CScore::UnInit()
{
    KwTools::CAutoLock auto_lock(s_score_lock);
    m_bInitFinish = false;
    if (m_pdbArtistEnvData) {
        delete [] m_pdbArtistEnvData;
        m_pdbArtistEnvData=NULL;
    }
    if (m_pdbArtistSpecData) {
        delete [] m_pdbArtistSpecData;
        m_pdbArtistSpecData=NULL;
    }
    if (m_pdbSingerEnvData) {
        delete [] m_pdbSingerEnvData;
        m_pdbSingerEnvData=NULL;
    }
}
