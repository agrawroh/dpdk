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
	
	# EAL headers (top-level eal/include/*.h)
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

	############################################################################
	# EAL ARCH-SPECIFIC HEADERS (Flatten each subdir inside eal/*)
	############################################################################

	# eal/loongarch/include
	@echo ">> Copying eal loongarch headers..."
	if [ -d lib/eal/loongarch/include ]; then \
		for header in lib/eal/loongarch/include/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi

	# eal/x86 (some in x86 root, some in x86/include)
	@echo ">> Copying eal x86 headers..."
	if [ -d lib/eal/x86 ]; then \
		for header in lib/eal/x86/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi
	if [ -d lib/eal/x86/include ]; then \
		for header in lib/eal/x86/include/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi

	# eal/riscv/include
	@echo ">> Copying eal riscv headers..."
	if [ -d lib/eal/riscv/include ]; then \
		for header in lib/eal/riscv/include/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi

	# eal/arm/include
	@echo ">> Copying eal arm headers..."
	if [ -d lib/eal/arm/include ]; then \
		for header in lib/eal/arm/include/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi

	# eal/ppc/include
	@echo ">> Copying eal ppc headers..."
	if [ -d lib/eal/ppc/include ]; then \
		for header in lib/eal/ppc/include/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi

	# eal/windows
	@echo ">> Copying eal windows special headers..."
	# e.g. eal_windows.h at root, plus eal/windows/include/*.h
	if [ -f lib/eal/windows/eal_windows.h ]; then \
		cp -f lib/eal/windows/eal_windows.h "$(PREFIX)/include/" || true; \
	fi
	if [ -d lib/eal/windows/include ]; then \
		for header in lib/eal/windows/include/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi

	# eal/freebsd
	@echo ">> Copying eal freebsd headers..."
	if [ -d lib/eal/freebsd ]; then \
		# freebsd/eal_alarm_private.h
		for header in lib/eal/freebsd/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi
	if [ -d lib/eal/freebsd/include ]; then \
		for header in lib/eal/freebsd/include/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi

	# eal/include/generic
	@echo ">> Copying eal generic headers..."
	if [ -d lib/eal/include/generic ]; then \
		for header in lib/eal/include/generic/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi

	# eal/common
	@echo ">> Copying eal common headers..."
	if [ -d lib/eal/common ]; then \
		for header in lib/eal/common/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi

	# eal/linux
	@echo ">> Copying eal linux headers..."
	if [ -d lib/eal/linux ]; then \
		for header in lib/eal/linux/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi
	if [ -d lib/eal/linux/include ]; then \
		for header in lib/eal/linux/include/*.h; do \
			cp -f "$$header" "$(PREFIX)/include/" || true; \
		done; \
	fi

	############################################################################
	# End EAL arch-specific section
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
			fi; \
		fi; \
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
