﻿//----------------------------------------------------
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
// Copyright (c) 2014 著作权由深圳鹏瑞软件有限公司所有。著作权人保留一切权利。
//
// 这份授权条款，在使用者符合下列条件的情形下，授予使用者使用及再散播本
// 软件包装原始码及二进位可执行形式的权利，无论此包装是否经改作皆然：
//
// 1. 对于本软件源代码的再散播，必须保留上述的版权宣告、本条件列表，以
//    及下述的免责声明。
// 2. 对于本套件二进位可执行形式的再散播，必须连带以文件以及／或者其他附
//    于散播包装中的媒介方式，重制上述之版权宣告、本条件列表，以及下述
//    的免责声明。

// 免责声明：本软件是本软件版权持有人以及贡献者以现状（"as is"）提供，
// 本软件包装不负任何明示或默示之担保责任，包括但不限于就适售性以及特定目
// 的的适用性为默示性担保。版权持有人及本软件之贡献者，无论任何条件、
// 无论成因或任何责任主义、无论此责任为因合约关系、无过失责任主义或因非违
// 约之侵权（包括过失或其他原因等）而起，对于任何因使用本软件包装所产生的
// 任何直接性、间接性、偶发性、特殊性、惩罚性或任何结果的损害（包括但不限
// 于替代商品或劳务之购用、使用损失、资料损失、利益损失、业务中断等等），
// 不负任何责任，即在该种使用已获事前告知可能会造成此类损害的情形下亦然。
//-----------------------------------------------------------------------------

#include <stdint.h>
#include <cpu_peri.h>
#include <stddef.h>
#include <cpu_peri_gpio.h>


#define INSERTED						(s32)1
#define DM_PIN							&USB_Plug[0]
#define DP_PIN							&USB_Plug[1]
#define POWER_SWITCH_PIN				&USB_Plug[2]

static const Pin USB_Plug[] = {
		{GPIO_B, PIN14, GPIO_MODE_IN, GPIO_OTYPE_PP, GPIO_SPEED_VH, GPIO_PUPD_PD, AF_NUll},
		{GPIO_B, PIN15, GPIO_MODE_IN, GPIO_OTYPE_PP, GPIO_SPEED_VH, GPIO_PUPD_PD, AF_NUll},
		{GPIO_H, PIN3, GPIO_MODE_OUT, GPIO_OTYPE_PP, GPIO_SPEED_VH, GPIO_PUPD_NONE, AF_NUll},
};

//-----------------------------------------------------------------------------
//功能: 本地延时
//参数:
//返回:
//备注:
//-----------------------------------------------------------------------------
static void Wait(u32 Time)
{
	volatile u32 i, j;

	for(j = 0; j < Time; j++)
		for(i = 0; i < 60000; i++);
}
//-----------------------------------------------------------------------------
//功能: USB检测IO口初始化
//参数:
//返回:
//备注:
//-----------------------------------------------------------------------------
static s32 USB_PlugInit(void)
{
	PIO_Configure(USB_Plug, PIO_LISTSIZE(USB_Plug));
	return (0);
}

//-----------------------------------------------------------------------------
//功能: 查询USB是否被插入
//参数:
//返回: 1 -- 插入； 0 -- 未插入
//备注:
//-----------------------------------------------------------------------------
static s32 USB_PlugState(void)
{
	s32 DM, DP;

	PIO_Clear(POWER_SWITCH_PIN); // USB供电
	Wait(100); // 等待USB完全上电
	DM = PIO_Get(DM_PIN);
	DP = PIO_Get(DP_PIN);
	PIO_Set(POWER_SWITCH_PIN); // USB供电
	Wait(2000); // 等待USB完全掉电
	if(DM || DP)
		return (1);
	
	return (0);
}

//-----------------------------------------------------------------------------
//功能: 查询USB是否被插入
//参数:
//返回: 1 -- 插入； 0 -- 未插入
//备注:
//-----------------------------------------------------------------------------
s32 USB_Detector(void)
{
	s32 Res;
	Res = USB_PlugInit();
	if(Res)
		return (0);
		
	if(INSERTED == USB_PlugState())
		return (1);
		
	return (0);	
}