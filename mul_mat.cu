#include<stdlib.h>
#include<stdio.h>
const int N = 32;
const int blocksize = 16;

__global__ void mul(int* A, int* B, int* C){
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int lig = blockIdx.y * blockDim.y + threadIdx.y;

    int index = lig * N + col;
    
    if (col < N && lig < N){
        int inter = 0;
        for (int i = 0; i<N; ++i){
            inter += A[lig*N + i] * B[i*N + col];
        }
        C[index] = inter;
    }
}

__host__ void affiche(int *A, int z){
    for( int i=0;i<z;i++){
        for (int j=0; j<z;j++){
            printf(" %d ",A[i*z+j]);
        }
        printf("\n");
    }
}

int main(void){
    int *A, *B, *C, *da, *db, *dc;
    int size = N * N * sizeof(int);


    cudaMalloc((void **) & da, size);
    cudaMalloc((void **) & db, size);
    cudaMalloc((void **) & dc, size);

    A = (int *)malloc(size);
    B = (int *)malloc(size);
    C = (int *)malloc(size);

    for (int i=0; i<N * N; ++i){
        A[i]=1; B[i]=1;
    }



    cudaMemcpy(da, A, size, cudaMemcpyHostToDevice);
    cudaMemcpy(db, B, size, cudaMemcpyHostToDevice);

    dim3 dimBlock(blocksize, blocksize);
    dim3 dimGrid(N*N/dimBlock.x, N*N/dimBlock.y);

    mul<<<dimGrid, dimBlock>>>(da, db, dc);

    cudaMemcpy(C, dc, size, cudaMemcpyDeviceToHost);

    affiche(C, N);


    free(A); free(B); free(C);
    cudaFree(da); cudaFree(db); cudaFree(dc);
    return 0;
}

