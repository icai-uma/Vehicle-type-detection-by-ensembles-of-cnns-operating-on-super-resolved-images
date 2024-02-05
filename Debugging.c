#include "Debugging.h"
#include "mex.h"
#include <math.h>

void PrintValues(double *Values,int NumValues)
{
    int ndx;
    
    for(ndx=0;ndx<NumValues;ndx++)
        mexPrintf("%lf\n",Values[ndx]);
    mexPrintf("\n\n");
}
  
    
void PrintMatrix(double *Matrix,int NumRows,int NumCols)
{
    int NdxRow,NdxCol;
    
    for(NdxRow=0;NdxRow<NumRows;NdxRow++)
    {
        for(NdxCol=0;NdxCol<NumCols;NdxCol++)
        {
            mexPrintf("%lf\t",Matrix[NdxCol*NumRows+NdxRow]);
        }
        mexPrintf("\n");
    }        
    mexPrintf("\n\n");
}  

FILE * OpenLog(char cad[]) 
{
	FILE * fichero;
	fichero = fopen( cad, "a+" );

	if( !fichero ) mexPrintf( "Error (NO ABIERTO)\n" );
    
	return fichero;
}

void RecordMatrixLog(FILE * fichero, double *Matriz,int NumFilas,int NumCols)
	{
    int NdxFila,NdxCol;
    
    for(NdxFila=0;NdxFila<NumFilas;NdxFila++)
    {
        for(NdxCol=0;NdxCol<NumCols;NdxCol++)
        {
 		    fprintf( fichero, "%lf\t",Matriz[NdxCol*NumFilas+NdxFila]);
        }
		fprintf( fichero, "\n");
    }        
	fprintf( fichero, "\n");
	fflush(fichero);
}  

void CloseLog(FILE * fichero) 
{
   if( fclose(fichero) )
      printf( "Error: fichero NO CERRADO\n" );
}



