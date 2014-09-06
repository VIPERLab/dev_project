#include "stdafx.h"
#include "fft.h"
#include "math.h"
#include <malloc/malloc.h>

int HammingWin(double * pWin, int N)
{
	if(malloc_size(pWin) < N * sizeof(double))
		return 1;
	for(int i = 0; i < N; i ++)
		pWin[i] = (0.54-0.46*cos(2 * PI * i / N));
	return 0;
}

int HanningWin(double * pWin, int N)
{
	if(malloc_size(pWin) < N * sizeof(double))
		return 1;
	for(int i = 0; i < N; i ++)
		pWin[i] = (0.5-0.5*cos(2 * PI * i / (N - 1)));
	return 0;
}

void ApplyWindow(double * In, double * Win, int Len, double * Out)
{
	if (NULL == In || NULL == Win || NULL == Out)
	{
		return;
	}

	for(int i = 0; i < Len; i ++)
		Out[i] = In[i] * Win[i];
}

void UnApplyWindow(double * In, double * Win, int Len, double * Out)
{
	for(int i = 0; i < Len; i ++)
		Out[i] = In[i] / Win[i];
}

unsigned int NumberOfBitsNeeded(unsigned int p_nSamples)
{

	int i;

	if( p_nSamples < 2 )
	{
		return 0;
	}

	for ( i=0; ; i++ )
	{
		if( p_nSamples & (1 << i) ) return i;
	}

}

unsigned int ReverseBits(unsigned int p_nIndex, unsigned int p_nBits)
{
	unsigned int i, rev;

	for(i=rev=0; i < p_nBits; i++)
	{
		rev = (rev << 1) | (p_nIndex & 1);
		p_nIndex >>= 1;
	}

	return rev;

}

bool IsPowerOfTwo(unsigned int p_nX)
{
	if( p_nX < 2 ) return false;

	if( p_nX & (p_nX-1) ) return false;

	return true;
}

void fft_double (unsigned int p_nSamples, bool p_bInverseTransform, double *p_lpRealIn, double *p_lpImagIn, double *p_lpRealOut, double *p_lpImagOut)
{

	if(!p_lpRealIn || !p_lpRealOut || !p_lpImagOut) return;



	unsigned int NumBits;
	unsigned int i, j, k, n;
	unsigned int BlockSize, BlockEnd;

	double angle_numerator = 2.0 * PI;
	double tr, ti;

	if( !IsPowerOfTwo(p_nSamples) )
	{
		return;
	}

	if( p_bInverseTransform ) angle_numerator = -angle_numerator;

	NumBits = NumberOfBitsNeeded ( p_nSamples );


	for( i=0; i < p_nSamples; i++ )
	{
		j = ReverseBits ( i, NumBits );
		p_lpRealOut[j] = p_lpRealIn[i];
		p_lpImagOut[j] = (p_lpImagIn == NULL) ? 0.0 : p_lpImagIn[i];
	}


	BlockEnd = 1;
	for( BlockSize = 2; BlockSize <= p_nSamples; BlockSize <<= 1 )
	{
		double delta_angle = angle_numerator / (double)BlockSize;
		double sm2 = sin( -2 * delta_angle );
		double sm1 = sin ( -delta_angle );
		double cm2 = cos ( -2 * delta_angle );
		double cm1 = cos ( -delta_angle );
		double w = 2 * cm1;
		double ar[3], ai[3];

		for( i=0; i < p_nSamples; i += BlockSize )
		{

			ar[2] = cm2;
			ar[1] = cm1;

			ai[2] = sm2;
			ai[1] = sm1;

			for ( j=i, n=0; n < BlockEnd; j++, n++ )
			{
				ar[0] = w*ar[1] - ar[2];
				ar[2] = ar[1];
				ar[1] = ar[0];

				ai[0] = w*ai[1] - ai[2];
				ai[2] = ai[1];
				ai[1] = ai[0];

				k = j + BlockEnd;
				tr = ar[0]*p_lpRealOut[k] - ai[0]*p_lpImagOut[k];
				ti = ar[0]*p_lpImagOut[k] + ai[0]*p_lpRealOut[k];

				p_lpRealOut[k] = p_lpRealOut[j] - tr;
				p_lpImagOut[k] = p_lpImagOut[j] - ti;

				p_lpRealOut[j] += tr;
				p_lpImagOut[j] += ti;

			}
		}

		BlockEnd = BlockSize;

	}


	if( p_bInverseTransform )
	{
		double denom = (double)p_nSamples;

		for ( i=0; i < p_nSamples; i++ )
		{
			p_lpRealOut[i] /= denom;
			p_lpImagOut[i] /= denom;
		}
	}

}

/*
* PowerSpectrum
*
* This function computes the same as RealFFT, above, but
* adds the squares of the real and imaginary part of each
* coefficient, extracting the power and throwing away the
* phase.
*
* For speed, it does not call RealFFT, but duplicates some
* of its code.
*/

void PowerSpectrum(int NumSamples, double *In, double *Out)
{
    if (NumSamples<4) {
        return;
    }
	int Half = NumSamples / 2;
	int i;

	double theta = PI / Half;

	double *tmpReal = new double[Half];
	double *tmpImag = new double[Half];
	double *RealOut = new double[Half];
	double *ImagOut = new double[Half];

	for (i = 0; i < Half; i++) {
		tmpReal[i] = In[2 * i];
		tmpImag[i] = In[2 * i + 1];
	}

	fft_double(Half, 0, tmpReal, tmpImag, RealOut, ImagOut);

	double wtemp = double (sin(0.5 * theta));

	double wpr = -2.0 * wtemp * wtemp;
	double wpi = double (sin(theta));
	double wr = 1.0 + wpr;
	double wi = wpi;

	int i3;

	double h1r, h1i, h2r, h2i, rt, it;

	for (i = 1; i < Half / 2; i++) {

		i3 = Half - i;

		h1r = 0.5 * (RealOut[i] + RealOut[i3]); //这里的静态代码分析警告真是无厘头看不明白啊
		h1i = 0.5 * (ImagOut[i] - ImagOut[i3]);
		h2r = 0.5 * (ImagOut[i] + ImagOut[i3]);
		h2i = -0.5 * (RealOut[i] - RealOut[i3]);

		rt = h1r + wr * h2r - wi * h2i;
		it = h1i + wr * h2i + wi * h2r;

		Out[i] = rt * rt + it * it;

		rt = h1r - wr * h2r + wi * h2i;
		it = -h1i + wr * h2i + wi * h2r;

		Out[i3] = rt * rt + it * it;

		wr = (wtemp = wr) * wpr - wi * wpi + wr;
		wi = wi * wpr + wtemp * wpi + wi;
	}

	rt = (h1r = RealOut[0]) + ImagOut[0];
	it = h1r - ImagOut[0];
	Out[0] = rt * rt + it * it;

	rt = RealOut[Half / 2];
	it = ImagOut[Half / 2];
	Out[Half / 2] = rt * rt + it * it;

	delete[]tmpReal;
	delete[]tmpImag;
	delete[]RealOut;
	delete[]ImagOut;
}

const char *WindowFuncName(int whichFunction)
{
	switch (whichFunction) {
   default:
   case 0:
	   return "Rectangular";
   case 1:
	   return "Bartlett";
   case 2:
	   return "Hamming";
   case 3:
	   return "Hanning";
	}
}

void WindowFunc(int whichFunction, int NumSamples, float *in)
{
	int i;

	if (whichFunction == 1) {
		// Bartlett (triangular) window
		for (i = 0; i < NumSamples / 2; i++) {
			in[i] *= (i / (float) (NumSamples / 2));
			in[i + (NumSamples / 2)] *=
				(float)(1.0 - (i / (float) (NumSamples / 2)));
		}
	}

	if (whichFunction == 2) {
		// Hamming
		for (i = 0; i < NumSamples; i++)
			in[i] *= (float)(0.54 - 0.46 * cos(2 * PI * i / (NumSamples - 1)));
	}

	if (whichFunction == 3) {
		// Hanning
		for (i = 0; i < NumSamples; i++)
			in[i] *= (float)(0.50 - 0.50 * cos(2 * PI * i / (NumSamples - 1)));
	}
}
