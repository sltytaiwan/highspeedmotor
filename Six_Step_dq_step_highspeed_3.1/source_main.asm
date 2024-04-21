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
;*
;*	 This file contains main loop program.
;*
;*	 Author: 	name
;*
;*	 Logfile:   
;*
;*	 Date:	
;*
;*	 Revision:   1.0
;*
;*   Revised History:
;*   Initial revision. 1.0
;*
;*******************************************************************************
; *******************************************************************************
;Resource dispatch for software modules
;	A. Internal Data Memory Planning:
;		0420h~0460h  (M1)---> for stack usd, set AR7 starting at this address 
;      
; 		
; 	B. Index Pointers: AR0~AR7
; 		1. Stack pointer: AR6 @ 060h
;		2. Current loop: AR4, AR5
;		3. Voltage loop: AR2, AR3 
;*******************************************************************************
;!!!!注意程式撰寫長度不可超過1000h=4096 words (請看Debug文件夾.map檔之RAML0~L2)
;*******************************************************************************					
					.include	"PetchVect.inc"
					.include	"Sintable.inc"
					.include    "Arctantable.inc"
					.include	"register.inc"
					.include    "variable.inc"
					.include    "constant.inc"					
					.include    "Macro.inc"


					.global		INITIAL_ALL				  
					.def		_c_int00
					.global		_main

					.text				;executable code and constants

_c_int00:								;program entry point

_main:


;===========================================================================


		SETC INTM,DBGM						;Disable Interrupt 初始化不能跳中斷

;===========================================================================
;
;*****************************PIE table flash to RAM*********************
		MOVW	DP,#INTpage
		MOV   	@PIECTRL,#0x0000  		;ENPIE = 0

		EALLOW

		MOVL XAR7,#0x3F2000 		    ; PIE table start address in FlashC_1
		MOVL XAR6,#0x000D02 		    ; PIE table start address in PIE RAM
		RPT #253						; Repeat next instruction N times RPT #(N-1)
		||PREAD *XAR6++,*XAR7 			; Array2[i] = Array1[i],
										; i++
		EDIS

		MOVW	DP,#INTpage
		MOV   	@PIECTRL,#0x0001  		;ENPIE = 1

;****************************Sintable flash to RAM***********************

		MOV    AL,#3071					; sintable points, over#255 so RPT AL
		MOVL XAR7,#0x3F3000 		    ; sintable start address in FlashC_2
		MOVL XAR6,#0x009000 		    ; sintable start address in RAML3
		RPT  AL						    ; Repeat next instruction N times RPT #(N-1)
		||PREAD *XAR6++,*XAR7 			; Array2[i] = Array1[i],
										; i++
;*************************************************************************

;****************************Arctantable flash to RAM***********************

;		MOV    AL,#1023					; Arctantable points, over#255 so RPT AL
;		MOVL XAR7,#0x3F3800 		    ; Arctantable start address in FLASHC_3
;		MOVL XAR6,#0x009800 		    ; Arctantable start address in RAML2
;		RPT  AL						    ; Repeat next instruction N times RPT #(N-1)
;		||PREAD *XAR6++,*XAR7 			; Array2[i] = Array1[i],
										; i++
;*************************************************************************

		LCR		INITIAL_ALL				;Peripheral control registers intialization

;===========================================================================


;=====================================
;      Registers initialization
;=====================================
		   ZAPA							;ACC=0, P=0, OVC=0
		   MOV		TL,#0				;TL=0

		   MOVL		XAR0,#0
		   MOVL		XAR1,#0
		   MOVL		XAR2,#0
		   MOVL		XAR3,#0
		   MOVL		XAR4,#0
		   MOVL		XAR5,#0
		   MOVL		XAR6,#0
		   MOVL		XAR7,#0

;           MOV   	AR1,#twoINT_counter
		   MOV   	*XAR1,#0

;=============================================

		  EINT			 				;Enable interrupt
      
;-------------------------get initial position------------------
; 		    MOVW  	DP,#GPIOpage2
;			MOV		AL,@GPBDAT
;			AND		AL,#0x0403
;			TBIT	AL,#10
;			SB		W,TC
;			ADD		AL,#0x03FF
;			B		END,UNC
;W:
;			TSET	AL,#2
;			SUB		AL,#0x0001
;END:
;			MOV		AR0,AL
;			MOV		AL,*AR0
;			MOVW  	DP,#VAR16page
;			MOV		@Hallsensor,AL
;			MOVW  	DP,#eQEP1page
;			MOV		@QPOSCNT,AL

;			MOV		@twoINT_counter,#0
;			MOV		@twoINT_counter+1,#0
;-------------------------END of initial position------------------
LOOP:
           NOP							;Autosave comeback
    	   NOP

	;		MOVW	DP,#GPIOpage2
	;		OR      @GPACLEAR,#0x0200		;GPIO09

 		   	MOVW  	DP,#VAR16page
;			CMP		@twoINT_counter,#40		;if  twoINT_counter < 40
		 	B   	LOOP,LT             	; bra to LOOP(2ms)

	;	   	MOVW	DP,#GPIOpage2
	;		OR      @GPASET,#0x0200
	;		RPT		#10
	;		||NOP
	;	   INTR		INT13        			; if  twoINT_counter > 40
		                        			;  enable second loop INT

		   B      LOOP,UNC



;===========================================================================
;開啟中斷時 須將該向量位置取消(如果有其他中斷被開啟會跑來這進入無限迴圈)
;Reset				B		_c_int00,UNC   Reset 是自動的 不用設
PVECTORS_01			B		PVECTORS_01,UNC      
PVECTORS_02			B		PVECTORS_02,UNC
PVECTORS_03			B		PVECTORS_03,UNC
PVECTORS_04			B		PVECTORS_04,UNC
PVECTORS_05			B		PVECTORS_05,UNC
PVECTORS_06			B		PVECTORS_06,UNC
PVECTORS_07			B		PVECTORS_07,UNC
PVECTORS_08			B		PVECTORS_08,UNC
PVECTORS_09			B		PVECTORS_09,UNC
PVECTORS_10			B		PVECTORS_10,UNC
PVECTORS_11			B		PVECTORS_11,UNC
PVECTORS_12			B		PVECTORS_12,UNC
PVECTORS_13			B		PVECTORS_13,UNC ;CPU-Timer1
PVECTORS_14			B		PVECTORS_14,UNC ;CPU-Timer2
PVECTORS_15			B		PVECTORS_15,UNC
PVECTORS_16			B		PVECTORS_16,UNC
PVECTORS_17			B		PVECTORS_17,UNC
PVECTORS_18			B		PVECTORS_18,UNC
PVECTORS_19			B		PVECTORS_19,UNC
PVECTORS_20			B		PVECTORS_20,UNC
PVECTORS_21			B		PVECTORS_21,UNC
PVECTORS_22			B		PVECTORS_22,UNC
PVECTORS_23			B		PVECTORS_23,UNC
PVECTORS_24			B		PVECTORS_24,UNC
PVECTORS_25			B		PVECTORS_25,UNC
PVECTORS_26			B		PVECTORS_26,UNC
PVECTORS_27			B		PVECTORS_27,UNC
PVECTORS_28			B		PVECTORS_28,UNC
PVECTORS_29			B		PVECTORS_29,UNC
PVECTORS_30			B		PVECTORS_30,UNC
PVECTORS_31			B		PVECTORS_31,UNC
PVECTORS_32			B		PVECTORS_32,UNC
PVECTORS_33			B		PVECTORS_33,UNC
PVECTORS_34			B		PVECTORS_34,UNC
PVECTORS_35			B		PVECTORS_35,UNC
PVECTORS_36			B		PVECTORS_36,UNC
PVECTORS_37			B		PVECTORS_37,UNC
PVECTORS_38			B		PVECTORS_38,UNC
PVECTORS_39			B		PVECTORS_39,UNC
PVECTORS_40			B		PVECTORS_40,UNC
PVECTORS_41			B		PVECTORS_41,UNC
PVECTORS_42			B		PVECTORS_42,UNC
PVECTORS_43			B		PVECTORS_43,UNC
PVECTORS_44			B		PVECTORS_44,UNC
PVECTORS_45			B		PVECTORS_45,UNC
PVECTORS_46			B		PVECTORS_46,UNC
PVECTORS_47			B		PVECTORS_47,UNC
PVECTORS_48			B		PVECTORS_48,UNC
;PVECTORS_49	    	B		PVECTORS_49,UNC
PVECTORS_50			B		PVECTORS_50,UNC
PVECTORS_51			B		PVECTORS_51,UNC
PVECTORS_52			B		PVECTORS_52,UNC
;PVECTORS_53			B		PVECTORS_53,UNC
PVECTORS_54			B		PVECTORS_54,UNC
PVECTORS_55			B		PVECTORS_55,UNC
PVECTORS_56			B		PVECTORS_56,UNC
PVECTORS_57			B		PVECTORS_57,UNC
PVECTORS_58			B		PVECTORS_58,UNC
PVECTORS_59			B		PVECTORS_59,UNC
PVECTORS_60			B		PVECTORS_60,UNC
PVECTORS_61			B		PVECTORS_61,UNC
PVECTORS_62			B		PVECTORS_62,UNC
PVECTORS_63			B		PVECTORS_63,UNC
PVECTORS_64			B		PVECTORS_64,UNC
PVECTORS_65			B		PVECTORS_65,UNC
PVECTORS_66			B		PVECTORS_66,UNC
PVECTORS_67			B		PVECTORS_67,UNC
PVECTORS_68			B		PVECTORS_68,UNC
PVECTORS_69			B		PVECTORS_69,UNC
PVECTORS_70			B		PVECTORS_70,UNC
PVECTORS_71			B		PVECTORS_71,UNC
PVECTORS_72			B		PVECTORS_72,UNC
PVECTORS_73			B		PVECTORS_73,UNC
PVECTORS_74			B		PVECTORS_74,UNC
PVECTORS_75			B		PVECTORS_75,UNC
PVECTORS_76			B		PVECTORS_76,UNC
PVECTORS_77			B		PVECTORS_77,UNC
PVECTORS_78			B		PVECTORS_78,UNC
PVECTORS_79			B		PVECTORS_79,UNC
PVECTORS_80			B		PVECTORS_80,UNC
PVECTORS_81			B		PVECTORS_81,UNC
PVECTORS_82			B		PVECTORS_82,UNC
PVECTORS_83			B		PVECTORS_83,UNC
PVECTORS_84			B		PVECTORS_84,UNC
PVECTORS_85			B		PVECTORS_85,UNC
PVECTORS_86			B		PVECTORS_86,UNC
PVECTORS_87			B		PVECTORS_87,UNC
PVECTORS_88			B		PVECTORS_88,UNC
PVECTORS_89			B		PVECTORS_89,UNC
PVECTORS_90			B		PVECTORS_90,UNC
PVECTORS_91			B		PVECTORS_91,UNC
PVECTORS_92			B		PVECTORS_92,UNC
PVECTORS_93			B       PVECTORS_93,UNC
PVECTORS_94			B		PVECTORS_94,UNC
PVECTORS_95			B		PVECTORS_95,UNC
PVECTORS_96			B		PVECTORS_96,UNC
PVECTORS_97			B		PVECTORS_97,UNC
PVECTORS_98			B		PVECTORS_98,UNC
PVECTORS_99			B		PVECTORS_99,UNC
PVECTORS_100		B		PVECTORS_100,UNC
PVECTORS_101		B		PVECTORS_101,UNC
PVECTORS_102		B		PVECTORS_102,UNC
PVECTORS_103		B		PVECTORS_103,UNC
PVECTORS_104		B		PVECTORS_104,UNC
PVECTORS_105		B		PVECTORS_105,UNC
PVECTORS_106		B		PVECTORS_106,UNC
PVECTORS_107		B		PVECTORS_107,UNC
PVECTORS_108		B		PVECTORS_108,UNC
PVECTORS_109		B		PVECTORS_109,UNC
PVECTORS_110		B		PVECTORS_110,UNC
PVECTORS_111		B		PVECTORS_111,UNC
PVECTORS_112		B		PVECTORS_112,UNC
PVECTORS_113		B		PVECTORS_113,UNC
PVECTORS_114		B		PVECTORS_114,UNC
PVECTORS_115		B		PVECTORS_115,UNC
PVECTORS_116		B		PVECTORS_116,UNC
PVECTORS_117		B		PVECTORS_117,UNC
PVECTORS_118		B		PVECTORS_118,UNC
PVECTORS_119		B		PVECTORS_119,UNC
PVECTORS_120		B		PVECTORS_120,UNC
PVECTORS_121		B		PVECTORS_121,UNC
PVECTORS_122		B		PVECTORS_122,UNC
PVECTORS_123		B		PVECTORS_123,UNC
PVECTORS_124		B		PVECTORS_124,UNC
PVECTORS_125		B		PVECTORS_125,UNC
PVECTORS_126		B		PVECTORS_126,UNC
PVECTORS_127		B		PVECTORS_127,UNC
