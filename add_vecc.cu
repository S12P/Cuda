#include<stdio.h>
#include<stdlib.h>
#include <iostream>
#include<cuda.h>
#define N (1024*1024)
#define nb_thread 512
__global__ void add(int *a, int *b, int *c) {
	int index = threadIdx.x + blockIdx.x * blockDim.x;
	c[index] = a[index] + b[index];
}


int main(void) {
	int *a,*b,*c; // sur le cpu
	int *d_a, *d_b, *d_c; // sur le gpu
	
	int size = N * sizeof(int);
	
	cudaMalloc((void **) & d_a, size);
	cudaMalloc((void **) & d_b, size);
	cudaMalloc((void **) & d_c, size);


	a = (int *)malloc(size);
	b = (int *)malloc(size);
	c = (int *)malloc(size);
	for (int i = 0; i<N; i++){
		a[i]=rand()%20;
		b[i]=rand()%20;
	}
	

	cudaMemcpy(d_a, a, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_b, b, size, cudaMemcpyHostToDevice);

	add<<<N/nb_thread,nb_thread>>>(d_a, d_b, d_c);

	cudaMemcpy(c, d_c, size, cudaMemcpyDeviceToHost);
	free(a);
	free(b);
	free(c);
	cudaFree(d_a);
	cudaFree(d_b);
	cudaFree(d_c);
	for (int i=0; i<N;i++)	
		printf("%d %d %d \n",a[i],b[i],c[i]);
	return 0;
}

