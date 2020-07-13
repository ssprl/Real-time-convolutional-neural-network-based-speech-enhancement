#define _USE_MATH_DEFINES
#define _CRT_SECURE_NO_WARNINGS

#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>
#include"Transforms.h"

void transformMagnitude(Transform* transform, float* output);
void FFT(Transform* fft, float* input);
void IFFT(Transform* fft, float* inputreal, float* inputimaginary);
float* calc_hanning(int m, int n);
float* hanning(int n);
void jmap(float* input, float* output, int nSamples, int Srate, float beta)
{
	float spu = 0;
	float PERC = 50;
	//FILE *f = fopen("Test.txt", "w");
	int len1; int len2;
	float *win;
	float sum = 0;
	int k;
	
	float angle;
	int len = (int)floor(20 * Srate / 1000);// % Frame size in samples
	int nFFT = 1024;//  2 * len;
	int j = 1;
	float *sig_re = (float*)calloc(nFFT, sizeof(float));
	float *sig_img = (float*)calloc(nFFT, sizeof(float));
	float* noise_mean = (float*)calloc(nFFT, sizeof(float));
	float* noise_pow = (float*)calloc(nFFT, sizeof(float));
	float* noise_mu = (float*)calloc(nFFT, sizeof(float));
	float* noise_mu2 = (float*)calloc(nFFT, sizeof(float));
	float* xwin = (float*)calloc(nFFT, sizeof(float));
	float* temp = (float*)calloc(nFFT, sizeof(float));
	float max;
	float* ksi = (float *)calloc(nFFT, sizeof(float));
	//float* ksi_min = (float *)calloc(nFFT, sizeof(float));
	float* Xk_prev = (float *)calloc(nFFT, sizeof(float));
	float* log_sigma_k = (float *)calloc(nFFT, sizeof(float));
	float* vk = (float *)calloc(nFFT, sizeof(float));
	float* hw = (float *)calloc(nFFT, sizeof(float));
	float* evk = (float *)calloc(nFFT, sizeof(float));
	float* Lambda = (float *)calloc(nFFT, sizeof(float));
	float* pSAP = (float *)calloc(nFFT, sizeof(float));
	float* sig = (float *)calloc(nFFT, sizeof(float));
	float* insign = (float *)calloc(nFFT, sizeof(float));
	float* sig2 = (float*)calloc(nFFT, sizeof(float));
	float* gammak = (float*)calloc(nFFT, sizeof(float));
	Transform* Xx; 
	Transform* spec;
	if (len % 2 == 1)
		len = len + 1;

	// % window overlap in percent of frame size
	
		len1 = (int) floor(len*PERC / 100);
		
		len2 = len - len1;

		int Nframes = (int)floor(182347 / len2) - 1;
		float* xfinal = (float*)calloc(Nframes*len2, sizeof(float));
		float* x_old = (float *)calloc(len1, sizeof(float));
		win= hanning(len); // % define window
		
	for (int i = 0; i < len; i++)
		sum += win[i];
	//printf("%0.32lf\n", sum);


	for (int i = 0; i < len; i++)
		win[i] = win[i]*len2 / sum;
	
	


	Xx = newTransform(nFFT);
	
	for (int k = 0; k < 6; k++) 
	{
		for (int i = 0; i < len; i++)
		xwin[i] = win[i] * input[k*len+i];
	
		

		Xx->doTransform(Xx, xwin);
		//FFT(Xx,xwin);
		transformMagnitude(Xx,temp);
		

		for (int i = 0; i < nFFT; i++)
		noise_mean[i] += temp[i];
		
	}
	
		
	for (int i = 0; i < nFFT; i++) {
		noise_mu[i] = noise_mean[i] / 6;
		noise_mu2[i] = pow(noise_mu[i], 2);
	}

	
	//printf("%lf\n", noise_mu2[641]);
	//%-- - allocate memory and initialize various variables

		
//	% -------------- - Initialize parameters------------
	//	%
//		k = 1;
float	aa = 0.98;
float 	eta = 0.15;
float	qk = 0.3;
float	qkr = (1 - qk) / qk;
float	ksi_min = pow(10,((double)-25 /(double)10));// % note that in Chap. 7, ref.[17], ksi_min(dB) = -15 dB is recommended
float	count = 0;
float  sum_log_sigma_k = 0;
int SPU = 0;
Transform *xi_w;
k = 1;

//%= == == == == == == == == == == == == == == == Start Processing == == == == == == == == == == == == == == == == == == == == == == == == == == == =
//%
//for n = 1:Nframes
for (int n = 1; n <= Nframes; n++)
{
	for (int i = 0; i < len; i++) {
	//	insign[i] = win[i] * x[(n - 1)*len2 + i];
		insign[i] = win[i] * input[(k-1) + i];
		//printf("insign[%d] = %0.16lf\n", i, insign[i]);
	}


	//%-- - Take fourier transform of  frame
	
	
	spec = newTransform(nFFT);
	//FFT(spec, insign);
	spec->doTransform(spec, insign);

// % compute the magnitude
	
	transformMagnitude(spec, sig);

	

	for (int i = 0; i < nFFT; i++)
		sig2[i] = pow(sig[i], 2);
	
		//  % posteriori SNR

	
	for(int i=0;i<nFFT;i++)
	 gammak[i] = sig2[i]/noise_mu2[i] < 40 ? sig2[i] / noise_mu2[i] : 40;

	


	if (n == 1)
	{
		for (int i = 0; i < nFFT; i++)
		{
			max = gammak[i] - 1 > 0 ? gammak[i] - 1 : 0;
			ksi[i] = aa + (1 - aa)*max;
		}
	}
	else
	{
		for (int i = 0; i < nFFT; i++)
		{
			max = gammak[i] - 1 > 0 ? gammak[i] - 1 : 0;
			ksi[i] = aa*(Xk_prev[i]/noise_mu2[i]) + (1 - aa)*max;
			ksi[i] = ksi_min > ksi[i] ? ksi_min : ksi[i];
		}
	}

//	for (int i = 0; i<nFFT; i++)
//	fprintf(f, "%0.32lf\n", ksi[i]);

//	fclose(f);

	
	sum_log_sigma_k = 0;
	for (int i = 0; i < nFFT; i++)
	{
		log_sigma_k[i] = gammak[i] * ksi[i] / (1 + ksi[i]) - log(1 + ksi[i]);
		sum_log_sigma_k += log_sigma_k[i];
	}
		

	float vad_decision = sum_log_sigma_k / nFFT;

	
	
	


		if (vad_decision < eta)// % noise on
		{	
			for (int i = 0; i < nFFT; i++)
				noise_pow[i] = noise_pow[i] + noise_mu2[i];

			count = count + 1;
		}
		
		for(int i=0;i<nFFT;i++)
		noise_mu2[i] = noise_pow[i] / count;

		for (int i = 0; i < nFFT; i++)
			vk[i] = ksi[i] * gammak[i]/(1+ksi[i]);

		for (int i = 0; i < nFFT; i++)
			hw[i] = (ksi[i] + sqrt(pow(ksi[i], 2) + (1 + ksi[i] / beta)*ksi[i] / gammak[i])) / (2 * (beta + ksi[i]));
//	% -- - estimate speech presence probability
		
		if(SPU == 1)
	
			for (int i = 0; i < nFFT; i++)
			{
				evk[i] = exp(vk[i]);
				Lambda[i] = qkr*evk[i] / (1 + ksi[i]);
				pSAP[i] = Lambda[i] / (1 + Lambda[i]);
				sig[i] = sig[i] * hw[i] * pSAP[i];
			}
		else
			for (int i = 0; i < nFFT; i++)
			sig[i] = sig[i]*hw[i];
	

//		% save for estimation of a priori SNR in next frame
		for (int i = 0; i < nFFT; i++)
		Xk_prev[i] = pow(sig[i],2);
		
		for (int i = 0; i < nFFT; i++) {
			angle = atan2(spec->imaginary[i],spec->real[i]);
			sig_re[i] = cos(angle)*sig[i];
			sig_img[i] = sin(angle)*sig[i];
		}
		
		xi_w=newTransform(nFFT);
		xi_w->invTransform(xi_w, sig_re,sig_img);

		for (int i = 0; i < len2; i++) {
			output[(k - 1) + i] = x_old[i] + xi_w->real[i];
		//	printf("xfinal[%d] = %0.16lf\n", (k - 1) + i, xfinal[(k - 1) + i]);
		}
	for (int i = 0; i < len2; i++)
	x_old[i] = xi_w->real[len1 + i];
	

	k = k + len2;

}

}


float* hanning(int n)
{
	float* w = (float *)calloc(n + 1, sizeof(float));
	float* w1;
	int half;
	if (n % 2 == 0) {
		half = n / 2;
		w1 = calc_hanning(half, n);
		memcpy(w, w1, half * sizeof(float));
		for (int i = 1; i <= half; i++)
			w[i - 1 + half] = w1[half - i];
	}
	else
	{
		half = (n + 1) / 2;
		w1 = calc_hanning(half, n);
		memcpy(w, w1, half * sizeof(float));
		for (int i = 1; i <= half; i++)
			w[i - 1 + half] = w1[half - i];
	}

	return w;
}

float* calc_hanning(int m, int n)
{
	float* w = (float *)calloc(m, sizeof(float));
	float res;
	for (int i = 1; i <= m; i++) {
		res = ((float)M_PI * 2 * i) / (n + 1);
		w[i-1] = 0.5 * ((float)1 - (float)cos(res));
	}
	return w;
}
