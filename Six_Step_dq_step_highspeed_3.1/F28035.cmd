/*############################################################################

 FILE:   F280xx_nonBIOS_flash.cmd

 DESCRIPTION:  Linker allocation for all sections. 
############################################################################
 Author: Tim Love
 Release Date: March 2008	
############################################################################*/

/* Define the memory block start/length for the F28035
   PAGE 0 will be used to organize program sections
   PAGE 1 will be used to organize data sections

   Notes:
         Memory blocks on F2803x are uniform (ie same
         physical memory) in both PAGE 0 and PAGE 1.
         That is the same memory region should not be
         defined for both PAGE 0 and PAGE 1.
         Doing so will result in corruption of program
         and/or data.

         L0 memory block is mirrored - that is
         it can be accessed in high memory or low memory.
         For simplicity only one instance is used in this
         linker file.

         Contiguous SARAM memory blocks or flash sectors can be
         be combined if required to create a larger memory block.
*/



MEMORY
{
PAGE 0:    /* Program Memory */
           /* Memory (RAM/FLASH/OTP) blocks can be moved to PAGE1 for data allocation */
//   RAML0       : origin = 0x008000, length = 0x000800     /* on-chip RAM block L0 */
//   RAML1       : origin = 0x008800, length = 0x000400     /* on-chip RAM block L1 */
//   RAML2       : origin = 0x008C00, length = 0x000400     /* on-chip RAM block L2 */

   RAML012     : origin = 0x008000, length = 0x001000     /*RAML0~L2 combine */

   OTP         : origin = 0x3D7800, length = 0x000400     /* on-chip OTP */

   FLASHH      : origin = 0x3E8000, length = 0x002000     /* on-chip FLASH */
   FLASHG      : origin = 0x3EA000, length = 0x002000     /* on-chip FLASH */
   FLASHF      : origin = 0x3EC000, length = 0x002000     /* on-chip FLASH */
   FLASHE      : origin = 0x3EE000, length = 0x002000     /* on-chip FLASH */
   FLASHD      : origin = 0x3F0000, length = 0x002000     /* on-chip FLASH */
//   FLASHC      : origin = 0x3F2000, length = 0x002000     /* on-chip FLASH */
   FLASHB      : origin = 0x3F4000, length = 0x002000     /* on-chip FLASH */
   FLASHA      : origin = 0x3F6000, length = 0x001F80     /* on-chip FLASH */

   CSM_RSVD    : origin = 0x3F7F80, length = 0x000076     /* Part of FLASHA.  Program with all 0x0000 when CSM is in use. */
   BEGIN_FLASH : origin = 0x3F7FF6, length = 0x000002     /* Part of FLASHA.  Used for "boot to Flash" bootloader mode. */
   CSM_PWL_P0  : origin = 0x3F7FF8, length = 0x000008     /* Part of FLASHA.  CSM password locations in FLASHA */

//   IQTABLES    : origin = 0x3FE000, length = 0x000B50     /* IQ Math Tables in Boot ROM */
//   IQTABLES2   : origin = 0x3FEB50, length = 0x00008C     /* IQ Math Tables in Boot ROM */
//   IQTABLES3   : origin = 0x3FEBDC, length = 0x0000AA	    /* IQ Math Tables in Boot ROM */

   ROM         : origin = 0x3FF27C, length = 0x000D44     /* Boot ROM */
   RESET       : origin = 0x3FFFC0, length = 0x000002     /* part of boot ROM  */
   VECTORS     : origin = 0x3FFFC2, length = 0x00003E     /* part of boot ROM  */

PAGE 1:    /* Data Memory */
           /* Memory (RAM/FLASH/OTP) blocks can be moved to PAGE0 for program allocation */
           /* Registers remain on PAGE1*/       
                                                      
	BOOT_RSVD   : origin = 0x000000 length = 0x000040     /* Part of M1, BOOT rom will use this for stack */
   	RAMM0       : origin = 0x000040, length = 0x0003C0    /* on-chip RAM block M0 */
   	RAMM1       : origin = 0x00a000, length = 0x000001    /* on-chip RAM block M1 */
	RAML3		: origin = 0x009000, length = 0x0007FF	  /*Sintable in RAML3*/
	FLASHC_1    : origin = 0x3F2000, length = 0x0007FF	  /*PieVectTable*/
    FLASHC_2	: origin = 0x3F3000, length = 0x001000	  /*Arctantable in flash*/
//FLASHB      : origin = 0x3F4000, length = 0x002000
}




/************************************************************************/
/* Link all user defined sections & allocate sections to memory blocks. */
/************************************************************************/
/*
   Note:
         codestart user defined section in DSP28_CodeStartBranch.asm used to redirect code
                   execution when booting to flash
         ramfuncs  user defined section to store functions that will be copied from Flash into RAM
*/


SECTIONS
{

/*** Code Security Password Locations ***/
   	csmpasswds      : > CSM_PWL_P0,     PAGE = 0		/* Used by file CSMPasswords.asm */
   	csm_rsvd        : > CSM_RSVD,    	PAGE = 0		/* Used by file CSMPasswords.asm */


/*** User Defined Sections ***/
   	codestart       : > BEGIN_FLASH,	PAGE = 0        /* Used by file CodeStartBranch.asm */
   	wddisable		: > FLASHA,		    PAGE = 0		/* Used by file CodeStartBranch.asm */		
  	copysections	: > FLASHA,		    PAGE = 0		/* Used by file SectionCopy.asm */
	PieVectTable	: > FLASHC_1,		PAGE = 1
	Sintable		: > FLASHC_2,		PAGE = 1
	Arctantable		: > RAMM1,			PAGE = 1
/* .reset is a standard section used by the compiler.  It contains the */ 
/* the address of the start of _c_int00 for C Code.   /*
/* When using the boot ROM this section and the CPU vector */
/* table is not needed.  Thus the default type is set here to  */
/* DSECT  */ 
	.reset         	: > RESET,      	PAGE = 0, TYPE = DSECT
	vectors         : > VECTORS,     	PAGE = 0, TYPE = DSECT


/*** Uninitialized Sections ***/

//   	.stack          : > RAMM0,       	PAGE = 1
//   	.ebss           : > RAMM1,       	PAGE = 1
//   	.esysmem        : > RAMM1,       	PAGE = 1


/*** Initialized Sections ***/                                          

	.text			:   LOAD = FLASHA, 		PAGE = 0    /* Load section to Flash */ 
                		RUN  = RAML012,     PAGE = 0    /* Run section from RAM */
                		LOAD_START(_text_loadstart),
                		RUN_START(_text_runstart),
						SIZE(_text_size)

//	.cinit			:	LOAD = FLASHA,	    PAGE = 0	/* Load section to Flash */ 
//                		RUN  = RAML012,  	PAGE = 0    /* Run section from RAM */
//                		LOAD_START(_cinit_loadstart),
//                		RUN_START(_cinit_runstart),
//						SIZE(_cinit_size)

//	.const			:   LOAD = FLASHA,  	PAGE = 0    /* Load section to Flash */
//                		RUN = RAML012, 	PAGE = 0    /* Run section from RAM */
//                		LOAD_START(_const_loadstart),
//                		RUN_START(_const_runstart),
//						SIZE(_const_size)

//	.econst			:   LOAD = FLASHA,  	PAGE = 0   	/* Load section to Flash */ 
//                		RUN = RAML012,  	PAGE = 0    /* Run section from RAM */
//                		LOAD_START(_econst_loadstart),
//                		RUN_START(_econst_runstart),
//						SIZE(_econst_size)

//	.pinit			:   LOAD = FLASHA,  	PAGE = 0    /* Load section to Flash */
//                		RUN = RAML012,   PAGE = 0    /* Run section from RAM */
//                		LOAD_START(_pinit_loadstart),
//                		RUN_START(_pinit_runstart),
//						SIZE(_pinit_size)

//	.switch			:   LOAD = FLASHA,  	PAGE = 0   	/* Load section to Flash */ 
//                		RUN = RAML012,   PAGE = 0    /* Run section from RAM */
//                		LOAD_START(_switch_loadstart),
//                		RUN_START(_switch_runstart),
//						SIZE(_switch_size)
								
}

/*
//===========================================================================
// End of file.
//===========================================================================
*/


