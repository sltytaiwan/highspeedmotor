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
          .global       PVECTORS_49
;======================================================================
;							ePWM2_interrupt
;======================================================================
PVECTORS_49:

		SETC    OVM							;0x7FFF and 0x8000 limit in high word
		SETC	SXM						    ;Sign extension is enabled.

;----------------------------------------------------------------------

		MOVW	DP,#INTpage
	   	AND     @PIEACK,#0x0004				;Write 1 to reset INT3.X, 清除中斷旗標
		MOVW  	DP,#ePWM2page
		OR   	@ETCLR2,#0x0001  			;清除epwm2中斷旗標

;----------------------------測試中斷時間-------------------------------

		MOVW	DP,#GPIOpage2
		TSET    @GPASET+1,#9				;測試中斷時間GPIO08
;		TSET	@GPATOGGLE+1,#9
		RPT		#10
		||	NOP

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
;----------------------------------------------------------------------
;                       AD轉換(SOC2)I_U
;----------------------------------------------------------------------

		ZAPA
		MOVW    DP,#ADCRESULTpage
		MOV     ACC,@ADCRESULT2<<4 	  		;讀U相回授值==>ADCINA1
		SUB		AL,#0x8000					;-32768~32752
		SUB		AL,#0x02B0						;補誤差
		MOVW	DP,#CCpage
		MOV     @IFB_U,AL
		MOVW	DP,#DQpage
		MOV     @DQ_IFB_U,AL

;----------------------------------------------------------------------
;                       AD轉換(SOC3)I_V
;----------------------------------------------------------------------

		ZAPA
		MOVW    DP,#ADCRESULTpage
		MOV     ACC,@ADCRESULT3<<4          ;讀V相回授值==>ADCINB1
		SUB		AL,#0x8000
		SUB		AL,#0x2A0					;補誤差
		MOVW	DP,#CCpage
		MOV     @IFB_V,AL
		MOVW	DP,#DQpage
		MOV     @DQ_IFB_V,AL

;----------------------------------------------------------------------
;                       AD轉換(SOC4)I_W
;----------------------------------------------------------------------

		ZAPA
		MOVW    DP,#ADCRESULTpage
		MOV     ACC,@ADCRESULT4<<4	        ;讀W相回授值==>ADCINA2/COMP1A
		SUB		AL,#0x8000
		SUB		AL,#0x2C0					;補誤差
		MOVW	DP,#CCpage
		MOV     @IFB_W,AL
		MOVW	DP,#DQpage
		MOV     @DQ_IFB_W,AL

;----------------------------------------------------------------------
;----------------------------------------------------------------------
;                       AD轉換(SOC8)CMD1(kp)
;----------------------------------------------------------------------

;		ZAPA
;		MOVW    DP,#ADCRESULTpage
;		MOV     ACC,@ADCRESULT8<<4          ;讀旋鈕==>ADCA4-->CMD1-->V_BUS_command
;		SUB		AL,#912						;補誤差
;		MPY		ACC,AL,#1024
;		LSL		ACC,#1
;		MOVW    DP,#DQpage
;		MOV		@delta_theta_V,AL
;		MOVW	DP,#DQpage
;		MOV		@DQ_kp_gain,AL

;----------------------------------------------------------------------
;                       AD轉換(SOC9)CMD2(ki)
;----------------------------------------------------------------------

;		ZAPA
;		MOVW    DP,#ADCRESULTpage
;		MOV	    ACC,@ADCRESULT9<<3			;讀旋鈕==>ADCB4-->CMD2
;		SUB		AL,#864
;		MOVW	DP,#DQpage
;		MOV		@DQ_ki_gain,AL
;----------------------------------------------------------------------
;                      AD轉換(SOC15)CMD3(delta_theta_V)
;----------------------------------------------------------------------

;		ZAPA
;		MOVW    DP,#ADCRESULTpage
;		MOV     ACC,@ADCRESULT15<<3         ;讀旋鈕==>ADCB7-->CMD3	0~32767
;		SUB		AL,#712
;		MOVW	DP,#CCpage
;		MPY		ACC,AL,#2482
;		LSL		ACC,#1
;		MOV		@I_command,AH
;		MOVW	DP,#DQpage
;		MOV		@i_q_command,AH

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

;=======================================================================
;							server_on
;=======================================================================

		MOVW    DP,#DQpage
		MOV		@i_d_command,#0

;=======================================================================
;						get_hall
;=======================================================================

		ZAPA
		MOVW  	DP,#GPIOpage2
		MOV		AL,@GPBDAT
		AND		AL,#0x0003
		TBIT	@GPBDAT,#10
		B		get_hall,NTC
		OR		AL,#0x0004

get_hall:
		MOVW  	DP,#CCpage
		MOV		@hall_reg,AL

;=======================================================================
;						get_RPM_DIR
;=======================================================================

		ZAPA
		MOVW	DP,#CCpage
		MOV		AL,@hall_reg
		CMP		AL,@hall_reg_pre
		B		GET_DIR,EQ
		CMP		@hall_reg_pre,#1
		B		START_1,EQ
		CMP		@hall_reg_pre,#3
		B		START_3,EQ
		CMP		@hall_reg_pre,#2
		B		START_2,EQ
		CMP		@hall_reg_pre,#6
		B		START_6,EQ
		CMP		@hall_reg_pre,#4
		B		START_4,EQ
		CMP		@hall_reg_pre,#5
		B		START_5,EQ
START_1:
		CMP		@hall_reg,#3
		B		DIR_POS,EQ
		B		DIR_NEG,UNC

START_3:
		CMP		@hall_reg,#2
		B		DIR_POS,EQ
		B		DIR_NEG,UNC

START_2:
		CMP		@hall_reg,#6
		B		DIR_POS,EQ
		B		DIR_NEG,UNC

START_6:
		CMP		@hall_reg,#4
		B		DIR_POS,EQ
		B		DIR_NEG,UNC

START_4:
		CMP		@hall_reg,#5
		B		DIR_POS,EQ
		B		DIR_NEG,UNC

START_5:
		CMP		@hall_reg,#1
		B		DIR_POS,EQ
		B		DIR_NEG,UNC

DIR_POS:
		MOVW	DP,#SPEEDpage
		MOV		@DIR_M,#1
		B		GET_DIR,UNC

DIR_NEG:
		MOVW	DP,#SPEEDpage
		MOV		@DIR_M,#-1

GET_DIR:

;=======================================================================
;						get_RPM_count
;=======================================================================
;-------------------GET INT SIGNAL (20khz)
		ZAPA
		MOVW	DP,#CCpage
		MOV		AL,@hall_reg
		CMP		AL,@hall_reg_pre
		B		RPM_COUNT_END,EQ
		MOVW	DP,#eCAP1page
		MOVL	ACC,@TSCTR
		MOVW	DP,#SPEEDpage
		SUBL	ACC,@TSCTR_pre
		ABS		ACC
		MOVL	@ecap_count,ACC
		MOVW	DP,#eCAP1page
		MOVL	ACC,@TSCTR
		MOVW	DP,#SPEEDpage
		MOVL	@TSCTR_pre,ACC

RPM_COUNT_END:
;-------------------GET ECAP SIGNAL	(60Mhz)
		ZAPA
		MOVW	DP,#eCAP1page
		MOVL	ACC,@CAP2
		SUBL	ACC,@CAP1
		ABS		ACC
		MOVL	XAR1,ACC
;=======================================================================
;						select_cal_RPM_mode
;=======================================================================

		MOVW	DP,#SPEEDpage
		CMP		@RPM_MODE,#0
		B		LOWER_SPEED,EQ
		CMP		@RPM_MODE,#1000
		B		HIGHER_SPEED,EQ

LOWER_SPEED:
		MOVW	DP,#SPEEDpage
		CMP		@RPM_M,#2500
		B		CAL_HIGHER_SPEED,GEQ
		B		CAL_LOWER_SPEED,UNC

HIGHER_SPEED:
		MOVW	DP,#SPEEDpage
		CMP		@RPM_M,#2000
		B		CAL_LOWER_SPEED,LT
		B		CAL_HIGHER_SPEED,UNC

;=======================================================================
;						CAL_RPM (lower speed)
;=======================================================================

CAL_LOWER_SPEED:
		ZAPA
		MOVW	DP,#SPEEDpage
		MOV 	@RPM_MODE,#0
;---------------------------------------
		MOVB	ACC,#0
		MOV		PH,#0x11E1
		MOV		PL,#0xA300
		RPT		#31
	  ||SUBCUL	ACC,@ecap_count
	  	MOVL	ACC,P

	  	CMP		@DIR_M,#1
	  	B		RPM_NEG,NEQ
	  	MOV		@RPM_M,AL
	  	B		RPM_GET,UNC

;=======================================================================
;						CAL_RPM_count_ecap (higher speed)
;=======================================================================

CAL_HIGHER_SPEED:

		MOVW	DP,#SPEEDpage
		MOV 	@RPM_MODE,#1000
;--------------------------------------

		MOVB	ACC,#0
		MOV		PH,#0x35A4
		MOV		PL,#0xE900
		RPT		#31
	  ||SUBCUL	ACC,XAR1
	  	MOVL	ACC,P

	  	CMP		@DIR_M,#1
	  	B		RPM_NEG,NEQ
	  	MOV		@RPM_M,AL
	  	B		RPM_GET,UNC
;-----------------finish calculate rpm
RPM_NEG:
		NEG		ACC
		MOV		@RPM_M,AL

RPM_GET:

;=======================================================================
;						get_control_mode(手動)
;		001(六步)->011(dq)->111(dqwm_close)->101(dpwm_open)
;=======================================================================

		ZAPA
		MOVW	DP,#CCpage
		MOV		AL,@hall_reg
		CMP		AL,@hall_reg_pre
		B		GET_MODE,EQ
		CMP		@hall_reg_pre,#1
		B		START_1_MODE,EQ
		B		GET_MODE,UNC

START_1_MODE:
		MOVW	DP,#GPIOpage2
		TBIT	@GPADAT,#15
		B		DPWM_CLOSE_MODE,TC
		B		DQ_MODE,UNC

DPWM_CLOSE_MODE:
		MOVW	DP,#GPIOpage2
		TBIT	@GPADAT,#14
		B		DPWM_OPEN_MODE,NTC
		MOVW	DP,#CCpage
		MOV		@MODE,#100		;200
		B		GET_MODE,UNC

DPWM_OPEN_MODE:
		MOVW	DP,#CCpage
		MOV		@MODE,#300
		B		GET_MODE,UNC

DQ_MODE:
		MOVW	DP,#GPIOpage2
		TBIT	@GPADAT,#14
		B		CC,NTC
		MOVW	DP,#CCpage
		MOV		@MODE,#100
		B		GET_MODE,UNC

CC:
		MOVW	DP,#CCpage
		MOV		@MODE,#0

GET_MODE:

;=======================================================================
;						get_control_mode(自動)
;								six step	<-	<100rpm
;					>400rpm->		dq		<-
;=======================================================================

;		ZAPA
;		MOVW	DP,#CCpage
;		MOV		AL,@hall_reg
;		CMP		AL,@hall_reg_pre
;		B		GET_MODE,EQ
;		CMP		@hall_reg_pre,#2
;		B		START_2_MODE,EQ
;
;START_2_MODE:
;		MOVW	DP,#CCpage
;		CMP		@MODE,#0
;		B		CC,EQ
;		CMP		@MODE,#100
;		B		DQ,EQ
;
;CC:
;		MOVW	DP,#CCpage
;		MOV		@MODE,#100
;		MOVW	DP,#SPEEDpage
;		CMP		@RPM_M,#1000
;		B		GET_MODE,GEQ
;		MOVW	DP,#CCpage
;		MOV		@MODE,#0
;		B		GET_MODE,UNC
;
;DQ:
;		MOVW	DP,#CCpage
;		MOV		@MODE,#100
;		MOVW	DP,#SPEEDpage
;		CMP		@RPM_M,#700
;		B		GET_MODE,GEQ
;		MOVW	DP,#CCpage
;		MOV		@MODE,#0
;		MOVW	DP,#SPEEDpage
;		CMP		@RPM_M,#500
;		B		GET_MODE,LT
;		MOVW	DP,#CCpage
;		MOV		@MODE,#100
;		B		GET_MODE,UNC
;
;GET_MODE:

;=======================================================================
;						TURN_RPM_2_ENCODER
;=======================================================================

		ZAPA
		MOVW	DP,#CCpage
		MOV		AL,@hall_reg
		CMP		AL,@hall_reg_pre
		B		COUNT_ENCODER,EQ

		MOVW	DP,#SPEEDpage
		MOVB	ACC,#0
		MOV		PH,#0x000F
		MOV		PL,#0xA000
		RPT		#31
	  ||SUBCUL	ACC,@ecap_count
	  	MOV		T,PL
	  	MOV		@ENCODER_STEP+1,T
	  	MOVL	P,ACC
	  	MOVB	ACC,#0
	  	RPT		#31
	  ||SUBCUL	ACC,@ecap_count
	  	MOV		T,PL
	  	MOV		@ENCODER_STEP,T


		MOVW	DP,#SPEEDpage
		MOV		@ENCODER_COUNT+1,#170		;;encoder~2048@30度 = 170.667
		MOV		@ENCODER_COUNT,#43713
		MOVW	DP,#CCpage
		CMP		@hall_reg,#1
		B		STORE_HALL,EQ			;30度

		MOVW	DP,#SPEEDpage
		MOV		@ENCODER_COUNT+1,#512		;encoder~4096@30度 = 682.667
		MOV		@ENCODER_COUNT,#0			;encoder~2048@60度 = 341.333
		MOVW	DP,#CCpage
		CMP		@hall_reg,#3
		B		STORE_HALL,EQ			;90度

		MOVW	DP,#SPEEDpage
		MOV		@ENCODER_COUNT+1,#853		;encoder~4096@120度 =
		MOV		@ENCODER_COUNT,#21845		;encoder~2048@120度 = 583.333
		MOVW	DP,#CCpage
		CMP		@hall_reg,#2
		B		STORE_HALL,EQ			;150度

		MOVW	DP,#SPEEDpage
		MOV		@ENCODER_COUNT+1,#1194		;encoder~4096@180度 =
		MOV		@ENCODER_COUNT,#43713		;encoder~2048@180度 = 1024
		MOVW	DP,#CCpage
		CMP		@hall_reg,#6
		B		STORE_HALL,EQ			;210度

		MOVW	DP,#SPEEDpage
		MOV		@ENCODER_COUNT+1,#1536			;encoder~4096@240度 =
		MOV		@ENCODER_COUNT,#0			;encoder~2048@240度 =
		MOVW	DP,#CCpage
		CMP		@hall_reg,#4
		B		STORE_HALL,EQ			;270度

		MOVW	DP,#SPEEDpage
		MOV		@ENCODER_COUNT+1,#1877		;encoder~4096@300度 =
		MOV		@ENCODER_COUNT,#21845			;encoder~2048@300度 = 1706.666
		MOVW	DP,#CCpage
		CMP		@hall_reg,#5
		B		STORE_HALL,EQ			;330度

COUNT_ENCODER:
		MOVW	DP,#SPEEDpage
		MOVL	ACC,@ENCODER_COUNT
		ADDL	ACC,@ENCODER_STEP
		AND		AH,#0X07FF

STORE_COUNT:
		MOVW	DP,#SPEEDpage
		MOVL	@ENCODER_COUNT,ACC

STORE_HALL:
		MOVW	DP,#CCpage
		MOV		AL,@hall_reg
		MOV		@hall_reg_pre,AL

;=======================================================================
;					mapping_sin_n_cos_counter
;=======================================================================

		ZAPA
		MOVW	DP,#SPEEDpage
		MOV		AL,@ENCODER_COUNT+1
		ADD		AL,#1536

		MOVW	DP,#DQpage
		MOV		@sin_counter_0,AL
		ADD		AL,#512
		MOV		@cos_counter_0,AL
		ADD		AL,#170
		MOV		@sin_counter_120_pos,AL
		ADD		AL,#512
		MOV		@cos_counter_120_pos,AL
		ADD		AL,#170
		MOV		@sin_counter_120_neg,AL
		ADD		AL,#512
		MOV		@cos_counter_120_neg,AL

;=======================================================================
;						get_sin_n_cos
;=======================================================================

		ZAPA
		MOVW	DP,#DQpage
		MOV    	ACC,@sin_counter_0   			;Sintable表的位置
		AND		AH,#0x0000
		AND		AL,#0x07FF						;mask
		OR    	AL,#0x9000						;超過的遮掉->0x9000~9FFF
		MOVL   	XAR2,ACC
		MOV	    ACC,*XAR2           			;取出Sintable位置的值
		MOV		@sin_value_0,AL

		ZAPA
		MOVW	DP,#DQpage
		MOV    	ACC,@cos_counter_0   			;Sintable表的位置
		AND		AH,#0x0000
		AND		AL,#0x07FF						;mask
		OR    	AL,#0x9000						;超過的遮掉->0x9000~9FFF
		MOVL   	XAR2,ACC
		MOV	    ACC,*XAR2           			;取出Sintable位置的值
		MOV		@cos_value_0,AL

		ZAPA
		MOVW	DP,#DQpage
		MOV    	ACC,@sin_counter_120_pos   		;Sintable表的位置
		AND		AH,#0x0000
		AND		AL,#0x07FF						;mask
		OR    	AL,#0x9000						;超過的遮掉->0x9000~9FFF
		MOVL   	XAR2,ACC
		MOV	    ACC,*XAR2           			;取出Sintable位置的值
		MOV		@sin_value_120_pos,AL

		ZAPA
		MOVW	DP,#DQpage
		MOV    	ACC,@cos_counter_120_pos   		;Sintable表的位置
		AND		AH,#0x0000
		AND		AL,#0x07FF						;mask
		OR    	AL,#0x9000						;超過的遮掉->0x9000~9FFF
		MOVL   	XAR2,ACC
		MOV	    ACC,*XAR2           			;取出Sintable位置的值
		MOV		@cos_value_120_pos,AL

		ZAPA
		MOVW	DP,#DQpage
		MOV    	ACC,@sin_counter_120_neg   		;Sintable表的位置
		AND		AH,#0x0000
		AND		AL,#0x07FF						;mask
		OR    	AL,#0x9000						;超過的遮掉->0x9000~9FFF
		MOVL   	XAR2,ACC
		MOV	    ACC,*XAR2           			;取出Sintable位置的值
		MOV		@sin_value_120_neg,AL

		ZAPA
		MOVW	DP,#DQpage
		MOV    	ACC,@cos_counter_120_neg   		;Sintable表的位置
		AND		AH,#0x0000
		AND		AL,#0x07FF						;mask
		OR    	AL,#0x9000						;超過的遮掉->0x9000~9FFF
		MOVL   	XAR2,ACC
		MOV	    ACC,*XAR2           			;取出Sintable位置的值
		MOV		@cos_value_120_neg,AL

		ZAPA
		MOVW	DP,#DQpage
		MOV    	ACC,@cos_counter_6time   		;Sintable表的位置
		AND		AH,#0x0000
		AND		AL,#0x07FF						;mask
		OR    	AL,#0x9000						;超過的遮掉->0x9000~9FFF
		MOVL   	XAR2,ACC
		MOV	    ACC,*XAR2           			;取出Sintable位置的值

;=======================================================================
;						ABC_2_DQ
;=======================================================================
;-----------------D---------------------

		MOVW	DP,#DQpage
		MOV		T,@sin_value_0
		MPY		ACC,T,@DQ_IFB_U
		LSL		ACC,#1
		MOV		@SUM_A,AH					;SIN()*ia

		MOV		T,@sin_value_120_neg
		MPY		ACC,T,@DQ_IFB_V
		LSL		ACC,#1
		MOV		@SUM_B,AH					;SIN(-120)*ib

		MOV		T,@sin_value_120_pos
		MPY		ACC,T,@DQ_IFB_W
		LSL		ACC,#1						;SIN(+120)*ic

		MOV		PH,@SUM_A
		ADDL	ACC,P
		MOV		PH,@SUM_B
		ADDL	ACC,P						;SIN()*ia + SIN(-120)*ib + SIN(+120)*ic

		MPY		ACC,AH,#0x5554				;*2/3
		LSL		ACC,#1
		MOV		@i_d,AH

;-----------------Q---------------------

		ZAPA
		MOVW	DP,#DQpage
		MOV		T,@cos_value_0
		MPY		ACC,T,@DQ_IFB_U
		LSL		ACC,#1
		MOV		@SUM_A,AH					;COS()*ia

		MOV		T,@cos_value_120_neg
		MPY		ACC,T,@DQ_IFB_V
		LSL		ACC,#1
		MOV		@SUM_B,AH					;COS(-120)*ib

		MOV		T,@cos_value_120_pos
		MPY		ACC,T,@DQ_IFB_W
		LSL		ACC,#1						;COS(+120)*ic

		MOV		PH,@SUM_A
		ADDL	ACC,P
		MOV		PH,@SUM_B
		ADDL	ACC,P					;COS()*ia + COS(-120)*ib + COS(+120)*ic

		MPY		ACC,AH,#0x5554				;*2/3
		LSL		ACC,#1
		MOV		@i_q,AH

;=======================================================================
;					switch_dq_or_six_step
;=======================================================================

		MOVW	DP,#CCpage
		CMP		@MODE,#100
		B		WC_MODE,EQ
		CMP		@MODE,#200
		B		WC_MODE,EQ
		CMP		@MODE,#300
		B		WOC_MODE,EQ

;=======================================================================
;					  six_step_part
;=======================================================================

six_step_part:

;=======================================================================
;						get_six_step
;=======================================================================

		ZAPA
		MOVW	DP,#CCpage

		MOV		@sin_counter_U_STEP,#170
		CMP		@hall_reg,#1
		B		Six_Step_get,EQ			;0~60度取30度

		MOV		@sin_counter_U_STEP,#512
		CMP		@hall_reg,#3
		B		Six_Step_get,EQ			;60~120度取90度

		MOV		@sin_counter_U_STEP,#853
		CMP		@hall_reg,#2
		B		Six_Step_get,EQ			;120~180度取150度

		MOV		@sin_counter_U_STEP,#1194
		CMP		@hall_reg,#6
		B		Six_Step_get,EQ			;180~240度取210度

		MOV		@sin_counter_U_STEP,#1536
		CMP		@hall_reg,#4
		B		Six_Step_get,EQ			;210~270度取240度

		MOV		@sin_counter_U_STEP,#1877
		CMP		@hall_reg,#5
		B		Six_Step_get,EQ			;270~330度取300度

Six_Step_get:
		MOVW	DP,#CCpage
		MOV		AL,@sin_counter_U_STEP
		ADD		AL,#683
		MOV		@sin_counter_W_STEP,AL
		ADD		AL,#683
		MOV		@sin_counter_V_STEP,AL

;=======================================================================
;						get_sin_n_cos
;=======================================================================

		ZAPA
		MOVW	DP,#CCpage
		MOV    	ACC,@sin_counter_U_STEP   			;Sintable表的位置
		AND		AH,#0x0000
		AND		AL,#0x07FF						;mask
		OR    	AL,#0x9000						;超過的遮掉->0x9000~9FFF
		MOVL   	XAR2,ACC
		MOV	    ACC,*XAR2           			;取出Sintable位置的值
		MOV		@sin_value_U_STEP,AL

		ZAPA
		MOVW	DP,#CCpage
		MOV    	ACC,@sin_counter_V_STEP  			;Sintable表的位置
		AND		AH,#0x0000
		AND		AL,#0x07FF						;mask
		OR    	AL,#0x9000						;超過的遮掉->0x9000~9FFF
		MOVL   	XAR2,ACC
		MOV	    ACC,*XAR2           			;取出Sintable位置的值
		MOV		@sin_value_V_STEP,AL

		ZAPA
		MOVW	DP,#CCpage
		MOV    	ACC,@sin_counter_W_STEP   			;Sintable表的位置
		AND		AH,#0x0000
		AND		AL,#0x07FF						;mask
		OR    	AL,#0x9000						;超過的遮掉->0x9000~9FFF
		MOVL   	XAR2,ACC
		MOV	    ACC,*XAR2           			;取出Sintable位置的值
		MOV		@sin_value_W_STEP,AL

;=======================================================================
;						SET_COMMAND
;=======================================================================

		ZAPA
		MOVW	DP,#CCpage
		MOV		T,@sin_value_U_STEP
		MPY		ACC,T,@I_command
		LSL		ACC,#1
		MOV		@I_U_command,AH

		ZAPA
		MOVW	DP,#CCpage
		MOV		T,@sin_value_V_STEP
		MPY		ACC,T,@I_command
		LSL		ACC,#1
		MOV		@I_V_command,AH

		ZAPA
		MOVW	DP,#CCpage
		MOV		T,@sin_value_W_STEP
		MPY		ACC,T,@I_command
		LSL		ACC,#1
		MOV		@I_W_command,AH

;=======================================================================
;						EPWM&PI program_U(epwm1)
;=======================================================================

		ZAPA
		MOVW	DP,#CCpage
		MOV		AH,@I_U_command
		SUB		AH,@IFB_U
		MOV		@error_U,AH					;V*-V=E(n)

		MOV		T,@error_U
		MPYA	P,T,@ki_gain				;E(n)*ki_gain
		MOVL	ACC,P
		LSL		ACC,#1
		MOVL	@XAR2,ACC

		MOV		AL,@error_U
		SUB		AL,@error_U_pre				;E(n)-E(n-1)
		MOV		T,AL
		MPY		ACC,T,@kp_gain				;(E(n)-E(n-1))*kp_gain
		LSL		ACC,#1
		ADDL	ACC,@XAR2						;(E(n)-E(n-1))*kp_gain + E(n)*ki_gain

		MOV		PH,@piout_U					;U(n-1)
		MOV		PL,#0
		ADDL	ACC,P						;U(n-1) + (E(n)-E(n-1))*kp_gain + E(n)*ki_gain)
		MOV		@piout_U,AH

		MOV		AL,@error_U
		MOV		@error_U_pre,AL				;save E(n)

		MOV		AL,AH
		ADD     AL,#DA_qua              ;將Q15轉回原值 +32767
        LSR     AL,#1              		;先加8000再右移1bit
		MPY		ACC,AL,#PWM_period
		LSL		ACC,#1

		MOVW	DP,#ePWM1page
		MOV		@CMPA1,AH

;=======================================================================
;						SPWM&PI program_V(epwm2)
;=======================================================================

		ZAPA
		MOVW	DP,#CCpage
		MOV		AH,@I_V_command
		SUB		AH,@IFB_V
		MOV		@error_V,AH					;V*-V=E(n)

		MOV		T,@error_V
		MPYA	P,T,@ki_gain				;E(n)*ki_gain
		MOVL	ACC,P
		LSL		ACC,#1
		MOVL	@XAR2,ACC

		MOV		AL,@error_V
		SUB		AL,@error_V_pre				;E(n)-E(n-1)
		MOV		T,AL
		MPY		ACC,T,@kp_gain				;(E(n)-E(n-1))*kp_gain
		LSL		ACC,#1
		ADDL	ACC,@XAR2					;(E(n)-E(n-1))*kp_gain + E(n)*ki_gain

		MOV		PH,@piout_V					;U(n-1)
		MOV		PL,#0
		ADDL	ACC,P						;U(n-1) + (E(n)-E(n-1))*kp_gain + E(n)*ki_gain)
		MOV		@piout_V,AH

		MOV		AL,@error_V
		MOV		@error_V_pre,AL				;save E(n)

		MOV		AL,AH
		ADD     AL,#DA_qua              ;將Q15轉回原值 +32767
        LSR     AL,#1              		;先加8000再右移1bit
		MPY		ACC,AL,#PWM_period
		LSL		ACC,#1

		MOVW	DP,#ePWM2page
		MOV		@CMPA2,AH

;=======================================================================
;						SPWM&PI program_W(epwm3)
;=======================================================================

		ZAPA
		MOVW	DP,#CCpage
		MOV		AH,@I_W_command
		SUB		AH,@IFB_W
		MOV		@error_W,AH					;V*-V=E(n)

		MOV		T,@error_W
		MPYA	P,T,@ki_gain				;E(n)*ki_gain
		MOVL	ACC,P
		LSL		ACC,#1
		MOVL	@XAR2,ACC

		MOV		AL,@error_W
		SUB		AL,@error_W_pre				;E(n)-E(n-1)
		MOV		T,AL
		MPY		ACC,T,@kp_gain				;(E(n)-E(n-1))*kp_gain
		LSL		ACC,#1					;#1
		ADDL	ACC,@XAR2						;(E(n)-E(n-1))*kp_gain + E(n)*ki_gain

		MOV		PH,@piout_W					;U(n-1)
		MOV		PL,#0
		ADDL	ACC,P						;U(n-1) + (E(n)-E(n-1))*kp_gain + E(n)*ki_gain)
		MOV		@piout_W,AH

		MOV		AL,@error_W
		MOV		@error_W_pre,AL				;save E(n)

		MOV		AL,AH
		ADD     AL,#DA_qua              ;將Q15轉回原值 +32767
        LSR     AL,#1              		;先加8000再右移1bit
		MPY		ACC,AL,#PWM_period
		LSL		ACC,#1

 		MOVW	DP,#ePWM3page
		MOV		@CMPA3,AH

;=======================================================================
;						end_six_step_part
;=======================================================================

		B		end,UNC

;=======================================================================
;					  	DQ_part
;=======================================================================

WC_MODE:

;=======================================================================
;						PI program_d
;=======================================================================

		ZAPA
		MOVW	DP,#DQpage
		MOV		AH,@i_d_command
		SUB		AH,@i_d
		MOV		@error_d,AH					;V*-V=E(n)

		MOV		T,@error_d
		MPYA	P,T,@DQ_ki_gain				;E(n)*ki_gain
		MOVL	ACC,P
		LSL		ACC,#1
		MOVL	P,ACC

		MOV		AL,@error_d
		SUB		AL,@error_d_pre				;E(n)-E(n-1)
		MOV		T,AL
		MPY		ACC,T,@DQ_kp_gain				;(E(n)-E(n-1))*kp_gain
		LSL		ACC,#2
		ADDL	ACC,P						;(E(n)-E(n-1))*kp_gain + E(n)*ki_gain

		MOV		PH,@piout_d_pre				;U(n-1)
		MOV		PL,#0
		ADDL	ACC,P						;U(n-1) + (E(n)-E(n-1))*kp_gain + E(n)*ki_gain)
		MOV		@piout_d_pre,AH
		MOV		@piout_d,AH

		MOV		AL,@error_d
		MOV		@error_d_pre,AL				;save E(n)

;=======================================================================
;						PI program_q
;=======================================================================

		ZAPA
		MOVW	DP,#DQpage
		MOV		AH,@i_q_command
		SUB		AH,@i_q
		MOV		@error_q,AH					;V*-V=E(n)

		MOV		T,@error_q
		MPYA	P,T,@DQ_ki_gain				;E(n)*ki_gain
		MOVL	ACC,P
		LSL		ACC,#1
		MOVL	P,ACC

		MOV		AL,@error_q
		SUB		AL,@error_q_pre				;E(n)-E(n-1)
		MOV		T,AL
		MPY		ACC,T,@DQ_kp_gain			;(E(n)-E(n-1))*kp_gain
		LSL		ACC,#2
		ADDL	ACC,P						;(E(n)-E(n-1))*kp_gain + E(n)*ki_gain

		MOV		PH,@piout_q_pre				;U(n-1)
		MOV		PL,#0
		ADDL	ACC,P						;U(n-1) + (E(n)-E(n-1))*kp_gain + E(n)*ki_gain)
		MOV		@piout_q_pre,AH
		MOV		@piout_q,AH

		MOV		AL,@error_q
		MOV		@error_q_pre,AL				;save E(n)


;=======================================================================
;						decoupling_q
;=======================================================================

		ZAPA
		MOVW	DP,#SPEEDpage				;0.6832*0.9=0.61488(900rpm)  0.0007591 Vpeak/rpm
		MPY		ACC,@RPM_M,#0x4F98			;
		LSL		ACC,#1
		MOVW	DP,#DQpage
		MOV		PH,AH
		MOV		AH,@piout_q
		ADDL	ACC,P
		MOV		@piout_q,AH

;=======================================================================
;						decoupling_d
;=======================================================================

;=======================================================================
;						DQ_2_ABC
;=======================================================================
;-----------------A---------------------

		ZAPA
		MOVW	DP,#DQpage
		MOV		T,@sin_value_0
		MPY		ACC,T,@piout_d
		LSL		ACC,#1
		MOVL	P,ACC						;SIN()*id

		MOV		T,@cos_value_0
		MPY		ACC,T,@piout_q
		LSL		ACC,#1
		ADDL	ACC,P						;COS()*iq
		MOV		@dq_piout_U,AH

;-----------------B---------------------

		ZAPA
		MOVW	DP,#DQpage
		MOV		T,@sin_value_120_neg
		MPY		ACC,T,@piout_d
		LSL		ACC,#1
		MOVL	P,ACC						;SIN(-120)*id

		MOV		T,@cos_value_120_neg
		MPY		ACC,T,@piout_q
		LSL		ACC,#1
		ADDL	ACC,P						;COS(-120)*iq
		MOV		@dq_piout_V,AH

;-----------------C---------------------

		ZAPA
		MOVW	DP,#DQpage
		MOV		T,@sin_value_120_pos
		MPY		ACC,T,@piout_d
		LSL		ACC,#1
		MOVL	P,ACC						;SIN(+120)*id

		MOV		T,@cos_value_120_pos
		MPY		ACC,T,@piout_q
		LSL		ACC,#1
		ADDL	ACC,P						;COS(+120)*iq
		MOV		@dq_piout_W,AH

;=======================================================================
;							SPWM
;=======================================================================

		ZAPA
		MOVW	DP,#DQpage
		MOV		AL,@dq_piout_U
		ADD     AL,#DA_qua              ;將Q15轉回原值 +32767
		LSR     AL,#1              		;先加8000再右移1bit
		MPY		ACC,AL,#PWM_period
		LSL		ACC,#1
		MOV		@spwm_U,AH

		MOVW	DP,#DQpage
		MOV		AL,@dq_piout_V
		ADD     AL,#DA_qua              ;將Q15轉回原值 +32767
		LSR     AL,#1              		;先加8000再右移1bit
		MPY		ACC,AL,#PWM_period
		LSL		ACC,#1
		MOV		@spwm_V,AH

		MOVW	DP,#DQpage
		MOV		AL,@dq_piout_W
		ADD     AL,#DA_qua              ;將Q15轉回原值 +32767
		LSR     AL,#1              		;先加8000再右移1bit
		MPY		ACC,AL,#PWM_period
		LSL		ACC,#1
		MOV		@spwm_W,AH

;=======================================================================
;						DPWM
;=======================================================================

		ZAPA
		MOVW	DP,#DQpage
		MOV		AL,@spwm_U
		MAX		AL,@spwm_V
		MAX		AL,@spwm_W
		MOV		@spwm_max,AL				;find max

		MOV		AL,@spwm_U
		MIN		AL,@spwm_V
		MIN		AL,@spwm_W
		MOV		@spwm_min,AL				;find min

		MOV		AH,@spwm_max
		ADD		ACC,@spwm_min<<#16
		MOV		@spwm_eff,AH

		CMP		@spwm_eff,#PWM_period
		B		DPWM_G,GEQ
		B		DPWM_S,UNC

DPWM_G:
		MOV		AH,#PWM_period
		SUB		ACC,@spwm_max<<#16
		MOV		@spwm_off,AH
		B		DPWM_F,UNC

DPWM_S:
		MOV		AH,@spwm_min
		NEG		AH
		MOV		@spwm_off,AH
		B		DPWM_F,UNC

DPWM_F:
		MOVW	DP,#DQpage
		MOV		AH,@spwm_off
		ADD		ACC,@spwm_U<<#16
		MOV		@dpwm_U,AH

		MOVW	DP,#DQpage
		MOV		AH,@spwm_off
		ADD		ACC,@spwm_V<<#16
		MOV		@dpwm_V,AH

		MOVW	DP,#DQpage
		MOV		AH,@spwm_off
		ADD		ACC,@spwm_W<<#16
		MOV		@dpwm_W,AH

;=======================================================================
;					CHOOSE_OUTPUT_DPWM_OR_SPWM
;=======================================================================

		MOVW	DP,#CCpage
		CMP		@MODE,#200
		B		DPWM,EQ

;=======================================================================
;							OUTPUT_SPWM
;=======================================================================

SPWM:
		MOVW	DP,#DQpage
		MOV		AH,@spwm_U
		MOVW	DP,#ePWM1page
		MOV		@CMPA1,AH

		MOVW	DP,#DQpage
		MOV		AH,@spwm_V
		MOVW	DP,#ePWM2page
		MOV		@CMPA2,AH

		MOVW	DP,#DQpage
		MOV		AH,@spwm_W
		MOVW	DP,#ePWM3page
		MOV		@CMPA3,AH

		B		Cal_theta_V,UNC

;=======================================================================
;							OUTPUT_DPWM
;=======================================================================

DPWM:
		MOVW	DP,#DQpage
		MOV		AH,@dpwm_U
		MOVW	DP,#ePWM1page
		MOV		@CMPA1,AH

		MOVW	DP,#DQpage
		MOV		AH,@dpwm_V
		MOVW	DP,#ePWM2page
		MOV		@CMPA2,AH

		MOVW	DP,#DQpage
		MOV		AH,@dpwm_W
		MOVW	DP,#ePWM3page
		MOV		@CMPA3,AH

;=======================================================================
;						cal_theta_V
;		theta_V = arctan ( piout_d*512 / piout_q_2 )
;=======================================================================

Cal_theta_V:

		MOVW	DP,#DQpage
		; Calculate signed: Quot16 = Num16/Den16, Rem16 = Num16%Den16
		ZAPA
		CLRC 	TC 								; Clear TC flag, used as sign flag
		MOV 	ACC,@piout_q_2 << #16 			; AH = Den16, AL = 0
		ABSTC 	ACC 							; Take abs value, TC = sign ^ TC
		MOV 	@V_qs,AH 						; Temp save Den16 in T register
		MPY		ACC,@piout_d,#512
		NEG		ACC
		ABSTC 	ACC 							; Take abs value, TC = sign ^ TC
		RPT 	#15 							; Repeat operation 16 times
		||SUBCUL ACC,@V_qs 						; Conditional subtract with Den16
		MOVL 	ACC,P 							; P = Quot16
		NEGTC 	ACC 							; Negate if TC = 1
		ADD		AL,#512
		MOV 	@tan_theta_V,AL 				; Store quotient in Quot1

*----------------- get_theta_V---------------------

		ZAPA
		MOVW	DP,#DQpage
		MOV    	ACC,@tan_theta_V   				;Arctantable表的位置
		AND		AH,#0x0000
		AND		AL,#0x03FF						;mask
		OR    	AL,#0x9800						;超過的遮掉->0x9000~9FFF
		MOVL   	XAR2,ACC
		MOV	    ACC,*XAR2           			;取出Arctantable位置的值
		MOV		@theta_value,AL

		MPY		ACC,@theta_value,#1024
		LSL		ACC,#1
		MOV		@theta_V,AH

;=======================================================================
;						MOVING_AVERAGE
;=======================================================================

		ZAPA
		MOVW	DP,#MATHpage
		MOV		ACC,@yout_7
		MOV		@yout_8,ACC
		MOV		ACC,@yout_6
		MOV		@yout_7,ACC
		MOV		ACC,@yout_5
		MOV		@yout_6,ACC
		MOV		ACC,@yout_4
		MOV		@yout_5,ACC
		MOV		ACC,@yout_3
		MOV		@yout_4,ACC
		MOV		ACC,@yout_2
		MOV		@yout_3,ACC
		MOV		ACC,@yout_1
		MOV		@yout_2,ACC
		MOVW	DP,#DQpage
		MOV		ACC,@theta_V
		MOVW	DP,#MATHpage
		MOVL	@yout_1,ACC

		ZAPA
		MOVW	DP,#MATHpage
		ADD		ACC,@yout_1
		ADD		ACC,@yout_2
		ADD		ACC,@yout_3
		ADD		ACC,@yout_4
		ADD		ACC,@yout_5
		ADD		ACC,@yout_6
		ADD		ACC,@yout_7
		ADD		ACC,@yout_8
		SFR		ACC,#3
		MOVW	DP,#DQpage
		MOV		@MA_theta_V,AL
		B		end,UNC

;=======================================================================
;					  WOC_part
;=======================================================================

WOC_MODE:

;=======================================================================
;		GPIO and PWM change. give pwm value
;=======================================================================
end:
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

		B		SPI_print,UNC

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
		MOVW	DP,#CCpage
		MOV		@kp_gain,#0x7FFF			;17000
		MOV		@ki_gain,#0x41C0			;7000
		MOV		@piout_U,#0
		MOV		@piout_V,#0
		MOV		@piout_W,#0
		MOV		@I_U_command,#0
		MOV		@I_V_command,#0
		MOV		@I_W_command,#0
		MOV		@error_U_pre,#0
		MOV		@error_V_pre,#0
		MOV		@error_W_pre,#0
		MOV		@IFB_U,#0
		MOV		@IFB_V,#0
		MOV		@IFB_W,#0
		MOV		@current_limit,#9928		;2482=10A  ; 40A
		MOV		@hall_reg_pre,#0
		MOV		@MODE,#0

		MOVW	DP,#DQpage
		MOV		@DQ_kp_gain,#0x7FFF
		MOV		@DQ_ki_gain,#0x3E70			;4D00
		MOV		@dq_piout_U,#0
		MOV		@dq_piout_V,#0
		MOV		@dq_piout_W,#0
		MOV		@piout_d,#0
		MOV		@piout_q,#0
		MOV		@i_d_command,#0
		MOV		@i_q_command,#0
		MOV		@i_d,#0
		MOV		@i_q,#0

		MOVW	DP,#SPEEDpage
		MOV		@ENCODER_COUNT,#0
		MOV		@ENCODER_COUNT+1,#0
		MOV		@ENCODER_STEP,#0
		MOV		@ENCODER_STEP+1,#0
		MOV		@RPM_M,#0
		MOV		@CYCLE_SIX_STEP,#0x7FFF
		MOV		@DIR_M,#1
		MOV		@RPM_M,#0

		MOVW	DP,#eCAP1page

		MOVW	DP,#MATHpage
		MOV		@yout_1,#0
		MOV		@yout_2,#0
		MOV		@yout_3,#0
		MOV		@yout_4,#0
		MOV		@yout_5,#0
		MOV		@yout_6,#0
		MOV		@yout_7,#0
		MOV		@yout_8,#0
		MOV		@yout_9,#0
		MOV		@yout_10,#0
		MOV		@MA_theta_V,#0

;======================================================================
;							SPI_print
;======================================================================
SPI_print:
;======================================================================
;							調 DA 板 offset
;======================================================================

;		MOVW	DP,#VAR16page
;		MOV     AL,#0x7FFF
;		MOV     @SPIOUTPUT,AL;#0xFFF0(AL)
;======================================================================

;		MOVW	DP,#DQpage
;		MOV		ACC,@i_q
;		LSL		ACC,#1
;		MOV		@AR1,AL
;		SPI1	@AR1
;
;		MOVW	DP,#DQpage
;		MOV		ACC,@i_d
;		LSL		ACC,#1
;		MOV		@AR2,AL
;		SPI2	@AR2
;
;		MOVW	DP,#SPEEDpage
;		MPY		ACC,@RPM_M_command,#2
;		MOV		@AR3,AL
;		SPI3	@AR3
;
;		MOVW	DP,#SPEEDpage
;		MPY		ACC,@RPM_M,#2
;		MOV		@AR4,AL
;		SPI4	@AR4
;
;======================================================================
;							END_SPI_print
;======================================================================
;=======================================================================
;							End ePWM2_interrupt
;=======================================================================

;-----------------------------測試中斷時間 gpio25
		MOVW	DP,#GPIOpage2
		OR		@GPACLEAR+1,#9

		IRET							;離開中斷
