DOCKER_DEVEL_FILE=docker_devel.mk
DOCKER_OUTPUT_TAG?=gcr.io/wizzie-registry/prozzie-sfacctd
VERSION=1.6.2
PMACCT_URL=http://www.pmacct.net/pmacct-$(VERSION).tar.gz
PMACCT_SHA256SUM=e6ede7f500fb1771b5cdfb63dfa016e34c19b8aa2d2f672bd4c63016a5d6bbe2

# Create a temp file in fd $(1)
tmpfile=tmpfile="$$(mktemp)"; exec $(1)<>"$$tmpfile"; rm "$$tmpfile"; unset tmpfile

# To disable develop docker, set this to n.
ENABLE_DOCKER?=y
ifeq ($(ENABLE_DOCKER),y)
# You can use your own dev docker
dev_docker_id=$(shell docker build -q docker/devel | sed 's/sha256://')
docker_prefix=docker run -v $(CURDIR)/pmacct-$(VERSION):/app $(dev_docker_id)
endif

.PHONY: all clean push

all: pmacct-$(VERSION)/src/sfacctd docker/release/Dockerfile
	docker build -t $(DOCKER_OUTPUT_TAG):$(VERSION) -f docker/release/Dockerfile .

push:
	gcloud docker -- push $(DOCKER_OUTPUT_TAG):$(VERSION)

clean:
	-docker rmi $(DEV_DOCKER_ID) $(DOCKER_OUTPUT_TAG)
	rm -rf docker/devel/ pmacct-$(VERSION)/ docker/release/Dockerfile

%/Dockerfile: docker/Dockerfile.m4
	mkdir -p "$(dir $@)"
	m4 --define=version="$(@:docker/%/Dockerfile=%)" "$<" > "$@"

pmacct-$(VERSION)/Makefile: pmacct-$(VERSION)/configure
pmacct-$(VERSION)/Makefile: cmd=./configure --enable-kafka --enable-jansson
pmacct-$(VERSION)/src/sfacctd: pmacct-$(VERSION)/Makefile
pmacct-$(VERSION)/src/sfacctd: cmd=make
pmacct-$(VERSION)/%: docker/devel/Dockerfile
	cd pmacct-$(VERSION); $(docker_prefix) $(cmd)

pmacct-$(VERSION)/configure:
	@$(call tmpfile,3); \
	echo 'Downloading $(PMACCT_URL)'; \
	wget -qO /dev/fd/3 '$(PMACCT_URL)'; \
	echo -n 'Checking sha256sum '; \
	echo "$(PMACCT_SHA256SUM)  /dev/fd/3" | sha256sum -c && \
	tar xzpf /dev/fd/3

ENVS.md: docker/release/sfacctd-start.sh
	@echo "| ENV | Default |\n|---|---|" > "$@"
	@sed -n '/^zz_var/{s%\\%...%;p};/RDKAFKA/q' '$<' | \
	awk '{printf "|%s|", $$2; $$1=$$2=""; printf "%s|\n", $$0}' | tr -d "'" \
	>> '$@'
