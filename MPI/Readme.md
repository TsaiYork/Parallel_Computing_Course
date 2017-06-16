#編譯
$ mpicc Parallel_trapezoid.c -o Parallel_trapezoid -lm
#mpicc mpi編譯器; -lm用到數學函式庫 所以加上library參數; 

#執行
$mpirun -np 4 Parallel_trapezoid

