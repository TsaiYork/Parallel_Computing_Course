//Use multiple block multiple thread
aaa
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <cuda_runtime.h>

#define WIDTH 512
#define threadDim 16

__global__ void MatMulKernel(float *Md, float *Nd, float *Pd, int width);
void MatMul(float *M, float *N, float *P, int width);


int main(int argc, char *argv[])
{
    int width = WIDTH;
    float M[WIDTH*WIDTH] = {0};
    float N[WIDTH*WIDTH] = {0};
    float P[WIDTH*WIDTH] = {0};
    float MxN[WIDTH*WIDTH] = {0};
    int pass = 1;
    
	srand(time(NULL));
	
    for (int i = 0; i < width; ++i) {
        for (int j = 0; j < width; ++j) {
            M[i*width + j] = rand() % 30;
            N[i*width + j] = rand() % 30;
        }
    }
    
    struct timeval starttime, endtime;
    gettimeofday(&starttime, NULL);
    for (int i = 0; i < width; ++i) {
        for (int j = 0; j < width; ++j) {
            for (int k = 0; k < width; ++k) {
                MxN[i*width + j] += M[i*width + k] * N[k*width + j];
            }
        }
    }
    gettimeofday(&endtime, NULL);
    double executime;
    executime = (endtime.tv_sec - starttime.tv_sec) * 1000.0;
    executime += (endtime.tv_usec - starttime.tv_usec) / 1000.0;
    printf("CPU time: %13lf msec\n", executime);
    
    MatMul(M, N, P, width);
    
    for (int i = 0; i < width; ++i) {
        for (int j = 0; j < width; ++j) {
            if(MxN[i*width + j] != P[i*width + j]) {
				printf("MxN[%d][%d] = %2.0f   P[%d][%d] = %2.0f\n", i, j, MxN[i*width + j], i, j, P[i*width + j]);
                pass = 0;
            }
        }
    }
    
    printf("Test %s\n", (pass)?"PASSED":"FAILED");
    
    return 0;
}



// Matrix multiplication kernel called by MatMul()
__global__ void MatMulKernel(float *Md, float *Nd, float *Pd, int width)
{
	
    // Thread row and column within matrix
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    int col = blockIdx.x * blockDim.x + threadIdx.x;

    // Each thread computes one element of P
    // by accumulating results into Pvalue
    float Pvalue = 0;
    
    // Multiply M and N
    for (int k = 0; k < width; ++k) {
        float Melement = *(Md + row*width + k);
        float Nelement = *(Nd + k*width + col);
        Pvalue += Melement * Nelement;
    }
    
    // Write Pvalue to device memory
    // Each thread writes one element
    *(Pd + row*width + col) = Pvalue;
}

// Matrix multiplication - Host code
void MatMul(float *M, float *N, float *P, int width)
{
    size_t size = width * width * sizeof(float);
    float *Md, *Nd, *Pd;
    
    // Allocate and Load M, N to device memory
    cudaMalloc((void **)&Md, size);
    cudaMemcpy(Md, M, size, cudaMemcpyHostToDevice);
    
    cudaMalloc((void **)&Nd, size);
    cudaMemcpy(Nd, N, size, cudaMemcpyHostToDevice);
    
    // Allocate P on the device
    cudaMalloc((void **)&Pd, size);
    
    // Setup the execution configuration
    dim3 dimGrid(WIDTH/threadDim, WIDTH/threadDim);	//blocks size of per grid
    dim3 dimBlock(threadDim, threadDim);	//threads size of per blocks
    
    // Get start time event
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start, 0);
    
    // Invoke kernel
    MatMulKernel<<<dimGrid, dimBlock>>>(Md, Nd, Pd, width);
    cudaError_t cuda_err = cudaGetLastError();
    if ( cudaSuccess != cuda_err ){
        printf("before kernel call: error = %s\n", cudaGetErrorString (cuda_err));
        exit(1) ;
    }
    
    // Get stop time event
    cudaEventRecord(stop, 0);
    cudaEventSynchronize(stop);
    // Compute execution time
    float elapsedTime;
    cudaEventElapsedTime(&elapsedTime, start, stop);
    printf("GPU time: %13f msec\n", elapsedTime);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
    
    // Read P from device memory
    cudaMemcpy(P, Pd, size, cudaMemcpyDeviceToHost);
    
    // Free device memory
    cudaFree(Md);
    cudaFree(Nd);
    cudaFree(Pd);
}