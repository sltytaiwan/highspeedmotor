;*************************************************************************
; F28035 register definition used in asm 			                     *
; Description:  28035 register definitions                               *
;*************************************************************************

;一個page最多只能放64個Word(16bits) = 32個DWord(32bits)


;-------Flash and OTP Registers-------------------

Flashpage			.set    0A80h/64d
FOPT			  .set		0A80h
FPWR              .set		0A82h
FSTATUS			  .set		0A83h
FSTDBYWAIT		  .set		0A84h
FACTIVEWAIT		  .set		0A85h	
FBANKWAIT		  .set		0A86h
FOTPWAIT		  .set		0A87h

;-------------------------------------------------

;Clocking and System Control Register
CLKpage    		.set	07010h/64d
XCLK        .set    07010h
PLLSTS      .set    07011h
CLKCTL      .set    07012h      
PLLLOCKPRD  .set    07013h      
INTOSC1TRIM .set    07014h      
INTOSC2TRIM .set    07016h      
LOSPCP      .set 	0701Bh
PCLKCR0     .set 	0701Ch
PCLKCR1     .set    0701Dh
LPMCR0      .set    0701Eh
PCLKCR3     .set    07020h       
PLLCR		.set    07021h
SCSR        .set    07022h
WDCNTR 		.set	07023h		;WD Counter reg
WDKEY		.set	07025h		;WD Key reg
WDCR		.set	07029h		;WD Control reg

;-------------------------------------------------

;PIE Interrupt Register			
INTpage			.set	0CE0h/40h
PIECTRL		.set    0CE0h
PIEACK		.set    0CE1h
PIEIER1		.set    0CE2h
PIEIFR1		.set    0CE3h
PIEIER2		.set    0CE4h
PIEIFR2		.set    0CE5h
PIEIER3		.set    0CE6h
PIEIFR3		.set    0CE7h
PIEIER4		.set    0CE8h
PIEIFR4		.set    0CE9h
PIEIER5		.set    0CEAh
PIEIFR5		.set    0CEBh
PIEIER6		.set    0CECh
PIEIFR6		.set    0CEDh
PIEIER7		.set    0CEEh
PIEIFR7		.set    0CEFh
PIEIER8		.set    0CF0h
PIEIFR8		.set    0CF1h
PIEIER9		.set    0CF2h
PIEIFR9		.set    0CF3h
PIEIER10	.set    0CF4h
PIEIFR10	.set    0CF5h
PIEIER11	.set    0CF6h
PIEIFR11	.set    0CF7h
PIEIER12	.set    0CF8h
PIEIFR12	.set    0CF9h

;-------------------------------------------------
;CPU-Timers 0,1,2 Configuration and control Registers
Timerpage			.set	0C00h/64d
TIMER0TIM		.set	0C00h
TIMER0TIMH		.set	0C01h
TIMER0PRD		.set	0C02h
TIMER0PRDH		.set	0C03h
TIMER0TCR		.set	0C04h
TIMER0TPR		.set	0C06h
TIMER0TPRH		.set	0C07h
	
TIMER1TIM		.set	0C08h
TIMER1TIMH		.set	0C09h
TIMER1PRD		.set	0C0Ah
TIMER1PRDH		.set	0C0Bh
TIMER1TCR		.set	0C0Ch
TIMER1TPR		.set	0C0Eh
TIMER1TPRH		.set	0C0Fh

TIMER2TIM		.set	0C10h
TIMER2TIMH		.set	0C11h
TIMER2PRD		.set	0C12h
TIMER2PRDH		.set	0C13h
TIMER2TCR		.set	0C14h
TIMER2TPR		.set	0C16h
TIMER2TPRH		.set	0C17h

;-------------------------------------------------
;-----------EQEP1page---------------
eQEP1page         .set    6B00h/40h 
QPOSCNT           .set    6B00h
QPOSINIT          .set    6B02h
QPOSMAX           .set    6B04h
QPOSCMP           .set    6B06h
QPOSILAT          .set    6B08h
QPOSSLAT          .set    6B0Ah
QPOSLAT           .set    6B0Ch
QUTMR             .set    6B0Eh
QUPRD             .set    6B10h
QWDTMR            .set    6B12h
QWDPRD            .set    6A13h 
QDECCTL           .set    6B14h
QEPCTL            .set    6B15h
QCAPCTL           .set    6B16h     
QPOSCTL           .set    6B17h
QEINT             .set    6B18h
QFLG              .set    6B19h
QCLR              .set    6B1Ah
QFRC              .set    6B1Bh
QEPSTS            .set    6B1Ch
QCTMR             .set    6B1Dh
QCPRD             .set    6B1Eh
QCTMRLAT          .set    6B1Fh
QCPRDLAT          .set    6B20h


;GPIO Control Register
GPIOpage		.set	6F80h/40h  ;GPIOpage
GPACTRL     .set    6F80h      ;GPIOA
GPAQSEL1    .set    6F82h
GPAQSEL2    .set    6F84h
GPAMUX1     .set    6F86h
GPAMUX2     .set    6F88h
GPADIR      .set    6F8Ah
GPAPUD      .set    6F8Ch
GPBCTRL     .set    6F90h      ;GPIOB     
GPBQSEL1    .set    6F92h
GPBMUX1     .set    6F96h
GPBDIR      .set    6F9Ah
GPBPUD      .set    6F9Ch
AIOMUX1     .set    6FB6h      
AIODIR      .set    6FBAh        

GPIOpage2		.set	6fC0h/40h  ;GPIOpage2
GPADAT      .set    6FC0h
GPASET      .set    6FC2h
GPACLEAR    .set    6FC4h
GPATOGGLE   .set    6FC6h
GPBDAT      .set    6FC8h
GPBSET      .set    6FCAh
GPBCLEAR    .set    6FCCh
GPBTOGGLE   .set    6FCEh
AIODAT      .set    6FD8h     
AIOSET      .set    6FDAh      
AIOCLEAR    .set    6FDCh         
AIOTOGGLE   .set    6FDEh      
GPIOXINT1SEL  .set    6FE0h    
GPIOXINT2SEL  .set    6FE1h    
GPIOXINT3SEL  .set    6FE2h    
GPIOLPMSEL    .set    6FE8h    

;-----------------------------------------------

;ePWM Module Control and Status Registers
ePWM1page	   	.set	   6800h/64d	;(ePWM1)
TBCTL1         .set    6800h      
TBSTS1         .set    6801h
TBPHSHR1       .set    6802h
TBPHS1         .set    6803h
TBCTR1         .set    6804h
TBPRD1         .set    6805h
TBPRDHR1       .set    6806h       
CMPCTL1        .set    6807h
CMPAHR1        .set    6808h
CMPA1          .set    6809h
CMPB1          .set    680Ah
AQCTLA1        .set    680Bh
AQCTLB1        .set    680Ch
AQSFRC1        .set    680Dh
AQCSFRC1       .set    680Eh
DBCTL1         .set    680Fh
DBRED1         .set    6810h
DBFED1         .set    6811h
TZSEL1         .set    6812h
TZDCSEL1       .set    6813h        
TZCTL1         .set    6814h
TZEINT1        .set    6815h
TZFLG1         .set    6816h
TZCLR1         .set    6817h
TZFRC1         .set    6818h
ETSEL1         .set    6819h
ETPS1          .set    681Ah
ETFLG1         .set    681Bh
ETCLR1         .set    681Ch
ETFRC1         .set    681Dh
PCCTL1         .set    681Eh
HTCNFG1        .set    6820h
HRPWR1         .set    6821h
HRMSTEP1       .set    6826h
HRPCTL1        .set    6828h
TBPRDHRM1      .set    682Ah
TBPRDM1        .set    682Bh
CMPAHRM1       .set    682Ch
CMPAM1         .set    682Dh
DCTRIPSEL1     .set    6830h
DCACTL1        .set    6831h
DCBCTL1        .set    6832h
DCFCTL1        .set    6833h
DCCAPCTL1      .set    6834h
DCFOFFSET1     .set    6835h
DCFOFFSETCNT1  .set    6836h
DCFWINDOW1     .set    6837h
DCFWINDOWCNT1  .set    6838h
DCCAP1         .set    6839h

ePWM2page	   	.set	   6840h/64d	;(ePWM2)
TBCTL2         .set    6840h      
TBSTS2         .set    6841h
TBPHSHR2       .set    6842h
TBPHS2         .set    6843h
TBCTR2         .set    6844h
TBPRD2         .set    6845h
TBPRDHR2       .set    6846h       
CMPCTL2        .set    6847h
CMPAHR2        .set    6848h
CMPA2          .set    6849h
CMPB2          .set    684Ah
AQCTLA2        .set    684Bh
AQCTLB2        .set    684Ch
AQSFRC2        .set    684Dh
AQCSFRC2       .set    684Eh
DBCTL2         .set    684Fh
DBRED2         .set    6850h
DBFED2         .set    6851h
TZSEL2         .set    6852h
TZDCSEL2       .set    6853h        
TZCTL2         .set    6854h
TZEINT2        .set    6855h
TZFLG2         .set    6856h
TZCLR2         .set    6857h
TZFRC2         .set    6858h
ETSEL2         .set    6859h
ETPS2          .set    685Ah
ETFLG2         .set    685Bh
ETCLR2         .set    685Ch
ETFRC2         .set    685Dh
PCCTL2         .set    685Eh
HTCNFG2        .set    6860h
HRPWR2         .set    6861h
HRMSTEP2       .set    6866h
HRPCTL2        .set    6868h
TBPRDHRM2      .set    686Ah
TBPRDM2        .set    686Bh
CMPAHRM2       .set    686Ch
CMPAM2         .set    686Dh
DCTRIPSEL2     .set    6870h
DCACTL2        .set    6871h
DCBCTL2        .set    6872h
DCFCTL2        .set    6873h
DCCAPCTL2      .set    6874h
DCFOFFSET2     .set    6875h
DCFOFFSETCNT2  .set    6876h
DCFWINDOW2     .set    6877h
DCFWINDOWCNT2  .set    6878h
DCCAP2         .set    6879h

ePWM3page	   	.set	   6880h/64d	;(ePWM3)
TBCTL3         .set    6880h      
TBSTS3         .set    6881h
TBPHSHR3       .set    6882h
TBPHS3         .set    6883h
TBCTR3         .set    6884h
TBPRD3         .set    6885h
TBPRDHR3       .set    6886h       
CMPCTL3        .set    6887h
CMPAHR3        .set    6888h
CMPA3          .set    6889h
CMPB3          .set    688Ah
AQCTLA3        .set    688Bh
AQCTLB3        .set    688Ch
AQSFRC3        .set    688Dh
AQCSFRC3       .set    688Eh
DBCTL3         .set    688Fh
DBRED3         .set    6890h
DBFED3         .set    6891h
TZSEL3         .set    6892h
TZDCSEL3       .set    6893h        
TZCTL3         .set    6894h
TZEINT3        .set    6895h
TZFLG3         .set    6896h
TZCLR3         .set    6897h
TZFRC3         .set    6898h
ETSEL3         .set    6899h
ETPS3          .set    689Ah
ETFLG3         .set    689Bh
ETCLR3         .set    689Ch
ETFRC3         .set    689Dh
PCCTL3         .set    689Eh
HTCNFG3        .set    68A0h
HRPWR3         .set    68A1h
HRMSTEP3       .set    68A6h
HRPCTL3        .set    68A8h
TBPRDHRM3      .set    68AAh
TBPRDM3        .set    68ABh
CMPAHRM3       .set    68ACh
CMPAM3         .set    68ADh
DCTRIPSEL3     .set    68B0h
DCACTL3        .set    68B1h
DCBCTL3        .set    68B2h
DCFCTL3        .set    68B3h
DCCAPCTL3      .set    68B4h
DCFOFFSET3     .set    68B5h
DCFOFFSETCNT3  .set    68B6h
DCFWINDOW3     .set    68B7h
DCFWINDOWCNT3  .set    68B8h
DCCAP3         .set    68B9h

ePWM4page	   	.set	   68C0h/64d	;(ePWM4)
TBCTL4         .set    68C0h      
TBSTS4         .set    68C1h
TBPHSHR4       .set    68C2h
TBPHS4         .set    68C3h
TBCTR4         .set    68C4h
TBPRD4         .set    68C5h
TBPRDHR4       .set    68C6h       
CMPCTL4        .set    68C7h
CMPAHR4        .set    68C8h
CMPA4          .set    68C9h
CMPB4          .set    68CAh
AQCTLA4        .set    68CBh
AQCTLB4        .set    68CCh
AQSFRC4        .set    68CDh
AQCSFRC4       .set    68CEh
DBCTL4         .set    68CFh
DBRED4         .set    68D0h
DBFED4         .set    68D1h
TZSEL4         .set    68D2h
TZDCSEL4       .set    68D3h        
TZCTL4         .set    68D4h
TZEINT4        .set    68D5h
TZFLG4         .set    68D6h
TZCLR4         .set    68D7h
TZFRC4         .set    68D8h
ETSEL4         .set    68D9h
ETPS4          .set    68DAh
ETFLG4         .set    68DBh
ETCLR4         .set    68DCh
ETFRC4         .set    68DDh
PCCTL4         .set    68DEh
HTCNFG4        .set    68E0h
HRPWR4         .set    68E1h
HRMSTEP4       .set    68E6h
HRPCTL4        .set    68E8h
TBPRDHRM4      .set    68EAh
TBPRDM4        .set    68EBh
CMPAHRM4       .set    68ECh
CMPAM4         .set    68EDh
DCTRIPSEL4     .set    68F0h
DCACTL4        .set    68F1h
DCBCTL4        .set    68F2h
DCFCTL4        .set    68F3h
DCCAPCTL4      .set    68F4h
DCFOFFSET4     .set    68F5h
DCFOFFSETCNT4  .set    68F6h
DCFWINDOW4     .set    68F7h
DCFWINDOWCNT4  .set    68F8h
DCCAP4         .set    68F9h

ePWM5page	   	.set	   6900h/64d	;(ePWM5)
TBCTL5         .set    6900h      
TBSTS5         .set    6901h
TBPHSHR5       .set    6902h
TBPHS5         .set    6903h
TBCTR5         .set    6904h
TBPRD5         .set    6905h
TBPRDHR5       .set    6906h       
CMPCTL5        .set    6907h
CMPAHR5        .set    6908h
CMPA5          .set    6909h
CMPB5          .set    690Ah
AQCTLA5        .set    690Bh
AQCTLB5        .set    690Ch
AQSFRC5        .set    690Dh
AQCSFRC5       .set    690Eh
DBCTL5         .set    690Fh
DBRED5         .set    6910h
DBFED5         .set    6911h
TZSEL5         .set    6912h
TZDCSEL5       .set    6913h        
TZCTL5         .set    6914h
TZEINT5        .set    6915h
TZFLG5         .set    6916h
TZCLR5         .set    6917h
TZFRC5         .set    6918h
ETSEL5         .set    6919h
ETPS5          .set    691Ah
ETFLG5         .set    691Bh
ETCLR5         .set    691Ch
ETFRC5         .set    691Dh
PCCTL5         .set    691Eh
HTCNFG5        .set    6920h
HRPWR5         .set    6921h
HRMSTEP5       .set    6926h
HRPCTL5        .set    6928h
TBPRDHRM5      .set    692Ah
TBPRDM5        .set    692Bh
CMPAHRM5       .set    692Ch
CMPAM5         .set    692Dh
DCTRIPSEL5     .set    6930h
DCACTL5        .set    6931h
DCBCTL5        .set    6932h
DCFCTL5        .set    6933h
DCCAPCTL5      .set    6934h
DCFOFFSET5     .set    6935h
DCFOFFSETCNT5  .set    6936h
DCFWINDOW5     .set    6937h
DCFWINDOWCNT5  .set    6938h
DCCAP5         .set    6939h

ePWM6page      	.set	   6940h/64d	;(ePWM6)
TBCTL6         .set    6940h      
TBSTS6         .set    6941h
TBPHSHR6       .set    6942h
TBPHS6         .set    6943h
TBCTR6         .set    6944h
TBPRD6         .set    6945h
TBPRDHR6       .set    6946h       
CMPCTL6        .set    6947h
CMPAHR6        .set    6948h
CMPA6          .set    6949h
CMPB6          .set    694Ah
AQCTLA6        .set    694Bh
AQCTLB6        .set    694Ch
AQSFRC6        .set    694Dh
AQCSFRC6       .set    694Eh
DBCTL6         .set    694Fh
DBRED6         .set    6950h
DBFED6         .set    6951h
TZSEL6         .set    6952h
TZDCSEL6       .set    6953h        
TZCTL6         .set    6954h
TZEINT6        .set    6955h
TZFLG6         .set    6956h
TZCLR6         .set    6957h
TZFRC6         .set    6958h
ETSEL6         .set    6959h
ETPS6          .set    695Ah
ETFLG6         .set    695Bh
ETCLR6         .set    695Ch
ETFRC6         .set    695Dh
PCCTL6         .set    695Eh
HTCNFG6        .set    6960h
HRPWR6         .set    6961h
HRMSTEP6       .set    6966h
HRPCTL6        .set    6968h
TBPRDHRM6      .set    696Ah
TBPRDM6        .set    696Bh
CMPAHRM6       .set    696Ch
CMPAM6         .set    696Dh
DCTRIPSEL6     .set    6970h
DCACTL6        .set    6971h
DCBCTL6        .set    6972h
DCFCTL6        .set    6973h
DCCAPCTL6      .set    6974h
DCFOFFSET6     .set    6975h
DCFOFFSETCNT6  .set    6976h
DCFWINDOW6     .set    6977h
DCFWINDOWCNT6  .set    6978h
DCCAP6         .set    6979h

ePWM7page	    .set	   6980h/64d	;(ePWM7)
TBCTL7         .set    6980h      
TBSTS7         .set    6981h
TBPHSHR7       .set    6982h
TBPHS7         .set    6983h
TBCTR7         .set    6984h
TBPRD7         .set    6985h
TBPRDHR7       .set    6986h       
CMPCTL7        .set    6987h
CMPAHR7        .set    6988h
CMPA7          .set    6989h
CMPB7          .set    698Ah
AQCTLA7        .set    698Bh
AQCTLB7        .set    698Ch
AQSFRC7        .set    698Dh
AQCSFRC7       .set    698Eh
DBCTL7         .set    698Fh
DBRED7         .set    6990h
DBFED7         .set    6991h
TZSEL7         .set    6992h
TZDCSEL7       .set    6993h        
TZCTL7         .set    6994h
TZEINT7        .set    6995h
TZFLG7         .set    6996h
TZCLR7         .set    6997h
TZFRC7         .set    6998h
ETSEL7         .set    6999h
ETPS7          .set    699Ah
ETFLG7         .set    699Bh
ETCLR7         .set    699Ch
ETFRC7         .set    699Dh
PCCTL7         .set    699Eh
HTCNFG7        .set    69A0h
HRPWR7         .set    69A1h
HRMSTEP7       .set    69A6h
HRPCTL7        .set    69A8h
TBPRDHRM7      .set    69AAh
TBPRDM7        .set    69ABh
CMPAHRM7       .set    69ACh
CMPAM7         .set    69ADh
DCTRIPSEL7     .set    69B0h
DCACTL7        .set    69B1h
DCBCTL7        .set    69B2h
DCFCTL7        .set    69B3h
DCCAPCTL7      .set    69B4h
DCFOFFSET7     .set    69B5h
DCFOFFSETCNT7  .set    69B6h
DCFWINDOW7     .set    69B7h
DCFWINDOWCNT7  .set    69B8h
DCCAP7         .set    69B9h

;-----------------------------------------------------

;SPI Module Registers
SPIpage			.set	7040h/64d
SPICCR    	.SET	7040h
SPICTL    	.SET	7041h
SPIST     	.SET	7042h
SPIBRR     	.SET	7044h
SPIRXEMU    .SET	7046h
SPIRXBUF    .SET	7047h
SPITXBUF    .SET	7048h
SPIDAT    	.SET	7049h
SPIFFTX   	.SET	704Ah
SPIFFRX    	.SET	704Bh
SPIFFCT    	.SET	704Ch
SPIPRI    	.SET	704Fh

;-----------------------------------------------------

;ADC Configuration & Control Registers

ADCpage           	.set    7100h/64d
ADCCTL1	     	  .set	  7100h    
ADCINTFLG         .set    7104h
ADCINTFLGCLR      .set    7105h 
ADCINTOVF         .set    7106h 
ADCINTOVFCLR      .set    7107h 
INTSEL1N2         .set    7108h 
INTSEL3N4         .set    7109h 
INTSEL5N6         .set    710Ah 
INTSEL7N8         .set    710Bh 
INTSEL9N10        .set    710Ch 
SOCPRICTL         .set    7110h
ADCSAMPLEMODE     .set    7112h
ADCINTSOCSEL1     .set    7114h 
ADCINTSOCSEL2     .set    7115h 
ADCSOCFLG1        .set    7118h 
ADCSOCFRC1        .set    711Ah
ADCSOCOVF1        .set    711Ch
ADCSOCOVFCLR1     .set    711Eh 
ADCSOC0CTL        .set    7120h
ADCSOC1CTL        .set    7121h
ADCSOC2CTL        .set    7122h
ADCSOC3CTL        .set    7123h
ADCSOC4CTL        .set    7124h
ADCSOC5CTL        .set    7125h
ADCSOC6CTL        .set    7126h
ADCSOC7CTL        .set    7127h
ADCSOC8CTL        .set    7128h
ADCSOC9CTL        .set    7129h
ADCSOC10CTL       .set    712Ah
ADCSOC11CTL       .set    712Bh
ADCSOC12CTL       .set    712Ch
ADCSOC13CTL       .set    712Dh
ADCSOC14CTL       .set    712Eh
ADCSOC15CTL       .set    712Fh
ADCREFTRIM        .set    7140h
ADCOFFTRIM        .set    7141h 
ADCREV            .set    714Fh
;----------ADCRESULpage--------------------------
ADCRESULTpage      	.set    0B00h/64d
ADCRESULT0        .set    0B00h
ADCRESULT1        .set    0B01h
ADCRESULT2        .set    0B02h     
ADCRESULT3        .set    0B03h
ADCRESULT4        .set    0B04h
ADCRESULT5        .set    0B05h
ADCRESULT6        .set    0B06h
ADCRESULT7        .set    0B07h
ADCRESULT8        .set    0B08h
ADCRESULT9        .set    0B09h
ADCRESULT10       .set    0B0Ah
ADCRESULT11       .set    0B0Bh
ADCRESULT12       .set    0B0Ch
ADCRESULT13       .set    0B0Dh
ADCRESULT14       .set    0B0Eh
ADCRESULT15       .set    0B0Fh

;-------Comparator Registers----------------------

COMPpage		  .set   	6400h/64d
COMPCTL1		  .set		6400h		;Comparator1
COMPSTS1		  .set		6402h
DACVAL1			  .set		6406h

COMPCTL2		  .set		6420h		;Comparator2
COMPSTS2		  .set		6422h
DACVAL2			  .set		6426h

COMPCTL3		  .set		6440h		;Comparator3
COMPSTS3		  .set		6442h
DACVAL3			  .set		6446h
;-------eCAP Control and Status Registers---------

eCAP1page			.set	6A00h/64d		

TSCTR        	  .set    6A00h
CTRPHS       	  .set    6A02h
CAP1              .set    6A04h
CAP2              .set    6A06h
CAP3              .set    6A08h
CAP4              .set    6A0Ah
ECCTL1            .set    6A14h
ECCTL2            .set    6A15h
ECEINT            .set    6A16h
ECFLG             .set    6A17h
ECCLR             .set    6A18h
ECFRC             .set    6A19h   

OLpage      	    .set    8840h/64d
COUNTER_ON		  .set    8840h
COUNTER_OFF       .set    8841h
c1_ON		      .set    8842h
c2_OFF    	      .set    8843h
COUNTER_ON2		  .set    8844h
COUNTER_OFF2      .set    8845h
c1_ON2		      .set    8846h
c2_OFF2    	      .set    8847h

