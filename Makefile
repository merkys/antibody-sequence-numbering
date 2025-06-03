MAKEFILE_DIRS = .
MAKEFILE_WCARDS = $(addsuffix /Makelocal*, ${MAKEFILE_DIRS})
MAKECONF_WCARDS = $(addsuffix /Makeconf*, ${MAKEFILE_DIRS})

MAKECONF_FILES = $(filter-out %.example, \
	$(filter-out %~, $(wildcard ${MAKECONF_WCARDS}) \
))

ifneq ("${MAKECONF_FILES}","")
include ${MAKECONF_FILES}
endif

.PHONY: all clean distclean cleanAll

all:

clean:

cleanAll distclean: clean

MAKELOCAL_FILES = ${filter-out %~, ${wildcard ${MAKEFILE_WCARDS}}}

ifneq ("${MAKELOCAL_FILES}","")
include ${MAKELOCAL_FILES}
endif
