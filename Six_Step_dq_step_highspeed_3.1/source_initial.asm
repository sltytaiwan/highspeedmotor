;*******************************************************************************
;*	 Header:   
;*	 Version:1.0
;*******************************************************************************
;* =============================================================================
;*
;*	Copyright 2011 BY NTUT-EE Lab-316
;*
;* =============================================================================
;*
;*	 File Description:
;*
;*	 This file contains initial setup.
;*
;*	 Author: name 
;*			
;*
;*	 Logfile:   source_init.asm
;*
;*	 Date:	2011/04/20
;*
;*	 Revision:   1.0
;*
;*   Revised History: 
;*   Initial revision.
;*	
; Setting initial parameters(from System Control and Interrupts PDF.)
; 1.Flash
; 2.Clock
; 3.GPIO
; 4.AD
; 5.ePWM
; 6.eCAP
;*******************************************************************************


					.include	"register.inc"
					.include    "Macro.inc"
					.include    "constant.inc"
					.include	"variable.inc"
					.global		INITIAL_ALL



;-----------------------GPIO Mux dierection------------------------------

;====================================================================================
;						 	Start INITIAL_ALL
;====================================================================================

  			 							    
INITIAL_ALL:
			
			   EALLOW
;====================================================================================
;						 	Flash and OTP setting
;====================================================================================		

;====================================================================================
;						 	COUNTER CLEAR
;====================================================================================


			    MOVW	DP,#Flashpage 
			    MOV		@FOPT,#0x0001
			    MOV		@FBANKWAIT,#0x0003
			    MOV		@FOTPWAIT,#0x0005
			    MOV		@FSTDBYWAIT,#0x01FF
			    MOV		@FACTIVEWAIT,#0x01FF      
				MOV		@FPWR,#0x0000
				MOV		@FSTATUS,#0x0000		
				
				RPT 	#8||NOP
	

;====================================================================================
;						 End Flash and OTP setting
;====================================================================================
;==================================================================================== 
;		     				  Clock setting(EVM板)
;==================================================================================== 
;
;		MOVW	DP,#CLKpage
;		MOV		@XCLK,#0x0043			;GPIO19 is XCLKIN input source,XCLKOUT=OFF
;		MOV   	@SCSR,#0x0007			;Initialize Watch Dog, Watch dog用不到..自己變7= ="
;		MOV   	@WDCR,#0x0040			;Set WDDIS bit in WDCR to disable WD
;		MOV		@CLKCTL,#0x6402			;XCLKINOFF
;		MOV   	@PLLSTS,#0x0004  	 	;PLL Off
;		OR    	@PLLSTS,#0x0040			;Set MCLKOFF=1
;		MOV   	@PLLCR,#0x000C			;10MHz*12
;		MOV   	@PLLSTS,#0x0001        	;(PLLLOCKS=1,MCLKOFF=0)PLL finish clocking, PLL不再倍頻, 鎖住倍率
;		OR    	@PLLSTS,#0x0100			;Select Divide By 2 for CLKIN.(10MHz*12)/2
;		MOV   	@LOSPCP,#0x0000		  	;Low speed clock = SYSCLKOUT/1, 給周邊的CLock
;
;		MOV   	@PCLKCR0,#0x030C        ;開啟ADC,SPI功能
;		MOV   	@PCLKCR1,#0x417F        ;開啟ePWM,ECAP,EQEP功能
;		MOV   	@PCLKCR3,#0x6700		;開啟CLA,GPIO,CPUTIMER功能
;
;******************************控制板使用外部CLOCK*******************************************

		MOVW    DP,#CLKpage
;-------use the external oscillator by GPIO19(CB3LV)frequency to 20MHz-------------------
        MOV     @XCLK,#0x0043           ;GPIO19 is XCLKIN input source,XCLKOUT off(p.40)
        MOV     @SCSR,#0x0007           ;Initialize Watch Dog, Watch dog用不到..
        MOV     @WDCR,#0x0040           ;Set WDDIS bit in WDCR to disable WD
        MOV     @CLKCTL,#0x4005         ;Crystal oscillator off,XCLKIN oscillator input on
        MOV     @PLLSTS,#0x0004         ;PLL Off
        OR      @PLLSTS,#0x0040         ;Set MCLKOFF=1
        MOV     @PLLCR,#0x0006          ;20MHz*6
        MOV     @PLLSTS,#0x0001         ;(PLLLOCKS=1,MCLKOFF=0)PLL finish clocking, PLL不再倍頻, 鎖住倍率
        OR      @PLLSTS,#0x0100         ;Select Divide By 2 for CLKIN.(20MHz*6)/2 =60MHz(system clock)
        MOV     @LOSPCP,#0x0000         ;Low speed clock = SYSCLKOUT/1, 給周邊的CLock
;---------------enable or disable clocks to the various peripheral module-------------------
        MOV     @PCLKCR0,#0x030C        ;開啟ADC,SPI功能
        MOV     @PCLKCR1,#0x417F        ;開啟ePWM,ECAP,EQEP功能
        MOV     @PCLKCR3,#0x6701        ;開啟CLA,GPIO,COMP,CPU-Timer功能

;=====================================================================================
;							End Clock setting
;=====================================================================================
;=======================================================================================
;								ADC setting
;=======================================================================================
	
		MOVW	DP,#ADCpage			
		MOV   	@ADCCTL1,#0000000011100100b      ;Enable ADC Funtion,Circuit power up
		               	 ;\\\\\\\\\\\\\\\=	---->;temperature sensor           
		                 ;\\\\\\\\\\\\\\=   ---->;VREFLO choice  
		                 ;\\\\\\\\\\\\\=	---->;INT pluse generation latching
		                 ;\\\\\\\\\\\\=	  	---->;use interal reference generation
		                 ;\\\\\\\\\\=	   	---->;"1"Reference circuit buffers inside
		                 ;\\\\\\\\\=	  	---->;"1"bandgap circuit buffers inside
		                 ;\\\\\\\\=	  	  	---->;"1"analog circuit buffers inside
		                 ;\\\=====		  	---->;"0Xh"ADCINAx目前位置
					     ;\\=				---->;"0"ADC is sample next channel,"1"ADC busy					
					     ;\=				---->;ADC Enable or Disable
					     ;=				  	---->;"0"no effect "1"reset ADC

		MOV		@INTSEL1N2,#0000000000101111b    ;Interrupt 1(x) and 2(y)
 						   ;\\\\\\\\\\\=====---->;"0Fh"EOC15 select ADCINT1            
		            	   ;\\\\\\\\\\=     ---->;"1"ADCINT1 enable
		            	   ;\\\\\\\\\=	   	---->;No more ADCINTx pulse generate until ADCINTx flag is cleared by user
		         		   ;\\\=====	    ---->;"00h"EOC0 select ADCINT2
		           		   ;\\=			    ---->;"ADCINT2 is disable
		          	   	   ;\=	  		    ---->;No more ADCINTx pulse generate until ADCINTx flag is cleared by user
		           		   
;		MOV   	@INTSEL3N4,#0000000000000000b 	 ;Interrupt 3(x) and 4(y)
;		MOV   	@INTSEL5N6,#0000000000000000b 	 ;Interrupt 5(x) and 6(y)
;		MOV   	@INTSEL7N8,#0000000000000000b    ;Interrupt 7(x) and 8(y)
;		MOV   	@INTSEL9N10,#0000000000000000b   ;Interrupt 9(x) and 10(y)

;		MOV   	@SOCPRICTL,#0x0000				;SOC0 is the highest priority

		MOV   	@ADCSAMPLEMODE,#0000000000000000b ;"0" Sequential mode ; "1" Simultaneous mode
 							   ;\\\\\\\\\\\\\\\=  ---->;SOC0 and SOC1            
		            		   ;\\\\\\\\\\\\\\=   ---->;SOC2 and SOC3
		            		   ;\\\\\\\\\\\\\=	  ---->;SOC4 and SOC5
		            		   ;\\\\\\\\\\\\=	  ---->;SOC6 and SOC7
							   ;\\\\\\\\\\\=	  ---->;SOC8 and SOC9
							   ;\\\\\\\\\\=	      ---->;SOC10 and SOC11
							   ;\\\\\\\\\=	      ---->;SOC12 and SOC13
							   ;\\\\\\\\=	      ---->;SOC14 and SOC15

;*******************************************
;if Sequential mode   設定 SOC0,2,4,...,14 
;if Simultaneous mode 設定 SOC0 ~ SOC15    
;*******************************************
			;[software only,trigger source.]

		MOV   @ADCSOC0CTL,#0x0006	;SOC0  選channel A0;
		MOV   @ADCSOC1CTL,#0x0206	;SOC1  選channel B0
		   
		MOV   @ADCSOC2CTL,#0x0058	;SOC2  選channel A1
		MOV   @ADCSOC3CTL,#0x0258	;SOC3  選channel B1
		   
		MOV   @ADCSOC4CTL,#0x0098;86;SOC4  選channel A2	;ADCINA2/COMP1A
		MOV   @ADCSOC5CTL,#0x0286	;SOC5  選channel B2
		   		   
		MOV   @ADCSOC6CTL,#0x00C6;D9;SOC6  選channel A3
		MOV   @ADCSOC7CTL,#0x02C6	;SOC7  選channel B3

		MOV   @ADCSOC8CTL,#0x0119	;SOC8  選channel A4	;ADCINA4/COMP2A 25+1cycle
		MOV   @ADCSOC9CTL,#0x0306	;SOC9  選channel B4

		MOV   @ADCSOC10CTL,#0x0146	;SOC10 選channel A5
		MOV   @ADCSOC11CTL,#0x0346	;SOC11 選channel B5

		MOV   @ADCSOC12CTL,#0x0186	;SOC12 選channel A6	;ADCINA6/COMP3A
		MOV   @ADCSOC13CTL,#0x0386	;SOC13 選channel B6

		MOV   @ADCSOC14CTL,#0x01DF	;SOC14 選channel A7
		MOV   @ADCSOC15CTL,#0x03C6	;SOC15 選channel B7


;****************************
;Delay 1ms [ADC(P.16)]          
;****************************
  		MOV   AR0,#12000			;可用IO腳設定high, 到中斷讀AD之前再low看時間.
DELAY_1ms:		
		   NOP

		   BANZ  DELAY_1ms,AR0--	;指令集6-59, power up之後須給1ms之delay

		OR    @ADCCTL1,#0x4000		;Power up 之後再Enable ADC

;-----------------------ADC channel---------------------------------- 
                       				
		MOV    	@AIOMUX1,#0xAAAA		;ADCINA0~ADCINA7 將AIOMUX1皆設為ADCINAx與ADCINBx
		MOV		@AIOMUX1+1,#0xAAAA	 	;ADCINB0~ADCINB7
;=========================================================================================
;									Comparator Setting
;=========================================================================================

	;	MOVW	DP,#COMPpage
	;	MOV		@COMPCTL1,#0x0105	;Comparator1
	;	MOV		@COMPSTS1,#0x0000	;inputA=ADCINA2
	;	MOV		@DACVAL1,#0x02A5	;677 for 3.936A	784 for 6.25A

	;	MOV		@COMPCTL2,#0x0105	;Comparator2
	;	MOV		@COMPSTS2,#0x0000	;inputA=ADCINA4
	;	MOV		@DACVAL2,#0x02A5

	;	MOV		@COMPCTL3,#0x0105	;Comparator3
	;	MOV		@COMPSTS3,#0x0000	;inputA=ADCINA6
	;	MOV		@DACVAL3,#0x02A5
;=========================================================================================
;							GPIO setting
;=========================================================================================
;                           (間接定址範例)
;
;		MOV   AR1,#GPAMUX1      		;AR1為間接定址,把GPAMUX1位置放入AR1  
;	    MOV   *XAR1,#0x5555    			;*XAR1的*指其記憶體內容
		                        		;+++++++++++++++++++開啟epwm4B,epwm4A
                                		; ++++++++++++++++++開啟epwm3B,epwm3A
                                		;  +++++++++++++++++開啟epwm2B,epwm2A 
                                		;   ++++++++++++++++開啟epwm1B,epwm1A
;		MOV   AR1,#GPAMUX1+1    		;+1為左移1word=16bit位址,即是取High的部份
;		MOV   *XAR1,#0x1555    			;+++++++++++++++++++開啟TZ1~TZ3 
                                		; +++++++++++++++++開啟epwm6B,epwm6A
                                		;  ++++++++++++++++開啟epwm5B,epwm5A
										;   +++++++++++++++開啟GPIO15  
;=========================================================================
;						在此GPIO設定 用直接定址!

		MOVW	DP,#GPIOpage					;GPIOpage
;--------------------------GPIO0~GPIO44 function------------------------                                                

		MOV		@GPAMUX1,#000000000000000b		;Fuction of GPIO0~GPIO7
                         ;\\\\\\\\\\\\\\== ---->;GPIO0 = ePWM1A
                         ;\\\\\\\\\\\\==   ---->;GPIO1 = ePWM1B
                         ;\\\\\\\\\\==     ---->;GPIO2 = ePWM2A
                         ;\\\\\\\\==       ---->;GPIO3 = ePWM2B
                         ;\\\\\\==         ---->;GPIO4 = ePWM3A
                         ;\\\\==           ---->;GPIO5 = ePWM3B
                         ;\\==             ---->;GPIO6 = ePWM4A
                         ;==               ---->;GPIO7 = ePWM4B

		MOV		@GPAMUX1+1,#0000000000000000b     ;Fuction of GPIO8~GPIO15
                           ;\\\\\\\\\\\\\\== ---->;GPIO8 = ePWM5A
                           ;\\\\\\\\\\\\==   ---->;GPIO9 = ePWM5B
                           ;\\\\\\\\\\==     ---->;GPIO10 = ePWM6A
                           ;\\\\\\\\==       ---->;GPIO11 = ePWM6B
                           ;\\\\\\==         ---->;GPIO12
                           ;\\\\==           ---->;GPIO13
                           ;\\==             ---->;GPIO14 = switch 3 (input)
                           ;==               ---->;GPIO15 = switch 4 (input)

		MOV		@GPAMUX2,#0100010100010001b		;Fuction of GPIO16~GPIO23
                         ;\\\\\\\\\\\\\\== ---->;SPISIMOA(I/O) (output)
                         ;\\\\\\\\\\\\==   ---->;GPIO17:目前SPI只傳送資料故不用設SPISOMIA
                         ;\\\\\\\\\\==     ---->;SPICLKA(I/O)  (output)
                         ;\\\\\\\\==       ---->;GPIO19 = XCLKIN (input)
                         ;\\\\\\==         ---->;GPIO20 => EQEP1A(COMP1OUT test comparator1)
                         ;\\\\==           ---->;GPIO21 => EQEP1B
                         ;\\==             ---->;GPIO22 = switch 1 (input):Servo On
                         ;==               ---->;GPIO23 => EQEP1I (Z pluse)
		
	    MOV		@GPAMUX2+1,#0000000000000001b	  ;Fuction of GPIO24~GPIO31 
                           ;\\\\\\\\\\\\\\== ---->;GPIO24 => ECAP1
                           ;\\\\\\\\\\\\==   ---->;GPIO25
                           ;\\\\\\\\\\==     ---->;GPIO26 = CS1 (output)
                           ;\\\\\\\\==       ---->;GPIO27 = Test pin (output)
                           ;\\\\\\==         ---->;GPIO28
                           ;\\\\==           ---->;GPIO29
                           ;\\==             ---->;GPIO30
                           ;==               ---->;GPIO31  EVM板LED2 low動作(output)
		
		MOV		@GPBMUX1,#0000000000000000b		;Fuction of GPIO32~GPIO39 
                         ;\\\\\\\\\\\\\\== ---->;GPIO32 = Hall U
                         ;\\\\\\\\\\\\==   ---->;GPIO33 = Hall V
                         ;\\\\\\\\\\==     ---->;GPIO34   EVM板LED3 low動作(output)
                         ;\\\\\\\\==       ---->;GPIO35
                         ;\\\\\\==         ---->;GPIO36
                         ;\\\\==           ---->;GPIO37
                         ;\\==             ---->;GPIO38
                         ;==               ---->;GPIO39 = LDAC (output)

        MOV		@GPBMUX1+1,#0000000000000000b	  ;Fuction of GPIO40~GPIO44
                           ;\\\\\\\\\\\\\\== ---->;GPIO40 = ePWM7A
                           ;\\\\\\\\\\\\==   ---->;GPIO41 = ePWM7B
                           ;\\\\\\\\\\==     ---->;GPIO42 = Hall W
                           ;\\\\\\\\==       ---->;GPIO43 = Z pulse
                           ;\\\\\\==         ---->;GPIO44 = CS2 (output)

;-----------------------GPIO debounce(system clock= 100MHz)--------------------------------

		MOV		@GPACTRL,#0x0000		;GPIO0~GPIO15 Sampling Period=Tsysclkout
		MOV		@GPACTRL+1,#0x0040		;GPIO16~GPIO23 Qualification=Sampling Period=128*Tsysclkout,
		                                ;GPIO24~GPIO31  Sampling Period=Tsysclkout

        MOV		@GPAQSEL1,#0x0000		;GPIO0~GPIO7 synchronize to SYSCLKOUT
		MOV		@GPAQSEL1+1,#0x0000     ;GPIO8~GPIO15 synchronize to SYSCLKOUT

        MOV		@GPAQSEL2,#0x8A00		;GPIO16~GPIO23 synchronize to SYSCLKOUT
	    MOV     @GPAQSEL2+1,#0x0000     ;GPIO26=Qualification using 6 samples

		MOV		@GPBCTRL,#0x4040		;GPIO32~GPIO39 Sampling Period=Tsysclkout
										;GPIO40~GPIO44 Sampling Period=Tsysclkout,
		                                ;GPIO24~GPIO31 Qualification=Sampling Period=510*Tsysclkout
		MOV		@GPBQSEL1,#0x000A		;GPIO32~GPIO39 synchronize to SYSCLKOUT
		MOV		@GPBQSEL1+1,#0x0020     ;GPIO40~GPIO44 synchronize to SYSCLKOUT
        
;-----------------------GPIO Mux direction------------------------------
;0:Input , 1:Output , defalt is 0:Input

		MOV		@GPADIR,#1111111111111111b	   ;direction of GPIO0~GPIO15
                        ;\\\\\\\\\\\\==== ---->;GPIO0~3 
                        ;\\\\\\\\====     ---->;GPIO4~7
                        ;\\\\====         ---->;GPIO8~11
                        ;====             ---->;GPIO12~15

                         
		MOV		@GPADIR+1,#1000111000000101b     ;direction of GPIO16~GPIO31
                          ;\\\\\\\\\\\\==== ---->;GPIO16~19 
                          ;\\\\\\\\====     ---->;GPIO20~23
                          ;\\\\====         ---->;GPIO24~27
                          ;====             ---->;GPIO28~31		

		MOV		@GPBDIR,#0001000010000100b     ;direction of GPIO32~GPIO44
                        ;\\\\\\\\\\\\==== ---->;GPIO32~35 
                        ;\\\\\\\\====     ---->;GPIO36~39
                        ;\\\\====         ---->;GPIO40~43
                        ;xxx=             ---->;GPIO44	

;-----------------------GPIO Mux initial value---------------------------

		MOVW	DP,#GPIOpage2			;GPIOpage2
		MOV		@GPADAT,#0x0000			;GPIO0~GPIO15
		MOV		@GPADAT+1,#0x8000		;GPIO16~GPIO31 ; GPIO31初始值為1
        MOV		@GPBDAT,#0x0403;4		;GPIO32~GPIO44 ; GPIO34初始值為1 get mode

;=======================================================================================
;							End GPIO setting
;=======================================================================================

;=====================================================================================
;								PIE setting
;=====================================================================================
;
		MOVW	DP,#INTpage
		MOV   	@PIECTRL,#0x0001  		;開啟中斷向量表功能ENPIE[INT(P.129)]			
		MOV   	@PIEIFR3,#0x0022  		;設PIE interrupt 3.2,Flag為1表示可執行
		MOV   	@PIEIER3,#0x0022  		;Enable PIE interrupt 3.2 and interrupt 3.6
		MOV   	@PIEACK,#0x0004   		;設定4代表開啟INT3.x的功能,ePWM中斷皆在INT3.x, 第二個bit=1, 代表開啟INT3.x, 寫在最後會清除中斷旗標

		AND   	IFR,#0x0000       		;Clear interrupt flag
		 OR    	IER,#0x0004      		;Enable interrupt group 3

;=====================================================================================
;							  End PIE setting
;=====================================================================================		
;
;======================================================================================
;							CPU Timer1 setting(SYSCLK=60MHz,16.67ns)
;======================================================================================

		MOVW	DP,#Timerpage		    ;CPU Timer0,1,2	page
		MOV		@TIMER1TIM,#0x0000	    ;先將Timer1之counts清零
		MOV		@TIMER1TIMH,#0x0000     ;Timer1 counts High word
	;	MOV		@TIMER1PRD,#0x0000	    ;Timer1 counter 如果使用INTR進中斷可以不用設
		MOV		@TIMER1PRDH,#0x0000     ;Timer1 period High word
		MOV		@TIMER1TCR,#0x4800      ;先enable Timer1, Free run

;======================================================================================
;							End CPU Timer setting
;======================================================================================
;;=====================================================================================
;		                   PI controller setting
;======================================================================================
         MOVW   DP,#VAR16page
         MOV	@CURRENT_LIMIT,#5296;(3A)		;10592		;4A
         MOV	@Sin_counter,#0x0000
         MOV	@Sin_counter+1,#0x0000
		 MOV	@SIN_U,#0x0000
		 MOV	@SIN_V,#0x0000
		 MOV	@SIN_W,#0x0000
		 MOV	@counter,#0x0000
		 MOV	@ERROR_U,#0x0000
		 MOV	@ERROR_V,#0x0000
		 MOV	@ERROR_W,#0x0000
		 MOV	@PIOUT_U,#0x0000
		 MOV	@PIOUT_V,#0x0000
		 MOV	@PIOUT_W,#0x0000
		 MOV	@counter1,#0x0000
		 MOVW	DP,#DQpage
		 MOVW	DP,#OLpage
		 MOV	@COUNTER_ON,#0x0000
		 MOV	@COUNTER_OFF,#0x0000
		 MOV	@c1_ON,#0x0000
		 MOV	@c2_OFF,#0x0000
;;=====================================================================================
;		                  End PI controller setting
;======================================================================================

;======================================================================================
;					        ePWM setting(TBCLK=STYCLK=60MHz)
;======================================================================================
;--------------------------ePWM1 setting-----------------------------------------------

		MOVW	DP,#ePWM1page			;ePWM1	
		MOV		@TBPRD1,#1499			;因為ETSEL在TBCTR = 0x0000時進中斷，故產生20KHz中斷頻率,並因為AQCTLA設定得到開關切換頻率kHZ[ePWM(P.25)]
										;f=100M/5000=20k
		MOV		@TBPHS1,#0x0000			;Phase shift 0 degree
		MOV		@TBCTL1,#0x0012		    ;上下數Up-down-count mode,Synchronization Output Select(TBCTR = 0x0000)
										;bit0,1 : 00=Up, 01=Down, 10=Up-Down
		MOV     @TBCTR1,#0x0000      	;Time base counter 先清為零
		MOV    	@CMPCTL1,#0x000A        ;shadow mode , Load on CTR=Zero
		MOV		@CMPA1,#0x0000
		MOV     @AQCTLA1,#0x0090		;Counter=CMPA when the counter is decrementing.force EPWMxA output high.
                                        ;Counter=CMPA when the counter is incrementing.force EPWMxA output low.
		MOV   	@ETSEL1,#0x000A 		;Enable event when TBCTR = 0x0000
		MOV   	@ETPS1,#0x0001   		;Generate an INT on the every event INTCNT=01
		MOV     @DBCTL1,#0x000B;7       ;Active high complementrary(AHC). EPWMxB is inverted,
		                                ;Rising-edge(EPWMxA) and Falling-edge(EPWMxB)
		MOV     @DBRED1,#36;210;135     ;50/60M s;實際上Dead-time只有600ns
		MOV     @DBFED1,#36;210;135
		
	;	MOV		@TZSEL1,#0x00C0			;Select and enable DCAEVT2 and DCBEVT2(cycle by cycle)
	;	MOV		@TZCTL1,#0x088A			;Select DCAEVT2 and DCBEVT2 action on EPMWxA and EPWMxB for low-state
	;	MOV		@TZDCSEL1,#0x0208
	;	MOV		@DCTRIPSEL1,#0x8888		;Define the source for the DCAH/DCAL DCBH/DCBL and choose the Comparator1's OUTPUT
	;	MOV		@DCACTL1,#0x0000		;Source is DCAEVT1/2, and sychrouns with TBCLK
	;	MOV		@DCBCTL1,#0x0000		;Source is DCBEVT1/2, and sychrouns with TBCLK

;--------------------------ePWM2 setting-----------------------------------------------

		MOVW	DP,#ePWM2page			;ePWM2	
		MOV		@TBPRD2,#1499			;因為ETSEL在TBCTR = 0x0000時進中斷，故產生20KHz中斷頻率,並因為AQCTLA設定得到開關切換頻率20kHZ[ePWM(P.25)]
		MOV		@TBPHS2,#0x0000			;Phase shift 0 degree
		MOV		@TBCTL2,#0x0012			;上下數Up-count mode,Disable EPWMxSYNCO signal
										;bit0,1 : 00=Up, 01=Down, 10=Up-Down
		MOV     @TBCTR2,#0x0000      	;Time base counter 先清為零
		MOV    	@CMPCTL2,#0x000A        ;shadow mode , Load on CTR=Zero
		MOV		@CMPA2,#0x0000
		MOV     @AQCTLA2,#0x0090		;Counter=CMPA when the counter is decrementing.force EPWMxA output high.
                                        ;Counter=CMPA when the counter is incrementing.force EPWMxA output low.

        MOV     @ETSEL2,#0x000A;B  		;Enable event when TBCTR=0x0000 and TBCTR = TBPRD
		MOV     @ETPS2,#0x0001   		;Generate an INT on the first event INTCNT=01
		MOV     @DBCTL2,#0x000B;7       ;Active high complementrary(AHC). EPWMxB is inverted,
		                                ;Rising-edge(EPWMxA) and Falling-edge(EPWMxB)
		MOV     @DBRED2,#36;210;135    ;實際上Dead-tmie只有600ns
		MOV     @DBFED2,#36;210;135

	;	MOV		@TZSEL2,#0x00C0			;Select and enable DCAEVT2 and DCBEVT2(cycle by cycle)
	;	MOV		@TZCTL2,#0x088A			;Select DCAEVT2 and DCBEVT2 action on EPMWxA and EPWMxB for low-state
	;	MOV		@TZDCSEL2,#0x0208
	;	MOV		@DCTRIPSEL2,#0x8888		;Define the source for the DCAH/DCAL DCBH/DCBL and choose the Comparator1's OUTPUT
	;	MOV		@DCACTL2,#0x0000		;Source is DCAEVT1/2, and sychrouns with TBCLK
	;	MOV		@DCBCTL2,#0x0000		;Source is DCBEVT1/2, and sychrouns with TBCLK
;--------------------------ePWM3 setting-----------------------------------------------
	
		MOVW	DP,#ePWM3page			;ePWM3
		MOV		@TBPRD3,#1499			;因為ETSEL在TBCTR = 0x0000時進中斷，故產生20KHz中斷頻率,並因為AQCTLA設定得到開關切換頻率20kHZ[ePWM(P.25)]
		MOV		@TBPHS3,#0x0000			;Phase shift 0 degree
		MOV		@TBCTL3,#0x0012			;上下數Up-count mode,Disable EPWMxSYNCO signal
										;bit0,1 : 00=Up, 01=Down, 10=Up-Down
		MOV     @TBCTR3,#0x0000      	;Time base counter 先清為零
		MOV    	@CMPCTL3,#0x000A        ;shadow mode , Load on CTR=Zero
		MOV		@CMPA3,#0x0000
		MOV     @AQCTLA3,#0x0090		;Counter=CMPA when the counter is decrementing.force EPWMxA output high.
                                        ;Counter=CMPA when the counter is incrementing.force EPWMxA output low.
        MOV    @ETSEL3,#0x0009  		;Enable event when TBCTR=0x0000.
		MOV    @ETPS3,#0x0001   		;Generate an INT on the first event INTCNT=01
		MOV    @DBCTL3,#0x000B;7        ;Active high complementrary(AHC). EPWMxB is inverted,
		                                ;Rising-edge(EPWMxA) and Falling-edge(EPWMxB)
		MOV    @DBRED3,#36;210;135    	 ;實際上Dead-tmie只有600ns
		MOV    @DBFED3,#36;210;135

	;	MOV		@TZSEL3,#0x00C0			;Select and enable DCAEVT2 and DCBEVT2(cycle by cycle)
	;	MOV		@TZCTL3,#0x088A			;Select DCAEVT2 and DCBEVT2 action on EPMWxA and EPWMxB for low-state
	;	MOV		@TZDCSEL3,#0x0208
	;	MOV		@DCTRIPSEL3,#0x8888		;Define the source for the DCAH/DCAL DCBH/DCBL and choose the Comparator1's OUTPUT
	;	MOV		@DCACTL3,#0x0000		;Source is DCAEVT1/2, and sychrouns with TBCLK
	;	MOV		@DCBCTL3,#0x0000		;Source is DCBEVT1/2, and sychrouns with TBCLK
;--------------------------ePWM4 setting-----------------------------------------------

		MOVW	DP,#ePWM4page			;ePWM3
		MOV		@TBPRD4,#1499			;因為ETSEL在TBCTR = 0x0000時進中斷，故產生20KHz中斷頻率,並因為AQCTLA設定得到開關切換頻率20kHZ[ePWM(P.25)]
		MOV		@TBPHS4,#0x0000			;Phase shift 0 degree
		MOV		@TBCTL4,#0x0016			;上下數Up-count mode,Disable EPWMxSYNCO signal
										;bit0,1 : 00=Up, 01=Down, 10=Up-Down
		MOV     @TBCTR4,#0x0000      	;Time base counter 先清為零
		MOV    	@CMPCTL4,#0x0000        ;shadow mode , Load on CTR=Zero
		MOV		@CMPA4,#0x0000
		MOV     @AQCTLA4,#0x0012		;Counter=CMPA when the counter is decrementing.force EPWMxA output high.
                                        ;Counter=CMPA when the counter is incrementing.force EPWMxA output low.
        MOV    @ETSEL4,#0x0009  		;Enable event when TBCTR=0x0000.
		MOV    @ETPS4,#0x0005   		;Generate an INT on the first event INTCNT=01
		MOV    @DBCTL4,#0x000B;7        ;Active high complementrary(AHC). EPWMxB is inverted,
		                                ;Rising-edge(EPWMxA) and Falling-edge(EPWMxB)
		MOV    @DBRED4,#50;210;135    	 ;實際上Dead-tmie只有500ns
		MOV    @DBFED4,#50;210;135

	;	MOV		@TZSEL4,#0x00C0			;Select and enable DCAEVT2 and DCBEVT2(cycle by cycle)
	;	MOV		@TZCTL4,#0x088A			;Select DCAEVT2 and DCBEVT2 action on EPMWxA and EPWMxB for low-state
	;	MOV		@TZDCSEL4,#0x0208
	;	MOV		@DCTRIPSEL4,#0x8888		;Define the source for the DCAH/DCAL DCBH/DCBL and choose the Comparator1's OUTPUT
	;	MOV		@DCACTL4,#0x0000		;Source is DCAEVT1/2, and sychrouns with TBCLK
	;	MOV		@DCBCTL4,#0x0000		;Source is DCBEVT1/2, and sychrouns with TBCLK
;--------------------------ePWM5 setting-----------------------------------------------

		MOVW	DP,#ePWM5page			;ePWM3
		MOV		@TBPRD5,#29999			;因為ETSEL在TBCTR = 0x0000時進中斷，故產生20KHz中斷頻率,並因為AQCTLA設定得到開關切換頻率20kHZ[ePWM(P.25)]
		MOV		@TBPHS5,#0x0000			;Phase shift 0 degree
		MOV		@TBCTL5,#0x0012			;上下數Up-count mode,Disable EPWMxSYNCO signal
										;bit0,1 : 00=Up, 01=Down, 10=Up-Down
		MOV     @TBCTR5,#0x0000      	;Time base counter 先清為零
		MOV    	@CMPCTL5,#0x0000        ;shadow mode , Load on CTR=Zero
		MOV		@CMPA5,#0x0000
		MOV     @AQCTLA5,#0x0012		;Counter=CMPA when the counter is decrementing.force EPWMxA output high.
                                        ;Counter=CMPA when the counter is incrementing.force EPWMxA output low.
        MOV    @ETSEL5,#0x0009  		;Enable event when TBCTR=0x0000.
		MOV    @ETPS5,#0x0005   		;Generate an INT on the first event INTCNT=01
		MOV    @DBCTL5,#0x000B;7        ;Active high complementrary(AHC). EPWMxB is inverted,
		                                ;Rising-edge(EPWMxA) and Falling-edge(EPWMxB)
		MOV    @DBRED5,#50;210;135    	 ;實際上Dead-tmie只有500ns
		MOV    @DBFED5,#50;210;135

	;	MOV		@TZSEL4,#0x00C0			;Select and enable DCAEVT2 and DCBEVT2(cycle by cycle)
	;	MOV		@TZCTL4,#0x088A			;Select DCAEVT2 and DCBEVT2 action on EPMWxA and EPWMxB for low-state
	;	MOV		@TZDCSEL4,#0x0208
	;	MOV		@DCTRIPSEL4,#0x8888		;Define the source for the DCAH/DCAL DCBH/DCBL and choose the Comparator1's OUTPUT
	;	MOV		@DCACTL4,#0x0000		;Source is DCAEVT1/2, and sychrouns with TBCLK
	;	MOV		@DCBCTL4,#0x0000		;Source is DCBEVT1/2, and sychrouns with TBCLK
;--------------------------ePWM6 setting-----------------------------------------------

		MOVW	DP,#ePWM6page			;ePWM2
		MOV		@TBPRD6,#29999			;因為ETSEL在TBCTR = 0x0000時進中斷，故產生20KHz中斷頻率,並因為AQCTLA設定得到開關切換頻率20kHZ[ePWM(P.25)]
		MOV		@TBPHS6,#0x0000			;Phase shift 0 degree
		MOV		@TBCTL6,#0x0012			;上下數Up-count mode,Disable EPWMxSYNCO signal
										;bit0,1 : 00=Up, 01=Down, 10=Up-Down
		MOV     @TBCTR6,#0x0000      	;Time base counter 先清為零
		MOV    	@CMPCTL6,#0x0000        ;shadow mode , Load on CTR=Zero
		MOV		@CMPA6,#0
		MOV     @AQCTLA6,#0x0012		;Counter=CMPA when the counter is decrementing.force EPWMxA output high.
                                        ;Counter=CMPA when the counter is incrementing.force EPWMxA output low.
	    MOV     @ETSEL6,#0x0009  		;Enable event when TBCTR=0x0000
		MOV     @ETPS6,#0x0005   		;Generate an INT on the first event INTCNT=01
		MOV     @DBCTL6,#0x000B;B       ;Active high complementrary(AHC). EPWMxB is inverted,
		                                ;Rising-edge(EPWMxA) and Falling-edge(EPWMxB)
		MOV     @DBRED6,#50;210;135    ;實際上Dead-tmie只有900ns
		MOV     @DBFED6,#50;210;135


;=========================================================================================
;							End ePWM setting
;=========================================================================================


;=======================================================================================
;					        	SPI setting
;=======================================================================================
        MOVW   DP,#SPIpage
        MOV    @SPITXBUF,#0x0000    ;SPI Buffer 先清零
        MOV    @SPICCR,#0x0000   	;bit7 set to 0
                                   	;Initialzes the SPI operating flags to the reset condition

        MOV    @SPIFFTX,#0xE040  	;SPI FIFO能重新開始傳送或接收
                                   	;開啟SPI_FIFO的功能
                                   	;重複致能Transmit FIFO operation
                                   	;Transmit FIFO is empty 
                                   	;Clear TXFFINT flag                                  	                                  	
                                   	                                   
      	MOV    @SPIFFRX,#0x204F  	;開啟SPI_FIFO的功能
                                   	;重複致能Receive FIFO operation
									;Receive FIFO is empty
                                   	;Clear RXFFINT flag
                                   
        MOV    @SPIFFCT,#0x0000  	;SPI FIFO transfer defalt is zero       
        MOV    @SPICTL,#0x0006   	;SPI clock phase沒有delay
                                  	;SPI設定為master mode, Enable transmission,disable interrupts              
      	MOV    @SPIBRR,#0x0003   	;設定Baud rate為3,SPICLK為100M/4=25MHZ
   	    MOV    @SPIPRI,#0x0010   	;SPI free Run      	 
        OR     @SPICCR,#0x00DF   	;SPI is ready to transmit or receive the next character
                                   	;SPI loop back mode enable
                                   	;設定SPI為Falling Edge mode,ㄧ次傳送16個字元

;=======================================================================================
;					       	 End SPI setting
;=======================================================================================		
;=======================================================================================
;					        	eCAP setting
;=======================================================================================
;----there are four captures in 28035
;---------------------------------------------
		MOVW	DP,#eCAP1page

		MOV   	@ECEINT,#0x0000		;disable all capture interrupts
		MOV   	@ECCLR,#0xFFFF		;clear all cap intterupt
		TCLR	@ECCTL1,#8			;disable cap1-cap4 register load
		TCLR	@ECCTL2,#4			;make sure the counter is stopped
;---------------------------------------------

		MOV		@TSCTR,#0X0000		;set initial counter is zero (low word)
		MOV		@TSCTR+1,#0X0000	;(high word) 

		MOV		@CTRPHS,#0x0000		;set initial phase is zero (low word)
		MOV		@CTRPHS+1,#0x0000	;(high word)

		MOV		@CAP1,#0X0000		;initial capture is zero (low word)
		MOV		@CAP1+1,#0X0000		;(high word)

		MOV		@ECCTL1,#0X8044		;**** **** **** ****
									;1000 0000 0000 0100
									;---- ---- ---- ---# ==>triggered on a rising edge
									;---- ---- ---- --#- ==>重置計數器在以捕捉時間後
									;---- ---- #### ##-- ==>no set 
									;---- ---# ---- ---- ==>enable cap1-4 load at event time
									;--## ###- ---- ---- ==>event Filter select   
									;##-- ---- ---- ---- ==>TSCTR counter stops immediately by emulation suspend 

		MOV		@ECCTL2,#0X0002		;**** **** **** ****
									;0000 0000 0000 0010
									;---- ---- ---- ---# ==>continuous mode
									;---- ---- ---- -##- ==>warp after capture event 2 in continuous mode
									;---- ---- ---- #--- ==>no effect
									;---- ---- ---# ---- ==>TSCTR free-running
									;---- ---- --#- ---- ==>disable sync option 
									;---- ---- ##-- ---- ==>disable sync out signal
									;---- ---# ---- ---- ==>writing a zero has no effect 
									;---- --#- ---- ---- ==>select eCAP mode!!!!!!
									;---- -#-- ---- ---- ==>output is active high
									;#### #--- ---- ---- ==>reserved

		MOV		@ECEINT,#0X0000		;enable capture event 2 as an interrupt source

		TSET	@ECCTL1,#8			;enable CAP
		TSET	@ECCTL2,#4

;=======================================================================================
;					         END eCAP setting
;=======================================================================================
;====================================================================
;  								 eQEP setting  (encoder)
;====================================================================
	    MOVW	DP,#eQEP1page
		MOV     @QPOSCNT,#0x0000			;先清0
		MOV     @QPOSCNT+1,#0x0000
		MOV     @QPOSINIT,#0					;計數初始值 #20
		MOV     @QPOSINIT+1,#0x0000
		MOV		@QPOSILAT,#0x0000
		MOV     @QPOSMAX,#719	;59F			;最大0x0000FFFF
		MOV     @QPOSMAX+1,#0x0000
;		MOV     @QEPCTL,#0x100A				;Quadrature count mode
		MOV		@QEPCTL,#0x121A
		MOV     @QCAPCTL,#0x0000
		MOV     @QPOSCTL,#0x0000
		MOV     @QEPSTS,#0x0000


		MOVW	DP,#ECAPpage
		MOV		@angle,#0
		MOV		@angle_last,#0
		MOV		@angle_change,#0
		MOV		@angle_gain,#0
;       MOVW	DP,#CurrentAveragepage
;       MOV		@Current_Sensor,#0
;       MOV		@Average,#0
;       MOV		@Move_result_HW,#0
;       MOV		@Move_result_LW,#0
;       MOV		@Move_ave_point,#0
;       MOV		@Current_IU_fb,#0



		EDIS							;寫完有保護之暫存器,打"EDIS"

;=========================================================================
;							End INITIAL_ALL
;=========================================================================


		LRETR
