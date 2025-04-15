# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2010-2014 Intel Corporation

# binary name
APP = rss_helper

# all source are stored in SRCS-y
# SRCS-y := main.c
SRCS-y := test.cpp

# Build using pkg-config variables if possible
ifeq ($(shell pkg-config --exists libdpdk && echo 0),0)

all: shared
# all: static
.PHONY: shared static
shared: build/$(APP)-shared
	ln -sf $(APP)-shared build/$(APP)
static: build/$(APP)-static
	ln -sf $(APP)-static build/$(APP)

PKGCONF ?= pkg-config

PC_FILE := $(shell $(PKGCONF) --path libdpdk 2>/dev/null)
# Set compiler to g++ for C++ files
CC = g++
CFLAGS += -O3 $(shell $(PKGCONF) --cflags libdpdk)
# Remove C-specific warning flags that don't apply to C++
CFLAGS := $(filter-out -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition -Wnested-externs,$(CFLAGS))
# Add proper linking for C++ standard library
LDFLAGS_SHARED = $(shell $(PKGCONF) --libs libdpdk) -lstdc++
LDFLAGS_STATIC = $(shell $(PKGCONF) --static --libs libdpdk) -lstdc++

build/$(APP)-shared: $(SRCS-y) Makefile $(PC_FILE) | build
	$(CC) $(CFLAGS) $(SRCS-y) -o $@ $(LDFLAGS) $(LDFLAGS_SHARED)

build/$(APP)-static: $(SRCS-y) Makefile $(PC_FILE) | build
	$(CC) $(CFLAGS) $(SRCS-y) -o $@ $(LDFLAGS) $(LDFLAGS_STATIC)

build:
	@mkdir -p $@

.PHONY: clean
clean:
	rm -f build/$(APP) build/$(APP)-static build/$(APP)-shared
	test -d build && rmdir -p build || true

else

ifeq ($(RTE_SDK),)
$(error "Please define RTE_SDK environment variable")
endif

# Default target, detect a build directory, by looking for a path with a .config
RTE_TARGET ?= $(notdir $(abspath $(dir $(firstword $(wildcard $(RTE_SDK)/*/.config)))))

include $(RTE_SDK)/mk/rte.vars.mk

# Set C++ compiler explicitly
CC = g++

# C++ flags
CXXFLAGS += -O3
CXXFLAGS += $(filter-out -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition -Wnested-externs,$(WERROR_FLAGS))
CXXFLAGS += -DALLOW_EXPERIMENTAL_API
CXXFLAGS += -std=c++11

# C flags (filtered to remove C-specific warnings)
CFLAGS += -O3
CFLAGS += $(filter-out -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition -Wnested-externs,$(WERROR_FLAGS))
CFLAGS += -DALLOW_EXPERIMENTAL_API

# Add proper linking for C++ standard library
LDLIBS += -lstdc++

include $(RTE_SDK)/mk/rte.extapp.mk

endif
