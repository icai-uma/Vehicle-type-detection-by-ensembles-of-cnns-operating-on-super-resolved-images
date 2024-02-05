/* PART II: Update of the Stochastic Approximation Algorithm for background modelling from:

 Stochastic approximation for background modelling
 Ezequiel Lopez-Rubio and Rafael Marcos Luque-Baena
 Computer Vision and Image Understanding, DOI: 10.1016/j.cviu.2011.01.007

Example usage: See the matlab file test.m 

 Please note that the code is optimised for one gaussian and one uniform distribution, 
 so it does not work with another combination. 

Authors: R.M.Luque and Ezequiel Lopez-Rubio
Date: February 2011
*/

/*
Use the following commands to compile this MEX file at the Matlab prompt:
32-bit Windows:
mex updateAE_MEX.c MatesLap.c Debugging.c lapack.a blas.a libf2c.a
64-bit Windows:
mex LINKFLAGS="$LINKFLAGS /NODEFAULTLIB:LIBCMT" updateAE_MEX.c MatesLap.c Debugging.c BLAS_nowrap.lib libf2c.lib clapack_nowrap.lib
Linux:
mex updateAE_MEX.c MatesLap.c Debugging.c libf2c.a -lmwlapack -lmwblas

*/

#include "mex.h"
#include "Mates.h"
#include "Debugging.h"

#include <stdio.h>
#include <math.h>
#include <time.h>
#include <float.h>
#include <string.h>
#include <stdlib.h>
#include <memory.h>

/* Determinant of a 2x2 submatrix */
#define DET2(a,b,c,d) (ptrC[a]*ptrC[d]-ptrC[b]*ptrC[c])

#pragma float_control( except, off )   /* disable exception semantics*/
#pragma float_control( precise, off )  /* disable precise semantics*/
#pragma fp_contract(on)                /* enable contractions*/
#pragma fenv_access(off)               /* disable fpu environment sensitivity*/

/*---------------------------------------
 * Functions which return if the value is NaN or INF
 * They are needed because the Microsoft compiler (.NET 2008) does not include them as primitives 
 * (does not include the C99 especification)
 */
#ifndef isnan
bool isnan(double x) {
    return x != x;
}
#endif

#ifndef isinf
bool isinf(double x) {
    return ((x - x) != 0);
}
#endif
/* ------------------------------------------------------ */
#define REINITIALISATION_MODE 1

/* This is used for debugging porposes*/
#define DEBUG_MODE 0
#define MY_PIXEL 0

/* Definition of pi number if it is not previously defined */
#ifndef M_PI
#define M_PI 3.141615
#endif


int DimColorSpace;
FILE * fich;

/* Calcular offsets para convoluciones */
void HallarOffsets(int *Offset,int NdxPixel,int NumFilasA);
void HallarOffsets8vecinos(int *Offset,int NdxPixel,int NumFilasA,int NumColsA);
void PosicionFilaColumna(int NdxPixel,int NumFilasA,int *col,int *fila);

void PixelInitialisation(long i,double *ptrMu,double *ptrMuFore,double *ptrC,double *ptrInvC,double *ptrLogDetC,double *ptrNoise,double *ptrCounter,double *ptrPattern);

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )     
{
	int NumImageRows,NumImageColumns,NumCompUnif,NumCompGauss,NumComp,CurrentFrame,Z,NdxCorr; 
	int Offset[8],fil,col;
	long size;
	mxArray *Mu,*C,*InvC,*LogDetC,*Min,*Max,*Den,*Counter,*MuFore;
	double *Pattern,*ptrEpsilon,*ptrNumComp,*ptrNumCompUnif,*ptrNumCompGauss,*ptrPi;
	double *ptrCounter,*ptrNoise,*ptrMuFore,*ptrZ,*ptrVar,*ptrCov;
	double *ptrCurrentFrame,*pDataResp,*ptrOutput;
	double LogDensityProb,LearningRate,OneLessLearningRate,AntPi,CoefOld,CoefNew,CoefOldFore,CoefNewFore;
	double Sigma2_Red,Sigma2_Green,Sigma2_Blue;
	double LearningRateFore,OneLessLearningRateFore,PiFore,ptrVectorProd[9],ptrVectorDif[3],ptrResponsibilities[2];
	const int *DimPatterns;
	double MyLogDensity,respY,corrY,numerador,denominador,sqrtVarY,sqrtVarX;
	double DistMahal,tempVar,tempVarY,suma;
	double *ptrMu,*ptrC,*ptrInvC,*ptrLogDetC,*ptrDen,*ptrMin,*ptrMax;
	double *CorrOri,*Corr,*MiCorr,*NewOutput,*NewOutputOri;
	int contadorTrunc,cont;
	int DimResp[3];
	register long i;
	double DetC,InvDetC;
	unsigned char *ptrData, *pDataCurrentR, *pDataCurrentG, *pDataCurrentB;
	
	#if (DEBUG_MODE == 1) 
		/*Log variables*/
		char *fileName;
		mwSize loglen; 
		mxArray *Log;
		
		/* Getting the name of the log file*/
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
	ptrData = (unsigned char*) mxGetData(prhs[1]);
	size = NumImageRows * NumImageColumns;

	pDataCurrentR=ptrData;/*separate R G and B images*/
	pDataCurrentG=ptrData+size;
	pDataCurrentB=ptrData+2*size;

	/* Duplicate the model structure */
    plhs[0]=mxDuplicateArray(prhs[0]);

	/* Get the work variables */
	ptrNumCompGauss=mxGetPr(mxGetField(plhs[0],0,"NumCompGauss"));
	ptrNumCompUnif=mxGetPr(mxGetField(plhs[0],0,"NumCompUnif"));
	ptrNumComp=mxGetPr(mxGetField(plhs[0],0,"NumComp"));
	ptrEpsilon=mxGetPr(mxGetField(plhs[0],0,"Epsilon"));
	ptrPi=mxGetPr(mxGetField(plhs[0],0,"Pi"));

	Mu=mxGetField(plhs[0],0,"Mu");
	MuFore=mxGetField(plhs[0],0,"MuFore");
	C=mxGetField(plhs[0],0,"C");
	InvC=mxGetField(plhs[0],0,"InvC");
	LogDetC=mxGetField(plhs[0],0,"LogDetC");
    Min=mxGetField(plhs[0],0,"Min");
    Max=mxGetField(plhs[0],0,"Max");
	Den=mxGetField(plhs[0],0,"Den");
	Counter=mxGetField(plhs[0],0,"Counter");
	ptrVar=mxGetPr(mxGetField(plhs[0],0,"Var"));
	ptrCov=mxGetPr(mxGetField(plhs[0],0,"Cov"));
	
	NumCompGauss =(int)(*ptrNumCompGauss);
	NumCompUnif = (int)(*ptrNumCompUnif);
	NumComp=(int)(*ptrNumComp);

	/* Noise values for each color components (R,G,B)  */
	ptrNoise=mxGetPr(mxGetField(plhs[0],0,"Noise"));
	Sigma2_Red=(double)(*ptrNoise);
	Sigma2_Green=(double)(*(ptrNoise+1));
	Sigma2_Blue=(double)(*(ptrNoise+2));

	/* Work pointers */
	ptrMu = mxGetPr(Mu);
	ptrMuFore = mxGetPr(MuFore);
	ptrC = mxGetPr(C);
	ptrInvC = mxGetPr(InvC);
	ptrLogDetC = mxGetPr(LogDetC);
	ptrDen = mxGetPr(Den);
	ptrMax = mxGetPr(Max);
	ptrMin = mxGetPr(Min);
	ptrCounter = mxGetPr(Counter);

	#if (REINITIALISATION_MODE == 1)  
		ptrZ=mxGetPr(mxGetField(plhs[0],0,"Z"));
		Z = (int)(*ptrZ);	
		#if (DEBUG_MODE == 1) 
			fprintf(fich,"Z value for pixel reinitialisation: %d\n", Z);
		#endif
	#endif

	/* Create a matrix for the return argument */
	DimResp[0]=DimPatterns[0];
	DimResp[1]=DimPatterns[1];
	DimResp[2] = NumComp;
	plhs[1] = mxCreateNumericArray(2,DimPatterns,mxDOUBLE_CLASS, mxREAL);
	plhs[2] = mxCreateNumericArray(3,DimResp,mxDOUBLE_CLASS, mxREAL);

	/* Assign pointers to the various parameters */
	ptrOutput = (double*) mxGetData(plhs[1]);
	pDataResp = (double*) mxGetData(plhs[2]);
	
	Pattern = (double *)mxMalloc(DimColorSpace*sizeof(double));
	NewOutputOri=mxMalloc(NumImageColumns*NumImageRows*sizeof(double));
	CorrOri=mxMalloc(4*NumImageColumns*NumImageRows*sizeof(double));
	
	/* Update the current frame */
	ptrCurrentFrame=mxGetPr(mxGetField(plhs[0],0,"CurrentFrame")); 
	(*ptrCurrentFrame) = (*ptrCurrentFrame) + 1.0;
	CurrentFrame=(int)(*ptrCurrentFrame);

	#if (DEBUG_MODE == 1)  
		if (CurrentFrame == 1) {
			fprintf(fich,"Beginning of the update process\n");
			fprintf(fich,"Sequence noise: ");
			RecordMatrixLog(fich,ptrNoise,1,DimColorSpace); 
		}
		fprintf(fich,"Current frame n�: %d\n", CurrentFrame);	
	#endif
	
	/* Load the learning rate */
	LearningRate=(*ptrEpsilon);
    OneLessLearningRate=1.0-LearningRate;
	LearningRateFore=(*ptrEpsilon);
	OneLessLearningRateFore=1.0-LearningRateFore;

	/* ******************************************************************* */
	/*               RESPONSIBILITY AND VARIANCE COMPUTATION               */
	/* ******************************************************************* */
      
	/* For each one of the image pixels */
	for (i=0;i<size;i++)
	{
		/* MATLAB code: Pattern = Patterns(:,NdxPattern); */
		*Pattern = *pDataCurrentR++;
		*(Pattern+1) = *pDataCurrentG++;
		*(Pattern+2) = *pDataCurrentB++;
	
		/* The pixel is reinitialised if it belongs to the foreground too much time */
		#if (REINITIALISATION_MODE == 1)  
		if (*ptrCounter > Z) PixelInitialisation(i,ptrMu,ptrMuFore,ptrC,ptrInvC,ptrLogDetC,ptrNoise,ptrCounter,Pattern);
		#endif

		/* ------------------------------------------------------------------------------ */ 
		/* Start of the code to compute the responsibilities */
        /* ------------------------------------------------------------------------------ */
		LogDensityProb = 0.0;
		ptrVectorDif[0]=Pattern[0]-ptrMu[0];
		ptrVectorDif[1]=Pattern[1]-ptrMu[1];
		ptrVectorDif[2]=Pattern[2]-ptrMu[2];
		    
		/* MATLAB code: Differences(:,NdxPattern)'*Model.InvC{NdxCompGauss}*Diferencias(:,NdxPattern)); */
		ptrVectorProd[0]=ptrVectorDif[0]*ptrInvC[0]+ptrVectorDif[1]*ptrInvC[1]+
			 ptrVectorDif[2]*ptrInvC[2];
		ptrVectorProd[1]=ptrVectorDif[0]*ptrInvC[3]+ptrVectorDif[1]*ptrInvC[4]+
			 ptrVectorDif[2]*ptrInvC[5];
		ptrVectorProd[2]=ptrVectorDif[0]*ptrInvC[6]+ptrVectorDif[1]*ptrInvC[7]+
			 ptrVectorDif[2]*ptrInvC[8];
	         
		DistMahal=ptrVectorProd[0]*ptrVectorDif[0]+ptrVectorProd[1]*ptrVectorDif[1]+
			 ptrVectorProd[2]*ptrVectorDif[2];
	         
		/* LogConstante=-0.5*DimColorSpace*log(2*M_PI)-0.5*(*ptrLogDetC); */
		MyLogDensity=-2.756815599614018-0.5*(*ptrLogDetC)-0.5*DistMahal;

		/* MATLAB code: p(t sub n | i);  ptrResponsibilities[NdxComp]=Model.Pi(NdxCompGauss)*exp(MyLogDensity); */
		(*ptrResponsibilities) = (*ptrPi)*exp(MyLogDensity);

		/* Discard NaN and INF values for responsibilities  */
		if (isnan(*ptrResponsibilities) || isinf(*ptrResponsibilities))
		{
			(*ptrResponsibilities) = 0.0;
		}

		/* Compute the conditional probabilities for belonging to the uniform and gaussian distributions */
		ptrResponsibilities[1] = (ptrPi[1])*(*ptrDen);

		LogDensityProb = ptrResponsibilities[0]+ptrResponsibilities[1];
		/* Normalise the responsibilities using the LogDensity value. An extremely low value is added to the denominator 
		  * in order to have a bigger value than 0 */
		ptrResponsibilities[0] = ptrResponsibilities[0]/(LogDensityProb + 0.000000001);
		ptrResponsibilities[1] = ptrResponsibilities[1]/(LogDensityProb + 0.000000001);
		/* ------------------------------------------------------------------------------ */
		/* End of the code to compute the responsibilities */
		/* ------------------------------------------------------------------------------ */
			
		#if (DEBUG_MODE == 1)
			if (i==MY_PIXEL) {
				fprintf(fich,"Pixel n� %d\n",i);	
				RecordMatrixLog(fich,Pattern,1,DimColorSpace);
				fprintf(fich,"Responsibilities: ");
				RecordMatrixLog(fich,ptrResponsibilities,1,NumComp);
			}
		#endif
		
		/* The responsibilities are also returned  */
		*(pDataResp) = *(ptrResponsibilities);
		*(pDataResp + size) = ptrResponsibilities[1];
		
	
		/* Pointers asociated to the gaussian distribution are incremented */
        ptrPi++;
        ptrMu+=3;
		ptrMuFore+=3;
        ptrC+=9;
        ptrInvC+=9;
        ptrLogDetC++;
		
		/* Pointers asociated to the uniform distribution are incremented */
		ptrPi++;
		
		/* The output is the responsibility of the gaussian distribution (between 0 and 1). 
		  * The higher the value, the more probability to belong to the background of the sequence. 
		  * It is considered that the gaussian distribnution models the background of the sequence whereas the 
		  * the uniform distribution deal with the foreground part */
		*(ptrOutput) = ptrResponsibilities[0];

		/* The counter is incremented if the pixel belongs to the foreground */
		if (ptrResponsibilities[0] < 0.5) (*ptrCounter)+=1;
		else (*ptrCounter)=0;

		/* Pearson correlation computation */
		/* var = (1-step_size)*var + step_size*(P(Uniform | t) - resp_fore)^2 */
		tempVar = ((1.0-*ptrOutput) - *ptrPi);
		(*ptrVar)=OneLessLearningRate*(*ptrVar)+LearningRate*(tempVar*tempVar);

		HallarOffsets(Offset,i,NumImageRows);
		for (NdxCorr=0;NdxCorr<4;NdxCorr++) 
		{
			if (Offset[NdxCorr] != 0) {
				tempVarY = 1.0-*(ptrOutput + Offset[NdxCorr]) - (*(ptrPi + 2*Offset[NdxCorr]));
				ptrCov[NdxCorr]=OneLessLearningRate*ptrCov[NdxCorr]+LearningRate*(tempVar*tempVarY);	
			}
			else ptrCov[NdxCorr]=0.0;
		}
		
		/* Global pointers are incremented */
		pDataResp++;
		ptrOutput++;
		ptrCounter++;
		ptrVar++;		
		ptrCov+=4;
	}

	/* ******************************************************************* */
	/*           PEARSON CORRELATION COMPUTATION                           */
	/* ******************************************************************* */


	
    Corr = CorrOri;
	ptrVar=mxGetPr(mxGetField(plhs[0],0,"Var"));
	ptrCov=mxGetPr(mxGetField(plhs[0],0,"Cov"));

	for(i=0;i<size;i++)
	{
		sqrtVarX = sqrt(*ptrVar);
		MiCorr = Corr;

		HallarOffsets(Offset,i,NumImageRows);
		for (NdxCorr=0;NdxCorr<4;NdxCorr++) 
		{
			if (Offset[NdxCorr] != 0) {
				
				sqrtVarY = sqrt(*(ptrVar + Offset[NdxCorr]));
				MiCorr[NdxCorr] = (ptrCov[NdxCorr])/(sqrtVarX*sqrtVarY);

				#if (DEBUG_MODE == 1)
					if (i==MY_PIXEL) {
						fprintf(fich,"Posicion: %d, SqrtVarX: %f, SqrtVarY: %f, Cov: %f, Corr: %f \n",NdxCorr,sqrtVarX,sqrtVarY,ptrCov[NdxCorr],MiCorr[NdxCorr]);	
					}
				#endif
	
			}
			else MiCorr[NdxCorr]=0.0;
		}
		
		
		/* Apuntar al siguiente pixel */
		ptrVar++;
		Corr+=4;
		ptrCov+=4;
	}

	/* ******************************************************************* */
	/*               RESPONSIBILITY SMOOTHING BY PEARSON CORRELATIONS      */
	/* ******************************************************************* */
	

	ptrOutput = (double*) mxGetData(plhs[1]);
	NewOutput = NewOutputOri;	
	Corr = CorrOri;
	contadorTrunc = 0;
	for(i=0;i<size;i++)
	{

		
		HallarOffsets8vecinos(Offset,i,NumImageRows,NumImageColumns);
		
		numerador = *ptrOutput;
		denominador = 1.0;

		#if (DEBUG_MODE == 1)
			if (i==MY_PIXEL) {
				fprintf(fich,"RespX: %f \n",*ptrOutput);	
			}
		#endif

		for (NdxCorr=0;NdxCorr<4;NdxCorr++) 
		{
			if (Offset[NdxCorr] != 0) {
				respY = (*(ptrOutput + Offset[NdxCorr]));
				corrY = Corr[NdxCorr];
				numerador += (respY*corrY);
				denominador+= corrY;

				#if (DEBUG_MODE == 1)
					if (i==MY_PIXEL) {
						PosicionFilaColumna(i+Offset[NdxCorr],NumImageRows,&fil,&col);
						fprintf(fich,"Pixel (%d,%d), Posicion: %d, RespY: %f, CorrY: %f \n",fil,col,NdxCorr,respY,corrY);	
					}
				#endif
			}
		}


		cont = 0;
		for (NdxCorr=4;NdxCorr<8;NdxCorr++) 
		{
			if (Offset[NdxCorr] != 0) {
				respY = (*(ptrOutput + Offset[NdxCorr]));
				corrY = *(Corr + 4*Offset[NdxCorr] + cont);
				
				#if (DEBUG_MODE == 1)
					if (i==MY_PIXEL) {
						PosicionFilaColumna(i+Offset[NdxCorr],NumImageRows,&fil,&col);
						fprintf(fich,"Pixel (%d,%d), Posicion: %d, RespY: %f, CorrY: %f \n",fil,col,NdxCorr,respY,corrY);	
					}
				#endif

				numerador += (respY*corrY);
				denominador += corrY;
				cont++;
			}
		}

		/* suma = numerador / denominador; */
		suma = numerador / 9.0;
		if (suma >= 0.0) 
			*NewOutput = suma;
		else {
			*NewOutput = 0.0;
			contadorTrunc++;
		}

		#if (DEBUG_MODE == 1)
			if (i==MY_PIXEL) {
				fprintf(fich,"Resp_old: %f, RespNueva: %f \n",*ptrOutput,*NewOutput);	
				fprintf(fich,"N� veces suma < 0: %d \n",contadorTrunc);	
			}
		#endif

		/* Apuntar al siguiente pixel */
		ptrOutput++;
		NewOutput++;
		Corr+=4;
    }


	/* Copy the smoothed result */
	ptrOutput = (double*) mxGetData(plhs[1]);
	memcpy(ptrOutput,NewOutputOri,NumImageColumns*NumImageRows*sizeof(double));


	/* ******************************************************************* */
	/*               PROBABILISTIC MIXTURE UPDATE                          */
	/* ******************************************************************* */

	ptrMu = mxGetPr(Mu);
	ptrMuFore = mxGetPr(MuFore);
	ptrC = mxGetPr(C);
	ptrInvC = mxGetPr(InvC);
	ptrLogDetC = mxGetPr(LogDetC);
	ptrPi=mxGetPr(mxGetField(plhs[0],0,"Pi"));
	ptrOutput = (double*) mxGetData(plhs[1]);
	pDataCurrentR=ptrData;/*separate R G and B images*/
	pDataCurrentG=ptrData+size;
	pDataCurrentB=ptrData+2*size;

	/* For each one of the image pixels */
	for (i=0;i<size;i++)
	{
		/* MATLAB code: Pattern = Patterns(:,NdxPattern); */
		*Pattern = *pDataCurrentR++;
		*(Pattern+1) = *pDataCurrentG++;
		*(Pattern+2) = *pDataCurrentB++;

		/* Update of the corresponding variables of the gaussian distribution */ 
		AntPi=*ptrPi;
		*ptrPi=OneLessLearningRate*(*ptrPi) + LearningRate*(*ptrOutput);
		CoefOld=(OneLessLearningRate*AntPi)/(*ptrPi);
		CoefNew=(LearningRate*(*ptrOutput))/(*ptrPi);

		PiFore = 1.0 - OneLessLearningRateFore*(*ptrPi) + LearningRateFore*(*ptrOutput);
		CoefOldFore=(OneLessLearningRateFore*(1.0-AntPi))/(PiFore);
		CoefNewFore=(LearningRateFore*(1.0-(*ptrOutput)))/(PiFore);

		#if (DEBUG_MODE == 1)
			if (i==MY_PIXEL) fprintf(fich,"CoefOld: %f CoefNew: %f\n",CoefOld,CoefNew);
		#endif

		/* MATLAB code: Model.Mu{NdxComp} = (1-Model.Epsilon)*Model.Mu{NdxComp} + ...
		* Model.Epsilon*R*Patterns(:,NdxPattern);  */
		ptrMu[0]=CoefOld*ptrMu[0]+CoefNew*Pattern[0];
		ptrMu[1]=CoefOld*ptrMu[1]+CoefNew*Pattern[1];
		ptrMu[2]=CoefOld*ptrMu[2]+CoefNew*Pattern[2];

		/* MATLAB code: Model.MuFore{NdxComp} = (1-Model.Epsilon)*Model.MuFore{NdxComp} + ... 
		* Model.Epsilon*R_fore*Patterns(:,NdxPattern);  */
		ptrMuFore[0]=CoefOldFore*ptrMuFore[0]+CoefNewFore*Pattern[0];
		ptrMuFore[1]=CoefOldFore*ptrMuFore[1]+CoefNewFore*Pattern[1];
		ptrMuFore[2]=CoefOldFore*ptrMuFore[2]+CoefNewFore*Pattern[2];

		/* MATLAB code: VectorDif=Patterns(:,NdxPattern) - Model.Mu{NdxCompGauss}; */
		ptrVectorDif[0]=Pattern[0]-ptrMu[0];
		ptrVectorDif[1]=Pattern[1]-ptrMu[1];
		ptrVectorDif[2]=Pattern[2]-ptrMu[2];

		/* MATLAB code: Model.C{NdxComp} = (1-Model.Epsilon)*Model.C{NdxComp} + ...
		* Model.Epsilon*R*Diferencia*Diferencia'; */
		ptrC[0]=CoefOld*ptrC[0]+CoefNew*ptrVectorDif[0]*ptrVectorDif[0];
		ptrC[4]=CoefOld*ptrC[4]+CoefNew*ptrVectorDif[1]*ptrVectorDif[1];
		ptrC[8]=CoefOld*ptrC[8]+CoefNew*ptrVectorDif[2]*ptrVectorDif[2];
		ptrC[3]=ptrC[1]=CoefOld*ptrC[1]+CoefNew*ptrVectorDif[0]*ptrVectorDif[1];
		ptrC[6]=ptrC[2]=CoefOld*ptrC[2]+CoefNew*ptrVectorDif[0]*ptrVectorDif[2];
		ptrC[7]=ptrC[5]=CoefOld*ptrC[5]+CoefNew*ptrVectorDif[1]*ptrVectorDif[2];

		/* Add the noise to the diagonal of the covariance matrix */
		ptrC[0]+=Sigma2_Red;
		ptrC[4]+=Sigma2_Green;
		ptrC[8]+=Sigma2_Blue;

		/* Get the eigenvalues to compute the determinant of the covariance matrix */
		DetC=ptrC[0]*ptrC[4]*ptrC[8]+ptrC[3]*ptrC[7]*ptrC[2]+ptrC[1]*ptrC[5]*ptrC[6]
		-ptrC[2]*ptrC[4]*ptrC[6]-ptrC[1]*ptrC[3]*ptrC[8]-ptrC[0]*ptrC[5]*ptrC[7];
		InvDetC=1.0/DetC;
		*ptrLogDetC=log(DetC);

		/* MATLAB code: Model.InvC{NdxComp}=inv(Model.C{NdxComp});  */
		ptrInvC[0]=InvDetC*DET2(4,7,5,8);
		ptrInvC[4]=InvDetC*DET2(0,6,2,8);
		ptrInvC[8]=InvDetC*DET2(0,3,1,4);
		ptrInvC[3]=ptrInvC[1]=-InvDetC*DET2(1,7,2,8);
		ptrInvC[6]=ptrInvC[2]=InvDetC*DET2(3,6,4,7);
		ptrInvC[7]=ptrInvC[5]=-InvDetC*DET2(0,6,1,7);
		ptrC[0]-=Sigma2_Red;
		ptrC[4]-=Sigma2_Green;
		ptrC[8]-=Sigma2_Blue;

		/* Record the relevant pixel information to the log */
		#if (DEBUG_MODE == 1)
		if (i==MY_PIXEL) {
			fprintf(fich,"Pi: %f Counter: %f\n",*ptrPi,*ptrCounter);
			fprintf(fich,"Mu\n");
			RecordMatrixLog(fich,ptrMu,1,DimColorSpace); 
			fprintf(fich,"C\n");
			RecordMatrixLog(fich,ptrC,DimColorSpace,DimColorSpace); 
			fprintf(fich,"InvC\n");
			RecordMatrixLog(fich,ptrInvC,DimColorSpace,DimColorSpace);
			fprintf(fich,"log(DetC): %f\n",*ptrLogDetC); 
			fprintf(fich,"MuFore\n");
			RecordMatrixLog(fich,ptrMuFore,1,DimColorSpace); 
		}
		#endif



		/* Pointers asociated to the gaussian distribution are incremented */
		ptrPi++;
		ptrMu+=3;
		ptrMuFore+=3;
		ptrC+=9;
		ptrInvC+=9;
		ptrLogDetC++;

		/* Update of the corresponding variables of the uniform distribution */ 
		*ptrPi=OneLessLearningRate*(*ptrPi) + LearningRate*ptrResponsibilities[1];
		/* Pointers asociated to the uniform distribution are incremented */
		ptrPi++;

		/* Global pointers are incremented */
		ptrOutput++;
	}

	/* Copy the smoothed result */
	ptrOutput = (double*) mxGetData(plhs[1]);
	memcpy(ptrOutput,NewOutputOri,NumImageColumns*NumImageRows*sizeof(double));

		
	#if (DEBUG_MODE == 1) 
		/* Close the log file */
		CloseLog(fich);
	#endif
	
	/* Release pointers */
	mxFree(Pattern);
	mxFree(NewOutputOri);
	mxFree(CorrOri);
}
 
/**********************************************************************************************
 * Function to reinitialise a pixel which has exceeded the Z value. Z is the maximun number of consecutive 
 * frames in which a pixel belongs to the foreground class.
 **********************************************************************************************/
void PixelInitialisation(long i,double *ptrMu,double *ptrMuFore,double *ptrC,double *ptrInvC,double *ptrLogDetC,double *ptrNoise,double *ptrCounter,double *ptrPattern) 
{
	double *ptrMyEigenvalues,*ptrMyEigenvectors;
	double tmpLogDetC,Sigma2_Red,Sigma2_Green,Sigma2_Blue;
	double temp[3];
	int NdxDim;

	ptrMyEigenvalues=mxMalloc(DimColorSpace*sizeof(double));
    ptrMyEigenvectors=mxMalloc(DimColorSpace*DimColorSpace*sizeof(double));

	/* The counter for this pixel is initialised*/
	*ptrCounter = 0;

	/* Swap between Mu and MuFore*/
	temp[0]=ptrMu[0];
	temp[1]=ptrMu[1];
	temp[2]=ptrMu[2];
	ptrMu[0]=ptrMuFore[0];
	ptrMu[1]=ptrMuFore[1];
	ptrMu[2]=ptrMuFore[2];
	ptrMuFore[0]=temp[0];
	ptrMuFore[1]=temp[1];
	ptrMuFore[2]=temp[2];

	#if (DEBUG_MODE == 1)
		if (i==MY_PIXEL) {
			fprintf(fich,"REINITIALISATION OF THE PIXEL\n");
			fprintf(fich,"ptrMu:");
			RecordMatrixLog(fich,ptrMu,1,DimColorSpace); 
			fprintf(fich,"ptrMuFore:");
			RecordMatrixLog(fich,ptrMuFore,1,DimColorSpace); 
			fprintf(fich,"--------------------------\n");
		}
	#endif

	/* Add the noise to the diagonal of the covariance matrix */
	Sigma2_Red=(double)(*ptrNoise);
	Sigma2_Green=(double)(*(ptrNoise+1));
	Sigma2_Blue=(double)(*(ptrNoise+2));

	/* Initialisation of the covariance matrix in combination with the noise */
	memset(ptrC,0,DimColorSpace*DimColorSpace*sizeof(double));
	ptrC[0] = Sigma2_Red;
	ptrC[4] = Sigma2_Green;
	ptrC[8] = Sigma2_Blue;

    /* Compute the inverse of the covariance matrix */
	InverseNorm(ptrC,ptrInvC,NULL,NULL,DimColorSpace,DimColorSpace);
	
	/* The eigenvalues of the covariance matrix are computed */ 
	EigValVec(ptrC,ptrMyEigenvalues,ptrMyEigenvectors,DimColorSpace);    

	/* log(det C) is computed*/
	tmpLogDetC=0.0;
	for(NdxDim=0;NdxDim<DimColorSpace;NdxDim++)
	{
		tmpLogDetC+=log(ptrMyEigenvalues[NdxDim]);
	}
	*ptrLogDetC = tmpLogDetC;

	/* Release pointers */
	mxFree(ptrMyEigenvalues);
    mxFree(ptrMyEigenvectors);
}


/* Calcular offsets para convoluciones */
void HallarOffsets(int *Offset,int NdxPixel,int NumFilasA) 
{
	int col, fila;
	col = (NdxPixel / NumFilasA) + 1;
	fila = (NdxPixel % NumFilasA) + 1;

	Offset[0] = 0;
	Offset[1] = 0;
	Offset[2] = 0;
	Offset[3] = 0;
	
	if ((fila > 1) && (col > 1))  {
		Offset[0] = -1; 
		Offset[1] = -NumFilasA-1; 
		Offset[2] = -NumFilasA;
		if (fila < NumFilasA) Offset[3] = -NumFilasA+1;
	}
	else if ((fila == 1) && (col > 1)) {
		Offset[2] = -NumFilasA;
		Offset[3] = -NumFilasA+1;
	}
	else if ((col == 1) && (fila > 1)) {
		Offset[0] = -1;
	}
}

void HallarOffsets8vecinos(int *Offset,int NdxPixel,int NumFilasA,int NumColsA) 
{
	int col, fila;
	
	col = (NdxPixel / NumFilasA) + 1;
	fila = (NdxPixel % NumFilasA) + 1;

	HallarOffsets(Offset,NdxPixel,NumFilasA);
	
	Offset[4] = 0;
	Offset[5] = 0;
	Offset[6] = 0;
	Offset[7] = 0;

	if ((fila < NumFilasA) && (col < NumColsA))  {
		Offset[4] = 1; 
		Offset[5] = NumFilasA+1; 
		Offset[6] = NumFilasA;
		if (fila > 1) Offset[7] = NumFilasA-1;
	}
	else if ((fila == NumFilasA) && (col < NumColsA)) {
		Offset[6] = NumFilasA;
		Offset[7] = NumFilasA-1;
	}
	else if ((col == NumColsA) && (fila < NumFilasA)) {
		Offset[4] = 1;
	}
}

void PosicionFilaColumna(int NdxPixel,int NumFilasA,int *col,int *fila) 
{
	*col = (NdxPixel / NumFilasA) + 1;
	*fila = (NdxPixel % NumFilasA) + 1;
}
