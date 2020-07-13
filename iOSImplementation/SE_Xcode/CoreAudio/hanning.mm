//#define M_PI
#define _USE_MATH_DEFINES
#include<stdio.h>
#include<stdlib.h>
#include<math.h>
#include<string.h>
/*
if ~rem(n, 2)
% Even length window
half = n / 2;
w = calc_hanning(half, n);
w = [w; w(end:-1 : 1)];
else
% Odd length window
half = (n + 1) / 2;
w = calc_hanning(half, n);
w = [w; w(end - 1:-1 : 1)];
end

function w = calc_hanning(m,n)
%CALC_HANNING   Calculates Hanning window samples.
%   CALC_HANNING Calculates and returns the first M points of an N point
%   Hanning window.

w = .5*(1 - cos(2*pi*(1:m)'/(n+1)));



*/
double* calc_hanning(int m, int n);
double* hanning(int n)
{
	double* w = (double *)calloc(n+1, sizeof(double));
	double* w1;
	int half;
	if (n % 2 == 0) {
		half = n / 2;
		w1 = calc_hanning(half, n);
		memcpy(w, w1, half*sizeof(double));
		for (int i = 1 ; i <= half; i++)
			w[i-1 + half] = w1[half-i];
	}
	else
	{
		half = (n + 1) / 2;
		w1 = calc_hanning(half, n);
		memcpy(w, w1, half * sizeof(double));
		for (int i = 1; i <= half; i++)
			w[i-1 + half] = w1[half-i];
	}
	return w;
}

double* calc_hanning(int m,int n)
{
	double* w = (double *) calloc(m, sizeof(double));
	double res;
	for (int i = 1; i <= m; i++) {
		res = (M_PI*2 * i)/(n + 1);
		w[i] = 0.5 * ((double)1 - cos(res));
	}
	

	return w;
}