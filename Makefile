SRC_DIR = ./src
OBJ_DIR = ./obj
LIB_DIR = ./lib
BIN_DIR = ./bin
INC_DIR = ./include

CC = g++

CFLAGS += \
	-g \
	-Wall \
	-std=c++11 \
	-O2 \
#	-fsanitize=address \

LIBS += \
	-lcityhash \
	-lpthread \
	-laio \

DEFS += \
	-DCITYHASH \
	-DLINUX_AIO \
	-DUNIFORM \
	-DUSE_HUGEPAGE\
	-DBIGKV \
#	-DYCSB \
#	-DHOPSCOTCH \
#	-DHOTSPOT \

OBJ_SRC += \
	$(SRC_DIR)/hopscotch.c \
	$(SRC_DIR)/bigkv_index.c \
	$(SRC_DIR)/util.c \
	$(SRC_DIR)/keygen.c \
	$(SRC_DIR)/cond_lock.c \
	$(SRC_DIR)/master.c \
	$(SRC_DIR)/request.c \
	$(SRC_DIR)/handler.c \
	$(SRC_DIR)/request.c \
	$(SRC_DIR)/device.c \
	$(SRC_DIR)/poller.c \
	$(SRC_DIR)/aio.c \
	$(SRC_DIR)/queue.c \
	$(SRC_DIR)/lfqueue.c \

TARGET_OBJ =\
		$(patsubst %.c,%.o,$(OBJ_SRC))\

all: client server

client: $(SRC_DIR)/client.cc $(LIB_DIR)/libdfhash.a
	@mkdir -p $(BIN_DIR)
	$(CC) -o $(BIN_DIR)/$@ $^ $(CFLAGS) $(LIBS) $(DEFS) -I$(INC_DIR) 

server: $(SRC_DIR)/temp.cc $(LIB_DIR)/libdfhash.a
	@mkdir -p $(BIN_DIR)
	$(CC) -o $(BIN_DIR)/$@ $^ $(CFLAGS) $(LIBS) $(DEFS) -I$(INC_DIR)

$(LIB_DIR)/libdfhash.a: $(TARGET_OBJ)
	@mkdir -p $(LIB_DIR)
	@mv $(SRC_DIR)/*.o $(OBJ_DIR)
	$(AR) r $@ $(OBJ_DIR)/*

.c.o:
	$(CC) $(CFLAGS) $(LIBS) $(DEFS) -c $< -o $@ -I$(INC_DIR)

clean:
	@rm -vf $(BIN_DIR)/*
	@rm -vf $(OBJ_DIR)/*.o
	@rm -vf $(LIB_DIR)/*.o
	@rm -vf $(LIB_DIR)/libdfhash.a
