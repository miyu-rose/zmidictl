SHELL=fish.x
AS=has060x
LK=hlkx

OBJ=zmidictl.o zmidilib.o miyulib.o
OBJ_DEBUG=zmidictl_dbg.o zmidilib_dbg.o miyulib.o

all : zmidictl.x
debug : zmidictl_dbg.x

zmidictl.x : $(OBJ)
	$(LK) -x -o$@ $(OBJ)
zmidictl_dbg.x : $(OBJ_DEBUG)
	$(LK) -x -o$@ $(OBJ_DEBUG)

zmidictl_dbg.o : zmidictl.s
	$(AS) -u -s__DEBUG__ -o$@ $<
zmidilib_dbg.o : zmidilib.s
	$(AS) -u -w3 -s__DEBUG__ -o$@ $<

%.o : %.s
	$(AS) -u -w3 $<


clean :
	-rm *.o *.x *.*~ *.bak *_dbg.* > NUL

zmidictl.o     : zmidi.h
zmidictl_dbg.o : zmidi.h
zmidilib.o     : zmidi.h
zmidilib_dbg.o : zmidi.h
