MEXFILES ?= ssr_binaural ssr_aap ssr_nfc_hoa ssr_vbap ssr_wfs ssr_brs ssr_generic

MATLABROOT ?=c:/Progra~1/MATLAB/R2012b
SSR_DIR ?= ../..

SOURCES := ssr_global position orientation directionalpoint xmlparser

MEX_DIR = $(SSR_DIR)/mex
APF_DIR = $(SSR_DIR)/apf
SRC_DIR = $(SSR_DIR)/src
EXTERN_DIR = $(SSR_DIR)/3rdparty/win64

TARGETS := $(MEXFILES:%=$(MEX_DIR)/%.mexw64)
OBJECTS := $(SOURCES:%=$(SRC_DIR)/%.o)

CXX = g++

CXXFLAGS += -std=c++11

# optimization:
CXXFLAGS += -O3
CXXFLAGS += -DNDEBUG

CXXFLAGS += -Wall -Wextra
CXXFLAGS += -pedantic
# warnings are errors
CXXFLAGS += -pedantic-errors
CXXFLAGS += -Werror
# even more warnings:
# CXXFLAGS += -Wpointer-arith
# CXXFLAGS += -Wcast-align
# CXXFLAGS += -Wwrite-strings
# CXXFLAGS += -Wredundant-decls
# CXXFLAGS += -Wlong-long
# CXXFLAGS += -Wconversion
# CXXFLAGS += -Wsign-conversion
# CXXFLAGS += -Wshadow
# CXXFLAGS += -Wold-style-cast
# CXXFLAGS += -Winline

CXXFLAGS += -Wl,--export-all-symbols -m64 -shared -DMATLAB_MEX_FILE
CXXFLAGS += -I$(MATLABROOT)/extern/include 
CXXFLAGS += -I$(APF_DIR) -I$(SRC_DIR) -I$(EXTERN_DIR)/include

LIBS += -L$(MATLABROOT)/bin/win64
LIBS += -L$(MATLABROOT)/extern/lib/win64/microsoft 
LIBS += -lmex -lmx -lmwlapack -leng -lmwblas -ladvapi32 -luser32 -lgdi32 -lkernel32 -lmingwex
LIBS += -L$(EXTERN_DIR)/lib/
LIBS += -lxml2 -lws2_32 
LIBS += -llibfftw3f-3
LIBS += -llibsndfile-1

all: matlab 

matlab : $(TARGETS)

%.mexw64 %.mexw32 : $(OBJECTS) %.o
	$(CXX) $(CXXFLAGS) $? -o $@ $(LIBS)

%.o : %.cpp 
	$(CXX) $(CXXFLAGS) -c -o $@ $<
	
clean: 
	rm -f $(MEX_DIR)/*.mex*
	