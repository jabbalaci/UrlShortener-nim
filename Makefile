debug:
	nim c urlshortener.nim

release:
	nim c -d:release urlshortener.nim
