//----------------------------------------------------
// Copyright (c) 2014, SHENZHEN PENGRUI SOFT CO LTD. All rights reserved.

// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:

// 1. Redistributions of source code must retain the above copyright notice,
//    this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and/or other materials provided with the distribution.

// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//-----------------------------------------------------------------------------
// Copyright (c) 2014 ����Ȩ�����������������޹�˾���С�����Ȩ�˱���һ��Ȩ����
//
// �����Ȩ�����ʹ���߷������������������£�����ʹ����ʹ�ü���ɢ����
// ������װԭʼ�뼰����λ��ִ����ʽ��Ȩ�������۴˰�װ�Ƿ񾭸�����Ȼ��
//
// 1. ���ڱ�����Դ�������ɢ�������뱣�������İ�Ȩ���桢�������б�����
//    ������������������
// 2. ���ڱ��׼�����λ��ִ����ʽ����ɢ���������������ļ��Լ�������������
//    ��ɢ����װ�е�ý�鷽ʽ����������֮��Ȩ���桢�������б����Լ�����
//    ������������

// �����������������Ǳ�������Ȩ�������Լ�����������״��"as is"���ṩ��
// ��������װ�����κ���ʾ��Ĭʾ֮�������Σ������������ھ��������Լ��ض�Ŀ
// �ĵ�������ΪĬʾ�Ե�������Ȩ�����˼�������֮�����ߣ������κ�������
// ���۳�����κ��������塢���۴�����Ϊ���Լ��ϵ���޹�ʧ������������Υ
// Լ֮��Ȩ��������ʧ������ԭ��ȣ����𣬶����κ���ʹ�ñ�������װ��������
// �κ�ֱ���ԡ�����ԡ�ż���ԡ������ԡ��ͷ��Ի��κν�����𺦣�����������
// �������Ʒ������֮���á�ʹ����ʧ��������ʧ��������ʧ��ҵ���жϵȵȣ���
// �����κ����Σ����ڸ���ʹ���ѻ���ǰ��֪���ܻ���ɴ����𺦵���������Ȼ��
//-----------------------------------------------------------------------------
//����ģ��:  CPU��ʼ��
 //���ߣ�     Liuwei
 //�汾��      V1.1.0
 //�ļ�����:  CPU��ʼ�������û������ʵ�ֵĲ���
//����˵��:  ��
//�޶���ʷ:

 //1. ����: 2015-02-22
 //  ����: Liuwei
 //  �°汾�ţ�V1.0.0
 //  �޸�˵��: s3c2416��ԭʼ�汾
 //------------------------------------------------------


.fpu	softvfp
.file	"initcpu.S"

#include "arm_mode_s_file.h"
#include "initcpu.h"

//// DRAM Register Address
#define BANKCFG 	0x48000000	//DRAM configuration
#define BANKCON1 	0x48000004	//DRAM control
#define BANKCON2 	0x48000008	//DRAM timing control
#define BANKCON3	0x4800000C	//DRAM (E)MRS
#define REFRESH 	0x48000010	//DRAM refresh control
#define TIMEOUT 	0x48000014	//Write Buffer Time out control

#define	WTCON   	0x53000000
#define	GPKCON		0x560000E0	//Configure the pins of portttt K

#define	LOCKCON0	0x4C000000  //MPLL lock time conut
#define	LOCKCON1	0x4C000004  //EPLL lock time count
#define	MPLLCON		0x4C000010  //MPLL configuration
#define	EPLLCON		0x4C000018  //EPLL configuration
#define	CLKSRC		0x4C000020  //Clock source control
#define	CLKDIV0		0x4C000024  //Clock divider ratio control
#define	CLKDIV1     0x4C000028  //Clock divider ratio control
#define	HCLKCON     0x4C000030  //HCLK enable
#define	PCLKCON     0x4C000034  //PCLK enable
#define	SCLKCON     0x4C000038  //Special clock enable

.section .text._start, "ax", %progbits
.align  2
.global _start
_start: 
     
    ldr     r0,=R1_I|R1_C       //��ֹMMU,ʹ��I-Cahce.
    mcr     p15, 0, r0, c1, c0, 0
    
    mov     r0,#0
    mcr     p15,0,r0,c7,c7,0    //Invalidate I+D Cache
    mcr     p15,0,r0,c8,c7,0    //Invalidate I+D TLB
        
    mrs     r0, cpsr                //ȡCPSR
    bic     r0, r0, #SF_MODEMASK    //��ģʽλ
    orr     r1, r0, #(SF_SVCMODE|SF_IRQ_BIT|SF_FIQ_BIT) //����Ϊ����̬������ֹ�ж�
    msr     cpsr,r1

    ldr     r0,=WTCON           //��ֹ���Ź�
    ldr     r1,=0x0
    str     r1,[r0]

    bl      init_clock      //clock_init�ɻ��ʵ��,û��ѹջ����,�����ڴ�ֱ�ӵ���

    mov     r0,pc
    ldr     r1,=0x30000000
    ldr     r2,=0x34000000
    cmp     r0,r1
    bcc     BootFromNandFlash
    cmp     r0,r2
    bcs     BootFromNandFlash
  	
    ////��ʼ��MMU
    ldr		r0,=R1_I
    mcr     p15, 0, r0, c1, c0, 0

    ldr     sp,=usr_top
    bl		MMU_Init

    ldr		r0,=R1_M|R1_I|R1_C|R1_V
    mcr     p15, 0, r0, c1, c0, 0
	nop
	nop
	nop
	nop
	ldr		r0,=0xFFFF0000
	ldr		r1,=isr_vector
	ldr		r2,=isr_vector_end
copy_isr_table:
	ldmia	r1!,{r4-r7}
	stmia	r0!,{r4-r7}
	cmp		r1,r2
	bcc		copy_isr_table
	nop
	nop

   //// ��ʼ��ջָ��
    mov     r1,#SF_UNDEFMODE|SF_IRQ_BIT|SF_FIQ_BIT
    msr     cpsr_cxsf,r1        //UndefMode
    ldr     sp,=undef_top
    bic     sp,sp,#0x07

    mov     r1,#SF_ABORTMODE|SF_IRQ_BIT|SF_FIQ_BIT
    msr     cpsr_cxsf,r1        //AbortMode
    ldr     sp,=abort_top
    bic     sp,sp,#0x07

    mov     r1,#SF_IRQMODE|SF_IRQ_BIT|SF_FIQ_BIT
    msr     cpsr_cxsf,r1        //IRQMode
    ldr     sp,=irq_top
    bic     sp,sp,#0x07

    mov     r1,#SF_FIQMODE|SF_IRQ_BIT|SF_FIQ_BIT
    msr     cpsr_cxsf,r1        //FIQMode
    ldr     sp,=fiq_top
    bic     sp,sp,#0x07

    mov     r1,#SF_SVCMODE|SF_IRQ_BIT|SF_FIQ_BIT
    msr     cpsr_cxsf,r1        //SVCMode
    ldr     sp,=svc_top
    bic     sp,sp,#0x07

    mov     r1,#SF_SYSMODE|SF_IRQ_BIT|SF_FIQ_BIT
    msr     cpsr_cxsf,r1        //SYSMode
    ldr     sp,=usr_top
    bic     sp,sp,#0x07
    nop
    nop
    bl      Load_Preload
	nop
	nop
	b	.

////////////////////////////

init_clock:
    ldr     r0,=MPLLCON         // Set MPLL off
    ldr     r1,[r0]
    bic     r1,#(1<<24)
    str     r1,[r0]
    nop
    nop
    ldr     r0,=CLKDIV0         // Set Clock Divider
    ldr     r1,[r0]
    bic     r1,r1,#0x37         // clear HCLKDIV, PREDIV, PCLKDIV
    bic     r1,r1,#(0xf<<9)     // clear ARMCLKDIV
    ldr     r2,=CLK_DIV_VAL
    orr     r1,r1,r2
    str     r1,[r0]

    ldr     r0,=LOCKCON0        // Set lock time of MPLL. added by junon
    ldr     r1,=0x0FFF
    str     r1,[r0]

    ldr     r0,=MPLLCON         // Set MPLL on
    ldr     r1,=MPLL_VAL
    str     r1,[r0]

    ////
    ldr     r0,=LOCKCON1        // Set lock time of EPLL. added by junon
    ldr     r1,=0x0FFF
    str     r1,[r0]

    ldr     r0,=EPLLCON         // Set EPLL on
    ldr     r1,=EPLL_VAL
    str     r1,[r0]

    ////
    ldr     r0,=CLKSRC          // Select MPLL clock out for SYSCLK
    ldr     r1,[r0]
    orr     r1,r1,#0x10
    str     r1,[r0]
    nop
    nop
    mrc     p15, 0, r0, c1, c0, 0
    orr     r0, r0, #0xc0000000   // Clock setting in MMU
    mcr     p15, 0, r0, c1, c0, 0
    bx      lr
////////////////////////////
init_dmc:
    //InitMEM(DDR2)
    ldr     r0,=GPKCON
    ldr     r1,=0xaaaaaaaa
    str     r1, [r0]

    //Set DDR2 Memory parameter control registers
    ldr     r0,=BANKCFG
    ldr     r1,=BANKCFGVAL      // set Sdata[31:16]
    str     r1, [r0]

    ldr     r0,=BANKCON1
    ldr     r1,=BANKCON1VAL     // set Sdata[31:16]
    str     r1, [r0]

    ldr     r0,=BANKCON2
    ldr     r1,=BANKCON2VAL     // set Sdata[31:16]
    str     r1, [r0]

    ldr     r2,=BANKCON1        // 4nd:Issue a PALL command
    ldr     r1,[r2]
    bic     r1,r1,#(0x3<<0)
    orr     r1,r1,#(0x1<<0)
    str     r1,[r2]

    ldr     r2,=BANKCON3        // 5th:Issue a EMRS2 command
    ldr     r3,=0xffff0000
    ldr     r1,[r2]
    bic     r1,r1,r3
    orr     r1,r1,#(BA_EMRS2<<30)
    str     r1,[r2]

    ldr     r2,=BANKCON1
    ldr     r1,[r2]
    bic     r1,r1,#(0x3<<0)
    orr     r1,r1,#(0x3<<0)
    str     r1,[r2]

    ldr     r2,=BANKCON3        // 6th:Issue a EMRS3 command
    ldr     r3,=0xffff0000
    ldr     r1,[r2]
    bic     r1,r1,r3
    orr     r1,r1,#(BA_EMRS3<<30)
    str     r1,[r2]

    ldr     r2,=BANKCON1
    ldr     r1,[r2]
    bic     r1,r1,#(0x3<<0)
    orr     r1,r1,#(0x3<<0)
    str     r1,[r2]

    ldr     r2,=BANKCON3        // 7th:Issue a EMRS1 command
    ldr     r3,=0xffff0000
    ldr     r4,=((BA_EMRS1<<30)+(RDQS_DIS<<27)+(nDQS_DIS<<26)+(OCD_MODE_EXIT<<23)+(DLL_EN<<16))

    ldr     r1,[r2]
    bic     r1,r1,r3
    orr     r1,r1,r4
    str     r1,[r2]

    ldr     r2,=BANKCON1
    ldr     r1,[r2]
    bic     r1,r1,#(0x3<<0)
    orr     r1,r1,#(0x3<<0)
    str     r1,[r2]

    ldr     r2,=BANKCON3        // 8th  :   Issue a MRS command
    ldr     r3,=0xffff
    ldr     r1,[r2]
    bic     r1,r1,r3
    orr     r1,r1,#((BA_MRS<<14)+(DLL_RESET_HIGH<<8)+(TM<<7)+(CL_MRS<<4))
    str     r1,[r2]

    ldr     r2,=BANKCON1
    ldr     r1,[r2]
    bic     r1,r1,#(0x3<<0)
    orr     r1,r1,#(0x2<<0)
    str     r1,[r2]

    ldr     r2,=BANKCON1        // 9nd  :   Issue a PALL command
    ldr     r1,[r2]
    bic     r1,r1,#(0x3<<0)
    orr     r1,r1,#(0x1<<0)
    str     r1,[r2]

    ldr     r4,=REFRESH         // 10th : wait 2 auto - clk
    ldr     r0,=0x20
    str     r0,[r4]

    ldr     r2,=BANKCON3        // 11th :   Issue a MRS command
    ldr     r3,=0xffff
    ldr     r1,[r2]
    bic     r1,r1,r3
    orr     r1,r1,#((BA_MRS<<14)+(DLL_RESET_LOW<<8)+(TM<<7)+(CL_MRS<<4))
    str     r1,[r2]

    ldr     r2,=BANKCON1
    ldr     r1,[r2]
    bic     r1,r1,#(0x3<<0)
    orr     r1,r1,#(0x2<<0)
    str     r1,[r2]

    mov     r0, #0x100          // Wait 200 clock
loop:
    subs    r0, r0,#1
    bne loop

    ldr     r2,=BANKCON3        // 12th :   Issue a EMRS1 command For OCD Mode Set to default
    ldr     r3,=0xffff0000
    ldr     r4,=((BA_EMRS1<<30)+(RDQS_DIS<<27)+(nDQS_DIS<<26)+(OCD_MODE_DEFAULT<<23)+(DLL_EN<<16))
    ldr     r1,[r2]
    bic     r1,r1,r3
    orr     r1,r1,r4
    str     r1,[r2]

    ldr     r2,=BANKCON1
    ldr     r1,[r2]
    bic     r1,r1,#(0x3<<0)
    orr     r1,r1,#(0x3<<0)
    str     r1,[r2]

    ldr     r2,=BANKCON3
    ldr     r3,=0xffff0000
    ldr     r4,=((BA_EMRS1<<30)+(RDQS_DIS<<27)+(nDQS_DIS<<26)+(OCD_MODE_EXIT<<23)+(DLL_EN<<16))
    ldr     r1,[r2]
    bic     r1,r1,r3
    orr     r1,r1,r4
    str     r1,[r2]

    ldr     r2,=BANKCON1
    ldr     r1,[r2]
    bic     r1,r1,#(0x3<<0)
    orr     r1,r1,#(0x3<<0)
    str     r1,[r2]

    ldr     r4,=REFRESH         // 13fh : refresh  normal
    ldr     r0,=REFCYC
    str     r0,[r4]

    ldr     r2,=BANKCON1        // 14th :   Issue a Normal mode
    ldr     r1,[r2]
    bic     r1,r1,#(0x3<<0)
    str     r1,[r2]
    nop
    nop
    nop
    bx      lr

    ////////////////////////
BootFromNandFlash:
    bl      init_dmc
    ldr     sp,=usr_top
    ldr     r0,=0
    ldr     r1,=0x30000000
    ldr     r2,=(1<<20)
    bl      NandBoot_CopyToRAM
    nop
    nop
    ldr     pc,=0x30000000
    nop
    b  .

    ////////////////////////
    //��������£����������е�����������ڷ��������¼��������NandFlash.
WriteSelfToNandFlash:
    nop
    ldr     sp,=usr_top     //������ʱջ
    bl      init_clock      //��ʼ��CPUʱ��
    ldr     r0,=0           //NandFlash ��ʼҳ��ַ
    ldr     r1,=0x30000000  //����Դ
    ldr     r2,=(1<<20)     //����Դ��С(�ֽ���)
    bl      NandBoot_Prog
    nop
    b   .   //��¼NandFlash��ɺ�,���򵽴�ֹͣ,CPU�����ϵ�,��ɴ�NandFlash����.
    ////////////////////////

    .end
