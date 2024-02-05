/*PART I: Initialisation of the Stochastic Approximation Algorithm for background modelling from:

 Stochastic approximation for background modelling
 Ezequiel Lopez-Rubio and Rafael Marcos Luque-Baena
 Computer Vision and Image Understanding, DOI: 10.1016/j.cviu.2011.01.007

 Example usage: See the matlab file test.m 

 Authors: R.M.Luque and Ezequiel Lopez-Rubio
 Date: February 2011
*/
/*
Use the following commands to compile this MEX file at the Matlab prompt:
32-bit Windows:
mex initializeAE_MEX.c MatesLap.c Debugging.c lapack.a blas.a libf2c.a
64-bit Windows:
mex LINKFLAGS="$LINKFLAGS /NODEFAULTLIB:LIBCMT" initializeAE_MEX.c MatesLap.c Debugging.c BLAS_nowrap.lib libf2c.lib clapack_nowrap.lib
Linux:
mex initializeAE_MEX.c MatesLap.c Debugging.c libf2c.a -lmwlapack -lmwblas
*/


#include "mex.h"
#include "Mates.h"
#include "Debugging.h"

#include <stdio.h>
#include <math.h>
#include <float.h>
#include <string.h>
#include <stdlib.h>

#define MAX_VALUE 255
#define MIN_VALUE 0
/* Debug mode is activated if the variable is 1*/
#define DEBUG_MODE 0

/* For debugging porpuses a specific pixel is selected:
  * Calculate the pixel (x,y) with image size (M,N)
   MI_PIXEL = (x-1)*M + (y-1)	
   Ej: Pixel (153,430) y size (480,640)
   MI_PIXEL = (153-1)*480 + (430 - 1) = 73389
 */
#define MI_PIXEL 73389

/*
mex initializeAE_MEX.c nrutil.c eig.c lu.c svd.c Mates.c ran2.c Debug.c
*/

void GetPositionData(unsigned char* data, double * output, int NumCompColor, int Size, int NumFrames);
void MyMean(double *ptrMean,double *data,int DimColorSpace,int NumPatterns);
void MyCov(double *ptrCov,double *data,int DimColorSpace,int NumPatterns);

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )     
{
	int DimColorSpace,NumFrames,NumImageRows,NumImageColumns,NumCompUnif,NumCompGauss,NumComp; 
	long size;
	mxArray *Mu,*C,*InvC,*LogDetC,*Min,*Max,*Den;
	double *data,*ptrNumComp,*ptrNumCompUnif,*ptrNumCompGauss; /*,*ptrPi;*/
	double *ptrMyEigenvalues, *ptrMyEigenvectors, *ptrCurrentFrame;
	double *ptrMu,*ptrC,*ptrInvC,*ptrLogDetC,*ptrDen,*ptrMin,*ptrMax;
	double tmpLogDetC,tmpDen;
	const int *DimPatterns;
	register long i;
	register int NdxComp,k,NdxDim;
	unsigned char* ptrData;
	
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
		fprintf(fich,"Beginning of the initialisation process\n");
    #endif
	
	/* Get input data */
    DimPatterns=mxGetDimensions(prhs[1]);
	NumImageRows = DimPatterns[0];
	NumImageColumns = DimPatterns[1];
	DimColorSpace = DimPatterns[2];
	NumFrames=DimPatterns[3];
	ptrData = (unsigned char*) mxGetData(prhs[1]);
	size = NumImageRows * NumImageColumns;

	#if (DEBUG_MODE == 1) 
		fprintf(fich,"Building of the output model\n");
    #endif
	
	/* Duplicate the model structure */
    plhs[0]=mxDuplicateArray(prhs[0]);
        
	#if (DEBUG_MODE == 1) 
		fprintf(fich,"Getting the work variables\n");
	#endif
	
	/* Get the work variables */
	ptrNumCompGauss=mxGetPr(mxGetField(plhs[0],0,"NumCompGauss"));
	ptrCurrentFrame=mxGetPr(mxGetField(plhs[0],0,"CurrentFrame")); 
	ptrNumCompUnif=mxGetPr(mxGetField(plhs[0],0,"NumCompUnif"));
	ptrNumComp=mxGetPr(mxGetField(plhs[0],0,"NumComp"));
	/*ptrPi=mxGetPr(mxGetField(plhs[0],0,"Pi"));	*/
	
	Mu=mxGetField(plhs[0],0,"Mu");
	C=mxGetField(plhs[0],0,"C");
	InvC=mxGetField(plhs[0],0,"InvC");
	LogDetC=mxGetField(plhs[0],0,"LogDetC");
    Min=mxGetField(plhs[0],0,"Min");
    Max=mxGetField(plhs[0],0,"Max");
	Den=mxGetField(plhs[0],0,"Den");
	
	NumCompGauss =(int)(*ptrNumCompGauss);
	NumCompUnif = (int)(*ptrNumCompUnif);
	NumComp=(int)(*ptrNumComp);
	
	#if (DEBUG_MODE == 1) 
		fprintf(fich,"Allocating space for work variables\n");
	#endif
	
	/* Allocate space for work variables */
	ptrMyEigenvalues=mxMalloc(DimColorSpace*sizeof(double));
    ptrMyEigenvectors=mxMalloc(DimColorSpace*DimColorSpace*sizeof(double));
	data = (double*) mxMalloc(NumFrames * DimColorSpace * sizeof(double)); 
    
	/* Work pointers */
	ptrMu = mxGetPr(Mu);
	ptrC = mxGetPr(C);
	ptrInvC = mxGetPr(InvC);
	ptrLogDetC = mxGetPr(LogDetC);
	ptrDen = mxGetPr(Den);
	ptrMax = mxGetPr(Max);
	ptrMin = mxGetPr(Min);

	/* Frame Counter is initialised */
	*ptrCurrentFrame = 0;

	#if (DEBUG_MODE == 1) 
		fprintf(fich,"Image Width:%d Image Height:%d Dim. of the color space:%d \n", NumImageRows,NumImageColumns,DimColorSpace);
		fprintf(fich,"Gaussian distributions: %d Uniform distributions: %d In total: %d\n",NumCompGauss,NumCompUnif,NumComp);
	#endif
	
	/* For each one of the image pixels */
	for (i=0;i<size;i++)
	{
		/* The color intensity of this pixel is obtained along the sequence */
		GetPositionData(ptrData+i,data,DimColorSpace,size,NumFrames);

		#if (DEBUG_MODE == 1)
			if (i==MI_PIXEL) {
				fprintf(fich,"Initialising Pixel n� %d\n",i);
				fprintf(fich,"Data \n");
				RecordMatrixLog(fich,data,DimColorSpace,NumFrames);
			}
		#endif
		
		/* Gaussians distributions are initialised */
		for (NdxComp=0;NdxComp<NumCompGauss;NdxComp++) 
		{
			/* The a priori probability is equally intialised for all the distributions: gaussians and uniforms  */
			/*ptrPi[NdxComp] = (1.0/(double)NumComp);*/
			
            /* Both mean and covariance matrix are obtained for each pixel */
			MyMean(ptrMu,data,DimColorSpace,NumFrames);
			MyCov(ptrC,data,DimColorSpace,NumFrames);  
			SumDiagonalConstant(ptrC,1.0,ptrC,DimColorSpace);

	    	/* The inverse of the covariance matrix is computed */
			InverseNorm(ptrC,ptrInvC,NULL,NULL,DimColorSpace,DimColorSpace);
			
			/* The eigenvalues and eigenvectors are computed */
			EigValVec(ptrC,ptrMyEigenvalues,ptrMyEigenvectors,DimColorSpace);    
			
			/* The log(det C)  is also computed to improve the efficiency */
			tmpLogDetC=0.0;
			for(NdxDim=0;NdxDim<DimColorSpace;NdxDim++)
			{
				tmpLogDetC+=log(ptrMyEigenvalues[NdxDim]);
			}
			*ptrLogDetC = tmpLogDetC;

			/* Some information of the process is saved in the log file */
			#if (DEBUG_MODE == 1)
				if (i==MI_PIXEL) {
					fprintf(fich,"Pi: %f\n",*(ptrPi+NdxComp));
					fprintf(fich,"Mu\n");
					RecordMatrixLog(fich,ptrMu,1,DimColorSpace); 
					fprintf(fich,"C\n");
					RecordMatrixLog(fich,ptrC,DimColorSpace,DimColorSpace); 
				}
			#endif
			
			/* Pointers are incremented */
            ptrMu+=3;
            ptrC+=9;
            ptrInvC+=9;
            ptrLogDetC++;			
		}

		/* Uniform distributions are initialised */
		for (NdxComp=0;NdxComp<NumCompUnif;NdxComp++) 
		{
			tmpDen = 1.0;			
			/*ptrPi[NdxComp+NumCompGauss] = (1/(double)NumComp);*/

			
			for (k=0;k<DimColorSpace;k++) 
			{
				*(ptrMin) = MIN_VALUE;
				*(ptrMax) = MAX_VALUE;
				tmpDen = tmpDen * (double)(*(ptrMax)) - (*(ptrMin));
				ptrMin++;
				ptrMax++;
			}
			*ptrDen = 1/tmpDen;
			ptrDen++;
		}
		/*ptrPi+=NumComp;*/
	}

	#if (DEBUG_MODE == 1)
		fprintf(fich,"End of the initialisation process\n");
		fprintf(fich,"-------------------------------------------\n");
		/* Close the log file */
		CerrarLog(fich);
	#endif

	
	/* Release pointers */
	mxFree(ptrMyEigenvalues);
	mxFree(ptrMyEigenvectors);
	mxFree(data);
}

/* Procedure to return the color intensity of an image pixel which is pointed by 'data'. 
    The number of available frames is indicated in 'NumFrames' */
void GetPositionData(unsigned char* data, double * output, int NumCompColor, int Size, int NumFrames)
{
	unsigned char* pDataCurrent=data;
	double * ptr;
	long nSize;
	register int i,j;
	
	/* The image size is computed */
	nSize = Size*NumCompColor;
	ptr = output;

	/* The pixel is stored by getting its value in each frame */
	for (i=0;i<NumFrames;i++) 
	{
		for (j=0;j<NumCompColor;j++) 
		{
			*ptr = *(pDataCurrent+j*Size);
			ptr++;
		}
		pDataCurrent = pDataCurrent+nSize;
	}
}

/* Procedure to compute the mean of a pixel distribution  */
void MyMean(double *ptrMean,double *data,int DimColorSpace,int NumPatterns)
{
     int NdxPattern;
     
     memset(ptrMean,0,DimColorSpace*sizeof(double));
     for(NdxPattern=0;NdxPattern<NumPatterns;NdxPattern++)
     {
          MatrixSum(ptrMean,data+NdxPattern*DimColorSpace,ptrMean,DimColorSpace,1);
     }
     ScalarMatrixProduct(1.0/NumPatterns,ptrMean,ptrMean,DimColorSpace,1);
}

/* Procedure to compute the covariance matrix of a pixel distribution  */
void MyCov(double *ptrCov,double *data,int DimColorSpace,int NumPatterns)
{
     double *ptrMean;
     double *ptrDif,*ptrDifDif;
     int NdxPattern;
     
     ptrMean=malloc(DimColorSpace*sizeof(double));
     ptrDif=malloc(DimColorSpace*sizeof(double));     
     ptrDifDif=malloc(DimColorSpace*DimColorSpace*sizeof(double));     
     memset(ptrCov,0,DimColorSpace*sizeof(double));     
     MyMean(ptrMean,data,DimColorSpace,NumPatterns);
     for(NdxPattern=0;NdxPattern<NumPatterns;NdxPattern++)
     {
          MatrixDifference(data+NdxPattern*DimColorSpace,ptrMean,ptrDif,DimColorSpace,1);
          MatrixProduct(ptrDif,ptrDif,ptrDifDif,DimColorSpace,1,DimColorSpace);
          MatrixSum(ptrCov,ptrDifDif,ptrCov,DimColorSpace,DimColorSpace);          
     }
     ScalarMatrixProduct(1.0/NumPatterns,ptrCov,ptrCov,DimColorSpace,DimColorSpace);
     
     free(ptrMean);
     free(ptrDif);
     free(ptrDifDif);          
}

