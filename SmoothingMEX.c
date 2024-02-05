/* Smoothing approximation algorithm applied to images from:

 Stochastic approximation for background modelling
 Ezequiel Lopez-Rubio and Rafael Marcos Luque-Baena
 Computer Vision and Image Understanding, DOI: 10.1016/j.cviu.2011.01.007

Example usage: See the matlab file Smoothing.m 
output=SmoothingMEX(image,dx,dy,K);

Use the following commands to compile this MEX file at the Matlab prompt:
mex SmoothingMEX.c Debugging.c

Authors: R.M.Luque and Ezequiel Lopez-Rubio
Date: February 2011
*/

#include "mex.h"
#include "Debugging.h"

#include <stdio.h>
#include <math.h>
#include <time.h>
#include <float.h>
#include <string.h>
#include <stdlib.h>
#include <memory.h>

/* Gavin C. Cawley. On a Fast, Compact Approximation of the Exponential Function.
Neural Computation 12, 2009�2012 (2000). Obtains 11 bit precision. */
#ifndef M_LN2
#define M_LN2 = 0.69314718055994530942
#endif

#define EXP_A 1512775.395195186
#define EXP_C 60801

__inline double exponential(double y)
{
	union
	{
		double d;
		struct { int j,i; } n;
	}
	eco;
	eco.n.i = (int)(EXP_A*(y)) + (1072693248 - EXP_C);
	eco.n.j = 0;
	return eco.d;
}

/* This is used for debugging porposes*/
#define MY_PIXEL 0
#define DEBUG_MODE 0

/* 2D Convolution 'quick & dirty'. Squared filter of odd size. Output has the same size than the original one.
The result on the edges is undefined. */
void conv2(double *ptrA,double *ptrFil,double *ptrRes,int *Offset,int NumRowsA,int NumColsA,int SizeRow);

/* Compute offsets for convolutions. */
void ComputeOffsets(int *Offset,double *DeltaFil,double *DeltaCol,int NumRowsA,int NumColsA,int SizeRow);

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )     
{
	int NumImageRows,NumImageColumns,FilterSize,NumPixels; 
	int cnt,NdxPix,NdxElemFil,NumElemsFil;
	int *Offset;
	unsigned int MiNdx;
	double *DeltaFil,*DeltaCol;
	double *ptrDx,*ptrDy,*ptrK;
	double *ptrMu_old,*ptrMu_new,*ptrC_old,*ptrC_new,*ptrPi_new,*ptrPi_old,*ptrH;
	double *ptrAux,*ptrS11,*ptrS12,*ptrS22;
	double ArgumExp,mySum,Weight;
	double const_exp, const_h;
	
	#if (DEBUG_MODE == 1) 
		/* Log variables */
		FILE * fich;
		char *fileName;
		mwSize loglen; 
		mxArray *Log;
		
		/* Get the name of the log file */
		Log = mxGetField(prhs[0],0,"Log");
		loglen = mxGetNumberOfElements(Log) + 1;
		fileName = mxMalloc(loglen*sizeof(char));

	    if (mxGetString(Log, fileName, loglen) != 0)
			mexErrMsgTxt("Could not convert string data.");
		
		fich = OpenLog(fileName);
	#endif
	
	/* Get input data */
    NumImageRows=mxGetM(prhs[1]);
	NumImageColumns=mxGetN(prhs[1]);
	FilterSize=mxGetM(prhs[3]);
	ptrDx=mxGetPr(prhs[1]);
	ptrDy=mxGetPr(prhs[2]);	
	ptrK=mxGetPr(prhs[3]);	
	
	/* Duplicate the model structure */
    plhs[0]=mxDuplicateArray(prhs[0]);

	ptrMu_old = mxGetPr(mxGetField(prhs[0],0,"Mu"));
	ptrC_old = mxGetPr(mxGetField(prhs[0],0,"C"));
	ptrPi_old = mxGetPr(mxGetField(prhs[0],0,"Pi"));
	ptrH=mxGetPr(mxGetField(plhs[0],0,"H"));		
	const_h =(double)(*ptrH);

	ptrMu_new = mxGetPr(mxGetField(plhs[0],0,"Mu"));
	ptrC_new = mxGetPr(mxGetField(plhs[0],0,"C"));
	ptrPi_new = mxGetPr(mxGetField(plhs[0],0,"Pi"));
	memset(ptrMu_new,0,NumImageRows*NumImageColumns*3*sizeof(double));
	memset(ptrC_new,0,NumImageRows*NumImageColumns*9*sizeof(double));
	memset(ptrPi_new,0,NumImageRows*NumImageColumns*sizeof(double));
	
	/* Get the work variables */
	ptrAux=(double *)mxMalloc(NumImageRows*NumImageColumns*sizeof(double));
	ptrS11=(double *)mxMalloc(NumImageRows*NumImageColumns*sizeof(double));
	ptrS12=(double *)mxMalloc(NumImageRows*NumImageColumns*sizeof(double));
	ptrS22=(double *)mxMalloc(NumImageRows*NumImageColumns*sizeof(double));    
    Offset=(int *)mxMalloc(FilterSize*FilterSize*sizeof(int));	
    DeltaFil=(double *)mxMalloc(FilterSize*FilterSize*sizeof(double));	
    DeltaCol=(double *)mxMalloc(FilterSize*FilterSize*sizeof(double));	
	NumPixels=NumImageRows*NumImageColumns;
	NumElemsFil=FilterSize*FilterSize;
	
	memset(ptrS11,0,NumImageRows*NumImageColumns*sizeof(double));
	memset(ptrS12,0,NumImageRows*NumImageColumns*sizeof(double));
	memset(ptrS22,0,NumImageRows*NumImageColumns*sizeof(double));
	
	const_exp = -(0.5/const_h/const_h);

	/* Offsets are computed for the convolution process */
    ComputeOffsets(Offset,DeltaFil,DeltaCol,NumImageRows,NumImageColumns,FilterSize);

    /* Obtain the elements for the "local gradient covariance matrix" */
	/* xx=dx.*dx; */
	for(cnt=0;cnt<NumPixels;cnt++)
	{
        ptrAux[cnt]=ptrDx[cnt]*ptrDx[cnt];
    }
    conv2(ptrAux,ptrK,ptrS11,Offset,NumImageRows,NumImageColumns,FilterSize);
    
	/* xy=dx.*dy; */
	for(cnt=0;cnt<NumPixels;cnt++)
	{
        ptrAux[cnt]=ptrDx[cnt]*ptrDy[cnt];
    }
    conv2(ptrAux,ptrK,ptrS12,Offset,NumImageRows,NumImageColumns,FilterSize);

	/* yy=dy.*dy; */
	for(cnt=0;cnt<NumPixels;cnt++)
	{
        ptrAux[cnt]=ptrDy[cnt]*ptrDy[cnt];
    }
    conv2(ptrAux,ptrK,ptrS22,Offset,NumImageRows,NumImageColumns,FilterSize);
        
    /* Smooth the input image */
    for(NdxPix=0;NdxPix<NumPixels;NdxPix++)
    {
		 /* Get the output pixel value */
		 mySum=0.0;
		 
		 for(NdxElemFil=0;NdxElemFil<NumElemsFil;NdxElemFil++)
		 {
			 MiNdx=NdxPix+Offset[NdxElemFil];
			 if (MiNdx<NumPixels)
			 {
				 ArgumExp=const_exp*( 
					  (DeltaCol[NdxElemFil]*ptrS11[NdxPix]+
					  DeltaFil[NdxElemFil]*ptrS12[NdxPix])*DeltaCol[NdxElemFil]
					  +
					  (DeltaCol[NdxElemFil]*ptrS12[NdxPix]+
					  DeltaFil[NdxElemFil]*ptrS22[NdxPix])*DeltaFil[NdxElemFil]);
				 Weight=exponential(ArgumExp);
				 mySum+=Weight;
						
				 /* Modification of the mean (3 components) */
				(*ptrMu_new)+=ptrMu_old[MiNdx]*Weight;                
				ptrMu_new[NumPixels]+=ptrMu_old[MiNdx+NumPixels]*Weight;                
				ptrMu_new[2*NumPixels]+=ptrMu_old[MiNdx+2*NumPixels]*Weight;
				/* Modification of the weights (1 component) */
				(*ptrPi_new)+=ptrPi_old[MiNdx]*Weight;
				/* Modification of the covariance matrix (6 components) */
				(*ptrC_new)+=ptrC_old[MiNdx]*Weight;
				ptrC_new[NumPixels]+=ptrC_old[MiNdx+NumPixels]*Weight;                
				ptrC_new[2*NumPixels]+=ptrC_old[MiNdx+2*NumPixels]*Weight;                
				ptrC_new[4*NumPixels]+=ptrC_old[MiNdx+4*NumPixels]*Weight;                
				ptrC_new[5*NumPixels]+=ptrC_old[MiNdx+5*NumPixels]*Weight;                
				ptrC_new[8*NumPixels]+=ptrC_old[MiNdx+8*NumPixels]*Weight;                
			 }
		 }   
		 /* Check if the pixel is suitable */
		 if (mySum>0.0) {
			  (*ptrMu_new)/=mySum;
			  ptrMu_new[NumPixels]/=mySum;
			  ptrMu_new[2*NumPixels]/=mySum;
			  (*ptrPi_new)/=mySum;
			  (*ptrC_new)/=mySum;
			  ptrC_new[NumPixels]/=mySum;
			  ptrC_new[2*NumPixels]/=mySum;
			  ptrC_new[4*NumPixels]/=mySum;
			  ptrC_new[5*NumPixels]/=mySum;
			  ptrC_new[8*NumPixels]/=mySum;
		 }
		 else {
			  (*ptrMu_new)=ptrMu_old[NdxPix];
			  ptrMu_new[NumPixels]=ptrMu_old[NdxPix+NumPixels];
			  ptrMu_new[2*NumPixels]=ptrMu_old[NdxPix+2*NumPixels];
			  (*ptrPi_new)=ptrPi_old[NdxPix];
			  (*ptrC_new)=ptrC_old[NdxPix];
			  ptrC_new[NumPixels]=ptrC_old[NdxPix+NumPixels];
			  ptrC_new[2*NumPixels]=ptrC_old[NdxPix+2*NumPixels];
			  ptrC_new[4*NumPixels]=ptrC_old[NdxPix+4*NumPixels];
			  ptrC_new[5*NumPixels]=ptrC_old[NdxPix+5*NumPixels];
			  ptrC_new[8*NumPixels]=ptrC_old[NdxPix+8*NumPixels];
		 }

		 ptrC_new[3*NumPixels]=ptrC_new[NumPixels];
		 ptrC_new[6*NumPixels]=ptrC_new[2*NumPixels];
		 ptrC_new[7*NumPixels]=ptrC_new[5*NumPixels];

  		 ptrMu_new++;         
 		 ptrPi_new++;
		 ptrC_new++;
    }

	#if (DEBUG_MODE == 1) 
		/*Close the log file */
		CloseLog(fich);
	#endif
	
	/* Release memmory */
	mxFree(ptrAux);
	mxFree(ptrS11);
	mxFree(ptrS12);
	mxFree(ptrS22);
	mxFree(Offset);
	mxFree(DeltaFil);
	mxFree(DeltaCol);    	
}


/* Offsets are computed for convolutions */
void ComputeOffsets(int *Offset,double *DeltaFil,double *DeltaCol,int NumRowsA,int NumColsA,int SizeRow)
{
     int NdxRow,NdxCol,NdxValue,Middle;

     Middle=(SizeRow-1)/2;
     /* Offsets are computed inside A */
     NdxValue=0;     
     for(NdxRow=0;NdxRow<SizeRow;NdxRow++)
     {
          for(NdxCol=0;NdxCol<SizeRow;NdxCol++)
          {
               Offset[NdxValue]=NdxRow-Middle+NumRowsA*(NdxCol-Middle);
               DeltaFil[NdxValue]=NdxRow-Middle;
               DeltaCol[NdxValue]=NdxCol-Middle;
               NdxValue++;
          }
     }
}

/* 2D Convolution 'quick & dirty'. Squared filter of odd size. Output has the same size than the original one.
The result on the edges is undefined. */
void conv2(double *ptrA,double *ptrFil,double *ptrRes,int *Offset,int NumRowsA,int NumColsA,int SizeRow)
{
     int NumElemsA;
     int NdxElemA,NdxElemFil,NumElemsFil;
     unsigned int MiNdx;

     NumElemsA=NumRowsA*NumColsA;
     NumElemsFil=SizeRow*SizeRow;
     
     /* Perform convolution */
     for(NdxElemA=0;NdxElemA<NumElemsA;NdxElemA++)
     {            
         for(NdxElemFil=0;NdxElemFil<NumElemsFil;NdxElemFil++)
         {
             MiNdx=NdxElemA+Offset[NdxElemFil];
			 /* As it is an unsigned variable, it is not necessary to check MiNdx>=0 */
             if (MiNdx<NumElemsA)
             {
                (*ptrRes)+=ptrA[MiNdx]*ptrFil[NdxElemFil];
             }
         }   
         ptrRes++;                     
     }
      
}     



