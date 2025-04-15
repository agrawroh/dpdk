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
# Direct approach to copying all header files using direct paths

install: all
	@echo ">> Installing to $(PREFIX)"
	
	# Create required directories
	mkdir -p $(PREFIX)/lib
	mkdir -p $(PREFIX)/include
	mkdir -p $(PREFIX)/include/sys
	mkdir -p $(PREFIX)/include/netinet
	
	# Install static library
	cp -f $(TARGET_LIB) $(PREFIX)/lib
	
	# Copy rte_config.h (which we know works)
	@echo ">> Copying rte_config.h..."
	if [ -f config/rte_config.h ]; then \
		cp -f config/rte_config.h $(PREFIX)/include/; \
	fi

	@echo ">> Copying rte_build_config.h..."
	if [ -f config/rte_build_config.h ]; then \
		cp -f config/rte_build_config.h $(PREFIX)/include/; \
	fi
	
	# Direct copy of essential headers - avoiding pipes and loops which might fail
	@echo ">> Directly copying essential headers..."
	
	# EAL headers
	for header in lib/eal/include/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	for header in lib/eal/common/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	for header in lib/eal/linux/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	for header in lib/eal/linux/include/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	for header in lib/eal/include/generic/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	for header in lib/eal/include/generic/*.h; do \
		cp -f $$header $(PREFIX)/include/generic/ || true; \
	done

	# Ethdev headers
	for header in lib/ethdev/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done
	
	# Mbuf headers
	for header in lib/mbuf/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done
	
	# Net headers
	for header in lib/net/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	############################################################################
	# NEW: Explicitly copy headers from additional DPDK subdirectories
	############################################################################
	# For each subdirectory, replicate the pattern above: a for-loop copying *.h

	# ACL
	for header in lib/acl/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# argparse
	for header in lib/argparse/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# bbdev
	for header in lib/bbdev/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# bitratestats
	for header in lib/bitratestats/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# bpf
	for header in lib/bpf/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# cfgfile
	for header in lib/cfgfile/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# cmdline
	for header in lib/cmdline/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# compressdev
	for header in lib/compressdev/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# cryptodev
	for header in lib/cryptodev/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# distributor
	for header in lib/distributor/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# dmadev
	for header in lib/dmadev/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# efd
	for header in lib/efd/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# eventdev
	for header in lib/eventdev/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# fib
	for header in lib/fib/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# graph
	for header in lib/graph/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# gpudev
	for header in lib/gpudev/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# gro
	for header in lib/gro/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# gso
	for header in lib/gso/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# hash
	for header in lib/hash/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# ip_frag
	for header in lib/ip_frag/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# ipsec
	for header in lib/ipsec/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# jobstats
	for header in lib/jobstats/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# kvargs
	for header in lib/kvargs/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# latencystats
	for header in lib/latencystats/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# lpm
	for header in lib/lpm/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# member
	for header in lib/member/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# meter
	for header in lib/meter/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# mempool
	for header in lib/mempool/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# metrics
	for header in lib/metrics/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# mldev
	for header in lib/mldev/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# node
	for header in lib/node/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# pci
	for header in lib/pci/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# pdcp
	for header in lib/pdcp/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# pipeline
	for header in lib/pipeline/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# port
	for header in lib/port/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# power
	for header in lib/power/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# ptr_compress
	for header in lib/ptr_compress/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# rawdev
	for header in lib/rawdev/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# reorder
	for header in lib/reorder/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# rib
	for header in lib/rib/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# ring
	for header in lib/ring/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# rcu
	for header in lib/rcu/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# regexdev
	for header in lib/regexdev/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# sched
	for header in lib/sched/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# security
	for header in lib/security/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# stack
	for header in lib/stack/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# table
	for header in lib/table/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# telemetry
	for header in lib/telemetry/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# timer
	for header in lib/timer/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# vhost
	for header in lib/vhost/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# pcapng
	for header in lib/pcapng/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# log
	for header in lib/log/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	# dispatcher
	for header in lib/dispatcher/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	for header in lib/eal/x86/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	for header in lib/eal/x86/include/*.h; do \
		cp -f $$header $(PREFIX)/include/ || true; \
	done

	############################################################################
	# End new subdirectory block
	############################################################################
	
	# Copy system headers
	if [ -d lib/eal/windows/include/sys ]; then \
		cp -f lib/eal/windows/include/sys/*.h $(PREFIX)/include/sys/ || true; \
	fi
	
	if [ -d lib/eal/windows/include/netinet ]; then \
		cp -f lib/eal/windows/include/netinet/*.h $(PREFIX)/include/netinet/ || true; \
	fi
	
	# Manual copy of critical headers if they haven't been copied yet
	@echo ">> Manual fallback for critical headers..."
	for file in rte_eal.h rte_ethdev.h rte_mbuf.h rte_version.h; do \
		if [ ! -f $(PREFIX)/include/$$file ]; then \
			found=$$(find . -name $$file -type f | head -1); \
			if [ -n "$$found" ]; then \
				echo "Copying $$found to $(PREFIX)/include/"; \
				cp -f $$found $(PREFIX)/include/; \
			else \
				echo "ERROR: Could not find $$file!"; \
			fi \
		fi \
	done
	
	# Copy all remaining header files from lib (with a more robust loop)
	@echo ">> Copying remaining lib headers..."
	find lib -name "*.h" -type f | while read -r header; do \
		base=$$(basename "$$header"); \
		cp -f "$$header" "$(PREFIX)/include/$$base" || true; \
	done
	
	# Copy driver headers that might be needed
	@echo ">> Copying driver headers..."
	find drivers -name "*.h" -type f | grep -v "/test/" | grep -v "/doc/" | while read -r header; do \
		base=$$(basename "$$header"); \
		cp -f "$$header" "$(PREFIX)/include/$$base" || true; \
	done
	
	# Final verification
	@echo ">> Verifying critical headers..."
	ls -la $(PREFIX)/include/rte_*.h
	
	@echo ">> Installation complete"
	@echo ">> Total headers installed: $$(ls -1 $(PREFIX)/include/*.h | wc -l)"

################################################################################
# cleanup
################################################################################

clean:
	rm -f $(OBJS) $(TARGET_LIB)
