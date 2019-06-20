CC=docker
CXX=$(CC)-compose

PROJECT=quickc/openvpn-client

up:
	$(CXX) up -d

down:
	$(CXX) down

build:
	$(CC) build -t $(PROJECT) .

build-fresh:
	$(CC) build -t $(PROJECT) --no-cache .

clean:
	-$(CC) rm $(PROJECT)
	-$(CC) rmi $(PROJECT)
