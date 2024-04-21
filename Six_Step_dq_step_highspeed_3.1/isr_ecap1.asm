;*******************************************************************************
;*	 Header:
;*	 Version:
;*******************************************************************************
;* =============================================================================
;*
;*	Copyright 2011 BY NTUT-EE Lab-316
;*
;* =============================================================================
;*
;*	 File Description:
;*			          ISR1 (current loop) subroutine
;*
;*	 Author: Hsuan
;*
;*
;*	 Logfile:isr_current.asm
;*
;*	 Date: 2018.10.20
;*
;*	 Revised History:
;*   Initial revision.
;DEBOUNCE_OUT BIT:
;6->switch1(Servo on)->Servo on or off
;5->switch2(Input1)->SPWM or DPWM
;4->Feedforward(Only for step cmd)
;3->switch3(D1)->Feedforward(Only for ramp cmd)
;2->switch4(D2)->Anti-Windup(Speed loop)
;1->switch3(D1)->Speed_down
;********************************************************************

          .include      "register.inc"
          .include      "Macro.inc"
          .include    	"variable.inc"
          .include      "constant.inc"
          .global       PVECTORS_56

;======================================================================
;							ecap1_interrupt
;======================================================================
PVECTORS_56:
;---------------------------------------------------------------------

		SETC    OVM							;0x7FFF and 0x8000 limit in high word
		SETC	SXM						    ;Sign extension is enabled.

;----------------------------------------------------------------------
		MOVW  	DP,#eCAP1page
		MOVL	XAR1,@CAP1
		MOVL	XAR2,@CAP2
		MOVW	DP,#ECAPpage
		MOVL	@ecap_cap_1,XAR1
		MOVL	@ecap_cap_2,XAR2

ENDINT:

		MOVW	DP,#INTpage
	   	AND     @PIEACK,#0x0008				;Write 1 to reset INT4.X, 清除中斷旗標

		MOVW  	DP,#eCAP1page
		OR   	@ECCLR,#0xFFFF  			;Clear all Ecap interrupt flag


		IRET							;離開中斷
