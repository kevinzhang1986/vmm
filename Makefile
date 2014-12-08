# $FreeBSD: releng/10.1/sys/modules/vmm/Makefile 268891 2014-07-19 22:06:46Z jhb $

KMOD=	vmm

SRCS=	opt_acpi.h opt_ddb.h device_if.h bus_if.h pci_if.h

CFLAGS+= -DVMM_KEEP_STATS -DSMP
CFLAGS+= -Iio
CFLAGS+= -Iintel

# generic vmm support
SRCS+=	vmm.c		\
	vmm_dev.c	\
	vmm_host.c	\
	vmm_instruction_emul.c	\
	vmm_ioport.c	\
	vmm_ipi.c	\
	vmm_lapic.c	\
	vmm_mem.c	\
	vmm_msr.c	\
	vmm_stat.c	\
	vmm_util.c	\
	x86.c		\
	vmm_support.S

.PATH: io
SRCS+=	iommu.c		\
	ppt.c           \
	vatpic.c	\
	vatpit.c	\
	vhpet.c		\
	vioapic.c	\
	vlapic.c

# intel-specific files
.PATH: intel
SRCS+=	ept.c		\
	vmcs.c		\
	vmx_msr.c	\
	vmx.c		\
	vtd.c

# amd-specific files
.PATH: amd
SRCS+=	amdv.c

OBJS=	vmx_support.o

CLEANFILES=	vmx_assym.s vmx_genassym.o

vmx_assym.s:    vmx_genassym.o
.if exists(@)
vmx_assym.s:    @/kern/genassym.sh
.endif
	sh @/kern/genassym.sh vmx_genassym.o > ${.TARGET}

vmx_support.o:	vmx_support.S vmx_assym.s
	${CC} -c -x assembler-with-cpp -DLOCORE ${CFLAGS} \
	    ${.IMPSRC} -o ${.TARGET}

vmx_genassym.o: vmx_genassym.c @ machine x86
	${CC} -c ${CFLAGS:N-fno-common} ${.IMPSRC}

.include <bsd.kmod.mk>
