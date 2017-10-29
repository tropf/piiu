CC=g++
CFLAGS=-lboost_system -lboost_signals -pthread -std=c++14 -I. -Ofast
STATICFLAGS=

srv: srv.cxx
	$(CC) -o srv srv.cxx $(CFLAGS)

static: srv.cxx
	$(CC) -o srv srv.cxx $(CFLAGS) $(STATICFLAGS)
