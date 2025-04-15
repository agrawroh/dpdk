################################################################################
# Monolithic Makefile for Modern DPDK (Unofficial) with 'install' target
################################################################################

# 1) Toolchain commands (override via environment if needed)
CC      ?= gcc
AR      ?= ar
LD      ?= ld
PREFIX  ?= /usr/local   # Used by 'make install'. Overridden by rules_foreign_cc.

# 2) Basic CFLAGS
CFLAGS  ?= -O3 -g -fPIC -Wall -Werror

# 3) Additional DPDK-specific flags or defines
DPDK_CFLAGS ?= -Wno-deprecated-declarations -D_GNU_SOURCE

# 4) Include paths (adjust to your layout)
INCLUDES  ?= -I$(CURDIR)/include -I$(CURDIR)

# 5) Libraries required at link time (adjust as needed)
LDLIBS   ?= -lm -lpthread -ldl

# 6) Final static library name
TARGET_LIB ?= libdpdk.a

# 7) Gather all .c files under lib/ and drivers/, excluding test/doc/examples
C_SRCS = $(shell find lib drivers -type f -name '*.c' \
          ! -path '*/test/*' \
          ! -path '*/doc/*' \
          ! -path '*/examples/*')

OBJS = $(C_SRCS:.c=.o)

################################################################################
# Top-level targets
################################################################################

.PHONY: all clean config install

all: config $(TARGET_LIB)

# Optional config step
config:
	@echo ">> No real config. If needed, generate rte_config.h or detect CPU features."

$(TARGET_LIB): $(OBJS)
	@echo "  [AR] $@"
	$(AR) rcs $@ $^

################################################################################
# Object file compilation
################################################################################

%.o: %.c
	@echo "  [CC] $<"
	$(CC) $(CFLAGS) $(DPDK_CFLAGS) $(INCLUDES) -c $< -o $@

################################################################################
# install
################################################################################
# We install headers and generate rte_build_config.h if needed, flattening them
# into $(PREFIX)/include. We also place the static library in $(PREFIX)/lib.

install: all
	@echo ">> Installing to $(PREFIX)"
	# Create required directories
	mkdir -p $(PREFIX)/lib
	mkdir -p $(PREFIX)/include
	mkdir -p $(PREFIX)/include/sys
	mkdir -p $(PREFIX)/include/netinet

	# Install static library
	cp -f $(TARGET_LIB) $(PREFIX)/lib

	# Copy rte_config.h (if it exists)
	@echo ">> Copying rte_config.h..."
	if [ -f config/rte_config.h ]; then \
		cp -f config/rte_config.h $(PREFIX)/include/; \
	fi

	@echo ">> Generating rte_build_config.h..."
	cat > $(PREFIX)/include/rte_build_config.h << 'EOF'
/*
 * SPDX-License-Identifier: BSD-3-Clause
 * Copyright(c) 2010-2014 Intel Corporation
 */

/**
 * @file
 * DPDK Build Configuration
 */

#ifndef _RTE_BUILD_CONFIG_H_
#define _RTE_BUILD_CONFIG_H_

/* This file was auto-generated from meson build system */

/* Platform */
#define RTE_ARCH "x86_64"
#define RTE_MACHINE "native"
#define RTE_CACHE_LINE_SIZE 64

/* Compilation */
#define RTE_TOOLCHAIN "gcc"
#define RTE_TOOLCHAIN_GCC 1
#define RTE_CCFLAGS "-Wall -O3 -fPIC"

/* Enable libraries */
#define RTE_HAS_LIBEAL 1
#define RTE_HAS_LIBRTE_MBUF 1
#define RTE_HAS_LIBRTE_MEMPOOL 1
#define RTE_HAS_LIBRTE_RING 1
#define RTE_HAS_LIBRTE_ETHER 1
#define RTE_HAS_LIBRTE_NET 1
#define RTE_HAS_LIBRTE_TIMER 1
#define RTE_HAS_LIBRTE_HASH 1
#define RTE_HAS_LIBRTE_EFD 1
#define RTE_HAS_LIBRTE_CMDLINE 1
#define RTE_HAS_LIBRTE_KVARGS 1

/* Environment abstraction layer */
#define RTE_MAX_LCORE 128
#define RTE_MAX_NUMA_NODES 8
#define RTE_MAX_MEMSEG 512
#define RTE_MAX_MEMZONE 2560
#define RTE_MAX_TAILQ 32
#define RTE_LOG_LEVEL 8
#define RTE_ENABLE_ASSERT 1
#define RTE_BACKTRACE 1
#define RTE_EAL_PMD_PATH ""

/* Execution units */
#define RTE_MAX_VFIO_GROUPS 64

/* Ethernet */
#define RTE_MAX_ETHPORTS 32
#define RTE_MAX_QUEUES_PER_PORT 1024
#define RTE_ETHDEV_QUEUE_STAT_CNTRS 16
#define RTE_ETHDEV_RXTX_CALLBACKS 1

/* Mempool */
#define RTE_MEMPOOL_CACHE_MAX_SIZE 512
#define RTE_MEMPOOL_ALIGN 128

/* Mbuf */
#define RTE_MBUF_DEFAULT_MEMPOOL_OPS "ring_mp_mc"
#define RTE_MBUF_REFCNT_ATOMIC 1
#define RTE_PKTMBUF_HEADROOM 128

/* Driver enablement */
#define RTE_NET_VIRTIO 1
#define RTE_NET_VMXNET3 1
#define RTE_NET_E1000 1
#define RTE_NET_IXGBE 1
#define RTE_NET_I40E 1
#define RTE_CRYPTO 1
#define RTE_CRYPTO_AESNI_MB 1

/* Common configuration flags */
#define RTE_CFLAGS "-march=native -DRTE_MACHINE_CPUFLAG_SSE -DRTE_MACHINE_CPUFLAG_SSE2 -DRTE_MACHINE_CPUFLAG_SSE3 -DRTE_MACHINE_CPUFLAG_SSSE3 -DRTE_MACHINE_CPUFLAG_SSE4_1 -DRTE_MACHINE_CPUFLAG_SSE4_2 -DRTE_MACHINE_CPUFLAG_AES -DRTE_MACHINE_CPUFLAG_PCLMULQDQ -DRTE_MACHINE_CPUFLAG_AVX -DRTE_COMPILE_TIME_CPUFLAGS=RTE_CPUFLAG_SSE,RTE_CPUFLAG_SSE2,RTE_CPUFLAG_SSE3,RTE_CPUFLAG_SSSE3,RTE_CPUFLAG_SSE4_1,RTE_CPUFLAG_SSE4_2,RTE_CPUFLAG_AES,RTE_CPUFLAG_PCLMULQDQ,RTE_CPUFLAG_AVX"

#endif /* _RTE_BUILD_CONFIG_H_ */
EOF

	@echo ">> Directly copying essential headers..."

	# EAL headers
	for header in lib/eal/include/*.h; do \
		cp -f "$$header" "$(PREFIX)/include/" || true; \
	done

	# Ethdev headers
	for header in lib/ethdev/*.h; do \
		cp -f "$$header" "$(PREFIX)/include/" || true; \
	done

	# Mbuf headers
	for header in lib/mbuf/*.h; do \
		cp -f "$$header" "$(PREFIX)/include/" || true; \
	done

	# Net headers
	for header in lib/net/*.h; do \
		cp -f "$$header" "$(PREFIX)/include/" || true; \
	done

	# Ring headers
	for header in lib/ring/*.h; do \
		cp -f "$$header" "$(PREFIX)/include/" || true; \
	done

	# Mempool headers
	for header in lib/mempool/*.h; do \
		cp -f "$$header" "$(PREFIX)/include/" || true; \
	done

	# Windows sys and netinet
	if [ -d lib/eal/windows/include/sys ]; then \
		cp -f lib/eal/windows/include/sys/*.h $(PREFIX)/include/sys/ || true; \
	fi

	if [ -d lib/eal/windows/include/netinet ]; then \
		cp -f lib/eal/windows/include/netinet/*.h $(PREFIX)/include/netinet/ || true; \
	fi

	# Linux sys and netinet
	if [ -d lib/eal/linux/include/sys ]; then \
		cp -f lib/eal/linux/include/sys/*.h $(PREFIX)/include/sys/ || true; \
	fi

	if [ -d lib/eal/linux/include/netinet ]; then \
		cp -f lib/eal/linux/include/netinet/*.h $(PREFIX)/include/netinet/ || true; \
	fi

	# Manual fallback for critical headers
	@echo ">> Manual fallback for critical headers..."
	for file in rte_eal.h rte_ethdev.h rte_mbuf.h rte_version.h; do \
		if [ ! -f "$(PREFIX)/include/$$file" ]; then \
			found=$$(find . -name $$file -type f | head -1); \
			if [ -n "$$found" ]; then \
				echo "Copying $$found to $(PREFIX)/include/"; \
				cp -f "$$found" "$(PREFIX)/include/"; \
			else \
				echo "ERROR: Could not find $$file!"; \
			fi; \
		fi; \
	done

	@echo ">> Copying remaining lib headers..."
	find lib -name "*.h" -type f | while read -r header; do \
		base=$$(basename "$$header"); \
		cp -f "$$header" "$(PREFIX)/include/$$base" || true; \
	done

	@echo ">> Copying driver headers..."
	find drivers -name "*.h" -type f | grep -v "/test/" | grep -v "/doc/" | while read -r header; do \
		base=$$(basename "$$header"); \
		cp -f "$$header" "$(PREFIX)/include/$$base" || true; \
	done

	@echo ">> Verifying critical headers..."
	ls -la $(PREFIX)/include/rte_*.h || true

	@echo ">> Installation complete"
	@echo ">> Total headers installed: $$(ls -1 $(PREFIX)/include/*.h 2>/dev/null | wc -l)"

################################################################################
# cleanup
################################################################################

clean:
	rm -f $(OBJS) $(TARGET_LIB)
