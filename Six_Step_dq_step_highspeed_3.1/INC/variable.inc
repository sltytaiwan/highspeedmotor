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
;*	   This file is the memory definition using in the system.
;*		
;*
;*	 Author:   
;*
;*	 Logfile:
;*
;*	 Date:	
;*
;*	 Revision:   1.0
;*
;*   Revised History:
;*   Initial revision.
;*******************************************************************************

;Page partition                     
Stackpage			.equ	0440h/64	;400h~440h



;==============================================================

;===========================================                
;				Stackpage
;===========================================

stack				.equ	0440h
stack1				.equ	stack+2
stack2				.equ	stack1+2
stack3				.equ	stack2+2
stack4				.equ	stack3+2
stack5				.equ	stack4+2
stack6				.equ	stack5+2
stack7				.equ	stack6+2
stack8				.equ	stack7+2
stack9				.equ	stack8+2





;===========================================
;				VAR16page
;===========================================
VAR16page			.equ    0480h/64	;480h~4C0h
Sin_counter			.equ  	0480h
twoINT_counter		.equ  	0482h
I_FB_U_SPI			.equ  	twoINT_counter+1
I_FB_V_SPI			.equ  	I_FB_U_SPI+1
I_FB_W_SPI			.equ  	I_FB_V_SPI+1
Speed_cmd_SPI		.equ  	I_FB_W_SPI+1
Speed_fb_SPI		.equ  	Speed_cmd_SPI+1
SIN_U_SPI			.equ  	Speed_fb_SPI+1
SIN_V_SPI			.equ  	SIN_U_SPI+1
SIN_W_SPI			.equ  	SIN_V_SPI+1
Sintable_value		.equ  	SIN_W_SPI+2		;0490
sixstepcount        .equ  	Sintable_value+1;0491
SPIOUTPUT			.equ  	sixstepcount+1	;0492
counter        		.equ    SPIOUTPUT+1		;0493
counter1        	.equ    counter+1 		;0494
ERROR_NOW_U			.equ	counter1+1 		;0495
ERROR_U				.equ	ERROR_NOW_U+1	;0496
ERROR_1_U			.equ	ERROR_U+1		;0497
CMD1				.equ	ERROR_1_U+1	    ;0498
CMD2				.equ	CMD1+1		    ;0499
CMD3				.equ	CMD2+1		    ;049A
PIOUT_U				.equ	CMD3+1		    ;049B
ERROR_NOW_V			.equ	PIOUT_U+1		;049C
CURRENT_LIMIT		.equ	ERROR_NOW_V+1	;049D
sintable_value_V	.equ	CURRENT_LIMIT+1	   ;049E
sintable_value_W	.equ	sintable_value_V+1	;049F
sintable_value_U	.equ	sintable_value_W+1	;04A0
sin_counter1		.equ	sintable_value_U+1	;04A1
Hallsensor			.equ	sin_counter1+1
SIX_STEP_U			.equ	Hallsensor+1
SIX_STEP_V			.equ	SIX_STEP_U+1
SIX_STEP_W			.equ	SIX_STEP_V+1
SIN_U				.equ	SIX_STEP_W+1
SIN_V				.equ	SIN_U+1
SIN_W				.equ	SIN_V+1
I_FB_U				.equ	SIN_W+1
I_FB_V				.equ	I_FB_U+1		;04AA
I_FB_W				.equ	I_FB_V+1
Debounce_NEW		.equ	I_FB_W+1
Debounce_OLD		.equ	Debounce_NEW+1
Debounce_State		.equ	Debounce_OLD+1
Debounce_Times		.equ	Debounce_State+1
Debounce_OUT		.equ	Debounce_Times+1	;04B0
CMD4				.equ	Debounce_OUT+1		;04B1
ERROR_V				.equ	CMD4+1
ERROR_1_V			.equ	ERROR_V+1
PIOUT_V				.equ	ERROR_1_V+1
CMD5				.equ	PIOUT_V+1
ERROR_W				.equ	CMD5+1
ERROR_1_W			.equ	ERROR_W+1
PIOUT_W				.equ	ERROR_1_W+1			;04B8
CMD6				.equ	PIOUT_W+1           ;04B9
CMD7				.equ	CMD6+1              ;04BA
V_CMD				.equ	CMD7+1              ;04BB
kp_gain_U				.equ	V_CMD				;04BC
ki_gain_U				.equ	kp_gain+1           ;04BD
ERROR_NOW_W			.equ	ki_gain+1           ;04BE
Flag				.equ	ERROR_NOW_W+1       ;04BF

;===========================================
;				AApage
;===========================================
AApage				.equ    0500h/64	;500h~540h
Debounce_NEW_15		.equ  	0500h
Debounce_OLD_15		.equ	Debounce_NEW_15+1
Debounce_State_15	.equ	Debounce_OLD_15+1
Debounce_Times_15	.equ	Debounce_State_15+1
Debounce_OUT_15		.equ	Debounce_Times_15+1
SHIFT				.equ	Debounce_OUT_15+1			;05BD
CURRENTCMD			.equ	SHIFT+1		            	;05BE
Compasation_Gain	.equ	CURRENTCMD+1            	;05BF
ENCORDER_COUNTER	.equ	Compasation_Gain+1
U_AL                .equ    ENCORDER_COUNTER+1
U_AH                .equ    U_AL+1
V_AL                .equ    U_AH+1
V_AH                .equ    V_AL+1
W_AL                .equ    V_AH+1
W_AH                .equ    W_AL+1
U_square_count      .equ    W_AH+1
V_square_count      .equ    U_square_count+1
W_square_count      .equ    V_square_count+1
UVW_count_test      .equ    W_square_count+1
OUT_STEP			.equ	UVW_count_test+1
PIOUT_STEP			.equ	OUT_STEP+1
OUT_SLOW			.equ	PIOUT_STEP+1
PIOUT_SLOW			.equ	OUT_SLOW+1
Scan_off_100		.equ	PIOUT_SLOW+1
Scan_on_100			.equ	Scan_off_100+1
AA_FLAG				.equ	Scan_on_100+1
error_value         .equ	AA_FLAG+1
error_pv            .equ	error_value+1
SV                  .equ	error_pv+1
PV                  .equ	SV+1
kp                  .equ	PV+1
ki                  .equ	kp+1
counter_sq          .equ	ki+1
control_v           .equ	counter_sq+1
control_pv          .equ	control_v+2
kppp                .equ    control_pv+2


;===========================================
;				ECAPpage
;===========================================
ECAPpage			.equ	0580h/64	;0580h~05C0h

capture_period		.equ	0580h
capture_counter     .equ	capture_period+2	;0582
cap_den             .equ	capture_counter+2	;0584
cap_num             .equ	cap_den+2	        ;0586
capture_highword	.equ	cap_num+2	        ;0588
initial_counter		.equ	capture_highword+1	;0589
initial_capflag		.equ	initial_counter+1	;058A
capture_quotient16	.equ	initial_capflag+1   ;058B
capture_frequency	.equ	capture_quotient16+1;8C
hallsensor_speed	.equ	capture_frequency+1	;8D
angle				.equ	hallsensor_speed+1	;8E
angle_last			.equ	angle+1				;8F
angle_change		.equ	angle_last+1		;90
angle_gain			.equ	angle_change+1		;91
GAIN				.equ	angle_gain+1		;92
speed_count_err		.equ	GAIN+1				;93
speed_feedback	    .equ	speed_count_err+1	;94
speed_count 		.equ	speed_feedback+1    ;95
speed_count_1		.equ	speed_count+1		;96
speed_feedback_neg	.equ	speed_count_1+1		;97
Zpulse				.equ	speed_feedback_neg+1;98
ZFLAG				.equ	Zpulse+1			;99
GAIN_2				.equ	ZFLAG+1				;9A
Iout				.equ	GAIN_2+1			;9B
Iout_LPF			.equ	Iout+1				;9C
Iout_LPF_old		.equ	Iout_LPF+1			;9D
limit_sin2          .equ	Iout_LPF_old+1		;9E
ecap_cap_1        	.equ	limit_sin2+1        ;059F
ecap_cap_2          .equ    ecap_cap_1+2          ;05A0
ecap_cap_3          .equ    ecap_cap_2+2         ;059F
ecap_cap_4          .equ    ecap_cap_3+2
decouple            .equ    ecap_cap_4+2
;===========================================
;				SPEED-page
;===========================================
SPEEDpage		.equ	05C0h/64					;05C0h~0600h
RESOULT_SPEED	.equ	05C0h			      ;
COUNT_SIX_STEP  .equ    RESOULT_SPEED+1
CYCLE_SIX_STEP  .equ    COUNT_SIX_STEP+1
RPM_M           .equ    CYCLE_SIX_STEP+1
ENCODER_COUNT   .equ    RPM_M+1
ENCODER_STEP    .equ    ENCODER_COUNT+2
CYCLE_SIX_STEP3 .equ    ENCODER_STEP+2
RPM_M_command   .equ    CYCLE_SIX_STEP3+1
error_RPM_M     .equ    RPM_M_command+1
error_RPM_M_pre .equ    error_RPM_M+1
piout_RPM_M     .equ    error_RPM_M_pre+1
kp_gain_RPM_M   .equ    piout_RPM_M+1
ki_gain_RPM_M   .equ    kp_gain_RPM_M+1
DIR_M           .equ    ki_gain_RPM_M+1
ecap_count      .equ    DIR_M+1
TSCTR_pre       .equ    ecap_count+2
RPM_M_ecap      .equ    TSCTR_pre+2
ENCODER_STEP_ecap   .equ    RPM_M_ecap+2
RPM_MODE        .equ    ENCODER_STEP_ecap+2
;===========================================
;				DQ-page
;===========================================
DQpage					.equ	0700h/64h
sin_counter_0			.equ  	0700h
cos_counter_0           .equ    sin_counter_0+1
sin_counter_120_pos     .equ    cos_counter_0+1
cos_counter_120_pos     .equ    sin_counter_120_pos+1
sin_counter_120_neg     .equ    cos_counter_120_pos+1
cos_counter_120_neg     .equ    sin_counter_120_neg+1
sin_value_0             .equ    cos_counter_120_neg+1
cos_value_0             .equ    sin_value_0+1
sin_value_120_pos       .equ    cos_value_0+1
cos_value_120_pos       .equ    sin_value_120_pos+1
sin_value_120_neg       .equ    cos_value_120_pos+1
cos_value_120_neg       .equ    sin_value_120_neg+1
cos_counter_6time       .equ    cos_value_120_neg+1
cos_value_6time         .equ    cos_counter_6time+1
i_d                     .equ    cos_value_6time+1
i_d_command             .equ    i_d+1
error_d                 .equ    i_d_command+1
error_d_pre             .equ    error_d+1
piout_d                 .equ    error_d_pre+1
piout_d_pre             .equ    piout_d+1
i_q                     .equ    piout_d_pre+1
i_q_command             .equ    i_q+1
error_q                 .equ    i_q_command+1
error_q_pre             .equ    error_q+1
piout_q                 .equ    error_q_pre+1
piout_q_pre             .equ    piout_q+1
dq_piout_U              .equ    piout_q_pre+1
dq_piout_V              .equ    dq_piout_U+1
dq_piout_W              .equ    dq_piout_V+1
SUM_A                   .equ    dq_piout_W+1
SUM_B                   .equ    SUM_A+1
DQ_IFB_U                .equ    SUM_B+1
DQ_IFB_V                .equ    DQ_IFB_U+1
DQ_IFB_W                .equ    DQ_IFB_V+1
DQ_ki_gain              .equ    DQ_IFB_W+1
DQ_kp_gain              .equ    DQ_ki_gain+1
piout_q_2               .equ    DQ_kp_gain+1
spwm_U                  .equ    piout_q_2+1
spwm_V                  .equ    spwm_U+1
spwm_W                  .equ    spwm_V+1
spwm_max                .equ    spwm_W+1
spwm_min                .equ    spwm_max+1
spwm_eff                .equ    spwm_min+1
spwm_off                .equ    spwm_eff+1
dpwm_U                  .equ    spwm_off+1
dpwm_V                  .equ    dpwm_U+1
dpwm_W                  .equ    dpwm_V+1
theta_V                 .equ    dpwm_W+1
tan_theta_V             .equ    theta_V+1
delta_theta_V           .equ    tan_theta_V+1
theta_value             .equ    delta_theta_V+1
V_qs                    .equ    theta_value+1
V_ds                    .equ    V_qs+1
MA_theta_V              .equ    V_ds+1
;==========================================================
;                    CC-page
;==========================================================
CCpage                  .equ    0770h/64h

IFB_U                   .equ    0770h               ;0750h
IFB_V                   .equ    IFB_U+1             ;0751h
IFB_W                   .equ    IFB_V+1             ;0752h
current_limit           .equ    IFB_W+1             ;0753h
eqepcnt                 .equ    current_limit+1     ;0754h
SPI_out                 .equ    eqepcnt+1           ;0755h
sin_counter_U           .equ    SPI_out+1           ;0756h
sin_counter_V           .equ    sin_counter_U+1     ;0757h
sin_counter_W           .equ    sin_counter_V+1     ;0758h
sin_counter_U_STEP      .equ    sin_counter_W+1     ;0759h
sin_counter_V_STEP      .equ    sin_counter_U_STEP+1     ;0760h
sin_counter_W_STEP      .equ    sin_counter_V_STEP+1     ;0761h
sin_value_U             .equ    sin_counter_W_STEP+1     ;0762h
sin_value_V             .equ    sin_value_U+1       ;0763h
sin_value_W             .equ    sin_value_V+1       ;0764h
sin_value_U_STEP        .equ    sin_value_W+1       ;0765h
sin_value_V_STEP        .equ    sin_value_U_STEP+1       ;0766h
sin_value_W_STEP        .equ    sin_value_V_STEP+1       ;0767h
kp_gain                 .equ    sin_value_W_STEP+1       ;0768h
ki_gain                 .equ    kp_gain+1           ;0769h
I_U_command             .equ    ki_gain+1           ;0770h
error_U                 .equ    I_U_command+1       ;0771h
error_U_pre             .equ    error_U+1           ;0772h
piout_U                 .equ    error_U_pre+1       ;0773h
I_V_command             .equ    piout_U+1           ;0774h
error_V                 .equ    I_V_command+1       ;0775h
error_V_pre             .equ    error_V+1           ;0776h
piout_V                 .equ    error_V_pre+1       ;0777h
I_W_command             .equ    piout_V+1           ;0778h
error_W                 .equ    I_W_command+1       ;0779h
error_W_pre             .equ    error_W+1           ;0780h
piout_W                 .equ    error_W_pre+1       ;0781h
hall_reg                .equ    piout_W+1           ;0782h
hall_reg_pre            .equ    hall_reg+1          ;0783h
I_command               .equ    hall_reg_pre+1      ;0784h
MODE                    .equ    I_command+1         ;0785h
REG                     .equ    MODE+1              ;0785h

;==========================================================
;                    MATH-page
;==========================================================
MATHpage                  .equ    07E0h/64h

input_sqrt              .equ    07E0h                  ;32 byte
close_value             .equ    input_sqrt+2           ;07E2h
yout_1                  .equ    close_value+2          ;07E4h
yout_2                  .equ    yout_1+2               ;07E6h
yout_3                  .equ    yout_2+2               ;07E8h
yout_4                  .equ    yout_3+2               ;07EAh
yout_5                  .equ    yout_4+2               ;07ECh
yout_6                  .equ    yout_5+2               ;07EEh
yout_7                  .equ    yout_6+2               ;07F0h
yout_8                  .equ    yout_7+2               ;07F2h
yout_9                  .equ    yout_8+2               ;07F4h
yout_10                 .equ    yout_9+2               ;07F6h
mathdata                .equ    yout_10+2              ;07F8h
MA_result               .equ    mathdata+2             ;07FAh

;==========================================================
;                    WOC-page
;==========================================================
WOCpage                             .equ    0850h/64    ;480h~4C0h
sin_counter_WOC_0                   .equ   0850h
sin_counter_WOC_120_pos             .equ   sin_counter_WOC_0+1
sin_counter_WOC_120_neg             .equ   sin_counter_WOC_120_pos+1
cos_counter_WOC_0                   .equ   sin_counter_WOC_120_neg+1
cos_counter_WOC_120_pos             .equ   cos_counter_WOC_0+1
cos_counter_WOC_120_neg             .equ   cos_counter_WOC_120_pos+1
sin_value_WOC_0                     .equ   cos_counter_WOC_120_neg+1
sin_value_WOC_120_pos               .equ   sin_value_WOC_0+1
sin_value_WOC_120_neg               .equ   sin_value_WOC_120_pos+1
cos_value_WOC_0                     .equ   sin_value_WOC_120_neg+1
cos_value_WOC_120_pos               .equ   cos_value_WOC_0+1
cos_value_WOC_120_neg               .equ   cos_value_WOC_120_pos+1
WOC_piout_U                         .equ   cos_value_WOC_120_neg+1
WOC_piout_V                         .equ   WOC_piout_U+1
WOC_piout_W                         .equ   WOC_piout_V+1
spwm_WOC_U                          .equ   WOC_piout_W+1
spwm_WOC_V                          .equ   spwm_WOC_U+1
spwm_WOC_W                          .equ   spwm_WOC_V+1
spwm_WOC_max                        .equ   spwm_WOC_W+1
spwm_WOC_min                        .equ   spwm_WOC_max+1
spwm_WOC_eff                        .equ   spwm_WOC_min+1
spwm_WOC_off                        .equ   spwm_WOC_eff+1
dpwm_WOC_U                          .equ   spwm_WOC_off+1
dpwm_WOC_V                          .equ   dpwm_WOC_U+1
dpwm_WOC_W                          .equ   dpwm_WOC_V+1
