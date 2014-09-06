#ifndef FFT_H
#define FFT_H

#define PI 3.14159265358979

int HammingWin(double * pWin, int N);
void ApplyWindow(double * In, double * Win, int Len, double * Out);
void UnApplyWindow(double * In, double * Win, int Len, double * Out);
void fft_double (unsigned int p_nSamples, bool p_bInverseTransform, double *p_lpRealIn, double *p_lpImagIn, double *p_lpRealOut, double *p_lpImagOut);
void PowerSpectrum(int NumSamples, double *In, double *Out);
void WindowFunc(int whichFunction, int NumSamples, float *in);
int HanningWin(double * pWin, int N);
#endif