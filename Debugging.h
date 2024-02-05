#ifndef _DEPURAR_H

#define _DEPURAR_H

#include <stdio.h>

void PrintValues(double *Values,int NumValues);

void PrintMatrix(double *Matrix,int NumRows,int NumCols);

FILE * OpenLog(char cad[]);

void CloseLog(FILE * fichero);

void RecordMatrixLog(FILE * fichero, double *Matriz,int NumFilas,int NumCols);

#endif

