#ifndef __HANDLER_H__
#define __HANDLER_H__

#include "config.h" 
#include "type.h"
#include "queue.h"
#include "cond_lock.h"

#include <pthread.h>
#include <libaio.h>
#include <stdlib.h>
#include <stdint.h>

struct callback {
	void *(*func)(void *);
	void *arg;
};

static inline struct callback *
make_callback(void *(*func)(void*), void *arg) {
	struct callback *cb = 
		(struct callback *)malloc(sizeof(struct callback));
	cb->func = func;
	cb->arg  = arg;
	return cb;
}

struct handler {
	int number;
	pthread_t hlr_tid, plr_tid;

	struct kv_ops *ops;
	struct dev_abs *dev;

	cl_lock *flying;

	queue *req_q;
	queue *retry_q;

#ifdef LINUX_AIO
	io_context_t aio_ctx;
#elif SPDK
	// TODO: include SPDK variables
#endif

	int (*read)(struct handler *, uint64_t, uint32_t, char *,
		    struct callback *);
	int (*write)(struct handler *, uint64_t, uint32_t, char *,
		     struct callback *);
};

/* handler */
struct handler *handler_init(htable_t ht_type);
void handler_free(struct handler *hlr);

int forward_req_to_hlr(struct handler *hlr, struct request *req);
int retry_req_to_hlr(struct handler *hlr, struct request *req);

struct request *get_next_request(struct handler *hlr);

void *request_handler(void *input);


/* poller */
void *device_poller(void *input);

#endif
