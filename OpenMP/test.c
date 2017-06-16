//#include <stdafx.h>
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

int main(){
#pragma omp parallel
    printf("Hello,This thread: %d\n",omp_get_thread_num());
    return 0;
}
