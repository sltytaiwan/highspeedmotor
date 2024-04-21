;* ==================================================================
;*   File Description:
;*      Collection of different macros for other sub-routine using.
;*
;*   Author:
;*
;*   Logfile: Macro.inc
;*
;*   Date:
;*
;*   Revision:   1.0
;*
;*  Revised History:
;*      Initial revision.
;*  The marcos are as followed:
;********************************************************************    
;*****************************************************************************
;Function-Push Minimun Context
;
;Description:
;   1. PUSH ST0
;   2. PUSH ST1
;   3. store ACC
;   4. store P
;   5. store XT
;   6. store XAR0~XAR6
;;Using XAR7 as stack pointer and the stack is located at (0x0420h~0x0432h).
;*****************************************************************************

PUSHALL .macro

        PUSH    ST0                         ;ST0,ST1會擺在SP指的位置
        PUSH    ST1

        MOVL    XAR7,#stack                 ;the first stack address
        NOP     *,ARP7                      ;*=0x0420h

        MOVL    *++,ACC
        MOVL    *++,P
        MOVL    *++,XT
        MOVL    *++,XAR0
        MOVL    *++,XAR1
        MOVL    *++,XAR2
        MOVL    *++,XAR3
        MOVL    *++,XAR4
        MOVL    *++,XAR5
        MOVL    *,XAR6

    .endm

;*****************************************************************************
;Function-Pop Minimun Context
;
;Description:
;   1. POP ST1
;   2. POP ST0
;   3. store XAR6~XAR0
;   4. store XT
;   5. store P
;   6. store ACC
;
;Using XAR7 as stack pointer and the stack is located at (0x0420h~0x0432h). 
;*****************************************************************************

POPALL      .macro

        POP     ST1
        POP     ST0

        MOVW    DP,#Stackpage
        MOVL    XAR7,#stack9                ;the last stack address
        NOP     *,ARP7                      ;*=0x0432h

        MOVL    XAR6,*--
        MOVL    XAR5,*--
        MOVL    XAR4,*--
        MOVL    XAR3,*--
        MOVL    XAR2,*--
        MOVL    XAR1,*--
        MOVL    XAR0,*--

        MOVL    XT,*--
        MOVL    P,*--
        MOVL    ACC,*

    .endm


;*****************************************************************************
;Function-Bit set macro function
;Input:
;   1.var:variable to be accessed
;   2.BIT_NO= Bit no 0~15
;This function need 200ns
;*****************************************************************************
SetBit  .macro  var,BIT_NO      ;Set bit Macro
        MOV   AL,@var  
        OR    AL,#(0001h << BIT_NO)
        MOV   AR0,#var
        MOV   *XAR0,AL
        .endm
;*****************************************************************************
;Function-Bit clear macro function
;
;Input:
;   1.var: variable to be accessed
;   2.BIT_NO= Bit no 0~15
;*****************************************************************************
ClrBit  .macro  var,BIT_NO      ;Clear bit Macro
        MOV   AL,@var
        AND   AL,#(~(0001h << BIT_NO))
        MOV   AR0,#var
        MOV   *XAR0,AL
    .endm




;*****************************************************************************
;Function-SPI1~SPI4 macro function
;   Digital to analog converter macro function (4 set)
;-----------------------------------------------------------------------------
;Input:
;   1.address: variable address
;This function need ?? 
;*****************************************************************************

SPI1   .macro  address

        MOVW    DP,#GPIOpage2
        TSET    @GPACLEAR+1,#10                     ;GPIO26(CS1)清0

        ZAPA                            ;所有內部暫存器清為0

        MOV     AL,address
;        ADD     AL,#0              ;校正DA offset(暫時尚未校正)(-32768~32767)MAPPING(0~4095)
        SUB     AL,#53              ;要記得改喔(D/A 校正)(to PI controller)
;       LSR     AL,#3                   ;要記得改喔(D/A 校正)(to PI controller)
        ADD     AL,#DA_qua              ;將Q15轉回原值 +32767
        LSR     AL,#0X0004              ;先加8000再右移4bit
;       ADD     AL,#0x0800              ;QPOSCNT
        OR      ACC,#0X7000             ;give controlling bits(0x7000 A channel )

        MOVW    DP,#SPIpage
        MOV     @SPITXBUF,ACC           ;start transmit

ReceiveCheck1:

        MOVW    DP,#SPIpage
        TBIT    @SPIFFRX,#8
        B       ReceiveCheck1,NTC       ;利用接收腳來判斷 傳送值是否傳?

        MOVW    DP,#GPIOpage2
        TSET    @GPASET+1,#10           ;set GPIO26(CS1)

        TSET    @GPBCLEAR,#7            ;clear GPIO39 LDAC
        RPT     #5 || NOP
        TSET    @GPBSET,#7              ;set GPIO39  LDAC

        MOVW    DP,#SPIpage
        AND     @SPIFFRX,#0XDFFF        ;清除RX FIFO ,set zero to reset
        OR      @SPIFFRX,#0X2000        ;重新開始 RX FIFO Function
      .endm

SPI2   .macro address

        MOVW    DP,#GPIOpage2
        TSET    @GPACLEAR+1,#10                     ;GPIO26(CS1)清0

        ZAPA

        MOV     AL, address
;        ADD     AL,#735          ;校正DA offset(暫時尚未校正)
        SUB     AL,#25          ;要記得改喔(D/A 校正)(to PI controller)
;       LSR     AL,#3               ;要記得改喔(D/A 校正)(to PI controller)
        ADD     AL,#DA_qua
        LSR     AL,#0X0004
        OR      ACC,#0XF000             ;give controlling bits (0xF000 B channel )

        MOVW    DP,#SPIpage
        MOV     @SPITXBUF,ACC           ;start transmit

ReceiveCheck2:

        MOVW    DP,#SPIpage
        TBIT    @SPIFFRX,#8
        B       ReceiveCheck2,NTC       ;利用接收腳來判斷 傳送值是否傳?

        MOVW    DP,#GPIOpage2
        TSET    @GPASET+1,#10           ;set GPIO26(CS1)

        TSET    @GPBCLEAR,#7            ;clear GPIO39 LDAC
        RPT     #5 || NOP
        TSET    @GPBSET,#7              ;set GPIO39  LDAC

        MOVW    DP,#SPIpage
        AND     @SPIFFRX,#0XDFFF        ;清除RX FIFO ,set zero to reset
        OR      @SPIFFRX,#0X2000        ;重新開始 RX FIFO Function
        .endm



SPI3   .macro  address

        MOVW    DP,#GPIOpage2
        TSET    @GPBCLEAR,#12                       ;GPIO44(CS2)清0

        ZAPA

        MOV     AL, address
;        ADD     AL,#655                  ;校正DA offset(暫時尚未校正)
        SUB     AL,#65          ;要記得改喔(D/A 校正)(to PI controller)
        ADD     AL,#DA_qua
        LSR     AL,#0X0004
        OR      ACC,#0X7000             ;give controlling bits(0x7000 A channel )

        MOVW    DP,#SPIpage
        MOV     @SPITXBUF,ACC           ;start transmit

ReceiveCheck3:

        MOVW    DP,#SPIpage
        TBIT    @SPIFFRX,#8
        B       ReceiveCheck3,NTC       ;利用接收腳來判斷 傳送值是否傳?

        MOVW    DP,#GPIOpage2
        TSET    @GPBSET,#12             ;set GPIO44(CS2)

        TSET    @GPBCLEAR,#7            ;clear GPIO39 LDAC
        RPT     #5 || NOP
        TSET    @GPBSET,#7              ;set GPIO39  LDAC

        MOVW    DP,#SPIpage
        AND     @SPIFFRX,#0XDFFF        ;清除RX FIFO ,set zero to reset
        OR      @SPIFFRX,#0X2000        ;重新開始 RX FIFO Function
      .endm



SPI4   .macro address

        MOVW    DP,#GPIOpage2
        TSET    @GPBCLEAR,#12                       ;GPIO44(CS2)清0

        ZAPA

        MOV     AL, address
;        ADD     AL,#849                  ;校正DA offset(暫時尚未校正)
        SUB     AL,#55
        ADD     AL,#DA_qua
        LSR     AL,#0X0004
    ;   ADD     AL,#0x0800              ;QPOSCNT
        OR      acc,#0XF000             ;give controlling bits (0xF000 B channel )

        MOVW    DP,#SPIpage
        MOV     @SPITXBUF,ACC           ;start transmit

ReceiveCheck4:

        MOVW    DP,#SPIpage
        TBIT    @SPIFFRX,#8
        B       ReceiveCheck4,NTC       ;利用接收腳來判斷 傳送值是否傳?

        MOVW    DP,#GPIOpage2
        TSET    @GPBSET,#12             ;set GPIO44(CS2)

        TSET    @GPBCLEAR,#7            ;clear GPIO39 LDAC
        RPT     #5 || NOP
        TSET    @GPBSET,#7             ;set GPIO39   LDAC

        MOVW    DP,#SPIpage
        AND     @SPIFFRX,#0XDFFF        ;清除RX FIFO ,set zero to reset
        OR      @SPIFFRX,#0X2000        ;重新開始 RX FIFO Function
      .endm



BABYLONIAN .macro address               ;32位元平方根(因為位元數較多因此需要迭代更多次才可以更為準確)

       MOVW     DP,#MATHpage
       MOV      AL, address
       MOV      AH,address+1
       MOVL     @input_sqrt,ACC
       MOV      ACC,#10
       MOVL      @close_value,ACC

;----------- Babylonian  S = [Y + (X / Y)] / 2 ,CPU p.424 ----------------
round1:
        ZAPA
        MOVW    DP,#MATHpage
        MOVB    ACC,#0
        MOVL    P,@input_sqrt             ;第一次逼近 AL = input_sqrt, AH = 0
        RPT     #31                         ;Repeat operation 16 times
        ||SUBCUL    ACC,@close_value            ;X /Y , Conditional subtract with y_value AL=quotient
        MOVL    @yout_1,P                  ;AL=quotient商數  AH=remainder餘數
        MOVL    ACC,@close_value             ;Y
        ADDL    ACC,@yout_1                  ;Y + (X / Y)
        MOV     T,#1
        LSRL    ACC,T                       ;[Y + (X / Y)] / 2  , 2 為根號次方數
        MOVL    @yout_1,ACC

round2:
        MOVW    DP,#MATHpage
        MOVB    ACC,#0
        MOVL    P,@input_sqrt             ;第二次逼近 AL = input_sqrt, AH = 0
        RPT     #31                         ;Repeat operation 16 times
        ||SUBCUL    ACC,@yout_1                 ;X /Y , Conditional subtract with y_value AL=quotient
        MOVL    @yout_2,P                  ;AL=quotient商數  AH=remainder餘數
        MOVL    ACC,@yout_1                  ;Y
        ADDL    ACC,@yout_2                  ;Y + (X / Y)
        MOV     T,#1
        LSRL    ACC,T                       ;[Y + (X / Y)] / 2  , 2 為根號次方數
        MOVL    @yout_2,ACC
round3:
        MOVW    DP,#MATHpage
        MOVB    ACC,#0
        MOVL    P,@input_sqrt             ;第三次逼近 AL = input_sqrt, AH = 0
        RPT     #31                         ;Repeat operation 16 times
        ||SUBCUL    ACC,@yout_2                 ;X /Y , Conditional subtract with y_value AL=quotient
        MOVL    @yout_3,P                  ;AL=quotient商數  AH=remainder餘數
        MOVL    ACC,@yout_2                  ;Y
        ADDL    ACC,@yout_3                  ;Y + (X / Y)
        MOV     T,#1
        LSRL    ACC,T                       ;[Y + (X / Y)] / 2  , 2 為根號次方數
        MOVL    @yout_3,ACC
round4:
        MOVW    DP,#MATHpage
        MOVB    ACC,#0
        MOVL    P,@input_sqrt             ;第四次逼近 AL = input_sqrt, AH = 0
        RPT     #31                         ;Repeat operation 16 times
        ||SUBCUL    ACC,@yout_3                 ;X /Y , Conditional subtract with y_value AL=quotient
        MOVL    @yout_4,P                  ;AL=quotient商數  AH=remainder餘數
        MOVL    ACC,@yout_3                  ;Y
        ADDL    ACC,@yout_4                  ;Y + (X / Y)
        MOV     T,#1
        LSRL    ACC,T                       ;[Y + (X / Y)] / 2  , 2 為根號次方數
        MOVL    @yout_4,ACC
round5:
        MOVW    DP,#MATHpage
        MOVB    ACC,#0
        MOVL    P,@input_sqrt             ;第五次逼近 AL = input_sqrt, AH = 0
        RPT     #31                         ;Repeat operation 16 times
        ||SUBCUL    ACC,@yout_4         ;X /Y , Conditional subtract with y_value AL=quotient
        MOVL     @yout_5,P                  ;AL=quotient商數  AH=remainder餘數
        MOVL    ACC,@yout_4                  ;Y
        ADDL    ACC,@yout_5                  ;Y + (X / Y)
        MOV     T,#1
        LSRL    ACC,T                       ;[Y + (X / Y)] / 2  , 2 為根號次方數
        MOVL    @yout_5,ACC
round6:
        MOVW    DP,#MATHpage
        MOVB    ACC,#0
        MOVL    P,@input_sqrt             ;第六次逼近 AL = input_sqrt, AH = 0
        RPT     #31                         ;Repeat operation 16 times
        ||SUBCUL    ACC,@yout_5         ;X /Y , Conditional subtract with y_value AL=quotient
        MOVL    @yout_6,P                  ;AL=quotient商數  AH=remainder餘數
        MOVL    ACC,@yout_5                  ;Y
        ADDL    ACC,@yout_6                  ;Y + (X / Y)
        MOV     T,#1
        LSRL    ACC,T                       ;[Y + (X / Y)] / 2  , 2 為根號次方數
        MOVL    @yout_6,ACC

        .endm
