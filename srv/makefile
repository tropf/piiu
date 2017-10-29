CC=g++
CFLAGS=-lboost_system -lboost_signals -pthread -std=c++14 -I. -Ofast /usr/local/lib64/libdlib.a
STATICFLAGS=

udp: udp.cxx
	$(CC) -o udp udp.cxx $(CFLAGS)
srv: srv.cxx
	$(CC) -o srv srv.cxx $(CFLAGS)

static: srv.cxx
	$(CC) -o srv srv.cxx $(CFLAGS) $(STATICFLAGS)
