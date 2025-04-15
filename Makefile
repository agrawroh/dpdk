################################################################################
# Minimal/Legacy-Style Makefile for building DPDK libraries
# Warning: For DPDK >= 21.x you will need to adapt/patch code!
################################################################################

# Adjust as needed
RTE_TARGET ?= x86_64-native-linux-gcc
RTE_SDK    ?= $(CURDIR)

# Common flags (adjust to match your environment)
CFLAGS     = -O3 -g -fPIC -Wall -Werror
INCFLAGS   = -I$(RTE_SDK) -I$(RTE_SDK)/$(RTE_TARGET)/include

# DPDK libraries often require extra flags
# e.g., -march=native or -mavx512f for some vector code
# Add any required flags here:
DPDK_CFLAGS = 

# For linking; might need many more libs depending on config
LDLIBS      = -lm -lpthread -ldl

# If you are building with NUMA support, hugepage support, etc., you might need:
# -lnuma -lrte_eal -lrte_mempool -lrte_ring - ... etc.

# Subdirectories that build DPDK components (example from older structure)
SUBDIRS = lib drivers

# The final “build all” target
all: config $(SUBDIRS)

# The old 'make config' concept—use a .config file or environment variables
# For demonstration, this is a placeholder
config:
	@echo ">> Using target: $(RTE_TARGET)"
	@mkdir -p $(RTE_TARGET)/build
	@touch $(RTE_TARGET)/.config
	@echo ">> (Optional) Generate config headers or set environment variables here"
	@echo ">> This is a placeholder that you must adapt to your system."

# Build each subdir in sequence
$(SUBDIRS):
	$(MAKE) -C $@ RTE_SDK=$(RTE_SDK) RTE_TARGET=$(RTE_TARGET) \
	        CFLAGS="$(CFLAGS) $(DPDK_CFLAGS) $(INCFLAGS)" \
	        LDLIBS="$(LDLIBS)"

# Example subdir Makefile snippet (e.g. dpdk/lib/Makefile):
# 
#   LIB_SRCS = rte_eal.c rte_memory.c ...
#   LIB_OBJS = $(LIB_SRCS:.c=.o)
# 
#   all: libdpdk.a
# 
#   libdpdk.a: $(LIB_OBJS)
#       ar rcs $@ $^
# 
#   %.o: %.c
#       $(CC) $(CFLAGS) -c $< -o $@
# 
#   clean:
#       rm -f $(LIB_OBJS) libdpdk.a
# 

clean:
	rm -rf $(RTE_TARGET) */*.o */*.a

.PHONY: all config clean $(SUBDIRS)
