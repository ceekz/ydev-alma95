IMAGE ?= ydev-alma95
PLATFORM ?= linux/amd64

.PHONY: build test shell

build:
	docker build --platform $(PLATFORM) -t $(IMAGE) .

test:
	PLATFORM=$(PLATFORM) ./scripts/smoke-test.sh $(IMAGE)

shell:
	docker run --rm -it --platform $(PLATFORM) $(IMAGE) bash
