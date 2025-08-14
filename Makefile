ISO_NAME=rogueos-amd64-\$$(shell date +%Y%m%d).iso

.PHONY: iso docker-iso clean

iso:
	./build.sh

docker-iso:
	docker build -t rogueos-builder .
	docker run --rm -v \$$(PWD)/out:/src/out rogueos-builder

clean:
	./clean.sh
