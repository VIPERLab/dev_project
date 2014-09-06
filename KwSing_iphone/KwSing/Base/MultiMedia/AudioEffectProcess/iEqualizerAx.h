/*******************************************************************************
File:	iEqualizerAx.h
Desc:	从DXSDK中contrast例子改写而来，EqualizerAx的接口定义
Author:	Wang Lei
Date:	Apr, 2008
*******************************************************************************/

#ifndef __IEQUALIZERAX__
#define __IEQYALIZERAX__

/*extern*/ struct EqSettings;
/*extern*/ struct RevSettings;

#ifdef __cplusplus
extern "C" {
#endif
	// {10379E5F-8764-4704-9F12-3F6BCA71F277}
	DEFINE_GUID(IID_IAUDIOEQUALIZER, 
		0x10379e5f, 0x8764, 0x4704, 0x9f, 0x12, 0x3f, 0x6b, 0xca, 0x71, 0xf2, 0x77);

    DECLARE_INTERFACE_(IAudioEqReverb, IUnknown)
    {
		STDMETHOD(put_EqSetting) (THIS_			//均衡器设置接口
			const EqSettings * pCfg
		) PURE;
		STDMETHOD(put_RevSetting) (THIS_		//混音器设置接口
			const RevSettings * pCfg
		) PURE;
		STDMETHOD(enable_eq) (THIS_				//打开/关闭均衡器的接口
			bool bEnable
		) PURE;
		STDMETHOD(enable_rev) (THIS_			//打开/关闭混音器的接口
			bool bEnable
		) PURE;
		STDMETHOD(enable_dolby) (THIS_			//打开/关闭杜比环绕的接口
			bool bEnable
		) PURE;
		STDMETHOD(set_DolbyDelay) (THIS_		//设置杜比环绕的参数
			int nDelay
		) PURE;
		STDMETHOD(set_PreAmplify) (THIS_		//设置前置放大的参数（dB）
			int nDB
		) PURE;
		STDMETHOD(set_amplify) (THIS_			//设置放大系数的接口，仅在Karaoke应用中有用
			float amp
		) PURE;
		STDMETHOD(enable_send) (THIS_			//设置是否要回传数据给应用程序，仅在Karaoke应用中有用
			bool bSend
		) PURE;
		STDMETHOD(SetMessageWnd) (THIS_			//设置接受回传数据消息的窗口，仅在Karaoke应用中有用
			HWND hwnd
		) PURE;
		STDMETHOD(SetPassword) (THIS_			//设置密码
			long lPassword
		) PURE;
		STDMETHOD(GetDolbySupport) (THIS_
			IPin * pPin
		) PURE;
		STDMETHOD(get_amplify)(THIS_
			float & amp
		) PURE;
		STDMETHOD(get_PreAmplify) (THIS_		//得到前置放大的参数（dB）
			int & nDB
		) PURE;
		STDMETHOD(get_EqSetting) (THIS_			//得到均衡器设置
			EqSettings & pCfg, bool & bEnableEq
		) PURE;
		STDMETHOD(get_RevSetting) (THIS_		//得到混音器设置
			RevSettings & pCfg, bool & bEnableRev
		) PURE;
		STDMETHOD(set_SendAmplitude) (THIS_		//设置是否发送平均幅度
			BOOL bSend,
			int nPlayOrRecord	//0: Play, 1: Record
		) PURE;
		STDMETHOD(FreeTempBuf)	(THIS_			//释放发送Wav Sample时开辟的内存
			) PURE;
		STDMETHOD(FreeTotalTempBuf)	(THIS_		//释放所有发送Wav Sample时开辟的内存
			) PURE;
		STDMETHOD(RenderZero)	(THIS_			//该变量设为true，则render得所有数据都为0
			bool bRenderZero
		)	PURE;
		//STDMETHOD(set_CanStopMsgThread) (THIS_	//设置接收WM_CAN_STOP消息的线程的线程号
		//	DWORD dwCanStopThreadID
		//) PURE;
		//STDMETHOD(get_AvgAmp) (THIS_			//得到平均幅度
		//	double & fAvgAmp
		//) PURE;
    };

#ifdef __cplusplus
}
#endif

#endif // __IEQUALIZERAX__

