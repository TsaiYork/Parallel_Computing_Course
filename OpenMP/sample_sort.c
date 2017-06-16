#include <omp.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <iostream>


using namespace std;

#define DATA_RANGE 10 
#define SWAP(x,y) {int t; t = x; x = y; y = t;} 

int tmp;
void swap(int arr[],int x,int y){
    tmp = arr[x];
    arr[x] = arr[y];
    arr[y] = tmp;
}

int partition(int[], int, int); 
void quickSort(int[], int, int); 

int main(void) { 
    srand(time(NULL)); 
    
    int number[DATA_RANGE] = {0}; 

    printf("排序前："); 
    int i;
    for(i = 0; i < DATA_RANGE; i++) { 
        number[i] = rand() % 100; 
        printf("%d ", number[i]); 
    } 
    clock_t t_q1 = clock();
    quickSort(number, 0, DATA_RANGE-1); 
    clock_t t_q2 = clock();
    

    printf("\n排序後："); 
    for(i = 0; i < DATA_RANGE; i++) 
        printf("%d ", number[i]); 
    
    printf("\n"); 

    return 0; 
} 

int partition(int number[], int left, int right) { 
    int i = left - 1; 
    int j;                  //right is the pivot
    for(j = left; j < right; j++) { 
        if(number[j] <= number[right]) { 
            i++; 
            SWAP(number[i], number[j]); 
        } 
    } 

    SWAP(number[i+1], number[right]); 
    return i+1; 
} 

void quickSort(int number[], int left, int right) { 
    if(left < right) { 
        int q = partition(number, left, right); 
        quickSort(number, left, q-1); 
        quickSort(number, q+1, right); 
    } 
} 