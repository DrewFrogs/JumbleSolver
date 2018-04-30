all: run

run:
	gcc -c jumble.adb
	gnatmake jumble.adb

clean:
	rm jumble jumble.o jumble.ali
