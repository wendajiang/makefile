#############################################################################
## Customizable Section: adapt those variables to suit your program.
##==========================================================================
CONFIGURE = Release
# The pre-processor options used by the cpp (man cpp for more).
CPPFLAGS  = -g -fPIC -D__STDC_CONSTANT_MACROS -Wall -std=c++11 -mcx16 \
			-I/usr/local/protobuf3.3/include 
			
# The options used in linking as well as in any direct use of ld.
LDFLAGS   = -Wl,-z,defs,-Bsymbolic
LD_FLAGS= -Wl,-stack_size,0x10000000
SPE_LIBS = -L /usr/local/protobuf3.3/lib/ -lpthread -lrt -luuid -lstdc++ -lprotobuf 
			 
# The directories in which source files reside.
SRCDIRS   = ./ 

# The target file name.
#OUTPUT   = ../lib/linux/live/$(CONFIGURE)/LIVES.so
OUTPUT   = ./bin/$(CONFIGURE)/pb_demo

## Implicit Section: change the following only when necessary.
##==========================================================================

# The source file types (headers excluded).
# .c indicates C source files, and others C++ ones.
SRCEXTS = .c .C .cc .cpp .CPP .c++

# The header file types.
HDREXTS = .h .H .hh .hpp .HPP .h++

# The pre-processor and compiler options.
# Users can override those variables from the command line.
CFLAGS  = 
#-std=c99
CXXFLAGS= 

# The C program compiler.
CC     = gcc -g -mcx16

# The C++ program compiler.
CXX    = g++ -g -mcx16

# Un-comment the following line to compile C programs as C++ ones.
#CC     = $(CXX)

# The command used to delete file.
RM     = rm -f

# The command used to generate timestamp.
DATE   = `date '+%Y%m%d-%H%M%S'`

# The command used to pack
TAR    = tar -zcf

# The command used to create archives
AR     = ar rcs

## Stable Section: usually no need to be changed. But you can add more.
##==========================================================================
SHELL   = /bin/sh
EMPTY   =
SPACE   = $(EMPTY) $(EMPTY)
SOURCES = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS))))
HEADERS = $(foreach d,$(SRCDIRS),$(wildcard $(addprefix $(d)/*,$(HDREXTS))))
SRC_CXX = $(filter-out %.c,$(SOURCES))
OBJS    = $(addsuffix .o, $(basename $(SOURCES)))
DEPS    = $(OBJS:.o=.d)

## Define some useful variables.
DEP_OPT = $(shell if `$(CC) --version | grep -i "GCC" >/dev/null`; then \
                  echo "-MM -MP"; else echo "-M"; fi )
DEPEND      = $(CC)  $(DEP_OPT) $(CFLAGS) $(CPPFLAGS)
DEPEND.d    = $(subst -g ,,$(DEPEND))
COMPILE.c   = $(CC) $(CFLAGS)   $(CPPFLAGS) -c
COMPILE.cxx = $(CXX) $(CXXFLAGS) $(CPPFLAGS) -c
LINK.c      = $(CC)  $(LDFLAGS)
LINK.cxx    = $(CXX) $(LDFLAGS)

.PHONY: all dist clean distclean

# Delete the default suffixes
.SUFFIXES:

all: $(OUTPUT)

# Rules for creating dependency files (.d).
#------------------------------------------
%.d:%.c
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

%.d:%.C
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

%.d:%.cc
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

%.d:%.cpp
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

%.d:%.CPP
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

%.d:%.c++
	@echo -n $(dir $<) > $@
	@$(DEPEND.d) $< >> $@

# Rules for generating object files (.o).
#----------------------------------------
%.o:%.c
	$(COMPILE.c) $< -o $@

%.o:%.C
	$(COMPILE.cxx) $< -o $@

%.o:%.cc
	$(COMPILE.cxx) $< -o $@

%.o:%.cpp
	$(COMPILE.cxx) $< -o $@

%.o:%.CPP
	$(COMPILE.cxx) $< -o $@

%.o:%.c++
	$(COMPILE.cxx) $< -o $@

# Rules for generating the executable.
#-------------------------------------
$(OUTPUT):$(OBJS)
ifeq ($(SRC_CXX),)              # C program
	$(LINK.c)   $(OBJS) $(SPE_LIBS) -o $@
else                            # C++ program
	$(LINK.cxx) $(OBJS) $(SPE_LIBS) -o $@
endif
	@echo Building $@ completed.

ifneq ($(DEPS),)
  sinclude $(DEPS)
endif

dist: all
	$(TAR) $(OUTPUT).$(DATE).tar.gz $(OUTPUT)

clean:
	$(RM) $(OBJS) $(DEPS) $(OUTPUT)

distclean: clean
	$(RM) $(DEPS) $(OUTPUT).*.tar.gz

