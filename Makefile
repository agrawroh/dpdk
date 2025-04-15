# SPDX-License-Identifier: BSD-3-Clause
# Copyright(c) 2010-2014 Intel Corporation

# binary name
APP = rss_helper

# all source are stored in SRCS-y
SRCS-y := test.cpp

# Define RTE_SDK if not already defined
ifeq ($(RTE_SDK),)
RTE_SDK = /build/bazel_root/base/sandbox/processwrapper-sandbox/1/execroot/envoy
endif

# Define RTE_TARGET if not already defined
RTE_TARGET ?= x86_64-native-linuxapp-gcc

# Include path for DPDK headers
DPDK_INCLUDE_PATH ?= $(RTE_SDK)/include
EXTRA_INCLUDE_PATH ?= $(RTE_SDK)/dpdk/include

# Set compiler to match the Bazel environment
CC = $(CXX)

# Basic flags for C++ compilation
BASE_CFLAGS = -O3 -DALLOW_EXPERIMENTAL_API -std=c++11
BASE_CFLAGS += -I$(DPDK_INCLUDE_PATH) -I$(EXTRA_INCLUDE_PATH)

# Add flags from the Bazel build environment
CFLAGS += $(BASE_CFLAGS) $(CXXFLAGS)
# Remove C-specific warning flags that don't apply to C++
CFLAGS := $(filter-out -Wstrict-prototypes -Wmissing-prototypes -Wold-style-definition -Wnested-externs,$(CFLAGS))

# Linking flags
LDFLAGS += -lstdc++

# Object files
OBJS = $(patsubst %.cpp,%.o,$(SRCS-y))

# Build rules
all: $(APP)

$(APP): $(OBJS)
	$(CC) -o $@ $(OBJS) $(LDFLAGS)

%.o: %.cpp
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f $(APP) $(OBJS)
