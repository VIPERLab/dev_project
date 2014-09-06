#ifndef PCM_WAV_HEADER_H
#define PCM_WAV_HEADER_H

//Attention: This header structure works only when the wav file is pcm format.
typedef unsigned short WORD;
typedef unsigned long DWORD;

struct WAVEFORM
{
	WORD wFormatTag;
	WORD nChannels;
	DWORD nSamplesPerSec;
	DWORD nAvgBytesPerSec;
	WORD nBlockAlign;
	WORD wBitsPerSample;
	WORD cbSize;
};

struct RIFF 
{
	char riffID[4];
	DWORD riffSIZE;
	char riffFORMAT[4];
};

struct FMT
{
	char fmtID[4];
	DWORD fmtSIZE;
	WAVEFORM fmtFORMAT;
};

struct DATA 
{
	char dataID[4];
	DWORD dataSIZE;
};

struct WAVE_HEADER{
	RIFF riff;
	FMT fmt;
	DATA data;
};

#endif