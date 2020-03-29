#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <pthread.h>
#include "err.h"
#include "pix.h"
#include <inttypes.h>
 
#define MAX 1042

typedef struct omg {
    uint64_t *pidx;
    uint64_t max;
    uint32_t *ppi;
} omg;

void *worker (void *data) {
    omg pack = *((omg*) data);
    pix(pack.ppi, pack.pidx, pack.max);
    return data;
}

void pixtime(uint64_t clock_tick) {
  fprintf(stderr, "%016lX\n", clock_tick);
}

int main (int argc, char** argv) {

    if(argc < 2)
        syserr("too short");
    int NUM = atoi(argv[1]);

    uint64_t liczba = 0;
    uint64_t *pidx = &liczba;
    uint64_t max = MAX;
    uint32_t ppi[max];

    omg pack;
    pack.ppi = ppi;
    pack.pidx = pidx;
    pack.max = max;

    pthread_t th[NUM];
    pthread_attr_t attr;
    int i, err;
    
    if ((err = pthread_attr_init(&attr)) != 0 ) 
        syserr("attr_init");

    if ((err = pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_JOINABLE) != 0))
      syserr("setdetach");

    for(i = 0; i < NUM; i++) {
        if ((err = pthread_create(&th[i], &attr, worker, &pack)) != 0) 
            syserr("create");
    }

    for(i = 0; i < NUM; i++) {
	    if ((err = pthread_join(th[i], NULL) != 0))
            syserr("join");
    }  

    if((err = pthread_attr_destroy (&attr)) != 0)
        syserr("attr_destroy");

    for(uint64_t i=0;i<max;i++){
        printf("%08" PRIX32, ppi[i]);
        if(i % 8 == 7 && i != 0)
            printf("\n");
    }
    printf("\n");
    return 0;
}