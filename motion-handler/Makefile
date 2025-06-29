CFLAGS += -Iinclude

all: motion-handler

motion-handler: motion-handler.o gpio-utils.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^ $(LDLIBS)

clean:
	rm -f *.o motion-handler

.PHONY: all clean
