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
          .global       PVECTORS_53
;======================================================================
;							ePWM6_interrupt
;======================================================================
PVECTORS_53:
;---------------------------------------------------------------------

		SETC    OVM							;0x7FFF and 0x8000 limit in high word
		SETC	SXM						    ;Sign extension is enabled.

;----------------------------------------------------------------------

		MOVW	DP,#INTpage
	   	AND     @PIEACK,#0x0004				;Write 1 to reset INT3.X, 清除中斷旗標
		MOVW  	DP,#ePWM6page
		OR   	@ETCLR6,#0x0001  			;清除epwm6中斷旗標

;=======================================================================
;							server_on?
;=======================================================================

		ZAPA
		MOVW	DP,#GPIOpage2
		TBIT	@GPADAT+1,#6
		B		Scan_OFF,NTC

Scan_ON:
		MOVW	DP,#AApage
		MOV		@Scan_off_100,#0x0000
		INC		@Scan_on_100
		CMP		@Scan_on_100,#200
		B		Servo_ON_or_OFF,LT
		MOVW	DP,#VAR16page
		TSET	@Debounce_OUT,#6
		MOVW	DP,#AApage
		MOV		@Scan_on_100,#200
		B		Servo_ON_or_OFF,UNC

Scan_OFF:
		MOVW	DP,#AApage
		MOV		@Scan_on_100,#0x0000
		INC		@Scan_off_100
		CMP		@Scan_off_100,#20
		B		Servo_ON_or_OFF,LT
		MOVW	DP,#VAR16page
		TCLR	@Debounce_OUT,#6
		MOVW	DP,#AApage
		MOV		@Scan_off_100,#20
		B		Servo_ON_or_OFF,UNC

Servo_ON_or_OFF:
		MOVW	DP,#VAR16page
		TBIT	@Debounce_OUT,#6			;判斷Debounce之後 ON or OFF
	  	B		Servo_OFF,NTC

;======================================================================
;						ADC_interrupt
;======================================================================

		MOVW	DP,#ADCpage
		MOV     @ADCINTFLGCLR,#0x0001		    ;清出ADCINT1中斷旗標
		MOV   	@ADCSOCFRC1,#0xFFFF 	 		;軟體觸發中斷SOC0

		MOVW	DP,#ADCpage

AD_Wait:
		TBIT	@ADCINTFLG,#0		  			;判斷是否轉換完成ADCINT1 (1.72us)
		B       AD_Wait,NTC						;if ADCINTFLG bit0 = 0 , jmp to AD_Wait

;----------------------------------------------------------------------
;                       AD轉換(SOC8)CMD1(kp)
;----------------------------------------------------------------------

;		ZAPA
;		MOVW    DP,#ADCRESULTpage
;		MOV     ACC,@ADCRESULT8<<3          ;讀旋鈕==>ADCA4-->CMD1-->V_BUS_command
;		SUB		AL,#0x0000					;補誤差
;		MOVW	DP,#SPEEDpage
;		MOV		@kp_gain_RPM_M,AL

;----------------------------------------------------------------------
;                       AD轉換(SOC9)CMD2(ki)
;----------------------------------------------------------------------

;		ZAPA
;		MOVW    DP,#ADCRESULTpage
;		MOV	    ACC,@ADCRESULT9<<3			;讀旋鈕==>ADCB4-->CMD2
;		MOVW	DP,#SPEEDpage
;		MOV		@ki_gain_RPM_M,AL

;----------------------------------------------------------------------
;                      AD轉換(SOC15)CMD3(speed_command)
;----------------------------------------------------------------------

		ZAPA
		MOVW    DP,#ADCRESULTpage
		MOV     ACC,@ADCRESULT15<<3         ;讀旋鈕==>ADCB7-->CMD3	0~32767
		SUB		AL,#712
		MOVW    DP,#SPEEDpage
		MPY		ACC,AL,#10000
		LSL		ACC,#1
		MOV		@RPM_M_command,AH

;----------------------------------------------------------------------
;                      SPEED_STEP(500rpm->1000rpm)
;----------------------------------------------------------------------
;		MOVW    DP,#SPEEDpage
;		MOV		@RPM_M_command,#2000
;		MOVW	DP,#GPIOpage2
;		TBIT	@GPADAT,#14
;		B		SPEED_SET,NTC
;		MOVW    DP,#SPEEDpage
;		MOV		@RPM_M_command,#10000
		MOVW	DP,#GPIOpage2
		TBIT	@GPADAT,#15
		B		SPEED_SET,NTC
		MOVW    DP,#SPEEDpage
		MOV		@RPM_M_command,#10000

SPEED_SET:

;=======================================================================
;						PI program_M_RPM
;=======================================================================

		ZAPA
		MOVW	DP,#SPEEDpage
		MOV		AH,@RPM_M_command
		SUB		AH,@RPM_M
		MOV		@error_RPM_M,AH					;V*-V=E(n)

		MOV		T,@error_RPM_M
		MPYA	P,T,@ki_gain_RPM_M				;E(n)*ki_gain
		MOVL	ACC,P
		LSL		ACC,#1
		MOVL	P,ACC

		MOV		AL,@error_RPM_M
		SUB		AL,@error_RPM_M_pre				;E(n)-E(n-1)
		MOV		T,AL
		MPY		ACC,T,@kp_gain_RPM_M			;(E(n)-E(n-1))*kp_gain
		LSL		ACC,#3
		ADDL	ACC,P							;(E(n)-E(n-1))*kp_gain + E(n)*ki_gain

		MOV		PH,@piout_RPM_M					;U(n-1)
		MOV		PL,#0
		ADDL	ACC,P							;U(n-1) + (E(n)-E(n-1))*kp_gain + E(n)*ki_gain)
		MOV		@piout_RPM_M,AH

		MOV		AL,@error_RPM_M
		MOV		@error_RPM_M_pre,AL				;save E(n)

;=======================================================================
;						limit_iq
;=======================================================================

		ZAPA
		MOVW	DP,#SPEEDpage
		MOV		T,@piout_RPM_M
		MOVW	DP,#CCpage
		MPY		ACC,T,@current_limit
		LSL		ACC,#1
		MOV		@I_command,AH
		MOVW	DP,#DQpage
		MOV		@i_q_command,AH

;=======================================================================
;		GPIO and PWM change. give pwm value
;=======================================================================
		EALLOW

		MOV		AR1,#GPAMUX1
		OR		*XAR1,#0x5555				;**** **** **** ****
		MOV		AR1,#GPAMUX1+1
		OR		*XAR1,#0x0055
											;0000 0000 0000 0001
		MOV		AR1,#GPADIR
		OR		*XAR1,#0x03FF				;SET PWM PIN as ePWM Output
		EDIS
;=======================================================================
;		end give pwm value
;=======================================================================
		B		break,UNC
;=========================================================================
;						SERVE_OFF
;=========================================================================

Servo_OFF:

;=======================================================================
;		GPIO and PWM change. give pwm value
;=======================================================================
		MOVW 	DP,#GPIOpage2
		TSET 	@GPASET+1,#11				;GPIO27 High,LED OFF

		EALLOW
		MOV		AR1,#GPAMUX1
		AND		*XAR1,#0x0000
		MOV		AR1,#GPAMUX1+1
		AND		*XAR1,#0x0000				;pwm CHANGE TO gpio

		MOV		AR1,#GPADIR
		AND		*XAR1,#0x00FF				;SET PWM PIN as GPIO input(GPIO1~GPIO6)

		EDIS

;=========================================================================
;		end GPIO and PWM change
;=========================================================================

;=========================================================================
;					SET_INITIAL
;=========================================================================
		MOVW	DP,#SPEEDpage
		MOV		@RPM_M_command,#0
		MOV		@piout_RPM_M,#0
		MOV		@ki_gain_RPM_M,#0x04C0
		MOV		@kp_gain_RPM_M,#0x7FFF
		MOVW	DP,#CCpage
		MOV		@I_command,#0
		MOVW	DP,#DQpage
		MOV		@i_q_command,#0
break:

		IRET							;離開中斷
