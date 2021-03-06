!     path:      $HeadURL$
!     revision:  $Revision$
!     created:   $Date$  
!     presently: %H%  %T%
!
!  --------------------------------------------------------------------------
! |  Copyright �, Atmospheric and Environmental Research, Inc., 2015         |
! |                                                                          |
! |  All rights reserved. This source code is part of the LBLRTM software    |
! |  and is designed for scientific and research purposes. Atmospheric and   |
! |  Environmental Research, Inc. (AER) grants USER the right to download,   |
! |  install, use and copy this software for scientific and research         |
! |  purposes only. This software may be redistributed as long as this       |
! |  copyright notice is reproduced on any copy made and appropriate         |
! |  acknowledgment is given to AER. This software or any modified version   |
! |  of this software may not be incorporated into proprietary software or   |
! |  commercial software offered for sale without the express written        |
! |  consent of AER.                                                         |
! |                                                                          |
! |  This software is provided as is without any express or implied          |
! |  warranties.                                                             |
! |                       (http://www.rtweb.aer.com/)                        |
!  --------------------------------------------------------------------------
!
      SUBROUTINE LOWTRN 

!                                                                       
!     CC                                                                
!     CC   STRIPPED DOWN VERSION OF LOWTRAN 7 TO RUN AS A SUBROUTINE    
!     CC   TO SUPPLY LBLRTM WITH AEROSOLS,CLOUDS,FOGS AND RAIN          
!     CC                                                                
!_______________________________________________________________________
!                                                                       
!     1 May 2003                                                        
!                                                                       
!     The interface between LBLRTM and LOWTRN has been substantially    
!     modified by S. A. Clough and M. W. Shephard.                      
!                                                                       
!     In general, the overall strategy has been changed to have LOWTRN  
!     provide aerosol, cloud and rain properties on the LBLRTM          
!     vertical grid.                                                    
!                                                                       
!     The implications of this are that the any' user suppled' LOWTRN   
!     information should be provided on a vertical grid consistent with 
!     that of LBLRTM.                                                   
!                                                                       
!     The results have been checked for a number of options: downwelling
!     radiance, upwelling radiance, both at arbitrary zenith angles.    
!                                                                       
!     A known error is that the TANGENT case is NOT working properly.   
!                                                                                                                              
!     ******************************************************************
!     THIS SUBROUTINE IS ONLY USED FOR AEROSOLS AND CLOUDS              
!                                                                       
!     BUILT IN CLOUD AND RAIN MODELS ARE CHOSEN BY ICLD (RECORD 3.1)    
!                                                                       
!     USER DEFINED MODEL CAN BE INPUT BY SETTING IAERSL=7 (RECORD 1.2)  
!                                                                       
!     FOR A MORE COMPLETE EXPLANATION SEE LBLRTM USER INSTRUCTIONS      
!                                                                       
!     ******************************************************************
!     PROGRAM ACTIVATED  BY IAERSL = 1 OR 7  (RECORD 1.2)               
!     RECORD SEQUENCE AS FOLLOWS                                        
!                                                                       
!                                                                       
!     RECORD 3.1   IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,RAINR
!     GNDALT                                                            
!     FORMAT(6I5,5F10.3)                                                
!                                                                       
!     RECORD 3.2  CTHIK,CALT,CEXT,ISEED   (ICLD=18,19, OR 20)           
!     FORMAT(3F10.3,I10)                                                
!                                                                       
!     RECORD 3.3  ZCVSA,ZTVSA,ZINVSA      (IVSA=1)                      
!     FORMAT(3F10.3)                                                    
!                                                                       
!     RECORD 3.4  ML,TITLE                (IAERSL=7)                    
!     FORMAT(I5,18A4)                                                   
!                                                                       
!     RECORD 3.5 IS REPEATED ML TIMES                                   
!                                                                       
!     RECORD 3.5   ZMDL,AHAZE,EQLWCZ,RRATZ,IHAZ1,                       
!     ICLD1,IVUL1,ISEA1,ICHR1                                           
!     FORMAT (4F10.3,5I5)                                               
!                                                                       
!     RECORDS 3.6.1 - 3.6.3 READ IN THE USER DEFINED CLOUD EXTINCTION   
!     AND ABSORPTION        (IHAZE=7 OR ICLD=11)                        
!                                                                       
!     RECORD 3.6.1   (IREG(I),I=1,4)                                    
!     FORMAT (4I5)                                                      
!                                                                       
!     RECORD 3.6.2   AWCCON(N),TITLE(N)                                 
!     FORMAT (E10.3,18A4)                                               
!                                                                       
!     RECORD 3.6.3 (VX(I),EXTC(N,I),ABSC(N,I),ASYM(N,I),I=1,47)         
!     FORMAT (3(F6.2,2F7.5,F6.4)) ** 16 RECORDS **                      
!                                                                       
!                                                                       
!     ******************************************************************
!                                                                       
!     MODEL IS READ IN LBLATM                                           
!     M1, M2, AND M3 ARE SET DEPENDING ON MODEL                         
!                                                                       
!     ******************************************************************
!                                                                       
!     RECORD 3.1    IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,    
!     RAINRT,GNDALT                                                     
!                                                                       
!     FORMAT(6I5,5F10.3)                                                
!                                                                       
!     IHAZE SELECTS THE TYPE OF EXTINCTION AND A DEFAULT                
!     METEROLOGIACL RANGE FOR THE BOUNDARY-LAYER AEROSOL MODEL          
!     (0 TO 2KM ALTITUDE)                                               
!     IF VIS IS ALSO SPECIFIED ON RECORD 3.1, IT WILL OVERRIDE          
!     THE DEFAULT IHAZE VALUE                                           
!                                                                       
!     IHAZE=0  NO AEROSOL ATTENUATION INCLUDED IN CALCULATION.          
!     =1  RURAL EXTINCTION, (23 KM VIS. DEFAULT PROFILE)                
!     =2  RURAL EXTINCTION, (5 KM VIS. DEFAULT PROFILE)                 
!     =3  NAVY MARITIME EXTINCTION,SETS OWN VIS.                        
!     =4  MARITIME EXTINCTION, 23 KM VIS.    (LOWTRAN 5 MODEL)          
!     =5  URBAN EXTINCTION, (5 KM VIS DEFAULT PROFILE)                  
!     =6  TROPOSPHERIC EXTINCTION, (50 KM VIS. DEFAULT PROFILE)         
!     =7  USER DEFINED  AEROSOL EXTINCTION COEFFICIENTS                 
!     RECORDS 3.6.1 TO 3.6.3                                            
!     =8  FOG1 (ADVECTION FOG) EXTINCTION, 0.2 KM VIS.                  
!     =9  FOG2 (RADIATION FOG) EXTINCTION, 0.5 KM VIS.                  
!     =10 DESERT EXTINCTION SETS OWN VISIBILITY FROM WIND SPEED         
!                                                                       
!                                                                       
!     ISEASN SELECTS THE SEASONAL DEPENDENCE OF THE PROFILES            
!     FOR BOTH THE TROPOSPHERIC (2 TO 10 KM) AND                        
!     STRATOSPHERIC (10 TO 30 KM) AEROSOLS.                             
!                                                                       
!     ISEASN=0 DEFAULTS TO SEASON OF MODEL                              
!     (MODEL 0,1,2,4,6,7) SUMMER                                        
!     (MODEL 3,5)         WINTER                                        
!     =1 SPRING-SUMMER                                                  
!     =2 FALL - WINTER                                                  
!                                                                       
!     IVULCN SELECTS BOTH THE PROFILE AND EXTINCTION TYPE               
!     FOR THE STRATOSPHERIC AEROSOLS AND DETERMINES TRANSITION          
!     PROFILES ABOVE THE STRATOSPHERE TO 100 KM.                        
!                                                                       
!     IVULCN=0 DEFAULT TO STRATOSPHERIC BACKGROUND                      
!     =1 STRATOSPHERIC BACKGROUND                                       
!     =2 AGED VOLCANIC EXTINCTION/MODERATE VOLCANIC PROFILE             
!     =3 FRESH VOLCANIC EXTINCTION/HIGH VOLCANIC PROFILE                
!     =4 AGED VOLCANIC EXTINCTION/HIGH VOLCANIC PROFILE                 
!     =5 FRESH VOLCANIC EXTINCTION/MODERATE VOLCANIC PROFILE            
!     =6 BACKGROUND STRATOSPHERIC EXTINCTION                            
!     /MODERATE VOLCANIC PROFILE                                        
!     =7 BACKGROUND STRATOSPHERIC EXTINCTION                            
!     /HIGH VOLCANIC PROFILE                                            
!     =8 FRESH VOLCANIC EXTINCTION/EXTREME VOLCANIC PROFILE             
!                                                                       
!     ICSTL IS THE AIR MASS CHARACTER(1 TO 10) ONLY USED WITH           
!     NAVY MARITIME MODEL (IHAZE=3), DEFAULT VALUE IS 3.                
!                                                                       
!     ICSTL = 1 OPEN OCEAN                                              
!     .                                                                 
!     .                                                                 
!     .                                                                 
!     10 STRONG CONTINENTAL INFLUENCE                                   
!                                                                       
!     ICLD DETERMINES THE INCLUSION OF CIRRUS CLOUD ATTENUATION         
!     AND GIVES A CHOICE OF FIVE CLOUD MODELS AND 5 RAIN MODELS         
!                                                                       
!     ICLD FOR CLOUD AND OR RAIN                                        
!                                                                       
!     ICLD = 0  NO CLOUDS OR RAIN                                       
!     = 1  CUMULUS CLOUD; BASE .66 KM; TOP 3.0 KM                       
!     = 2  ALTOSTRATUS CLOUD; BASE 2.4 KM; TOP 3.0 KM                   
!     = 3  STRATUS CLOUD; BASE .33 KM; TOP 1.0 KM                       
!     = 4  STRATUS/STRATO CU; BASE .66 KM; TOP 2.0 KM                   
!     = 5  NIMBOSTRATUS CLOUD; BASE .16 KM; TOP .66 KM                  
!     = 6  2.0 MM/HR DRIZZLE (MODELED WITH CLOUD 3)                     
!     RAIN 2.0 MM/HR AT 0.0 KM TO 0.22 MM/HR AT 1.5 KM                  
!     = 7  5.0 MM/HR LIGHT RAIN (MODELED WITH CLOUD 5)                  
!     RAIN 5.0 MM/HR AT 0.0 KM TO 0.2 MM/HR AT 2.0 KM                   
!     = 8  12.5 MM/HR MODERATE RAIN (MODELED WITH CLOUD 5)              
!     RAIN 12.5 MM.HR AT 0.0 KM TO 0.2 MM/HR AT 2.0 KM                  
!     = 9  25.0 MM/HR HEAVY RAIN (MODELED WITH CLOUD 1)                 
!     RAIN 25.0 MM/HR AT 0.0 KM TO 0.2 MM/HR AT 3.0 KM                  
!     =10  75.0 MM/HR EXTREME RAIN (MODELED WITH CLOUD 1)               
!     RAIN 75.0 MM/HR AT 0.0 KM TO 0.2 MM/HR AT 3.5 KM                  
!     =11  READ IN USER DEFINED CLOUD EXTINCTION AND ABSORPTION         
!     =18  STANDARD CIRRUS MODEL                                        
!     =19  SUB-VISUAL CIRRUS MODEL                                      
!     =20  NOAA CIRRUS MODEL (LOWTRAN 6 MODEL)                          
!                                                                       
!     IVSA DETERMINES THE USE OF THE ARMY VERTICAL STRUCTURE            
!     ALGORITHM FOR AEROSOLS IN THE BOUNDARY LAYER.                     
!                                                                       
!     IVSA=0   NOT USED                                                 
!     =1   VERTICAL STRUCTURE ALGORITHM                                 
!                                                                       
!     VIS =    METEROLOGICAL RANGE (KM) (WHEN SPECIFIED, SUPERSEDES     
!     DEFAULT VALUE SET BY IHAZE)                                       
!                                                                       
!     WSS =    CURRENT WIND SPEED (M/S).                                
!     ONLY FOR (IHAZE=3 OR IHAZE=10)                                    
!     WHH =    24 HOUR AVERAGE WIND SPEED (M/S).  ONLY WITH (IHAZE=3)   
!                                                                       
!     RAINRT = RAIN RATE (MM/HR).             DEFAULT VALUE IS ZERO.    
!     GNDALT = ALTITUDE OF SURFACE RELATIVE TO SEA LEVEL (KM)           
!     USED TO MODIFY AEROSOL PROFILES BELOW 6 KM ALTITUDE               
!                                                                       
!     ******************************************************************
!                                                                       
!     OPTIONAL INPUT RECORDS AFTER RECORD 3.1                           
!     SELECTED BY PARAMETERS ICLD, IVSA, AND IHAZE ON RECORD 3.1        
!                                                                       
!     ******************************************************************
!                                                                       
!     RECORD 3.2     CTHIK,CALT,CEXT,ISEED        (ICLD=18,19,20)       
!     FORMAT(3F10.3,I10)                                                
!     INPUT RECORD FOR CIRRUS ALTITUDE PROFILE                          
!     SUBROUTINE WHEN ICLD = 18,19,20                                   
!                                                                       
!     CHTIK    = CIRRUS THICKNESS (KM)                                  
!     0  USE THICKNESS STATISTICS                                       
!     > 0 USER DEFINED THICKNESS                                        
!                                                                       
!     CALT     = CIRRUS BASE ALTITUDE (KM)                              
!     0 USE CALCULATED VALUE                                            
!     > 0 USER DEFINED BASE ALTITUDE                                    
!                                                                       
!     CEXT     = EXTINCTION COEFFIENT (KM-1) AT 0.55 MICRONS            
!     0 USE 0.14 * CTHIK                                                
!     > 0 USER DEFINED EXTINCTION COEFFICIENT                           
!                                                                       
!     ISEED    = RANDOM NUMBER INITIALIZATION FLAG.                     
!     0 USE DEFAULT MEAN VALUES FOR CIRRUS                              
!     > 0 INITIAL VALUE OF SEED FOR RANDM FUNCTION                      
!                                                                       
!                                                                       
!     ******************************************************************
!                                                                       
!     RECORD 3.3               ZCVSA,ZTVSA,ZINVSA     (IVSA=1)          
!     FORMAT(3F10.3)                                                    
!     INPUT RECORD FOR ARMY VERTICAL STRUCTURE                          
!     ALGORITHM SUBROUTINE WHEN IVSA=1.                                 
!                                                                       
!     ZCVSA = CLOUD CEILING HEIGHT (KM) =0 UNKNOWN HEIGHT               
!                                                                       
!     ZCVSA > 0  KNOWN CLOUD CEILING                                    
!     ZCVSA = 0  UNKNOWN CLOUD CEILING HEIGHT                           
!     PROGRAM CALCULATES CLOUD HEIGHT                                   
!     ZCVSA < 0  NO CLOUD CEILING                                       
!                                                                       
!     ZTVSA = THICKNESS OF CLOUD OR FOG (KM),                           
!     THICKNESS = 0 DEFAULTS TO 0.2 KM                                  
!                                                                       
!     ZINVSA= HEIGHT OF THE INVERSION (KM)                              
!     = 0   DEFAULTS TO 2 KM (0.2 KM FOR FOG)                           
!     < 0   NO INVERSION LAYER                                          
!                                                                       
!     ******************************************************************
!                                                                       
!     RECORD 3.4     ML,IRD1,IRD2,TITLE       (IAERSL=7)  READ IN LOWTRA
!     FORMAT(3I5,18A4)                                                  
!     ADDITIONAL AEROSOL PROFILE                                        
!                                                                       
!     ML     = NUMBER OF AEROSOL PROFILES LEVELS TO BE INSERTED         
!     (MAXIMUM OF 34)                                                   
!                                                                       
!     TITLE  = IDENTIFICATION OF NEW MODEL AEROSOL PROFILE              
!                                                                       
!                                                                       
!     RECORD 3.5 IS REPEATED ML TIMES                                   
!                                                                       
!     RECORD 3.5                                READ IN AERNSM          
!     ZMDL,AHAZE,EQLWCZ,RRATZ,IHAZ1,ICLD1,IVUL1,ISEA1,ICHR1             
!     (IAERSL=7)                                                        
!     FORMAT(4F10.3,5I5)                                                
!                                                                       
!     ZMDL   = ALTITUDE OF LAYER BOUNDARY (KM)                          
!                                                                       
!     AHAZE  = AEROSOL VISIBLE EXTINCTION COFF (KM-1)                   
!                                                                       
!     EQLWCZ = LIQUID WATER CONTENT (GM M-3) AT ALT ZMDL                
!                                                                       
!     **** EITHER AHAZE OR EQLWCZ IS ALLOWED ****                       
!                                                                       
!     FOR THE AEROSOL, CLOUD OR FOG MODELS                              
!                                                                       
!     RRATZ  = RAIN RATE (MM/HR) AT ALT ZMDL                            
!                                                                       
!     IHAZ1 AEROSOL MODEL USED FOR SPECTRAL DEPENDENCE OF EXTINCTION    
!                                                                       
!     IVUL1 STRATOSPHERIC AERSOL MODEL USED FOR SPECTRAL DEPENDENCE     
!     OF EXT AT ZMDL                                                    
!                                                                       
!     ICLD1 CLOUD MODEL USED FOR SPECTRAL DEPENDENCE OF EXT AT ZMDL     
!                                                                       
!     ONLY ONE OF IHAZ1, ICLD1 OR IVUL1 IS ALLOWED                      
!     IHAZ1 NE 0 OTHERS IGNORED                                         
!     IHAZ1 EQ 0 AND ICLD1 NE 0 USE ICLD1                               
!                                                                       
!     IF AHAZE AND EQLWCZ ARE BOTH ZERO, DEFAULT PROFILE LOADED         
!     ACCORDING TO IHAZ1,ICLD1,IVUL1                                    
!                                                                       
!     ISEA1 =  AEROSOL SEASON CONTROL FOR THE ALTITUDE ZMDL             
!                                                                       
!     ICHR1 =  INDICATES A BOUNDARY CHANGE BETWEEN TWO OR MORE ADJACENT 
!     USER DEFINED AEROSOL OR CLOUD REGIONS AT ALTITUDE ZMDL            
!     (REQUIRED FOR IHAZE=7 OR ICLD=11)                                 
!     NOTE: DEFAULTS TO 0 FOR IHAZE.NE.7 OR ICLD.NE.11                  
!                                                                       
!     = 0   NO BOUNDARY CHANGE                                          
!                                                                       
!     = 1   SIGNIFIES BOUNDARY CHANGE                                   
!                                                                       
!     ******************************************************************
!                                                                       
!     RECORDS 3.6.1 - 3.6.3 READS IN THE USER DEFINED CLOUD EXTINCTION  
!     AND ABSORPTION        (IHAZE=7 OR ICLD=11)                        
!                                                                       
!     RECORD 3.6.1   (IREG(I),I=1,4)                                    
!     FORMAT (4I5)                                                      
!                                                                       
!     IREG   = SPECIFIES WHICH OF THE FOUR ALTITUDE REGIONS A USER      
!     DEFINED AEROSOL OR CLOUD MODEL WILL USE                           
!                                                                       
!     RECORD 3.6.2   AWCCON(N),TITLE(N)                                 
!     FORMAT (E10.3,18A4)                                               
!                                                                       
!     AWCCON(N) = CONVERSION FACTOR FROM EQUIVALENT LIQUID WATER        
!     CONTENT (GM/M3) TO EXTINCTION COEFFICIENT (KM-1).                 
!                                                                       
!     TITLE(N)  = FOR AN AEROSOL OR CLOUD REGION                        
!                                                                       
!     RECORD 3.6.3 (VX(I),EXTC(N,I),ABSC(N,I),ASYM(N,I),I=1,47)         
!     FORMAT (3(F6.2,2F7.5,F6.4)) ** 16 RECORDS **                      
!                                                                       
!     VX(I)    = WAVELENGTH OF AEROSOL COEFFICIENT                      
!     (NOT USED BY PROGRAM BUT CORRESPONDING TO                         
!     WAVELENGTHS DEFINED IN ARRAY VX2                                  
!     IN SUBROUTINE EXTDA)                                              
!                                                                       
!     EXTC(N,I) = AEROSOL EXTINCTION COEFFICIENT                        
!     ABSC(N,I) = AEROSOL ABSORPTION COEFFICIENT                        
!     ASYM(N,I) = AEROSOL ASYMMETRY FACTOR                              
!                                                                       
!     *** REPEAT RECORDS 3.6.2 - 3.6.3 N TIMES, WHERE                   
!     *** N = IREG(1)+IREG(2)+IREG(3)+IREG(4) FROM RECORD 3.6.1         
!                                                                       
!     ******************************************************************
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUM NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX2(47),AWCCON(5) 
!                                                                       
      CHARACTER*8      HMOD 
!                                                                       
      COMMON /CMN/ HMOD(3),ZM(MXZMD),PF(MXZMD),TF(MXZMD),RFNDXM(MXZMD), &
     &          ZP(IM2),PP(IM2),TP(IM2),RFNDXP(IM2),SP(IM2),PPSUM(IM2), &
     &          TPSUM(IM2),RHOPSM(IM2),IMLOW,WGM(MXZMD),DENW(MXZMD),    &
     &          AMTP(MXMOL,MXPDIM)                                      
!                                                                       
      COMMON /PATHD/ PBAR(MXLAY),TBAR(MXLAY),AMOUNT(MXMOL,MXLAY),       &
     &               WN2L(MXLAY),DVL(MXLAY),WTOTL(MXLAY),ALBL(MXLAY),   &
     &               ADBL(MXLAY),AVBL(MXLAY),H2OSL(MXLAY),IPATH(MXLAY), &
     &               ITYL(MXLAY),SECNTA(MXLAY),HT1,HT2,ALTZ(0:MXLAY),   &
     &               PZ(0:MXLAY),TZ(0:MXLAY)                            
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                                &
     &                     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4      
      COMMON /LCRD1/ MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRNT,TBOUND,SALB 
      COMMON /ADRIVE/LOWFLG,IREAD,MODELF,ITYPEF,NOZERO,NOPRNF,          &
     & H1F,H2F,ANGLEF,RANGEF,BETAF,LENF,VL1,VL2,RO,IPUNCH,VBAR,         &
     & HMINF,PHIF,IERRF,HSPACE                                          
      COMMON /LCRD2/ IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,   &
     &    RAINRT                                                        
      COMMON /LCRD2A/ CTHIK,CALT,CEXT 
      COMMON /LCRD2D/ IREG(4),ALTB(4),IREGC(4) 
      COMMON /LCRD3/ H1,H2,ANGLE,RANGE,BETA,RE,LEN 
      COMMON /LCRD4/ V1,V2,DV 
      REAL*8           V1P,V2P 
      CHARACTER*8       XID,       HMOLID,      YID 
      Real*8                SECANT,       XALTZ 
      COMMON /CVRLOW/ HNAMLOW,HVRLOW 
      COMMON /FILHDR/ XID(10),SECANT,PAVE,TAVE,HMOLID(60),XALTZ(4),     &
     &     WK(60),PZL,PZU,TZL,TZU,WN2   ,DVP,V1P,V2P,TBOUNF,EMISIV,     &
     &     FSCDID(17),NMOL,LAYER,YI1,YID(10) ,LSTWDF                    
      COMMON /CNSTNS/ PI,CA,DEG,GCAIR,BIGNUM,BIGEXP 
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,N_LVL,JH1 
      COMMON/MODEL/ ZMDL(MXZMD),PM(MXZMD),TM(MXZMD),                    &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
      COMMON /MART/ RHH 
      COMMON /MDLZ/ HMDLZ(10) 
      COMMON /ZVSALY/ ZVSA(10),RHVSA(10),AHVSA(10),IHVSA(10) 
      CHARACTER*20 HHAZE,HSEASN,HVULCN,HMET,HMODEL,BLANK 
      CHARACTER*24 HTRRAD 
      CHARACTER*18 HNAMLOW,HVRLOW 
      COMMON /TITL/ HHAZE(16),HSEASN(2),HVULCN(8),BLANK,                &
     & HMET(2),HMODEL(8),HTRRAD(4)                                      
      COMMON /VSBD/ VSB(10) 
!                                                                       
!     ISEED IS INTEGER*4                                                
!                                                                       
      INTEGER*4 ISEED 
!                                                                       
!     **   IRD, IPR, AND IPU ARE UNIT NUMBERS FOR INPUT, OUTPUT, AND    
!     **   TAPE7 RESPECTIVELY                                           
!                                                                       
      EQUIVALENCE (FSCDID(5),IEMS),(FSCDID(4),IAERSL) 
!                                                                       
      DATA MAXATM,MAXGEO   /3020, 3014/ 
!                                                                       
      DATA I_1/1/, I_10/10/ 
!                                                                       
!%%%%%%%%                                                               
!                                                                       
!     iemsct has been set to 1 here to force the reults from lowtrn     
!     to always be available on the lblrtm vertical grid.               
!                                                                       
!     IEMSCT = IEMS                                                     
      IEMSCT = 1 
!                                                                       
!                                                                       
!     ASSIGN CVS VERSION NUMBER TO MODULE                               
!                                                                       
      HVRLOW = '$Revision$' 
!                                                                       
!     ALTITUDE PARAMETERS                                               
!                                                                       
!     ZMDL  COMMON/MODEL/  THE ALTITUDES USED IN LOWTRAN                
!     ZCVSA,ZTVSA,ZIVSA RECORD 3.3 LOWTRAN FOR VSA INPUT                
!     ZM  BLANK COMMON  RETURNS ALTITUDES FOR LBLRTM USE                
!     ZP  BLANK COMMON NOT USED BY LOWTRAN                              
!     ZVSA  NINE ALTITUDES GEN BY VSA ROUTINE                           
!                                                                       
      PI = 2.0*ASIN(1.0) 
      CA = PI/180. 
      DEG = 1.0/CA 
!                                                                       
!     **   GCAIR IS THE GAS CONSTANT FOR AIR IN UNITS OF MB/(GM CM-3 K) 
!                                                                       
      GCAIR = 2.87053E+3 
!                                                                       
!     **   BIGNUM AND BIGEXP ARE THE LARGEST NUMBER AND THE LARGEST ARGU
!     **   EXP ALLOWED AND ARE MACHINE DEPENDENT. THE NUMBERS USED HERE 
!     **   FOR A TYPICAL 32 BIT-WORD COMPUTER.                          
!                                                                       
      BIGNUM = 1.0E38 
      BIGEXP = 87.0 
      KMAX = 16 
!                                                                       
!     **   NL IS THE NUMBER OF BOUNDARIES IN THE STANDARD MODELS 1 TO 6 
!     **   BOUNDARY    (AT 99999 KM) IS NO LONGER USED                  
!                                                                       
      NL = 50 
      JH1 = 0 
      IKLO = 1 
!                                                                       
!     CC                                                                
!     CC    FIX DV TO 5.0 FOR LBLRTM USAGE                              
!     CC                                                                
!                                                                       
      DV = 5.0 
!                                                                       
!     CC                                                                
!     CC    OBTAIN PARAMETERS IN COMMON/LCRD3/AND/LCRD4/ FROM COMMON ADR
!     CC    WHICH PASSED THEM FROM LBLATM                               
!     CC                                                                
!                                                                       
      DO 10 II = 1, 4 
         IREG(II) = 0 
   10 END DO 
      DO 20 I = 1, 5 
         DO 18 J = 1, 40 
            ABSC(I,J) = 0. 
            EXTC(I,J) = 0. 
            ASYM(I,J) = 0. 
   18    CONTINUE 
   20 END DO 
!                                                                       
!     CC                                                                
!     CC    OBTAIN ITYPE FROM LBLRTM CONTROL AS STORED IN COMMON ADRIVE 
!     CC                                                                
!                                                                       
      ITYPE = ITYPEF 
!                                                                       
      H1 = H1F 
      NOPRNT = NOPRNF 
      MODEL = MODELF 
      MDELS = MODEL 
      M1 = MODEL 
      M2 = MODEL 
      M3 = MODEL 
!                                                                       
!                                                                       
      IF (ITYPE.EQ.1) THEN 
         LENF = 0 
      ENDIF 
!                                                                       
      IF (MODEL.EQ.0) THEN 
         M1 = 0 
         M2 = 0 
         M3 = 0 
      ENDIF 
      M = MODEL 
      IM = 0 
!                                                                       
      IF (IAERSL.EQ.7) THEN 
         M = 7 
         IM = 1 
      ENDIF 
!                                                                       
      H2 = H2F 
      ANGLE = ANGLEF 
      RANGE = RANGEF 
      BETA = BETAF 
      LEN = LENF 
      V1 = VL1 
      V2 = VL2 
      RE = RO 
!                                                                       
!     CC                                                                
!     CC    SET TBOUND AND SALB TO ZERO NOT UTILIZED HERE               
!     CC                                                                
!                                                                       
      TBOUND = 0.0 
      SALB = 0.0 
!                                                                       
!     **   START CALCULATION                                            
!                                                                       
!                                                                       
      WRITE (IPR,900) 
!                                                                       
!     OBTAIN MODEL PARAMETERS FROM LBLRTM  (     RECORD 2.1)            
!                                                                       
      JPRT = 0 
      WRITE (IPR,905) MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRNT 
      NPR = NOPRNT 
!                                                                       
!     **   RECORD 3.1 AEROSOL MODEL                                     
!                                                                       
      READ (IRD,910) IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,   &
     &   RAINRT,GNDALT                                                  
      IF (IHAZE.EQ.3) THEN 
         IF (V1.LT.250.0.OR.V2.LT.250.0) IHAZE = 4 
         IF (IHAZE.EQ.4) WRITE (IPR,930) 
      ENDIF 
      WRITE (IPR,920) IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,  &
     &   RAINRT,GNDALT                                                  
      IF (GNDALT.GT.0.) WRITE (IPR,915) GNDALT 
      IF (GNDALT.GE.6.0) THEN 
         WRITE (IPR,925) GNDALT 
         GNDALT = 0. 
      ENDIF 
!                                                                       
      IF (VIS.LE.0.0.AND.IHAZE.GT.0) VIS = VSB(IHAZE) 
      RHH = 0. 
      CALL YDIAR (IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,RAINRT&
     &   ,GNDALT,YID)                                                   
      IF (MODEL.EQ.0) GO TO 30 
      IF ((MODEL.EQ.3.OR.MODEL.EQ.5).AND.ISEASN.EQ.0) ISEASN = 2 
!                                                                       
!     **WARNING** IF V1 OR V2 LESS THEN 250 CM-1 PROGRAM WILL NOT       
!     PERMIT USE OF NAVY MARITIME (IHAZE=3) SWITCHES TO IHAZE=4         
!                                                                       
      ICH(1) = IHAZE 
      ICH(2) = 6 
      ICH(3) = 9+IVULCN 
   30 IF (RAINRT.EQ.0) GO TO 40 
      WRITE (IPR,935) RAINRT 
   40 ICH(4) = 18 
      ICH(1) = MAX(ICH(1),I_1) 
      ICH(3) = MAX(ICH(3),I_10) 
      IF (ICLD.GE.1.AND.ICLD.LE.11) THEN 
         ICH(4) = ICH(3) 
         ICH(3) = ICH(2) 
         ICH(2) = ICLD 
      ENDIF 
!                                                                       
!     CC   IF(ICH(4).LE.9) ICH(4)=10                                    
!                                                                       
      IFLGA = 0 
      IFLGT = 0 
      CTHIK = -99. 
      CALT = -99. 
      ISEED = -99 
      IF (ICLD.LT.18) GO TO 50 
!                                                                       
!     **   RECORD 3.2 CIRRUS CLOUDS                                     
!                                                                       
      READ (IRD,940) CTHIK,CALT,CEXT,ISEED 
      WRITE (IPR,945) CTHIK,CALT,CEXT,ISEED 
   50 CONTINUE 
!                                                                       
!     **   RECORD 3.3 VERTICAL STRUCTURE ALGORITHM                      
!                                                                       
      ZCVSA = -99. 
      ZTVSA = -99. 
      ZINVSA = -99. 
!                                                                       
      IF (IVSA.ne.0) then 
         READ (IRD,950) ZCVSA,ZTVSA,ZINVSA 
         WRITE (IPR,955) ZCVSA,ZTVSA,ZINVSA 
!                                                                       
         CALL VSA (IHAZE,VIS,ZCVSA,ZTVSA,ZINVSA,ZVSA,RHVSA,AHVSA,IHVSA) 
!                                                                       
!     END OF VSA MODEL SET-UP                                           
!                                                                       
         endif 
!                                                                       
         IF (MODEL.NE.0) ML = NL 
!                                                                       
         IF (MDELS.NE.0) HMODEL(7) = HMODEL(MDELS) 
         IF (MDELS.EQ.0) HMODEL(7) = HMODEL(8) 
!                                                                       
!                                                                       
         IF (IAERSL.EQ.7) THEN 
!                                                                       
!        **   RECORD 3.4 USER SUPPLIED AEROSOL AND CLOUD PROFILE        
!                                                                       
            READ (IRD,960) ML,HMODEL(7) 
            WRITE (IPR,965) ML,HMODEL(7) 
         ENDIF 
         M = 7 
         CALL AERNSM (IAERSL,JPRT,GNDALT) 
         IF (ICLD.LT.20) GO TO 70 
!                                                                       
!     SET UP CIRRUS MODEL                                               
!                                                                       
         IF (CTHIK.NE.0) IFLGT = 1 
         IF (CALT.NE.0) IFLGA = 1 
         IF (ISEED.EQ.0) IFLGT = 2 
         IF (ISEED.EQ.0) IFLGA = 2 
         CALL CIRRUS (CTHIK,CALT,ISEED,CPROB,MDELS) 
         WRITE (IPR,970) 
         IF (IFLGT.EQ.0) WRITE (IPR,975) CTHIK 
         IF (IFLGT.EQ.1) WRITE (IPR,980) CTHIK 
         IF (IFLGT.EQ.2) WRITE (IPR,985) CTHIK 
         IF (IFLGA.EQ.0) WRITE (IPR,990) CALT 
         IF (IFLGA.EQ.1) WRITE (IPR,995) CALT 
         IF (IFLGA.EQ.2) WRITE (IPR,1000) CALT 
         WRITE (IPR,1005) CPROB 
!                                                                       
!     END OF CIRRUS MODEL SET UP                                        
!                                                                       
   70    CONTINUE 
!                                                                       
!     **   RECORD 3.6                                                   
!                                                                       
         IF ((IHAZE.EQ.7).OR.(ICLD.EQ.11)) THEN 
!                                                                       
!        **   RECORDS 3.6.1 - 3.6.3                                     
!        **           USER SUPPLIED AEROSOL EXTINCTION AND ABSORPTION   
!                                                                       
            CALL RDEXA 
         ENDIF 
!                                                                       
!     WRITE(IPR,1313)H1,H2,ANGLE,RANGE,BETA,RO,LEN                      
!     1313 FORMAT('0 RECORD 2.2 ****',6F10.3,I5)                        
!                                                                       
         GO TO 80 
!                                                                       
!     **   RO IS THE RADIUS OF THE EARTH                                
!                                                                       
   80    RE = 6371.23 
         IF (MODEL.EQ.1) RE = 6378.39 
         IF (MODEL.EQ.4) RE = 6356.91 
         IF (MODEL.EQ.5) RE = 6356.91 
         IF (RO.GT.0.0) RE = RO 
!                                                                       
!                                                                       
!     IPH   =-99                                                        
!     IDAY  =-99                                                        
!     ISOURC=-99                                                        
!                                                                       
!     ANGLEM=-99.                                                       
!                                                                       
         WRITE (IPR,1010) HTRRAD(IEMSCT+1) 
         MDEL = MODEL 
         IF (MDEL.EQ.0) MDEL = 8 
         MM1 = MDEL 
         MM2 = MDEL 
         MM3 = MDEL 
         IF (M1.NE.0) MM1 = M1 
         IF (M2.NE.0) MM2 = M2 
         IF (M3.NE.0) MM3 = M3 
         WRITE (IPR,1015) MM1,HMODEL(MM1),MM2,HMODEL(MM2),MM3,HMODEL(   &
         MM3)                                                           
!                                                                       
         IF (JPRT.EQ.0) GO TO 90 
         IF (ISEASN.EQ.0) ISEASN = 1 
         IVULCN = MAX(IVULCN,I_1) 
         IHVUL = IVULCN+10 
         IF (IVULCN.EQ.6) IHVUL = 11 
         IF (IVULCN.EQ.7) IHVUL = 11 
         IF (IVULCN.EQ.8) IHVUL = 13 
         IHMET = 1 
         IF (IVULCN.GT.1) IHMET = 2 
         IF (IHAZE.EQ.0) GO TO 90 
         WRITE (IPR,1020) HHAZE(IHAZE),VIS,HHAZE(6),HHAZE(6),HSEASN(    &
         ISEASN) ,HHAZE(IHVUL),HVULCN(IVULCN),HSEASN(ISEASN),HHAZE(15), &
         HMET(IHMET)                                                    
   90    CONTINUE 
         IF (ITYPE.EQ.1) WRITE (IPR,1025) H1,RANGE 
         IF (ITYPE.EQ.2) WRITE (IPR,1030) H1,H2,ANGLE,RANGE,BETA,LEN 
         IF (ITYPE.EQ.3) WRITE (IPR,1035) H1,H2,ANGLE 
!                                                                       
!                                                                       
!                                                                       
!                                                                       
         ALAM1 = 1.0E38 
         IF (V1.GT.0.) ALAM1 = 10000./V1 
         ALAM2 = 10000./V2 
         DV = MAX(DV,5.) 
         DV = REAL(INT(DV/5+0.1))*5.0 
         IF (ALAM1.GT.999999.) ALAM1 = 999999. 
         WRITE (IPR,1040) V1,ALAM1,V2,ALAM2,DV 
!                                                                       
!     **   LOAD ATMOSPHERIC PROFILE INTO /MODEL/                        
!                                                                       
         CALL STDMDL 
!                                                                       
         IF (IEMSCT.EQ.1) CALL NEWMDL (MAXATM) 
!                                                                       
!     **   TRACE PATH THROUGH THE ATMOSPHERE AND CALCULATE ABSORBER AMOU
!                                                                       
         ISSGEO = 0 
         MODEL = MDELS 
         CALL GEO (IERROR,BENDNG,MAXGEO) 
!                                                                       
!                                                                       
!     FINAL SET OF LAYERS                                               
!                                                                       
!                                                                       
!                                                                       
         IF (IERROR.GT.0) GO TO 100 
!                                                                       
!                                                                       
!                                                                       
!     **   LOAD AEROSOL EXTINCTION AND ABSORPTION COEFFICIENTS          
!                                                                       
!     CC                                                                
!     CC    LOAD EXTINCTIONS AND ABSORPTIONS FOR 0.2-200.0 UM (1-46)    
!     CC                                                                
!     CC   CALL EXABIN                                                  
!     CC                                                                
!     CC    CALCULATE EQUIVALENT LIQUID WATER CONSTANTS                 
!     CC                                                                
!                                                                       
         CALL EQULWC 
!                                                                       
!                                                                       
!                                                                       
         CALL TRANS 
!                                                                       
  100    CONTINUE 
!                                                                       
         LOWFLG = 0 
         RETURN 
!                                                                       
  900 FORMAT('1',20X,'***** LOWTRAN 7 (MODIFIED)*****') 
  905 FORMAT('0 RECORD 2.1 ****',8I5       ) 
  910 FORMAT(6I5,5F10.3) 
  915 FORMAT('0','  GNDALT =',F10.2) 
  920 FORMAT('0 RECORD 3.1 ****',6I5,5F10.3) 
  925 FORMAT('0 GNDALT GT 6.0 RESET TO ZERO, GNDALT WAS',F10.3) 
  930 FORMAT('0**WARNING** NAVY MODEL IS NOT USEABLE BELOW 250CM-1'/    &
     & 10X,' PROGRAM WILL SWITCH TO IHAZE=4 LOWTRAN 5 MARITIME'//)      
  935 FORMAT('0 RAIN MODEL CALLED, RAIN RATE = ',F9.2,' MM/HR') 
  940 FORMAT(3F10.3,I10) 
  945 FORMAT('0 RECORD 2A *****',3F10.3,I10) 
  950 FORMAT(3F10.3) 
  955 FORMAT('0 RECORD 3.3 ****',3F10.3) 
  960 FORMAT(I5,18A4) 
  965 FORMAT('0 RECORD 3.4 ****',I5,18A4) 
  970 FORMAT(15X,'CIRRUS ATTENUATION INCLUDED') 
  975 FORMAT(15X,'CIRRUS ATTENUTION STATISTICALLY DETERMENED TO BE',    &
     & F10.3,'KM')                                                      
  980 FORMAT(15X,'CIRRUS THICKNESS USER DETERMINED TO BE',F10.3,'KM') 
  985 FORMAT(15X,'CIRRUS THICKNESS DEFAULTED TO MEAN VALUE OF    ',     &
     & F10.3,'KM')                                                      
  990 FORMAT(15X,'CIRRUS BASE ALTITUDE STATISCALLY DETERMINED TO BE',   &
     & F10.3,' KM')                                                     
  995 FORMAT(15X,'CIRRUS BASE ALTITUDE USER DETERMINED TO BE',          &
     & F10.3,' KM')                                                     
 1000 FORMAT(15X,'CIRRUS BASE ALTITUDE DEFAULTED TO MEAN VALUE OF',     &
     & F10.3,'KM')                                                      
 1005 FORMAT(15X,'PROBABILTY OF CLOUD OCCURRING IS',F7.1,               &
     & ' PERCENT')                                                      
 1010 FORMAT('0 PROGRAM WILL COMPUTE ',A24) 
 1015 FORMAT('0 ATMOSPHERIC MODEL',/,                                   &
     & 10X,'TEMPERATURE = ',I4,5X,A20,/,                                &
     & 10X,'WATER VAPOR = ',I4,5X,A20,/,                                &
     & 10X,'OZONE       = ',I4,5X,A20)                                  
 1020 FORMAT('0 AEROSOL MODEL',/,10X,'REGIME',                          &
     & T35,'AEROSOL TYPE',T60,'PROFILE',T85,'SEASON',/,/,               &
     & 10X,'BOUNDARY LAYER (0-2 KM)',T35,A20,T60,F5.1,                  &
     & ' KM VIS AT SEA LEVEL',/,10X,'TROPOSPHERE  (2-10KM)',T35,        &
     & A20,T60,A20,T85,A20,/,10X,'STRATOSPHERE (10-30KM)',              &
     & T35,A20,T60,A20,T85,A20,/,10X,'UPPER ATMOS (30-100KM)',          &
     & T35,A20,T60,A20)                                                 
 1025 FORMAT('0 HORIZONTAL PATH',/,10X,'ALTITUDE = ',F10.3,' KM',/,     &
     &    10X,'RANGE    = ',F10.3,' KM')                                
 1030 FORMAT('0 SLANT PATH, H1 TO H2',/,                                &
     &    10X,'H1    = ',F10.3,' KM',/,10X,'H2    = ',F10.3,' KM',/,    &
     &    10X,'ANGLE = ',F10.3,' DEG',/,10X,'RANGE = ',F10.3,' KM',/,   &
     &    10X,'BETA  = ',F10.3,' DEG',/,10X,'LEN   = ',I6)              
 1035 FORMAT('0 SLANT PATH TO SPACE',/,                                 &
     &    10X, 'H1    = ',F10.3,' KM',/,10X,'HMIN  = ',F10.3,' KM',/,   &
     &    10X,'ANGLE = ',F10.3,' DEG')                                  
 1040 FORMAT('0 FREQUENCY RANGE '/,10X,' V1 = ',F12.1,' CM-1  (',       &
     & F10.2,' MICROMETERS)',/,10X,' V2 = ',F12.1,' CM-1  (',F10.2,     &
     & ' MICROMETERS)',/10X,' DV = ',F12.1,' CM-1')                     
!                                                                       
      END                                           
      SUBROUTINE AERNSM(IAERSL,JPRT,GNDALT) 
                                                                        
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
      PARAMETER (NCASE=15) 
                                                                        
      CHARACTER*1 JCHAR 
!                                                                       
!     ******************************************************************
!     DEFINES ALTITUDE DEPENDENT VARIABLES Z,P,T,WH,WO AND HAZE         
!     CLD RAIN  CLDTYPE                                                 
!     LOADS HAZE INTO APPROPRATE LOCATION                               
!     ******************************************************************
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELFAS(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX2(47),AWCCON(5) 
!                                                                       
      CHARACTER*8      HMOD 
!                                                                       
      COMMON /CMN/ HMOD(3),ZM(MXZMD),PF(MXZMD),TF(MXZMD),RFNDXM(MXZMD), &
     &          ZP(IM2),PP(IM2),TP(IM2),RFNDXP(IM2),SP(IM2),PPSUM(IM2), &
     &          TPSUM(IM2),RHOPSM(IM2),IMMAX,WGM(MXZMD),DENW(MXZMD),    &
     &          AMTP(MXMOL,MXPDIM)                                      
!                                                                       
      COMMON /PATHD/ PBAR(MXLAY),TBAR(MXLAY),AMOUNT(MXMOL,MXLAY),       &
     &               WN2L(MXLAY),DVL(MXLAY),WTOTL(MXLAY),ALBL(MXLAY),   &
     &               ADBL(MXLAY),AVBL(MXLAY),H2OSL(MXLAY),IPATH(MXLAY), &
     &               ITYL(MXLAY),SECNTA(MXLAY),HT1,HT2,ALTZ(0:MXLAY),   &
     &               PZ(0:MXLAY),TZ(0:MXLAY)                            
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                                &
     &                     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4      
      COMMON /LCRD1/ MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRNT,TBOUND,SALB 
      COMMON /CARD1B/ JUNIT(NCASE),WMOL(NCASE),WAIR1,JLOW 
      COMMON /LCRD2/ IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,   &
     &    RAINRT                                                        
      COMMON /LCRD2A/ CTHIK,CALT,CEXT 
      COMMON /LCRD2D/ IREG(4),ALTB(4),IREGC(4) 
      COMMON /LCRD3/ H1,H2,ANGLE,RANGE,BETA,RE,LEN 
      COMMON /LCRD4/ V1,V2,DV 
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,N_LVL,JH1 
      COMMON /MART/ RHH 
!     COMMON /MDATA/ ZDA(MXZMD),P(MXZMD),T(MXZMD),WH(MXZMD),WO(MXZMD),  
!    *     HMIX(MXZMD),CLD(MXZMD,7),RR(MXZMD,7)                         
      COMMON /MDATA/                              WH(MXZMD),WO(MXZMD),  &
     &                 CLD(MXZMD,7),RR(MXZMD,7)                         
      COMMON /MDATA2/ZDA(MXZMD),P(MXZMD),T(MXZMD) 
                                                                        
      COMMON /MODEL/ ZMDL(MXZMD),PMM(MXZMD),TMM(MXZMD),                 &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
      COMMON /ZVSALY/ ZVSA(10),RHVSA(10),AHVSA(10),IHVSA(10) 
      COMMON /MDLZ/HMDLZ(10) 
      COMMON /TITL/ HZ(16),SEASN(2),VULCN(8),BLANK,                     &
     &     HMET(2),HMODEL(8),HTRRAD(4)                                  
      DIMENSION ITY1(MXZMD+1),IH1(MXZMD),IS1(MXZMD),IVL1(MXZMD),        &
     &     ZGN(MXZMD)                                                   
      DIMENSION INEW(MXZMD),RELHUM(MXZMD),ZSTF(MXZMD),CLDTOP(10),       &
     &     AHAST(MXZMD)                                                 
!                                                                       
      CHARACTER*20 HZ,SEASN,VULCN,HMET,HMODEL,BLANK 
      CHARACTER*24 HTRRAD 
      CHARACTER*20 AHOL1,AHOL2,AHOL3,AHLVSA,AHUS 
      CHARACTER*20 AHAHOL(NCASE),HHOL 
      DIMENSION  JCHAR(NCASE) 
!                                                                       
      DATA I_1/1/, I_12/12/, I_32/32/, I_34/34/ 
!                                                                       
      DATA AHLVSA/'VSA DEFINED         '/ 
      DATA  AHUS /'USER DEFINED        '/ 
      DATA AHAHOL/                                                      &
     & 'CUMULUS             ',                                          &
     & 'ALTOSTRATUS         ',                                          &
     & 'STRATUS             ',                                          &
     & 'STRATUS STRATO CUM  ',                                          &
     & 'NIMBOSTRATUS        ',                                          &
     & 'DRIZZLE 2.0 MM/HR   ',                                          &
     & 'LT RAIN 5.0 MM/HR   ',                                          &
     & 'MOD RAIN 12.5 MM/HR ',                                          &
     & 'HEAVY RAIN 25 MM/HR ',                                          &
     & 'EXTREME RAIN 75MM/HR',                                          &
     & 'USER ATMOSPHERE     ',                                          &
     & 'USER RAIN NO CLOUD  ',                                          &
     & 'CIRRUS CLOUD        ',                                          &
     & 'SUB-VISUAL CIRRUS   ',                                          &
     & 'NOAA CIRRUS MODEL   '/                                          
      DATA CLDTOP / 3.,3.,1.,2.,.66,1.,.66,.66,3.,3./ 
!                                                                       
!     F(A) IS SATURATED WATER WAPOR DENSITY AT TEMP T,A=TZERO/T         
!                                                                       
      F(A) = EXP(18.9766-14.9595*A-2.43882*A*A)*A 
!                                                                       
!     ZM ORIGINALLY IS LBLRTM ALT                                       
!                                                                       
!     ZGN IS EFFICTIVE ALTITUDE ARRAY                                   
!     ZDA COMMON   /MDATA/  ALTITUDE OF THE PRESSURES,TEMP IN MDATA     
!     ZMDL COMMON /MODEL/ FINAL ALTITUDE FOR LOWTRAN                    
!     ZSTF  STORAGE OF ORIGINAL LBLRTM ALTITUDES                        
!     ZK  EFFECTIVE ALTITUDE FOR CLOUD                                  
!     ZSC EFFECTIVE ALTITUDE FOR AEROSOLS                               
!     ZP  BLANK COMMON  UNUSED                                          
!     ZM,PM,TM  ARE FOR LBLRTM USE BETWEEN 0 AND 6 KM                   
!                                                                       
      IREGC(1) = 0 
      IREGC(2) = 0 
      IREGC(3) = 0 
      IREGC(4) = 0 
      ICL = 0 
      MLSV = ML 
      DO 10 I = 0, n_lvl-1 
         ZSTF(I) = ALTZ(I) 
   10 END DO 
      ICONV = 1 
      IRD0 = 1 
      ICLDL = ICLD 
      IF ((MODEL.GT.0.).AND.(MODEL.LT.7)) IRD0 = 0 
      IF ((IRD0.EQ.1).AND.(IVSA.EQ.1)) THEN 
         IRD0 = 0 
         IRD1 = 0 
!                                                                       
!        C         IRD2 = 0                                             
!        C         IF(IAERSL .EQ. 7) IRD2 = 1                           
!                                                                       
         ICONV = 0 
         ML = ML+10-JLOW 
         IF (ML.GT.34) WRITE (IPR,905) 
         ML = MIN(ML,I_34) 
         ZVSA(10) = ZVSA(9)+0.01 
         RHVSA(10) = 0. 
         AHVSA(10) = 0. 
         IHVSA(10) = 0 
         IF (MODEL.EQ.0) WRITE (IPR,900) 
         IF (MODEL.EQ.0) STOP 
      ENDIF 
      ICL = 0 
      IDSR = 0 
      IF (ICLD.EQ.18.OR.ICLD.EQ.19) THEN 
         CALL CIRR18 
                                                                        
!     cloud is between cl1 and cld2                                     
!     transition regions cloudo>cloud1 and cloud2>cloud3                
                                                                        
         cld1 = calt 
         cld2 = calt + cthik 
                                                                        
         cld0 = cld1 - 0.010 
         IF (CLD0.LE.0.) CLD0 = 0. 
         cld3 = cld2 + 0.010 
!                                                                       
      ENDIF 
!                                                                       
      CALL FLAYZ                                                        &
     &   (ML,MODEL,ICLD,IAERSL,ZMDL,altz,n_lvl,GNDALT,IVSA,IEMSCT)      
!                                                                       
      DO 20 I = 1, ML 
         JPRT = 1 
         IF (MODEL.EQ.0.OR.MODEL.EQ.7) JPRT = 0 
         IF (IAERSL.EQ.7) JPRT = 0 
         IF (ICLD.GT.0) JPRT = 0 
         IF (IVSA.GT.0) JPRT = 0 
         HAZEC(I) = 0.0 
   20 END DO 
      DO 30 II = 1, 4 
         ALTB(II) = 0. 
   30 END DO 
      T0 = 273.15 
      IC1 = 1 
      N = 7 
      IF (ML.EQ.1) M = 0 
      IVULCN = MAX(IVULCN,I_1) 
      ISEASN = MAX(ISEASN,I_1) 
      IF (JPRT.EQ.0) THEN 
         WRITE (IPR,950) MODEL,ICLD 
      ENDIF 
      IF (IAERSL.EQ.7) WRITE (IPR,910) 
!                                                                       
      KLO = 1 
!                                                                       
      IF (IAERSL.NE.7) THEN 
         DO 50 I = 1, ML 
            INEW(I) = KLO-1 
            IF (ZMDL(I).LT.ALTZ(KLO)) GO TO 50 
   40       INEW(I) = KLO 
            KLO = KLO+1 
            IF (KLO.GT.MLSV) GO TO 50 
            IF (ZMDL(I).GT.ALTZ(KLO)) GO TO 40 
   50    CONTINUE 
      ENDIF 
!                                                                       
!                                                                       
      DO 220 K = 1, ML 
!                                                                       
!        LOOP OVER LAYERS                                               
!                                                                       
         RH = 0. 
         WH(K) = 0. 
         WO(K) = 0. 
         DP = 0 
         IHAZ1 = 0 
         ICLD1 = 0 
         ISEA1 = 0 
         IVUL1 = 0 
         VIS1 = 0. 
         AHAZE = 0. 
         EQLWCZ = 0. 
         RRATZ = 0. 
         ICHR = 0 
         DO 60 KM = 1, 15 
            JCHAR(KM) = ' ' 
            WMOL(KM) = 0. 
   60    CONTINUE 
         DO 70 KM = 1, 15 
            JUNIT(KM) = JOU(JCHAR(KM)) 
   70    CONTINUE 
         JUNIT(1) = M1 
         JUNIT(2) = M1 
         JUNIT(3) = M2 
         JUNIT(4) = 6 
         JUNIT(5) = M3 
         JUNIT(6) = 6 
         JUNIT(7) = 6 
         JUNIT(8) = 6 
         JUNIT(9) = 6 
         JUNIT(10) = 6 
         JUNIT(11) = 6 
         JUNIT(12) = 6 
         JUNIT(13) = 6 
         JUNIT(14) = 6 
         JUNIT(15) = 6 
!                                                                       
!                                                                       
!        AHAZE =  AEROSOL VISIBLE EXTINCTION COFF (KM-1)                
!        AT A WAVELENGTH OF 0.55 MICROMETERS                            
!                                                                       
!        EQLWCZ=LIQUID WATER CONTENT (GM M-3) AT ALT Z                  
!        FOR AEROSOL, CLOUD OR FOG MODELS                               
!                                                                       
!        RRATZ=RAIN RATE (MM/HR) AT ALT Z                               
!                                                                       
!        IHAZ1 AEROSOL MODEL USED FOR SPECTRAL DEPENDENCE OF EXTINCTION 
!                                                                       
!        IVUL1 STRATOSPHERIC AERSOL MODEL USED FOR SPECTRAL DEPENDENCE  
!        OF EXT AT Z                                                    
!                                                                       
!        ICLD1 CLOUD MODEL USED FOR SPECTRAL DEPENDENCE OF EXT AT Z     
!                                                                       
!        ONLY ONE OF IHAZ1,ICLD1  OR IVUL1 IS ALLOWED                   
!        IHAZ1 NE 0 OTHERS IGNORED                                      
!        IHAZ1 EQ 0 AND ICLD1 NE 0 USE ICLD1                            
!                                                                       
!        IF AHAZE AND EQLWCZ ARE BOUTH ZERO                             
!        DEFAULT PROFILE ARE LOADED FROM IHAZ1,ICLD1,IVUL1              
!        ISEA1 = AERSOL SEASON CONTROL FOR ALTITUDE Z                   
!                                                                       
!        C    IF(IRD2 .EQ. 1) THEN                                      
!                                                                       
         IF (IAERSL.EQ.7) THEN 
            READ (IRD,915) ZMDL(K),AHAZE,EQLWCZ,RRATZ,IHAZ1,ICLD1,      &
            IVUL1,ISEA1,ICHR                                            
            WRITE (IPR,915) ZMDL(K),AHAZE,EQLWCZ,RRATZ,IHAZ1,ICLD1,     &
            IVUL1,ISEA1,ICHR                                            
!                                                                       
            IF (ICHR.EQ.1) THEN 
               IF (IHAZ1.EQ.0) THEN 
                  IF (ICLD1.NE.11) ICHR = 0 
               ELSE 
                  IF (IHAZ1.NE.7) ICHR = 0 
               ENDIF 
            ENDIF 
            INEW(K) = KLO-1 
            IF (ZMDL(K).LT.ALTZ(KLO)) GO TO 90 
   80       INEW(K) = KLO 
            KLO = KLO+1 
            IF (KLO.GT.MLSV) GO TO 90 
            IF (ZMDL(K).GT.ALTZ(KLO)) GO TO 80 
   90       CONTINUE 
         ENDIF 
         IF (IAERSL.NE.7) THEN 
            RRATZ = RAINRT 
            IF (ZMDL(K).GT.6.) RRATZ = 0. 
         ENDIF 
!                                                                       
!                                                                       
!        GNDALT NOT ZERO                                                
!                                                                       
         ZSC = ZMDL(K) 
         IF ((GNDALT.GT.0.).AND.(ZMDL(K).LT.6.0)) THEN 
            ASC = 6./(6.-GNDALT) 
            CON = -ASC*GNDALT 
            ZSC = ASC*ZMDL(K)+CON 
            IF (ZSC.LT.0.) ZSC = 0. 
         ENDIF 
         ZGN(K) = ZSC 
!                                                                       
!                                                                       
         ICLDS = ICLD1 
         IF (ICLD1.EQ.0) ICLD1 = ICLD 
         ICLDL = ICLD1 
         IF (ICLD1.GT.11) ICLD1 = 0 
         IF (IHAZ1.NE.0) IVUL1 = 0 
         IF (IHAZ1.NE.0) ICLD1 = 0 
         IF (ICLD1.NE.0) IVUL1 = 0 
         IF ((AHAZE.NE.0.).OR.(EQLWCZ.NE.0.)) GO TO 100 
         IF (RRATZ.NE.0.) GO TO 100 
         IF ((IVSA.EQ.1).AND.(ICLD1.EQ.0)) THEN 
            CALL LAYVSA (K,RH,AHAZE,IHAZ1,ZSTF) 
         ELSE 
            CALL LAYCLD (K,EQLWCZ,RRATZ,IAERSL,ICLD1,GNDALT,RAINRT) 
            IF (ICLD1.LT.1) GO TO 100 
            IF (ICLD1.GT.10) GO TO 100 
            IF (ZMDL(K).GT.CLDTOP(ICLD1)+GNDALT) THEN 
               RRATZ = 0. 
            ENDIF 
         ENDIF 
  100    CONTINUE 
         ICLDC = ICLD 
         IF (ICLDS.NE.0) ICLDC = ICLDS 
         IF (ICLDC.EQ.18.OR.ICLDC.EQ.19) THEN 
            DENSTY(16,K) = 0. 
            IF (ZMDL(K).GE.CLD1.AND.ZMDL(K).LE.CLD2) DENSTY(16,K) =     &
            CEXT                                                        
         ENDIF 
         CLDAMT(K) = EQLWCZ 
         IF (ICLDS.EQ.0.AND.CLDAMT(K).EQ.0.) ICLD1 = 0 
         RRAMT(K) = RRATZ 
         IF (MODEL.NE.0) THEN 
            IF (EQLWCZ.GT.0.0) RH = 100.0 
            IF (RRATZ.GT.0.0) RH = 100.0 
         ENDIF 
         AHAST(K) = AHAZE 
!                                                                       
!        IHAZ1  IS IHAZE FOR THIS LAYER                                 
!        ISEA1 IS ISEASN FOR THIS LAYER                                 
!        IVUL1 IS IVULCN FOR THE LAYER                                  
!                                                                       
         IF (ISEA1.EQ.0) ISEA1 = ISEASN 
         ITYAER = IHAZE 
         IF (IHAZ1.GT.0) ITYAER = IHAZ1 
         IF (IVUL1.GT.0) IVULCN = IVUL1 
         IF (IVUL1.LE.0) IVUL1 = IVULCN 
!                                                                       
         IF (K.EQ.1) GO TO 130 
         IF (ICHR.EQ.1) GO TO 120 
         IF (ICLD1.NE.IREGC(IC1)) GO TO 110 
         IF (IHAZ1.EQ.0.AND.ICLD1.EQ.0) THEN 
            IF (ZSC.GT.2.) ITYAER = 6 
            IF (ZSC.GT.10.) ITYAER = IVULCN+10 
            IF (ZSC.GT.30.) ITYAER = 19 
            IF (ITYAER.EQ.ICH(IC1)) GO TO 130 
         ENDIF 
         IF (ICLD1.EQ.0.AND.IHAZ1.EQ.0) GO TO 120 
         N = 7 
         IF (IC1.GT.1) N = IC1+10 
         IF (IHAZ1.EQ.0) GO TO 130 
         IF (IHAZ1.NE.ICH(IC1)) GO TO 120 
         GO TO 130 
  110    IF (ICLD1.NE.0) THEN 
            IF (ICLD1.EQ.IREGC(1)) THEN 
               N = 7 
               ALTB(1) = ZMDL(K) 
               GO TO 140 
            ENDIF 
            IF (IC1.EQ.1) GO TO 120 
            IF (ICLD1.EQ.IREGC(2)) THEN 
               N = 12 
               ALTB(2) = ZMDL(K) 
               GO TO 140 
            ENDIF 
            IF (IC1.EQ.2) GO TO 120 
            IF (ICLD1.EQ.IREGC(3)) THEN 
               N = 13 
               ALTB(3) = ZMDL(K) 
               GO TO 140 
            ENDIF 
         ELSE 
            IF (IHAZ1.EQ.0.AND.ICLD1.EQ.0) THEN 
               IF (ZSC.GT.2.) ITYAER = 6 
               IF (ZSC.GT.10.) ITYAER = IVULCN+10 
               IF (ZSC.GT.30.) ITYAER = 19 
            ENDIF 
            IF (ITYAER.EQ.ICH(1)) THEN 
               N = 7 
               ALTB(1) = ZMDL(K) 
               GO TO 140 
            ENDIF 
            IF (IC1.EQ.1) GO TO 120 
            IF (ITYAER.EQ.ICH(2)) THEN 
               N = 12 
               ALTB(2) = ZMDL(K) 
               GO TO 140 
            ENDIF 
            IF (IC1.EQ.2) GO TO 120 
            IF (ITYAER.EQ.ICH(3)) THEN 
               N = 13 
               ALTB(3) = ZMDL(K) 
               GO TO 140 
            ENDIF 
         ENDIF 
  120    IC1 = IC1+1 
         ICL = 0 
!                                                                       
!                                                                       
!                                                                       
         N = IC1+10 
         IF (RH.GT.0.) RHH = RH 
         IF (IC1.LE.4) GO TO 130 
         IC1 = 4 
         N = 14 
         ITYAER = ICH(IC1) 
  130    ICH(IC1) = ITYAER 
         IREGC(IC1) = ICLD1 
         ALTB(IC1) = ZMDL(K) 
!                                                                       
!        FOR LVSA OR CLD OR RAIN ONLY                                   
!                                                                       
  140    IF (IHAZ1.LE.0) IHAZ1 = IHAZE 
!                                                                       
         DENSTY(7,K) = 0. 
         DENSTY(12,K) = 0. 
         DENSTY(13,K) = 0. 
         DENSTY(14,K) = 0. 
         DENSTY(15,K) = 0. 
!                                                                       
!        IF((GNDALT.GT.0.).AND.(ZMDL(K).LT.6.0)) THEN                   
!        J= INT(ZSC+1.0E-6)+1                                           
!        FAC=ZSC- REAL(J-1)                                             
!        ELSE                                                           
!                                                                       
         J = INT(ZMDL(K)+1.0E-6)+1 
         IF (ZMDL(K).GE.25.0) J = (ZMDL(K)-25.0)/5.0+26. 
         IF (ZMDL(K).GE.50.0) J = (ZMDL(K)-50.0)/20.0+31. 
         IF (ZMDL(K).GE.70.0) J = (ZMDL(K)-70.0)/30.0+32. 
         J = MIN(J,I_32) 
         FAC = ZMDL(K)- REAL(J-1) 
         IF (J.LT.26) GO TO 150 
         FAC = (ZMDL(K)-5.0* REAL(J-26)-25.)/5. 
         IF (J.GE.31) FAC = (ZMDL(K)-50.0)/20. 
         IF (J.GE.32) FAC = (ZMDL(K)-70.0)/30. 
         FAC = MIN(FAC,1.0) 
!                                                                       
!        ENDIF                                                          
!                                                                       
  150    L = J+1 
         WHN = 0. 
         IF (MODEL.EQ.0) THEN 
            CALL GETPT (K,ZMDL,P,T,WHN,INEW) 
            WH(K) = WHN 
         ELSE 
            CALL CHECK (P(K),JUNIT(1),1) 
            CALL CHECK (T(K),JUNIT(2),2) 
            CALL LDEFAL (ZMDL(K),P(K),T(K)) 
            CALL LCONVR (P(K),T(K)) 
            WH(K) = WMOL(1) 
         ENDIF 
!                                                                       
         TMP = T(K)-T0 
!                                                                       
!        FOR LVSA OR CLD OR RAIN ONLY                                   
!                                                                       
         IF (RH.GT.0.0) THEN 
            TA = T0/T(K) 
            WH(K) = F(TA)*0.01*RH 
            IF (IVSA.EQ.1) GO TO 160 
!                                                                       
!           WRITE(IPR,800) ZMDL(K),EQLWCZ,ICLD1,RRATZ                   
!                                                                       
!                                                                       
  160    ENDIF 
!                                                                       
!        C    IF (M3.GT.0) WO(K,7)=WO(J,M3)*(WO(L,M3)/WO(J,M3))**FAC    
!                                                                       
         HSTOR(K) = 0. 
!                                                                       
!        IF (HMIX(J).LE.0.) GO TO 40                                    
!        IF (HMIX(L).LE.0.) GO TO 40                                    
!        HSTOR(K)=HMIX(J)*(HMIX(L)/HMIX(J))**FAC                        
!                                                                       
         DENSTY(7,K) = 0. 
         DENSTY(12,K) = 0. 
         DENSTY(13,K) = 0. 
         DENSTY(14,K) = 0. 
         DENSTY(15,K) = 0. 
!                                                                       
!        PS=P(K,7)/1013.0                                               
!                                                                       
         TS = 273.15/T(K) 
         WTEMP = WH(K) 
         RELHUM(K) = 0. 
         IF (WTEMP.LE.0.) GO TO 170 
         RELHUM(K) = 100.0*WTEMP/F(TS) 
         IF (RELHUM(K).GT.100.) WRITE (IPR,920) RELHUM(K),ZMDL(K) 
         IF (RELHUM(K).GT.100.) RELHUM(K) = 100. 
         IF (RELHUM(K).LT.0.) WRITE (IPR,920) RELHUM(K),ZMDL(K) 
         IF (RELHUM(K).LT.0.) RELHUM(K) = 0. 
  170    RHH = RELHUM(K) 
         RH = RHH 
         IF (VIS1.LE.0.0) VIS1 = VIS 
         IF (AHAZE.EQ.0.0) GO TO 180 
         DENSTY(N,K) = AHAZE 
         IF (ITYAER.EQ.3) GO TO 180 
!                                                                       
!        AHAZE IS IN LOWTRAN NUMBER DENSTY UNITS                        
!                                                                       
         GO TO 200 
  180    CONTINUE 
!                                                                       
!        AHAZE NOT INPUT OR NAVY MARITIME MODEL IS CALLED               
!                                                                       
!        CHECK IF GNDALT NOT ZERO                                       
!                                                                       
         IF ((GNDALT.GT.0.).AND.(ZMDL(K).LT.6.0)) THEN 
            J = INT(ZSC+1.0E-6)+1 
            FAC = ZSC- REAL(J-1) 
            L = J+1 
         ENDIF 
         IF (ITYAER.EQ.3.AND.ICL.EQ.0) THEN 
            CALL MARINE (VIS1,MODEL,WSS,WHH,ICSTL,EXTC,ABSC,IC1) 
            IREG(IC1) = 1 
            VIS = VIS1 
            ICL = ICL+1 
         ENDIF 
         IF (ITYAER.EQ.10.AND.IDSR.EQ.0) THEN 
            CALL DESATT (WSS,VIS1) 
            IREG(IC1) = 1 
            VIS = VIS1 
            IDSR = IDSR+1 
         ENDIF 
         IF (AHAZE.GT.0.0) GO TO 200 
         CALL AERPRF (J,K,VIS1,HAZ1,IHAZ1,ICLD1,ISEA1,IVUL1,NN) 
         CALL AERPRF (L,K,VIS1,HAZ2,IHAZ1,ICLD1,ISEA1,IVUL1,NN) 
         HAZE = 0. 
         IF ((HAZ1.LE.0.0).OR.(HAZ2.LE.0.0)) GO TO 190 
         HAZE = HAZ1*(HAZ2/HAZ1)**FAC 
         DENSTY(N,K) = HAZE 
  190    CONTINUE 
         IF (CLDAMT(K).GT.0.0) THEN 
            HAZE = HAZEC(K) 
            IF (HAZE.GT.0.) DENSTY(N,K) = HAZE 
         ENDIF 
  200    CONTINUE 
         IF (K.EQ.1) GO TO 210 
         IF (CLDAMT(K).LE.0.0.AND.CLDAMT(K-1).GT.0.0) THEN 
            HAZE = HAZ1*(HAZ2/HAZ1)**FAC 
            IF (HAZE.GT.0.) DENSTY(N,K) = HAZE 
         ENDIF 
  210    CONTINUE 
         ITY1(K) = ITYAER 
         IH1(K) = IHAZ1 
         IF (AHAZE.NE.0) IH1(K) = -99 
         IS1(K) = ISEA1 
         IVL1(K) = IVUL1 
         WGM(K) = WH(K) 
  220 END DO 
!                                                                       
!     END OF LOOP                                                       
!                                                                       
      IF (ML.LT.20) WRITE (IPR,925) 
      IF (ML.GE.20) WRITE (IPR,930) 
      IHH = ICLD 
      IF (IHH.LE.0) IHH = 12 
      IHH = MIN(IHH,I_12) 
      IF (ICLD.EQ.18) IHH = 13 
      IF (ICLD.EQ.19) IHH = 14 
      IF (ICLD.EQ.20) IHH = 15 
!                                                                       
      HHOL = AHAHOL(IHH) 
      IF (IVSA.NE.0) HHOL = AHLVSA 
!                                                                       
      IF (ICLD.NE.0) THEN 
         IF (JPRT.EQ.0) WRITE (IPR,935) HHOL,M 
      ENDIF 
      IF (JPRT.EQ.0) WRITE (IPR,940) 
!                                                                       
      IF (JPRT.EQ.1) GO TO 240 
!                                                                       
      DO 230 KK = 1, ML 
!                                                                       
         K = KK 
         IF (JPRT.EQ.1) GO TO 230 
!                                                                       
         AHOL1 = BLANK 
         AHOL2 = BLANK 
         AHOL3 = BLANK 
         ITYAER = ITY1(KK) 
         IF (ITYAER.EQ.0) ITYAER = 1 
         IF (ITYAER.EQ.16) ITYAER = 11 
         IF (ITYAER.EQ.17) ITYAER = 11 
         IF (ITYAER.EQ.18) ITYAER = 13 
         IHAZ1 = IH1(KK) 
         ISEA1 = IS1(KK) 
         IVUL1 = IVL1(KK) 
!                                                                       
         AHOL1 = HZ(ITYAER) 
         IF (IVSA.EQ.1) AHOL1 = HHOL 
         IF (CLDAMT(KK).GT.0.0.OR.RRAMT(KK).GT.0.0) AHOL1 = HHOL 
         IF (IHAZE.EQ.0) AHOL1 = HHOL 
         AHOL2 = AHUS 
         IF (AHAST(KK).EQ.0) AHOL2 = AHOL1 
         IF (CLDAMT(KK).GT.0.0.OR.RRAMT(KK).GT.0.0) AHOL2 = HHOL 
         IF (ZGN(KK).GT.2.0) AHOL3 = SEASN(ISEA1) 
         WRITE (IPR,945) ZMDL(KK),P(KK),T(KK),RELHUM(KK),WH(KK),        &
         CLDAMT(KK),RRAMT(KK),AHOL1,AHOL2,AHOL3                         
  230 continue 
  240 IMMAX = ML 
      M = 7 
      IF (ML.EQ.1) WRITE (IPR,925) 
      IF (ML.NE.1) MODEL = M 
      RETURN 
!                                                                       
  900 FORMAT('   ERROR MODEL EQ 0 AND ARMY MODEL CANNOT MIX') 
  905 FORMAT('  ERROR ML GT 24 AND ARMY MODEL TOP LAYER TRUNCATED') 
  910 FORMAT(/,10X,' MODEL 0 / 7 USER INPUT DATA ',//) 
  915      FORMAT    (4F10.3,5I5) 
  920 FORMAT(' ***ERROR RELHUM ' ,E15.4,'  AT ALT  ',F12.3) 
  925 FORMAT('0 ') 
  930 FORMAT('1  ') 
  935 FORMAT(//'0 CLOUD AND OR RAIN TYPE CHOSEN IS   ',A20,             &
     & '  M IS SET TO',I5//)                                            
  940 FORMAT(T7,'Z',T17,'P',T26,'T',T32,'REL H', T41,'H2O',             &
     & T49,'CLD AMT',T59,'RAIN RATE', T90,'AEROSOL'/,                   &
     & T6,'(KM)',T16,'(MB)',T25,'(K)',T33,'(%)',T39,'(GM M-3)',T49,     &
     & '(GM M-3)',T59,'(MM HR-1)',T69,                                  &
     & 'TYPE', T90,'PROFILE')                                           
  945 FORMAT(2F10.3,2F8.2,1P3E10.3,1X,3A20) 
  950 FORMAT(//,' MODEL ATMOSPHERE NO. ',I5,' ICLD =',I5,//) 
!                                                                       
      END                                           
!                                                                       
!     ***********************************************************       
!                                                                       
      SUBROUTINE LAYCLD(K,CLDATZ,RRATZ,IAERSL,ICLD1,GNDALT,RAINRT) 
!                                                                       
!     THIS SUBROUTINE RESTRUCTURES THE ATMOSPHERIC PROFILE              
!     TO PROFIDE FINER LAYERING WITHIN THE FIRST 6 KM.                  
!                                                                       
!     ZMDL COMMON /MODEL/ FINAL ALTITUDE FOR LOWTRAN                    
!     ZK  EFFECTIVE CLOUD ALTITUDES                                     
!     ZCLD CLOUD ALTITUDE ARRAY                                         
!     ZDIF  ALT DIFF OF 2 LAYERS                                        
!     ZDA COMMON /MDATA/ CLD AND RAIN INFO IN THIS COMMON               
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!     COMMON /MDATA/ ZDA(MXZMD),P(MXZMD),T(MXZMD),WH(MXZMD),WO(MXZMD),  
!    *     HMIX(MXZMD),CLD(MXZMD,7),RR(MXZMD,7)                         
      COMMON /MDATA/                              WH(MXZMD),WO(MXZMD),  &
     &                 CLD(MXZMD,7),RR(MXZMD,7)                         
      COMMON /MDATA2/ZDA(MXZMD),P(MXZMD),T(MXZMD) 
      COMMON /MODEL/ ZMDL(MXZMD),PN(MXZMD),TN(MXZMD),                   &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
      DIMENSION ZCLD(16) 
      DATA ZCLD/ 0.0,0.16,0.33,0.66,1.0,1.5,2.0,2.4,2.7,                &
     & 3.0,3.5,4.0,4.5,5.0,5.5,6.0/                                     
      DATA CLDTP/6.0001/ 
      DATA DELZ /0.02/ 
      ICLD = ICLD1 
      IF (ICLD.EQ.0) RETURN 
      IF (ICLD.GT.11) RETURN 
      ZK = ZMDL(K)-GNDALT 
      ZK = MAX(ZK,0.) 
      IF (ZMDL(K).GT.6.) ZK = ZMDL(K) 
      IF (ICLD.GT.5) GO TO 10 
!                                                                       
!     CC                                                                
!     CC    ICLD  IS  1- 5 ONE OF 5 SPECIFIC CLOUD MODELS IS CHOSEN     
!     CC                                                                
!                                                                       
      MC = ICLD 
      MR = 6 
      GO TO 20 
   10 CONTINUE 
!                                                                       
!     CC                                                                
!     CC   ICLD  IS  6-10 ONE OF 5 SPECIFIC CLOUD/RAIN MODELS CHOSEN    
!     CC                                                                
!                                                                       
      IF (ICLD.EQ.6) MC = 3 
      IF (ICLD.EQ.7.OR.ICLD.EQ.8) MC = 5 
      IF (ICLD.GT.8) MC = 1 
      MR = ICLD-5 
   20 CONTINUE 
      IF (ZK.GT.CLDTP) GO TO 70 
      CLDATZ = 0. 
      RRATZ = 0. 
      IF (ZK.LE.10.) RRATZ = RAINRT 
      IF (MC.LT.1) GO TO 60 
      DO 50 MK = 1, 15 
         IF (ZK.GE.ZCLD(MK+1)) GO TO 50 
         IF (ZK.LT.ZCLD(MK)) GO TO 50 
         IF (ABS(ZK-ZCLD(MK)).LT.DELZ) GO TO 30 
         GO TO 40 
   30    CLDATZ = CLD(MK,MC) 
         RRATZ = RR(MK,MR) 
         GO TO 60 
   40    ZDIF = ZCLD(MK+1)-ZCLD(MK) 
         IF (ZDIF.LT.DELZ) GO TO 30 
         FAC = (ZCLD(MK+1)-ZK)/ZDIF 
         CLDATZ = CLD(MK+1,MC)+FAC*(CLD(MK,MC)-CLD(MK+1,MC)) 
         RRATZ = RR(MK+1,MR)+FAC*(RR(MK,MR)-RR(MK+1,MR)) 
         GO TO 60 
   50 END DO 
   60 CLDAMT(K) = CLDATZ 
      CLD(K,7) = CLDATZ 
      RR(K,7) = RRATZ 
      RRAMT(K) = RRATZ 
      RETURN 
   70 CONTINUE 
      CLDAMT(K) = 0.0 
      RRAMT(K) = 0.0 
      CLDATZ = 0.0 
      RRATZ = 0.0 
      RETURN 
      END                                           
      BLOCK DATA MDTA 
!                                                                       
!     >    BLOCK DATA                                                   
!                                                                       
!     CLOUD AND RAIN   DATA                                             
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!     COMMON /MDATA/ ZDA(MXZMD),P(MXZMD),T(MXZMD),WH(MXZMD),WO(MXZMD),  
!    *     HMIX(MXZMD),CLD1(MXZMD),CLD2(MXZMD),CLD3(MXZMD),CLD4(MXZMD), 
!    *     CLD5(MXZMD),CLD6(MXZMD),CLD7(MXZMD),RR1(MXZMD),RR2(MXZMD),   
!    *     RR3(MXZMD),RR4(MXZMD),RR5(MXZMD),RR6(MXZMD),RR7(MXZMD)       
      COMMON /MDATA/                              WH(MXZMD),WO(MXZMD),  &
     &                 CLD1(MXZMD),CLD2(MXZMD),CLD3(MXZMD),CLD4(MXZMD), &
     &     CLD5(MXZMD),CLD6(MXZMD),CLD7(MXZMD),RR1(MXZMD),RR2(MXZMD),   &
     &     RR3(MXZMD),RR4(MXZMD),RR5(MXZMD),RR6(MXZMD),RR7(MXZMD)       
      COMMON /MDATA2/ZDA(MXZMD),P(MXZMD),T(MXZMD) 
!                                                                       
!     DATA  Z/                                                          
!     C       0.0,       1.0,       2.0,       3.0,       4.0,          
!     C       5.0,       6.0,       7.0,       8.0,       9.0,          
!     C      10.0,      11.0,      12.0,      13.0,      14.0,          
!     C      15.0,      16.0,      17.0,      18.0,      19.0,          
!     C      20.0,      21.0,      22.0,      23.0,      24.0,          
!     C      25.0,      27.5,      30.0,      32.5,      35.0,          
!     C      37.5,      40.0,      42.5,      45.0,      47.5,          
!     C      50.0,      55.0,      60.0,      65.0,      70.0,          
!     C      75.0,      80.0,      85.0,      90.0,      95.0,          
!     C     100.0,     105.0,     110.0,     115.0,     120.0/          
!     CC   CLOUD MODELS 1-5                                             
!                                                                       
      DATA CLD1/ 0.0,0.0,0.0,0.2,0.35,1.0,1.0,1.0,0.3,0.15,6990*0.0/ 
      DATA CLD2/ 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.3,0.4,0.3,6990*0.0/ 
      DATA CLD3/ 0.0,0.0,0.15,0.30,0.15,6995*0.0/ 
      DATA CLD4/ 0.0,0.0,0.0,0.10,0.15,0.15,0.10,6993*0.0/ 
      DATA CLD5/ 0.0,0.30,0.65,0.40,6996*0.0/ 
      DATA CLD6/ 7000*0.0/ 
      DATA CLD7/ 7000*0.0/ 
!                                                                       
!     CC   RAIN MODELS 1-5                                              
!                                                                       
      DATA RR1/ 2.0,1.78,1.43,1.22,0.86,0.22,6994*0.0/ 
      DATA RR2/ 5.0,4.0,3.4,2.6,0.8,0.2,6994*0.0/ 
      DATA RR3/ 12.5,10.5,8.0,6.0,2.5,0.8,0.2,6993*0.0/ 
      DATA RR4/ 25.0,21.5,17.5,12.0,7.5,4.2,2.5,1.0,0.7,0.2,6990*0.0/ 
      DATA RR5/ 75.0,70.0,65.0,60.0,45.0,20.0,12.5,7.0,3.5,             &
     & 1.0,0.2,6989*0.0/                                                
      DATA RR6/ 7000*0.0/ 
      DATA RR7/ 7000*0.0/ 
!                                                                       
!     DATA CO2       /                                                  
!                                                                       
      END                                           
!                                                                       
!     **************************************************************    
!                                                                       
      SUBROUTINE GETPT(K,ZMDL,P,T,WHN,INEW) 
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE phys_consts, ONLY: avogad
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX2(47),AWCCON(5) 
!                                                                       
      CHARACTER*8      HMOD 
!                                                                       
      COMMON /CMN/ HMOD(3),Zc(MXZMD),Pc(MXZMD),Tc(MXZMD),RFNDXM(MXZMD), &
     &          ZP(IM2),PP(IM2),TP(IM2),RFNDXP(IM2),SP(IM2),PPSUM(IM2), &
     &          TPSUM(IM2),RHOPSM(IM2),IMLOW,WGM(MXZMD),DENW(MXZMD),    &
     &          AMTP(MXMOL,MXPDIM)                                      
!                                                                       
!                                                                       
      COMMON /PATHD/ PBAR(MXLAY),TBAR(MXLAY),AMOUNT(MXMOL,MXLAY),       &
     &               WN2L(MXLAY),DVL(MXLAY),WTOTL(MXLAY),ALBL(MXLAY),   &
     &               ADBL(MXLAY),AVBL(MXLAY),H2OSL(MXLAY),IPATH(MXLAY), &
     &               ITYL(MXLAY),SECNTA(MXLAY),HT1,HT2,ALTZ(0:MXLAY),   &
     &               PM(0:MXLAY),TM(0:MXLAY)                            
!                                                                       
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,N_LVL,JH1 
      DIMENSION INEW( *) 
      DIMENSION ZMDL( *),P(MXZMD),T(MXZMD) 
!                                                                       
!     ZP BLANK COMMON UNUSED                                            
!     ALTZ  BLANK COMMON LBLRTM ALTITUDES                               
!     ZMDL COMMON /MODEL/ FINAL ALTITUDE FOR LOWTRAN                    
!                                                                       
!     THIS ROUTINE INTERPOLATES P,T,AND H2O INTO                        
!     LOWTRAN LAYERS WHEN MODEL = 7                                     
!                                                                       
      WTH2O = 18.015 
      B = WTH2O*1.E06/AVOGAD 
      J = INEW(K) 
!                                                                       
      JL = J-1 
      IF (JL.LT.0) JL = 0 
      JP = JL+1 
      IF (JP.GT.ML) GO TO 40 
      DIF = ALTZ(JP)-ALTZ(JL) 
      FAC = (ZMDL(K)-ALTZ(JL))/DIF 
      P(K) = PM(JL) 
      IF (PM(JP).LE.0.0.OR.PM(JL).LE.0.) GO TO 10 
      P(K) = PM(JL)*(PM(JP)/PM(JL))**FAC 
   10 T(K) = TM(JL) 
      IF (TM(JP).LE.0.0.OR.TM(JL).LE.0.) GO TO 20 
      T(K) = TM(JL)*(TM(JP)/TM(JL))**FAC 
   20 WHN = DENW(JL+1) 
      IF (DENW(JP+1).LE.0.0.OR.DENW(JL+1).LE.0.) GO TO 30 
      WHN = DENW(JL+1)*(DENW(JP+1)/DENW(JL+1))**FAC 
   30 CONTINUE 
      WHN = WHN*B 
      RETURN 
   40 P(K) = PM(JL) 
      T(K) = TM(JL) 
      WHN = DENW(JL)*B 
      RETURN 
      END                                           
      SUBROUTINE CIRR18 
!                                                                       
!     ******************************************************************
!     *  ROUTINE TO SET CTHIK CALT CEXT  FOR  CIRRUS CLOUDS 18 19       
!     *  INPUTS!                                                        
!     *           CHTIK    -  CIRRUS THICKNESS (KM)                     
!     *                       0 = USE THICKNESS STATISTICS              
!     *                       .NE. 0 = USER DEFINES THICKNESS           
!     *                                                                 
!     *           CALT     -  CIRRUS BASE ALTITUDE (KM)                 
!     *                       0 = USE CALCULATED VALUE                  
!     *                       .NE. 0 = USER DEFINES BASE ALTITUDE       
!     *                                                                 
!     *           ICLD     -  CIRRUS PRESENCE FLAG                      
!     *                       0 = NO CIRRUS                             
!     *                       18  19 = USE CIRRUS PROFILE               
!     *                                                                 
!     *           MODEL    -  ATMOSPHERIC MODEL                         
!     *                       1-5  AS IN MAIN PROGRAM                   
!     *                       MODEL = 0,6,7 NOT USED SET TO 2           
!     *                                                                 
!     *  OUTPUTS!                                                       
!     *         CTHIK        -  CIRRUS THICKNESS (KM)                   
!     *         CALT         -  CIRRUS BASE ALTITUDE (KM)               
!     CEXT IS THE EXTINCTION COEFFIENT(KM-1) AT 0.55                    
!     DEFAULT VALUE 0.14*CTHIK                                          
!     *                                                                 
!     ******************************************************************
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX2(47),AWCCON(5) 
!                                                                       
      COMMON /LCRD1/ MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRNT,TBOUND,SALB 
      COMMON /LCRD2/ IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,   &
     &     RAINRT                                                       
      COMMON /LCRD2A/ CTHIK,CALT,CEXT 
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,IMULT,JH1 
      COMMON /LCRD4/ V1,V2,DV 
      COMMON/MODEL/ ZMDL(MXZMD),PM(MXZMD),TM(MXZMD),                    &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
      DIMENSION CBASE(5,2),TSTAT(11),PTAB(5),CAMEAN(5) 
      DIMENSION CBASE1(5),CBASE2(5) 
      EQUIVALENCE (CBASE1(1),CBASE(1,1)),(CBASE2(1),CBASE(1,2)) 
!                                                                       
      DATA  CAMEAN           / 11.0, 10.0, 8.0, 7.0, 5.0 / 
      DATA  PTAB           / 0.8, 0.4, 0.5, 0.45, 0.4/ 
      DATA  CBASE1            / 7.5, 7.3, 4.5, 4.5, 2.5 / 
      DATA  CBASE2            /16.5,13.5,14.0, 9.5,10.0 / 
      DATA  TSTAT             / 0.0,.291,.509,.655,.764,.837,.892,      &
     & 0.928, 0.960, 0.982, 1.00 /                                      
      MDL = MODEL 
!                                                                       
!     CHECK IF USER WANTS TO USE A THICKNESS VALUE HE PROVIDES          
!     DEFAULTED MEAN CIRRUS THICKNESS IS 1.0KM  OR 0.2 KM.              
!                                                                       
      IF (CTHIK.GT.0.0) GO TO 10 
      IF (ICLD.EQ.18) CTHIK = 1.0 
      IF (ICLD.EQ.19) CTHIK = 0.2 
   10 IF (CEXT.EQ.0.) CEXT = 0.14*CTHIK 
!                                                                       
!     BASE HEIGHT CALCULATIONS                                          
!                                                                       
      IF (MODEL.LT.1.OR.MODEL.GT.5) MDL = 2 
!                                                                       
      HMAX = CBASE(MDL,2)-CTHIK 
      BRANGE = HMAX-CBASE(MDL,1) 
      IF (CALT.GT.0.0) GO TO 20 
      CALT = CAMEAN(MDL) 
!                                                                       
   20 IF (ICLD.EQ.18) WRITE (IPR,900) 
      IF (ICLD.EQ.19) WRITE (IPR,905) 
      WRITE (IPR,910) CTHIK 
      WRITE (IPR,915) CALT 
      WRITE (IPR,920) CEXT 
!                                                                       
!     END OF CIRRUS MODEL SET UP                                        
!                                                                       
      RETURN 
!                                                                       
  900 FORMAT(15X,'CIRRUS ATTENUATION INCLUDED   (STANDARD CIRRUS)') 
  905 FORMAT(15X,'CIRRUS ATTENUATION INCLUDED   (THIN     CIRRUS)') 
  910 FORMAT(15X,'CIRRUS THICKNESS ',                                   &
     & F10.3,'KM')                                                      
  915 FORMAT(15X,'CIRRUS BASE ALTITUDE ',                               &
     & F10.3,' KM')                                                     
  920   FORMAT(15X,'CIRRUS PROFILE EXTINCT ',F10.3) 
!                                                                       
      END                                           
      SUBROUTINE DESATT(WSPD,VIS) 
!                                                                       
!     ******************************************************************
!     *                                                                 
!     *    THIS SUBROUTINE CALCULATES THE ATTENUATION COEFFICIENTS AND  
!     *    ASYMMETRY PARAMETER FOR THE DESERT AEROSOL BASED ON THE WIND 
!     *    SPEED AND METEOROLOGICAL RANGE                               
!     *                                                                 
!     *                                                                 
!     *                                                                 
!     *    PROGRAMMED BY:  D. R. LONGTIN         OPTIMETRICS, INC.      
!     *                                          BURLINGTON, MASSACHUSET
!     *                                          JULY 1987              
!     *                                                                 
!     *                                                                 
!     *    INPUTS:    WSPD    -  WIND SPEED (IN M/S) AT 10 M            
!     *               VIS     -  METEOROLOGICAL RANGE (KM)              
!     *                                                                 
!     *    OUTPUTS:   DESEXT  -  EXTINCTION COEFFICIENT AT 47 WAVELENGTH
!     *               DESSCA  -  SCATTERING COEFFICIENT AT 47 WAVELENGTH
!     *    *****      DESABS  -  ABSORPTION COEFFICIENT AT 47 WAVELENGTH
!     *               DESG    -  ASYMMETRY PARAMETER AT 47 WAVELENGTHS  
!     *                                                                 
!     ******************************************************************
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),WHNO3(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
!                                                                       
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX2(47),AWCCON(5) 
      COMMON /DESAER/ EXT(47,4),ABS(47,4),G(47,4) 
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &                     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4      
      DIMENSION DESEXT(47),DESSCA(47),DESABS(47),DESG(47),WIND(4) 
      REAL      DESEXT    ,DESSCA    ,DESABS    ,DESG    ,WIND 
      INTEGER WAVEL 
!                                                                       
      DATA I_3/3/ 
!                                                                       
      DATA WIND/0., 10., 20., 30./ 
      DATA RAYSCT / 0.01159 / 
      IF (WSPD.LT.0.) WSPD = 10. 
!                                                                       
      NWSPD = INT(WSPD/10)+1 
      IF (NWSPD.GE.5) WRITE (IPR,905) 
      NWSPD = MIN(NWSPD,I_3) 
!                                                                       
!     INTERPOLATE THE RADIATIVE PROPERTIES AT WIND SPEED WSPD           
!                                                                       
      DO 10 WAVEL = 1, 47 
!                                                                       
!        EXTINCTION COEFFICIENT                                         
!                                                                       
         SLOPE = LOG(EXT(WAVEL,NWSPD+1)/EXT(WAVEL,NWSPD))/(WIND(NWSPD+1)&
         -WIND(NWSPD))                                                  
         B = LOG(EXT(WAVEL,NWSPD+1))-SLOPE*WIND(NWSPD+1) 
         DESEXT(WAVEL) = EXP(SLOPE*WSPD+B) 
!                                                                       
!        ABSORPTION COEFFICIENT                                         
!                                                                       
         SLOPE = LOG(ABS(WAVEL,NWSPD+1)/ABS(WAVEL,NWSPD))/(WIND(NWSPD+1)&
         -WIND(NWSPD))                                                  
         B = LOG(ABS(WAVEL,NWSPD+1))-SLOPE*WIND(NWSPD+1) 
         DESABS(WAVEL) = EXP(SLOPE*WSPD+B) 
!                                                                       
!        SCATTERING COEFFICIENT                                         
!                                                                       
         DESSCA(WAVEL) = DESEXT(WAVEL)-DESABS(WAVEL) 
!                                                                       
!        ASYMMETRY PARAMETER                                            
!                                                                       
         SLOPE = (G(WAVEL,NWSPD+1)-G(WAVEL,NWSPD))/(WIND(NWSPD+1)-      &
         WIND(NWSPD))                                                   
         B = G(WAVEL,NWSPD+1)-SLOPE*(WIND(NWSPD+1)) 
         DESG(WAVEL) = SLOPE*WSPD+B 
   10 END DO 
!                                                                       
      EXT55 = DESEXT(4) 
!                                                                       
!     DETERMINE METEROLOGICAL RANGE FROM 0.55 EXTINCTION                
!     AND KOSCHMIEDER FORMULA                                           
!                                                                       
      IF (VIS.LE.0.) THEN 
         VIS = 3.912/(DESEXT(4)+RAYSCT) 
      ENDIF 
!                                                                       
!     RENORMALIZE ATTENUATION COEFFICIENTS TO 1.0 KM-1 AT               
!     0.55 MICRONS FOR CAPABILTY WITH LOWTRAN                           
!                                                                       
      DO 20 WAVEL = 1, 47 
         EXTC(1,WAVEL) = DESEXT(WAVEL)/EXT55 
!                                                                       
!        C          DESSCA(WAVEL) = DESSCA(WAVEL)       /EXT55          
!                                                                       
         ABSC(1,WAVEL) = DESABS(WAVEL)/EXT55 
         ASYM(1,WAVEL) = DESG(WAVEL) 
   20 END DO 
      WRITE (IPR,900) VIS,WSPD 
      RETURN 
!                                                                       
  900  FORMAT(//,'  VIS = ',F10.3,' WIND = ',F10.3) 
  905  FORMAT(' WARNING: WIND SPEED IS BEYOND 30 M/S; RADIATIVE',       &
     &'PROPERTIES',/,'OF THE DESERT AEROSOL HAVE BEEN EXTRAPOLATED')    
!                                                                       
      END                                           
      BLOCK DATA DSTDTA 
!                                                                       
!     >    BLOCK DATA                                                   
!     ******************************************************************
!     *                                                                 
!     *    DESERT AEROSOL EXTINCTION COEFFICIENTS, ABSORPTION COEFFICIEN
!     *    AND ASYMMETRY PARAMETERS FOR FOUR WIND SPEEDS: 0 M/S, 10 M/S,
!     *    20 M/S AND 30 M/S                                            
!     *                                                                 
!     *    PROGRAMMED BY:  D. R. LONGTIN         OPTIMETRICS, INC.      
!     *                                          BURLINGTON, MASSACHUSET
!     *                                          FEB  1988              
!     *                                                                 
!     ******************************************************************
!                                                                       
      COMMON /DESAER/DESEX1(47),DESEX2(47),DESEX3(47),DESEX4(47),       &
     &DESAB1(47),DESAB2(47),DESAB3(47),DESAB4(47),DESG1(47),DESG2(47),  &
     &DESG3(47),DESG4(47)                                               
!                                                                       
!     EXTINCTION COEFFICIENTS                                           
!                                                                       
      DATA DESEX1 /                                                     &
     & 8.7330E-2, 7.1336E-2, 6.5754E-2, 4.0080E-2, 2.8958E-2, 1.4537E-2,&
     & 7.1554E-3, 4.3472E-3, 3.5465E-3, 2.9225E-3, 2.5676E-3, 4.3573E-3,&
     & 5.7479E-3, 2.9073E-3, 2.0109E-3, 1.8890E-3, 1.8525E-3, 1.8915E-3,&
     & 1.9503E-3, 2.3256E-3, 4.9536E-3, 2.0526E-3, 2.6738E-3, 9.2804E-3,&
     & 1.5352E-2, 6.9396E-3, 2.2455E-3, 1.9840E-3, 1.9452E-3, 1.9019E-3,&
     & 1.8551E-3, 1.9661E-3, 1.9865E-3, 2.4089E-3, 1.7485E-3, 1.4764E-3,&
     & 2.2604E-3, 2.1536E-3, 2.3008E-3, 2.9272E-3, 2.6943E-3, 2.4319E-3,&
     & 1.9199E-3, 1.4887E-3, 8.0630E-4, 4.6950E-4, 2.0792E-4/           
      DATA DESEX2 /                                                     &
     & 1.0419E-1, 8.8261E-2, 8.2699E-2, 5.7144E-2, 4.6078E-2, 3.1831E-2,&
     & 2.4638E-2, 2.1952E-2, 2.1254E-2, 2.0743E-2, 2.0397E-2, 2.2340E-2,&
     & 2.3848E-2, 2.1104E-2, 2.0422E-2, 2.0462E-2, 2.0591E-2, 2.0843E-2,&
     & 2.1030E-2, 2.1630E-2, 2.2880E-2, 1.9075E-2, 2.0928E-2, 2.9835E-2,&
     & 3.8025E-2, 2.7349E-2, 2.1502E-2, 2.1475E-2, 2.1563E-2, 2.1726E-2,&
     & 2.2265E-2, 2.2580E-2, 2.2708E-2, 2.1705E-2, 2.1230E-2, 2.0523E-2,&
     & 2.6686E-2, 2.5461E-2, 2.3785E-2, 2.6033E-2, 2.6484E-2, 2.6464E-2,&
     & 2.5318E-2, 2.3341E-2, 1.7824E-2, 1.3092E-2, 7.2020E-3/           
      DATA DESEX3 /                                                     &
     & 2.7337E-1, 2.5795E-1, 2.5252E-1, 2.2773E-1, 2.1710E-1, 2.0402E-1,&
     & 1.9809E-1, 1.9664E-1, 1.9635E-1, 1.9655E-1, 1.9661E-1, 1.9907E-1,&
     & 2.0164E-1, 1.9957E-1, 2.0013E-1, 2.0142E-1, 2.0270E-1, 2.0400E-1,&
     & 2.0501E-1, 2.0665E-1, 2.0573E-1, 1.9165E-1, 2.0121E-1, 2.2402E-1,&
     & 2.4718E-1, 2.2503E-1, 2.0749E-1, 2.0910E-1, 2.0999E-1, 2.1165E-1,&
     & 2.1784E-1, 2.1727E-1, 2.1803E-1, 2.0995E-1, 2.1214E-1, 2.1308E-1,&
     & 2.5226E-1, 2.4234E-1, 2.2638E-1, 2.3991E-1, 2.4680E-1, 2.5176E-1,&
     & 2.5655E-1, 2.5505E-1, 2.3610E-1, 2.1047E-1, 1.5938E-1/           
      DATA DESEX4 /                                                     &
     & 1.9841E0, 1.9721E0, 1.9676E0, 1.9488E0, 1.9424E0, 1.9377E0,      &
     & 1.9374E0, 1.9484E0, 1.9509E0, 1.9549E0, 1.9570E0, 1.9642E0,      &
     & 1.9737E0, 1.9764E0, 1.9860E0, 1.9944E0, 2.0020E0, 2.0113E0,      &
     & 2.0148E0, 2.0245E0, 2.0283E0, 1.9397E0, 1.9973E0, 2.1039E0,      &
     & 2.2246E0, 2.1587E0, 2.0409E0, 2.0520E0, 2.0613E0, 2.0651E0,      &
     & 2.1194E0, 2.1065E0, 2.1104E0, 2.0651E0, 2.0926E0, 2.1155E0,      &
     & 2.3696E0, 2.2931E0, 2.1828E0, 2.2708E0, 2.3304E0, 2.3762E0,      &
     & 2.4533E0, 2.4915E0, 2.5118E0, 2.4463E0, 2.2122E0/                
!                                                                       
!     ABSORPTION COEFFICIENTS                                           
!                                                                       
      DATA DESAB1 /                                                     &
     & 6.4942E-4, 6.1415E-4, 5.8584E-4, 4.4211E-4, 1.3415E-4, 7.8142E-5,&
     & 5.7566E-5, 8.3848E-5, 7.6988E-5, 4.4486E-5, 8.9604E-5, 2.4887E-3,&
     & 3.3444E-3, 6.8781E-4, 1.6387E-4, 3.5236E-4, 3.5340E-4, 4.0930E-4,&
     & 5.0526E-4, 8.2146E-4, 3.7647E-3, 1.0162E-3, 1.3525E-3, 7.7761E-3,&
     & 1.3108E-2, 5.1252E-3, 1.0973E-3, 6.8573E-4, 5.7622E-4, 5.1268E-4,&
     & 7.6834E-4, 5.3793E-4, 5.0611E-4, 1.2828E-3, 6.7827E-4, 4.3826E-4,&
     & 5.1221E-4, 8.8642E-4, 9.5535E-4, 1.0000E-3, 7.5646E-4, 6.1552E-4,&
     & 4.6087E-4, 3.5642E-4, 2.3556E-4, 1.7596E-4, 1.1699E-4/           
      DATA DESAB2 /                                                     &
     & 4.3569E-3, 4.3413E-3, 4.3277E-3, 4.0649E-3, 3.9091E-4, 8.4594E-5,&
     & 5.8501E-5, 8.4412E-5, 7.7547E-5, 4.6817E-5, 9.2721E-5, 2.5389E-3,&
     & 3.3588E-3, 7.9414E-4, 8.5079E-4, 4.6002E-3, 4.4872E-3, 4.6200E-3,&
     & 5.2973E-3, 4.8910E-3, 8.9899E-3, 5.4745E-3, 3.6375E-3, 1.1862E-2,&
     & 1.5179E-2, 7.0015E-3, 8.4693E-3, 6.9516E-3, 6.3008E-3, 6.3684E-3,&
     & 8.4992E-3, 6.9625E-3, 6.5192E-3, 7.8955E-3, 7.7192E-3, 5.8540E-3,&
     & 5.3263E-3, 9.3004E-3, 7.4848E-3, 3.0952E-3, 1.8219E-3, 1.3078E-3,&
     & 1.0653E-3, 5.5231E-4, 3.2311E-4, 2.2422E-4, 1.3839E-4/           
      DATA DESAB3 /                                                     &
     & 4.1552E-2, 4.1671E-2, 4.1781E-2, 4.1125E-2, 5.0552E-3, 2.1085E-4,&
     & 7.5703E-5, 9.5531E-5, 8.8354E-5, 9.0588E-5, 1.5058E-4, 3.4972E-3,&
     & 3.6310E-3, 2.6709E-3, 1.2558E-2, 5.9184E-2, 5.8289E-2, 5.9206E-2,&
     & 6.5487E-2, 5.8707E-2, 7.4669E-2, 5.2152E-2, 2.5783E-2, 4.7971E-2,&
     & 3.2378E-2, 2.4739E-2, 8.1225E-2, 7.5085E-2, 7.1232E-2, 7.3042E-2,&
     & 8.0638E-2, 7.8255E-2, 7.4882E-2, 7.8853E-2, 8.1412E-2, 6.5722E-2,&
     & 4.8565E-2, 8.4983E-2, 7.1273E-2, 3.0870E-2, 1.7031E-2, 1.1455E-2,&
     & 1.0554E-2, 4.0418E-3, 2.1509E-3, 1.4115E-3, 7.9698E-4/           
      DATA DESAB4 /                                                     &
     & 4.1777E-1, 4.1880E-1, 4.2000E-1, 4.1846E-1, 8.6452E-2, 2.6538E-3,&
     & 4.0804E-4, 3.1418E-4, 2.9996E-4, 9.3018E-4, 1.2814E-3, 2.1436E-2,&
     & 8.7553E-3, 3.7670E-2, 2.0849E-1, 7.0914E-1, 7.0420E-1, 7.1379E-1,&
     & 7.6309E-1, 7.1128E-1, 8.2992E-1, 5.3585E-1, 2.4456E-1, 3.8103E-1,&
     & 1.7784E-1, 1.9305E-1, 7.9910E-1, 7.8987E-1, 7.7502E-1, 7.9400E-1,&
     & 7.6332E-1, 8.3629E-1, 8.1581E-1, 8.3122E-1, 8.4901E-1, 7.0150E-1,&
     & 4.4205E-1, 7.7354E-1, 7.1088E-1, 3.9328E-1, 2.3337E-1, 1.6258E-1,&
     & 1.5289E-1, 5.8849E-2, 3.5576E-2, 2.4463E-2, 1.4525E-2/           
!                                                                       
!     ASYMMETRY PARAMETER                                               
!                                                                       
      DATA DESG1 /                                                      &
     & 0.6603, 0.6581, 0.6547, 0.6383, 0.6276, 0.5997, 0.5829, 0.5873,  &
     & 0.5967, 0.6130, 0.6323, 0.6850, 0.6068, 0.6312, 0.6816, 0.7298,  &
     & 0.7574, 0.7874, 0.8124, 0.8424, 0.8301, 0.8107, 0.6143, 0.6167,  &
     & 0.4892, 0.4917, 0.6662, 0.6334, 0.6298, 0.6498, 0.7470, 0.6711,  &
     & 0.6751, 0.7538, 0.8054, 0.7797, 0.5522, 0.6575, 0.4702, 0.3719,  &
     & 0.3626, 0.3690, 0.3790, 0.3805, 0.3766, 0.3639, 0.3281/          
      DATA DESG2 /                                                      &
     & 0.6836, 0.6879, 0.6877, 0.6919, 0.6901, 0.7045, 0.7279, 0.7466,  &
     & 0.7522, 0.7568, 0.7629, 0.7700, 0.7567, 0.7617, 0.7781, 0.8289,  &
     & 0.8360, 0.8465, 0.8624, 0.8707, 0.9524, 0.8292, 0.6202, 0.6425,  &
     & 0.5777, 0.5623, 0.7610, 0.7310, 0.7247, 0.7419, 0.7782, 0.7481,  &
     & 0.7446, 0.8090, 0.8415, 0.8110, 0.6120, 0.7106, 0.5739, 0.4421,  &
     & 0.4089, 0.3979, 0.3917, 0.3853, 0.3842, 0.3829, 0.3797/          
      DATA DESG3 /                                                      &
     & 0.7718, 0.7865, 0.7907, 0.8077, 0.7801, 0.7827, 0.7871, 0.7880,  &
     & 0.7887, 0.7888, 0.7894, 0.7909, 0.7882, 0.7934, 0.8103, 0.8729,  &
     & 0.8766, 0.8844, 0.8979, 0.8997, 0.9698, 0.8318, 0.6197, 0.6420,  &
     & 0.5797, 0.5698, 0.8014, 0.7938, 0.7901, 0.8069, 0.7894, 0.8139,  &
     & 0.8086, 0.8546, 0.8691, 0.8288, 0.6394, 0.7400, 0.6495, 0.5235,  &
     & 0.4793, 0.4583, 0.4376, 0.4169, 0.4006, 0.3941, 0.3875/          
      DATA DESG4 /                                                      &
     & 0.8290, 0.8407, 0.8443, 0.8500, 0.8087, 0.7994, 0.7988, 0.7987,  &
     & 0.7988, 0.7989, 0.7998, 0.8023, 0.8011, 0.8076, 0.8331, 0.9045,  &
     & 0.9083, 0.9149, 0.9266, 0.9263, 0.9783, 0.8321, 0.6168, 0.6379,  &
     & 0.5706, 0.5673, 0.8196, 0.8324, 0.8347, 0.8549, 0.7940, 0.8621,  &
     & 0.8588, 0.8918, 0.8922, 0.8407, 0.6488, 0.7557, 0.7021, 0.6024,  &
     & 0.5533, 0.5280, 0.5016, 0.4711, 0.4396, 0.4230, 0.4058/          
      END                                           
!                                                                       
!     ***************************************************************** 
!                                                                       
      SUBROUTINE FLAYZ(ML,MODEL,ICLD,IAERSL,ZMDL,ALTZ,n_lvl,            &
     &     GNDALT,IVSA,IEMSCT)                                          
!                                                                       
!     SUBROUTINE TO CREATE FINAL LOWTRAN BOUNDRIES                      
!                                                                       
!     ZMDL COMMON /MODEL/ FINAL ALTITUDE FOR LOWTRAN                    
!     ZCLD CLOUD ALTITUDE                                               
!     ZK1 USED WITH VSA                                                 
!     ALTZ BLANK COMMON LBLRTM ALTITUDES                                
!     ZNEW ALTITUDES ABOVE THE CLOUD                                    
!     ZNEWV ALTITUDES ABOVE THE 1ST 9 VSA ALTITUDES                     
!     ZTST  =ZCLD(J)                                                    
!     ZVSA  VSA ALTITUDES                                               
!                                                                       
      COMMON /LCRD2A/ CTHIK,CALT,CEXT 
      COMMON /ZVSALY/ ZVSA(10),RHVSA(10),AHVSA(10),IHVSA(10) 
      DIMENSION ZNEWV(24),ALTZ(0:*),ZMDL( *) 
      DIMENSION ZNEW(17),ZCLD(16),ZAER(34),ZST(234) 
      DATA ZCLD/ 0.0,0.16,0.33,0.66,1.0,1.5,2.0,2.4,2.7,                &
     & 3.0,3.5,4.0,4.5,5.0,5.5,6.0/                                     
      DATA ZNEWV/1.,2.,3.,4.,5.,6.,7.,8.,9.,10.,11.,12.,                &
     & 14.,16.,18.,20.,22.,25.,30.,35.,40.,50.,70.,100./                
      DATA ZNEW/ 7.,8.,9.,10.,12.,14.,16.,18.,20.,22.,25.,30.,          &
     & 35.,40.,50.,70.,100./                                            
      DATA ZAER / 0., 1., 2., 3., 4., 5., 6., 7., 8., 9.,               &
     &           10.,11.,12.,13.,14.,15.,16.,17.,18.,19.,               &
     &           20.,21.,22.,23.,24.,25.,30.,35.,40.,45.,               &
     &           50.,70.,100.,   1000./                                 
      DATA DELZ /0.02/ 
                                                                        
      parameter (maxlay=205) 
                                                                        
      IF (IAERSL.EQ.7) GO TO 300 
!                                                                       
      IF (MODEL.EQ.0) GO TO 140 
!                                                                       
      IF (IVSA.EQ.1) THEN 
         DO 10 I = 1, 9 
            ZMDL(I) = ZVSA(I) 
   10    CONTINUE 
!                                                                       
         HMXVSA = ZVSA(9) 
         ZK1 = HMXVSA+0.01 
         IF (HMXVSA.LT.2.) ML = 33 
         IF (HMXVSA.LT.1.) ML = 34 
         IF (HMXVSA.EQ.2.) ML = 32 
         MDEL = 34-ML 
         DO 20 K = 1, ML 
            IK = K-10+MDEL 
            IF (IK.GE.1) ZMDL(K) = ZNEWV(IK) 
            IF (K.EQ.10) ZMDL(K) = ZK1 
   20    CONTINUE 
!                                                                       
         RETURN 
      ELSE 
         ML = 46 
      ENDIF 
!                                                                       
      IF (ICLD.GE.1.AND.ICLD.LE.11) GO TO 110 
      DO 30 I = 1, n_lvl 
         IF (ALTZ(I-1).GT.100.) GO TO 40 
         IL = I 
         ZMDL(I) = ALTZ(I-1) 
   30 END DO 
   40 ML = IL 
!                                                                       
!     IF(IEMSCT.NE.0) ZMDL(ML)=100.                                     
!                                                                       
      IF (GNDALT.LE.0.) GO TO 60 
      DALT = (6.-GNDALT)/6. 
      IF (DALT.LE.0.) GO TO 60 
!                                                                       
      DO 50 I = 1, 6 
         ZMDL(I) = REAL(I-1)*DALT+GNDALT 
   50 END DO 
   60 IF (ICLD.EQ.18.OR.ICLD.EQ.19) THEN 
!******%%%%%%%%                                                         
!         CLDD = 0.1*CTHIK                                              
!         CLD0 = CALT-0.5*CLDD                                          
!         CLD0 = MAX(CLD0,0.)                                           
!         CLD1 = CLD0+CLDD                                              
!         CLD2 = CLD1+CTHIK-CLDD                                        
!         CLD3 = CLD2+CLDD                                              
                                                                        
         cld1 = calt 
         cld2 =calt + cthik 
                                                                        
         cld0 = cld1 - 0.010 
         IF (CLD0.LE.0.) CLD0 = 0. 
         cld3 = cld2 + 0.010 
!                                                                       
!     find mdl lvl above cld bottom                                     
         DO 70 I = 1, ML 
            IJ = I 
            IF (ZMDL(I).LT.CLD1) GO TO 70 
            GO TO 80 
   70    CONTINUE 
                                                                        
!     abort if                                                          
         GO TO 300 
   80    mcld = ij 
!     save model levels                                                 
         DO 90 I = mcld, ML 
            ZST(I) = ZMDL(I) 
   90    CONTINUE 
!     insert cloud- make small layers at cloud bottom and top           
!     to trick path intergration in geo                                 
         ZMDL(IJ) = CLD0 
         ZMDL(IJ+1) = CLD1 
         ZMDL(IJ+2) = CLD2 
         ZMDL(IJ+3) = CLD3 
         IJ = IJ + 3 
!     restore rest of zmdl above cloud top                              
         DO 100 I = mcld,ml 
            IF (ZST(I).LT.CLD3) GO TO 100 
            IJ = IJ+1 
            ZMDL(IJ) = ZST(I) 
  100    CONTINUE 
!                                                                       
         ml = ij 
!                                                                       
      ENDIF 
!                                                                       
      GO TO 300 
!____________________________________________________________           
!                                                                       
!     STAND CLOUD                                                       
!                                                                       
  110 continue 
                                                                        
!     icld ge 1 and le 11 to reach this point                           
                                                                        
!     cld model has 16 lvls; upper mdl atmosphere has 17 lvls           
                                                                        
      DO 120 I = 1, 16 
         ZMDL(I) = ZCLD(I)+GNDALT 
  120 END DO 
!                                                                       
      ml = 16 + 17 
                                                                        
      DO 130 i = 17, ML 
         ZMDL(I) = ZNEW(i-16) 
  130 END DO 
!                                                                       
      GO TO 300 
!____________________________________________________________           
!                                                                       
!     MODEL 7                                                           
!                                                                       
  140 CONTINUE 
!                                                                       
      ml = n_lvl 
!                                                                       
      IF (ICLD.EQ.0) GO TO 280 
      IF (ICLD.EQ.20) GO TO 280 
      IF (IVSA.EQ.1) GO TO 280 
      IF (ML.EQ.1) GO TO 280 
      KK = 0 
                                                                        
      DO 150 I = 0, n_lvl-1 
         IF (ALTZ(I).GT.6.0) GO TO 160 
         KK = I 
  150 END DO 
  160 IF (KK.LT.1) GO TO 200 
!                                                                       
      I = 1 
      J = 1 
      K = 0 
  170 ZTST = ZCLD(J) 
      IF (ZCLD(J).LT.ALTZ(0)) THEN 
         J = J+1 
         GO TO 170 
      ENDIF 
      IF (ABS(ZTST-ALTZ(K)).LT.DELZ) GO TO 180 
      IF (ZTST.LT.ALTZ(K)) THEN 
         ZMDL(I) = ZTST 
         I = I+1 
         J = J+1 
      ELSE 
         ZMDL(I) = ALTZ(K) 
         I = I+1 
         K = K+1 
      ENDIF 
      GO TO 190 
!                                                                       
  180 ZMDL(I) = ALTZ(K) 
      I = I+1 
      J = J+1 
      K = K+1 
!                                                                       
  190 IF (K.GE.KK) GO TO 200 
      IF (J.GE.17) GO TO 200 
      IF (I.GT.maxlay) GO TO 220 
      GO TO 170 
!                                                                       
  200 IF (KK.EQ.0) THEN 
         I = 1 
         KK = 1 
      ENDIF 
!                                                                       
      DO 210 M = KK, n_lvl-1 
         ZMDL(I) = ALTZ(M) 
         I = I+1 
         IF (I.GT.maxlay) GO TO 220 
  210 END DO 
!                                                                       
  220 continue 
      ML = I-1 
                                                                        
! insert levels just above and below cloud bottom and top               
                                                                        
      IF (ICLD.EQ.18.OR.ICLD.EQ.19) THEN 
!******%%%%%%%%                                                         
!         CLDD = 0.1*CTHIK                                              
!         CLD0 = CALT-0.5*CLDD                                          
!         CLD0 = MAX(CLD0,0.)                                           
!         CLD1 = CLD0+CLDD                                              
!         CLD2 = CLD1+CTHIK-CLDD                                        
!         CLD3 = CLD2+CLDD                                              
                                                                        
         cld1 = calt 
         cld2 =calt + cthik 
                                                                        
         cld0 = cld1 - 0.010 
         IF (CLD0.LE.0.) CLD0 = 0. 
         cld3 = cld2 + 0.010 
!                                                                       
         DO 225 I = 1, ML 
            IJ = I 
            IF (ZMDL(I).LT.CLD1) GO TO 225 
            GO TO 230 
  225    CONTINUE 
         GO TO 300 
  230    mcld = ij 
!     save model levels                                                 
         DO 235 I = mcld, ML 
            ZST(I) = ZMDL(I) 
  235    CONTINUE 
!     insert cloud- make small layers at cloud bottom and top           
!     to trick path intergration in geo                                 
         ZMDL(IJ) = CLD0 
         ZMDL(IJ+1) = CLD1 
         ZMDL(IJ+2) = CLD2 
         ZMDL(IJ+3) = CLD3 
         IJ = IJ + 3 
!     restore rest of zmdl above cloud top                              
         DO 240 I = mcld,ml 
            IF (ZST(I).LT.CLD3) GO TO 240 
            IJ = IJ+1 
            ZMDL(IJ) = ZST(I) 
  240    CONTINUE 
!                                                                       
         ml = ij 
!                                                                       
      ENDIF 
!                                                                       
      GO TO 300 
!____________________________________________________________________   
!                                                                       
  280 CONTINUE 
      DO 285 I = 1, ML 
         ZMDL(I) = ALTZ(I) 
  285 END DO 
!____________________________________________________________________   
!                                                                       
  300 CONTINUE 
                                                                        
                                                                        
      RETURN 
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE TRANS 
!                                                                       
!     ******************************************************************
!     CALCULATES TRANSMITTANCE VALUES BETWEEN V1 AND V2                 
!     FOR A GIVEN ATMOSPHERIC SLANT PATH                                
!                                                                       
!     MODIFIED FOR ASYMMETRY CALCULATION - JAN 1986 (A.E.R. INC.)       
!                                                                       
!     ******************************************************************
!                                                                       
!     K           WPATH(IK,K)                                           
!                                                                       
!     6    MOLECULAR (RAYLIEGH) SCATTERING                              
!     7    BOUNDRY LAYER AEROSOL (0 TO 2 KM)                            
!     12    TROPOSPHERIC AEROSOL (2-10 KM)                              
!     13    STRATOSPHERIC  AEROSOL (10-30)                              
!     14    UPPER STRATOPHERIC (ABOVE 30KM)                             
!     15    AEROSOL WEIGHTED RELATIVE HUMITY (0 TO 2 KM)                
!     16    CIRRUS CLOUDS                                               
!     ******************************************************************
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
      PARAMETER (MAXDV=2050) 
      INTEGER PHASE,DIST 
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX2(47),AWCCON(5) 
!                                                                       
      CHARACTER*8      HMOD 
!                                                                       
      COMMON /CMN/ HMOD(3),ZM(MXZMD),PF(MXZMD),TF(MXZMD),RFNDXM(MXZMD), &
     &          ZP(IM2),PP(IM2),TP(IM2),RFNDXP(IM2),SP(IM2),PPSUM(IM2), &
     &          TPSUM(IM2),RHOPSM(IM2),IMLOW,WGM(MXZMD),DENW(MXZMD),    &
     &          AMTP(MXMOL,MXPDIM)                                      
!                                                                       
      COMMON /PATHD/ PBAR(MXLAY),TBAR(MXLAY),AMOUNT(MXMOL,MXLAY),       &
     &               WN2L(MXLAY),DVL(MXLAY),WTOTL(MXLAY),ALBL(MXLAY),   &
     &               ADBL(MXLAY),AVBL(MXLAY),H2OSL(MXLAY),IPATH(MXLAY), &
     &               ITYL(MXLAY),SECNTA(MXLAY),HT1,HT2,ALTZ(0:MXLAY),   &
     &               PZ(0:MXLAY),TZ(0:MXLAY)                            
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
!                                                                       
      COMMON /MODEL/ ZMDL(MXZMD),PMM(MXZMD),TMM(MXZMD),                 &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
                                                                        
!                                                                       
      COMMON /RAIN/ RNPATH(IM2),RRAMTK(IM2) 
      COMMON /LCRD1/ MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRNT,TBOUND,SALB 
      COMMON /LCRD2/ IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,   &
     &     RAINRT                                                       
      COMMON /LCRD3/ H1,H2,ANGLE,RANGE,BETA,RE,LEN 
      COMMON /LCRD4/ V1,V2,DV 
      COMMON /CNSTNS/ PI,CA,DEG,GCAIR,BIGNUM,BIGEXP 
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,N_LVL,JH1 
      COMMON /AER/ XX1,XX2,XX3,XX4,XX5,                                 &
     &     YY1,YY2,YY3,YY4,YY5,ZZ1,ZZ2,ZZ3,ZZ4,ZZ5                      
      CHARACTER*8      XID,       HMOLID,      YID 
      Real*8               SECANT,       XALTZ 
      COMMON /FILHDR/ XID(10),SECANT,PAVE,TAVE,HMOLID(60),XALTZ(4),     &
     &     WK(60),PZL,PZU,TZL,TZU,WN2   ,DVP,V1P,V2P,TBOUNF,EMISIV,     &
     &     FSCDID(17),NMOL,LAYER,YI1,YID(10) ,LSTWDF                    
      REAL*8           VI1,VI2,V1P,V2P,VV,v_mid 
      COMMON /LPANEL/ VI1,VI2,DVV,NLIMAP 
      COMMON /ZOUTP/ ZOUT(MXLAY),SOUT(MXLAY),RHOSUM(MXLAY),             &
     &     AMTTOT(MXMOL),AMTCUM(MXMOL),ISKIP(MXMOL)                     
      EQUIVALENCE (VI1,PNLHDR(1)) 
      EQUIVALENCE (FSCDID(17),NLIM) 
      EQUIVALENCE (XID(1),XFILHD(1)) 
      DIMENSION XFILHD(2),PNLHDR(2),SRAI(MAXDV) 
      DIMENSION ABST(MAXDV),SCTT(MAXDV),ASYT(MAXDV),ASYDM(MAXDV) 
      DIMENSION ABST_st(MAXDV),SCTT_st(MAXDV),ASYT_st(MAXDV),           &
     &     ASYDM_st(MAXDV)                                              
      DIMENSION VID(6),VL10(5),SUMEXT(MAXDV) 
      DATA VID/0.1,0.2,0.5,1.0,2.0,5.0/ 
      DATA VL10/25.,50.,125.,250.,500./ 
      DVP = DV 
      IENT = 0 
      SUMA = 0. 
      FACTOR = 0.5 
!                                                                       
!     CC                                                                
!     CC    FREQUENCY CAN GO BELOW 350 CM-1 FOR LBLRTM                  
!     CC                                                                
!                                                                       
      V2 = MIN(V2,50000.) 
      DV = MAX(DV,5.) 
      ICOUNT = 0 
      IEMISS = 0 
      IF (IEMSCT.EQ.1.OR.IEMSCT.EQ.2) IEMISS = 1 
      TCRRIS = EXP(-W(16)*2.) 
!                                                                       
!     234  FORMAT(2F8.4)                                                
!     CC                                                                
!     CC   SET LOWTRAN DV DEPENDING ON FREQUENCY RANGE                  
!     CC   CAN BE 0.1,0.2,0.5,1.0,2.0 OR 5.0                            
!     CC                                                                
!                                                                       
      IF (V2.GT.300) THEN 
         V1 = REAL(INT(V1/5.0+0.1))*5.0 
         V2 = REAL(INT(V2/5.0+0.1))*5.0 
      ENDIF 
      V2 = MAX(V2,V1) 
      VDEL = V2-V1 
      IF (V1.GT.350.) VIDV = 5.0 
      IF (V1.GT.350.) GO TO 70 
      IF (V1.LE.10.) THEN 
         DO 10 I = 1, 4 
            IF (VDEL.LE.VL10(I)) GO TO 20 
   10    CONTINUE 
         IC = 5 
         GO TO 30 
   20    IC = I 
   30    CONTINUE 
         VIDV = VID(IC) 
      ELSE 
         DO 40 I = 4, 5 
            IF (VDEL.LE.VL10(I)) GO TO 50 
   40    CONTINUE 
         IC = 6 
         GO TO 60 
   50    IC = I 
   60    CONTINUE 
         VIDV = VID(IC) 
      ENDIF 
   70 CONTINUE 
      NLIM = (VDEL/VIDV)+5. 
      DVP = VIDV 
      V1 = V1-2*DVP 
      V2 = V2+2*DVP 
      V1P = V1 
      V2P = V2 
      WRITE (IPR,900) V1,V2,DVP 
      RMAXDV =  REAL(MAXDV) 
      IF ((V2-V1)/DV.GT.RMAXDV) STOP 'TRANS; (V2-V1)/DV GT MAXDV ' 
      DO 80 I = 1, MAXDV 
         ABST(I) = 0. 
         SCTT(I) = 0. 
         ASYT(I) = 0. 
         SRAI(I) = 0. 
         ASYDM(I) = 0. 
         ABST_st(I) = 0. 
         SCTT_st(I) = 0. 
         ASYT_st(I) = 0. 
         ASYDM_st(I) = 0. 
   80 END DO 
      REWIND IEXFIL 
      CALL BUFOUT (IEXFIL,XFILHD(1),NFHDRF) 
      IF (ICLD.EQ.20.AND.V1.LT.350.) WRITE (IPR,905) 
      NLIMAP = NLIM 
      XKT0 = 0.6951*296. 
      BETA0 = 1./XKT0 
!                                                                       
!     **   BEGINING OF   LAYER   LOOP                                   
!                                                                       
      VI1 = V1 
      VI2 = V2 
      mid_v = nlim/2 
      v_mid = v1 + dvp*real(mid_v-1) 
                                                                        
!     initialize flag for buffering out and output layer count          
                                                                        
      i_bufout = 1 
      laycnt   = 1 
!                                                                       
      do nv = 1,nlim 
         sumext(nv) = 0. 
      enddo 
                                                                        
      DO 130 IK = IKLO, IKMAX 
         W7 = WPATH(IK,7) 
         W12 = WPATH(IK,12) 
         W15 = WPATH(IK,15) 
         IF (W7.GT.0.0.AND.ICH(1).LE.7) W15 = W15/W7 
         IF (W12.GT.0.0.AND.ICH(1).GT.7) W15 = W15/W12 
!                                                                       
!        INVERSE OF LOG REL HUM                                         
!                                                                       
         W(15) = 100.-EXP(W15) 
         IF (W7.LE.0.0.AND.ICH(1).LE.7) W(15) = 0. 
         IF (W12.LE.0.0.AND.ICH(1).GT.7) W(15) = 0. 
!                                                                       
!        **   LOAD AEROSOL EXTINCTION AND ABSORPTION COEFFICIENTS       
!                                                                       
!        CC                                                             
!        CC    LOAD EXTINCTIONS AND ABSORPTIONS FOR 0.2-200.0 UM (1-46) 
!        CC                                                             
!                                                                       
         CALL EXABIN 
!                                                                       
!        CC                                                             
!                                                                       
         VI = V1 
         VI = VI-VIDV 
         NV = 0 
         XKT = 0.6951*TBBY(IK) 
         BETAR = 1./XKT 
                                                                        
         rad_mid = RADFN(v_mid,XKT) 
                                                                        
!                                                                       
!        CC                                                             
!        CC   BEGINNING OF FREQUENCY LOOP                               
!        CC                                                             
!                                                                       
   90    CONTINUE 
!                                                                       
!        CC                                                             
!                                                                       
         CSSA = 1. 
         ASYMR = 1. 
         NV = NV+1 
         VI = VI+VIDV 
         V = ABS(VI) 
         VV = V 
!                                                                       
         SCTMOL = RAYSCT(V)*WPATH(IK,6) 
!                                                                       
         DVV = VIDV 
!                                                                       
         RADFT = RADFN(VV,XKT) 
         RADFT0 = RADFN(VV,XKT0) 
!                                                                       
!        CC                                                             
!        CC    AEROSOL ATTENUATIONS                                     
!        CC                                                             
!                                                                       
         TRAIN = 0.0 
!                                                                       
         CALL AEREXT (V,IK,RADFT) 
!                                                                       
         EXT = XX1*WPATH(IK,7)+XX2*WPATH(IK,12)+XX3*WPATH(IK,13)+XX4*   &
         WPATH(IK,14)+XX5*WPATH(IK,16)                                  
         ABT = YY1*WPATH(IK,7)+YY2*WPATH(IK,12)+YY3*WPATH(IK,13)+YY4*   &
         WPATH(IK,14)+YY5*WPATH(IK,16)                                  
!                                                                       
!        ASYMMETRY FACTOR IS WEIGHTED AVERAGE                           
!                                                                       
!        CC   ASY=(ZZ1*(XX1-YY1)*WPATH(IK,7)+ZZ2*(XX2-YY2)*WPATH(IK,12)+
!        CC  + ZZ3*(XX3-YY3)*WPATH(IK,13)+ZZ4*(XX4-YY4)*WPATH(IK,14))/  
!        CC  + ((XX1-YY1)*WPATH(IK,7)+(XX2-YY2)*WPATH(IK,12)+           
!        CC  + (XX3-YY3)*WPATH(IK,13)+(XX4-YY4)*WPATH(IK,14)+SCTMOL)    
!                                                                       
         ASY = (ZZ1*(XX1-YY1)*WPATH(IK,7)+ZZ2*(XX2-YY2)*WPATH(IK,12)+   &
         ZZ3 *(XX3-YY3)*WPATH(IK,13)+ZZ4*(XX4-YY4)*WPATH(IK,14)+ZZ5*(   &
         XX5- YY5)*WPATH(IK,16))                                        
         SCT = EXT-ABT 
         IF (VV.GE.350.AND.ICLD.EQ.20) ABT = ABT+(WPATH(IK,16)*2./RADFT) 
!                                                                       
!        CC                                                             
!        CC   ADD CONTRIBUTION OF CLOUDS AND RAIN                       
!        CC                                                             
!                                                                       
         IF (RRAMTK(IK).NE.0.0) THEN 
            TRAIN = TNRAIN(RRAMTK(IK),VV,TBBY(IK),RADFT) 
            IF (V.LT.250.) THEN 
               IF (ICLD.LE.11) PHASE = 1 
               IF (ICLD.GT.11) PHASE = 2 
               DIST = 1 
!                                                                       
!              CALL SCATTERING ROUTINE TO OBTAIN ASYMMTRY FACTOR AND RAT
!              OF ABSORPTION TO EXTINCTION DUE TO RAIN WITHIN RANGE OF  
!              19 TO 231 GHZ                                            
!              EXTRAPOLATE ABOVE AND BELOW THAT FREQ RANGE              
!                                                                       
               CALL RNSCAT (V,RRAMTK(IK),TBBY(IK),PHASE,DIST,IK,CSSA,   &
               ASYMR,IENT)                                              
               IENT = IENT+1 
            ELSE 
               CSSA = 0.5 
               ASYMR = 0.85 
            ENDIF 
         ENDIF 
!                                                                       
!        SET EXT DUE TO RAIN FOR LAYER                                  
!                                                                       
         RNEXPT = TRAIN*RNPATH(IK) 
!                                                                       
!        PUT RADIATION  CLD BACK IN                                     
!                                                                       
         SRAI(NV) = SRAI(NV)+RNEXPT*RADFT 
!                                                                       
         ABT = ABT+RNEXPT*CSSA 
         SCT = SCT+RNEXPT*(1.-CSSA) 
         ASY = ASY+ASYMR*(1.-CSSA)*RNEXPT 
!                                                                       
!                                                                       
         SCT = SCT+SCTMOL 
!                                                                       
         EXT = SCT+ABT 
!                                                                       
         IF (IK.LE.JH1) THEN 
!                                                                       
!           DOUBLE  TANGENT PATH LAYERS                                 
!                                                                       
            SUMEXT(NV) = SUMEXT(NV)+EXT*RADFT*2.0 
            IF (IEMISS.EQ.0) THEN 
               EXT = EXT*2. 
               SCT = SCT*2. 
               ABT = ABT*2. 
            ENDIF 
         ELSE 
            SUMEXT(NV) = SUMEXT(NV)+EXT*RADFT 
         ENDIF 
!                                                                       
         IF (VV.GE.1.0) THEN 
            RADRAT = RADFT/RADFT0 
         ELSE 
            RADRAT = BETAR/BETA0 
         ENDIF 
!                                                                       
!        CC                                                             
!        CC    IF TRANSMISSION STORE THE ACCUMULATED AMOUNTS            
!        CC    IF EMISSION STORE THE AMOUNTS PER LAYER                  
!        CC                                                             
!                                                                       
         IF (IEMISS.EQ.1) THEN 
            ABST(NV) = ABST(NV)+ABT 
            SCTT(NV) = SCTT(NV)+SCT 
            ASYDM(NV) = ASYDM(NV)+SCT+SCTMOL 
            ASYT(NV) = ASYT(NV)+ASY 
         ELSE 
            ABST(NV) = ABST(NV)+ABT*RADRAT 
            SCTT(NV) = SCTT(NV)+SCT*RADRAT 
         ENDIF 
                                                                        
!                                                                       
!        CC                                                             
!        CC    CIRRUS CLOUD SHOULD BE ADDED IN LATER                    
!        CC                                                             
!                                                                       
                                                                        
         IF (ASYDM(nv).GT.0.) THEN 
            ASYT(nv) = ASYT(nv)/ASYDM(nv) 
         ELSE 
            ASYT(nv) = 0. 
         ENDIF 
                                                                        
         IF (VI.LT.V2) GO TO 90 
!                                                                       
!        CC                                                             
!        CC    ***END OF FREQUENCY LOOP                                 
!        CC                                                             
!        CC   BUFFER OUT ABSORPTION, SCATTERING, AND                    
!        CC   ASYMMETRY PANELS OF LAYERS BY FREQUENCY                   
!        CC   TO IEXFIL FOR USE IN LBLRTM                               
!        CC                                                             
!                                                                       
!  _____________________________________________                        
                                                                        
         IF (((IEMISS.GE.1).OR.(IK.EQ.IKMAX)) ) THEN 
                                                                        
            if (i_bufout .eq. -1) then 
!     a thin layer has been identified                                  
!     obtain absorption, scattering and asymmetry for combined layer    
            do 110 i=1,nlim 
                                                                        
            abst_st(i) = abst_st(i)+abst(i) 
            sctt_sum_i = sctt_st(i)+sctt(i) 
                                                                        
            if (sctt_sum_i .gt. 0) then 
            f_asym = sctt(i)/sctt_sum_i 
!    obtain a weighted average for the asymmetry paramter               
!                     asyt_st(i) = (1-f_asym)*asyt_st(i)+f_asym*asyt(i) 
            asyt_st(i) = asyt_st(i) - f_asym*(asyt_st(i)-asyt(i)) 
            else 
            asyt_st(i) = 0. 
            endif 
                                                                        
            sctt_st(i) = sctt_sum_i 
                                                                        
  110       continue 
            else 
            do 115 i=1,nlim 
            abst_st(i) = abst(i) 
            sctt_st(i) = sctt(i) 
            asyt_st(i) = asyt(i) 
  115       continue 
            endif 
!  _____________________________________________                        
                                                                        
            if (ikmax.ne.1 .and. abs(zmdl(ik+1)-zout(laycnt+1))         &
            .gt.0.001) then                                             
            i_bufout = -1 
            go to 122 
            else 
!                                                                       
            CALL BUFOUT (IEXFIL,PNLHDR(1),NPHDRF) 
!                                                                       
            CALL BUFOUT (IEXFIL,ABST_st(1),NLIM) 
            CALL BUFOUT (IEXFIL,SCTT_st(1),NLIM) 
            CALL BUFOUT (IEXFIL,ASYT_st(1),NLIM) 
!                                                                       
            if (laycnt.eq.1) write(ipr,935) v_mid 
!                                                                       
            write(ipr,940) laycnt,zout(laycnt),zout(laycnt+1), rad_mid* &
            ABST_st(mid_v),rad_mid*sctt_st(mid_v), asyt_st(mid_v)       
!                                                                       
            DO 120 I = 1, nlim 
               ABST_st(I) = 0. 
               SCTT_st(I) = 0. 
               ASYT_st(I) = 0. 
               ASYDM_st(I) = 0. 
  120       CONTINUE 
            laycnt = laycnt +1 
            i_bufout = 1 
            endif 
         ENDIF 
!                                                                       
  122    continue 
!                                                                       
         DO 125 I = 1, MAXDV 
            ABST(I) = 0. 
            SCTT(I) = 0. 
            ASYT(I) = 0. 
            ASYDM(I) = 0. 
  125    CONTINUE 
!                                                                       
!        ***END OF LAYER LOOP***    (IK LOOP)                           
!                                                                       
  130 END DO 
!                                                                       
!                                                                       
      REWIND IEXFIL 
      VI = V1-VIDV 
      DO 140 NV = 1, NLIM 
         VI = VI+VIDV 
         IF (ICOUNT.EQ.0.OR.ICOUNT.EQ.50) THEN 
            ICOUNT = 0 
            IF (VI.GT.100.) WRITE (IPR,910) 
            IF (VI.LE.100.) WRITE (IPR,915) 
         ENDIF 
         ICOUNT = ICOUNT+1 
         IF (SUMEXT(NV).LE.BIGEXP) THEN 
            TRAN = EXP(-SUMEXT(NV)) 
         ELSE 
            TRAN = 1.0/BIGNUM 
         ENDIF 
         IF (SRAI(NV).LE.BIGEXP) THEN 
            TR1 = EXP(-SRAI(NV)) 
         ELSE 
            TR1 = 1.0/BIGNUM 
         ENDIF 
         IF (VI.GT.V1) FACTOR = 1.0 
         IF (VI.GE.V2) FACTOR = 0.5 
         SUMA = SUMA+FACTOR*DVV*(1.0-TRAN) 
         IF (VI.GT.100.) ALAM = 1.0E+04/VI 
         IF (VI.LE.100.) ALAM = VI*29.979 
         WRITE (IPR,920) VI,ALAM,TRAN,TR1 
  140 END DO 
      IF (ICLD.EQ.20) WRITE (IPR,925) TCRRIS 
      AB = 1.0-SUMA/(VI-V1) 
      WRITE (IPR,930) V1,VI,SUMA,AB 
!                                                                       
      RETURN 
!                                                                       
!     **   FORMAT STATEMENTS FOR SPECTRAL DATA                          
!     **   PAGE HEADERS                                                 
!                                                                       
  900 FORMAT(/,'1 LOWTRAN WAVENUMBER INTERVAL- V1P, V2P, DVP:',         &
     &                                                  3F10.3,//)      
  905 FORMAT(' CIRRUS NOT DEFINED BELOW 350 CM-1') 
  910 FORMAT ('1',/ 1X,'  FREQ WAVELENGTH  TOTAL    RAIN '/) 
  915 FORMAT ('1',/ 1X,'  FREQ FREQUENCY   TOTAL    RAIN  ',            &
     &                 /2X,' CM-1    GHZ  ',2(4X,'TRANS')/)             
  920 FORMAT(1X,F7.1,F8.3,10F9.4,F12.3) 
  925 FORMAT('0TRANSMISSION DUE TO CIRRUS = ',F10.4) 
  930 FORMAT('0INTEGRATED ABSORPTION FROM ',F9.3,' TO ',F9.3,' CM-1 =', &
     & F10.2,' CM-1',/,' AVERAGE TRANSMITTANCE =',F6.4,/)               
  935 FORMAT(//,'    LAYER OPTICAL PROPERTIES AT',f12.3,                &
     & ' FOR THE PATH FROM Z(J) TO Z(J+1)',//,                          &
     & T3,'J',T10,'Z(J)',T19,'Z(J+1)',                                  &
     & T27,'ABSORB',T37,'SCATTR',T47,'ASYM PAR',/,                      &
     & T10,'(KM)',T20,'(KM)')                                           
  940 format(i4,2f10.3,1p,3e10.2) 
!                                                                       
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE RNSCAT(V,R,TT,PHASE,DIST,IK,CSSA,ASYMR,IENT) 
!                                                                       
!     ******************************************************************
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
      INTEGER PHASE,DIST 
      DIMENSION SC(3,4) 
!                                                                       
!     ARGUMENTS:                                                        
!                                                                       
!     F = FREQUENCY (GHZ)                                               
!     R = RAINFALL RATE (MM/HR)                                         
!     T = TEMPERATURE (DEGREES CELSIUS)                                 
!     PHASE = PHASE PARAMETER (1=WATER, 2=ICE)                          
!     DIST = DROP SIZE DISTRIBUTION PARAMETER                           
!     (1=MARSHALL-PALMER, 2=BEST)                                       
!                                                                       
!     RESULTS:                                                          
!                                                                       
!     SC(1) = ABSORPTION COEFFICIENT (1/KM)                             
!     SC(2) = EXTINCTION COEFFICIENT (1/KM)                             
!     SC(I),I=3,NSC = LEGENDRE COEFFICIENTS #I-3  (NSC=10)              
!     2=BAD RAINFALL RATE, 3=BAD TEMPERATURE,                           
!     4=BAD PHASE PARAMETER, 5=BAD DROP SIZE DISTRIBUTION               
!                                                                       
!     THE INTERNAL DATA:                                                
!                                                                       
      DIMENSION FR(9),TEMP(3) 
!                                                                       
!     FR(I),I=1,NF = TABULATED FREQUENCIES (GHZ)  (NF=9)                
!     TEMP(I),I=1,NT = TABULATED TEMPERATURES  (NT=3)                   
!                                                                       
!     THE BLOCK-DATA SECTION                                            
!                                                                       
      DATA RMIN,RMAX/0.,50./,NF/9/,NT/3/,NSC/4/,MAXI/3/ 
      DATA TK/273.15/,CMT0/1.0/,C7500/0.5/,G0/0.0/,G7500/0.85/ 
      DATA (TEMP(I),I=1,3)/-10.,0.,10./ 
      DATA (FR(I),I=1,9)/19.35,37.,50.3,89.5,100.,118.,130.,183.,231./ 
!                                                                       
!     THIS SUBROUTINE REQUIRES FREQUENCIES IN GHZ                       
!                                                                       
      NOPR = 0 
      IF (IK.EQ.1) NOPR = 1 
      IF (IENT.GT.1) NOPR = 0 
      F = V*29.97925 
      FSAV = F 
      RSAV = R 
      TSAV = T 
      INT = 0 
!                                                                       
!     CONVERT TEMP TO DEGREES CELSIUS                                   
!                                                                       
      T = TT-TK 
!                                                                       
!     FREQ RANGE OF DATA 19.35-231 GHZ IF LESS THAN 19.35               
!     SET UP PARAMETERS FOR INTERPOLATION                               
!                                                                       
      IF (F.LT.FR(1)) THEN 
         FL = 0.0 
         FM = FR(1) 
         INT = 1 
         IF (NOPR.GT.0) WRITE (IPR,900) 
      ENDIF 
!                                                                       
!     IF MORE THAN 231 GHZ SET UP PARAMETERS FOR EXTRAPOLATION          
!                                                                       
      IF (F.GT.FR(NF)) THEN 
         FL = FR(NF) 
         FM = 7500. 
         INT = 2 
         IF (NOPR.GT.0) WRITE (IPR,900) 
      ENDIF 
!                                                                       
!     TEMP RANGE OF DATA IS -10 TO +10 DEGREES CELCIUS                  
!     IF BELOW OR ABOVE EXTREME SET AND DO CALCULATIONS AT EXTREME      
!                                                                       
      IF (T.LT.TEMP(1)) THEN 
         T = TEMP(1) 
         IF (NOPR.GT.0) WRITE (IPR,905) 
      ENDIF 
!                                                                       
      IF (T.GT.TEMP(3)) THEN 
         T = TEMP(3) 
         IF (NOPR.GT.0) WRITE (IPR,905) 
      ENDIF 
!                                                                       
!     RAIN RATE OF DATA IS FOR 0-50 MM/HR                               
!     IF GT 50 TREAT CALCULATIONS AS IF 50 MM/HR WAS INPUT              
!                                                                       
      IF (R.GT.50) THEN 
         R = 50. 
         IF (NOPR.GT.0) WRITE (IPR,910) 
      ENDIF 
!                                                                       
      KI = 1 
!                                                                       
!     FIGURE OUT THE SECOND INDEX                                       
!                                                                       
   10 J = PHASE+2*DIST 
!                                                                       
!                                                                       
!     GET THE TEMPERATURE INTERPOLATION PARAMETER ST                    
!     IF NEEDED AND AMEND THE SECOND INDEX                              
!                                                                       
      CALL BS (J,T,TEMP,NT,ST) 
!                                                                       
!     FIGURE OUT THE THIRD INDEX AND THE FREQUENCY INTERPOLATION        
!     PARAMETER SF                                                      
!                                                                       
      CALL BS (K,F,FR,NF,SF) 
!                                                                       
!     INITIALIZE SC                                                     
!                                                                       
      DO 20 I = 1, NSC 
         SC(KI,I) = 0. 
   20 END DO 
      SC(KI,3) = 1. 
!                                                                       
!     NOW DO THE CALCULATIONS                                           
!                                                                       
!     THE WATER CONTENT IS                                              
!                                                                       
      IF (DIST.EQ.1) THEN 
         WC = .0889*R**.84 
      ELSE 
         WC = .067*R**.846 
      ENDIF 
!                                                                       
!     FOR A TEMPERATURE DEPENDENT CASE, I.E.                            
!                                                                       
      IF (J.LT.3) THEN 
         S1 = (1.-SF)*(1.-ST) 
         S2 = (1.-SF)*ST 
         S3 = SF*(1.-ST) 
         S4 = SF*ST 
         DO 30 I = 1, MAXI 
            IF (I.LE.2) THEN 
               ISC = I 
            ELSE 
               ISC = I+1 
            ENDIF 
            SC(KI,ISC) = S1*TAB(I,J,K,WC)+S2*TAB(I,J+1,K,WC)+S3*TAB(I,J,&
            K+1,WC)+S4*TAB(I,J+1,K+1,WC)                                
   30    CONTINUE 
!                                                                       
!        FOR A TEMPERATURE INDEPENDENT CASE                             
!                                                                       
      ELSE 
         S1 = 1.-SF 
         S2 = SF 
         DO 40 I = 1, MAXI 
            IF (I.LE.2) THEN 
               ISC = I 
            ELSE 
               ISC = I+1 
            ENDIF 
            SC(KI,ISC) = S1*TAB(I,J,K,WC)+S2*TAB(I,J,K+1,WC) 
   40    CONTINUE 
      ENDIF 
      F = FSAV 
      IF (INT.EQ.3) GO TO 50 
      IF (INT.EQ.4) GO TO 60 
      IF (INT.EQ.0) THEN 
         CSSA = SC(KI,1)/SC(KI,2) 
         CSSA = MIN(CSSA,1.0) 
         ASYMR = SC(KI,4)/3.0 
         F = FSAV 
         R = RSAV 
         T = TSAV 
         RETURN 
      ENDIF 
      IF (INT.EQ.1) THEN 
         INT = 3 
         F = FM 
         KI = 2 
      ENDIF 
      IF (INT.EQ.2) THEN 
         INT = 4 
         F = FL 
         KI = 3 
      ENDIF 
      GO TO 10 
   50 CONTINUE 
      FDIF = FM-F 
      FTOT = FM-FL 
      CM = SC(KI,1)/SC(KI,2) 
      CM = MIN(CM,1.0) 
      CL = CMT0 
      AM = SC(KI,4)/3.0 
      AL = G0 
      GO TO 70 
   60 CONTINUE 
      FDIF = FM-F 
      FTOT = FM-FL 
      CM = C7500 
      CL = SC(KI,1)/SC(KI,2) 
      CL = MIN(CL,1.0) 
      AM = G7500 
      AL = SC(KI,4)/3.0 
   70 CTOT = CM-CL 
      CAMT = FDIF*CTOT/FTOT 
      CSSA = CM-CAMT 
      ATOT = AM-AL 
      AAMT = FDIF*ATOT/FTOT 
      ASYMR = AM-AAMT 
      F = FSAV 
      R = RSAV 
      T = TSAV 
      RETURN 
!                                                                       
  900 FORMAT(2X,'***  THE ASYMMETRY PARAMETER DUE TO RAIN IS BASED ON', &
     & 'DATA BETWEEN 19 AND 231 GHZ',                                   &
     & /2X,'***  EXTRAPOLATION IS USED FOR FREQUENCIES LOWER AND',      &
     & 'HIGHER THAN THIS RANGE')                                        
  905 FORMAT(2X,'***  TEMPERATURE RANGE OF DATA IS -10 TO +10 ',        &
     &'DEGREES CELSIUS',/2X,'***  BEYOND THESE VALUES IT IS ',          &
     &'TREATED AS IF AT THE EXTREMES')                                  
  910 FORMAT(2X,'***  RAIN RATES BETWEEN 0 AND 50 MM/HR ARE',           &
     &'WITHIN THIS DATA RANGE',/2X,'***  ABOVE THAT THE ASYMMETRY',     &
     &' PARAMETER IS CALCULATED FOR 50 MM/HR')                          
!                                                                       
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE BS(I,A,B,N,S) 
!                                                                       
!     ******************************************************************
!                                                                       
      DIMENSION B(9) 
!                                                                       
!     THIS SUBROUTINE DOES THE BINARY SEARCH FOR THE INDEX I            
!     SUCH THAT A IS IN BETWEEN B(I) AND B(I+1)                         
!     AND CALCULATES THE INTERPOLATION PARAMETER S                      
!     SUCH THAT A=S*B(I+1)+(1.-S)*B(I)                                  
!                                                                       
      I = 1 
      J = N 
   10 M = (I+J)/2 
      IF (A.LE.B(M)) THEN 
         J = M 
      ELSE 
         I = M 
      ENDIF 
      IF (J.GT.I+1) GO TO 10 
      S = (A-B(I))/(B(I+1)-B(I)) 
      RETURN 
      END                                           
      FUNCTION TAB(II,JJ,KK,WC) 
!                                                                       
!     ******************************************************************
!                                                                       
!     THE INTERNAL DATA:                                                
!                                                                       
      DIMENSION A(9,6,9),ALPHA(9,6,9),A1(5),A2(5),ALPHA1(5),            &
     &    MAXI(6,9)                                                     
!                                                                       
!     A(1,J,K),J=1,3 = POWER LAW COEFFICIENT FOR THE ABSORPTION         
!     COEFICIENT FOR THE MARSHALL-PALMER WATER DROP SIZE                
!     DISTRIBUTION FOR TEMPERATURE=10.*(J-2) AND FREQUENCY=FR(K)        
!     A(2,J,K),J=1,3 = THE SAME FOR THE EXTINCTION COEFFICIENT          
!     A(I,J,K),J=1,3,I=3,9 = THE SAME FOR THE LEGENDRE                  
!     COEFFICIENT #I-2                                                  
!     A(I,4,K),I=1,9 = THE SAME AS A(I,2,K), BUT FOR ICE                
!     (NO TEMPERATURE DEPENDENCE)                                       
!     A(I,5,K),I=1,9 = THE SAME AS A(I,2,K), BUT FOR THE BEST DROP      
!     SIZE DISTRIBUTION (NO TEMPRATURE DEPENDENCE)                      
!     A(I,6,K),I=1,9 = THE SAME AS A(I,5,K), BUT FOR ICE                
!     ALPHA(I,J,K) = THE POWER EXPONENET CORRESPONDING TO A(I,J,K)      
!     MAXI(J,K): TAB(I,J,K,WC)=0. IF I.GT.MAXI(J,K)                     
!     A1, A2 AND ALPHA1 = THE POWER-LINEAR LAW COEFFICIENTS AND         
!     EXPONENT FOR THE EXCEPTIONAL CASES                                
!                                                                       
!     THE FORMULA:                                                      
!                                                                       
!     SC=A*WC**ALPHA IF ABS(A).GT.10.**-8,                              
!     SC=A1*WC**ALPHA1+A2*WC IF ABS(A).LE.10.**-8,                      
!     A1, A2 AND ALPHA1 ARE INDEXED BY INT(ALPHA)                       
!                                                                       
!     THE BLOCK-DATA SECTION                                            
!                                                                       
      DATA ((MAXI(J,K),J=1,6),K=1,9)/4*6,14*7,36*9/ 
      DATA (A1(I),A2(I),ALPHA1(I),I=1,5)/.611,-.807,1.18,.655,-.772,1.08&
     & ,.958,-1.,.99,.538,-.696,1.27,1.58,-1.50,1.02/                   
      DATA ((A(I,J,1),J=1,6),I=1,7)/.284,.285,.294,.001336,.36,.00146,  &
     &.363,.365,.375,.0148,.528,.0317,3*0.,.3147,0.,.438,               &
     &.4908,.487,.482,.528,.478,.538,3*.0350,.0470,.0482,.0647,         &
     &.002,.00205,.00208,.00285,.0037,.0048,4*0.,.00021,.00016/         
      DATA ((ALPHA(I,J,1),J=1,6),I=1,7)/1.214,1.233,1.25,1.035,1.22,    &
     &1.076,1.291,1.31,1.323,1.63,1.334,1.74,3.1,2.1,1.1,5.005,4.1,.555,&
     &-.009,-.013,-.016,.028,-.019,.031,.398,.399,.4,.473,.461,.525,    &
     &1.06,.97,1.03,1.03,1.18,1.16,4*0.,1.3,1.3/                        
      DATA ((A(I,J,2),J=1,6),I=1,7)/.8,.77,.73,.00344,.76,.0043,        &
     &1.28,1.27,1.24,.162,1.43,.332,.254,.172,0.,.93,.32,1.29,          &
     &.5,.486,.4706,.69,.481,.8,.0965,.0936,.09,.159,.151,.234,         &
     &.0234,.0228,.0221,.034,.057,.065,2*.0037,.0035,.005,.011,.0106/   
      DATA ((ALPHA(I,J,2),J=1,6),I=1,7)/2*1.1,1.09,1.13,1.02,1.19,      &
     &2*1.20,1.15,1.66,1.14,1.7,.29,.42,5.1,.39,.66,.44,                &
     &0.,-.01,-.0199,.12,-.01,.17,.386,.378,.2,.48,.485,.56,            &
     &.92,.91,.90,.97,1.15,1.13,1.32,1.26,1.32,1.41,1.69,1.67/          
      DATA ((A(I,J,3),J=1,6),I=1,7)/1.11,1.07,1.02,.0059,.92,.00775,    &
     &1.88,1.89,1.87,.43,1.80,.77,.512,.425,.336,1.25,.677,1.55,        &
     &.561,.534,.506,.867,.6,1.07,.175,.165,.156,.300,.292,.49,         &
     &.066,.064,.061,.105,.16,.22,                                      &
     &.0169,.0162,.0156,.023,.055,.056/                                 
      DATA ((ALPHA(I,J,3),J=1,6),I=1,7)/2*1.01,1.,1.18,.92,1.23,        &
     &3*1.1,1.58,1.,1.57,.264,.320,.445,.27,.416,.27,                   &
     &.048,.033,.018,.168,.09,.224,.429,.417,.402,.501,.528,.62,        &
     &2*.83,.82,.9,1.01,1.11,1.22,1.21,1.2,1.23,1.51,1.53/              
      DATA ((A(I,J,4),J=1,6),I=1,9)/1.51,1.49,1.44,.0163,1.12,.0194,    &
     &2.73,2.77,2.79,1.61,2.18,1.9,1.14,1.054,.961,1.57,1.36,1.66,      &
     &.99,.93,.87,1.31,1.33,1.63,.594,.557,.516,.77,1.02,1.16,          &
     &.352,.334,.315,.43,.73,.8,.171,.163,.154,.18,.47,.43,             &
     &.084,.081,.077,.106,.29,.32,.037,.036,.034,.029,.16,.11/          
      DATA ((ALPHA(I,J,4),J=1,6),I=1,9)/.87,.86,.85,1.181,.79,1.16,     &
     &.93,.92,.91,1.3,.84,1.18,.188,.21,.24,.09,.21,.06,                &
     &2*.2,.19,.175,.275,.2,2*.461,.459,.39,.51,.41,                    &
     &2*.66,.65,.58,.70,.64,2*.94,.93,.84,1.03,1.01,                    &
     &3*1.22,1.09,1.37,1.4,1.58,1.56,1.54,1.5,1.8,1.9/                  
      DATA ((A(I,J,5),J=1,6),I=1,9)/1.55,1.53,1.49,.0194,1.14,.0225,    &
     &2.82,2.87,2.90,1.91,2.22,2.,1.266,1.184,1.093,1.60,1.48,1.65,     &
     &1.13,1.07,1.,1.4,1.51,1.69,.74,.698,.649,.87,1.24,1.23,           &
     &.465,.444,.418,.52,.94,.91,.248,.238,.225,.24,.65,.53,            &
     &.132,.128,.122,.15,.43,.47,.065,.063,.06,.045,.26,.16/            
      DATA ((ALPHA(I,J,5),J=1,6),I=1,9)/.85,.84,.83,1.168,.78,1.15,     &
     &.9,.89,.88,1.23,.82,1.11,.172,.191,.216,.071,.181,.04,            &
     &.222,.221,.22,.165,.274,.17,.452,.454,.456,.35,.48,.33,           &
     &.63,.68,.63,.52,.66,.55,3*.89,.76,.94,.86,                        &
     &1.14,1.13,1.12,.96,1.24,1.1,1.44,1.41,1.43,1.31,1.6,1.6/          
      DATA ((A(I,J,6),J=1,6),I=1,9)/2*1.58,1.54,.0248,1.15,.0279,       &
     &2.94,2.97,3.,2.34,2.25,2.2,1.447,1.374,1.288,1.62,1.64,1.63,      &
     &1.37,1.31,1.234,1.52,1.8,1.77,1.,.96,.898,1.01,1.6,1.3,           &
     &.68,.66,.62,.66,1.31,1.07,.41,.4,.38,.33,.99,.66,                 &
     &.25,.24,.23,.23,.71,.56,.136,.133,.127,.081,.49,.26/              
      DATA ((ALPHA(I,J,6),J=1,6),I=1,9)/.83,.81,.8,1.145,.762,1.120,    &
     &.87,.86,.85,1.14,.799,1.,.149,.165,.184,.046,.148,.014,           &
     &.232,.236,.238,.146,.255,.13,.428,.433,.438,.28,.44,.23,          &
     &3*.59,.44,.59,.43,3*.81,.64,.83,.66,                              &
     &1.02,2*1.01,.81,1.06,.89,2*1.25,1.24,1.07,1.36,1.3/               
      DATA ((A(I,J,7),J=1,6),I=1,9)/1.60,1.59,1.56,.0285,1.16,.0314,    &
     &2.98,3.02,3.05,2.6,2.26,2.3,1.546,1.481,1.4,1.63,1.72,1.62,       &
     &1.52,1.464,1.388,1.58,1.97,1.8,1.18,1.13,1.07,1.08,1.82,1.33,     &
     &.84,.82,.78,.75,1.55,1.16,.54,.53,.5,.4,1.22,.74,                 &
     &.34,.33,.32,.3,.93,.67,2*.2,.19,.112,.67,.33/                     
      DATA ((ALPHA(I,J,7),J=1,6),I=1,9)/.81,.80,.788,1.132,.753,1.105,  &
     &.85,.84,.83,1.09,.788,.95,.136,.153,.167,.033,.131,.004,          &
     &.232,.236,.241,.133,.24,.11,.411,.416,.422,.25,.40,.19,           &
     &3*.56,.4,.55,.38,2*.77,.76,.58,.76,.56,                           &
     &3*.95,.74,.97,.78,1.17,2*1.16,.98,1.23,1.11/                      
      DATA ((A(I,J,8),J=1,6),I=1,9)/2*1.60,1.58,.045,1.15,.0461,        &
     &3.08,3.09,3.1,3.3,2.27,2.32,1.849,1.81,1.75,1.628,1.98,1.606,     &
     &2.07,2.04,1.98,1.78,2.5,1.946,1.89,1.86,1.81,1.30,2.6,1.508,      &
     &1.58,1.56,1.52,1.11,2.49,1.57,1.22,1.21,1.18,.68,2.2,1.11,        &
     &2*.91,.89,.61,2.,1.18,2*.65,.64,.299,1.6,.73/                     
      DATA ((ALPHA(I,J,8),J=1,6),I=1,9)/.777,.764,.752,1.092,.729,1.057,&
     &.796,.79,.784,.96,.756,.81,.1,.108,.117,.004,.089,-.006,          &
     &.207,.210,.215,.093,.182,.075,2*.34,.35,.15,.30,.122,             &
     &3*.46,.3,.41,.28,3*.61,.42,.55,.394,                              &
     &3*.75,.56,.7,.55,2*.91,.9,.76,.87,.79/                            
      DATA ((A(I,J,9),J=1,6),I=1,9)/2*1.58,1.56,.0587,1.13,.0579,       &
     &3.09,2*3.08,3.39,2.26,2.33,2.009,1.99,1.95,1.624,2.11,1.64,       &
     &2.43,2.42,2.38,1.902,2.80,2.078,2*2.42,2.38,1.454,3.09,1.7,       &
     &2*2.2,2.17,1.4,3.1,1.91,1.87,1.88,1.85,.94,3.,1.46,               &
     &2*1.54,1.52,.93,2.8,1.64,2*1.22,1.21,.53,2.5,1.17/                
      DATA ((ALPHA(I,J,9),J=1,6),I=1,9)/.757,.746,.736,1.06,.717,1.024, &
     &.766,.764,.761,.86,.74,.763,.084,.087,.092,-.0018,.069,.007,      &
     &.183,.182,.184,.078,.148,.075,3*.29,.128,.24,.13,                 &
     &.4,2*.39,.264,.33,.256,2*.52,.51,.367,.44,.360,                   &
     &2*.63,.62,.49,.55,.47,.76,2*.75,.67,.67,.66/                      
!                                                                       
!                                                                       
      IF (II.GT.MAXI(JJ,KK)) THEN 
         TAB = 0. 
         RETURN 
      ENDIF 
      IF (ABS(A(II,JJ,KK)).GT.1.E-8) THEN 
         TAB = A(II,JJ,KK)*WC**ALPHA(II,JJ,KK) 
      ELSE 
         L = ALPHA(II,JJ,KK) 
         TAB = A1(L)*WC**ALPHA1(L)+A2(L)*WC 
      ENDIF 
      RETURN 
      END                                           
      FUNCTION RAYSCT(V) 
!                                                                       
!     RADIATION FLD OUT                                                 
!     **  MOLECULAR SCATTERING                                          
!                                                                       
                                                                        
      IF (V.LE.3000.) then 
         RAYSCT = 0. 
         else 
!                                                                       
!     The following statement previosly operative in lbllow.f has  been 
!     replaced by the expression implemented in SUBROUTINE CONTNM in    
!     module contnm.f.                                                  
!                                                                       
!***      RAYSCT = V**3/(9.26799E+18-1.07123E+09*V**2)                  
!                                                                       
!     This formulation, adopted from MODTRAN_3.5 (using approximation   
!     of Shettle et al., (Appl Opt, 2873-4, 1980) with depolarization   
!     = 0.0279, output in km-1 for T=273K & P=1 ATM) has been used.     
!                                                                       
         RAYSCT = V**3/(9.38076E18-1.08426E09*V**2) 
!                                                                       
!     V**4 FOR RADIATION FLD IN                                         
!                                                                       
         endif 
!                                                                       
         RETURN 
      END                                           
      FUNCTION TNRAIN(RR,V,TM,RADFLD) 
!                                                                       
!     CC                                                                
!                                                                       
      COMMON /CNSTNS/ PI,CA,DEG,GCAIR,BIGNUM,BIGEXP 
      COMMON /LCRD3/ H1,H2,ANGLE,RANGE,BETA,RE,LEN 
!                                                                       
!     CC   CALCULATES TRANSMISSION DUE TO RAIN AS A FUNCTION OF         
!     CC   RR=RAIN RATE IN MM/HR                                        
!     CC   OR WITHIN 350CM-1 USES THE MICROWAVE TABLE ROUTINE TO        
!     CC   OBTAIN THE EXTINCTION DUE TO RAIN                            
!     CC   RANGE=SLANT RANGE KM                                         
!     CC                                                                
!     CC   ASSUMES A MARSHALL-PALMER RAIN DROP SIZE DISTRIBUTION        
!     CC   N(D)=NZERO*EXP(-A*D)                                         
!     CC   NZERO=8.E3 (MM-1)  (M-3)                                     
!     CC   A=41.*RR**(-0.21)                                            
!     CC   D=DROP DIAMETER (CM)                                         
!     CC                                                                
!                                                                       
      REAL*8           V 
!                                                                       
      REAL NZERO 
      DATA NZERO /8000./ 
!                                                                       
!     CC                                                                
!                                                                       
      freq = V 
!                                                                       
      A = 41./RR**0.21 
!                                                                       
!     CC                                                                
!                                                                       
      IF (RR.LE.0) TNRAIN = 0. 
      IF (RR.LE.0) RETURN 
!                                                                       
!     CC                                                                
!                                                                       
      IF (FREQ.GE.350.0) THEN 
         TNRAIN = PI*NZERO/A**3 
         TNRAIN = TNRAIN/RADFLD 
      ELSE 
         TNRAIN = GMRAIN(FREQ,TM,RR) 
      ENDIF 
      RETURN 
      END                                           
!                                                                       
!     ***************************************************************** 
!                                                                       
      SUBROUTINE LAYVSA(K,RH,AHAZE,IHAZ1,ZSTF) 
!                                                                       
!     RETURNS HAZE FOR VSA OPTION                                       
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,N_LVL,JH1 
      COMMON/MODEL/ ZMDL(MXZMD),PM(MXZMD),TM(MXZMD),                    &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
!                                                                       
      COMMON /LCRD1/ MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRNT,TBOUND,SALB 
      COMMON /LCRD2/ IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,   &
     &     RAINRT                                                       
!     COMMON /MDATA/ ZDA(MXZMD),P(MXZMD),T(MXZMD),WH(MXZMD),WO(MXZMD),  
!    *     HMIX(MXZMD),CDUM1(MXZMD,7),RDUM2(MXZMD,7)                    
      COMMON /MDATA/                              WH(MXZMD),WO(MXZMD),  &
     &                 CDUM1(MXZMD,7),RDUM2(MXZMD,7)                    
      COMMON /MDATA2/ZDA(MXZMD),P(MXZMD),T(MXZMD) 
      COMMON /ZVSALY/ ZVSA(10),RHVSA(10),AHVSA(10),IHVSA(10) 
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
!                                                                       
      DIMENSION ZSTF(MXZMD) 
!                                                                       
      RH = 0. 
      AHAZE = 0 
      IHAZ1 = 0 
      IF (MODEL.EQ.0) GO TO 10 
      IF (K.GT.9) RETURN 
      ZMDL(K) = ZVSA(K) 
      RH = RHVSA(K) 
      AHAZE = AHVSA(K) 
      IHAZ1 = IHVSA(K) 
      RETURN 
!                                                                       
!     MODEL 7 CODEING                                                   
!     OLD LAYERS  AEROSOL RETURNED                                      
!                                                                       
   10 CONTINUE 
      ZVSA(10) = ZVSA(9)+0.01 
      RHVSA(10) = 0. 
      AHVSA(10) = 0. 
      IHVSA(10) = 0 
!                                                                       
!     JML=ML                                                            
!                                                                       
      IF (ML.EQ.1) WRITE (IPR,900) 
      IF (ML.EQ.1) RETURN 
      IF (ZSTF(K).GT.ZVSA(10)) RETURN 
      DO 20 JJ = 1, 9 
         JL = JJ 
         IF (ZSTF(K).LT.ZVSA(JJ)) GO TO 20 
         JN = JJ+1 
         IF (ZSTF(K).LT.ZVSA(JN)) GO TO 30 
   20 END DO 
      JN = 10 
   30 CONTINUE 
      DIF = ZVSA(JN)-ZVSA(JL) 
      DZ = ZVSA(JN)-ZSTF(K) 
      DLIN = DZ/DIF 
      IHAZ1 = IHVSA(JL) 
!                                                                       
!     FAC=(ZVSA(JL)-ZSTF  ( K))/DIF                                     
!                                                                       
      AHAZE = (AHVSA(JN)-AHVSA(JL))*DLIN+AHVSA(JL) 
      RETURN 
!                                                                       
  900 FORMAT('   ERROR MODEL EQ 0 AND ARMY MODEL CANNOT MIX') 
!                                                                       
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE STDMDL 
!                                                                       
!     ******************************************************************
!     LOADS DENSITIES INTO COMMON MODEL AND                             
!     CALCULATES THE INDEX OF REFRACTION                                
!                                                                       
!     AERSOLS NOW LOADED IN AERNSM                                      
!                                                                       
!     ZM COMMON /MODEL/ FINAL ALTITUDE FOR LOWTRAN                      
!     Z COMMON /MDATA/  ALTITUDE FOR DATA IN MDATA                      
!     ZN  BLANK COMMON                                                  
!     ZP  BLANK COMMON                                                  
!                                                                       
!     ******************************************************************
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX2(47),AWCCON(5) 
!                                                                       
      CHARACTER*8      HMOD 
!                                                                       
      COMMON /CMN/ HMOD(3),ZN(MXZMD),PN(MXZMD),TN(MXZMD),RFNDXM(MXZMD), &
     &         ZP(IM2),PP1(IM2),TP(IM2),RFNDXP(IM2),SP(IM2),PPSUM(IM2), &
     &          TPSUM(IM2),RHOPSM(IM2),IMMAX,WGM(MXZMD),DEMW(MXZMD),    &
     &          AMTP(MXMOL,MXPDIM)                                      
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
      COMMON /LCRD1/ MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRNT,TBOUND,SALB 
      COMMON /LCRD2/ IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,   &
     &     RAINRT                                                       
      COMMON /LCRD3/ H1,H2,ANGLE,RANGE,BETA,RE,LEN 
      COMMON /LCRD4/ V1,V2,DV 
!     COMMON /MDATA/ ZMDL(MXZMD),P(MXZMD),T(MXZMD),WH(MXZMD),WO(MXZMD), 
!    *     HMIX(MXZMD),CLD(MXZMD,7),RR(MXZMD,7)                         
      COMMON /MDATA/                               WH(MXZMD),WO(MXZMD), &
     &                 CLD(MXZMD,7),RR(MXZMD,7)                         
      COMMON /MDATA2/ZMDL(MXZMD),P(MXZMD),T(MXZMD) 
      COMMON /CNSTNS/ PI,CA,DEG,GCAIR,BIGNUM,BIGEXP 
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,N_LVL,JH1 
      COMMON /MODEL/ ZM(MXZMD),PM(MXZMD),TM(MXZMD),                     &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDM(MXZMD),RRM(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)             
!                                                                       
!     XLOSCH = LOSCHMIDT'S NUMBER,MOLECULES CM-2,KM-1                   
!                                                                       
      DATA PZERO /1013.25/,TZERO/273.15/,XLOSCH/2.6868E24/ 
!                                                                       
!     RV GAS CONSTANT FOR WATER IN MB/(GM M-3 K)                        
!     CON CONVERTS WATER VAPOR FROM GM M-3 TO MOLECULES CM-2 KM-1       
!                                                                       
      DATA RV/4.6152E-3/,CON/3.3429E21/ 
!                                                                       
!     CONSTANTS FOR INDEX OF REFRACTION, AFTER EDLEN, 1965              
!                                                                       
      DATA A0/83.42/,A1/185.08/,A2/4.11/,                               &
     &     B1/1.140E5/,B2/6.24E4/,C0/43.49/,C1/1.70E4/                  
!                                                                       
!     F(A) IS SATURATED WATER WAPOR DENSITY AT TEMP T,A=TZERO/T         
!                                                                       
      F(A) = EXP(18.9766-14.9595*A-2.43882*A*A)*A 
!                                                                       
!     H20 CONTINUUM IS STORED AT 296 K RHZERO IS AIR DENSITY AT 296 K   
!     IN UNITS OF LOSCHMIDT'S                                           
!                                                                       
!     CALL DRYSTR                                                       
!                                                                       
      RHZERO = (273.15/296.0) 
!                                                                       
      IF (ICLD.GT.20) THEN 
         WRITE (IPR,900) ICLD 
         STOP 'STDMDL: ICLD GT 20' 
      ENDIF 
!                                                                       
!     LOAD ATMOSPHERE PROFILE INTO /MODEL/                              
!                                                                       
      IF (M.LT.7) ML = NL 
      DO 10 I = 1, ML 
         IF (M.NE.7) ZM(I) = ZMDL(I) 
         PM(I) = P(I) 
         TM(I) = T(I) 
         PP = PM(I) 
         TT = TM(I) 
         F1 = (PP/PZERO)/(TT/TZERO) 
         F2 = (PP/PZERO)*SQRT(TZERO/TT) 
         WTEMP = WH(I) 
         RELHUM(I) = 0. 
!                                                                       
!        RELHUM IS CALCULATED ONLY FOR THE BOUNDRY LAYER (0 TO 2 KM)    
!                                                                       
!        SCALED H2O DENSITY                                             
!                                                                       
         DENSTY(1,I) = 0.1*WTEMP*F2**0.9 
!                                                                       
!        C    IF (ZM(I).GT.6.0) GO TO 15                                
!        C    IF(DENSTY(7,I).LE.0.) GO TO 15                            
!                                                                       
         TS = TZERO/TT 
         RELHUM(I) = 100.0*(WTEMP/F(TS)) 
!                                                                       
!        UNIFORMALY MIXED GASES DENSITYS                                
!                                                                       
         DENSTY(2,I) = F1*F2**0.75 
!                                                                       
!        UV OZONE                                                       
!                                                                       
         DENSTY(8,I) = 46.6667*WO(I) 
!                                                                       
!        IR OZONE                                                       
!                                                                       
         DENSTY(3,I) = DENSTY(8,I)*F2**0.4 
!                                                                       
!        N2 CONTINUUM                                                   
!                                                                       
         DENSTY(4,I) = 0.8*F1*F2 
!                                                                       
!        SELF BROADENED WATER                                           
!                                                                       
         RHOAIR = F1 
         RHOH2O = CON*WTEMP/XLOSCH 
         RHOFRN = RHOAIR-RHOH2O 
         DENSTY(5,I) = XLOSCH*RHOH2O**2/RHZERO 
!                                                                       
!        FOREIGN BROADENED                                              
!                                                                       
         DENSTY(10,I) = XLOSCH*RHOH2O*RHOFRN/RHZERO 
!                                                                       
!        MOLECULAR SCATTERING                                           
!                                                                       
         DENSTY(6,I) = F1 
!                                                                       
!        AEROSOL FOR 0 TO 2KM                                           
!                                                                       
!                                                                       
!        RELITIVE HUMIDITY WEIGHTED BY BOUNDRY LAYER AEROSOL (0 TO 2 KM)
!                                                                       
         RELH = RELHUM(I) 
         RELH = MIN(RELH,99.) 
         RHLOG = LOG(100.-RELH) 
!                                                                       
!        DENSTY(15,I)=RELHUM(I)*DENSTY(7,I)                             
!                                                                       
         DENSTY(15,I) = RHLOG*DENSTY(7,I) 
!                                                                       
!        DENSITY (9,I) NO LONGER USED                                   
!                                                                       
         DENSTY(9,I) = 0. 
!                                                                       
!        IF(ICH(1).GT.7) DENSTY(15,I)=RELHUM(I)*DENSTY(12,I)            
!                                                                       
         IF (ICH(1).GT.7) DENSTY(15,I) = RHLOG*DENSTY(12,I) 
!                                                                       
!        HNO3 IN ATM * CM /KM                                           
!        DENSTY(11,I)= F1* HMIX(I)*1.0E-4                               
!                                                                       
         DENSTY(11,I) = 0. 
!                                                                       
!        IF(MODEL.EQ.0) DENSTY(11,I)=F1*HSTOR(I)*1.0E-4                 
!        CIRRUS CLOUD                                                   
!                                                                       
         IF (ICLD.LT.18) DENSTY(16,I) = 0.0 
!                                                                       
!        RFNDX = REFRACTIVITY 1-INDEX OF REFRACTION                     
!        FROM EDLEN, 1966                                               
!                                                                       
         PPW = RV*WTEMP*TT 
         AVW = 0.5*(V1+V2) 
         RFNDX(I) = ((A0+A1/(1.-(AVW/B1)**2)+A2/(1.0-(AVW/B2)**2))*(PP/ &
         PZERO)*(TZERO+15.0)/TT-(C0-(AVW/C1)**2)*PPW/PZERO)*1.E-6       
   10 END DO 
      WRITE (IPR,910) 
      ZERO = 0. 
      DO 20 I = 1, ML 
         WRITE (IPR,905) I,ZM(I),PM(I),TM(I),ZERO,ZERO,DENSTY(7,I),     &
         DENSTY(12,I),DENSTY(13,I),DENSTY(14,I),DENSTY(15,I), DENSTY(16,&
         I),RELHUM(I)                                                   
   20 END DO 
      RETURN 
!                                                                       
  900 FORMAT('1',//10X,'ICLD  CANNOT BE GREATER THAN 20 BUT IS',        &
     & I5,//)                                                           
  905 FORMAT (I4,0PF9.2,F9.3,F7.1,1X,1P9E10.3) 
  910 FORMAT('1',/,'  ATMOSPHERIC PROFILES',//,                         &
     & 3X,'I',T10,'Z',T18,'P',T26,'T',T33,'CNTMFRN',T45,'HNO3',         &
     & T53,'AEROSOL 1',T63,'AEROSOL 2', T73,'AEROSOL 3',T83,            &
     & 'AEROSOL 4',T93,'AER1*RH',T103,'CIRRUS',T118,'RH'/,              &
     & T9,'(KM)',T17,'(MB)',T25,'(K)',T31,'MOL/CM2 KM',T42,             &
     & 'ATM CM/KM',T54,'(-)',T64,'(-)',T74,'(-)',T84,'(-)',T94,         &
     & '(-)',T104,'(-)',T113,'(PERCNT)',/)                              
!                                                                       
      END                                           
!                                                                       
!     ***************************************************************** 
!                                                                       
      SUBROUTINE NEWMDL(MAXATM) 
!                                                                       
!     CC                                                                
!     CC   ROUTINE TO COMBINE LOWTRAN AND LBLRTM LAYERING               
!                                                                       
!     ZMTP STORES ZM VALUES                                             
!     ZOUT COMMON /ZOUTP/ FINAL LBLRTM BOUNDRIES                        
!     ZMDL COMMON /MODEL/ FINAL ALTITUDE FOR LOWTRAN                    
!     CC                                                                
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
      COMMON /LCRD1/ MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRNT,TBOUND,SALB 
      COMMON/MODEL/ZMDL(MXZMD),PM(MXZMD),TM(MXZMD),                     &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
      COMMON /ZOUTP/ ZOUT(MXLAY),SOUT(MXLAY),RHOSUM(MXLAY),             &
     &     AMTTOT(MXMOL),AMTCUM(MXMOL),ISKIP(MXMOL)                     
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISS,N_LVL,JH1 
!                                                                       
      DIMENSION PTMP(MXZMD),TTMP(MXZMD),RTMP(MXZMD),                    &
     &     DENTMP(16,MXZMD),ZMTP(MXZMD),RRAMTJ(MXZMD)                   
!                                                                       
      DO 10 I = 1, ML 
         ZMTP(I) = ZMDL(I) 
         PTMP(I) = PM(I) 
         TTMP(I) = TM(I) 
         RTMP(I) = RFNDX(I) 
         RRAMTJ(I) = RRAMT(I) 
         DO 8 K = 1, 16 
            DENTMP(K,I) = DENSTY(K,I) 
    8    CONTINUE 
   10 END DO 
      IF (ITYPE.EQ.1) GO TO 130 
      IF (ML.LT.2) GO TO 130 
      DO 20 I = 1, N_LVL 
         DO 18 K = 1, 16 
            DENSTY(K,I) = 0. 
   18    CONTINUE 
   20 END DO 
      I = 1 
      L = 1 
      J1 = 1 
   30 DO 80 J = J1, ML 
         IF (ZMDL(J).LT.ZOUT(1)) GO TO 80 
         IF (ZMDL(J).LE.ZOUT(I)) GO TO 40 
         GO TO 60 
   40    PM(L) = PTMP(J) 
         TM(L) = TTMP(J) 
         RFNDX(L) = RTMP(J) 
         RRAMT(L) = RRAMTJ(J) 
         ZMTP(L) = ZMDL(J) 
         DO 50 K = 1, 16 
            DENSTY(K,L) = DENTMP(K,J) 
   50    CONTINUE 
         L = L+1 
         IF (L.GT.MAXATM) GO TO 100 
         J1 = J+1 
         IF (ZMDL(J).LT.ZOUT(I)) GO TO 80 
         GO TO 90 
   60    JL = J-1 
         IF (JL.LT.1) JL = 1 
         JP = JL+1 
         DIF = ZMDL(JP)-ZMDL(JL) 
         DZ = ZOUT(I)-ZMDL(JL) 
         DLIN = DZ/DIF 
         PM(L) = (PTMP(JP)-PTMP(JL))*DLIN+PTMP(JL) 
         TM(L) = (TTMP(JP)-TTMP(JL))*DLIN+TTMP(JL) 
         RFNDX(L) = (RTMP(JP)-RTMP(JL))*DLIN+RTMP(JL) 
         RRAMT(L) = (RRAMTJ(JP)-RRAMTJ(JL))*DLIN+RRAMTJ(JL) 
         ZMTP(L) = ZOUT(I) 
         DO 70 K = 1, 16 
            DENSTY(K,L) = (DENTMP(K,JP)-DENTMP(K,JL))*DLIN+DENTMP(K,JL) 
   70    CONTINUE 
         L = L+1 
         IF (L.GT.MAXATM) GO TO 100 
         GO TO 90 
   80 END DO 
   90 IF (I.EQ.N_LVL) GO TO 110 
      I = I+1 
      GO TO 30 
!                                                                       
!     CC                                                                
!     CC    SET LOWTRAN HEIGHTS TO FINAL COMBINED LAYERING OF LBL/LOW   
!     CC    SET ML TO THE FINAL COUNT OF COMBINED LAYERING              
!     CC                                                                
!                                                                       
  100 WRITE (IPR,900) 
      STOP 'NEWMDL; LAYER LIMIT' 
  110 LM = L-1 
      DO 120 I = 1, LM 
         ZMDL(I) = ZMTP(I) 
  120 END DO 
      ML = LM 
  130 RETURN 
!                                                                       
  900 FORMAT(' LAYER LIMIT REACHED  CHANGE AVARAT  2. 10. 20. WORKS' ) 
!                                                                       
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE AERPRF (I,K,VIS,HAZE,IHAZE,ICLD,ISEASN,IVULCN,N) 
!                                                                       
!     ******************************************************************
!     WILL COMPUTE DENSITY    PROFILES FOR AEROSOLS                     
!     ******************************************************************
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
       USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!     PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
      COMMON/PRFD  / ZHT(34),HZ2K(34,5),FAWI50(34),FAWI23(34),          &
     &     SPSU50(34),SPSU23(34),BASTFW(34),VUMOFW(34),HIVUFW(34),      &
     &     EXVUFW(34),BASTSS(34),VUMOSS(34),HIVUSS(34),EXVUSS(34),      &
     &     UPNATM(34),VUTONO(34),VUTOEX(34),EXUPAT(34)                  
      COMMON /MODEL/ ZMDL(MXZMD),PM(MXZMD),TM(MXZMD),                   &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
      DIMENSION VS(5) 
      DATA VS/50.,23.,10.,5.,2./ 
      DATA CULWC/7.683E-03/,ASLWC/4.509E-03/,STLWC/5.272E-03/ 
      DATA SCLWC/4.177E-03/,SNLWC/7.518E-03/ 
      HAZE = 0. 
      N = 7 
      IF (IHAZE.EQ.0) THEN 
         IF (ICLD.EQ.0.OR.ICLD.EQ.20) RETURN 
      ENDIF 
      IF (ZHT(I).GT.2.0) GO TO 30 
      DO 10 J = 2, 5 
         IF (VIS.GE.VS(J)) GO TO 20 
   10 END DO 
      J = 5 
   20 CONST = 1./(1./VS(J)-1./VS(J-1)) 
      HAZE = CONST*((HZ2K(I,J)-HZ2K(I,J-1))/VIS+HZ2K(I,J-1)/VS(J)-HZ2K(I&
     &   ,J)/VS(J-1))                                                   
   30 IF (ICLD.GE.1.AND.ICLD.LE.11) GO TO 40 
      IF (ZHT(I).GT.2.0) GO TO 100 
      RETURN 
   40 IF (CLDAMT(K).LE.0.) GO TO 100 
      IH = ICLD 
      IF (CLDAMT(K).GT.0.0) N = 12 
      GO TO (50,60,70,80,90,70,90,90,50,50,50), IH 
   50 HAZEC(K) = CLDAMT(K)/CULWC 
      IF (ZHT(I).GT.2.0) GO TO 100 
      RETURN 
   60 HAZEC(K) = CLDAMT(K)/ASLWC 
      IF (ZHT(I).GT.2.0) GO TO 100 
      RETURN 
   70 HAZEC(K) = CLDAMT(K)/STLWC 
      IF (ZHT(I).GT.2.0) GO TO 100 
      RETURN 
   80 HAZEC(K) = CLDAMT(K)/SCLWC 
      IF (ZHT(I).GT.2.0) GO TO 100 
      RETURN 
   90 HAZEC(K) = CLDAMT(K)/SNLWC 
      IF (ZHT(I).GT.2.0) GO TO 100 
      RETURN 
  100 IF (ZHT(I).GT.10.) GO TO 140 
      IF (ICLD.GE.1.AND.ICLD.LE.11) THEN 
         N = 13 
      ELSE 
         N = 12 
      ENDIF 
      CONST = 1./(1./23.-1./50.) 
      IF (ISEASN.GT.1) GO TO 120 
      IF (VIS.LE.23.) HAZI = SPSU23(I) 
      IF (VIS.LE.23.) GO TO 260 
      IF (ZHT(I).GT.4.0) GO TO 110 
      HAZI = CONST*((SPSU23(I)-SPSU50(I))/VIS+SPSU50(I)/23.-SPSU23(I)/  &
     &   50.)                                                           
      GO TO 260 
  110 HAZI = SPSU50(I) 
      GO TO 260 
  120 IF (VIS.LE.23.) HAZI = FAWI23(I) 
      IF (VIS.LE.23.) GO TO 260 
      IF (ZHT(I).GT.4.0) GO TO 130 
      HAZI = CONST*((FAWI23(I)-FAWI50(I))/VIS+FAWI50(I)/23.-FAWI23(I)/  &
     &   50.)                                                           
      GO TO 260 
  130 HAZI = FAWI50(I) 
      GO TO 260 
  140 IF (ZHT(I).GT.30.0) GO TO 240 
      IF (ICLD.GE.1.AND.ICLD.LE.11) THEN 
         N = 14 
      ELSE 
         N = 13 
      ENDIF 
      HAZI = BASTSS(I) 
      IF (ISEASN.GT.1) GO TO 190 
      IF (IVULCN.EQ.0) HAZI = BASTSS(I) 
      IF (IVULCN.EQ.0) GO TO 260 
      GO TO (150,160,170,170,160,160,170,180), IVULCN 
  150 HAZI = BASTSS(I) 
      GO TO 260 
  160 HAZI = VUMOSS(I) 
      GO TO 260 
  170 HAZI = HIVUSS(I) 
      GO TO 260 
  180 HAZI = EXVUSS(I) 
      GO TO 260 
  190 IF (IVULCN.EQ.0) HAZI = BASTFW(I) 
      IF (IVULCN.EQ.0) GO TO 260 
      GO TO (200,210,220,220,210,210,220,230), IVULCN 
  200 HAZI = BASTFW(I) 
      GO TO 260 
  210 HAZI = VUMOFW(I) 
      GO TO 260 
  220 HAZI = HIVUFW(I) 
      GO TO 260 
  230 HAZI = EXVUFW(I) 
      GO TO 260 
  240 N = 14 
      IF (IVULCN.GT.1) GO TO 250 
      HAZI = UPNATM(I) 
      GO TO 260 
  250 HAZI = VUTONO(I) 
  260 IF (HAZI.GT.0) HAZE = HAZI 
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE GEO(IERROR,BENDNG,MAXGEO) 
!                                                                       
!     ******************************************************************
!     THIS SUBROUTINE SERVES AS AN INTERFACE BETWEEN THE MAIN           
!     LOWTRAN PROGRAM 'LOWTRN' AND THE NEW SET OF SUBROUTINES,          
!     INCLUDING 'EXPINT', 'FINDSH', 'SCALHT', 'RFPATL', 'FILL',         
!     AND 'LAYER',  WHICH CALCULATE THE ABSORBER                        
!     AMOUNTS FOR A REFRACTED PATH THROUGH THE ATMOSPHERE.              
!     THE INPUT PARAMETERS ITYPE, H1, H2, ANGLE, RANGE, BETA, AND LEN   
!     ALL FUNCTION IN THE SAME WAY IN THE NEW ROUTINES AS IN THE OLD.   
!     ******************************************************************
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
      PARAMETER (MXZ20 = MXZMD+20, MX2Z3 = 2*MXZMD+3) 
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX2(47),AWCCON(5) 
!                                                                       
      CHARACTER*8      HMOD 
!                                                                       
      COMMON /CMN/ HMOD(3),ZN(MXZMD),PN(MXZMD),TN(MXZMD),RFNDXM(MXZMD), &
     &          ZP(IM2),PP(IM2),TP(IM2),RFNDXP(IM2),SP(IM2),PPSUM(IM2), &
     &          TPSUM(IM2),RHOPSM(IM2),IMMAX,WGM(MXZMD),DEMW(MXZMD),    &
     &          AMTP(MXMOL,MXPDIM)                                      
!                                                                       
!     RFRPTH is dependent upon MXZMD (MXZ20=MXZMD+20;MX2Z3=2*MXZMD+3)   
!                                                                       
      COMMON  /RFRPTH/ ZL(MXZ20),PL(MXZ20),TL(MXZ20),RFNDXL(MXZ20),     &
     &     SL(MXZ20),PPSUML(MXZ20),TPSUML(MXZ20),RHOSML(MXZ20),         &
     &     DENL(16,MXZ20),AMTL(16,MXZ20),LJ(MX2Z3)                      
      COMMON /RAIN/ RNPATH(IM2),RRAMTK(IM2) 
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                                &
     &                     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4      
      COMMON /LCRD1/ MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRNT,TBOUND,SALB 
      COMMON /LCRD2/ IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,   &
     &    RAINRT                                                        
      COMMON /LCRD3/ H1,H2,ANGLE,RANGE,BETA,REE,LEN 
      COMMON /LCRD4/ V1,V2,DV 
      COMMON /CNSTNS/ PI,CA,DEG,GCAIR,BIGNUM,BIGEXP 
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,N_LVL,JH1 
      COMMON/MODEL/ ZMDL(MXZMD),PM(MXZMD),TM(MXZMD),                    &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
      COMMON /PARMLT/ RE,DELTAS,ZMAX,IMAX,IMOD,IBMAX,IPATH 
      COMMON /ADRIVE/LOWFLG,IREAD,MODELF,ITYPEF,NOZERO,NOPRNF,          &
     & H1F,H2F,ANGLEF,RANGEF,BETAF,LENF,VL1,VL2,RO,IPUNCH,VBAR,         &
     & HMINF,PHIF,IERRF,HSPACE                                          
      DIMENSION KMOL(16) 
!                                                                       
!     **   KMOL(K) IS A POINTER USED TO REORDER THE AMOUNTS WHEN PRINTIN
!                                                                       
      DATA KMOL/1,2,3,11,8,5,9,10,4,6,7,12,13,14,16,15/ 
!                                                                       
!     **   INITIALIZE CONSTANTS AND CLEAR CUMULATIVE VARIABLES          
!     **   DELTAS IS THE NOMINAL PATH LENGTH INCRENMENT USED IN THE RAY 
!                                                                       
      H1 = H1F 
      H2 = H2F 
      ANGLE = ANGLEF 
      HMIN = HMINF 
      LEN = LENF 
      PHI = PHIF 
      IERROR = IERRF 
      DELTAS = 5.0 
      JMAXST = 1 
      IERROR = 0 
      RE = REE 
      IMOD = ML 
      IMAX = ML 
!                                                                       
!     **   ZERO OUT CUMULATIVE VARIABLES                                
!                                                                       
      DO 10 I = 1, 68 
         LJ(I) = 0 
         SL(I) = 0.0 
         PPSUML(I) = 0.0 
         TPSUML(I) = 0.0 
         RHOSML(I) = 0.0 
         DO 8 K = 1, KMAX 
            AMTL(K,I) = 0.0 
    8    CONTINUE 
   10 END DO 
      ZMAX = ZMDL(IMAX) 
      IF (ITYPE.GE.2) GO TO 60 
!                                                                       
!     **   HORIZONTAL PATH, MODEL EQ 1 TO 7:  INTERPOLATE PROFILE TO H1 
!                                                                       
      ZL(1) = H1 
      IF (ML.EQ.1) THEN 
         TL(1) = TM(1) 
         LJ(1) = 1 
         SL(1) = RANGE 
      ELSE 
         DO 20 I = 2, ML 
            I2 = I 
            IF (H1.LT.ZMDL(I)) GO TO 30 
   20    CONTINUE 
   30    CONTINUE 
         I1 = I2-1 
         FAC = (H1-ZMDL(I1))/(ZMDL(I2)-ZMDL(I1)) 
         CALL EXPINT (PL(1),PM(I1),PM(I2),FAC) 
         TL(1) = TM(I1)+(TM(I2)-TM(I1))*FAC 
         II1 = I1 
         IF (FAC.GT.0.5) II1 = I2 
         LJ(1) = II1 
         SL(II1) = RANGE 
         DO 40 K = 1, KMAX 
            CALL EXPINT (DENL(K,1),DENSTY(K,I1),DENSTY(K,I2),FAC) 
   40    CONTINUE 
      ENDIF 
!                                                                       
!     **   CALCULATE ABSORBER AMOUNTS FOR A HORIZONTAL PATH             
!                                                                       
      WRITE (IPR,900) H1,RANGE,MODEL 
      TBBY(1) = TL(1) 
      IKMAX = 1 
      DO 50 K = 1, KMAX 
         IF (ML.EQ.1) DENL(K,1) = DENSTY(K,1) 
         W(K) = DENL(K,1)*RANGE 
         WPATH(1,K) = W(K) 
   50 END DO 
      WTEM = (296.0-TL(1))/(296.0-260.0) 
      WTEM = MAX(WTEM,0.) 
      WTEM = MIN(WTEM,1.) 
      W(9) = W(5)*WTEM 
      WPATH(1,9) = W(9) 
      GO TO 170 
   60 CONTINUE 
!                                                                       
!     **   SLANT PATH SELECTED                                          
!     **   INTERPRET SLANT PATH PARAMETERS                              
!                                                                       
      IF (IERROR.EQ.0) GO TO 70 
      IF (ISSGEO.NE.1) WRITE (IPR,905) 
      RETURN 
   70 CONTINUE 
!                                                                       
!     **   CALCULATE THE PATH THROUGH THE ATMOSPHERE                    
!                                                                       
      IAMT = 1 
      CALL RFPATL (H1,H2,ANGLE,PHI,LEN,HMIN,IAMT,RANGE,BETA,BENDNG) 
!                                                                       
!     **   UNFOLD LAYER AMOUNTS IN AMTP INTO THE CUMULATIVE             
!     **   AMOUNTS IN WPATH FROM H1 TO H2                               
!                                                                       
      DO 80 I = 1, IPATH 
         IF (H1.EQ.ZL(I)) IH1 = I 
         IF (H2.EQ.ZL(I)) IH2 = I 
   80 END DO 
      JMAX = (IPATH-1)+LEN*(MIN0(IH1,IH2)-1) 
      IKMAX = JMAX 
!                                                                       
!     **   DETERMINE LJ(J), WHICH IS THE NUMBER OF THE LAYER IN AMTP(K,L
!     **   STARTING FROM HMIN, WHICH CORRESPONDS TO THE LAYER J IN      
!     **   WPATH(J,K), STARTING FROM H1                                 
!     **   INITIAL DIRECTION OF PATH IS DOWN                            
!                                                                       
      L = IH1 
      LDEL = -1 
      IF (LEN.EQ.1.OR.H1.GT.H2) GO TO 90 
!                                                                       
!     **   INITIAL DIRECTION OF PATH IS UP                              
!                                                                       
      L = 0 
      LDEL = 1 
   90 CONTINUE 
      JTURN = 0 
      JMAXP1 = JMAX+1 
      DO 110 J = 1, JMAXP1 
!                                                                       
!        **   TEST FOR REVERSING DIRECTION OF PATH FROM DOWN TO UP      
!                                                                       
         IF (L.NE.1.OR.LDEL.NE.-1) GO TO 100 
         JTURN = J 
         L = 0 
         LDEL = +1 
  100    CONTINUE 
         L = L+LDEL 
         LJ(J) = L 
  110 END DO 
!                                                                       
!     **   LOAD TBBY AND WPATH                                          
!     **   TBBY IS DENSITY WEIGHTED MEAN TEMPERATURE                    
!                                                                       
      AMTTOT = 0. 
      DO 120 K = 1, KMAX 
         W(K) = 0.0 
         WPATH(1,K) = 0.0 
  120 END DO 
      IMAX = 0 
      DO 140 J = 1, JMAX 
         L = LJ(J) 
         IMAX = MAX(IMAX,L) 
         TBBY(L) = TPSUML(L)/RHOSML(L) 
         AMTTOT = AMTTOT+RHOSML(L) 
         DO 130 K = 1, KMAX 
            IF (K.EQ.9) GO TO 130 
!                                                                       
!           CC                                                          
!                                                                       
            WPATH(L,K) = AMTL(K,L) 
            W(K) = W(K)+WPATH(L,K) 
  130    CONTINUE 
         WTEM = (296.0-TBBY(L))/(296.0-260.0) 
         IF (WTEM.LT.0.0) WTEM = 0. 
         IF (WTEM.GT.1.0) WTEM = 1.0 
         WPATH(L,9) = WTEM*AMTL(5,L) 
         W(9) = W(9)+WPATH(L,9) 
  140 END DO 
      JMAX = IMAX 
      JMAXST = IMAX 
      JMAX = IMAX 
      IKMAX = IMAX 
!                                                                       
!     **   INCLUDE BOUNDARY EMISSION IF:                                
!     **       1. TBOUND IS SET TO ZERO IN THIS VERSION OF LOWTRAN      
!     **       2. SLANT PATH INTERSECTS THE EARTH (TBOUND               
!     **          SET TO TEMPERATURE OF LOWEST BOUNDARY)                
!                                                                       
      IF (TBOUND.EQ.0.0.AND.H2.EQ.ZMDL(1)) TBOUND = TM(1) 
!                                                                       
!     **   PRINT CUMULATIVE ABSORBER AMOUNTS                            
!                                                                       
      IF (NPR.EQ.1) GO TO 160 
      WRITE (IPR,910) 
      DO 150 J = 1, JMAX 
         LZ = J+1 
         L1 = LZ-1 
         IF (NPR.NE.1) WRITE (IPR,915) J,ZL(L1),ZL(LZ),TBBY(J),WPATH(J, &
         KMOL(1)),(WPATH(J,KMOL(K)),K=10,15)                            
  150 END DO 
!                                                                       
!     **   PRINT PATH SUMMARY                                           
!                                                                       
  160 WRITE (IPR,920) H1,H2,ANGLE,RANGE,BETA,PHI,HMIN,BENDNG,LEN 
  170 CONTINUE 
!                                                                       
!     **   CALCULATE THE AEROSOL WEIGHTED MEAN RH                       
!                                                                       
      IF (W(7).GT.0.0.AND.ICH(1).LE.7) THEN 
         W15 = W(15)/W(7) 
!                                                                       
!        INVERSE OF LOG REL HUM                                         
!                                                                       
         W(15) = 100.-EXP(W15) 
         GO TO 180 
      ENDIF 
      IF (W(12).GT.0.0.AND.ICH(1).GT.7) THEN 
         W15 = W(15)/W(12) 
!                                                                       
!        INVERSE OF LOG REL HUM                                         
!                                                                       
         W(15) = 100.-EXP(W15) 
         GO TO 180 
      ENDIF 
      W(15) = 0. 
  180 CONTINUE 
!                                                                       
!     **   PRINT TOTAL PATH AMOUNTS                                     
!                                                                       
      WRITE (IPR,925) (W(KMOL(K)),K=10,16) 
!                                                                       
      IF (JMAXST.GT.MAXGEO) THEN 
         WRITE (IPR,930) MAXGEO,JMAXST 
         STOP 'GEO: JMAXST .GT. MAXGEO' 
      ENDIF 
      DO 190 IK = 1, JMAXST 
         IL = LJ(IK) 
         RNPATH(IK) = SL(IL) 
         RRAMTK(IK) = RRAMT(IL) 
  190 END DO 
!                                                                       
      RETURN 
!                                                                       
  900 FORMAT('0HORIZONTAL PATH AT ALTITUDE = ',F10.3,                   &
     &   ' KM WITH RANGE = ',F10.3,' KM, MODEL = ',I3)                  
  905 FORMAT('0GEO:  IERROR NE 0: END THIS CALCULATION AND SKIP TO'     &
     &    ,' THE NEXT CASE')                                            
  910 FORMAT(////,'    LAYER   ABSORBER AMOUNTS FOR THE PATH FROM',     &
     &    ' Z(J) TO Z(J+1)',//,T3,'J',T9,'Z(J)',T18,'Z(J+1)',T27,'TBAR',&
     & T37,'H2O',                                                       &
     & T46,'MOL SCAT',T61,'AER 1',T73,'AER 2',T85,'AER 3',T97,'AER 4',  &
     & T109,'CIRRUS',/,                                                 &
     & T8,'(KM)',T17,'(KM)',T28,'(K)',T32,'LOWTRN U.')                  
  915 FORMAT(I3,2F9.3,F9.2,1P8E12.3) 
  920 FORMAT(//,'0SUMMARY OF THE GEOMETRY CALCULATION',//,              &
     & 10X,'H1      = ',F10.3,' KM',/,10X,'H2      = ',F10.3,' KM',/,   &
     &10X,'ANGLE   = ',F10.3,' DEG',/,10X,'RANGE   = ',F10.3,' KM',/,   &
     &10X,'BETA    = ',F10.3,' DEG',/,10X,'PHI     = ',F10.3,' DEG',/,  &
     & 10X,'HMIN    = ',F10.3,' KM',/,10X,'BENDING = ',F10.3,' DEG',/,  &
     & 10X,'LEN     = ',I10)                                            
  925 FORMAT(////,' EQUIVALENT SEA LEVEL TOTAL ABSORBER AMOUNTS',//,    &
     &    T15,'       ',T26,'MOL SCAT',T41,'AER 1', T53,'AER 2',        &
     &    T65,'AER 3',T77, 'AER 4',T87,'CIRRUS',T99,'MEAN RH'/,         &
     &    T99,'(PRCNT)',//,22X,1P6E12.3,0PF12.2,//)                     
  930 FORMAT(//'  CURRENT GEOMETRY DIMENSION ',I5 ,/                    &
     &,' JMAXST = ',I5,' RESET AVTRAT TDIFF1 TDIFF2 TO 2. 10. 20.')     
!                                                                       
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE FINDSL(H,SH,GAMMA) 
!                                                                       
!     **   GIVEN AN ALTITUDE H, THIS SUBROUTINE FINDS THE LAYER BOUNDARI
!     **   ZM(I1) AND ZM(I2) WHICH CONTAIN H,  THEN CALCULATES THE SCALE
!     **   HEIGHT (SH) AND THE VALUE AT THE GROUND (GAMMA+1) FOR THE    
!     **   INDEX OF REFRACTION                                          
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
      COMMON /PARMLT/ RE,DELTAS,ZMAX,IMAX,IMOD,IBMAX,IPATH 
      COMMON /CNSTNS/ PI,CA,DEG,GCAIR,BIGNUM,BIGEXP 
      COMMON /MODEL/ ZMDL(MXZMD),P(MXZMD),T(MXZMD),                     &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
!                                                                       
      DO 10 IM = 2, IMOD 
         I2 = IM 
         IF (ZMDL(IM).GE.H) GO TO 20 
   10 END DO 
      I2 = IMOD 
   20 CONTINUE 
      I1 = I2-1 
      CALL SCALHT (ZMDL(I1),ZMDL(I2),RFNDX(I1),RFNDX(I2),SH,GAMMA) 
      RETURN 
      END 
                                          
      SUBROUTINE RFPATL(H1,H2,ANGLE,PHI,LEN,HMIN,IAMT,RANGE,BETA,BENDNG) 
!                                                                       
!     ******************************************************************
!     THIS SUBROUTINE TRACES THE REFRACTED RAY FROM H1 WITH A           
!     INITIAL ZENITH ANGLE ANGLE TO H2 WHERE THE ZENITH ANGLE IS PHI,   
!     AND CALCULATES THE ABSORBER AMOUNTS (IF IAMT.EQ.1) ALONG          
!     THE PATH.  IT STARTS FROM THE LOWEST POINT ALONG THE PATH         
!     (THE TANGENT HEIGHT HMIN IF LEN = 1 OR HA = MIN(H1,H2) IF LEN = 0)
!     AND PROCEEDS TO THE HIGHEST POINT.  BETA AND RANGE ARE THE        
!     EARTH CENTERED ANGLE AND THE TOTAL DISTANCE RESPECTIVELY          
!     FOR THE REFRACTED PATH FROM H1 TO H2                              
!     ******************************************************************
!                                                                       
      USE lblparams, ONLY: MXZMD
      PARAMETER (MXZ20 = MXZMD+20, MX2Z3 = 2*MXZMD+3) 
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
      COMMON /PARMLT/ RE,DELTAS,ZMAX,IMAX,IMOD,IBMAX,IPATH 
      COMMON /CNSTNS/ PI,CA,DEG,GCAIR,BIGNUM,BIGEXP 
!                                                                       
!     RFRPTH is dependent upon MXZMD (MXZ20=MXZMD+20;MX2Z3=2*MXZMD+3)   
!                                                                       
      COMMON  /RFRPTH/ ZL(MXZ20),PL(MXZ20),TL(MXZ20),RFNDXL(MXZ20),     &
     &     SL(MXZ20),PPSUML(MXZ20),TPSUML(MXZ20),RHOSML(MXZ20),         &
     &     DENL(16,MXZ20),AMTL(16,MXZ20),LJ(MX2Z3)                      
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,N_LVL,JH1 
!                                                                       
      DATA I_2/2/ 
!                                                                       
      IF (H1.GT.H2) GO TO 10 
      IORDER = 1 
      HA = H1 
      HB = H2 
      ANGLEA = ANGLE 
      GO TO 20 
   10 CONTINUE 
      IORDER = -1 
      HA = H2 
      HB = H1 
      ANGLEA = PHI 
   20 CONTINUE 
      JNEXT = 1 
!                                                                       
!     IF(IAMT.EQ.1 .AND. NPR.NE.1)  WRITE(IPR,20)                       
!                                                                       
      IF (LEN.EQ.0) GO TO 30 
!                                                                       
!     **   LONG PATH: FILL IN THE SYMETRIC PART FROM THE TANGENT HEIGHT 
!     **   TO HA                                                        
!                                                                       
      CALL FILL (HMIN,HA,JNEXT) 
      JHA = JNEXT 
      JH1 = JNEXT-1 
   30 CONTINUE 
!                                                                       
!     **   FILL IN THE REMAINING PATH FROM HA TO HB                     
!                                                                       
      IF (HA.EQ.HB) GO TO 40 
      CALL FILL (HA,HB,JNEXT) 
   40 CONTINUE 
      JMAX = JNEXT 
      IPATH = JMAX 
!                                                                       
!     **   INTEGRATE EACH SEGMENT OF THE PATH                           
!     **   CALCULATE CPATH SEPERATELY FOR LEN = 0,1                     
!                                                                       
      IF (LEN.EQ.1) GO TO 50 
      CALL FINDSL (HA,SH,GAMMA) 
      CPATH = (RE+HA)*ANDEX(HA,SH,GAMMA)*SIN(ANGLEA/DEG) 
      GO TO 60 
   50 CONTINUE 
      CALL FINDSL (HMIN,SH,GAMMA) 
      CPATH = (RE+HMIN)*ANDEX(HMIN,SH,GAMMA) 
   60 CONTINUE 
      BETA = 0.0 
      S = 0.0 
      BENDNG = 0.0 
      IF (LEN.EQ.0) GO TO 100 
!                                                                       
!     **   DO SYMETRIC PART, FROM TANGENT HEIGHT(HMIN) TO HA            
!                                                                       
      IHLOW = 1 
      IF (IORDER.EQ.-1) IHLOW = 2 
!                                                                       
      SINAI = 1.0 
      COSAI = 0.0 
      THETA = 90.0 
      J2 = JHA-1 
      DO 90 J = 1, J2 
         CALL SCALHT (ZL(J),ZL(J+1),RFNDXL(J),RFNDXL(J+1),SH,GAMMA) 
         CALL LOLAYR (J,SINAI,COSAI,CPATH,SH,GAMMA,IAMT,DS,DBEND) 
         DBEND = DBEND*DEG 
         PHI = ASIN(SINAI)*DEG 
         DBETA = THETA-PHI+DBEND 
         PHI = 180.0-PHI 
         S = S+DS 
         BENDNG = BENDNG+DBEND 
         BETA = BETA+DBETA 
         IF (IAMT.NE.1) GO TO 70 
         PBAR = PPSUML(J)/RHOSML(J) 
         TBAR = TPSUML(J)/RHOSML(J) 
         RHOBAR = RHOSML(J)/DS 
!                                                                       
!        IF(IAMT.EQ.1 .AND. NPR.NE.1) WRITE(IPR,22) J,ZP(J),ZP(J+1),    
!        1    THETA,DS,S,DBETA,BETA,PHI,DBEND,BENDNG,PBAR,TBAR,RHOBAR   
!                                                                       
   70    CONTINUE 
         IF (ISSGEO.EQ.1) GO TO 80 
!                                                                       
!        CC   ATHETA(J)=THETA                                           
!        CC   ADBETA(J)=DBETA                                           
!                                                                       
   80    CONTINUE 
         THETA = 180.0-PHI 
   90 END DO 
!                                                                       
!     **   DOUBLE PATH QUANTITIES FOR THE OTHER PART OF THE SYMETRIC PAT
!                                                                       
      BENDNG = 2.0*BENDNG 
      BETA = 2.0*BETA 
      S = 2.0*S 
!                                                                       
!     IF(IAMT.EQ.1 .AND. NPR.NE.1) WRITE(IPR,26) S,BETA,BENDNG          
!                                                                       
      JNEXT = JHA 
      GO TO 120 
  100 CONTINUE 
!                                                                       
!     **   SHORT PATH                                                   
!                                                                       
      JNEXT = 1 
!                                                                       
!     **   ANGLEA IS THE ZENITH ANGLE AT HA IN DEG                      
!     **   SINAI IS SIN OF THE INCIDENCE ANGLE                          
!     **   COSAI IS CARRIED SEPERATELY TO AVOID A PRECISION PROBLEM     
!     **   WHEN SINAI IS CLOSE TO 1.0                                   
!                                                                       
      THETA = ANGLEA 
      IF (ANGLEA.GT.45.0) GO TO 110 
      SINAI = SIN(ANGLEA/DEG) 
      COSAI = -COS(ANGLEA/DEG) 
      GO TO 120 
  110 CONTINUE 
      SINAI = COS((90.0-ANGLEA)/DEG) 
      COSAI = -SIN((90.0-ANGLEA)/DEG) 
  120 CONTINUE 
!                                                                       
!     **   DO PATH FROM HA TO HB                                        
!                                                                       
      IF (HA.EQ.HB) GO TO 160 
      J1 = JNEXT 
      J2 = JMAX-1 
      IHLOW = 1 
      IF (IORDER.EQ.-1) IHLOW = 2 
      IHIGH = MOD(IHLOW,I_2)+1 
!                                                                       
      DO 150 J = J1, J2 
         CALL SCALHT (ZL(J),ZL(J+1),RFNDXL(J),RFNDXL(J+1),SH,GAMMA) 
         CALL LOLAYR (J,SINAI,COSAI,CPATH,SH,GAMMA,IAMT,DS,DBEND) 
         DBEND = DBEND*DEG 
         PHI = ASIN(SINAI)*DEG 
         DBETA = THETA-PHI+DBEND 
         PHI = 180.0-PHI 
         S = S+DS 
         BENDNG = BENDNG+DBEND 
         BETA = BETA+DBETA 
         IF (IAMT.NE.1) GO TO 130 
         PBAR = PPSUML(J)/RHOSML(J) 
         TBAR = TPSUML(J)/RHOSML(J) 
         RHOBAR = RHOSML(J)/DS 
!                                                                       
!        IF(IAMT.EQ.1 .AND. NPR.NE.1) WRITE(IPR,22) J,ZP(J),ZP(J+1),    
!        1    THETA,DS,S,DBETA,BETA,PHI,DBEND,BENDNG,PBAR,TBAR,RHOBAR   
!                                                                       
  130    CONTINUE 
         IF (ISSGEO.EQ.1) GO TO 140 
!                                                                       
!        CC   ADBETA(J)=DBETA                                           
!        CC   ATHETA(J)=THETA                                           
!                                                                       
  140    CONTINUE 
         THETA = 180.0-PHI 
  150 END DO 
  160 CONTINUE 
!                                                                       
!     CC   IF(ISSGEO.EQ.0) ATHETA(JMAX)=THETA                           
!                                                                       
      IF (IORDER.EQ.-1) PHI = ANGLEA 
      RANGE = S 
      RETURN 
!                                                                       
!                                                                       
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE FILL(HA,HB,JNEXT) 
!                                                                       
!     ******************************************************************
!     THIS SUBROUTINE DEFINES THE ATMOSPHERIC BOUNDARIES OF THE PATH    
!     FROM HA TO HB AND INTERPOLATES (EXTRAPOLATES) THE DENSITIES TO    
!     THESE BOUNDARIES ASSUMING THE DENSITIES VARY EXPONENTIALLY        
!     WITH HEIGHT                                                       
!     ******************************************************************
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
      PARAMETER (MXZ20 = MXZMD+20, MX2Z3 = 2*MXZMD+3) 
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
      COMMON /MODEL/ ZMDL(MXZMD),P(MXZMD),T(MXZMD),                     &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
      COMMON /PARMLT/ RE,DELTAS,ZMAX,IMAX,IMOD,IBMAX,IPATH 
      COMMON /CNSTNS/ PI,CA,DEG,GCAIR,BIGNUM,BIGEXP 
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,N_LVL,JH1 
!                                                                       
!     RFRPTH is dependent upon MXZMD (MXZ20=MXZMD+20;MX2Z3=2*MXZMD+3)   
!                                                                       
      COMMON  /RFRPTH/ ZL(MXZ20),PL(MXZ20),TL(MXZ20),RFNDXL(MXZ20),     &
     &     SL(MXZ20),PPSUML(MXZ20),TPSUML(MXZ20),RHOSML(MXZ20),         &
     &     DENL(16,MXZ20),AMTL(16,MXZ20),LJ(MX2Z3)                      
!                                                                       
      IF (HA.LT.HB) GO TO 10 
      WRITE (IPR,900) HA,HB,JNEXT 
      STOP 
   10 CONTINUE 
!                                                                       
!     **   FIND ZMDL(IA): THE SMALLEST ZMDL(I).GT.HA                    
!                                                                       
      DO 20 I = 1, IMAX 
         IF (HA.GE.ZMDL(I)) GO TO 20 
         IA = I 
         GO TO 30 
   20 END DO 
      IA = IMAX+1 
      IB = IA 
      GO TO 50 
!                                                                       
!     **   FIND ZMDL(IB): THE SMALLEST ZMDL(I).GE.HB                    
!                                                                       
   30 CONTINUE 
      DO 40 I = IA, IMAX 
         IF (HB-ZMDL(I).GT..0001) GO TO 40 
         IB = I 
         GO TO 50 
   40 END DO 
      IB = IMAX+1 
   50 CONTINUE 
!                                                                       
!     **   INTERPOLATE DENSITIES TO HA, HB                              
!                                                                       
      ZL(JNEXT) = HA 
      I2 = IA 
      IF (I2.EQ.1) I2 = 2 
      I2 = MIN(I2,IMAX) 
      I1 = I2-1 
      A = (HA-ZMDL(I1))/(ZMDL(I2)-ZMDL(I1)) 
      CALL EXPINT (PL(JNEXT),P(I1),P(I2),A) 
      TL(JNEXT) = T(I1)+(T(I2)-T(I1))*A 
      CALL EXPINT (RFNDXL(JNEXT),RFNDX(I1),RFNDX(I2),A) 
      DO 60 K = 1, KMAX 
         CALL EXPINT (DENL(K,JNEXT),DENSTY(K,I1),DENSTY(K,I2),A) 
   60 END DO 
      IF (IA.EQ.IB) GO TO 80 
!                                                                       
!     **   FILL IN DENSITIES BETWEEN HA AND HB                          
!                                                                       
      I1 = IA 
      I2 = IB-1 
      DO 70 I = I1, I2 
         JNEXT = JNEXT+1 
         ZL(JNEXT) = ZMDL(I) 
         PL(JNEXT) = P(I) 
         TL(JNEXT) = T(I) 
         RFNDXL(JNEXT) = RFNDX(I) 
         DO 68 K = 1, KMAX 
            DENL(K,JNEXT) = DENSTY(K,I) 
   68    CONTINUE 
   70 END DO 
   80 CONTINUE 
!                                                                       
!     **   INTERPOLATE THE DENSITIES TO HB                              
!                                                                       
      JNEXT = JNEXT+1 
      ZL(JNEXT) = HB 
      I2 = IB 
      IF (I2.EQ.1) I2 = 2 
      I2 = MIN(I2,IMAX) 
      I1 = I2-1 
      A = (HB-ZMDL(I1))/(ZMDL(I2)-ZMDL(I1)) 
      CALL EXPINT (PL(JNEXT),P(I1),P(I2),A) 
      TL(JNEXT) = T(I1)+(T(I2)-T(I1))*A 
      CALL EXPINT (RFNDXL(JNEXT),RFNDX(I1),RFNDX(I2),A) 
      DO 90 K = 1, KMAX 
         CALL EXPINT (DENL(K,JNEXT),DENSTY(K,I1),DENSTY(K,I2),A) 
   90 END DO 
      RETURN 
!                                                                       
  900 FORMAT('0SUBROUTINE FILL- ERROR, HA .GE. HB',//,                  &
     &    10X,'HA, HB, JNEXT = ',2E25.15,I6)                            
!                                                                       
      END                                           
!                                                                       
!     ***************************************************************** 
!                                                                       
      SUBROUTINE LOLAYR(J,SINAI,COSAI,CPATH,SH,GAMMA,IAMT,S,BEND) 
!                                                                       
!     ***************************************************************** 
!     THIS SUBROUTINE CALCULATES THE REFRACTED PATH FROM Z1 TO Z2       
!     WITH THE SIN OF THE INITIAL INCIDENCE ANGLE SINAI                 
!     ***************************************************************** 
!                                                                       
      USE lblparams, ONLY: MXZMD
      PARAMETER (MXZ20 = MXZMD+20, MX2Z3 = 2*MXZMD+3) 
!                                                                       
      COMMON /PARMLT/ RE,DELTAS,ZMAX,IMAX,IMOD,IBMAX,IPATH 
      COMMON /CNSTNS/ PI,CA,DEG,GCAIR,BIGNUM,BIGEXP 
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,N_LVL,JH1 
!                                                                       
!     RFRPTH is dependent upon MXZMD (MXZ20=MXZMD+20;MX2Z3=2*MXZMD+3)   
!                                                                       
      COMMON  /RFRPTH/ ZL(MXZ20),PL(MXZ20),TL(MXZ20),RFNDXL(MXZ20),     &
     &     SL(MXZ20),PPSUML(MXZ20),TPSUML(MXZ20),RHOSML(MXZ20),         &
     &     DENL(16,MXZ20),AMTL(16,MXZ20),LJ(MX2Z3)                      
!                                                                       
      DIMENSION HDEN(20),DENA(20),DENB(20) 
!                                                                       
      DATA EPSILN/1.0E-5/ 
!                                                                       
!     **   INITIALIZE LOOP                                              
!                                                                       
      N = 0 
      Z1 = ZL(J) 
      Z2 = ZL(J+1) 
      H1 = Z1 
      R1 = RE+H1 
      DHMIN = DELTAS**2/(2.0*R1) 
      SINAI1 = SINAI 
      COSAI1 = COSAI 
      Y1 = COSAI1**2/2.0+COSAI1**4/8.0+COSAI1**6*3.0/48.0 
      Y3 = 0.0 
      X1 = -R1*COSAI1 
      RATIO1 = R1/RADREF(H1,SH,GAMMA) 
      DSDX1 = 1.0/(1.0-RATIO1*SINAI1**2) 
      DBNDX1 = DSDX1*SINAI1*RATIO1/R1 
      S = 0.0 
      BEND = 0.0 
      IF (IAMT.EQ.2) GO TO 50 
!                                                                       
!     **   INITIALIZE THE VARIABLES FOR THE CALCULATION OF THE          
!     **   ABSORBER AMOUNTS                                             
!                                                                       
      PA = PL(J) 
      PB = PL(J+1) 
      TA = TL(J) 
      TB = TL(J+1) 
      RHOA = PA/(GCAIR*TA) 
      RHOB = PB/(GCAIR*TB) 
      DZ = ZL(J+1)-ZL(J) 
      HP = -DZ/ LOG(PB/PA) 
      IF (ABS(RHOB/RHOA-1.0).LT.EPSILN) GO TO 10 
      HRHO = -DZ/ LOG(RHOB/RHOA) 
      GO TO 20 
   10 HRHO = 1.0E30 
   20 CONTINUE 
      DO 40 K = 1, KMAX 
         DENA(K) = DENL(K,J) 
         DENB(K) = DENL(K,J+1) 
         IF (DENA(K).LE.0.0.OR.DENB(K).LE.0.0) GO TO 30 
         IF (ABS(1.0-DENA(K)/DENB(K)).LE.EPSILN) GO TO 30 
!                                                                       
!        **   USE EXPONENTIAL INTERPOLATION                             
!                                                                       
         HDEN(K) = -DZ/ LOG(DENB(K)/DENA(K)) 
         GO TO 40 
!                                                                       
!        **   USE LINEAR INTERPOLATION                                  
!                                                                       
   30    HDEN(K) = 0.0 
   40 END DO 
   50 CONTINUE 
!                                                                       
!     **   LOOP THROUGH PATH                                            
!     **   INTEGRATE PATH QUANTITIES USING QUADRATIC INTEGRATION WITH   
!     **   UNEQUALLY SPACED POINTS                                      
!                                                                       
   60 CONTINUE 
      N = N+1 
      DH = -DELTAS*COSAI1 
      DHMIN = MAX(DH,DHMIN) 
      H3 = H1+DH 
      H3 = MIN(H3,Z2) 
      DH = H3-H1 
      R3 = RE+H3 
      H2 = H1+DH/2.0 
      R2 = RE+H2 
      SINAI2 = CPATH/(ANDEX(H2,SH,GAMMA)*R2) 
      SINAI3 = CPATH/(ANDEX(H3,SH,GAMMA)*R3) 
      RATIO2 = R2/RADREF(H2,SH,GAMMA) 
      RATIO3 = R3/RADREF(H3,SH,GAMMA) 
      IF ((1.0-SINAI2).GT.EPSILN) GO TO 70 
!                                                                       
!     **   NEAR A TANGENT HEIGHT, COSAI = -SQRT(1-SINAI**2) LOSES       
!     **   PRECISION. USE THE FOLLOWING ALGORITHM TO GET COSAI.         
!                                                                       
      Y3 = Y1+(SINAI1*(1.0-RATIO1)/R1+4.0*SINAI2*(1.0-RATIO2)/R2+SINAI3*&
     &   (1.0-RATIO3)/R3)*DH/6.0                                        
      COSAI3 = -SQRT(2.0*Y3-Y3**2) 
      X3 = -R3*COSAI3 
      DX = X3-X1 
      W1 = 0.5*DX 
      W2 = 0.0 
      W3 = 0.5*DX 
      GO TO 90 
!                                                                       
   70 CONTINUE 
      COSAI2 = -SQRT(1.0-SINAI2**2) 
      COSAI3 = -SQRT(1.0-SINAI3**2) 
      X2 = -R2*COSAI2 
      X3 = -R3*COSAI3 
!                                                                       
!     **   CALCULATE WEIGHTS                                            
!                                                                       
      D31 = X3-X1 
      D32 = X3-X2 
      D21 = X2-X1 
      IF (D32.EQ.0.0.OR.D21.EQ.0.0) GO TO 80 
      W1 = (2-D32/D21)*D31/6.0 
      W2 = D31**3/(D32*D21*6.0) 
      W3 = (2.0-D21/D32)*D31/6.0 
      GO TO 90 
   80 CONTINUE 
      W1 = 0.5*D31 
      W2 = 0.0 
      W3 = 0.5*D31 
!                                                                       
   90 CONTINUE 
      DSDX2 = 1.0/(1.0-RATIO2*SINAI2**2) 
      DSDX3 = 1.0/(1.0-RATIO3*SINAI3**2) 
      DBNDX2 = DSDX2*SINAI2*RATIO2/R2 
      DBNDX3 = DSDX3*SINAI3*RATIO3/R3 
!                                                                       
!     **   INTEGRATE                                                    
!                                                                       
      DS = W1*DSDX1+W2*DSDX2+W3*DSDX3 
      S = S+DS 
      DBEND = W1*DBNDX1+W2*DBNDX2+W3*DBNDX3 
      BEND = BEND+DBEND 
      IF (IAMT.EQ.2) GO TO 150 
!                                                                       
!     **   CALCULATE AMOUNTS                                            
!                                                                       
      DSDZ = DS/DH 
      PB = PA*EXP(-DH/HP) 
      RHOB = RHOA*EXP(-DH/HRHO) 
      IF ((DH/HRHO).LT.EPSILN) GO TO 100 
      PPSUML(J) = PPSUML(J)+DSDZ*(HP/(1.0+HP/HRHO))*(PA*RHOA-PB*RHOB) 
      TPSUML(J) = TPSUML(J)+DSDZ*HP*(PA-PB)/GCAIR 
      RHOSML(J) = RHOSML(J)+DSDZ*HRHO*(RHOA-RHOB) 
      GO TO 110 
  100 CONTINUE 
      PPSUML(J) = PPSUML(J)+0.5*DS*(PA*RHOA+PB*RHOB) 
      TPSUML(J) = TPSUML(J)+0.5*DS*(PA+PB)/GCAIR 
      RHOSML(J) = RHOSML(J)+0.5*DS*(RHOA+RHOB) 
  110 CONTINUE 
      DO 130 K = 1, KMAX 
         IF (ABS(HDEN(K)).EQ.0.0) GO TO 120 
         IF ((DH/HDEN(K)).LT.EPSILN) GO TO 120 
!                                                                       
!        **   EXPONENTIAL INTERPOLATION                                 
!                                                                       
         DENB(K) = DENL(K,J)*EXP(-(H3-Z1)/HDEN(K)) 
         AMTL(K,J) = AMTL(K,J)+DSDZ*HDEN(K)*(DENA(K)-DENB(K)) 
         GO TO 130 
  120    CONTINUE 
!                                                                       
!        **   LINEAR INTERPOLATION                                      
!                                                                       
         DENB(K) = DENL(K,J)+(DENL(K,J+1)-DENL(K,J))*(H3-Z1)/DZ 
         AMTL(K,J) = AMTL(K,J)+0.5*(DENA(K)+DENB(K))*DS 
  130 END DO 
      PA = PB 
      RHOA = RHOB 
      DO 140 K = 1, KMAX 
         DENA(K) = DENB(K) 
  140 END DO 
  150 CONTINUE 
      IF (H3.GE.Z2) GO TO 160 
      H1 = H3 
      R1 = R3 
      SINAI1 = SINAI3 
      RATIO1 = RATIO3 
      Y1 = Y3 
      COSAI1 = COSAI3 
      X1 = X3 
      DSDX1 = DSDX3 
      DBNDX1 = DBNDX3 
      GO TO 60 
  160 CONTINUE 
      SINAI = SINAI3 
      COSAI = COSAI3 
      SL(J) = S 
      RETURN 
      END                                           
!                                                                       
!     ***************************************************************** 
!                                                                       
      SUBROUTINE EQULWC 
!                                                                       
!     CC                                                                
!     CC   EQUIVALENT LIQUID  WATER CONSTANTS FOR BEXT (0.55UM)=1.0KM-1 
!     CC   AWCCON(1-4) IS SET TO ONE OF THE CONSTANTS FOR EACH AEROSOL  
!     CC   IN SUBROUTINE EXABIN AND MULTIPLIED BY THE BEXT (DENSTY(N,I))
!     CC   WHERE N=7,12,13 OR 14 AND I IS THE NUMBER OF LAYERS          
!     CC                                                                
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX0(47),AWCCON(5) 
!                                                                       
      CHARACTER*8      HMOD 
!                                                                       
      COMMON /CMN/ HMOD(3),ZN(MXZMD),PN(MXZMD),TN(MXZMD),RFNDXM(MXZMD), &
     &          ZP(IM2),PP(IM2),TP(IM2),RFNDXP(IM2),SP(IM2),PPSUM(IM2), &
     &          TPSUM(IM2),RHOPSM(IM2),IMMAX,WGM(MXZMD),DEMW(MXZMD),    &
     &          AMTP(MXMOL,MXPDIM)                                      
!                                                                       
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISS,N_LVL,JH1 
      COMMON /MODEL/ ZMDL(MXZMD),PM(MXZMD),TM(MXZMD),                   &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
!                                                                       
      DO 10 I = 1, ML 
         IF (DENSTY(7,I).NE.0.0) EQLWC(I) = DENSTY(7,I)*AWCCON(1) 
         IF (DENSTY(12,I).NE.0.0) EQLWC(I) = DENSTY(12,I)*AWCCON(2) 
         IF (DENSTY(13,I).NE.0.0) EQLWC(I) = DENSTY(13,I)*AWCCON(3) 
         IF (DENSTY(14,I).NE.0.0) EQLWC(I) = DENSTY(14,I)*AWCCON(4) 
   10 END DO 
      RETURN 
      END                                           
!                                                                       
!     ***************************************************************** 
!                                                                       
      SUBROUTINE INDX (WAVL,TC,KEY,REIL,AIMAG) 
!                                                                       
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
!     * *                                                               
!     * * WAVELENGTH IS IN CENTIMETERS.  TEMPERATURE IS IN DEG. C.      
!     * *                                                               
!     * * KEY IS SET TO 1 IN SUBROUTINE GAMFOG                          
!     * *                                                               
!     * * REIL IS THE REAL PART OF THE REFRACTIVE INDEX.                
!     * *                                                               
!     * * AIMAG IS THE IMAGINARY PART OF THE REFRACTIVE INDEX IT IS     
!     * *                                                               
!     * * RETURNED NEG. I.E.  M= REAL - I*AIMAG  .                      
!     * *                                                               
!     * * A SERIES OF CHECKS ARE MADE AND WARNINGS GIVEN.               
!     * *                                                               
!     * * RAY APPLIED OPTICS VOL 11,NO.8,AUG 72, PG. 1836-1844          
!     * *                                                               
!     * * CORRECTIONS HAVE BEEN MADE TO RAYS ORIGINAL PAPER             
!     * *                                                               
!     * *                                                               
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
!                                                                       
      R1 = 0.0 
      R2 = 0.0 
      IF (WAVL.LT..0001) WRITE (IPR,900) 
      IF (TC.LT.-20.) WRITE (IPR,905) 
      CALL DEBYE (WAVL,TC,KEY,REIL,AIMAG) 
!                                                                       
!     * *  TABLE 3 WATER PG. 1840                                       
!                                                                       
      IF (WAVL.GT..034) GO TO 10 
      GO TO 20 
   10 IF (WAVL.GT..1) GO TO 50 
      R2 = DOP(WAVL,1.83899,1639.,52340.4,10399.2,588.24,345005.,259913.&
     &   ,161.29,43319.7,27661.2)                                       
      R2 = R2+R2*(TC-25.)*.0001*EXP((.000025*WAVL)**.25) 
      REIL = REIL*(WAVL-.034)/.066+R2*(.1-WAVL)/.066 
      GO TO 50 
   20 IF (WAVL.GT..0006) GO TO 30 
      GO TO 40 
   30 REIL = DOP(WAVL,1.83899,1639.,52340.4,10399.2,588.24,345005.,     &
     &   259913.,161.29,43319.7,27661.2)                                
      REIL = REIL+REIL*(TC-25.)*.0001*EXP((.000025*WAVL)**.25) 
      IF (WAVL.GT..0007) GO TO 50 
      R1 = DOP(WAVL,1.79907,3352.27,99.914E+04,15.1963E+04,1639.,50483.5&
     &   ,9246.27,588.24,84.4697E+04,10.7615E+05)                       
      R1 = R1+R1*(TC-25.)*.0001*EXP((.000025*WAVL)**.25) 
      REIL = R1*(.0007-WAVL)/.0001+REIL*(WAVL-.0006)/.0001 
      GO TO 50 
   40 REIL = DOP(WAVL,1.79907,3352.27,99.914E+04,15.1963E+04,1639.,     &
     &   50483.5,9246.27,588.24,84.4697E+04,10.7615E+05)                
      REIL = REIL+REIL*(TC-25.)*.0001*EXP((.000025*WAVL)**.25) 
!                                                                       
!     * *  TABLE 2 WATER PG. 1840                                       
!                                                                       
   50 IF (WAVL.GE..3) GO TO 180 
      IF (WAVL.GE..03) GO TO 60 
      GO TO 70 
   60 AIMAG = AIMAG+AB(WAVL,.25,300.,.47,3.)+AB(WAVL,.39,17.,.45,1.3)+AB&
     &   (WAVL,.41,62.,.35,1.7)                                         
      GO TO 180 
   70 IF (WAVL.GE..0062) GO TO 80 
      GO TO 90 
   80 AIMAG = AIMAG+AB(WAVL,.41,62.,.35,1.7)+AB(WAVL,.39,17.,.45,1.3)+AB&
     &   (WAVL,.25,300.,.4,2.)                                          
      GO TO 180 
   90 IF (WAVL.GE..0017) GO TO 100 
      GO TO 110 
  100 AIMAG = AIMAG+AB(WAVL,.39,17.,.45,1.3)+AB(WAVL,.41,62.,.22,1.8)+AB&
     &   (WAVL,.25,300.,.4,2.)                                          
      GO TO 180 
  110 IF (WAVL.GE..00061) GO TO 120 
      GO TO 130 
  120 AIMAG = AIMAG+AB(WAVL,.12,6.1,.042,.6)+AB(WAVL,.39,17.,.165,2.4)+ &
     &   AB(WAVL,.41,62.,.22,1.8)                                       
      GO TO 180 
  130 IF (WAVL.GE..000495) GO TO 140 
      GO TO 150 
  140 AIMAG = AIMAG+AB(WAVL,.01,4.95,.05,1.)+AB(WAVL,.12,6.1,.009,2.) 
      GO TO 180 
  150 IF (WAVL.GE..000297) GO TO 160 
      GO TO 170 
  160 AIMAG = AIMAG+AB(WAVL,.27,2.97,.04,2.)+AB(WAVL,.01,4.95,.06,1.) 
      GO TO 180 
  170 AIMAG = AIMAG+AB(WAVL,.27,2.97,.025,2.)+AB(WAVL,.01,4.95,.06,1.) 
  180 CONTINUE 
      RETURN 
!                                                                       
  900 FORMAT(///,30X,'ATTEMPTING TO EVALUATE FOR A WAVELENGTH LESS THAN &
     &ONE MICRON',//)                                                   
  905 FORMAT(///,30X,'ATTEMPTING TO EVALUATE FOR A TEMPERATURE LESS THAN&
     & -20. DEGREES CENTIGRADE',//)                                     
!                                                                       
      END                                           
!                                                                       
!     ***************************************************************** 
!                                                                       
      SUBROUTINE DEBYE(WAVL,TC,KEY,RE,AI) 
!                                                                       
!     CC                                                                
!     CC    CALCULATES WAVENUMBER DEPENDENCE OF DIELECTRIC CONSTANT     
!     CC    OF WATER                                                    
!     CC                                                                
!                                                                       
      T = TC+273.15 
      IF (KEY.NE.0) GO TO 10 
      GO TO 20 
   10 EFIN = 5.27137+.0216474*TC-.00131198*TC*TC 
!                                                                       
!     CC   ALPHA=-16.8129/T+.0609265                                    
!                                                                       
      TAU = .00033836*EXP(2513.98/T) 
!                                                                       
!     CC   SIG=12.5664E+08                                              
!                                                                       
      ES = 78.54*(1.-.004579*(TC-25.)+.0000119*(TC-25.)**2-.000000028*  &
     &   (TC-25.)**3)                                                   
      GO TO 30 
   20 EFIN = 3.168 
!                                                                       
!     CC   ALPHA=.00023*TC*TC+.0052*TC+.288                             
!     CC   SIG=1.26*EXP(-12500./(T*1.9869))                             
!                                                                       
      TAU = 9.990288E-05*EXP(13200./(T*1.9869)) 
      ES = 3.168+.15*TC*TC+2.5*TC+200. 
   30 C1 = TAU/WAVL 
!                                                                       
!     CC                                                                
!     CC    TEMPORARY FIX TO CLASSICAL DEBYE EQUATION                   
!     CC    TO HANDLE ZERO CM-1 PROBLEM                                 
!     CC                                                                
!     CC   ALPHA=0.0                                                    
!     CC   SIG=0.0                                                      
!     CC                                                                
!     CC   C2=1.5708*ALPHA                                              
!     CC   DEM=1.+2.*C1**(1.-ALPHA)*SIN(C2)+C1**(2.*(1.-ALPHA))         
!     CC   E1=EFIN+(ES-EFIN)*(1.+(C1**(1.-ALPHA)*SIN(C2)))/DEM          
!     CC   IF(KEY.NE.0.AND.WAVL.GE.300.) E1=87.53-0.3956*TC             
!     CC   IF(KEY.NE.0 .AND. WAVL.GE.300.) E1=ES                        
!     CC   E2=(ES-EFIN)*C1**(1.-ALPHA)*COS(C2)/DEM+SIG*WAVL/18.8496E+10 
!     CC                                                                
!     CC    PERMANENT FIX TO CLSSICAL DEBYE EQUATION                    
!     CC    TO HANDLE ZERO CM-1 PROBLEM                                 
!     CC                                                                
!                                                                       
      E1 = EFIN+(ES-EFIN)/(1.0+C1**2) 
!                                                                       
!     CC                                                                
!                                                                       
      E2 = ((ES-EFIN)*C1)/(1.0+C1**2) 
!                                                                       
!     CC                                                                
!                                                                       
      RE = SQRT((E1+SQRT(E1*E1+E2*E2))/2.) 
      AI = -E2/(2.*RE) 
      RETURN 
      END                                           
      FUNCTION DOP(WAVL,A,CEN1,B,C,CEN2,D,E,CEN3,F,G) 
!                                                                       
!     CC                                                                
!     CC    DESCRIBES THE REAL PART OF THE DIELECTRIC CONSTANT          
!     CC                                                                
!                                                                       
      V = 1./WAVL 
      V2 = V*V 
      H1 = CEN1**2-V2 
      H2 = CEN2**2-V2 
      H3 = CEN3**2-V2 
      DOP = SQRT(A+B*H1/(H1*H1+C*V2)+D*H2/(H2*H2+E*V2)+F*H3/(H3*H3+G*V2)&
     &   )                                                              
      RETURN 
      END                                           
      FUNCTION AB(WAVL,A,CEN,B,C) 
!                                                                       
!     CC                                                                
!     CC    DESCRIBES THE IMAGINARY PART OF THE DIELECTRIC CONSTANT     
!     CC                                                                
!                                                                       
      AB = -A*EXP(-ABS(( LOG10(10000.*WAVL/CEN)/B))**C) 
      RETURN 
      END                                           
      FUNCTION GAMFOG(FREQ,T,RHO) 
!                                                                       
!     COMPUTES ATTENUATION OF EQUIVALENT LIQUID WATER CONTENT           
!     IN CLOUDS OR FOG IN DB/KM                                         
!     CONVERTED TO NEPERS BY NEW CONSTANT 1.885                         
!                                                                       
!     FREQ = WAVENUMBER (INVERSE CM)                                    
!     T    = TEMPERATURE (DEGREES KELVIN)                               
!     RHO  = EQUIVALENT LIQUID CONTENT  (G/CUBIC METER)                 
!     CINDEX=COMPLEX DIELECTRIC CONSTANT M  FROM INDEX                  
!     WAVL = WAVELENGTH IN CM                                           
!                                                                       
      COMPLEX CINDEX 
      IF (RHO.GT.0.) GO TO 10 
      GAMFOG = 0. 
      RETURN 
   10 CONTINUE 
      KEY = 1 
      WAVL = 1.0/FREQ 
      TC = T-273.2 
!                                                                       
!     CC                                                                
!     CC    CHANGE TEMP SO THAT MINIMUM IS -20.0 CENT.                  
!     CC                                                                
!                                                                       
      TC = MAX(TC,-20.0) 
      CALL INDX (WAVL,TC,KEY,REIL,AIMAK) 
      CINDEX = CMPLX(REIL,AIMAK) 
!                                                                       
!     CC                                                                
!     CC   ATTENUATION = 6.0*PI*FREQ*RHO*IMAG(-K)                       
!     CC    6.0*PI/10. = 1.885 (THE FACTOR OF 10 IS FOR UNITS CONVERSION
!     CC                                                                
!     GAMFOG=8.1888*FREQ*RHO*AIMAG( -  (CINDEX**2-1)/(CINDEX**2+2))     
!                                                                       
      GAMFOG = 1.885*FREQ*RHO*AIMAG(-(CINDEX**2-1)/(CINDEX**2+2)) 
      RETURN 
      END                                           
      FUNCTION AITK(ARG,VAL,X,NDIM) 
!                                                                       
!     IBM SCIENTIFIC SUBROUTINE                                         
!     AITKEN INTERPOLATION ROUTINE                                      
!                                                                       
      DIMENSION ARG(NDIM),VAL(NDIM) 
!                                                                       
      IF (NDIM.gt.1) then 
!                                                                       
!     START OF AITKEN-LOOP                                              
!                                                                       
   10    DO 30 J = 2, NDIM 
            IEND = J-1 
            DO 20 I = 1, IEND 
               H = ARG(I)-ARG(J) 
               IF (H.eq.0) go to 70 
               VAL(J) = (VAL(I)*(X-ARG(J))-VAL(J)*(X-ARG(I)))/H 
   20       continue 
   30    END DO 
!                                                                       
!     END OF AITKEN-LOOP                                                
!                                                                       
         endif 
                                                                        
                                                                        
   40    J = NDIM 
   50    AITK = VAL(J) 
   60    RETURN 
!                                                                       
!     THERE ARE TWO IDENTICAL ARGUMENT VALUES IN VECTOR ARG             
!                                                                       
   70    IER = 3 
         J = IEND 
         GO TO 50 
      END                                           
      FUNCTION GMRAIN(FREQ,T,RATE) 
!                                                                       
!     COMPUTES ATTENUATION OF CONDENSED WATER IN FORM OF RAIN           
!                                                                       
!     FREQ = WAVENUMBER (CM-1)                                          
!     T    = TEMPERATURE (DEGREES KELVIN)                               
!     RATE = PRECIPITATION RATE (MM/HR)                                 
!     WVLTH = WAVELENGTH IN CM                                          
!                                                                       
!     TABLES ATTAB AND FACTOR CALCULATED FROM FULL MIE THEORY           
!     UTILIZING MARSHALL-PALMER SIZE DISTRIBUTION WITH RAYS INDEX       
!     OF REFRACTION                                                     
!                                                                       
!     ATTAB IS ATTENUATION DATA TABLE IN NEPERS FOR 20 DEG CELSIUS      
!     WITH RADIATION FIELD REMOVED                                      
!                                                                       
!     WVNTBL IS WAVENUMBER TABLE FOR WAVENUMBERS USED IN TABLE ATTAB    
!     TMPTAB IS INTERPOLATION DATA TABLE FOR TEMPERATURES IN DEG KELVIN 
!                                                                       
!     TLMDA IS INTERPOLATION DATA TABLE FOR WAVELENGTH IN CM            
!     TFREQ IS INTERPOLATION DATA TABLE FOR WAVENUMBER IN CM-1          
!                                                                       
!     RATTAB IS RAIN RATE TABLE IN MM/HR                                
!                                                                       
!     FACTOR IS TABLE OF TEMPERATURE CORRECTION FACTORS FOR             
!     TABLE ATTAB FOR REPRESENTATIVE RAINS WITHOUT RADIATION FIELD      
!                                                                       
!                                                                       
!     AITKEN INTERPOLATION SCHEME WRITTEN BY                            
!     E.T. FLORANCE O.N.R. PASADENA CA.                                 
!                                                                       
!                                                                       
      DIMENSION ATTAB1(35),ATTAB2(35),ATTAB3(35),ATTAB4(35),ATTAB5(35) 
      DIMENSION ATTAB6(35),ATTAB7(35),ATTAB8(35),ATTAB9(35) 
      DIMENSION ATTAB(35,9),WVLTAB(27),RATTAB(9),FACTOR(5,8,5) 
      DIMENSION X(4),Y(4),ATTN(4),RATES(4) 
!                                                                       
!     CC   DIMENSION X(3),Y(3),ATTN(3),RATES(3)                         
!                                                                       
      DIMENSION TMPTAB(5),TLMDA(6),FACIT(5),TFACT(5) 
      DIMENSION TFREQ(8),WVNTBL(35) 
      DIMENSION FACEQ1(5,8),FACEQ2(5,8),FACEQ3(5,8),FACEQ4(5,8) 
      DIMENSION FACEQ5(5,8) 
      EQUIVALENCE (ATTAB1(1),ATTAB(1,1)),(ATTAB2(1),ATTAB(1,2)) 
      EQUIVALENCE (ATTAB3(1),ATTAB(1,3)),(ATTAB4(1),ATTAB(1,4)) 
      EQUIVALENCE (ATTAB5(1),ATTAB(1,5)),(ATTAB6(1),ATTAB(1,6)) 
      EQUIVALENCE (ATTAB7(1),ATTAB(1,7)),(ATTAB8(1),ATTAB(1,8)) 
      EQUIVALENCE (ATTAB9(1),ATTAB(1,9)) 
      EQUIVALENCE (FACEQ1(1,1),FACTOR(1,1,1)) 
      EQUIVALENCE (FACEQ2(1,1),FACTOR(1,1,2)) 
      EQUIVALENCE (FACEQ3(1,1),FACTOR(1,1,3)) 
      EQUIVALENCE (FACEQ4(1,1),FACTOR(1,1,4)) 
      EQUIVALENCE (FACEQ5(1,1),FACTOR(1,1,5)) 
!                                                                       
      DATA WVLTAB/.03,.033,.0375,.043,.05,.06,.075,.1,.15,.2,.25,.3,.5, &
     &.8,1.,2.,3.,4.,5.,5.5,6.,6.5,7.,8.,9.,10.,15./                    
      DATA WVNTBL/ 0.0000,                                              &
     &    .0667,.1000,.1111,.1250,.1429,.1538,                          &
     &  .1667,.1818,.2000,.2500,.3333,.5000,1.0000,                     &
     & 1.2500,2.0000,3.3333,4.0000,5.0000,6.6667,10.0000,               &
     & 13.3333,16.6667,20.0000,23.2558,26.6667,30.3030,33.3333,         &
     & 50.0,80.0,120.0,180.0,250.0,300.0,350.0/                         
      DATA RATTAB /.25,1.25,2.5,5.,12.5,25.,50.,100.,150./ 
      DATA TLMDA/.03,.1,.5,1.25,3.2,10./ 
      DATA TFREQ/0.0,0.1,0.3125,0.8,2.0,10.0,33.3333,350.0/ 
      DATA TMPTAB/273.15,283.15,293.15,303.15,313.15/ 
      DATA ATTAB1/                                                      &
     & 1.272E+00,1.332E+00,1.361E+00,1.368E+00,1.393E+00,1.421E+00,     &
     & 1.439E+00,1.466E+00,1.499E+00,1.541E+00,1.682E+00,1.951E+00,     &
     & 2.571E+00,3.575E+00,3.808E+00,4.199E+00,3.665E+00,3.161E+00,     &
     & 2.462E+00,1.632E+00,8.203E-01,4.747E-01,3.052E-01,2.113E-01,     &
     & 1.551E-01,1.168E-01,8.958E-02,7.338E-02,3.174E-02,1.178E-02,     &
     & 5.016E-03,2.116E-03,1.123E-03,8.113E-04,6.260E-04/               
      DATA ATTAB2/                                                      &
     & 4.915E+00,5.257E+00,5.518E+00,5.632E+00,5.807E+00,6.069E+00,     &
     & 6.224E+00,6.452E+00,6.756E+00,7.132E+00,8.453E+00,1.132E+01,     &
     & 1.685E+01,2.177E+01,2.246E+01,2.156E+01,1.470E+01,1.167E+01,     &
     & 8.333E+00,5.089E+00,2.356E+00,1.320E+00,8.315E-01,5.705E-01,     &
     & 4.151E-01,3.119E-01,2.385E-01,1.955E-01,8.373E-02,3.138E-02,     &
     & 1.351E-02,5.789E-03,3.090E-03,2.236E-03,1.725E-03/               
      DATA ATTAB3/                                                      &
     & 8.798E+00,9.586E+00,1.023E+01,1.049E+01,1.093E+01,1.159E+01,     &
     & 1.205E+01,1.263E+01,1.343E+01,1.450E+01,1.832E+01,2.627E+01,     &
     & 3.904E+01,4.664E+01,4.702E+01,4.152E+01,2.542E+01,1.959E+01,     &
     & 1.363E+01,8.087E+00,3.660E+00,2.028E+00,1.274E+00,8.710E-01,     &
     & 6.340E-01,4.757E-01,3.634E-01,2.971E-01,1.275E-01,4.795E-02,     &
     & 2.072E-02,8.936E-03,4.780E-03,3.460E-03,2.670E-03/               
      DATA ATTAB4/                                                      &
     & 1.575E+01,1.750E+01,1.914E+01,1.991E+01,2.108E+01,2.276E+01,     &
     & 2.399E+01,2.561E+01,2.785E+01,3.097E+01,4.204E+01,6.334E+01,     &
     & 8.971E+01,9.853E+01,9.609E+01,7.718E+01,4.290E+01,3.220E+01,     &
     & 2.188E+01,1.271E+01,5.641E+00,3.110E+00,1.947E+00,1.327E+00,     &
     & 9.657E-01,7.242E-01,5.539E-01,4.528E-01,1.942E-01,7.335E-02,     &
     & 3.181E-02,1.380E-02,7.394E-03,5.354E-03,4.132E-03/               
      DATA ATTAB5/                                                      &
     & 3.400E+01,3.927E+01,4.523E+01,4.796E+01,5.207E+01,5.886E+01,     &
     & 6.383E+01,7.060E+01,8.005E+01,9.360E+01,1.381E+02,2.069E+02,     &
     & 2.620E+02,2.534E+02,2.366E+02,1.673E+02,8.285E+01,6.059E+01,     &
     & 4.013E+01,2.280E+01,9.939E+00,5.439E+00,3.400E+00,2.315E+00,     &
     & 1.685E+00,1.263E+00,9.664E-01,7.914E-01,3.397E-01,1.288E-01,     &
     & 5.611E-02,2.450E-02,1.316E-02,9.536E-03,7.360E-03/               
      DATA ATTAB6/                                                      &
     & 6.087E+01,7.347E+01,8.886E+01,9.653E+01,1.081E+02,1.283E+02,     &
     & 1.435E+02,1.649E+02,1.947E+02,2.346E+02,3.543E+02,4.991E+02,     &
     & 5.705E+02,5.048E+02,4.510E+02,2.900E+02,1.335E+02,9.607E+01,     &
     & 6.269E+01,3.520E+01,1.519E+01,8.295E+00,5.182E+00,3.529E+00,     &
     & 2.569E+00,1.927E+00,1.474E+00,1.208E+00,5.191E-01,1.975E-01,     &
     & 8.627E-02,3.784E-02,2.037E-02,1.476E-02,1.139E-02/               
      DATA ATTAB7/                                                      &
     & 1.090E+02,1.396E+02,1.811E+02,2.029E+02,2.396E+02,3.039E+02,     &
     & 3.536E+02,4.189E+02,5.081E+02,6.217E+02,9.038E+02,1.165E+03,     &
     & 1.212E+03,9.731E+02,8.330E+02,4.901E+02,2.123E+02,1.507E+02,     &
     & 9.718E+01,5.408E+01,2.316E+01,1.264E+01,7.896E+00,5.377E+00,     &
     & 3.915E+00,2.939E+00,2.249E+00,1.844E+00,7.940E-01,3.029E-01,     &
     & 1.327E-01,5.846E-02,3.151E-02,2.284E-02,1.763E-02/               
      DATA ATTAB8/                                                      &
     & 1.950E+02,2.703E+02,3.904E+02,4.614E+02,5.825E+02,7.909E+02,     &
     & 9.475E+02,1.142E+03,1.380E+03,1.656E+03,2.237E+03,2.610E+03,     &
     & 2.500E+03,1.820E+03,1.491E+03,8.103E+02,3.336E+02,2.344E+02,     &
     & 1.495E+02,8.273E+01,3.524E+01,1.922E+01,1.203E+01,8.182E+00,     &
     & 5.961E+00,4.477E+00,3.429E+00,2.812E+00,1.216E+00,4.651E-01,     &
     & 2.043E-01,9.033E-02,4.874E-02,3.534E-02,2.728E-02/               
      DATA ATTAB9/                                                      &
     & 2.742E+02,4.012E+02,6.353E+02,7.829E+02,1.027E+03,1.439E+03,     &
     & 1.725E+03,2.071E+03,2.475E+03,2.909E+03,3.738E+03,4.104E+03,     &
     & 3.776E+03,2.589E+03,2.070E+03,1.078E+03,4.326E+02,3.023E+02,     &
     & 1.918E+02,1.059E+02,4.499E+01,2.454E+01,1.539E+01,1.045E+01,     &
     & 7.615E+00,5.722E+00,4.384E+00,3.596E+00,1.561E+00,5.978E-01,     &
     & 2.630E-01,1.165E-01,6.292E-02,4.562E-02,3.522E-02/               
      DATA FACEQ1/                                                      &
     & 1.606,1.252,1.000, .816, .680,1.603,1.246,1.000, .817, .684,     &
     & 1.444,1.207,1.000, .838, .694,1.016, .985,1.000,1.034,1.058,     &
     &  .950, .976,1.000,1.034,1.068, .922, .956,1.000,1.044,1.090,     &
     &  .932, .966,1.000,1.034,1.068, .957, .978,1.000,1.022,1.044/     
      DATA FACEQ2/                                                      &
     & 1.606,1.252,1.000, .816, .680,1.612,1.256,1.000, .817, .684,     &
     & 1.193,1.101,1.000, .889, .769, .885, .927,1.000,1.086,1.175,     &
     &  .941, .976,1.000,1.024,1.047, .932, .966,1.000,1.034,1.079,     &
     &  .932, .966,1.000,1.034,1.068, .957, .978,1.000,1.022,1.044/     
      DATA FACEQ3/                                                      &
     & 1.606,1.252,1.000, .816, .680,1.621,1.256,1.000, .817, .673,     &
     &  .969, .995,1.000, .982, .940, .895, .937,1.000,1.075,1.143,     &
     &  .950, .976,1.000,1.024,1.036, .932, .966,1.000,1.034,1.079,     &
     &  .932, .966,1.000,1.034,1.068, .957, .978,1.000,1.022,1.044/     
      DATA FACEQ4/                                                      &
     & 1.606,1.252,1.000, .816, .680,1.631,1.265,1.000, .807, .662,     &
     &  .848, .927,1.000,1.044,1.079, .922, .956,1.000,1.055,1.111,     &
     &  .950, .976,1.000,1.013,1.036, .932, .966,1.000,1.034,1.079,     &
     &  .932, .966,1.000,1.034,1.068, .957, .978,1.000,1.022,1.044/     
      DATA FACEQ5/                                                      &
     & 1.606,1.252,1.000, .816, .680,1.603,1.265,1.000, .807, .662,     &
     &  .820, .918,1.000,1.075,1.132, .941, .966,1.000,1.034,1.079,     &
     &  .960, .976,1.000,1.013,1.036, .932, .966,1.000,1.034,1.079,     &
     &  .932, .966,1.000,1.034,1.068, .957, .978,1.000,1.022,1.044/     
      DATA RATLIM /.05/ 
!                                                                       
!     GIVE ZERO ATTN IF RATE FALLS BELOW LIMIT                          
!                                                                       
      IF (RATE.GT.RATLIM) GO TO 10 
      GMRAIN = 0. 
      RETURN 
   10 WVLTH = 1.0/FREQ 
!                                                                       
!     CC   JMAX=3                                                       
!                                                                       
      JMAX = 4 
!                                                                       
!     CC   IF(WVLTH.GT.WVLTAB(1)) GO TO      14                         
!     CC   ILOW=0                                                       
!     CC   JMAX=2                                                       
!     CC   GO TO 18                                                     
!     CC   THIS DO LOOP IS 2 LESS THAN NO. OF WVLTAB INPUT              
!     CC14 DO 15 I=2,25                                                 
!                                                                       
      DO 20 I = 3, 33 
!                                                                       
!        CC   IF(WVLTH.LT.(.5*(WVLTAB(I)+WVLTAB(I+1)))) GO TO 16        
!                                                                       
         IF (FREQ.LT.WVNTBL(I)) GO TO 30 
   20 END DO 
!                                                                       
!     CC   SET ILOW EQUAL TO 1 LESS THAN DO MAX                         
!     CC   ILOW=24                                                      
!                                                                       
      I = 34 
!                                                                       
!     CC   GO TO 18                                                     
!     CC16 ILOW = I-2                                                   
!                                                                       
   30 ILOW = I-3 
!                                                                       
!     CC   DO 190 I=2,7                                                 
!                                                                       
      DO 40 K = 3, 7 
!                                                                       
!        CC   IF (RATE. LT.(.5*(RATTAB(I)+RATTAB(I+1))))GO TO 195       
!                                                                       
         IF (RATE.LT.RATTAB(K)) GO TO 50 
   40 END DO 
!                                                                       
!     CC   KMIN=6                                                       
!                                                                       
      K = 8 
!                                                                       
!     CC   GO TO 198                                                    
!     C195 KMIN=I-2                                                     
!                                                                       
   50 KMIN = K-3 
      DO 60 J = 1, JMAX 
         IJ = ILOW+J 
         X(J) = WVNTBL(IJ) 
   60 END DO 
!                                                                       
!     INTERPOLATE                                                       
!     CC   Z = - LOG(FREQ)                                              
!     CC   DO 25 K=1,3                                                  
!                                                                       
      DO 80 K = 1, 4 
         KJ = KMIN+K 
         RATES(K) = RATTAB(KJ) 
         DO 70 J = 1, JMAX 
            IJ = ILOW+J 
            Y(J) = LOG(ATTAB(IJ,KJ)) 
   70    CONTINUE 
         ATTN(K) = EXP(AITK(X,Y,FREQ,JMAX)) 
   80 END DO 
!                                                                       
!     APPLY TEMPERATURE CORRECTION                                      
!                                                                       
      DO 90 I = 2, 5 
         IF (T.LT.TMPTAB(I)) GO TO 100 
   90 END DO 
      ILOW = 4 
      GO TO 110 
  100 ILOW = I-1 
  110 CONTINUE 
      DO 120 J = 2, 8 
         IF (FREQ.LT.TFREQ(J)) GO TO 130 
  120 END DO 
!                                                                       
!     CC   JLOW IS 2 LESS THAN DO MAX                                   
!                                                                       
      JLOW = 6 
      GO TO 140 
  130 JLOW = J-2 
  140 CONTINUE 
      DO 160 K = 1, 2 
         DO 150 J = 1, 2 
!                                                                       
!           INTERPOLATE IN TEMPERATURE                                  
!           CC   KJ=(KMIN/2)+K                                          
!                                                                       
            KJ = K+(KMIN+1)/2 
            JI = JLOW+J 
            FAC = ((TMPTAB(ILOW)-T)*FACTOR(ILOW+1,JI,KJ)+(T-TMPTAB(ILOW+&
            1))*FACTOR(ILOW,JI,KJ))/(TMPTAB(ILOW)-TMPTAB(ILOW+1))       
            JI = JLOW+3-J 
            FACIT(J) = (TFREQ(JI)-FREQ)*FAC 
  150    CONTINUE 
         TFACT(K) = (FACIT(2)-FACIT(1))/(TFREQ(JLOW+1)-TFREQ(JLOW+2)) 
  160 END DO 
!                                                                       
!     COMPUTE ATTENUATION (DB/KM)                                       
!     CC   KJ=2*KMIN/2+1                                                
!                                                                       
      KJ = 2*((KMIN+1)/2)+1 
!                                                                       
!     CC   GMRAIN=AITK(RATES,ATTN,RATE,3)*                              
!                                                                       
      GMRAIN = AITK(RATES,ATTN,RATE,4)*((RATE-RATTAB(KJ))*TFACT(2)+     &
     &   (RATTAB(KJ+2)-RATE)*TFACT(1))/(RATTAB(KJ+2)-RATTAB(KJ))        
!                                                                       
!     CC                                                                
!     CC    APPLY CONVERSION TO NEPERS                                  
!     CC                                                                
!                                                                       
      RETURN 
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE CIRRUS(CTHIK,CALT,ISEED,CPROB,MODEL) 
!                                                                       
!     ******************************************************************
!     *  ROUTINE TO GENERATE ALTITUDE PROFILES OF CIRRUS DENSITY        
!     *  PROGRAMMED BY   M.J. POST                                      
!     *                  R.A. RICHTER        NOAA/WPL                   
!     *                                      BOULDER, COLORADO          
!     *                                      01/27/1981                 
!     *                                                                 
!     *  INPUTS|                                                        
!     *           CHTIK    -  CIRRUS THICKNESS (KM)                     
!     *                       0 = USE THICKNESS STATISTICS              
!     *                       .NE. 0 = USER DEFINES THICKNESS           
!     *                                                                 
!     *           CALT     -  CIRRUS BASE ALTITUDE (KM)                 
!     *                       0 = USE CALCULATED VALUE                  
!     *                       .NE. 0 = USER DEFINES BASE ALTITUDE       
!     *                                                                 
!     *           ICIR     -  CIRRUS PRESENCE FLAG                      
!     *                       0 = NO CIRRUS                             
!     *                       .NE. 0 = USE CIRRUS PROFILE               
!     *                                                                 
!     *           MODEL    -  ATMOSPHERIC MODEL                         
!     *                       1-5  AS IN MAIN PROGRAM                   
!     *                       MODEL = 0,6,7 NOT USED SET TO 2           
!     *                                                                 
!     *           ISEED    -  RANDOM NUMBER INITIALIZATION FLAG.        
!     *                       0 = USE DEFAULT MEAN VALUES FOR CIRRUS    
!     *                       .NE. 0 = INITIAL VALUE OF SEED FOR RANF   
!     *                       FUNCTION. CHANGE SEED VALUE EACH RUN FOR  
!     *                       DIFFERENT RANDOM NUMBER SEQUENCES. THIS   
!     *                       PROVIDES FOR STATISTICAL DETERMINATION    
!     *                       OF CIRRUS BASE ALTITUDE AND THICKNESS.    
!     *                                                                 
!     *  OUTPUTS|                                                       
!     *         CTHIK        -  CIRRUS THICKNESS (KM)                   
!     *         CALT         -  CIRRUS BASE ALTITUDE (KM)               
!     *         DENSTY(16,I) -  ARRAY, ALTITUDE PROFILE OF CIRRUS DENSIT
!     *         CPROB        -  CIRRUS PROBABILITY                      
!     *                                                                 
!     ******************************************************************
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX2(47),AWCCON(5) 
!                                                                       
      CHARACTER*8      HMOD 
!                                                                       
!                                                                       
      COMMON /CMN/ HMOD(3),ZN(MXZMD),PN(MXZMD),TN(MXZMD),RFNDXM(MXZMD), &
     &         ZP(IM2),PP(IM2),TP(IM2),RFNDXP(IM2),SP(IM2), PPSUM(IM2), &
     &          TPSUM(IM2),RHOPSM(IM2),IMMAX,WGM(MXZMD),DEMW(MXZMD),    &
     &          AMTP(MXMOL,MXPDIM)                                      
!                                                                       
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,N_LVL,JH1 
      COMMON /MODEL/ ZMDL (MXZMD),PM(MXZMD),TM(MXZMD),                  &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
!                                                                       
      DIMENSION CBASE(5,2),TSTAT(11),PTAB(5),CAMEAN(5) 
      DIMENSION CBASE1(5),CBASE2(5) 
!                                                                       
      EQUIVALENCE (CBASE1(1),CBASE(1,1)),(CBASE2(1),CBASE(1,2)) 
!                                                                       
!     ISEED IS INTEGER*4                                                
!                                                                       
      INTEGER*4 ISEED,IDUM 
!                                                                       
      DATA  CAMEAN           / 11.0, 10.0, 8.0, 7.0, 5.0 / 
      DATA  PTAB           / 0.8, 0.4, 0.5, 0.45, 0.4/ 
      DATA  CBASE1            / 7.5, 7.3, 4.5, 4.5, 2.5 / 
      DATA  CBASE2            /16.5,13.5,14.0, 9.5,10.0 / 
      DATA  TSTAT             / 0.0,.291,.509,.655,.764,.837,.892,      &
     & 0.928, 0.960, 0.982, 1.00 /                                      
!                                                                       
!     SET CIRRUS PROBABILITY AND PROFILE TO ALL ZEROES                  
!                                                                       
      CPROB = 0.0 
      MDL = MODEL 
!                                                                       
      DO 10 I = 1, 68 
         DENSTY(16,I) = 0. 
   10 END DO 
!                                                                       
!     CHECK IF USER WANTS TO USE A THICKNESS VALUE HE PROVIDES, CALCULAT
!     A STATISTICAL THICKNESS, OR USE A MEAN THICKNESS (ISEED = 0).     
!     DEFAULTED MEAN CIRRUS THICKNESS IS 1.0 KM.                        
!                                                                       
      IF (CTHIK.GT.0.0) GO TO 40 
      IF (ISEED.NE.0) GO TO 20 
      CTHIK = 1.0 
      GO TO 40 
!                                                                       
!     > CALCULATE CLOUD THICKNESS USING LOWTRAN CIRRUS THICKNESS STATIST
!     > NOTE - THIS ROUTINE USES A UNIFORM RANDOM NUMBER GENERATOR      
!     > WHICH RETURNS A NUMBER BETWEEN 0 AND 1.                         
!     >                                                                 
!                                                                       
   20 IDUM = -ISEED 
!                                                                       
      URN = RANDM(IDUM) 
      DO 30 I = 1, 10 
         IF (URN.GE.TSTAT(I).AND.URN.LT.TSTAT(I+1)) CTHIK = I-1 
   30 END DO 
      CTHIK = CTHIK/2.0+RANDM(IDUM)/2.0 
!                                                                       
!     DENCIR IS CIRRUS DENSITY IN KM-1                                  
!                                                                       
   40 DENCIR = 0.07*CTHIK 
!                                                                       
!     BASE HEIGHT CALCULATIONS                                          
!                                                                       
      IF (MODEL.LT.1.OR.MODEL.GT.5) MDL = 2 
      CPROB = 100.0*PTAB(MDL) 
!                                                                       
      HMAX = CBASE(MDL,2)-CTHIK 
      BRANGE = HMAX-CBASE(MDL,1) 
      IF (CALT.GT.0.0) GO TO 60 
      IF (ISEED.NE.0) GO TO 50 
      CALT = CAMEAN(MDL) 
      GO TO 60 
   50 CALT = BRANGE*RANDM(IDUM)+CBASE(MDL,1) 
!                                                                       
!     PUT CIRRUS DENSITY IN CORRECT ALTITUDE BINS. IF MODEL = 7,        
!     INTERPOLATE EH(16,I) FOR NON-STANDARD ALTITUDE BOUNDARIES.        
!                                                                       
   60 TOP = CALT+CTHIK 
      BOTTOM = CALT 
      IF (TOP.LT.ZMDL(1)) RETURN 
      IF (BOTTOM.GT.ZMDL(ML)) RETURN 
      IML = ML-1 
      DO 70 I = 1, IML 
         ZMIN = ZMDL(I) 
         ZMAX = ZMDL(I+1) 
         DENOM = ZMAX-ZMIN 
         IF (BOTTOM.LE.ZMIN.AND.TOP.GE.ZMAX) DENSTY(16,I) = DENCIR 
         IF (BOTTOM.GE.ZMIN.AND.TOP.LT.ZMAX) DENSTY(16,I) = DENCIR*     &
         CTHIK /DENOM                                                   
         IF (BOTTOM.GE.ZMIN.AND.TOP.GE.ZMAX.AND.BOTTOM.LT.ZMAX) DENSTY( &
         16,I) = DENCIR*(ZMAX-BOTTOM)/DENOM                             
         IF (BOTTOM.LT.ZMIN.AND.TOP.LE.ZMAX.AND.TOP.GT.ZMIN) DENSTY(16, &
         I ) = DENCIR*(TOP-ZMIN)/DENOM                                  
   70 END DO 
      RETURN 
      END                                           
!                                                                       
!     ***************************************************************** 
!                                                                       
      SUBROUTINE VSA(IHAZE,VIS,CEILHT,DEPTH,ZINVHT,Z,RH,AHAZE,IH) 
!                                                                       
!     VERTICAL STRUCTURE ALGORITHM                                      
!                                                                       
!     FROM ATMOSPHERIC SCIENCES LAB (U.S. ARMY)                         
!     WHITE SANDS N.M.                                                  
!                                                                       
!     CREATES A PROFILE OF AEROSOL DENSITY NEAR THE GROUND,INCLUDING    
!     CLOUDS AND FOG                                                    
!                                                                       
!     THESE PROFILES ARE AT 9 HEIGHTS BETWEEN 0 KM AND 2 KM             
!                                                                       
!                                                                       
!     ***VISIBILITY IS ASSUMED TO BE THE SURFACE VISIBILITY***          
!                                                                       
!     IHAZE  = THE TYPE OF AEROSOL                                      
!     VIS    = VISIBILITY IN KM                                         
!     CEILHT = THE CLOUD CEILING HEIGHT IN KM                           
!     DEPTH  = THE CLOUD/FOG DEPTH IN KM                                
!     ZINVHT = THE HEIGHT OF INVERSION OR BOUNDARY LAYER IN KM          
!                                                                       
!     VARIABLES USED IN VSA                                             
!                                                                       
!     ZC     = CLOUD CEILING HEIGHT IN M                                
!     ZT     = CLOUD DEPTH IN M                                         
!     ZINV   = INVERSION HEIGHT IN M                                    
!     SEE BELOW FOR MORE INFORMATION ABOUT ZC, ZT, AND ZINV             
!     D      = INITIAL EXTINCTION AT THE SURFACE (D=3.912/VIS)          
!     ZALGO  = THE DEPTH OF THE LAYER FOR THE ALGORITHM                 
!                                                                       
!     OUTPUT FROM VSA:                                                  
!                                                                       
!     Z      = HEIGHT IN KM                                             
!     RH     = RELATIVE HUMIDITY AT HEIGHT Z IN PERCENT                 
!     AHAZE  = EXTINCTION AT HEIGHT Z IN KM**-1                         
!     IH     = AEROSAL TYPE FOR HEIGHT Z                                
!     HMAX   = MAXIMUM HEIGHT IN KM USED IN VSA, NOT NECESSARILY 2.0 KM 
!                                                                       
!                                                                       
!     THE SLANT PATH CALCULATION USES THE FOLLOWING FUNCTION:           
!                                                                       
!     EXT55=A*EXP(B*EXP(C*Z))                                           
!                                                                       
!     WHERE 'Z' IS THE HEIGHT IN KILOMETERS,                            
!     'A' IS A FUNCTION OF EXT55 AT Z=0.0 AND IS ALWAYS POSITIVE,       
!     'B' AND 'C' ARE FUNCTIONS OF CLOUD CONDITIONS AND SURFACE         
!     VISIBILITY (EITHER A OR B CAN BE POSITIVE OR NEGATIVE),           
!     'EXT55' IS THE VISIBILE EXTINCTION COEFFICIENT IN KM**-1.         
!                                                                       
!     THEREFORE, THERE ARE 4 CASES DEPENDING ON THE SIGNS OF 'B' AND 'C'
!     CEILHT AND ZINVHT ARE USED AS SWITCHES TO DETERMINE WHICH CASE    
!     TO USE.  THE SURFACE EXTINCTION 'D' IS CALCULATED FROM THE        
!     VISIBILITY USING  D=3.912/VIS-0.012 AS FOLLOWS-                   
!                                                                       
!     CASE=1  FOG/CLOUD CONDITIONS                                      
!     'B' LT 0.0, 'C' LT 0.0                                            
!     'D' GE 7.064 KM**-1                                               
!     FOR A CLOUD 7.064 KM**-1 IS THE BOUNDARY VALUE AT                 
!     THE CLOUD BASE AND 'Z' IS THE VERTICAL DISTANCE                   
!     INTO THE CLOUD.                                                   
!     VARIABLE USED:   DEPTH                                            
!     ** DEFAULT:  DEPTH OF FOG/CLOUD IS 0.2 KM WHEN                    
!     'DEPTH' IS 0.0                                                    
!                                                                       
!     =2  CLOUD CEILING PRESENT                                         
!     'B' GT 0.0, 'C' GT 0.0                                            
!     'D' GT 0.398 KM**-1 IS CASE 2 FOR HAZY/FOG                        
!     SURFACE CONDITIONS                                                
!     'D' LE 0.398 KM**-1 IS CASE 2' FOR CLEAR/HAZY                     
!     SURFACE CONDITIONS                                                
!     VARIABLE USED:   CEILHT (MUST BE GE 0.0)                          
!     ** DEFAULTS:  CASE 2 - CEILHT IS CALCULATED FROM                  
!     SURFACE EXTINCTION OR                                             
!     CASE 2' - CEILHT IS 1.8 KM WHEN                                   
!     'CEILHT' IS 0.0                                                   
!                                                                       
!     =3  RADIATION FOG OR INVERSION OR BOUNDARY LAYER PRESENT          
!     'B' LT 0.0, 'C' GT 0.0                                            
!     VIS LE 2.0 KM DEFAULTS TO A RADIATION FOG AT THE                  
!     GROUND AND OVERRIDES INPUT BOUNDARY AEROSOL TYPE                  
!     VIS GT 2.0 KM FOR AN INVERSION OR BOUNDARY LAYER                  
!     WITH INPUT BOUNDARY AEROSOL TYPE                                  
!     ** IHAZE=9 (RADIATION FOG) ALWAYS DEFAULTS TO A                   
!     RADIATION FOG NO MATTER WHAT THE VISIBILITY IS.                   
!     SWITCH VARIABLE: CEILHT (MUST BE LT 0.0)                          
!     VARIABLE USED:   ZINVHT (MUST BE GE 0.0)                          
!     ** CEILHT MUST BE LT 0.0 FOR ZINVHT TO BE USED **                 
!     HOWEVER, IF DEPTH IS GT 0.0 AND ZINVHT IS EQ 0.0,                 
!     THE PROGRAM WILL SUBSTITUTE DEPTH FOR ZINVHT.                     
!     ** DEFAULT:  FOR A RADIATION FOG ZINVHT IS 0.2 KM                 
!     FOR AN INVERSION LAYER ZINVHT IS 2.0 KM                           
!                                                                       
!     =4  NO CLOUD CEILING, INVERSION LAYER, OR BOUNDARY                
!     LAYER PRESENT, I.E. CLEAR SKIES                                   
!     EXTINCTION PROFILE CONSTANT WITH HEIGHT                           
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
!                                                                       
      DIMENSION Z(10),RH(10),AHAZE(10),IH(10) 
      DIMENSION AA(2),CC(2),EE(4),A(2),B(2),C(2),FAC1(9),FAC2(9) 
!                                                                       
      REAL KMTOM 
!                                                                       
      DATA AA/135.,0.3981/,CC/-0.030,0.0125/,KMTOM/1000.0/,CR/0.35/ 
!                                                                       
!     THE LAST 3 VALUES OF EE BELOW ARE EXTINCTIONS FOR VISIBILITIES    
!     EQUAL TO 5.0, 23.0, AND 50.0 KM, RESPECTIVELY.                    
!                                                                       
      DATA EE/7.064,0.7824,0.17009,0.07824/ 
      DATA FAC1/0.0,0.03,0.05,0.075,0.1,0.18,0.3,0.45,1.0/ 
      DATA FAC2/0.0,0.03,0.1,0.18,0.3,0.45,0.6,0.78,1.0/ 
!                                                                       
      WRITE (IPR,900) 
!                                                                       
!     UPPER LIMIT ON VERTICAL DISTANCE - 2 KM                           
!                                                                       
      ZHIGH = 2000. 
      HMAX = ZHIGH 
      IF (VIS.GT.0.0) GO TO 10 
!                                                                       
!     DEFAULT FOR VISIBILITY DEPENDS ON THE VALUE OF IHAZE.             
!                                                                       
      IF (IHAZE.EQ.8) VIS = 0.2 
      IF (IHAZE.EQ.9) VIS = 0.5 
      IF (IHAZE.EQ.2.OR.IHAZE.EQ.5) VIS = 5.0 
      IF (IHAZE.EQ.1.OR.IHAZE.EQ.4.OR.IHAZE.EQ.7) VIS = 23.0 
      IF (IHAZE.EQ.6) VIS = 50.0 
!                                                                       
!     IF(IHAZE.EQ.3)VIS=??????                                          
!                                                                       
   10 D = 3.912/VIS-0.012 
!                                                                       
      ZC = CEILHT*KMTOM 
      IF (ZC.GT.CR) THEN 
         SZ = ZC-CR 
      ELSE 
         SZ = 0. 
      ENDIF 
      ZT = DEPTH*KMTOM 
      ZINV = ZINVHT*KMTOM 
!                                                                       
!     IHAZE=9 (RADIATION FOG) IS ALWAYS CALCULATED AS A RADIATION FOG.  
!                                                                       
      IF (IHAZE.EQ.9) ZC = -1.0 
!                                                                       
!     ALSO, CHECK TO SEE IF THE FOG DEPTH FOR A RADIATION FOG           
!     WAS INPUT TO DEPTH INSTEAD OF THE CORRECT VARIABLE ZINVHT.        
!                                                                       
      IF (IHAZE.EQ.9.AND.ZT.GT.0.0.AND.ZINV.EQ.0.0) ZINV = ZT 
!                                                                       
!     'IC' DEFINES WHICH CASE TO USE.                                   
!                                                                       
      IC = 2 
      IF (D.GE.EE(1).AND.ZC.GE.0.0) IC = 1 
!                                                                       
      IF (ZC.LT.0.0.AND.IC.EQ.2) IC = 3 
      IF (ZINV.LT.0.0.AND.IC.EQ.3) IC = 4 
!                                                                       
!     'ICC' IS FOR THE TWO CASES:  2 AND 2'.                            
!                                                                       
      ICC = 0 
      IF (IC.EQ.2) ICC = 1 
      IF (D.LE.AA(2).AND.IC.EQ.2) ICC = 2 
      K = 1 
      IF (ICC.EQ.2) GO TO 40 
      GO TO (20,30,50,60), IC 
!                                                                       
!     CASE 1:  DEPTH FOG/CLOUD; INCREASING EXTINCTION WITH HEIGHT FROM  
!     CLOUD/FOG BASE TO CLOUD/FOG TOP.                                  
!                                                                       
   20 CONTINUE 
      IF (ZC.LT.HMAX.AND.IC.EQ.2) K = 2 
!                                                                       
!     IC=-1 WHEN A CLOUD IS PRESENT AND THE PATH GOES INTO IT.          
!     USE CASE 2 OR 2' BELOW CLOUD AND CASE 1 INSIDE IT.                
!                                                                       
      IF (K.EQ.2) IC = (-1) 
!                                                                       
!     THE BASE OF THE CLOUD HAS AN EXTINCTION COEFFICIENT OF 7.064 KM-1.
!                                                                       
      IF (K.EQ.2) D = EE(1) 
      A(K) = AA(1) 
!                                                                       
!     IF THE SURFACE EXTINCTION IS GREATER THAN THE UPPER LIMIT OF 92.1 
!     KM**-1, RUN THE ALGORITHM WITH AN UPPER LIMIT OF 'D+10'.          
!                                                                       
      IF (D.GE.AA(1)) A(K) = D+10.0 
      C(K) = CC(1) 
      IF (ZT.LE.0.0) WRITE (IPR,940) 
      IF (ZT.LE.0.0) WRITE (IPR,945) 
      IF (ZT.GT.0.0) WRITE (IPR,955) ZT 
!                                                                       
!     IF THE DISTANCE FROM THE GROUND TO THE CLOUD/FOG TOP IS LESS      
!     THAN 2.0 KM, VSA WILL ONLY CALCULATE UP TO THE CLOUD TOP.         
!                                                                       
      IF (ZT.LE.0.0) ZT = 200. 
      HMAX =   MIN(ZT+ZC,HMAX) 
      GO TO 60 
!                                                                       
!     CASE 2:  HAZY/LIGHTLY FOGGY; INCREASING EXTINCTION WITH HEIGHT    
!     UP TO THE CLOUD BASE.                                             
!                                                                       
   30 A(K) = AA(2) 
      E = EE(1) 
      IF (ZC.EQ.0.0) WRITE (IPR,905) 
      IF (ZC.EQ.0.0) CEIL =  LOG( LOG(E/A(K))/( LOG(D/A(K))))/CC(2) 
      IF (ZC.EQ.0.0) WRITE (IPR,935) CEIL 
      IF (ZC.GT.0.0) WRITE (IPR,950) ZC 
      IF (ZC.EQ.0.0) ZC = CEIL 
      GO TO 60 
!                                                                       
!     CASE 2':  CLEAR/HAZY; INCREASING EXTINCTION WITH HEIGHT, BUT LESS 
!     SO THAN CASE 2, UP TO THE CLOUD BASE.                             
!                                                                       
   40 A(K) = D*0.9 
      E = EE(1) 
      IF (ZC.EQ.0.0) WRITE (IPR,905) 
      IF (ZC.EQ.0.0) WRITE (IPR,920) 
      IF (ZC.GT.0.0) WRITE (IPR,950) ZC 
      IF (ZC.EQ.0.0) ZC = 1800. 
      GO TO 60 
!                                                                       
!     CASE 3:  NO CLOUD CEILING BUT A RADIATION FOG OR AN INVERSION     
!     OR BOUNDARY LAYER PRESENT; DECREASING EXTINCTION WITH             
!     HEIGHT UP TO THE HEIGHT OF THE FOG OR LAYER.                      
!                                                                       
   50 A(K) = D*1.1 
      E = EE(3) 
      IF (IHAZE.EQ.2.OR.IHAZE.EQ.5) E = EE(2) 
      IF (IHAZE.EQ.6.OR.(VIS.GT.2.0.AND.IHAZE.NE.9)) E = EE(4) 
      IF (E.GT.D) E = D*0.99999 
      IF (ZT.GT.0.0.AND.ZINV.EQ.0.0.AND.VIS.LE.2.0) ZINV = ZT 
      IF (ZINV.EQ.0.0.AND.VIS.GT.2.0.AND.IHAZE.NE.9) WRITE (IPR,910) 
      IF (ZINV.EQ.0.0.AND.(VIS.LE.2.0.OR.IHAZE.EQ.9)) WRITE (IPR,915) 
      IF (ZINV.EQ.0.0.AND.(VIS.LE.2.0.OR.IHAZE.EQ.9)) WRITE (IPR,945) 
      IF (ZINV.GT.0.0.AND.VIS.GT.2.0.AND.IHAZE.NE.9) WRITE (IPR,960)    &
     &    ZINV                                                          
      IF (ZINV.GT.0.0.AND.(VIS.LE.2.0.OR.IHAZE.EQ.9)) WRITE (IPR,965)   &
     &    ZINV                                                          
      IF (ZINV.EQ.0.0.AND.VIS.GT.2.0.AND.IHAZE.NE.9) ZINV = 2000 
      IF (ZINV.EQ.0.0.AND.(VIS.LE.2.0.OR.IHAZE.EQ.9)) ZINV = 200 
      HMAX =   MIN(ZINV,HMAX) 
      ZC = 0.0 
!                                                                       
!     CASE 4:  NO CLOUD CEILING OR INVERSION LAYER;                     
!     CONSTANT EXTINCTION WITH HEIGHT.                                  
!                                                                       
   60 IF (IC.NE.4) B(K) =  LOG(D/A(K)) 
      IF (IC.EQ.4) WRITE (IPR,970) 
      IF (IC.EQ.2) THEN 
         C(K) = LOG( LOG(E/A(K))/B(K))/(ZC-SZ) 
      ENDIF 
      IF (IC.EQ.3) C(K) =  LOG( LOG(E/A(K))/B(K))/ZINV 
      IF (ZC.LT.HMAX.AND.K.EQ.1.AND.IC.EQ.2) GO TO 20 
      IF (IC.EQ.2) HMAX =   MIN(ZC,HMAX) 
      ZALGO = HMAX 
      IF (IC.LT.0) ZALGO = ZC 
      WRITE (IPR,925) 
      IF (IC.LT.0) K = 1 
!                                                                       
      DO 70 I = 1, 9 
         IF (IC.LT.0.AND.I.EQ.5) K = 2 
         IF (IC.LT.0.AND.I.EQ.5) ZALGO = HMAX-ZC 
         Z(I) = ZALGO*(1.0-FAC2(10-I)) 
         IF (IC.EQ.1) Z(I) = ZALGO*FAC1(I) 
         IF (IC.EQ.4) Z(I) = ZALGO* REAL(I-1)/8.0 
         IF (IC.LT.0.AND.I.LT.5) Z(I) = ZALGO*(1.0-FAC2(11-2*I)) 
         IF (IC.LT.0.AND.I.GE.5) Z(I) = ZALGO*FAC1(2*I-9) 
!                                                                       
!        IF(IC.LT.0.AND.(I.EQ.7.OR.I.EQ.8))Z(I)=ZALGO*FAC1(2*I-10)      
!        C    IF(IC.NE.4)AHAZE(I)=A(K)*EXP(B(K)*EXP(C(K)*Z(I)))         
!        C    IF(IC.EQ.4)AHAZE(I)=D                                     
!                                                                       
         IF (IC.NE.4) THEN 
            IF (Z(I).GT.SZ) THEN 
               AHAZE(I) = A(K)*EXP(B(K)*EXP(C(K)*Z(I)-SZ)) 
            ELSE 
               AHAZE(I) = A(K)*EXP(B(K)*EXP(C(K)*Z(I))) 
            ENDIF 
         ELSE 
            AHAZE(I) = D 
         ENDIF 
         IF (IC.LE.0.AND.I.GE.5) Z(I) = Z(I)+ZC 
         Z(I) = Z(I)/KMTOM 
         RH(I) = 6.953* LOG(AHAZE(I))+86.407 
         IF (AHAZE(I).GE.EE(1)) RH(I) = 100.0 
         VISIB = 3.912/(AHAZE(I)+0.012) 
         IH(I) = IHAZE 
!                                                                       
!        IF A RADIATION FOG IS PRESENT (I.E. VIS<=2.0 KM AND IC=3),     
!        IH IS SET TO 9 FOR ALL LEVELS.                                 
!                                                                       
         IF (VISIB.LE.2.0.AND.IC.EQ.3) IH(I) = 9 
!                                                                       
!        FOR A DEPTH FOG/CLOUD CASE, IH=8 DENOTING AN ADVECTION FOG.    
!                                                                       
         IF (IC.EQ.1.OR.(IC.LT.0.AND.I.GE.5)) IH(I) = 8 
         WRITE (IPR,930) Z(I),RH(I),AHAZE(I),VISIB,IH(I) 
   70 END DO 
      HMAX = HMAX/KMTOM 
      RETURN 
!                                                                       
  900 FORMAT('0 VERTICAL STRUCTURE ALGORITHM (VSA) USED') 
  905 FORMAT(' ',50X,'CLOUD CEILING HEIGHT UNKNOWN') 
  910 FORMAT(' ',50X,'INVERSION OR BOUNDARY LAYER HEIGHT UNKNOWN',/,    &
     &  ' ',50X,'VSA WILL USE A DEFAULT OF 2000.0 METERS',/)            
  915 FORMAT(' ',50X,'RADIATION FOG DEPTH UNKNOWN') 
  920 FORMAT(' ',50X,'VSA WILL USE A DEFAULT OF 1800.0 METERS',/) 
  925 FORMAT(5X,'HEIGHT(KM)',5X,'R.H.(%)',5X,'EXTINCTION(KM-1)',        &
     &   5X,'VIS(3.912/EXTN)',5X,'IHAZE',/)                             
  930 FORMAT(7X,F7.4,7X,F5.1,8X,E12.4,11X,F7.4,10X,I2) 
  935 FORMAT(' ',39X,'VSA WILL USE A CALCULATED VALUE OF ',F7.1,        &
     &       ' METERS',/)                                               
  940 FORMAT(' ',50X,'CLOUD DEPTH UNKNOWN') 
  945 FORMAT(' ',50X,'VSA WILL USE A DEFAULT OF 200.0 METERS',/) 
  950 FORMAT(' ',50X,'CLOUD CEILING HEIGHT IS ',F9.1,' METERS',/) 
  955 FORMAT(' ',50X,'CLOUD DEPTH IS ,F14.1,7H METERS',/) 
  960 FORMAT(' ',50X,'INVERSION OR BOUNDARY LAYER HEIGHT IS ',F7.1,     &
     & ' METERS',/)                                                     
  965 FORMAT(' ',50X,'DEPTH OF RADIATION FOG IS ',F7.1,' METERS',/) 
  970 FORMAT(' ',50X,'THERE IS NO INVERSION OR BOUNDARY LAYER OR ',     &
     & 'CLOUD PRESENT',/)                                               
!                                                                       
      END                                           
!                                                                       
!     ***************************************************************** 
!                                                                       
      SUBROUTINE EXABIN 
!                                                                       
!     LOADS EXTINCTION, ABSORPTION AND ASYMMETRY COEFFICIENTS           
!     FOR THE FOUR AEROSOL ALTITUDE REGIONS                             
!                                                                       
!     MODIFIED FOR ASYMMETRY - JAN 1986 (A.E.R. INC.)                   
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX0(47),AWCCON(5) 
!                                                                       
      CHARACTER*8      HMOD 
!                                                                       
      COMMON /CMN/ HMOD(3),ZM(MXZMD),PF(MXZMD),TF(MXZMD),RFNDXM(MXZMD), &
     &          ZP(IM2),PP(IM2),TP(IM2),RFNDXP(IM2),SP(IM2),PPSUM(IM2), &
     &          TPSUM(IM2),RHOPSM(IM2),IMLOW,WGM(MXZMD),DENW(MXZMD),    &
     &          AMTP(MXMOL,MXPDIM)                                      
!                                                                       
      COMMON /LCRD1/ MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRNT,TBOUND,SALB 
      COMMON /LCRD2/ IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,   &
     &     RAINRT                                                       
      COMMON /LCRD2D/ IREG(4),ALTB(4),IREGC(4) 
      COMMON /LCRD3/ H1,H2,ANGLE,RANGE,BETA,RE,LEN 
      COMMON /LCRD4/ V1,V2,DV 
!                                                                       
      COMMON /EXTD  /  VX2(47),RUREXT(47,4),RURABS(47,4),RURSYM(47,4),  &
     &     URBEXT(47,4),URBABS(47,4),URBSYM(47,4),OCNEXT(47,4),         &
     &     OCNABS(47,4),OCNSYM(47,4),TROEXT(47,4),TROABS(47,4),         &
     &     TROSYM(47,4),FG1EXT(47),FG1ABS(47),FG1SYM(47),               &
     &     FG2EXT(47),FG2ABS(47),FG2SYM(47),BSTEXT(47),BSTABS(47),      &
     &     BSTSYM(47),AVOEXT(47),AVOABS(47),AVOSYM(47),FVOEXT(47),      &
     &     FVOABS(47),FVOSYM(47),DMEEXT(47),DMEABS(47),DMESYM(47),      &
     &     CCUEXT(47),CCUABS(47),CCUSYM(47),CALEXT(47),CALABS(47),      &
     &     CALSYM(47),CSTEXT(47),CSTABS(47),CSTSYM(47),CSCEXT(47),      &
     &     CSCABS(47),CSCSYM(47),CNIEXT(47),CNIABS(47),CNISYM(47)       
      COMMON/CIRR/ CI64XT(47),CI64AB(47),CI64G(47),                     &
     &     CIR4XT(47),CIR4AB(47),CIR4G(47)                              
!                                                                       
      DIMENSION RHZONE(4) 
      DIMENSION ELWCR(4),ELWCU(4),ELWCM(4),ELWCT(4) 
!                                                                       
      DATA RHZONE/0.,70.,80.,99./ 
      DATA ELWCR/3.517E-04,3.740E-04,4.439E-04,9.529E-04/ 
      DATA ELWCM/4.675E-04,6.543E-04,1.166E-03,3.154E-03/ 
      DATA ELWCU/3.102E-04,3.802E-04,4.463E-04,9.745E-04/ 
      DATA ELWCT/1.735E-04,1.820E-04,2.020E-04,2.408E-04/ 
      DATA AFLWC/1.295E-02/,RFLWC/1.804E-03/,CULWC/7.683E-03/ 
      DATA ASLWC/4.509E-03/,STLWC/5.272E-03/,SCLWC/4.177E-03/ 
      DATA SNLWC/7.518E-03/,BSLWC/1.567E-04/,FVLWC/5.922E-04/ 
      DATA AVLWC/1.675E-04/,MDLWC/4.775E-04/ 
!                                                                       
      DO 10 I = 1, 47 
         VX0(I) = VX2(I) 
   10 END DO 
      I1 = 1 
      NB = 1 
      NE = 46 
!                                                                       
!     C    IF (IHAZE.EQ.7) I1=2                                         
!     C    IF(IHAZE.EQ.3) I1 = 2                                        
!     C    DO 185 M=I1,4                                                
!                                                                       
      DO 260 M = 1, 4 
!                                                                       
!        C    IF(ICLD.EQ.11.AND.M.EQ.2) GO TO 185                       
!                                                                       
         IF (IREG(M).NE.0) GO TO 260 
         ITA = ICH(M) 
         ITC = ICH(M)-7 
         ITAS = ITA 
   47    IF (IREGC(M).NE.0) GO TO 190 
         WRH = W(15) 
         IF (ICH(M).EQ.6.AND.M.NE.1) WRH = 70. 
!                                                                       
!        THIS CODING  DOES NOT ALLOW TROP RH DEPENDENT  ABOVE EH(7,I)   
!        DEFAULTS TO TROPOSPHERIC AT 70. PERCENT                        
!                                                                       
         DO 20 I = 2, 4 
            IF (WRH.LT.RHZONE(I)) GO TO 30 
   20    CONTINUE 
         I = 4 
   30    II = I-1 
         IF (WRH.GT.0.0.AND.WRH.LT.99.) X = LOG(100.0-WRH) 
         X1 = LOG(100.0-RHZONE(II)) 
         X2 = LOG(100.0-RHZONE(I)) 
         IF (WRH.GE.99.0) X = X2 
         IF (WRH.LE.0.0) X = X1 
         DO 180 N = NB, NE 
            ITA = ITAS 
            IF (ITA.EQ.3.AND.M.EQ.1) GO TO 40 
            ABSC(M,N) = 0. 
            EXTC(M,N) = 0. 
            ASYM(M,N) = 0.0 
            IF (ITA.GT.6) GO TO 110 
            IF (ITA.LE.0) GO TO 180 
   40       IF (N.GE.41.AND.ITA.EQ.3) ITA = 4 
!                                                                       
!           RH DEPENDENT AEROSOLS                                       
!                                                                       
            GO TO (50,50,60,70,80,90), ITA 
   50       Y2 = LOG(RUREXT(N,I)) 
            Y1 = LOG(RUREXT(N,II)) 
            Z2 = LOG(RURABS(N,I)) 
            Z1 = LOG(RURABS(N,II)) 
            A2 = LOG(RURSYM(N,I)) 
            A1 = LOG(RURSYM(N,II)) 
            E2 = LOG(ELWCR(I)) 
            E1 = LOG(ELWCR(II)) 
            GO TO 100 
   60       IF (M.GT.1) GO TO 70 
            A2 = LOG(OCNSYM(N,I)) 
            A1 = LOG(OCNSYM(N,II)) 
            A = A1+(A2-A1)*(X-X1)/(X2-X1) 
            ASYM(M,N) = EXP(A) 
            E2 = LOG(ELWCM(I)) 
            E1 = LOG(ELWCM(II)) 
!                                                                       
!           NAVY MARITIME AEROSOL CHANGES TO MARINE IN MICROWAVE        
!           NO NEED TO DEFINE EQUIVALENT WATER                          
!                                                                       
            GO TO 180 
   70       Y2 = LOG(OCNEXT(N,I)) 
            Y1 = LOG(OCNEXT(N,II)) 
            Z2 = LOG(OCNABS(N,I)) 
            Z1 = LOG(OCNABS(N,II)) 
            A2 = LOG(OCNSYM(N,I)) 
            A1 = LOG(OCNSYM(N,II)) 
            E2 = LOG(ELWCM(I)) 
            E1 = LOG(ELWCM(II)) 
            GO TO 100 
   80       Y2 = LOG(URBEXT(N,I)) 
            Y1 = LOG(URBEXT(N,II)) 
            Z2 = LOG(URBABS(N,I)) 
            Z1 = LOG(URBABS(N,II)) 
            A2 = LOG(URBSYM(N,I)) 
            A1 = LOG(URBSYM(N,II)) 
            E2 = LOG(ELWCU(I)) 
            E1 = LOG(ELWCU(II)) 
            GO TO 100 
   90       Y2 = LOG(TROEXT(N,I)) 
            Y1 = LOG(TROEXT(N,II)) 
            Z2 = LOG(TROABS(N,I)) 
            Z1 = LOG(TROABS(N,II)) 
            A2 = LOG(TROSYM(N,I)) 
            A1 = LOG(TROSYM(N,II)) 
            E2 = LOG(ELWCT(I)) 
            E1 = LOG(ELWCT(II)) 
  100       Y = Y1+(Y2-Y1)*(X-X1)/(X2-X1) 
            ZK = Z1+(Z2-Z1)*(X-X1)/(X2-X1) 
            A = A1+(A2-A1)*(X-X1)/(X2-X1) 
            ABSC(M,N) = EXP(ZK) 
            EXTC(M,N) = EXP(Y) 
            ASYM(M,N) = EXP(A) 
            IF (N.EQ.1) EC = E1+(E2-E1)*(X-X1)/(X2-X1) 
            IF (N.EQ.1) AWCCON(M) = EXP(EC) 
            GO TO 180 
  110       IF (ITA.GT.19) GO TO 170 
            IF (ITC.LT.1) GO TO 180 
            GO TO (120,130,180,140,150,160,150,160,140,140,160,170),    &
            ITC                                                         
  120       ABSC(M,N) = FG1ABS(N) 
            EXTC(M,N) = FG1EXT(N) 
            ASYM(M,N) = FG1SYM(N) 
            IF (N.EQ.1) AWCCON(M) = AFLWC 
            GO TO 180 
  130       ABSC(M,N) = FG2ABS(N) 
            EXTC(M,N) = FG2EXT(N) 
            ASYM(M,N) = FG2SYM(N) 
            IF (N.EQ.1) AWCCON(M) = RFLWC 
            GO TO 180 
  140       ABSC(M,N) = BSTABS(N) 
            EXTC(M,N) = BSTEXT(N) 
            ASYM(M,N) = BSTSYM(N) 
            IF (N.EQ.1) AWCCON(M) = BSLWC 
            GO TO 180 
  150       ABSC(M,N) = AVOABS(N) 
            EXTC(M,N) = AVOEXT(N) 
            ASYM(M,N) = AVOSYM(N) 
            IF (N.EQ.1) AWCCON(M) = AVLWC 
            GO TO 180 
  160       ABSC(M,N) = FVOABS(N) 
            EXTC(M,N) = FVOEXT(N) 
            ASYM(M,N) = FVOSYM(N) 
            ASYM(M,N) = DMESYM(N) 
            IF (N.EQ.1) AWCCON(M) = FVLWC 
            GO TO 180 
  170       ABSC(M,N) = DMEABS(N) 
            EXTC(M,N) = DMEEXT(N) 
            IF (N.EQ.1) AWCCON(M) = MDLWC 
  180    CONTINUE 
         GO TO 260 
  190    CONTINUE 
!                                                                       
!        CC                                                             
!        CC       SECTION TO LOAD EXTINCTION, ABSORPTION AND ASYMMETRY  
!        CC       COEFFICIENTS FOR CLOUD AND OR RAIN MODELS             
!        CC                                                             
!                                                                       
         DO 250 N = NB, NE 
            ABSC(M,N) = 0.0 
            EXTC(M,N) = 0.0 
            ASYM(M,N) = 0.0 
            IC = ICLD 
            GO TO (200,210,220,230,240,220,240,240,200,200,200), IC 
  200       ABSC(M,N) = CCUABS(N) 
            EXTC(M,N) = CCUEXT(N) 
            ASYM(M,N) = CCUSYM(N) 
            IF (N.EQ.1) AWCCON(M) = CULWC 
            GO TO 250 
  210       ABSC(M,N) = CALABS(N) 
            EXTC(M,N) = CALEXT(N) 
            ASYM(M,N) = CALSYM(N) 
            IF (N.EQ.1) AWCCON(M) = ASLWC 
            GO TO 250 
  220       ABSC(M,N) = CSTABS(N) 
            EXTC(M,N) = CSTEXT(N) 
            ASYM(M,N) = CSTSYM(N) 
            IF (N.EQ.1) AWCCON(M) = STLWC 
            GO TO 250 
  230       ABSC(M,N) = CSCABS(N) 
            EXTC(M,N) = CSCEXT(N) 
            ASYM(M,N) = CSCSYM(N) 
            IF (N.EQ.1) AWCCON(M) = SCLWC 
            GO TO 250 
  240       ABSC(M,N) = CNIABS(N) 
            EXTC(M,N) = CNIEXT(N) 
            ASYM(M,N) = CNISYM(N) 
            IF (N.EQ.1) AWCCON(M) = SNLWC 
  250    CONTINUE 
  260 END DO 
      DO 270 N = 1, 47 
         ABSC(5,N) = 0. 
         EXTC(5,N) = 0. 
         ASYM(5,N) = 0. 
         AWCCON(5) = 0. 
         IF (ICLD.EQ.18) THEN 
            ABSC(5,N) = CI64AB(N) 
            EXTC(5,N) = CI64XT(N) 
            ASYM(5,N) = CI64G(N) 
            AWCCON(5) = ASLWC 
         ENDIF 
         IF (ICLD.EQ.19) THEN 
            ABSC(5,N) = CIR4AB(N) 
            EXTC(5,N) = CIR4XT(N) 
            ASYM(5,N) = CIR4G(N) 
            AWCCON(5) = ASLWC 
         ENDIF 
  270 END DO 
      RETURN 
!                                                                       
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE AEREXT (V,IK,RADFT) 
!                                                                       
!     INTERPOLATES AEROSOL EXTINCTION, ABSORPTION, AND ASYMMETRY        
!     COEFFICIENTS FOR THE WAVENUMBER, V, WITHOUT THE RADIATION FIELD.  
!                                                                       
!     MODIFIED FOR ASYMMETRY  - JAN 1986 (A.E.R. INC.)                  
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYC(5,47),VX2(47),AWCCON(5) 
!                                                                       
      CHARACTER*8      HMOD 
!                                                                       
      COMMON /CMN/ HMOD(3),ZM(MXZMD),PF(MXZMD),TF(MXZMD),RFNDXM(MXZMD), &
     &          ZP(IM2),PP(IM2),TP(IM2),RFNDXP(IM2),SP(IM2),PPSUM(IM2), &
     &          TPSUM(IM2),RHOPSM(IM2),IMLOW,WGM(MXZMD),DENW(MXZMD),    &
     &          AMTP(MXMOL,MXPDIM)                                      
!                                                                       
      COMMON /LCRD1/ MODEL,ITYPE,IEMSCT,M1,M2,M3,IM,NOPRNT,TBOUND,SALB 
      COMMON /LCRD2/ IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,   &
     &     RAINRT                                                       
      COMMON /LCRD3/ H1,H2,ANGLE,RANGE,BETA,RE,LEN 
      COMMON /LCRD4/ V1,V2,DV 
      COMMON /CNTRL/ KMAX,M,IKMAX,NL,ML,IKLO,ISSGEO,IDUM1,IDUM2 
      COMMON /MODEL/ ZMDL(MXZMD),PM(MXZMD),TM(MXZMD),                   &
     &     RFNDX(MXZMD),DENSTY(16,MXZMD),                               &
     &     CLDAMT(MXZMD),RRAMT(MXZMD),EQLWC(MXZMD),HAZEC(MXZMD)         
      COMMON /AER/ EXTV(5),ABSV(5),ASYV(5) 
!                                                                       
!     CC                                                                
!     CC    REDEFINE EXTC(47) AND ABSC(47) IF ALAM GT 200 MICRONS       
!     CC                                                                
!                                                                       
      IF (V.LE.1.0E-5) GO TO 80 
      IF (RADFT.LE.0.) GO TO 80 
      IF (V.LE.33.333) GO TO 60 
!                                                                       
!     CC                                                                
!     CC   COMPUTE INFRARED ATTENUATION COEFFICIENT                     
!     CC                                                                
!                                                                       
      IF (V.LE.50.0) THEN 
         DO 10 MR = 1, 5 
            EXTC(MR,47) = GAMFOG(33.333,TBBY(IK),AWCCON(MR)) 
            ABSC(MR,47) = EXTC(MR,47) 
            ASYC(MR,47) = 0.0 
   10    CONTINUE 
      ENDIF 
      DO 20 I = 1, 4 
         EXTV(I) = 0. 
         ABSV(I) = 0. 
         ASYV(I) = 0. 
   20 END DO 
!                                                                       
!     C    IF (IHAZE.EQ.0) RETURN                                       
!                                                                       
      ALAM = 1.0E+4/V 
      DO 30 N = 2, 47 
         XD = ALAM-VX2(N) 
         IF (XD.lt.0.) go to 40 
   30 END DO 
      N = 47 
   40 VXD = VX2(N)-VX2(N-1) 
      DO 50 I = 1, 5 
         ASYV(I) = (ASYC(I,N)-ASYC(I,N-1))*XD/VXD+ASYC(I,N) 
         EXTV(I) = (EXTC(I,N)-EXTC(I,N-1))*XD/VXD+EXTC(I,N) 
         ABSV(I) = (ABSC(I,N)-ABSC(I,N-1))*XD/VXD+ABSC(I,N) 
         EXTV(I) = EXTV(I)/RADFT 
         ABSV(I) = ABSV(I)/RADFT 
   50 END DO 
      RETURN 
!                                                                       
!     CC                                                                
!                                                                       
   60 CONTINUE 
!                                                                       
!     CC    COMPUTE MICROWAVE ATTENUATION COEFFICIENTS                  
!     CC                                                                
!                                                                       
      DO 70 I = 1, 5 
         EXTV(I) = GAMFOG(V,TBBY(IK),AWCCON(I)) 
         ABSV(I) = EXTV(I) 
         ASYV(I) = 0.0 
         EXTV(I) = EXTV(I)/RADFT 
         ABSV(I) = ABSV(I)/RADFT 
   70 END DO 
      RETURN 
!                                                                       
!     CC                                                                
!                                                                       
   80 CONTINUE 
!                                                                       
!     CC    CALL FUNCTION TO OBTAIN LIMITING VALUE AS FREQ APPROACHES   
!     CC    ZERO USING RAY S MODIFIED DEBYE EQUATIONS                   
!     CC                                                                
!     CC   EQL=EQLWC(IL)                                                
!                                                                       
      DO 90 I = 1, 5 
         EXTV(I) = ABSLIM(TBBY(IK),AWCCON(I)) 
         ABSV(I) = EXTV(I) 
         ASYV(I) = 0.0 
!                                                                       
!        WRITE (IPR,300) I,AWCCON(I)                                    
!                                                                       
   90 END DO 
      RETURN 
!                                                                       
!                                                                       
      END                                           
      FUNCTION ABSLIM(TK,AWLWC) 
!                                                                       
!     CC                                                                
!     CC    FOR CLOUD OR AEROSOL ATTENUATION AS FREQ APPROACHES ZERO    
!     CC    MODIFIED DEBYE EQUATIONS FROM RAY (1972) APPL. OPTICS VOL 11
!     CC                                                                
!     CC    ANO= 8.0*10**(-2)  (CM-4)                                   
!     CC    ALM= 41.*RR**(-0.21)  (CM-1)  RR IN (MM/HR)                 
!     CC                                                                
!                                                                       
      DATA PI/3.14159265/ 
!                                                                       
!     CC   ANO=0.08                                                     
!     CC   ALM=41./RR**0.21                                             
!                                                                       
      TC = TK-273.15 
!                                                                       
!     CC                                                                
!                                                                       
      EFIN = 5.27137+.0216474*TC-.00131198*TC*TC 
      ES = 78.54*(1.-4.579E-03*(TC-25.)+1.19E-05*(TC-25.)**2-2.8E-08*(TC&
     &   -25.)**3)                                                      
      SLAMBD = 3.3836E-04*EXP(2513.98/TK) 
!                                                                       
!     CC                                                                
!     CC   VOL=PI*ANO*ALM**(-4)                                         
!                                                                       
      ESMIE2 = (ES-EFIN)/(ES+2.0)**2 
!                                                                       
!     CC                                                                
!     CC    DIVIDE VOLUME EQUIVALENT LIQUID BY 10 FOR UNITS CONVERSION  
!     CC                                                                
!                                                                       
      EQLWC = AWLWC/10.0 
!                                                                       
!     CC                                                                
!                                                                       
      ABSLIM = 0.6951*TK*36.0*PI*EQLWC*SLAMBD*ESMIE2 
!                                                                       
!     CC                                                                
!                                                                       
      RETURN 
      END                                           
      BLOCK DATA TITLE 
!                                                                       
!     >    BLOCK DATA                                                   
!     TITLE INFORMATION                                                 
!                                                                       
      CHARACTER*20 HHAZE,HSEASN,HVULCN,HMET,HMODEL,BLANK 
      CHARACTER*24 HTRRAD 
      COMMON /TITL/ HHAZE(16),HSEASN(2),HVULCN(8),BLANK,                &
     & HMET(2),HMODEL(8),HTRRAD(4)                                      
      COMMON /VSBD/ VSB(10) 
      DATA VSB /23.,5.,0.,23.,5.,50.,23.,0.2,0.5,0./ 
      DATA BLANK/'                    '/ 
      DATA HHAZE /                                                      &
     & 'RURAL               ',                                          &
     & 'RURAL               ',                                          &
     & 'NAVY MARITIME       ',                                          &
     & 'MARITIME            ',                                          &
     & 'URBAN               ',                                          &
     & 'TROPOSPHERIC        ',                                          &
     & 'USER DEFINED        ',                                          &
     & 'FOG1 (ADVECTTION)   ',                                          &
     & 'FOG2 (RADIATION)    ',                                          &
     & 'DESERT AEROSOL      ',                                          &
     & 'BACKGROUND STRATO   ',                                          &
     & 'AGED VOLCANIC       ',                                          &
     & 'FRESH VOLCANIC      ',                                          &
     & 'AGED VOLCANIC       ',                                          &
     & 'FRESH VOCANIC       ',                                          &
     & 'METEORIC DUST       '/                                          
      DATA HSEASN /                                                     &
     & 'SPRING-SUMMER       ',                                          &
     & 'FALL-WINTER         '/                                          
      DATA HVULCN /                                                     &
     & 'BACKGROUND STRATO   ',                                          &
     & 'MODERATE VOLCANIC   ',                                          &
     & 'HIGH VOLCANIC       ',                                          &
     & 'HIGH VOLCANIC       ',                                          &
     & 'MODERATE VOLCANIC   ',                                          &
     & 'MODERATE VOLCANIC   ',                                          &
     & 'HIGH VOLCANIC       ',                                          &
     & 'EXTREME VOLCANIC    '/                                          
      DATA HMET/                                                        &
     & 'NORMAL              ',                                          &
     & 'TRANSITION          '/                                          
      DATA HMODEL /                                                     &
     & 'TROPICAL MODEL      ',                                          &
     & 'MIDLATITUDE SUMMER  ',                                          &
     & 'MIDLATITUDE WINTER  ',                                          &
     & 'SUBARCTIC   SUMMER  ',                                          &
     & 'SUBARCTIC   WINTER  ',                                          &
     & '1976 U S STANDARD   ',                                          &
     & '                    ',                                          &
     & 'MODEL=0 HORIZONTAL  '/                                          
      DATA HTRRAD/                                                      &
     & 'TRANSMITTANCE           ',                                      &
     & 'RADIANCE                ',                                      &
     & 'RADIANCE+SOLAR SCATTERNG',                                      &
     & 'TRANSMITTED SOLAR IRRAD.'/                                      
      END                                           
      BLOCK DATA PRFDTA 
!                                                                       
!     >    BLOCK DATA                                                   
!                                                                       
!     AEROSOL PROFILE DATA                                              
!                                                                       
!     CC         0-2KM                                                  
!     CC           HZ2K=5 VIS PROFILES- 50KM,23KM,10KM,5KM,2KM          
!     CC         >2-10KM                                                
!     CC           FAWI50=FALL/WINTER   50KM VIS                        
!     CC           FAWI23=FALL/WINTER    23KM VIS                       
!     CC           SPSU50=SPRING/SUMMER  50KM VIS                       
!     CC           SPSU23=SPRING/SUMMER  23KM VIS                       
!     CC         >10-30KM                                               
!     CC           BASTFW=BACKGROUND STRATOSPHERIC   FALL/WINTER        
!     CC           VUMOFW=MODERATE VOLCANIC          FALL/WINTER        
!     CC           HIVUFW=HIGH VOLCANIC              FALL/WINTER        
!     CC           EXVUFW=EXTREME VOLCANIC           FALL/WINTER        
!     CC           BASTSS,VUMOSS,HIVUSS,EXVUSS=      SPRING/SUMMER      
!     CC         >30-100KM                                              
!     CC           UPNATM=NORMAL UPPER ATMOSPHERIC                      
!     CC           VUTONO=TRANSITION FROM VOLCANIC TO NORMAL            
!     CC           VUTOEX=TRANSITION FROM VOLCANIC TO EXTREME           
!     CC           EXUPAT=EXTREME UPPER ATMOSPHERIC                     
!                                                                       
      COMMON/PRFD  /ZHT(34),HZ2K(34,5),FAWI50(34),FAWI23(34),SPSU50(34),&
     &SPSU23(34),BASTFW(34),VUMOFW(34),HIVUFW(34),EXVUFW(34),BASTSS(34),&
     &VUMOSS(34),HIVUSS(34),EXVUSS(34),UPNATM(34),VUTONO(34),           &
     &VUTOEX(34),EXUPAT(34)                                             
      DATA ZHT/                                                         &
     &    0.,    1.,    2.,    3.,    4.,    5.,    6.,    7.,    8.,   &
     &    9.,   10.,   11.,   12.,   13.,   14.,   15.,   16.,   17.,   &
     &   18.,   19.,   20.,   21.,   22.,   23.,   24.,   25.,   30.,   &
     &   35.,   40.,   45.,   50.,   70.,  100.,99999./                 
       DATA HZ2K(1,1),HZ2K(1,2),HZ2K(1,3),HZ2K(1,4),HZ2K(1,5)/          &
     & 6.62E-02, 1.58E-01, 3.79E-01, 7.70E-01, 1.94E+00/                
       DATA HZ2K(2,1),HZ2K(2,2),HZ2K(2,3),HZ2K(2,4),HZ2K(2,5)/          &
     & 4.15E-02, 9.91E-02, 3.79E-01, 7.70E-01, 1.94E+00/                
       DATA HZ2K(3,1),HZ2K(3,2),HZ2K(3,3),HZ2K(3,4),HZ2K(3,5)/          &
     & 2.60E-02, 6.21E-02, 6.21E-02, 6.21E-02, 6.21E-02/                
      DATA FAWI50  /3*0.,                                               &
     & 1.14E-02, 6.43E-03, 4.85E-03, 3.54E-03, 2.31E-03, 1.41E-03,      &
     & 9.80E-04,7.87E-04,23*0./                                         
      DATA FAWI23              /3*0.,                                   &
     & 2.72E-02, 1.20E-02, 4.85E-03, 3.54E-03, 2.31E-03, 1.41E-03,      &
     & 9.80E-04,7.87E-04, 23*0./                                        
      DATA  SPSU50              / 3*0.,                                 &
     & 1.46E-02, 1.02E-02, 9.31E-03, 7.71E-03, 6.23E-03, 3.37E-03,      &
     & 1.82E-03  ,1.14E-03,23*0./                                       
      DATA  SPSU23              / 3*0.,                                 &
     & 3.46E-02, 1.85E-02, 9.31E-03, 7.71E-03, 6.23E-03, 3.37E-03,      &
     & 1.82E-03  ,1.14E-03,23*0./                                       
      DATA BASTFW       /11*0.,                                         &
     &           7.14E-04, 6.64E-04, 6.23E-04, 6.45E-04, 6.43E-04,      &
     & 6.41E-04, 6.00E-04, 5.62E-04, 4.91E-04, 4.23E-04, 3.52E-04,      &
     & 2.95E-04, 2.42E-04, 1.90E-04, 1.50E-04, 3.32E-05 ,7*0./          
      DATA    VUMOFW       /11*0.,                                      &
     &           1.79E-03, 2.21E-03, 2.75E-03, 2.89E-03, 2.92E-03,      &
     & 2.73E-03, 2.46E-03, 2.10E-03, 1.71E-03, 1.35E-03, 1.09E-03,      &
     & 8.60E-04, 6.60E-04, 5.15E-04, 4.09E-04, 7.60E-05 ,7*0./          
      DATA    HIVUFW       /11*0.,                                      &
     &           2.31E-03, 3.25E-03, 4.52E-03, 6.40E-03, 7.81E-03,      &
     & 9.42E-03, 1.07E-02, 1.10E-02, 8.60E-03, 5.10E-03, 2.70E-03,      &
     & 1.46E-03, 8.90E-04, 5.80E-04, 4.09E-04, 7.60E-05 ,7*0./          
      DATA    EXVUFW       /11*0.,                                      &
     &           2.31E-03, 3.25E-03, 4.52E-03, 6.40E-03, 1.01E-02,      &
     & 2.35E-02, 6.10E-02, 1.00E-01, 4.00E-02, 9.15E-03, 3.13E-03,      &
     & 1.46E-03, 8.90E-04, 5.80E-04, 4.09E-04, 7.60E-05 ,7*0./          
      DATA    BASTSS       /11*0.,                                      &
     &           7.99E-04, 6.41E-04, 5.17E-04, 4.42E-04, 3.95E-04,      &
     & 3.82E-04, 4.25E-04, 5.20E-04, 5.81E-04, 5.89E-04, 5.02E-04,      &
     & 4.20E-04, 3.00E-04, 1.98E-04, 1.31E-04, 3.32E-05 ,7*0./          
      DATA    VUMOSS       /11*0.,                                      &
     &           2.12E-03, 2.45E-03, 2.80E-03, 2.89E-03, 2.92E-03,      &
     & 2.73E-03, 2.46E-03, 2.10E-03, 1.71E-03, 1.35E-03, 1.09E-03,      &
     & 8.60E-04, 6.60E-04, 5.15E-04, 4.09E-04, 7.60E-05 ,7*0./          
      DATA    HIVUSS       /11*0.,                                      &
     &           2.12E-03, 2.45E-03, 2.80E-03, 3.60E-03, 5.23E-03,      &
     & 8.11E-03, 1.20E-02, 1.52E-02, 1.53E-02, 1.17E-02, 7.09E-03,      &
     & 4.50E-03, 2.40E-03, 1.28E-03, 7.76E-04, 7.60E-05 ,7*0./          
      DATA    EXVUSS       /11*0.,                                      &
     &           2.12E-03, 2.45E-03, 2.80E-03, 3.60E-03, 5.23E-03,      &
     & 8.11E-03, 1.27E-02, 2.32E-02, 4.85E-02, 1.00E-01, 5.50E-02,      &
     & 6.10E-03, 2.40E-03, 1.28E-03, 7.76E-04, 7.60E-05 ,7*0./          
      DATA UPNATM       /26*0.,                                         &
     & 3.32E-05, 1.64E-05, 7.99E-06, 4.01E-06, 2.10E-06, 1.60E-07,      &
     & 9.31E-10, 0.      /                                              
      DATA VUTONO       /26*0.,                                         &
     & 7.60E-05, 2.45E-05, 7.99E-06, 4.01E-06, 2.10E-06, 1.60E-07,      &
     & 9.31E-10, 0.      /                                              
      DATA VUTOEX       /26*0.,                                         &
     & 7.60E-05, 7.20E-05, 6.95E-05, 6.60E-05, 5.04E-05, 1.03E-05,      &
     & 4.50E-07, 0.      /                                              
      DATA EXUPAT       /26*0.,                                         &
     & 3.32E-05, 4.25E-05, 5.59E-05, 6.60E-05, 5.04E-05, 1.03E-05,      &
     & 4.50E-07, 0.      /                                              
      END                                           
      BLOCK DATA EXTDTA 
!                                                                       
!     >    BLOCK DATA                                                   
!     CC                                                                
!     CC   ALTITUDE REGIONS FOR AEROSOL EXTINCTION COEFFICIENTS         
!     CC                                                                
!     CC                                                                
!     CC         0-2KM                                                  
!     CC           RUREXT=RURAL EXTINCTION   RURABS=RURAL ABSORPTION    
!     CC           RURSYM=RURAL ASYMMETRY FACTORS                       
!     CC           URBEXT=URBAN EXTINCTION   URBABS=URBAN ABSORPTION    
!     CC           URBSYM=URBAN ASYMMETRY FACTORS                       
!     CC           OCNEXT=MARITIME EXTINCTION  OCNABS=MARITIME ABSORPTIO
!     CC           OCNSYM=MARITIME ASYMMETRY FACTORS                    
!     CC           TROEXT=TROPSPHER EXTINCTION  TROABS=TROPOSPHER ABSORP
!     CC           TROSYM=TROPSPHERIC ASYMMETRY FACTORS                 
!     CC           FG1EXT=FOG1 .2KM VIS EXTINCTION  FG1ABS=FOG1 ABSORPTI
!     CC           FG1SYM=FOG1 ASYMMETRY FACTORS                        
!     CC           FG2EXT=FOG2 .5KM VIS EXTINCTION  FG2ABS=FOG2 ABSORPTI
!     CC           FG2SYM=FOG2 ASYMMETRY FACTORS                        
!     CC         >2-10KM                                                
!     CC           TROEXT=TROPOSPHER EXTINCTION  TROABS=TROPOSPHER ABSOR
!     CC           TROSYM=TROPOSPHERIC ASYMMETRY FACTORS                
!     CC         >10-30KM                                               
!     CC           BSTEXT=BACKGROUND STRATOSPHERIC EXTINCTION           
!     CC           BSTABS=BACKGROUND STRATOSPHERIC ABSORPTION           
!     CC           BSTSYM=BACKGROUND STRATOSPHERIC ASYMMETRY FACTORS    
!     CC           AVOEXT=AGED VOLCANIC EXTINCTION                      
!     CC           AVOABS=AGED VOLCANIC ABSORPTION                      
!     CC           AVOSYM=AGED VOLCANIC ASYMMETRY FACTORS               
!     CC           FVOEXT=FRESH VOLCANIC EXTINCTION                     
!     CC           FVOABS=FRESH VOLCANIC ABSORPTION                     
!     CC           FVOSYM=FRESH VOLCANIC ASYMMETRY FACTORS              
!     CC         >30-100KM                                              
!     CC           DMEEXT=METEORIC DUST EXTINCTION                      
!     CC           DMEABS=METEORIC DUST ABSORPTION                      
!     CC           DMESYM=METEORIC DUST ASYMMETRY FACTORS               
!                                                                       
!     AEROSOL EXTINCTION AND ABSORPTION DATA                            
!                                                                       
!     MODIFIED TO INCLUDE ASYMMETRY DATA - JAN 1986 (A.E.R. INC.)       
!                                                                       
!     COMMON /EXTD  /VX2(40),RUREXT(40,4),RURABS(40,4),URBEXT(40,4),    
!     1URBABS(40,4),OCNEXT(40,4),OCNABS(40,4),TROEXT(40,4),TROABS(40,4),
!     2FG1EXT(40),FG1ABS(40),FG2EXT(40),FG2ABS(40),                     
!     3   BSTEXT(40),BSTABS(40),AVOEXT(40),AVOABS(40),FVOEXT(40)        
!     4),FVOABS(40),DMEEXT(40),DMEABS(40)                               
!                                                                       
      COMMON /EXTD  / VX2(47),RURE1(47),RURE2(47),RURE3(47),RURE4(47),  &
     & RURA1(47),RURA2(47),RURA3(47),RURA4(47),                         &
     & RURG1(47),RURG2(47),RURG3(47),RURG4(47),                         &
     & URBE1(47),URBE2(47),URBE3(47),URBE4(47),                         &
     & URBA1(47),URBA2(47),URBA3(47),URBA4(47),                         &
     & URBG1(47),URBG2(47),URBG3(47),URBG4(47),                         &
     & OCNE1(47),OCNE2(47),OCNE3(47),OCNE4(47),                         &
     & OCNA1(47),OCNA2(47),OCNA3(47),OCNA4(47),                         &
     & OCNG1(47),OCNG2(47),OCNG3(47),OCNG4(47),                         &
     & TROE1(47),TROE2(47),TROE3(47),TROE4(47),                         &
     & TROA1(47),TROA2(47),TROA3(47),TROA4(47),                         &
     & TROG1(47),TROG2(47),TROG3(47),TROG4(47),                         &
     & FG1EXT(47),FG1ABS(47),FG1SYM(47),FG2EXT(47),FG2ABS(47),          &
     & FG2SYM(47),BSTEXT(47),BSTABS(47),BSTSYM(47),AVOEXT(47),          &
     & AVOABS(47),AVOSYM(47),FVOEXT(47),FVOABS(47),FVOSYM(47),          &
     & DMEEXT(47),DMEABS(47),DMESYM(47),CCUEXT(47),CCUABS(47),          &
     & CCUSYM(47),CALEXT(47),CALABS(47),CALSYM(47),CSTEXT(47),          &
     & CSTABS(47),CSTSYM(47),CSCEXT(47),CSCABS(47),CSCSYM(47),          &
     & CNIEXT(47),CNIABS(47),CNISYM(47)                                 
!                                                                       
!     CI64--    STANDARD  CIRRUS  CLOUD  MODEL                          
!     ICE 64 MICRON MODE RADIUS CIRRUS CLOUD MODEL                      
!                                                                       
!     CIR4--    OPTICALLY  THIN  CIRRUS  MODEL                          
!     ICE  4 MICRON MODE RADIUS CIRRUS CLOUD MODEL                      
!                                                                       
       COMMON/CIRR/ CI64XT(47),CI64AB(47),CI64G(47),                    &
     &              CIR4XT(47),CIR4AB(47),CIR4G(47)                     
      DATA VX2 /                                                        &
     &   .2000,   .3000,   .3371,   .5500,   .6943,  1.0600,  1.5360,   &
     &  2.0000,  2.2500,  2.5000,  2.7000,  3.0000,  3.3923,  3.7500,   &
     &  4.5000,  5.0000,  5.5000,  6.0000,  6.2000,  6.5000,  7.2000,   &
     &  7.9000,  8.2000,  8.7000,  9.0000,  9.2000, 10.0000, 10.5910,   &
     & 11.0000, 11.5000, 12.5000, 14.8000, 15.0000, 16.4000, 17.2000,   &
     & 18.5000, 21.3000, 25.0000, 30.0000, 40.0000, 50.0000, 60.0000,   &
     & 80.0000, 100.000, 150.000, 200.000, 300.000/                     
      DATA RURE1 /                                                      &
     & 2.09291, 1.74582, 1.60500, 1.00000,  .75203,  .41943,  .24070,   &
     &  .14709,  .13304,  .12234,  .13247,  .11196,  .10437,  .09956,   &
     &  .09190,  .08449,  .07861,  .07025,  .07089,  .07196,  .07791,   &
     &  .04481,  .04399,  .12184,  .12658,  .12829,  .09152,  .08076,   &
     &  .07456,  .06880,  .06032,  .04949,  .05854,  .06000,  .06962,   &
     &  .05722,  .06051,  .05177,  .04589,  .04304,                     &
     &  .03582,  .03155,  .02018,  .01469,  .00798,  .00551, 0./        
      DATA RURE2 /                                                      &
     & 2.09544, 1.74165, 1.59981, 1.00000,  .75316,  .42171,  .24323,   &
     &  .15108,  .13608,  .12430,  .13222,  .13823,  .11076,  .10323,   &
     &  .09475,  .08728,  .08076,  .07639,  .07797,  .07576,  .07943,   &
     &  .04899,  .04525,  .12165,  .12741,  .12778,  .09032,  .07962,   &
     &  .07380,  .06880,  .06329,  .05791,  .06646,  .06639,  .07443,   &
     &  .06304,  .06443,  .05538,  .04867,  .04519,                     &
     &  .03821,  .03374,  .02173,  .01587,  .00862,  .00594, 0./        
      DATA RURE3 /                                                      &
     & 2.07082, 1.71456, 1.57962, 1.00000,  .76095,  .43228,  .25348,   &
     &  .16456,  .14677,  .13234,  .13405,  .20316,  .12873,  .11506,   &
     &  .10481,  .09709,  .08918,  .09380,  .09709,  .08791,  .08601,   &
     &  .06247,  .05601,  .11905,  .12595,  .12348,  .08741,  .07703,   &
     &  .07266,  .07044,  .07443,  .08146,  .08810,  .08563,  .08962,   &
     &  .08051,  .07677,  .06658,  .05747,  .05184,                     &
     &  .04572,  .04074,  .02689,  .01981,  .01084,  .00714, 0./        
      DATA RURE4 /                                                      &
     & 1.66076, 1.47886, 1.40139, 1.00000,  .80652,  .50595,  .32259,   &
     &  .23468,  .20772,  .18532,  .17348,  .35114,  .20006,  .17386,   &
     &  .16139,  .15424,  .14557,  .16215,  .16766,  .14994,  .14032,   &
     &  .12968,  .12601,  .13551,  .13582,  .13228,  .11070,  .09994,   &
     &  .09873,  .10418,  .13241,  .15924,  .16139,  .15949,  .15778,   &
     &  .15184,  .13848,  .12563,  .11076,  .09601,                     &
     &  .09312,  .08720,  .06644,  .05264,  .03181,  .02196, 0.0/       
      DATA RURA1 /                                                      &
     &  .67196,  .11937,  .08506,  .05930,  .05152,  .05816,  .05006,   &
     &  .01968,  .02070,  .02101,  .05652,  .02785,  .01316,  .00867,   &
     &  .01462,  .01310,  .01627,  .02013,  .02165,  .02367,  .03538,   &
     &  .02823,  .03962,  .06778,  .07285,  .08120,  .04032,  .03177,   &
     &  .02557,  .02342,  .02177,  .02627,  .03943,  .03114,  .03696,   &
     &  .02956,  .03500,  .03241,  .03297,  .03380,                     &
     &  .03170,  .02794,  .01769,  .01305,  .00730,  .00518, 0.0/       
      DATA RURA2 /                                                      &
     &  .62968,  .10816,  .07671,  .05380,  .04684,  .05335,  .04614,   &
     &  .01829,  .01899,  .01962,  .05525,  .06816,  .01652,  .00867,   &
     &  .01544,  .01373,  .01627,  .02892,  .02829,  .02532,  .03487,   &
     &  .02835,  .03854,  .06684,  .07272,  .08038,  .03987,  .03247,   &
     &  .02816,  .02816,  .03101,  .03741,  .04829,  .04032,  .04399,   &
     &  .03734,  .03956,  .03601,  .03525,  .03563,                     &
     & .03357,  .02965,  .01887,  .01395,  .00782,  .00555, 0.0/        
      DATA RURA3 /                                                      &
     &  .51899,  .08278,  .05816,  .04082,  .03570,  .04158,  .03620,   &
     &  .01513,  .01481,  .01633,  .05278,  .13690,  .02494,  .00886,   &
     &  .01804,  .01582,  .01677,  .04816,  .04367,  .03013,  .03443,   &
     &  .02930,  .03677,  .06209,  .06911,  .07475,  .03892,  .03494,   &
     &  .03513,  .03968,  .05152,  .06241,  .06937,  .06203,  .06215,   &
     &  .05614,  .05209,  .04608,  .04196,  .04095,                     &
     &  .03916,  .03486,  .02262,  .01686,  .00951,  .00674, 0.0/       
      DATA RURA4 /                                                      &
     &  .21943,  .02848,  .01943,  .01342,  .01171,  .01437,  .01323,   &
     &  .01152,  .00696,  .01329,  .06108,  .24690,  .05323,  .01430,   &
     &  .03361,  .02949,  .02652,  .09437,  .08506,  .05348,  .04627,   &
     &  .04380,  .04557,  .05380,  .05715,  .05899,  .04861,  .05253,   &
     &  .06171,  .07437,  .10152,  .12019,  .12190,  .11734,  .11411,   &
     &  .10766,  .09487,  .08430,  .07348,  .06861,                     &
     &  .06936,  .06458,  .04735,  .03761,  .02313,  .01668, 0.0/       
      DATA RURG1 /                                                      &
     &  .7581,   .6785,   .6712,   .6479,   .6342,   .6176,   .6334,    &
     &  .7063,   .7271,   .7463,   .7788,   .7707,   .7424,   .7312,    &
     &  .7442,   .7516,   .7662,   .7940,   .7886,   .7797,   .7664,    &
     &  .8525,   .8700,   .5846,   .5570,   .5992,   .6159,   .6271,    &
     &  .6257,   .6374,   .6546,   .6861,   .6859,   .6120,   .5570,    &
     &  .5813,   .5341,   .5284,   .5137,   .4348,   .4223,   .3775,    &
     &  .3435,   .3182,   .2791,   .2494,   .0000/                      
      DATA RURG2 /                                                      &
     &  .7632,   .6928,   .6865,   .6638,   .6498,   .6314,   .6440,    &
     &  .7098,   .7303,   .7522,   .7903,   .7804,   .7380,   .7319,    &
     &  .7508,   .7584,   .7738,   .8071,   .7929,   .7843,   .7747,    &
     &  .8507,   .8750,   .6112,   .5851,   .6272,   .6466,   .6616,    &
     &  .6653,   .6798,   .6965,   .7026,   .6960,   .6360,   .5848,    &
     &  .6033,   .5547,   .5445,   .5274,   .4518,   .4318,   .3863,    &
     &  .3516,   .3257,   .2853,   .2548,   .0000/                      
      DATA RURG3 /                                                      &
     &  .7725,   .7240,   .7197,   .6997,   .6858,   .6650,   .6702,    &
     &  .7181,   .7378,   .7653,   .8168,   .7661,   .7286,   .7336,    &
     &  .7654,   .7735,   .7910,   .8303,   .8025,   .7957,   .7946,    &
     &  .8468,   .8734,   .6831,   .6619,   .6994,   .7250,   .7449,    &
     &  .7547,   .7665,   .7644,   .7265,   .7170,   .6769,   .6409,    &
     &  .6442,   .6031,   .5854,   .5646,   .4977,   .4602,   .4127,    &
     &  .3751,   .3476,   .3048,   .2721,   .0000/                      
      DATA RURG4 /                                                      &
     &  .7778,   .7793,   .7786,   .7717,   .7628,   .7444,   .7365,    &
     &  .7491,   .7609,   .7921,   .8688,   .7537,   .7294,   .7413,    &
     &  .7928,   .8016,   .8225,   .8761,   .8359,   .8285,   .8385,    &
     &  .8559,   .8654,   .8414,   .8415,   .8527,   .8740,   .8903,    &
     &  .8952,   .8923,   .8611,   .8033,   .7989,   .7758,   .7632,    &
     &  .7508,   .7314,   .7091,   .6867,   .6419,   .5790,   .5259,    &
     &  .4749,   .4415,   .3886,   .3489,   .0000/                      
      DATA URBE1 /                                                      &
     & 1.88816, 1.63316, 1.51867, 1.00000,  .77785,  .47095,  .30006,   &
     &  .21392,  .19405,  .17886,  .18127,  .16133,  .14785,  .14000,   &
     &  .12715,  .11880,  .11234,  .10601,  .10500,  .10361,  .10342,   &
     &  .08766,  .08652,  .11937,  .12139,  .12297,  .09797,  .09057,   &
     &  .08595,  .08196,  .07563,  .06696,  .07209,  .06842,  .07177,   &
     &  .06354,  .06177,  .05373,  .04728,  .04051,                     &
     &  .03154,  .02771,  .01759,  .01278,  .00693,  .00480, 0.0/       
      DATA URBE2 /                                                      &
     & 1.95582, 1.64994, 1.53070, 1.00000,  .77614,  .46639,  .29487,   &
     &  .21051,  .18943,  .17285,  .17209,  .21418,  .15354,  .14051,   &
     &  .12728,  .11861,  .11089,  .11329,  .11323,  .10563,  .10247,   &
     &  .08696,  .08361,  .12013,  .12418,  .12304,  .09614,  .08842,   &
     &  .08487,  .08285,  .08361,  .08430,  .08880,  .08449,  .08601,   &
     &  .07835,  .07323,  .06367,  .05500,  .04747,                     &
     &  .03901,  .03454,  .02240,  .01638,  .00891,  .00612, 0.0/       
      DATA URBE3 /                                                      &
     & 1.96430, 1.64032, 1.52392, 1.00000,  .77709,  .46253,  .28690,   &
     &  .20310,  .17981,  .16101,  .15614,  .26475,  .15456,  .13563,   &
     &  .12215,  .11361,  .10500,  .11715,  .11753,  .10392,  .09766,   &
     &  .08443,  .08057,  .10943,  .11342,  .11063,  .08703,  .08025,   &
     &  .07886,  .08032,  .09101,  .10070,  .10386,  .09943,  .09886,   &
     &  .09152,  .08247,  .07152,  .06089,  .05253,                     &
     &  .04582,  .04091,  .02717,  .02008,  .01103,  .00754, 0.0/       
      DATA URBE4 /                                                      &
     & 1.41266, 1.33816, 1.29114, 1.00000,  .83646,  .55025,  .35342,   &
     &  .25285,  .21576,  .18310,  .16215,  .37854,  .20494,  .16665,   &
     &  .14778,  .13892,  .12943,  .15525,  .15709,  .13513,  .12481,   &
     &  .11759,  .11494,  .11487,  .11329,  .11108,  .09911,  .09209,   &
     &  .09342,  .10120,  .13177,  .15696,  .15766,  .15513,  .15203,   &
     &  .14532,  .13038,  .11785,  .10411,  .09101,                     &
     &  .08907,  .08399,  .06579,  .05337,  .03372,  .02379, 0.0/       
      DATA URBA1 /                                                      &
     &  .78437,  .58975,  .54285,  .36184,  .29222,  .20886,  .15658,   &
     &  .12329,  .11462,  .10747,  .11797,  .10025,  .08759,  .08184,   &
     &  .07506,  .07006,  .06741,  .06601,  .06544,  .06449,  .06665,   &
     &  .06278,  .06949,  .07316,  .07462,  .08101,  .05753,  .05272,   &
     &  .04899,  .04734,  .04494,  .04443,  .05133,  .04348,  .04443,   &
     &  .03994,  .03981,  .03633,  .03468,  .03146,                     &
     &  .02809,  .02471,  .01556,  .01145,  .00639,  .00454, 0.0/       
      DATA URBA2 /                                                      &
     &  .69032,  .49367,  .45165,  .29741,  .24070,  .17399,  .13146,   &
     &  .10354,  .09589,  .09025,  .10411,  .15101,  .07880,  .06949,   &
     &  .06570,  .06095,  .05829,  .07171,  .06797,  .05975,  .06013,   &
     &  .05589,  .06051,  .07139,  .07494,  .07956,  .05525,  .05184,   &
     &  .05089,  .05291,  .05886,  .06380,  .06880,  .06127,  .06019,   &
     &  .05525,  .05070,  .04500,  .04076,  .03741,                     &
     &  .03400,  .03010,  .01926,  .01427,  .00800,  .00567, 0.0/       
      DATA URBA3 /                                                      &
     &  .54848,  .37101,  .33734,  .21949,  .17785,  .12968,  .09854,   &
     &  .07804,  .07165,  .06791,  .08563,  .19639,  .06722,  .05316,   &
     &  .05316,  .04886,  .04620,  .07570,  .06899,  .05291,  .05101,   &
     &  .04734,  .05025,  .06171,  .06570,  .06854,  .04892,  .04797,   &
     &  .05057,  .05665,  .07127,  .08095,  .08411,  .07728,  .07475,   &
     &  .06886,  .06019,  .05222,  .04538,  .04171,                     &
     &  .03911,  .03486,  .02271,  .01697,  .00961,  .00681, 0.0/       
      DATA URBA4 /                                                      &
     &  .15975,  .10000,  .09013,  .05785,  .04671,  .03424,  .02633,   &
     &  .02525,  .01975,  .02354,  .06241,  .26690,  .05810,  .02285,   &
     &  .03810,  .03386,  .03044,  .09627,  .08557,  .05405,  .04576,   &
     &  .04392,  .04424,  .04671,  .04791,  .04861,  .04684,  .05177,   &
     &  .06158,  .07475,  .10342,  .12146,  .12177,  .11734,  .11335,   &
     &  .10608,  .09171,  .08063,  .06968,  .06475,                     &
     &  .06559,  .06131,  .04591,  .03714,  .02365,  .01734, 0.0/       
      DATA URBG1 /                                                      &
     &  .7785,   .7182,   .7067,   .6617,   .6413,   .6166,   .6287,    &
     &  .6883,   .7070,   .7243,   .7370,   .7446,   .7391,   .7371,    &
     &  .7414,   .7435,   .7466,   .7543,   .7498,   .7424,   .7270,    &
     &  .7674,   .7850,   .5880,   .5616,   .5901,   .6159,   .6238,    &
     &  .6240,   .6281,   .6306,   .6298,   .6252,   .5785,   .5378,    &
     &  .5512,   .5072,   .4930,   .4709,   .4009,   .4110,   .3672,    &
     &  .3344,   .3093,   .2717,   .2426,   .0000/                      
      DATA URBG2 /                                                      &
     &  .7906,   .7476,   .7385,   .6998,   .6803,   .6536,   .6590,    &
     &  .7066,   .7258,   .7484,   .7769,   .7405,   .7351,   .7459,    &
     &  .7625,   .7673,   .7759,   .7910,   .7732,   .7703,   .7644,    &
     &  .7966,   .8142,   .6635,   .6428,   .6700,   .6935,   .7050,    &
     &  .7092,   .7145,   .7094,   .6762,   .6684,   .6316,   .5997,    &
     &  .6013,   .5625,   .5433,   .5198,   .4552,   .4387,   .3928,    &
     &  .3575,   .3310,   .2899,   .2588,   .0000/                      
      DATA URBG3 /                                                      &
     &  .7949,   .7713,   .7650,   .7342,   .7162,   .6873,   .6820,    &
     &  .7131,   .7312,   .7583,   .8030,   .7171,   .7185,   .7400,    &
     &  .7698,   .7778,   .7923,   .8142,   .7864,   .7867,   .7891,    &
     &  .8147,   .8298,   .7276,   .7136,   .7361,   .7590,   .7729,    &
     &  .7783,   .7808,   .7624,   .7094,   .7022,   .6714,   .6480,    &
     &  .6417,   .6104,   .5887,   .5651,   .5058,   .4692,   .4212,    &
     &  .3825,   .3549,   .3112,   .2778,   .0000/                      
      DATA URBG4 /                                                      &
     &  .7814,   .7993,   .7995,   .7948,   .7870,   .7682,   .7751,    &
     &  .7501,   .7565,   .7809,   .8516,   .7137,   .7039,   .7241,    &
     &  .7728,   .7846,   .8093,   .8576,   .8125,   .8140,   .8304,    &
     &  .8472,   .8549,   .8525,   .8569,   .8640,   .8853,   .9017,    &
     &  .9061,   .9021,   .8685,   .8126,   .8091,   .7897,   .7802,    &
     &  .7691,   .7550,   .7353,   .7146,   .6754,   .6134,   .5601,    &
     &  .5056,   .4701,   .4134,   .3714,   .0000/                      
      DATA OCNE1 /                                                      &
     & 1.47576, 1.32614, 1.26171, 1.00000,  .88133,  .70297,  .56487,   &
     &  .46006,  .42044,  .38310,  .35076,  .42266,  .32278,  .28810,   &
     &  .24905,  .21184,  .16734,  .14791,  .21532,  .15076,  .12057,   &
     &  .10038,  .10703,  .15070,  .15665,  .14639,  .10228,  .08367,   &
     &  .07373,  .06829,  .05044,  .04373,  .04962,  .06158,  .07703,   &
     &  .07234,  .06297,  .05481,  .05329,  .08741,                     &
     &  .04608,  .03959,  .02382,  .01712,  .00936,  .00665, 0.0/       
      DATA OCNE2 /                                                      &
     & 1.36924, 1.25443, 1.20835, 1.00000,  .91367,  .77089,  .64987,   &
     &  .54886,  .50247,  .45038,  .38209,  .50589,  .43766,  .38076,   &
     &  .31658,  .27475,  .22215,  .21019,  .27570,  .21057,  .16949,   &
     &  .14209,  .14215,  .16956,  .17082,  .16025,  .11665,  .09759,   &
     &  .09215,  .09373,  .10532,  .12570,  .13000,  .13633,  .14291,   &
     &  .13506,  .11475,  .09658,  .08291,  .10348,                     &
     &  .06693,  .05786,  .03522,  .02519,  .01358,  .00954, 0.0/       
      DATA OCNE3 /                                                      &
     & 1.22259, 1.14627, 1.11842, 1.00000,  .94766,  .87538,  .80418,   &
     &  .72930,  .68582,  .62165,  .49962,  .67949,  .66468,  .59253,   &
     &  .49551,  .44671,  .37886,  .35924,  .43367,  .37019,  .30842,   &
     &  .26437,  .25228,  .24905,  .23975,  .22766,  .17804,  .15316,   &
     &  .15373,  .16791,  .22361,  .28348,  .28677,  .29082,  .29038,   &
     &  .27810,  .23867,  .20209,  .16430,  .14943,                     &
     &  .12693,  .11177,  .07095,  .05084,  .02690,  .01838, 0.0/       
      DATA OCNE4 /                                                      &
     & 1.09133, 1.06601, 1.05620, 1.00000,  .97506,  .94791,  .94203,   &
     &  .93671,  .92867,  .90411,  .80253,  .89222,  .94462,  .92146,   &
     &  .85797,  .82595,  .76747,  .68646,  .78209,  .75266,  .68658,   &
     &  .62722,  .60228,  .56335,  .53728,  .51861,  .43449,  .37196,   &
     &  .35899,  .37316,  .46854,  .58234,  .58690,  .60348,  .60563,   &
     &  .60000,  .55392,  .50367,  .43576,  .35949,                     &
     &  .34729,  .32254,  .23600,  .17953,  .10071,  .06714, 0.0/       
      DATA OCNA1 /                                                      &
     &  .30987,  .04354,  .02880,  .01797,  .01468,  .01766,  .01582,   &
     &  .00816,  .01146,  .01677,  .03310,  .03380,  .00715,  .00443,   &
     &  .00500,  .00601,  .00753,  .01595,  .02943,  .00994,  .01367,   &
     &  .01671,  .02538,  .03481,  .03405,  .03601,  .01608,  .01310,   &
     &  .01152,  .01082,  .01070,  .01563,  .02063,  .03171,  .03810,   &
     &  .03741,  .03804,  .03759,  .04209,  .07892,                     &
     &  .04347,  .03754,  .02269,  .01649,  .00917,  .00657, 0.0/       
      DATA OCNA2 /                                                      &
     &  .23367,  .03127,  .02070,  .01297,  .01063,  .01285,  .01190,   &
     &  .00937,  .00911,  .01576,  .05576,  .23487,  .03949,  .00905,   &
     &  .02057,  .01816,  .01665,  .08025,  .08044,  .03677,  .03139,   &
     &  .03190,  .03766,  .04532,  .04544,  .04715,  .03405,  .03614,   &
     &  .04329,  .05424,  .07823,  .09728,  .10057,  .10247,  .10222,   &
     &  .09551,  .08241,  .07158,  .06506,  .09203,                     &
     &  .06133,  .05332,  .03258,  .02366,  .01308,  .00932, 0.0/       
      DATA OCNA3 /                                                      &
     &  .13025,  .01557,  .01013,  .00646,  .00532,  .00665,  .00722,   &
     &  .01335,  .00728,  .01810,  .09835,  .37329,  .09703,  .01968,   &
     &  .05114,  .04342,  .03709,  .17456,  .16468,  .08785,  .06880,   &
     &  .06589,  .06791,  .07247,  .07329,  .07449,  .07025,  .07962,   &
     &  .09899,  .12481,  .17867,  .22019,  .22228,  .22051,  .21595,   &
     &  .20335,  .17278,  .14677,  .12171,  .12430,                     &
     &  .10890,  .09644,  .06106,  .04465,  .02457,  .01732, 0.0/       
      DATA OCNA4 /                                                      &
     &  .03506,  .00323,  .00215,  .00139,  .00114,  .00171,  .00532,   &
     &  .03082,  .01101,  .03741,  .20101,  .47608,  .21165,  .05234,   &
     &  .12886,  .11215,  .09684,  .32810,  .31778,  .20513,  .16658,   &
     &  .15956,  .15842,  .15905,  .15968,  .16051,  .16506,  .18323,   &
     &  .21709,  .25652,  .33222,  .39639,  .39854,  .40297,  .40025,   &
     &  .39025,  .35468,  .32006,  .27715,  .25348,                     &
     &  .25632,  .23876,  .17092,  .13198,  .07692,  .05407, 0.0/       
      DATA OCNG1 /                                                      &
     &  .7516,   .6960,   .6920,   .6756,   .6767,   .6844,   .6936,    &
     &  .7055,   .7110,   .7177,   .7367,   .6287,   .6779,   .6784,    &
     &  .6599,   .6659,   .6859,   .6887,   .6095,   .6558,   .6665,    &
     &  .6697,   .6594,   .5851,   .5644,   .5760,   .5903,   .5991,    &
     &  .6024,   .5979,   .6087,   .5837,   .5763,   .5348,   .4955,    &
     &  .4821,   .4635,   .4373,   .3944,   .2344,   .2754,   .2447,    &
     &  .2266,   .2088,   .1766,   .1481,   .0000/                      
      DATA OCNG2 /                                                      &
     &  .7708,   .7288,   .7243,   .7214,   .7211,   .7330,   .7445,    &
     &  .7579,   .7649,   .7790,   .8182,   .7673,   .7171,   .7205,    &
     &  .7235,   .7251,   .7397,   .7537,   .6934,   .7137,   .7193,    &
     &  .7206,   .7151,   .6732,   .6620,   .6696,   .6821,   .6895,    &
     &  .6898,   .6819,   .6556,   .5925,   .5869,   .5511,   .5284,    &
     &  .5124,   .4912,   .4646,   .4302,   .3124,   .3101,   .2752,    &
     &  .2529,   .2335,   .2021,   .1738,   .0000/                      
      DATA OCNG3 /                                                      &
     &  .7954,   .7782,   .7752,   .7717,   .7721,   .7777,   .7872,    &
     &  .8013,   .8089,   .8301,   .8844,   .8332,   .7557,   .7597,    &
     &  .7823,   .7822,   .7944,   .8157,   .7712,   .7738,   .7784,    &
     &  .7807,   .7800,   .7682,   .7659,   .7692,   .7780,   .7828,    &
     &  .7776,   .7621,   .7115,   .6342,   .6294,   .5999,   .5854,    &
     &  .5700,   .5512,   .5265,   .4996,   .4236,   .3765,   .3357,    &
     &  .3066,   .2830,   .2466,   .2184,   .0000/                      
      DATA OCNG4 /                                                      &
     &  .8208,   .8270,   .8260,   .8196,   .8176,   .8096,   .8096,    &
     &  .8202,   .8255,   .8520,   .9228,   .8950,   .7965,   .7847,    &
     &  .8242,   .8244,   .8376,   .8857,   .8463,   .8332,   .8379,    &
     &  .8441,   .8467,   .8502,   .8534,   .8562,   .8688,   .8789,    &
     &  .8785,   .8683,   .8252,   .7562,   .7519,   .7261,   .7141,    &
     &  .6980,   .6789,   .6540,   .6294,   .5783,   .5100,   .4595,    &
     &  .4164,   .3868,   .3404,   .3042,   .0000/                      
      DATA TROE1 /                                                      &
     & 2.21222, 1.82753, 1.67032, 1.00000,  .72424,  .35272,  .15234,   &
     &  .05165,  .03861,  .02994,  .04671,  .02462,  .01538,  .01146,   &
     &  .01032,  .00816,  .00861,  .00994,  .01057,  .01139,  .01747,   &
     &  .01494,  .02418,  .03165,  .03386,  .04247,  .01601,  .01215,   &
     &  .00937,  .00861,  .00823,  .01139,  .01924,  .01234,  .01348,   &
     &  .01114,  .01297,  .01266,  .01418,  .01487,                     &
     &  .01543,  .01321,  .00793,  .00582,  .00330,  .00239, 0.0/       
      DATA TROE2 /                                                      &
     & 2.21519, 1.82266, 1.66557, 1.00000,  .72525,  .35481,  .15449,   &
     &  .05475,  .04044,  .03082,  .04620,  .05272,  .01867,  .01266,   &
     &  .01127,  .00886,  .00886,  .01449,  .01399,  .01228,  .01728,   &
     &  .01475,  .02285,  .03215,  .03494,  .04285,  .01652,  .01304,   &
     &  .01101,  .01120,  .01297,  .01753,  .02468,  .01741,  .01766,   &
     &  .01513,  .01557,  .01456,  .01532,  .01582,                     &
     &  .01619,  .01386,  .00832,  .00610,  .00346,  .00251, 0.0/       
      DATA TROE3 /                                                      &
     & 2.19082, 1.79462, 1.64456, 1.00000,  .73297,  .36443,  .16278,   &
     &  .06468,  .04658,  .03399,  .04538,  .11892,  .02835,  .01646,   &
     &  .01386,  .01076,  .00968,  .02551,  .02222,  .01468,  .01690,   &
     &  .01437,  .01994,  .03127,  .03513,  .04076,  .01722,  .01513,   &
     &  .01519,  .01791,  .02538,  .03272,  .03816,  .03038,  .02886,   &
     &  .02551,  .02228,  .01937,  .01804,  .01791,                     &
     &  .01798,  .01539,  .00924,  .00678,  .00384,  .00278, 0.0/       
      DATA TROE4 /                                                      &
     & 1.75696, 1.54829, 1.45962, 1.00000,  .77816,  .43139,  .21778,   &
     &  .11329,  .08101,  .05506,  .04943,  .25291,  .06816,  .03703,   &
     &  .02601,  .01968,  .01468,  .04962,  .04247,  .02234,  .01797,   &
     &  .01532,  .01633,  .02259,  .02487,  .02595,  .01728,  .01892,   &
     &  .02399,  .03247,  .05285,  .06462,  .06608,  .05930,  .05525,   &
     &  .04861,  .03753,  .02968,  .02348,  .02165,                     &
     &  .02152,  .01841,  .01104,  .00809,  .00458,  .00332, 0.0/       
      DATA TROA1 /                                                      &
     &  .69671,  .09905,  .06563,  .04101,  .03354,  .03627,  .02810,   &
     &  .00873,  .00918,  .00930,  .03215,  .01285,  .00513,  .00316,   &
     &  .00557,  .00494,  .00646,  .00867,  .00937,  .01025,  .01646,   &
     &  .01481,  .02418,  .02886,  .03070,  .04032,  .01494,  .01139,   &
     &  .00873,  .00816,  .00797,  .01133,  .01911,  .01215,  .01329,   &
     &  .01101,  .01291,  .01266,  .01418,  .01487,                     &
     &  .01543,  .01321,  .00793,  .00582,  .00330,  .00239, 0.0/       
      DATA TROA2 /                                                      &
     &  .65000,  .08791,  .05816,  .03652,  .02994,  .03278,  .02557,   &
     &  .00810,  .00842,  .00867,  .03139,  .03949,  .00646,  .00316,   &
     &  .00595,  .00519,  .00646,  .01304,  .01247,  .01095,  .01620,   &
     &  .01449,  .02278,  .02930,  .03184,  .04063,  .01544,  .01234,   &
     &  .01044,  .01076,  .01272,  .01741,  .02462,  .01722,  .01747,   &
     &  .01506,  .01551,  .01456,  .01532,  .01582,                     &
     &  .01619,  .01386,  .00832,  .00610,  .00346,  .00251, 0.0/       
      DATA TROA3 /                                                      &
     &  .52804,  .06367,  .04158,  .02633,  .02184,  .02443,  .01937,   &
     &  .00658,  .00646,  .00709,  .02949,  .10013,  .00968,  .00310,   &
     &  .00677,  .00582,  .00646,  .02361,  .01994,  .01266,  .01544,   &
     &  .01386,  .01968,  .02848,  .03203,  .03854,  .01620,  .01449,   &
     &  .01462,  .01747,  .02513,  .03253,  .03797,  .03019,  .02861,   &
     &  .02538,  .02215,  .01930,  .01797,  .01791,                     &
     &  .01797,  .01539,  .00924,  .00677,  .00384,  .00278, 0.0/       
      DATA TROA4 /                                                      &
     &  .19829,  .01842,  .01215,  .00791,  .00665,  .00778,  .00652,   &
     &  .00361,  .00253,  .00399,  .02570,  .20690,  .01715,  .00316,   &
     &  .00873,  .00728,  .00658,  .04481,  .03525,  .01646,  .01405,   &
     &  .01310,  .01468,  .01956,  .02184,  .02367,  .01608,  .01816,   &
     &  .02342,  .03203,  .05234,  .06399,  .06538,  .05867,  .05456,   &
     &  .04810,  .03715,  .02949,  .02335,  .02158,                     &
     &  .02149,  .01840,  .01104,  .00809,  .00458,  .00332, 0.0/       
      DATA TROG1 /                                                      &
     &  .7518,   .6710,   .6638,   .6345,   .6152,   .5736,   .5280,    &
     &  .4949,   .4700,   .4467,   .4204,   .4028,   .3777,   .3563,    &
     &  .3150,   .2919,   .2695,   .2465,   .2402,   .2313,   .2101,    &
     &  .1760,   .1532,   .2091,   .2079,   .1843,   .1811,   .1687,    &
     &  .1626,   .1526,   .1356,   .1030,   .0962,   .1024,   .1086,    &
     &  .0928,   .0836,   .0643,   .0451,   .0290,   .0156,   .0118,    &
     &  .0076,   .0050,   .0024,   .0015,   .0000/                      
      DATA TROG2 /                                                      &
     &  .7571,   .6858,   .6790,   .6510,   .6315,   .5887,   .5418,    &
     &  .5075,   .4829,   .4598,   .4338,   .4043,   .3890,   .3680,    &
     &  .3259,   .3026,   .2800,   .2541,   .2494,   .2414,   .2196,    &
     &  .1873,   .1657,   .2123,   .2110,   .1890,   .1836,   .1709,    &
     &  .1640,   .1534,   .1354,   .1044,   .0984,   .1026,   .1073,    &
     &  .0935,   .0842,   .0661,   .0477,   .0309,   .0171,   .0129,    &
     &  .0084,   .0056,   .0027,   .0017,   .0000/                      
      DATA TROG3 /                                                      &
     &  .7667,   .7176,   .7128,   .6879,   .6690,   .6255,   .5769,    &
     &  .5403,   .5167,   .4947,   .4703,   .4143,   .4190,   .3993,    &
     &  .3563,   .3325,   .3095,   .2767,   .2751,   .2693,   .2464,    &
     &  .2175,   .1992,   .2247,   .2215,   .2042,   .1952,   .1814,    &
     &  .1726,   .1604,   .1398,   .1111,   .1065,   .1068,   .1086,    &
     &  .0984,   .0888,   .0724,   .0549,   .0358,   .0216,   .0166,    &
     &  .0109,   .0073,   .0036,   .0023,   .0000/                      
      DATA TROG4 /                                                      &
     &  .7696,   .7719,   .7710,   .7606,   .7478,   .7142,   .6727,    &
     &  .6381,   .6201,   .6050,   .5912,   .4849,   .5137,   .5019,    &
     &  .4625,   .4389,   .4169,   .3696,   .3707,   .3708,   .3473,    &
     &  .3232,   .3112,   .3022,   .2938,   .2850,   .2675,   .2494,    &
     &  .2347,   .2165,   .1857,   .1536,   .1509,   .1441,   .1416,    &
     &  .1354,   .1245,   .1088,   .0905,   .0614,   .0440,   .0354,    &
     &  .0257,   .0179,   .0089,   .0059,   .0000/                      
      DATA FG1EXT /                                                     &
     &  .98519,  .99155,  .99089, 1.00000, 1.00580, 1.01740, 1.03170,   &
     & 1.04140, 1.04700, 1.05320, 1.05890, 1.04900, 1.06820, 1.07800,   &
     & 1.09270, 1.10370, 1.11680, 1.10430, 1.11370, 1.12900, 1.14990,   &
     & 1.17210, 1.18280, 1.20140, 1.21260, 1.21950, 1.22680, 1.15590,   &
     & 1.05690,  .98291, 1.01120, 1.10910, 1.11460, 1.14670, 1.16250,   &
     & 1.18540, 1.21580, 1.24610, 1.26840, 1.20500, 1.20850, 1.23340,   &
     & 1.19560, 1.06530,  .68949,  .42888, 0.00000/                     
      DATA FG1ABS /                                                     &
     &  .00012,  .00001,  .00001,  .00000,  .00001,  .00095,  .01515,   &
     &  .10858,  .03890,  .13270,  .47131,  .49695,  .45787,  .17915,   &
     &  .37373,  .34600,  .31866,  .55187,  .55023,  .49984,  .46341,   &
     &  .45944,  .45916,  .46087,  .46240,  .46386,  .47193,  .48902,   &
     &  .51470,  .53099,  .55264,  .58664,  .58897,  .60369,  .61155,   &
     &  .62335,  .64120,  .65627,  .66278,  .66393,  .69344,  .71087,   &
     &  .67625,  .61180,  .42130,  .29086, 0.00000/                     
      DATA FG1SYM /                                                     &
     &  .8578,   .8726,   .8722,   .8717,   .8703,   .8652,   .8618,    &
     &  .8798,   .8689,   .8918,   .9641,   .9502,   .9297,   .8544,    &
     &  .9007,   .8885,   .8812,   .9604,   .9470,   .9193,   .9039,    &
     &  .9039,   .9057,   .9110,   .9158,   .9194,   .9381,   .9537,    &
     &  .9595,   .9587,   .9418,   .9101,   .9081,   .8957,   .8898,    &
     &  .8812,   .8685,   .8491,   .8246,   .7815,   .7148,   .6480,    &
     &  .5481,   .4725,   .3457,   .2575,   .0000/                      
      DATA FG2EXT /                                                     &
     &  .94790,  .96213,  .97061, 1.00000, 1.00940, 1.05180, 1.12520,   &
     & 1.29570, 1.39200, 1.41120, 1.04720, 1.10820, 1.43290, 1.45270,   &
     & 1.18710, 1.04370,  .82356,  .71746,  .92406,  .79342,  .60263,   &
     &  .47680,  .43171,  .36732,  .33259,  .31184,  .24137,  .21603,   &
     &  .24005,  .28816,  .42671,  .56861,  .57263,  .58090,  .57164,   &
     &  .54247,  .43983,  .34475,  .24907,  .19291,  .18500,  .15586,   &
     &  .09047,  .06445,  .03533,  .02529, 0.00000/                     
      DATA FG2ABS /                                                     &
     &  .00002,  .00000,  .00000,  .00000,  .00000,  .00016,  .00245,   &
     &  .01987,  .00619,  .02323,  .17209,  .57930,  .19812,  .03474,   &
     &  .09636,  .07999,  .06585,  .34591,  .32704,  .17023,  .12635,   &
     &  .11817,  .11624,  .11519,  .11538,  .11600,  .12327,  .14468,   &
     &  .18635,  .24056,  .35412,  .44884,  .45092,  .45215,  .44281,   &
     &  .41778,  .34433,  .27826,  .21066,  .17864,  .17626,  .15028,   &
     &  .08844,  .06358,  .03515,  .02523, 0.00000/                     
      DATA FG2SYM /                                                     &
     &  .8388,   .8459,   .8419,   .8286,   .8224,   .7883,   .7763,    &
     &  .8133,   .8393,   .8767,   .9258,   .8982,   .7887,   .8082,    &
     &  .8319,   .8243,   .8210,   .8282,   .8037,   .7904,   .7728,    &
     &  .7528,   .7436,   .7274,   .7171,   .7100,   .6790,   .6520,    &
     &  .6305,   .6020,   .5475,   .4577,   .4511,   .4084,   .3872,    &
     &  .3566,   .2976,   .2340,   .1711,   .0956,   .0623,   .0454,    &
     &  .0286,   .0190,   .0090,   .0052,   .0000/                      
      DATA BSTEXT /                                                     &
     & 1.48671, 1.55462, 1.51506, 1.00000,  .70633,  .28867,  .09994,   &
     &  .04184,  .02728,  .01848,  .01335,  .06513,  .08930,  .06532,   &
     &  .04766,  .04278,  .05810,  .05367,  .04392,  .03342,  .04456,   &
     &  .11867,  .14709,  .12734,  .09291,  .08778,  .05019,  .04070,   &
     &  .05734,  .03576,  .01975,  .01892,  .01956,  .03665,  .04152,   &
     &  .01715,  .01620,  .00835,  .00633,  .00589,                     &
     &  .01393,  .01193,  .00716,  .00526,  .00298,  .00216, 0.0/       
      DATA BSTABS /                                                     &
     & 0.00000, 0.00000, 0.00000, 0.00000, 0.00000, 0.00000,  .00019,   &
     &  .00127,  .00158,  .00291,  .00405,  .05880,  .08297,  .06019,   &
     &  .04519,  .04133,  .05703,  .05266,  .04304,  .03285,  .04437,   &
     &  .11816,  .14633,  .12639,  .09215,  .08722,  .04968,  .04044,   &
     &  .05709,  .03551,  .01962,  .01892,  .01949,  .03665,  .04146,   &
     &  .01709,  .01620,  .00835,  .00633,  .00589,                     &
     &  .01393,  .01193,  .00716,  .00526,  .00298,  .00216, 0.0/       
      DATA BSTSYM /                                                     &
     &  .6804,   .7134,   .7253,   .7259,   .6943,   .5918,   .4465,    &
     &  .3223,   .2686,   .2233,   .1916,   .1580,   .1299,   .1108,    &
     &  .0780,   .0629,   .0515,   .0454,   .0426,   .0379,   .0287,    &
     &  .0222,   .0204,   .0206,   .0214,   .0202,   .0205,   .0169,    &
     &  .0150,   .0157,   .0124,   .0083,   .0080,   .0063,   .0062,    &
     &  .0062,   .0043,   .0034,   .0024,   .0013,   .0007,   .0005,    &
     &  .0003,   .0002,   .0001,   .0001,   .0000/                      
      DATA AVOEXT /                                                     &
     & 1.14880, 1.19171, 1.18013, 1.00000,  .84873,  .53019,  .27968,   &
     &  .14551,  .11070,  .08633,  .07184,  .06076,  .04506,  .03399,   &
     &  .02095,  .01538,  .01266,  .01019,  .00994,  .01044,  .01361,   &
     &  .01791,  .02278,  .02918,  .03108,  .03234,  .03456,  .03184,   &
     &  .02772,  .02475,  .01715,  .01563,  .01665,  .01646,  .01734,   &
     &  .01772,  .01076,  .01051,  .01133,  .01329,                     &
     &  .01492,  .01277,  .00766,  .00562,  .00318,  .00231, 0.0/       
      DATA AVOABS /                                                     &
     &  .44816,  .11259,  .08500,  .05272,  .04082,  .02449,  .01487,   &
     &  .01019,  .00867,  .00842,  .00842,  .00949,  .00741,  .00487,   &
     &  .00316,  .00335,  .00399,  .00449,  .00525,  .00665,  .01114,   &
     &  .01652,  .02177,  .02437,  .02506,  .02658,  .03006,  .02861,   &
     &  .02513,  .02285,  .01620,  .01532,  .01633,  .01620,  .01709,   &
     &  .01741,  .01057,  .01038,  .01127,  .01329,                     &
     &  .01492,  .01277,  .00766,  .00562,  .00318,  .00231, 0.0/       
      DATA AVOSYM /                                                     &
     &  .8272,   .7148,   .7076,   .6978,   .6886,   .6559,   .6062,    &
     &  .5561,   .5255,   .4958,   .4729,   .4401,   .4015,   .3699,    &
     &  .3125,   .2773,   .2472,   .2173,   .2054,   .1908,   .1623,    &
     &  .1348,   .1233,   .1615,   .1757,   .1712,   .1521,   .1326,    &
     &  .1230,   .1081,   .0801,   .0528,   .0514,   .0461,   .0446,    &
     &  .0449,   .0415,   .0330,   .0198,   .0097,   .0044,   .0032,    &
     &  .0020,   .0013,   .0006,   .0004,   .0000/                      
      DATA FVOEXT /                                                     &
     &  .88715,  .92532,  .94013, 1.00000, 1.03013, 1.05975, 1.01171,   &
     &  .88677,  .82538,  .76361,  .71563,  .67424,  .60589,  .55057,   &
     &  .45222,  .37646,  .32316,  .25519,  .22728,  .20525,  .17810,   &
     &  .14481,  .14152,  .37639,  .44551,  .44405,  .42222,  .36462,   &
     &  .32551,  .27519,  .16728,  .10627,  .10861,  .10886,  .11665,   &
     &  .13127,  .10108,  .08557,  .06411,  .05741,                     &
     &  .05531,  .04707,  .02792,  .02028,  .01136,  .00820, 0.0/       
      DATA FVOABS /                                                     &
     &  .41582,  .22892,  .19108,  .14468,  .12475,  .09158,  .06601,   &
     &  .04943,  .04367,  .04342,  .04399,  .05076,  .04133,  .02829,   &
     &  .01924,  .01981,  .02297,  .02475,  .02778,  .03411,  .05335,   &
     &  .07133,  .08816,  .15342,  .18506,  .19354,  .20791,  .18449,   &
     &  .16101,  .13759,  .08456,  .06886,  .07278,  .07367,  .07956,   &
     &  .08785,  .06032,  .05747,  .05133,  .05323,                     &
     &  .05453,  .04657,  .02773,  .02020,  .01135,  .00820, 0.0/       
      DATA FVOSYM /                                                     &
     &  .9295,   .8115,   .7897,   .7473,   .7314,   .7132,   .7113,    &
     &  .7238,   .7199,   .7165,   .7134,   .6989,   .6840,   .6687,    &
     &  .6409,   .6325,   .6199,   .6148,   .6142,   .6072,   .5853,    &
     &  .5632,   .5486,   .4753,   .4398,   .4329,   .4091,   .4105,    &
     &  .4120,   .4136,   .4140,   .3637,   .3577,   .3344,   .3220,    &
     &  .3052,   .2957,   .2564,   .2055,   .1229,   .0632,   .0483,    &
     &  .0321,   .0216,   .0103,   .0059,   .0000/                      
      DATA DMEEXT /                                                     &
     & 1.05019, 1.05880, 1.05259, 1.00000,  .94949,  .81456,  .66051,   &
     &  .54380,  .49133,  .44677,  .41671,  .38063,  .34778,  .32804,   &
     &  .29722,  .27506,  .25082,  .22620,  .21652,  .20253,  .17266,   &
     &  .14905,  .14234,  .14082,  .15057,  .16399,  .23608,  .24481,   &
     &  .27791,  .25076,  .15272,  .09601,  .09456,  .14576,  .12373,   &
     &  .18348,  .12190,  .12924,  .08538,  .04108,                     &
     &  .04714,  .04069,  .02480,  .01789,  .00980,  .00693, 0.0/       
      DATA DMEABS /                                                     &
     &  .00063,  .00152,  .00184,  .00506,  .00791,  .01829,  .03728,   &
     &  .06158,  .07538,  .08943,  .10051,  .11614,  .13310,  .14348,   &
     &  .14633,  .13728,  .12462,  .11184,  .10709,  .10076,  .09006,   &
     &  .08734,  .09000,  .10304,  .11905,  .13437,  .19551,  .20095,   &
     &  .22494,  .18418,  .09285,  .06665,  .06823,  .12329,  .10551,   &
     &  .16184,  .09835,  .10582,  .06759,  .03247,                     &
     &  .04405,  .03816,  .02327,  .01696,  .00946,  .00677, 0.0/       
      DATA DMESYM /                                                     &
     &  .7173,   .7039,   .7020,   .6908,   .6872,   .6848,   .6891,    &
     &  .6989,   .7046,   .7099,   .7133,   .7159,   .7134,   .7058,    &
     &  .6827,   .6687,   .6583,   .6513,   .6494,   .6475,   .6467,    &
     &  .6496,   .6506,   .6461,   .6334,   .6177,   .5327,   .5065,    &
     &  .4632,   .4518,   .5121,   .5450,   .5467,   .4712,   .4853,    &
     &  .3984,   .4070,   .3319,   .3427,   .3766,   .3288,   .2969,    &
     &  .2808,   .2661,   .2409,   .2098,   .0000/                      
      DATA CCUEXT /                                                     &
     &  .98081,  .98746,  .98915, 1.00000, 1.00650, 1.02230, 1.04180,   &
     & 1.05830, 1.06780, 1.07870, 1.09780, 1.06440, 1.09750, 1.11300,   &
     & 1.14320, 1.16660, 1.20540, 1.15420, 1.17610, 1.21910, 1.26990,   &
     & 1.30300, 1.31090, 1.31060, 1.29940, 1.28640, 1.16620,  .98693,   &
     &  .88130,  .83429,  .92012, 1.07340, 1.08150, 1.12680, 1.14770,   &
     & 1.17600, 1.19210, 1.19120, 1.14510,  .97814,  .96308,  .94390,   &
     &  .75994,  .56647,  .26801,  .15748, 0.00000/                     
      DATA CCUABS /                                                     &
     &  .00007,  .00001,  .00000,  .00000,  .00001,  .00059,  .00956,   &
     &  .07224,  .02502,  .08913,  .41512,  .51824,  .41304,  .12614,   &
     &  .29826,  .26739,  .23672,  .55428,  .55642,  .44494,  .38433,   &
     &  .37277,  .37000,  .36872,  .36896,  .36984,  .37868,  .40498,   &
     &  .44993,  .48941,  .54799,  .60964,  .61302,  .63227,  .64074,   &
     &  .65112,  .65367,  .64760,  .61924,  .59000,  .61601,  .61058,   &
     &  .49236,  .38532,  .20641,  .13474, 0.00000/                     
      DATA CCUSYM /                                                     &
     &  .8557,   .8676,   .8680,   .8658,   .8630,   .8557,   .8496,    &
     &  .8566,   .8464,   .8627,   .9417,   .9458,   .8891,   .8136,    &
     &  .8503,   .8400,   .8453,   .9428,   .9168,   .8759,   .8733,    &
     &  .8841,   .8894,   .8986,   .9044,   .9082,   .9239,   .9342,    &
     &  .9367,   .9331,   .9119,   .8719,   .8692,   .8515,   .8424,    &
     &  .8287,   .8059,   .7742,   .7354,   .6554,   .5557,   .4720,    &
     &  .3713,   .2990,   .1846,   .1156,   .0000/                      
      DATA CALEXT /                                                     &
     &  .97331,  .98106,  .98472, 1.00000, 1.00850, 1.03090, 1.05770,   &
     & 1.08070, 1.09390, 1.11530, 1.20260, 1.08250, 1.13480, 1.16770,   &
     & 1.26750, 1.33520, 1.41110, 1.18200, 1.28390, 1.38040, 1.38430,   &
     & 1.31200, 1.26540, 1.17160, 1.10410, 1.05640,  .83383,  .66530,   &
     &  .61995,  .62907,  .77190,  .96660,  .97609, 1.02520, 1.04380,   &
     & 1.06270, 1.02550,  .95714,  .82508,  .63464,  .60962,  .54998,   &
     &  .34165,  .22587,  .10647,  .07067, 0.00000/                     
      DATA CALABS /                                                     &
     &  .00004,  .00000,  .00000,  .00000,  .00000,  .00036,  .00607,   &
     &  .04771,  .01579,  .05734,  .33199,  .54434,  .35157,  .08528,   &
     &  .21785,  .18813,  .15982,  .52068,  .52125,  .35294,  .28359,   &
     &  .26999,  .26668,  .26477,  .26484,  .26565,  .27546,  .30540,   &
     &  .36011,  .41780,  .51479,  .60420,  .60818,  .62781,  .63339,   &
     &  .63544,  .60762,  .56843,  .50067,  .44739,  .45910,  .42486,   &
     &  .27527,  .19352,  .09932,  .06832, 0.00000/                     
      DATA CALSYM /                                                     &
     &  .8523,   .8632,   .8623,   .8573,   .8532,   .8422,   .8297,    &
     &  .8252,   .8145,   .8317,   .9312,   .9383,   .8291,   .7640,    &
     &  .8202,   .8276,   .8547,   .9224,   .8859,   .8621,   .8706,    &
     &  .8780,   .8804,   .8833,   .8849,   .8858,   .8889,   .8899,    &
     &  .8872,   .8790,   .8513,   .7984,   .7944,   .7683,   .7545,    &
     &  .7333,   .6939,   .6405,   .5727,   .4313,   .3156,   .2437,    &
     &  .1693,   .1185,   .0574,   .0332,   .0000/                      
      DATA CSTEXT /                                                     &
     &  .97430,  .98324,  .98570, 1.00000, 1.00890, 1.03100, 1.05590,   &
     & 1.08130, 1.09760, 1.12170, 1.16390, 1.07880, 1.13660, 1.16990,   &
     & 1.22930, 1.26720, 1.31080, 1.15290, 1.23270, 1.29770, 1.31180,   &
     & 1.27830, 1.25190, 1.19190, 1.14390, 1.10790,  .91743,  .74497,   &
     &  .68246,  .67604,  .80234,  .98329,  .99219, 1.03880, 1.05710,   &
     & 1.07730, 1.05460, 1.00640,  .90146,  .71967,  .69823,  .65179,   &
     &  .44906,  .30781,  .14114,  .08913, 0.00000/                     
      DATA CSTABS /                                                     &
     &  .00005,  .00001,  .00000,  .00000,  .00000,  .00042,  .00681,   &
     &  .05317,  .01779,  .06484,  .35033,  .53843,  .36321,  .09457,   &
     &  .23629,  .20663,  .17789,  .52440,  .52484,  .37331,  .30681,   &
     &  .29375,  .29057,  .28880,  .28887,  .28969,  .29913,  .32789,   &
     &  .37961,  .43212,  .51866,  .60025,  .60398,  .62285,  .62874,   &
     &  .63229,  .61185,  .58151,  .52536,  .47993,  .49571,  .47074,   &
     &  .33104,  .24066,  .12346,  .08312, 0.00000/                     
      DATA CSTSYM /                                                     &
     &  .8519,   .8633,   .8629,   .8590,   .8546,   .8432,   .8328,    &
     &  .8330,   .8251,   .8439,   .9332,   .9388,   .8422,   .7823,    &
     &  .8288,   .8291,   .8482,   .9255,   .8906,   .8613,   .8675,    &
     &  .8772,   .8810,   .8869,   .8905,   .8927,   .9016,   .9069,    &
     &  .9060,   .8989,   .8714,   .8204,   .8168,   .7932,   .7811,    &
     &  .7628,   .7319,   .6905,   .6401,   .5324,   .4233,   .3459,    &
     &  .2636,   .2027,   .1120,   .0663,   .0000/                      
      DATA CSCEXT /                                                     &
     &  .96965,  .97960,  .98266, 1.00000, 1.01040, 1.03530, 1.06590,   &
     & 1.09980, 1.12280, 1.16020, 1.20330, 1.08630, 1.16840, 1.21860,   &
     & 1.28860, 1.32310, 1.33780, 1.11630, 1.24450, 1.30260, 1.26260,   &
     & 1.17670, 1.12990, 1.04180,  .98070,  .93828,  .74401,  .59962,   &
     &  .56489,  .57976,  .72193,  .90905,  .91772,  .96075,  .97500,   &
     &  .98623,  .93761,  .86388,  .73722,  .56926,  .54699,  .49341,   &
     &  .31131,  .20846,  .09872,  .06531, 0.00000/                     
      DATA CSCABS /                                                     &
     &  .00004,  .00000,  .00000,  .00000,  .00000,  .00035,  .00553,   &
     &  .04382,  .01430,  .05271,  .30881,  .54982,  .32983,  .07796,   &
     &  .20033,  .17269,  .14662,  .49557,  .49304,  .32632,  .26104,   &
     &  .24829,  .24525,  .24349,  .24358,  .24437,  .25378,  .28239,   &
     &  .33510,  .39227,  .49203,  .58265,  .58638,  .60338,  .60677,   &
     &  .60472,  .56954,  .52556,  .45708,  .40717,  .41646,  .38375,   &
     &  .25009,  .17726,  .09148,  .06291, 0.00000/                     
      DATA CSCSYM /                                                     &
     &  .8495,   .8597,   .8594,   .8535,   .8479,   .8349,   .8214,    &
     &  .8192,   .8151,   .8395,   .9321,   .9329,   .8156,   .7722,    &
     &  .8270,   .8319,   .8533,   .9138,   .8772,   .8562,   .8628,    &
     &  .8691,   .8713,   .8742,   .8759,   .8768,   .8805,   .8818,    &
     &  .8783,   .8685,   .8362,   .7776,   .7734,   .7458,   .7317,    &
     &  .7106,   .6738,   .6250,   .5655,   .4409,   .3338,   .2655,    &
     &  .1947,   .1427,   .0727,   .0422,   .0000/                      
      DATA CNIEXT /                                                     &
     &  .97967,  .98623,  .98795, 1.00000, 1.00710, 1.02340, 1.04300,   &
     & 1.06100, 1.07130, 1.08440, 1.10650, 1.06540, 1.10200, 1.12040,   &
     & 1.15490, 1.17990, 1.21730, 1.15000, 1.18140, 1.22610, 1.26770,   &
     & 1.28840, 1.29070, 1.28200, 1.26650, 1.25130, 1.12860,  .95670,   &
     &  .85784,  .81564,  .90486, 1.05950, 1.06760, 1.11240, 1.13250,   &
     & 1.15910, 1.16960, 1.16290, 1.11130,  .94771,  .93251,  .91151,   &
     &  .73279,  .55018,  .26554,  .15656, 0.00000/                     
      DATA CNIABS /                                                     &
     &  .00007,  .00001,  .00000,  .00000,  .00001,  .00058,  .00948,   &
     &  .07084,  .02436,  .08711,  .40714,  .52024,  .40688,  .12335,   &
     &  .29163,  .26107,  .23098,  .54886,  .55047,  .43579,  .37552,   &
     &  .36411,  .36140,  .36017,  .36043,  .36132,  .37019,  .39640,   &
     &  .44146,  .48184,  .54304,  .60651,  .60988,  .62882,  .63682,   &
     &  .64613,  .64572,  .63682,  .60584,  .57559,  .60014,  .59283,   &
     &  .47587,  .37364,  .20267,  .13269, 0.00000/                     
      DATA CNISYM /                                                     &
     &  .8550,   .8670,   .8677,   .8645,   .8616,   .8538,   .8474,    &
     &  .8534,   .8439,   .8609,   .9411,   .9449,   .8822,   .8101,    &
     &  .8486,   .8403,   .8475,   .9405,   .9134,   .8749,   .8732,    &
     &  .8833,   .8882,   .8968,   .9025,   .9061,   .9217,   .9322,    &
     &  .9346,   .9308,   .9086,   .8669,   .8641,   .8457,   .8364,    &
     &  .8222,   .7992,   .7677,   .7298,   .6525,   .5558,   .4752,    &
     &  .3796,   .3105,   .1995,   .1287,   .0000/                      
!                                                                       
!     EXTINCTION  COEFFICIENTS                                          
!                                                                       
      DATA CI64XT/                                                      &
     &   9.947E-01,  9.968E-01,  9.972E-01,  1.000E+00,  1.002E+00,     &
     &   1.005E+00,  1.010E+00,  1.013E+00,  1.016E+00,  1.018E+00,     &
     &   1.019E+00,  1.016E+00,  1.023E+00,  1.026E+00,  1.030E+00,     &
     &   1.033E+00,  1.036E+00,  1.037E+00,  1.038E+00,  1.040E+00,     &
     &   1.043E+00,  1.047E+00,  1.049E+00,  1.051E+00,  1.052E+00,     &
     &   1.053E+00,  1.055E+00,  1.032E+00,  1.034E+00,  1.047E+00,     &
     &   1.060E+00,  1.074E+00,  1.075E+00,  1.081E+00,  1.085E+00,     &
     &   1.090E+00,  1.102E+00,  1.117E+00,  1.131E+00,  1.094E+00,     &
     &   1.168E+00,  1.187E+00,  1.244E+00,  1.297E+00,  1.475E+00,     &
     &   1.695E+00,  1.556E+00 /                                        
!                                                                       
!     ABSORPTION  COEFFICIENTS                                          
!                                                                       
      DATA CI64AB/                                                      &
     &   7.893E-05,  1.914E-05,  1.450E-05,  5.904E-06,  3.905E-05,     &
     &   1.917E-03,  2.604E-01,  3.732E-01,  8.623E-02,  2.253E-01,     &
     &   4.152E-01,  4.460E-01,  4.660E-01,  4.589E-01,  4.848E-01,     &
     &   4.786E-01,  4.915E-01,  4.944E-01,  4.936E-01,  4.947E-01,     &
     &   4.978E-01,  5.012E-01,  5.028E-01,  5.070E-01,  5.095E-01,     &
     &   5.111E-01,  5.205E-01,  5.126E-01,  4.969E-01,  4.868E-01,     &
     &   4.836E-01,  4.982E-01,  4.999E-01,  5.097E-01,  5.126E-01,     &
     &   5.188E-01,  5.108E-01,  4.915E-01,  5.559E-01,  5.515E-01,     &
     &   5.600E-01,  5.948E-01,  6.225E-01,  6.348E-01,  5.693E-01,     &
     &   3.306E-01,  8.661E-02 /                                        
!                                                                       
!     ASYMMETRY  PARAMETER  -  G                                        
!                                                                       
      DATA CI64G/                                                       &
     &   .8626,  .8824,  .8851,  .8893,  .8904,  .8913,  .9332,  .9549, &
     &   .9141,  .9407,  .9763,  .9428,  .9509,  .9580,  .9699,  .9679, &
     &   .9735,  .9737,  .9717,  .9712,  .9712,  .9715,  .9721,  .9744, &
     &   .9756,  .9764,  .9822,  .9849,  .9721,  .9530,  .9341,  .9352, &
     &   .9366,  .9426,  .9425,  .9448,  .9365,  .9256,  .9485,  .9417, &
     &   .8868,  .8983,  .8589,  .8115,  .6810,  .5923,  .5703 /        
!                                                                       
!     EXTINCTION COEFFICIENTS                                           
!                                                                       
      DATA CIR4XT/                                                      &
     &   9.685E-01,  9.803E-01,  9.826E-01,  1.000E+00,  1.011E+00,     &
     &   1.038E+00,  1.066E+00,  1.090E+00,  1.118E+00,  1.201E+00,     &
     &   1.374E+00,  1.019E+00,  1.143E+00,  1.198E+00,  1.331E+00,     &
     &   1.434E+00,  1.424E+00,  1.283E+00,  1.298E+00,  1.326E+00,     &
     &   1.287E+00,  1.230E+00,  1.191E+00,  1.048E+00,  9.634E-01,     &
     &   9.093E-01,  6.067E-01,  5.216E-01,  6.953E-01,  8.902E-01,     &
     &   1.083E+00,  1.228E+00,  1.214E+00,  1.076E+00,  1.032E+00,     &
     &   8.881E-01,  6.275E-01,  3.462E-01,  2.118E-01,  3.955E-01,     &
     &   5.089E-01,  3.012E-01,  1.235E-01,  5.377E-02,  2.068E-02,     &
     &   6.996E-03,  1.560E-03 /                                        
!                                                                       
!     ABSORPTION  COEFFICIENTS                                          
!                                                                       
      DATA CIR4AB/                                                      &
     &   5.316E-06,  1.461E-06,  9.045E-07,  4.431E-07,  2.746E-06,     &
     &   1.413E-04,  2.920E-02,  5.578E-02,  6.844E-03,  2.151E-02,     &
     &   6.322E-02,  5.051E-01,  4.578E-01,  1.360E-01,  3.269E-01,     &
     &   1.572E-01,  2.246E-01,  4.176E-01,  4.282E-01,  3.802E-01,     &
     &   3.517E-01,  3.037E-01,  2.543E-01,  2.410E-01,  2.432E-01,     &
     &   2.438E-01,  2.346E-01,  3.747E-01,  4.839E-01,  5.722E-01,     &
     &   6.368E-01,  5.303E-01,  5.085E-01,  3.920E-01,  3.437E-01,     &
     &   2.481E-01,  1.175E-01,  7.172E-02,  1.108E-01,  3.459E-01,     &
     &   4.044E-01,  2.545E-01,  9.594E-02,  4.410E-02,  1.887E-02,     &
     &   6.433E-03,  1.456E-03 /                                        
!                                                                       
!     ASYMMETRY  PARAMETER  -  G                                        
!                                                                       
      DATA CIR4G/                                                       &
     &   .8517,  .8654,  .8661,  .8615,  .8574,  .8447,  .8321,  .8248, &
     &   .8227,  .8612,  .9363,  .9231,  .8419,  .7550,  .8481,  .8358, &
     &   .8718,  .8953,  .8884,  .8786,  .8731,  .8660,  .8625,  .8652, &
     &   .8659,  .8658,  .8676,  .8630,  .8434,  .8194,  .7882,  .7366, &
     &   .7339,  .7161,  .7015,  .6821,  .6383,  .5823,  .4845,  .2977, &
     &   .2295,  .1716,  .1228,  .0748,  .0329,  .0186,  .0081 /        
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE RDEXA 
!                                                                       
!     READ IN USER DEFINED EXTINCTION, ABSORPTION AND                   
!     ASYMMETRY PARAMETERS                                              
!                                                                       
!                                                                       
!     MXFSC IS THE MAXIMUM NUMBER OF LAYERS FOR OUTPUT TO LBLRTM        
!     MXLAY IS THE MAXIMUN NUMBER OF OUTPUT LAYERS                      
!     MXZMD IS THE MAX NUMBER OF LEVELS IN THE ATMOSPHERIC PROFILE      
!         STORED IN ZMDL (INPUT)                                        
!     MXPDIM IS THE MAXIMUM NUMBER OF LEVELS IN THE PROFILE ZPTH        
!         OBTAINED BY MERGING ZMDL AND ZOUT                             
!     MXMOL IS THE MAXIMUM NUMBER OF MOLECULES, KMXNOM IS THE DEFAULT   
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
!                                                                       
!     BLANK COMMON FOR ZMDL                                             
!                                                                       
      COMMON RELHUM(MXZMD),HSTOR(MXZMD),ICH(4),VH(16),TX(16),W(16) 
      COMMON WPATH(IM2,16),TBBY(IM2) 
      COMMON ABSC(5,47),EXTC(5,47),ASYM(5,47),VX2(47),AWCCON(5) 
!                                                                       
      CHARACTER*8      HMOD 
!                                                                       
      COMMON /CMN/ HMOD(3),ZM(MXZMD),PF(MXZMD),TF(MXZMD),RFNDXM(MXZMD), &
     &          ZP(IM2),PP(IM2),TP(IM2),RFNDXP(IM2),SP(IM2),PPSUM(IM2), &
     &          TPSUM(IM2),RHOPSM(IM2),IMLOW,WGM(MXZMD),DENW(MXZMD),    &
     &          AMTP(MXMOL,MXPDIM)                                      
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
      COMMON /LCRD2D/ IREG(4),ALTB(4),IREGC(4) 
!                                                                       
      DIMENSION TITLE(18),VX(47) 
!                                                                       
      READ (IRD,900) (IREG(IK),IK=1,4) 
      WRITE (IPR,905) (IREG(IK),IK=1,4) 
!                                                                       
      DO 10 IHC = 1, 4 
!                                                                       
         IF (IREG(IHC).EQ.0) GO TO 10 
         READ (IRD,910) AWCCON(IHC),TITLE 
         WRITE (IPR,915) AWCCON(IHC),TITLE 
         WRITE (IPR,920) 
!                                                                       
         READ (IRD,925) (VX(I),EXTC(IHC,I),ABSC(IHC,I),ASYM(IHC,I),I=1, &
         47)                                                            
         WRITE (IPR,930) (VX(I),EXTC(IHC,I),ABSC(IHC,I),ASYM(IHC,I),I=1,&
         47)                                                            
   10 END DO 
      RETURN 
!                                                                       
  900 FORMAT(4I5) 
  905 FORMAT('0 RECORD 3.6.2 *****',4I5) 
  910 FORMAT(E10.3,18A4) 
  915 FORMAT('0 RECORD 3.6.2 **** EQUIVALENT WATER = ',1PE10.3,18A4) 
  920 FORMAT('0 RECORD 3.6.3 ****') 
  925 FORMAT(3(F6.2,2F7.5,F6.4)) 
  930 FORMAT(2X,F6.2,2F7.5,F6.4,F6.2,2F7.5,F6.4,F6.2,2F7.5,F6.4) 
!                                                                       
      END                                           
!                                                                       
!     ***************************************************************** 
!                                                                       
      SUBROUTINE MARINE(VIS,MODEL,WS,WH,ICSTL,BEXT,BABS,NL) 
!                                                                       
!     THIS SUBROUTINE DETERMINES AEROSOL EXT + ABS COEFFICIENTS         
!     FOR THE NAVY MARITIME MODEL                                       
!     CODED BY STU GATHMAN                  -  NRL                      
!                                                                       
!     INPUTS-                                                           
!     WSS = CURRENT WIND SPEED (M/S)                                    
!     WHH = 24 HOUR AVERAGE WIND SPEED (M/S)                            
!     RHH = RELATIVE HUMIDITY (PERCENTAGE)                              
!     VIS = METEOROLOGICAL RANGE (KM)                                   
!     ICTL = AIR MASS CHARACTER  1 = OPEN OCEAN                         
!     10 = STRONG CONTINENTAL INFLUENCE                                 
!     MODEL = MODEL ATMOSPHERE                                          
!                                                                       
!     OUTPUTS-                                                          
!     BEXT = EXTINCTION COEFFICIENT (KM-1)                              
!     BABS = ABSORPTION COEFFICIENT (KM-1)                              
!                                                                       
      COMMON /MART/ RHH 
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
      COMMON /CNSTNS/ PI,CA,DEG,GCAIR,BIGNUM,BIGEXP 
      COMMON/A/T1QEXT(40,4),T2QEXT(40,4),T3QEXT(40,4),                  &
     &     T1QABS(40,4),T2QABS(40,4),T3QABS(40,4),ALAM(40),AREL(4)      
!                                                                       
!     C    COMMON/AER/A1, A2, A3        X(5)                            
!                                                                       
      DIMENSION WSPD(8), BEXT(5,47), BABS(5,47) 
      DIMENSION RHD(8) 
!                                                                       
      DATA WSPD/6.9, 4.1, 4.1, 10.29, 6.69, 12.35, 7.2, 6.9/ 
      DATA RHD/80., 75.63, 76.2, 77.13, 75.24, 80.53, 45.89, 80./ 
!                                                                       
      PISC = PI/1000.0 
      WRITE (IPR,900) 
!                                                                       
!     CHECK LIMITS OF MODEL VALIDITY                                    
!                                                                       
      RH = RHH 
      IF (RHH.GT.0.) GO TO 10 
      RH = RHD(MODEL+1) 
   10 WS = MIN(WS,20.) 
      WH = MIN(WH,20.) 
      RH = MIN(RH,98.) 
      IF (RH.LT.50.0.AND.RH.GE.0.0) RH = 50. 
      IF (ICSTL.LT.1.OR.ICSTL.GT.10) ICSTL = 3 
!                                                                       
!     FIND SIZE DISTRIBUTION PARAMETERS FROM METEOROLOGY INPUT          
!                                                                       
      IF (WH.LE.0.) WRITE (IPR,915) 
      IF (WH.LE.0.0) WH = WSPD(MODEL+1) 
      IF (WS.LE.0.) WRITE (IPR,920) 
      IF (WS.LE.0.0) WS = WH 
      WRITE (IPR,910) WS,WH,RH,ICSTL 
!                                                                       
!     F IS A RELATIVE HUMIDITY DEPENDENT GROWTH CORRECTION              
!     TO THE ATTENUATION COEFFICIENT.                                   
!                                                                       
      F = ((2.-RH/100.)/(6.*(1.-RH/100.)))**0.33333 
      A1 = 2000.0*ICSTL*ICSTL 
      A2 =   MAX(5.866*(WH-2.2),0.5) 
!                                                                       
!     CC   A3 =   MAX(0.01527*(WS-2.2), 1.14E-5)                        
!                                                                       
      A3 = 10**(0.06*WS-2.8) 
!                                                                       
!     FIND EXTINCTION AT 0.55 MICRONS AND NORMALIZE TO 1.               
!                                                                       
!     INTERPOLATE FOR RELATIVE HUMIDITY                                 
!                                                                       
      DO 20 J = 2, 4 
         IF (RH.LE.AREL(J)) GO TO 30 
   20 END DO 
   30 DELRH = AREL(J)-AREL(J-1) 
      DELRHV = RH-AREL(J-1) 
      RATIO = DELRHV/DELRH 
      QE1 = T1QEXT(4,J-1)+(T1QEXT(4,J)-T1QEXT(4,J-1))*RATIO 
      QE2 = T2QEXT(4,J-1)+(T2QEXT(4,J)-T2QEXT(4,J-1))*RATIO 
      QE3 = T3QEXT(4,J-1)+(T3QEXT(4,J)-T3QEXT(4,J-1))*RATIO 
      TOTAL = A1*10.**QE1+A2*10.**QE2+A3*10.**QE3 
      EXT55 = PISC*TOTAL/F 
!                                                                       
!     IF METEOROLOLICAL RANGE NOT SPECIFIED,FIND FROM METEOR DATA       
!                                                                       
      IF (VIS.LE.0.) VIS = 3.912/(EXT55+0.01159) 
      C = (1./EXT55)*(PISC/F) 
      A1 = C*A1 
      A2 = C*A2 
      A3 = C*A3 
!                                                                       
!     CALCULATE NORMALIZED ATTENUATION COEFICIENTS                      
!                                                                       
      DO 40 I = 1, 40 
         T1XV = T1QEXT(I,J-1)+(T1QEXT(I,J)-T1QEXT(I,J-1))*RATIO 
         T2XV = T2QEXT(I,J-1)+(T2QEXT(I,J)-T2QEXT(I,J-1))*RATIO 
         T3XV = T3QEXT(I,J-1)+(T3QEXT(I,J)-T3QEXT(I,J-1))*RATIO 
         T1AV = T1QABS(I,J-1)+(T1QABS(I,J)-T1QABS(I,J-1))*RATIO 
         T2AV = T2QABS(I,J-1)+(T2QABS(I,J)-T2QABS(I,J-1))*RATIO 
         T3AV = T3QABS(I,J-1)+(T3QABS(I,J)-T3QABS(I,J-1))*RATIO 
         BEXT(NL,I) = A1*10**(T1XV)+A2*10**(T2XV)+A3*10**(T3XV) 
         BABS(NL,I) = A1*10**(T1AV)+A2*10**(T2AV)+A3*10**(T3AV) 
   40 END DO 
      WRITE (IPR,905) VIS 
      RETURN 
!                                                                       
  900 FORMAT('0MARINE AEROSOL MODEL USED') 
  905 FORMAT('0',T10,'VIS = ',F10.2,' KM') 
  910 FORMAT(T10,'WIND SPEED = ',F8.2,' M/SEC',/,T10,                   &
     & 'WIND SPEED (24 HR AVERAGE) = ',F8.2,' M/SEC',/,                 &
     & T10,'RELATIVE HUMIDITY = ',F8.2,' PERCENT',/,                    &
     & T10,'AIRMASS CHARACTER =' ,I3)                                   
  915 FORMAT('0  WS NOT SPECIFIED, A DEFAULT VALUE IS USED') 
  920 FORMAT('0  WH NOT SPECIFIED, A DEFAULT VALUE IS USED') 
!                                                                       
      END                                           
      BLOCK DATA MARDTA 
!                                                                       
!     >    BLOCK DATA                                                   
!                                                                       
!     MARINE AEROSOL EXTINCTION AND ABSORPTION DATA                     
!     CODED BY STU GATHMAN                  -  NRL                      
!                                                                       
      COMMON/A/T1QEXT(40,4),T2QEXT(40,4),T3QEXT(40,4),                  &
     &T1QABS(40,4),T2QABS(40,4),T3QABS(40,4),ALAM(40),AREL(4)           
      DIMENSION A1(40),A2(40),A3(40),A4(40) 
      DIMENSION B1(40),B2(40),B3(40),B4(40) 
      DIMENSION C1(40),C2(40),C3(40),C4(40) 
      DIMENSION D1(40),D2(40),D3(40),D4(40) 
      DIMENSION E1(40),E2(40),E3(40),E4(40) 
      DIMENSION F1(40),F2(40),F3(40),F4(40) 
      EQUIVALENCE (A1(1), T1QEXT(1,1)), (A2(1), T1QEXT(1,2)),           &
     &            (A3(1), T1QEXT(1,3)), (A4(1), T1QEXT(1,4))            
      EQUIVALENCE (B1(1), T2QEXT(1,1)), (B2(1), T2QEXT(1,2)),           &
     &            (B3(1), T2QEXT(1,3)), (B4(1), T2QEXT(1,4))            
      EQUIVALENCE (C1(1), T3QEXT(1,1)), (C2(1), T3QEXT(1,2)),           &
     &            (C3(1), T3QEXT(1,3)), (C4(1), T3QEXT(1,4))            
      EQUIVALENCE (D1(1), T1QABS(1,1)), (D2(1), T1QABS(1,2)),           &
     &            (D3(1), T1QABS(1,3)), (D4(1), T1QABS(1,4))            
      EQUIVALENCE (E1(1), T2QABS(1,1)), (E2(1), T2QABS(1,2)),           &
     &            (E3(1), T2QABS(1,3)), (E4(1), T2QABS(1,4))            
      EQUIVALENCE (F1(1), T3QABS(1,1)), (F2(1), T3QABS(1,2)),           &
     &            (F3(1), T3QABS(1,3)), (F4(1), T3QABS(1,4))            
      DATA AREL/50.,85.,95.,98./ 
      DATA ALAM/                                                        &
     & 0.2000,   0.3000,   0.3371,   0.5500,   0.6943,   1.0600,        &
     & 1.5360,   2.0000,   2.2500,   2.5000,   2.7000,   3.0000,        &
     & 3.3923,   3.7500,   4.5000,   5.0000,   5.5000,   6.0000,        &
     & 6.2000,   6.5000,   7.2000,   7.9000,   8.2000,   8.7000,        &
     & 9.0000,   9.2000,  10.0000,  10.5910,  11.0000,  11.5000,        &
     &12.5000,  14.8000,  15.0000,  16.4000,  17.2000,  18.5000,        &
     &21.3000,  25.0000,  30.0000,  40.0000/                            
      DATA A1/                                                          &
     &-3.2949,  -3.4662,  -3.5275,  -3.8505,  -4.0388,  -4.4410,        &
     &-4.8584,  -5.1720,  -5.3272,  -5.4342,  -5.2765,  -4.5101,        &
     &-5.3730,  -5.7468,  -5.7579,  -5.8333,  -5.8552,  -5.1780,        &
     &-5.2910,  -5.5959,  -5.6295,  -5.6748,  -5.6051,  -5.5363,        &
     &-5.5330,  -5.5136,  -5.6568,  -5.6040,  -5.5221,  -5.3902,        &
     &-5.1724,  -5.0903,  -5.0901,  -5.1285,  -5.1444,  -5.1963,        &
     &-5.3101,  -5.3994,  -5.4873,  -5.4779/                            
      DATA A2/                                                          &
     &-2.8302,  -2.9446,  -2.9904,  -3.2510,  -3.4104,  -3.7635,        &
     &-4.1452,  -4.4466,  -4.6160,  -4.7772,  -4.7030,  -3.8461,        &
     &-4.6466,  -5.0105,  -5.0747,  -5.1810,  -5.2705,  -4.5537,        &
     &-4.6594,  -4.9872,  -5.0872,  -5.1229,  -5.0985,  -5.0623,        &
     &-5.0544,  -5.0407,  -5.0793,  -4.9796,  -4.8748,  -4.7298,        &
     &-4.5063,  -4.4260,  -4.4280,  -4.4650,  -4.4912,  -4.5474,        &
     &-4.6672,  -4.7711,  -4.8814,  -4.9073/                            
      DATA A3/                                                          &
     &-2.3712,  -2.4231,  -2.4512,  -2.6377,  -2.7631,  -3.0569,        &
     &-3.3918,  -3.6682,  -3.8305,  -4.0111,  -4.0467,  -3.2055,        &
     &-3.8717,  -4.1908,  -4.3282,  -4.4495,  -4.5780,  -3.9249,        &
     &-4.0136,  -4.3349,  -4.4674,  -4.5088,  -4.5083,  -4.4973,        &
     &-4.4923,  -4.4845,  -4.4753,  -4.3617,  -4.2509,  -4.1029,        &
     &-3.8779,  -3.7963,  -3.7989,  -3.8345,  -3.8639,  -3.9215,        &
     &-4.0438,  -4.1532,  -4.2719,  -4.3120/                            
      DATA A4/                                                          &
     &-1.9911,  -1.9989,  -2.0126,  -2.1342,  -2.2283,  -2.4663,        &
     &-2.7552,  -3.0036,  -3.1528,  -3.3328,  -3.4468,  -2.6649,        &
     &-3.1986,  -3.4769,  -3.6571,  -3.7821,  -3.9284,  -3.3776,        &
     &-3.4435,  -3.7436,  -3.8910,  -3.9455,  -3.9573,  -3.9633,        &
     &-3.9639,  -3.9610,  -3.9427,  -3.8304,  -3.7203,  -3.5733,        &
     &-3.3489,  -3.2650,  -3.2675,  -3.3017,  -3.3317,  -3.3893,        &
     &-3.5126,  -3.6243,  -3.7467,  -3.7927/                            
      DATA B1/                                                          &
     &-0.5781,  -0.5525,  -0.5484,  -0.5147,  -0.5094,  -0.5324,        &
     &-0.6138,  -0.7139,  -0.7776,  -0.8624,  -0.9838,  -0.7720,        &
     &-0.8542,  -0.9535,  -1.0873,  -1.1624,  -1.2647,  -1.2123,        &
     &-1.1811,  -1.2905,  -1.4126,  -1.4643,  -1.5227,  -1.4560,        &
     &-1.4177,  -1.4144,  -1.5746,  -1.6348,  -1.6431,  -1.6023,        &
     &-1.4648,  -1.3910,  -1.3898,  -1.4056,  -1.4196,  -1.4655,        &
     &-1.5795,  -1.6825,  -1.7924,  -1.8224/                            
      DATA B2/                                                          &
     &-0.1809,  -0.1651,  -0.1566,  -0.1258,  -0.1113,  -0.1046,        &
     &-0.1468,  -0.2157,  -0.2679,  -0.3480,  -0.4988,  -0.2657,        &
     &-0.2991,  -0.3924,  -0.5266,  -0.5983,  -0.7037,  -0.6671,        &
     &-0.6074,  -0.7134,  -0.8352,  -0.9080,  -0.9577,  -0.9579,        &
     &-0.9542,  -0.9629,  -1.0867,  -1.1219,  -1.1032,  -1.0330,        &
     &-0.8663,  -0.7677,  -0.7667,  -0.7768,  -0.7919,  -0.8304,        &
     &-0.9354,  -1.0400,  -1.1640,  -1.2357/                            
      DATA B3/                                                          &
     & 0.2483,   0.2574,   0.2626,   0.2887,   0.3055,   0.3312,        &
     & 0.3262,   0.2922,   0.2589,   0.1989,   0.0548,   0.2322,        &
     & 0.2487,   0.1816,   0.0685,   0.0090,  -0.0846,  -0.0876,        &
     &-0.0110,  -0.0936,  -0.2013,  -0.2799,  -0.3216,  -0.3575,        &
     &-0.3769,  -0.3944,  -0.5018,  -0.5379,  -0.5179,  -0.4473,        &
     &-0.2822,  -0.1730,  -0.1713,  -0.1737,  -0.1850,  -0.2141,        &
     &-0.3046,  -0.4002,  -0.5221,  -0.6163/                            
      DATA B4/                                                          &
     & 0.6276,   0.6324,   0.6363,   0.6570,   0.6715,   0.7006,        &
     & 0.7172,   0.7091,   0.6925,   0.6543,   0.5356,   0.6473,        &
     & 0.6924,   0.6516,   0.5661,   0.5206,   0.4440,   0.4091,        &
     & 0.4902,   0.4325,   0.3427,   0.2691,   0.2336,   0.1872,        &
     & 0.1593,   0.1386,   0.0348,  -0.0131,  -0.0031,   0.0566,        &
     & 0.2093,   0.3214,   0.3238,   0.3278,   0.3211,   0.3007,        &
     & 0.2257,   0.1426,   0.0304,  -0.0739/                            
      DATA C1/                                                          &
     & 2.1434,   2.1454,   2.1469,   2.1539,   2.1577,   2.1673,        &
     & 2.1812,   2.1970,   2.2030,   2.2115,   2.2149,   2.1931,        &
     & 2.2220,   2.2326,   2.2425,   2.2479,   2.2494,   2.2203,        &
     & 2.2382,   2.2473,   2.2380,   2.2373,   2.2179,   2.2310,        &
     & 2.2417,   2.2421,   2.2244,   2.1950,   2.1686,   2.1370,        &
     & 2.1193,   2.1454,   2.1477,   2.1703,   2.1725,   2.1729,        &
     & 2.1580,   2.1324,   2.0878,   2.0131/                            
      DATA C2/                                                          &
     & 2.5480,   2.5512,   2.5511,   2.5562,   2.5601,   2.5669,        &
     & 2.5792,   2.5874,   2.5950,   2.6022,   2.6081,   2.5875,        &
     & 2.6093,   2.6184,   2.6319,   2.6391,   2.6439,   2.6138,        &
     & 2.6319,   2.6437,   2.6442,   2.6421,   2.6336,   2.6336,        &
     & 2.6353,   2.6325,   2.6075,   2.5680,   2.5340,   2.5025,        &
     & 2.5122,   2.5652,   2.5681,   2.5869,   2.5925,   2.5986,        &
     & 2.5947,   2.5835,   2.5566,   2.4949/                            
      DATA C3/                                                          &
     & 2.9825,   2.9831,   2.9847,   2.9893,   2.9929,   2.9976,        &
     & 3.0090,   3.0130,   3.0179,   3.0233,   3.0294,   3.0148,        &
     & 3.0293,   3.0357,   3.0481,   3.0563,   3.0627,   3.0410,        &
     & 3.0532,   3.0646,   3.0713,   3.0733,   3.0716,   3.0701,        &
     & 3.0681,   3.0662,   3.0457,   3.0067,   2.9733,   2.9460,        &
     & 2.9643,   3.0156,   3.0182,   3.0337,   3.0399,   3.0477,        &
     & 3.0511,   3.0501,   3.0384,   2.9943/                            
      DATA C4/                                                          &
     & 3.3635,   3.3621,   3.3652,   3.3699,   3.3729,   3.3768,        &
     & 3.3868,   3.3888,   3.3916,   3.3952,   3.4000,   3.3911,        &
     & 3.4013,   3.4056,   3.4152,   3.4218,   3.4280,   3.4148,        &
     & 3.4222,   3.4312,   3.4393,   3.4442,   3.4452,   3.4463,        &
     & 3.4455,   3.4452,   3.4329,   3.4016,   3.3719,   3.3468,        &
     & 3.3617,   3.4046,   3.4068,   3.4198,   3.4255,   3.4334,        &
     & 3.4402,   3.4447,   3.4428,   3.4144/                            
      DATA D1/                                                          &
     &-7.7562,  -7.8498,  -7.8630,  -7.8493,  -7.7889,  -7.5044,        &
     &-7.0058,  -6.3955,  -6.3210,  -6.0026,  -5.4176,  -4.5443,        &
     &-5.6380,  -6.2635,  -5.9512,  -5.9860,  -5.9526,  -5.1907,        &
     &-5.3115,  -5.6289,  -5.6502,  -5.6922,  -5.6157,  -5.5462,        &
     &-5.5437,  -5.5234,  -5.6647,  -5.6087,  -5.5250,  -5.3918,        &
     &-5.1733,  -5.0909,  -5.0907,  -5.1291,  -5.1450,  -5.1968,        &
     &-5.3105,  -5.3997,  -5.4875,  -5.4779/                            
      DATA D2/                                                          &
     &-7.5869,  -7.6977,  -7.7070,  -7.6883,  -7.6227,  -7.2788,        &
     &-6.6637,  -5.9117,  -6.0351,  -5.6292,  -4.8814,  -3.8947,        &
     &-5.0236,  -5.7607,  -5.3390,  -5.4052,  -5.4335,  -4.5711,        &
     &-4.6910,  -5.0400,  -5.1263,  -5.1522,  -5.1200,  -5.0797,        &
     &-5.0708,  -5.0554,  -5.0883,  -4.9842,  -4.8775,  -4.7313,        &
     &-4.5074,  -4.4271,  -4.4290,  -4.4661,  -4.4923,  -4.5484,        &
     &-4.6679,  -4.7716,  -4.8817,  -4.9075/                            
      DATA D3/                                                          &
     &-7.3806,  -7.5324,  -7.5421,  -7.5190,  -7.4456,  -6.9683,        &
     &-6.1934,  -5.3374,  -5.6261,  -5.1328,  -4.2936,  -3.2785,        &
     &-4.3895,  -5.1770,  -4.7151,  -4.7944,  -4.8513,  -3.9542,        &
     &-4.0698,  -4.4296,  -4.5444,  -4.5647,  -4.5533,  -4.5320,        &
     &-4.5225,  -4.5111,  -4.4899,  -4.3685,  -4.2548,  -4.1053,        &
     &-3.8800,  -3.7987,  -3.8013,  -3.8369,  -3.8663,  -3.9238,        &
     &-4.0456,  -4.1545,  -4.2728,  -4.3123/                            
      DATA D4/                                                          &
     &-7.1591,  -7.3911,  -7.3998,  -7.3737,  -7.2891,  -6.6133,        &
     &-5.7137,  -4.8091,  -5.1828,  -4.6408,  -3.7712,  -2.7644,        &
     &-3.8361,  -4.6426,  -4.1724,  -4.2573,  -4.3263,  -3.4249,        &
     &-3.5341,  -3.8962,  -4.0222,  -4.0421,  -4.0386,  -4.0258,        &
     &-4.0169,  -4.0077,  -3.9676,  -3.8419,  -3.7270,  -3.5776,        &
     &-3.3529,  -3.2698,  -3.2724,  -3.3066,  -3.3365,  -3.3940,        &
     &-3.5164,  -3.6272,  -3.7486,  -3.7935/                            
      DATA E1/                                                          &
     &-4.1531,  -4.2017,  -4.0836,  -4.1441,  -4.0515,  -3.7234,        &
     &-3.2022,  -2.5924,  -2.5215,  -2.2244,  -1.7099,  -1.0243,        &
     &-1.8178,  -2.4304,  -2.1483,  -2.1897,  -2.1768,  -1.5025,        &
     &-1.5770,  -1.8688,  -1.9132,  -1.9550,  -1.9023,  -1.8200,        &
     &-1.8019,  -1.7822,  -1.9415,  -1.9082,  -1.8419,  -1.7290,        &
     &-1.5359,  -1.4523,  -1.4511,  -1.4744,  -1.4875,  -1.5339,        &
     &-1.6446,  -1.7377,  -1.8338,  -1.8404/                            
      DATA E2/                                                          &
     &-4.0237,  -4.0786,  -4.0596,  -4.0117,  -3.9167,  -3.5334,        &
     &-2.8890,  -2.1314,  -2.2533,  -1.8686,  -1.2114,  -0.5112,        &
     &-1.2226,  -1.9313,  -1.5503,  -1.6190,  -1.6646,  -0.9328,        &
     &-0.9892,  -1.2921,  -1.3909,  -1.4236,  -1.4060,  -1.3666,        &
     &-1.3550,  -1.3429,  -1.3966,  -1.3198,  -1.2346,  -1.1147,        &
     &-0.9248,  -0.8332,  -0.8328,  -0.8490,  -0.8658,  -0.9072,        &
     &-1.0110,  -1.1088,  -1.2210,  -1.2642/                            
      DATA E3/                                                          &
     &-3.8225,  -3.9189,  -3.8934,  -3.8788,  -3.7792,  -3.2584,        &
     &-2.4500,  -1.5859,  -1.8664,  -1.3920,  -0.6602,  -0.0250,        &
     &-0.6305,  -1.3614,  -0.9442,  -1.0200,  -1.0892,  -0.3681,        &
     &-0.4088,  -0.6976,  -0.8140,  -0.8430,  -0.8410,  -0.8268,        &
     &-0.8209,  -0.8142,  -0.8176,  -0.7305,  -0.6447,  -0.5305,        &
     &-0.3534,  -0.2582,  -0.2574,  -0.2661,  -0.2802,  -0.3137,        &
     &-0.4046,  -0.4954,  -0.6063,  -0.6635/                            
      DATA E4/                                                          &
     &-3.6380,  -3.8218,  -3.8158,  -3.6544,  -3.6442,  -2.9366,        &
     &-1.9981,  -1.0852,  -1.4468,  -0.9222,  -0.1746,   0.3789,        &
     &-0.1326,  -0.8516,  -0.4270,  -0.5021,  -0.5774,   0.1072,        &
     & 0.0779,  -0.1890,  -0.3060,  -0.3330,  -0.3362,  -0.3320,        &
     &-0.3290,  -0.3248,  -0.3123,  -0.2275,  -0.1469,  -0.0421,        &
     & 0.1192,   0.2136,   0.2149,   0.2122,   0.2019,   0.1760,        &
     & 0.0989,   0.0190,  -0.0836,  -0.1437/                            
      DATA F1/                                                          &
     &-0.5486,  -0.6082,  -0.5956,  -0.5356,  -0.4402,  -0.0871,        &
     & 0.4527,   1.0366,   1.1096,   1.3655,   1.7101,   1.8903,        &
     & 1.6543,   1.2291,   1.4722,   1.4553,   1.4742,   1.8427,        &
     & 1.8260,   1.6925,   1.6714,   1.6561,   1.6818,   1.7408,        &
     & 1.7604,   1.7735,   1.6870,   1.6975,   1.7266,   1.7732,        &
     & 1.8476,   1.8953,   1.8977,   1.9100,   1.9121,   1.9074,        &
     & 1.8820,   1.8553,   1.8167,   1.8034/                            
      DATA F2/                                                          &
     &-0.4081,  -0.4784,  -0.4660,  -0.4117,  -0.3046,   0.0831,        &
     & 0.7409,   1.4609,   1.3780,   1.7134,   2.1471,   2.2808,        &
     & 2.1315,   1.6742,   1.9804,   1.9449,   1.9238,   2.2748,        &
     & 2.2689,   2.1587,   2.1154,   2.1037,   2.1124,   2.1387,        &
     & 2.1490,   2.1552,   2.1238,   2.1535,   2.1840,   2.2226,        &
     & 2.2790,   2.3247,   2.3268,   2.3387,   2.3422,   2.3439,        &
     & 2.3339,   2.3198,   2.2926,   2.2751/                            
      DATA F3/                                                          &
     &-0.2242,  -0.3289,  -0.3406,  -0.2786,  -0.1532,   0.3414,        &
     & 1.1618,   1.9783,   1.7412,   2.1629,   2.6182,   2.6999,        &
     & 2.6101,   2.1844,   2.4931,   2.4589,   2.4253,   2.7204,        &
     & 2.7182,   2.6391,   2.5975,   2.5896,   2.5918,   2.6017,        &
     & 2.6055,   2.6086,   2.6049,   2.6334,   2.6574,   2.6843,        &
     & 2.7225,   2.7601,   2.7620,   2.7734,   2.7780,   2.7832,        &
     & 2.7839,   2.7809,   2.7677,   2.7571/                            
      DATA F4/                                                          &
     &-0.0119,  -0.2110,  -0.2063,  -0.1444,  -0.0667,   0.6542,        &
     & 1.5923,   2.4405,   2.1326,   2.5924,   3.0247,   3.0696,        &
     & 3.0154,   2.6365,   2.9257,   2.8957,   2.8634,   3.1026,        &
     & 3.1009,   3.0465,   3.0135,   3.0090,   3.0097,   3.0147,        &
     & 3.0167,   3.0193,   3.0233,   3.0464,   3.0635,   3.0808,        &
     & 3.1047,   3.1337,   3.1354,   3.1458,   3.1506,   3.1572,        &
     & 3.1639,   3.1680,   3.1651,   3.1624/                            
      END                                           
!                                                                       
!     *************************************************************     
!                                                                       
      SUBROUTINE LCONVR (P,T) 
!                                                                       
!     *************************************************************     
!                                                                       
!     WRITTEN APR, 1985 TO ACCOMMODATE 'JCHAR' DEFINITIONS FOR          
!     UNIFORM DATA INPUT -                                              
!                                                                       
!     JCHAR    JUNIT                                                    
!                                                                       
!     " ",A       10    VOLUME MIXING RATIO (PPMV)                      
!     B       11    NUMBER DENSITY (CM-3)                               
!     C       12    MASS MIXING RATIO (GM(K)/KG(AIR))                   
!     D       13    MASS DENSITY (GM M-3)                               
!     E       14    PARTIAL PRESSURE (MB)                               
!     F       15    DEW POINT TEMP (TD IN T(K)) - H2O ONLY              
!     G       16     "    "     "  (TD IN T(C)) - H2O ONLY              
!     H       17    RELATIVE HUMIDITY (RH IN PERCENT) - H2O ONLY        
!     I       18    AVAILABLE FOR USER DEFINITION                       
!     J       19    REQUEST DEFAULT TO SPECIFIED MODEL ATMOSPHERE       
!                                                                       
!     ***************************************************************   
!                                                                       
      USE planet_consts, ONLY: airmwt
      USE phys_consts, ONLY: avogad, alosmt
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
      PARAMETER (NCASE=15, NCASE2=NCASE-2) 
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
      COMMON /CONSTL/ PZERO,TZERO,ADCON,ALZERO,AVMWT,AMWT(MXMOL) 
      COMMON /CARD1B/ JUNITP,JUNITT,JUNIT1(NCASE2),WMOL1(NCASE),        &
     &                WAIR1,JLOW                                        
!                                                                       
      DATA C1/18.9766/,C2/-14.9595/,C3/-2.43882/ 
!                                                                       
!      DENSAT(ATEMP) = ATEMP*B*EXP(C1+C2*ATEMP+C3*ATEMP**2)*1.0E-6      
!                                                                       
      RHOAIR = ALOSMT*(P/PZERO)*(TZERO/T) 
!                                                                       
!     NOPRNT = 0                                                        
!     A = TZERO/T                                                       
!                                                                       
      DO 70 K = 1, 12 
         B = AVOGAD/AMWT(K) 
         R = AIRMWT/AMWT(K) 
         JUNIT = JUNIT1(K) 
         WMOL = WMOL1(K) 
         IF (K.NE.1) GO TO 10 
         CALL LWATVA (P,T) 
         GO TO 70 
   10    CONTINUE 
         IF (JUNIT.GT.10) GO TO 20 
!                                                                       
!        **   GIVEN VOL. MIXING RATIO                                   
!                                                                       
!        C    WMOL1(K)=WMOL*RHOAIR*1.E-6                                
!                                                                       
         GO TO 70 
   20    IF (JUNIT.NE.11) GO TO 30 
!                                                                       
!        **   GIVEN NUMBER DENSITY (CM-3)                               
!                                                                       
!        C    WMOL1(K) = WMOL                                           
!                                                                       
         WMOL1(K) = WMOL/(RHOAIR*1.E-6) 
         GO TO 70 
   30    CONTINUE 
         IF (JUNIT.NE.12) GO TO 40 
!                                                                       
!        **   GIVEN MASS MIXING RATIO (GM KG-1)                         
!                                                                       
!        C    WMOL1(K)= R*WMOL*1.0E-3*RHOAIR                            
!                                                                       
         WMOL1(K) = R*WMOL*1.0E+3 
         GO TO 70 
   40    CONTINUE 
         IF (JUNIT.NE.13) GO TO 50 
!                                                                       
!        **   GIVEN MASS DENSITY (GM M-3)                               
!                                                                       
!        C    WMOL1(K) = B*WMOL*1.0E-6                                  
!                                                                       
         WMOL1(K) = B*WMOL/RHOAIR 
         GO TO 70 
   50    CONTINUE 
         IF (JUNIT.NE.14) GO TO 60 
!                                                                       
!        **   GIVEN  PARTIAL PRESSURE (MB)                              
!                                                                       
!        C    WMOL1(K)= ALOSMT*(WMOL/PZERO)*(TZERO/T)                   
!                                                                       
         WTEM = ALOSMT*(WMOL/PZERO)*(TZERO/T) 
         WMOL1(K) = WTEM/(RHOAIR*1.E-6) 
         GO TO 70 
   60    CONTINUE 
         IF (JUNIT.GT.14) GO TO 80 
   70 END DO 
      RETURN 
   80 CONTINUE 
      WRITE (IPR,900) JUNIT 
      STOP 
!                                                                       
  900 FORMAT(/,'   **** ERROR IN CONVERT ****, JUNIT = ',I5) 
!                                                                       
      END                                           
!                                                                       
!     *************************************************************     
!                                                                       
      SUBROUTINE LWATVA(P,T) 
!                                                                       
!     *************************************************************     
!                                                                       
!     WRITTEN APR, 1985 TO ACCOMMODATE 'JCHAR' DEFINITIONS FOR          
!     UNIFORM DATA INPUT -                                              
!                                                                       
!     JCHAR    JUNIT                                                    
!                                                                       
!     " ",A       10    VOLUME MIXING RATIO (PPMV)                      
!     B       11    NUMBER DENSITY (CM-3)                               
!     C       12    MASS MIXING RATIO (GM(K)/KG(AIR))                   
!     D       13    MASS DENSITY (GM M-3)                               
!     E       14    PARTIAL PRESSURE (MB)                               
!     F       15    DEW POINT TEMP (TD IN T(K)) - H2O ONLY              
!     G       16     "    "     "  (TD IN T(C)) - H2O ONLY              
!     H       17    RELATIVE HUMIDITY (RH IN PERCENT) - H2O ONLY        
!     I       18    AVAILABLE FOR USER DEFINITION                       
!     J       19    REQUEST DEFAULT TO SPECIFIED MODEL ATMOSPHERE       
!                                                                       
!     THIS SUBROUTINE COMPUTES THE WATERVAPOR NUMBER DENSITY (MOL CM-3) 
!     GIVE HUMIDITY  # TD = DEW POINT TEMP(K,C), RH = RELATIVE          
!     (PERCENT), PPH2O = WATER VAPOR PARTIAL PRESSURE (MB), DENH2O =    
!     WATER VAPOR MASS DENSITY (GM M-3),AMSMIX = MASS MIXING RATIO      
!     (GM/KG).                                                          
!     THE FUNCTION DENSAT FOR THE SATURATION                            
!     WATER VAPOR DENSITY OVER WATER IS ACCURATE TO BETTER THAN 1       
!     PERCENT FROM -50 TO +50 DEG C. (SEE THE LOWTRAN3 OR 5 REPORT)     
!                                                                       
!     'JUNIT' GOVERNS CHOICE OF UNITS -                                 
!                                                                       
!     ******************************************************************
!                                                                       
      USE planet_consts, ONLY: airmwt
      USE phys_consts, ONLY: avogad, alosmt
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
      PARAMETER (NCASE=15, NCASE2=NCASE-2) 
!                                                                       
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
      COMMON /CARD1B/ JUNITP,JUNITT,JUNIT1(NCASE2),WMOL1(NCASE),        &
     &                WAIR,JLOW                                         
      COMMON /CONSTL/ PZERO,TZERO,ADCON,ALZERO,AVMWT,AMWT(MXMOL) 
!                                                                       
      DATA C1/18.9766/,C2/-14.9595/,C3/-2.43882/ 
      DATA XLOSCH/2.6868E19/ 
!                                                                       
      DENSAT(ATEMP) = ATEMP*B*EXP(C1+C2*ATEMP+C3*ATEMP**2)*1.0E-6 
!                                                                       
      RHOAIR = ALOSMT*(P/PZERO)*(TZERO/T) 
      PSS = P/PZERO 
      A = TZERO/T 
      WAIR = XLOSCH*PSS*A 
      B = AVOGAD/AMWT(1) 
      R = AIRMWT/AMWT(1) 
      JUNIT = JUNIT1(1) 
      WMOL = WMOL1(1) 
      IF (JUNIT.NE.10) GO TO 10 
!                                                                       
!     **   GIVEN VOL. MIXING RATIO                                      
!                                                                       
!     C    WMOL1(1)=WMOL*RHOAIR*1.E-6                                   
!                                                                       
      GO TO 90 
   10 IF (JUNIT.NE.11) GO TO 20 
!                                                                       
!     **   GIVEN NUMBER DENSITY (CM-3)                                  
!                                                                       
      WMOL1(1) = WMOL/(RHOAIR*1.E-6) 
      GO TO 90 
   20 CONTINUE 
      IF (JUNIT.NE.12) GO TO 30 
!                                                                       
!     **   GIVEN MASS MIXING RATIO (GM KG-1)                            
!                                                                       
!     C    WMOL1(1) = R*WMOL*1.0E-3*RHOAIR                              
!                                                                       
      WMOL1(1) = R*WMOL*1.0E+3 
      GO TO 90 
   30 CONTINUE 
      IF (JUNIT.NE.13) GO TO 40 
!                                                                       
!     **   GIVEN MASS DENSITY (GM M-3)                                  
!                                                                       
!     C    WMOL1(1) = B*WMOL*1.0E-6                                     
!                                                                       
      WMOL1(1) = B*WMOL/RHOAIR 
      GO TO 90 
   40 CONTINUE 
      IF (JUNIT.NE.14) GO TO 50 
!                                                                       
!     **   GIVEN WATER VAPOR PARTIAL PRESSURE (MB)                      
!                                                                       
!     C    WMOL1(1) = ALOSMT*(WMOL/PZERO)*(TZERO/T)                     
!                                                                       
      WTEM = ALOSMT*(WMOL/PZERO)*(TZERO/T) 
      WMOL1(1) = WTEM/(RHOAIR*1.E-6) 
      GO TO 90 
   50 CONTINUE 
      IF (JUNIT.NE.15) GO TO 60 
!                                                                       
!     **   GIVEN DEWPOINT (DEG K)                                       
!                                                                       
      ATD = TZERO/(WMOL) 
!                                                                       
!     C    WMOL1(1)= DENSAT(ATD)*(WMOL)/T                               
!                                                                       
      WTEM = DENSAT(ATD)*(WMOL)/T 
      WMOL1(1) = WTEM/(RHOAIR*1.E-6) 
      GO TO 90 
   60 CONTINUE 
      IF (JUNIT.NE.16) GO TO 70 
!                                                                       
!     **   GIVEN DEWPOINT (DEG C)                                       
!                                                                       
      ATD = TZERO/(TZERO+WMOL) 
!                                                                       
!     C    WMOL1(1) = DENSAT(ATD)*(TZERO+WMOL)/T                        
!                                                                       
      WTEM = DENSAT(ATD)*(TZERO+WMOL)/T 
      WMOL1(1) = WTEM/(RHOAIR*1.E-6) 
      GO TO 90 
   70 CONTINUE 
      IF (JUNIT.NE.17) GO TO 80 
!                                                                       
!     **   GIVEN RELATIVE HUMIDITY (PERCENT)                            
!                                                                       
!     DENNUM = DENSAT(A)*(WMOL/100.0)/(1.0-(1.0-WMOL/100.0)*DENSAT(A)/  
!     1    RHOAIR)                                                      
!     C    WMOL1(1) = DENSAT(A)*(WMOL/100.0)                            
!                                                                       
      WTEM = DENSAT(A)*(WMOL/100.0) 
      WMOL1(1) = WTEM/(RHOAIR*1.E-6) 
      GO TO 90 
   80 WRITE (IPR,900) JUNIT 
      STOP 'JUNIT' 
   90 CONTINUE 
      WMOL1(1) = 2.989E-23*WMOL1(1)*WAIR 
      DENST = DENSAT(A) 
      DENNUM = WMOL1(1) 
!                                                                       
!     RHP = 100.0*(DENNUM/DENST)*((RHOAIR-DENST)/(RHOAIR-DENNUM))       
!                                                                       
      RHP = 100.0*(DENNUM/DENST) 
      IF (RHP.LE.100.0) GO TO 100 
      WRITE (IPR,905) RHP 
  100 CONTINUE 
      RETURN 
!                                                                       
  900 FORMAT(/,'  **** ERROR IN WATVAP ****, JUNIT = ',I5) 
  905 FORMAT(/,' ********WARNING (FROM WATVAP) # RELATIVE HUMIDTY = ',  &
     &    G10.3,' IS GREATER THAN 100 PERCENT')                         
!                                                                       
      END                                           
      BLOCK DATA MLATLB 
!                                                                       
!     ******************************************************************
!     THIS SUBROUTINE INITIALIZES THE 6 BUILT-IN ATMOSPHERIC PROFILES   
!     (FROM 'OPTICAL PROPERTIES OF THE ATMOSPHERE, THIRD EDITION'       
!     AFCRL-72-0497 (AD 753 075), 'U.S. STANDARD ATMOSPHERE 1976' AND   
!     'SUPPLEMENTS 1966'), PLUS COLLECTED CONSTITUENT PROFILES (REF)    
!     AND SETS OTHER CONSTANTS RELATED TO THE ATMOSPHERIC PROFILES      
!     ******************************************************************
!                                                                       
      parameter (mxmol=47) 
                                                                        
      CHARACTER*8 CTMNA1,CTMNA2,CTMNA3,CTMNA4,CTMNA5,CTMNA6 
      COMMON /CLATML/                                                   &
     &CTMNA1(3),CTMNA2(3),CTMNA3(3),CTMNA4(3),CTMNA5(3),CTMNA6(3)       
      REAL*8           ATMNA1,ATMNA2,ATMNA3,ATMNA4,ATMNA5,ATMNA6 
      Character*8                                                HMODS 
      COMMON /MLATML/ ALT(50),P1(50),P2(50),P3(50),P4(50),P5(50),P6(50),&
     &T1(50),T2(50),T3(50),T4(50),T5(50),T6(50),                        &
     &AMOL11(50),AMOL12(50),AMOL13(50),AMOL14(50),AMOL15(50),AMOL16(50),&
     &AMOL17(50),AMOL18(50),                                            &
     &AMOL21(50),AMOL22(50),AMOL23(50),AMOL24(50),AMOL25(50),AMOL26(50),&
     &AMOL27(50),AMOL28(50),                                            &
     &AMOL31(50),AMOL32(50),AMOL33(50),AMOL34(50),AMOL35(50),AMOL36(50),&
     &AMOL37(50),AMOL38(50),                                            &
     &AMOL41(50),AMOL42(50),AMOL43(50),AMOL44(50),AMOL45(50),AMOL46(50),&
     &AMOL47(50),AMOL48(50),                                            &
     &AMOL51(50),AMOL52(50),AMOL53(50),AMOL54(50),AMOL55(50),AMOL56(50),&
     &AMOL57(50),AMOL58(50),                                            &
     &AMOL61(50),AMOL62(50),AMOL63(50),AMOL64(50),AMOL65(50),AMOL66(50),&
     &AMOL67(50),AMOL68(50),                                            &
     &ATMNA1(3),ATMNA2(3),ATMNA3(3),ATMNA4(3),ATMNA5(3),ATMNA6(3),      &
     &     HMODS(3),ZST(50),PST(50),TST(50),AMOLS(50,mxmol),IDUM        
!                                                                       
!     COMMON /TRACL/ TRAC(50,22)                                        
!                                                                       
      COMMON /TRACL/ ANO(50),SO2(50),ANO2(50),ANH3(50),HNO3(50),OH(50), &
     & HF(50),HCL(50),HBR(50),HI(50),CLO(50),OCS(50),H2CO(50),          &
     & HOCL(50),AN2(50),HCN(50),CH3CL(50),H2O2(50),C2H2(50),            &
     & C2H6(50),PH3(50), COF2(50), SF6(50), H2S(50),                   &
     & HCOOH(50), HO2(50), O(50), CLONO2(50),                           &
     & NOPLUS(50), HOBr(50), C2H4(50), CH3OH(50),                       &
     & CH3BR(50), CH3CN(50), CF4(50), C4H2(50),                         &
     & HC3N(50), H2(50), CS(50), SO3(50),                               &
     & TDUM(50)    
                                         
      DATA CTMNA1  /'TROPICAL','        ','        '/ 
      DATA CTMNA2  /'MIDLATIT','UDE SUMM','ER      '/ 
      DATA CTMNA3  /'MIDLATIT','UDE WINT','ER      '/ 
      DATA CTMNA4  /'SUBARCTI','C SUMMER','        '/ 
      DATA CTMNA5  /'SUBARCTI','C WINTER','        '/ 
      DATA CTMNA6  /'U. S. ST','ANDARD, ','1976    '/ 
!                                                                       
!     DATA ALT (KM)  /                                                  
!                                                                       
      DATA ALT/                                                         &
     &       0.0,       1.0,       2.0,       3.0,       4.0,           &
     &       5.0,       6.0,       7.0,       8.0,       9.0,           &
     &      10.0,      11.0,      12.0,      13.0,      14.0,           &
     &      15.0,      16.0,      17.0,      18.0,      19.0,           &
     &      20.0,      21.0,      22.0,      23.0,      24.0,           &
     &      25.0,      27.5,      30.0,      32.5,      35.0,           &
     &      37.5,      40.0,      42.5,      45.0,      47.5,           &
     &      50.0,      55.0,      60.0,      65.0,      70.0,           &
     &      75.0,      80.0,      85.0,      90.0,      95.0,           &
     &     100.0,     105.0,     110.0,     115.0,     120.0/           
!                                                                       
!     DATA PRESSURE  /                                                  
!                                                                       
      DATA P1/                                                          &
     & 1.013E+03, 9.040E+02, 8.050E+02, 7.150E+02, 6.330E+02,           &
     & 5.590E+02, 4.920E+02, 4.320E+02, 3.780E+02, 3.290E+02,           &
     & 2.860E+02, 2.470E+02, 2.130E+02, 1.820E+02, 1.560E+02,           &
     & 1.320E+02, 1.110E+02, 9.370E+01, 7.890E+01, 6.660E+01,           &
     & 5.650E+01, 4.800E+01, 4.090E+01, 3.500E+01, 3.000E+01,           &
     & 2.570E+01, 1.763E+01, 1.220E+01, 8.520E+00, 6.000E+00,           &
     & 4.260E+00, 3.050E+00, 2.200E+00, 1.590E+00, 1.160E+00,           &
     & 8.540E-01, 4.560E-01, 2.390E-01, 1.210E-01, 5.800E-02,           &
     & 2.600E-02, 1.100E-02, 4.400E-03, 1.720E-03, 6.880E-04,           &
     & 2.890E-04, 1.300E-04, 6.470E-05, 3.600E-05, 2.250E-05/           
      DATA P2/                                                          &
     & 1.013E+03, 9.020E+02, 8.020E+02, 7.100E+02, 6.280E+02,           &
     & 5.540E+02, 4.870E+02, 4.260E+02, 3.720E+02, 3.240E+02,           &
     & 2.810E+02, 2.430E+02, 2.090E+02, 1.790E+02, 1.530E+02,           &
     & 1.300E+02, 1.110E+02, 9.500E+01, 8.120E+01, 6.950E+01,           &
     & 5.950E+01, 5.100E+01, 4.370E+01, 3.760E+01, 3.220E+01,           &
     & 2.770E+01, 1.907E+01, 1.320E+01, 9.300E+00, 6.520E+00,           &
     & 4.640E+00, 3.330E+00, 2.410E+00, 1.760E+00, 1.290E+00,           &
     & 9.510E-01, 5.150E-01, 2.720E-01, 1.390E-01, 6.700E-02,           &
     & 3.000E-02, 1.200E-02, 4.480E-03, 1.640E-03, 6.250E-04,           &
     & 2.580E-04, 1.170E-04, 6.110E-05, 3.560E-05, 2.270E-05/           
      DATA P3/                                                          &
     & 1.018E+03, 8.973E+02, 7.897E+02, 6.938E+02, 6.081E+02,           &
     & 5.313E+02, 4.627E+02, 4.016E+02, 3.473E+02, 2.993E+02,           &
     & 2.568E+02, 2.199E+02, 1.882E+02, 1.611E+02, 1.378E+02,           &
     & 1.178E+02, 1.007E+02, 8.610E+01, 7.360E+01, 6.280E+01,           &
     & 5.370E+01, 4.580E+01, 3.910E+01, 3.340E+01, 2.860E+01,           &
     & 2.440E+01, 1.646E+01, 1.110E+01, 7.560E+00, 5.180E+00,           &
     & 3.600E+00, 2.530E+00, 1.800E+00, 1.290E+00, 9.400E-01,           &
     & 6.830E-01, 3.620E-01, 1.880E-01, 9.500E-02, 4.700E-02,           &
     & 2.220E-02, 1.030E-02, 4.560E-03, 1.980E-03, 8.770E-04,           &
     & 4.074E-04, 2.000E-04, 1.057E-04, 5.980E-05, 3.600E-05/           
      DATA P4/                                                          &
     & 1.010E+03, 8.960E+02, 7.929E+02, 7.000E+02, 6.160E+02,           &
     & 5.410E+02, 4.740E+02, 4.130E+02, 3.590E+02, 3.108E+02,           &
     & 2.677E+02, 2.300E+02, 1.977E+02, 1.700E+02, 1.460E+02,           &
     & 1.260E+02, 1.080E+02, 9.280E+01, 7.980E+01, 6.860E+01,           &
     & 5.900E+01, 5.070E+01, 4.360E+01, 3.750E+01, 3.228E+01,           &
     & 2.780E+01, 1.923E+01, 1.340E+01, 9.400E+00, 6.610E+00,           &
     & 4.720E+00, 3.400E+00, 2.480E+00, 1.820E+00, 1.340E+00,           &
     & 9.870E-01, 5.370E-01, 2.880E-01, 1.470E-01, 7.100E-02,           &
     & 3.200E-02, 1.250E-02, 4.510E-03, 1.610E-03, 6.060E-04,           &
     & 2.480E-04, 1.130E-04, 6.000E-05, 3.540E-05, 2.260E-05/           
      DATA P5/                                                          &
     & 1.013E+03, 8.878E+02, 7.775E+02, 6.798E+02, 5.932E+02,           &
     & 5.158E+02, 4.467E+02, 3.853E+02, 3.308E+02, 2.829E+02,           &
     & 2.418E+02, 2.067E+02, 1.766E+02, 1.510E+02, 1.291E+02,           &
     & 1.103E+02, 9.431E+01, 8.058E+01, 6.882E+01, 5.875E+01,           &
     & 5.014E+01, 4.277E+01, 3.647E+01, 3.109E+01, 2.649E+01,           &
     & 2.256E+01, 1.513E+01, 1.020E+01, 6.910E+00, 4.701E+00,           &
     & 3.230E+00, 2.243E+00, 1.570E+00, 1.113E+00, 7.900E-01,           &
     & 5.719E-01, 2.990E-01, 1.550E-01, 7.900E-02, 4.000E-02,           &
     & 2.000E-02, 9.660E-03, 4.500E-03, 2.022E-03, 9.070E-04,           &
     & 4.230E-04, 2.070E-04, 1.080E-04, 6.000E-05, 3.590E-05/           
      DATA P6/                                                          &
     & 1.013E+03, 8.988E+02, 7.950E+02, 7.012E+02, 6.166E+02,           &
     & 5.405E+02, 4.722E+02, 4.111E+02, 3.565E+02, 3.080E+02,           &
     & 2.650E+02, 2.270E+02, 1.940E+02, 1.658E+02, 1.417E+02,           &
     & 1.211E+02, 1.035E+02, 8.850E+01, 7.565E+01, 6.467E+01,           &
     & 5.529E+01, 4.729E+01, 4.047E+01, 3.467E+01, 2.972E+01,           &
     & 2.549E+01, 1.743E+01, 1.197E+01, 8.010E+00, 5.746E+00,           &
     & 4.150E+00, 2.871E+00, 2.060E+00, 1.491E+00, 1.090E+00,           &
     & 7.978E-01, 4.250E-01, 2.190E-01, 1.090E-01, 5.220E-02,           &
     & 2.400E-02, 1.050E-02, 4.460E-03, 1.840E-03, 7.600E-04,           &
     & 3.200E-04, 1.450E-04, 7.100E-05, 4.010E-05, 2.540E-05/           
!                                                                       
!     DATA TEMPERATUR/                                                  
!                                                                       
      DATA T1/                                                          &
     &    299.70,    293.70,    287.70,    283.70,    277.00,           &
     &    270.30,    263.60,    257.00,    250.30,    243.60,           &
     &    237.00,    230.10,    223.60,    217.00,    210.30,           &
     &    203.70,    197.00,    194.80,    198.80,    202.70,           &
     &    206.70,    210.70,    214.60,    217.00,    219.20,           &
     &    221.40,    227.00,    232.30,    237.70,    243.10,           &
     &    248.50,    254.00,    259.40,    264.80,    269.60,           &
     &    270.20,    263.40,    253.10,    236.00,    218.90,           &
     &    201.80,    184.80,    177.10,    177.00,    184.30,           &
     &    190.70,    212.00,    241.60,    299.70,    380.00/           
      DATA T2/                                                          &
     &    294.20,    289.70,    285.20,    279.20,    273.20,           &
     &    267.20,    261.20,    254.70,    248.20,    241.70,           &
     &    235.30,    228.80,    222.30,    215.80,    215.70,           &
     &    215.70,    215.70,    215.70,    216.80,    217.90,           &
     &    219.20,    220.40,    221.60,    222.80,    223.90,           &
     &    225.10,    228.45,    233.70,    239.00,    245.20,           &
     &    251.30,    257.50,    263.70,    269.90,    275.20,           &
     &    275.70,    269.30,    257.10,    240.10,    218.10,           &
     &    196.10,    174.10,    165.10,    165.00,    178.30,           &
     &    190.50,    222.20,    262.40,    316.80,    380.00/           
      DATA T3/                                                          &
     &    272.20,    268.70,    265.20,    261.70,    255.70,           &
     &    249.70,    243.70,    237.70,    231.70,    225.70,           &
     &    219.70,    219.20,    218.70,    218.20,    217.70,           &
     &    217.20,    216.70,    216.20,    215.70,    215.20,           &
     &    215.20,    215.20,    215.20,    215.20,    215.20,           &
     &    215.20,    215.50,    217.40,    220.40,    227.90,           &
     &    235.50,    243.20,    250.80,    258.50,    265.10,           &
     &    265.70,    260.60,    250.80,    240.90,    230.70,           &
     &    220.40,    210.10,    199.80,    199.50,    208.30,           &
     &    218.60,    237.10,    259.50,    293.00,    333.00/           
      DATA T4/                                                          &
     &    287.20,    281.70,    276.30,    270.90,    265.50,           &
     &    260.10,    253.10,    246.10,    239.20,    232.20,           &
     &    225.20,    225.20,    225.20,    225.20,    225.20,           &
     &    225.20,    225.20,    225.20,    225.20,    225.20,           &
     &    225.20,    225.20,    225.20,    225.20,    226.60,           &
     &    228.10,    231.00,    235.10,    240.00,    247.20,           &
     &    254.60,    262.10,    269.50,    273.60,    276.20,           &
     &    277.20,    274.00,    262.70,    239.70,    216.60,           &
     &    193.60,    170.60,    161.70,    161.60,    176.80,           &
     &    190.40,    226.00,    270.10,    322.70,    380.00/           
      DATA T5/                                                          &
     &    257.20,    259.10,    255.90,    252.70,    247.70,           &
     &    240.90,    234.10,    227.30,    220.60,    217.20,           &
     &    217.20,    217.20,    217.20,    217.20,    217.20,           &
     &    217.20,    216.60,    216.00,    215.40,    214.80,           &
     &    214.20,    213.60,    213.00,    212.40,    211.80,           &
     &    211.20,    213.60,    216.00,    218.50,    222.30,           &
     &    228.50,    234.70,    240.80,    247.00,    253.20,           &
     &    259.30,    259.10,    250.90,    248.40,    245.40,           &
     &    234.70,    223.90,    213.10,    202.30,    211.00,           &
     &    218.50,    234.00,    252.60,    288.50,    333.00/           
      DATA T6/                                                          &
     &    288.20,    281.70,    275.20,    268.70,    262.20,           &
     &    255.70,    249.20,    242.70,    236.20,    229.70,           &
     &    223.30,    216.80,    216.70,    216.70,    216.70,           &
     &    216.70,    216.70,    216.70,    216.70,    216.70,           &
     &    216.70,    217.60,    218.60,    219.60,    220.60,           &
     &    221.60,    224.00,    226.50,    230.00,    236.50,           &
     &    242.90,    250.40,    257.30,    264.20,    270.60,           &
     &    270.70,    260.80,    247.00,    233.30,    219.60,           &
     &    208.40,    198.60,    188.90,    186.90,    188.40,           &
     &    195.10,    208.80,    240.00,    300.00,    360.00/           
!                                                                       
!     DATA  H2O      /                                                  
!                                                                       
      DATA AMOL11/                                                      &
     & 2.593E+04, 1.949E+04, 1.534E+04, 8.600E+03, 4.441E+03,           &
     & 3.346E+03, 2.101E+03, 1.289E+03, 7.637E+02, 4.098E+02,           &
     & 1.912E+02, 7.306E+01, 2.905E+01, 9.900E+00, 6.220E+00,           &
     & 4.000E+00, 3.000E+00, 2.900E+00, 2.750E+00, 2.600E+00,           &
     & 2.600E+00, 2.650E+00, 2.800E+00, 2.900E+00, 3.200E+00,           &
     & 3.250E+00, 3.600E+00, 4.000E+00, 4.300E+00, 4.600E+00,           &
     & 4.900E+00, 5.200E+00, 5.500E+00, 5.700E+00, 5.900E+00,           &
     & 6.000E+00, 6.000E+00, 6.000E+00, 5.400E+00, 4.500E+00,           &
     & 3.300E+00, 2.100E+00, 1.300E+00, 8.500E-01, 5.400E-01,           &
     & 4.000E-01, 3.400E-01, 2.800E-01, 2.400E-01, 2.000E-01/           
      DATA AMOL21/                                                      &
     & 1.876E+04, 1.378E+04, 9.680E+03, 5.984E+03, 3.813E+03,           &
     & 2.225E+03, 1.510E+03, 1.020E+03, 6.464E+02, 4.129E+02,           &
     & 2.472E+02, 9.556E+01, 2.944E+01, 8.000E+00, 5.000E+00,           &
     & 3.400E+00, 3.300E+00, 3.200E+00, 3.150E+00, 3.200E+00,           &
     & 3.300E+00, 3.450E+00, 3.600E+00, 3.850E+00, 4.000E+00,           &
     & 4.200E+00, 4.450E+00, 4.700E+00, 4.850E+00, 4.950E+00,           &
     & 5.000E+00, 5.100E+00, 5.300E+00, 5.450E+00, 5.500E+00,           &
     & 5.500E+00, 5.350E+00, 5.000E+00, 4.400E+00, 3.700E+00,           &
     & 2.950E+00, 2.100E+00, 1.330E+00, 8.500E-01, 5.400E-01,           &
     & 4.000E-01, 3.400E-01, 2.800E-01, 2.400E-01, 2.000E-01/           
      DATA AMOL31/                                                      &
     & 4.316E+03, 3.454E+03, 2.788E+03, 2.088E+03, 1.280E+03,           &
     & 8.241E+02, 5.103E+02, 2.321E+02, 1.077E+02, 5.566E+01,           &
     & 2.960E+01, 1.000E+01, 6.000E+00, 5.000E+00, 4.800E+00,           &
     & 4.700E+00, 4.600E+00, 4.500E+00, 4.500E+00, 4.500E+00,           &
     & 4.500E+00, 4.500E+00, 4.530E+00, 4.550E+00, 4.600E+00,           &
     & 4.650E+00, 4.700E+00, 4.750E+00, 4.800E+00, 4.850E+00,           &
     & 4.900E+00, 4.950E+00, 5.000E+00, 5.000E+00, 5.000E+00,           &
     & 4.950E+00, 4.850E+00, 4.500E+00, 4.000E+00, 3.300E+00,           &
     & 2.700E+00, 2.000E+00, 1.330E+00, 8.500E-01, 5.400E-01,           &
     & 4.000E-01, 3.400E-01, 2.800E-01, 2.400E-01, 2.000E-01/           
      DATA AMOL41/                                                      &
     & 1.194E+04, 8.701E+03, 6.750E+03, 4.820E+03, 3.380E+03,           &
     & 2.218E+03, 1.330E+03, 7.971E+02, 3.996E+02, 1.300E+02,           &
     & 4.240E+01, 1.330E+01, 6.000E+00, 4.450E+00, 4.000E+00,           &
     & 4.000E+00, 4.000E+00, 4.050E+00, 4.300E+00, 4.500E+00,           &
     & 4.600E+00, 4.700E+00, 4.800E+00, 4.830E+00, 4.850E+00,           &
     & 4.900E+00, 4.950E+00, 5.000E+00, 5.000E+00, 5.000E+00,           &
     & 5.000E+00, 5.000E+00, 5.000E+00, 5.000E+00, 5.000E+00,           &
     & 4.950E+00, 4.850E+00, 4.500E+00, 4.000E+00, 3.300E+00,           &
     & 2.700E+00, 2.000E+00, 1.330E+00, 8.500E-01, 5.400E-01,           &
     & 4.000E-01, 3.400E-01, 2.800E-01, 2.400E-01, 2.000E-01/           
      DATA AMOL51/                                                      &
     & 1.405E+03, 1.615E+03, 1.427E+03, 1.166E+03, 7.898E+02,           &
     & 4.309E+02, 2.369E+02, 1.470E+02, 3.384E+01, 2.976E+01,           &
     & 2.000E+01, 1.000E+01, 6.000E+00, 4.450E+00, 4.500E+00,           &
     & 4.550E+00, 4.600E+00, 4.650E+00, 4.700E+00, 4.750E+00,           &
     & 4.800E+00, 4.850E+00, 4.900E+00, 4.950E+00, 5.000E+00,           &
     & 5.000E+00, 5.000E+00, 5.000E+00, 5.000E+00, 5.000E+00,           &
     & 5.000E+00, 5.000E+00, 5.000E+00, 5.000E+00, 5.000E+00,           &
     & 4.950E+00, 4.850E+00, 4.500E+00, 4.000E+00, 3.300E+00,           &
     & 2.700E+00, 2.000E+00, 1.330E+00, 8.500E-01, 5.400E-01,           &
     & 4.000E-01, 3.400E-01, 2.800E-01, 2.400E-01, 2.000E-01/           
      DATA AMOL61/                                                      &
     & 7.745E+03, 6.071E+03, 4.631E+03, 3.182E+03, 2.158E+03,           &
     & 1.397E+03, 9.254E+02, 5.720E+02, 3.667E+02, 1.583E+02,           &
     & 6.996E+01, 3.613E+01, 1.906E+01, 1.085E+01, 5.927E+00,           &
     & 5.000E+00, 3.950E+00, 3.850E+00, 3.825E+00, 3.850E+00,           &
     & 3.900E+00, 3.975E+00, 4.065E+00, 4.200E+00, 4.300E+00,           &
     & 4.425E+00, 4.575E+00, 4.725E+00, 4.825E+00, 4.900E+00,           &
     & 4.950E+00, 5.025E+00, 5.150E+00, 5.225E+00, 5.250E+00,           &
     & 5.225E+00, 5.100E+00, 4.750E+00, 4.200E+00, 3.500E+00,           &
     & 2.825E+00, 2.050E+00, 1.330E+00, 8.500E-01, 5.400E-01,           &
     & 4.000E-01, 3.400E-01, 2.800E-01, 2.400E-01, 2.000E-01/           
!                                                                       
!     DATA CO2       /                                                  
!                                                                       
      DATA AMOL12/                                                      &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.280E+02, 3.200E+02, 3.100E+02, 2.700E+02,           &
     & 1.950E+02, 1.100E+02, 6.000E+01, 4.000E+01, 3.500E+01/           
!                                                                       
!     DATA CO2       /                                                  
!                                                                       
      DATA AMOL22/                                                      &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.280E+02, 3.200E+02, 3.100E+02, 2.700E+02,           &
     & 1.950E+02, 1.100E+02, 6.000E+01, 4.000E+01, 3.500E+01/           
!                                                                       
!     DATA CO2       /                                                  
!                                                                       
      DATA AMOL32/                                                      &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.280E+02, 3.200E+02, 3.100E+02, 2.700E+02,           &
     & 1.950E+02, 1.100E+02, 6.000E+01, 4.000E+01, 3.500E+01/           
!                                                                       
!     DATA CO2       /                                                  
!                                                                       
      DATA AMOL42/                                                      &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.280E+02, 3.200E+02, 3.100E+02, 2.700E+02,           &
     & 1.950E+02, 1.100E+02, 6.000E+01, 4.000E+01, 3.500E+01/           
!                                                                       
!     DATA CO2       /                                                  
!                                                                       
      DATA AMOL52/                                                      &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.280E+02, 3.200E+02, 3.100E+02, 2.700E+02,           &
     & 1.950E+02, 1.100E+02, 6.000E+01, 4.000E+01, 3.500E+01/           
!                                                                       
!     DATA CO2       /                                                  
!                                                                       
      DATA AMOL62/                                                      &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02, 3.300E+02,           &
     & 3.300E+02, 3.280E+02, 3.200E+02, 3.100E+02, 2.700E+02,           &
     & 1.950E+02, 1.100E+02, 6.000E+01, 4.000E+01, 3.500E+01/           
!                                                                       
!     DATA OZONE     /                                                  
!                                                                       
      DATA AMOL13/                                                      &
     & 2.869E-02, 3.150E-02, 3.342E-02, 3.504E-02, 3.561E-02,           &
     & 3.767E-02, 3.989E-02, 4.223E-02, 4.471E-02, 5.000E-02,           &
     & 5.595E-02, 6.613E-02, 7.815E-02, 9.289E-02, 1.050E-01,           &
     & 1.256E-01, 1.444E-01, 2.500E-01, 5.000E-01, 9.500E-01,           &
     & 1.400E+00, 1.800E+00, 2.400E+00, 3.400E+00, 4.300E+00,           &
     & 5.400E+00, 7.800E+00, 9.300E+00, 9.850E+00, 9.700E+00,           &
     & 8.800E+00, 7.500E+00, 5.900E+00, 4.500E+00, 3.450E+00,           &
     & 2.800E+00, 1.800E+00, 1.100E+00, 6.500E-01, 3.000E-01,           &
     & 1.800E-01, 3.300E-01, 5.000E-01, 5.200E-01, 5.000E-01,           &
     & 4.000E-01, 2.000E-01, 5.000E-02, 5.000E-03, 5.000E-04/           
      DATA AMOL23/                                                      &
     & 3.017E-02, 3.337E-02, 3.694E-02, 4.222E-02, 4.821E-02,           &
     & 5.512E-02, 6.408E-02, 7.764E-02, 9.126E-02, 1.111E-01,           &
     & 1.304E-01, 1.793E-01, 2.230E-01, 3.000E-01, 4.400E-01,           &
     & 5.000E-01, 6.000E-01, 7.000E-01, 1.000E+00, 1.500E+00,           &
     & 2.000E+00, 2.400E+00, 2.900E+00, 3.400E+00, 4.000E+00,           &
     & 4.800E+00, 6.000E+00, 7.000E+00, 8.100E+00, 8.900E+00,           &
     & 8.700E+00, 7.550E+00, 5.900E+00, 4.500E+00, 3.500E+00,           &
     & 2.800E+00, 1.800E+00, 1.300E+00, 8.000E-01, 4.000E-01,           &
     & 1.900E-01, 2.000E-01, 5.700E-01, 7.500E-01, 7.000E-01,           &
     & 4.000E-01, 2.000E-01, 5.000E-02, 5.000E-03, 5.000E-04/           
      DATA AMOL33/                                                      &
     & 2.778E-02, 2.800E-02, 2.849E-02, 3.200E-02, 3.567E-02,           &
     & 4.720E-02, 5.837E-02, 7.891E-02, 1.039E-01, 1.567E-01,           &
     & 2.370E-01, 3.624E-01, 5.232E-01, 7.036E-01, 8.000E-01,           &
     & 9.000E-01, 1.100E+00, 1.400E+00, 1.800E+00, 2.300E+00,           &
     & 2.900E+00, 3.500E+00, 3.900E+00, 4.300E+00, 4.700E+00,           &
     & 5.100E+00, 5.600E+00, 6.100E+00, 6.800E+00, 7.100E+00,           &
     & 7.200E+00, 6.900E+00, 5.900E+00, 4.600E+00, 3.700E+00,           &
     & 2.750E+00, 1.700E+00, 1.000E-00, 5.500E-01, 3.200E-01,           &
     & 2.500E-01, 2.300E-01, 5.500E-01, 8.000E-01, 8.000E-01,           &
     & 4.000E-01, 2.000E-01, 5.000E-02, 5.000E-03, 5.000E-04/           
      DATA AMOL43/                                                      &
     & 2.412E-02, 2.940E-02, 3.379E-02, 3.887E-02, 4.478E-02,           &
     & 5.328E-02, 6.564E-02, 7.738E-02, 9.114E-02, 1.420E-01,           &
     & 1.890E-01, 3.050E-01, 4.100E-01, 5.000E-01, 6.000E-01,           &
     & 7.000E-01, 8.500E-01, 1.000E+00, 1.300E+00, 1.700E+00,           &
     & 2.100E+00, 2.700E+00, 3.300E+00, 3.700E+00, 4.200E+00,           &
     & 4.500E+00, 5.300E+00, 5.700E+00, 6.900E+00, 7.700E+00,           &
     & 7.800E+00, 7.000E+00, 5.400E+00, 4.200E+00, 3.200E+00,           &
     & 2.500E+00, 1.700E+00, 1.200E+00, 8.000E-01, 4.000E-01,           &
     & 2.000E-01, 1.800E-01, 6.500E-01, 9.000E-01, 8.000E-01,           &
     & 4.000E-01, 2.000E-01, 5.000E-02, 5.000E-03, 5.000E-04/           
      DATA AMOL53/                                                      &
     & 1.802E-02, 2.072E-02, 2.336E-02, 2.767E-02, 3.253E-02,           &
     & 3.801E-02, 4.446E-02, 7.252E-02, 1.040E-01, 2.100E-01,           &
     & 3.000E-01, 3.500E-01, 4.000E-01, 6.500E-01, 9.000E-01,           &
     & 1.200E+00, 1.500E+00, 1.900E+00, 2.450E+00, 3.100E+00,           &
     & 3.700E+00, 4.000E+00, 4.200E+00, 4.500E+00, 4.600E+00,           &
     & 4.700E+00, 4.900E+00, 5.400E+00, 5.900E+00, 6.200E+00,           &
     & 6.250E+00, 5.900E+00, 5.100E+00, 4.100E+00, 3.000E+00,           &
     & 2.600E+00, 1.600E+00, 9.500E-01, 6.500E-01, 5.000E-01,           &
     & 3.300E-01, 1.300E-01, 7.500E-01, 8.000E-01, 8.000E-01,           &
     & 4.000E-01, 2.000E-01, 5.000E-02, 5.000E-03, 5.000E-04/           
      DATA AMOL63/                                                      &
     & 2.660E-02, 2.931E-02, 3.237E-02, 3.318E-02, 3.387E-02,           &
     & 3.768E-02, 4.112E-02, 5.009E-02, 5.966E-02, 9.168E-02,           &
     & 1.313E-01, 2.149E-01, 3.095E-01, 3.846E-01, 5.030E-01,           &
     & 6.505E-01, 8.701E-01, 1.187E+00, 1.587E+00, 2.030E+00,           &
     & 2.579E+00, 3.028E+00, 3.647E+00, 4.168E+00, 4.627E+00,           &
     & 5.118E+00, 5.803E+00, 6.553E+00, 7.373E+00, 7.837E+00,           &
     & 7.800E+00, 7.300E+00, 6.200E+00, 5.250E+00, 4.100E+00,           &
     & 3.100E+00, 1.800E+00, 1.100E+00, 7.000E-01, 3.000E-01,           &
     & 2.500E-01, 3.000E-01, 5.000E-01, 7.000E-01, 7.000E-01,           &
     & 4.000E-01, 2.000E-01, 5.000E-02, 5.000E-03, 5.000E-04/           
!                                                                       
!     DATA  N2O      /                                                  
!                                                                       
      DATA AMOL14/                                                      &
     & 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01,           &
     & 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01, 3.195E-01,           &
     & 3.179E-01, 3.140E-01, 3.095E-01, 3.048E-01, 2.999E-01,           &
     & 2.944E-01, 2.877E-01, 2.783E-01, 2.671E-01, 2.527E-01,           &
     & 2.365E-01, 2.194E-01, 2.051E-01, 1.967E-01, 1.875E-01,           &
     & 1.756E-01, 1.588E-01, 1.416E-01, 1.165E-01, 9.275E-02,           &
     & 6.693E-02, 4.513E-02, 2.751E-02, 1.591E-02, 9.378E-03,           &
     & 4.752E-03, 3.000E-03, 2.065E-03, 1.507E-03, 1.149E-03,           &
     & 8.890E-04, 7.056E-04, 5.716E-04, 4.708E-04, 3.932E-04,           &
     & 3.323E-04, 2.837E-04, 2.443E-04, 2.120E-04, 1.851E-04/           
!                                                                       
!     DATA  N2O      /                                                  
!                                                                       
      DATA AMOL24/                                                      &
     & 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01,           &
     & 3.200E-01, 3.200E-01, 3.200E-01, 3.195E-01, 3.163E-01,           &
     & 3.096E-01, 2.989E-01, 2.936E-01, 2.860E-01, 2.800E-01,           &
     & 2.724E-01, 2.611E-01, 2.421E-01, 2.174E-01, 1.843E-01,           &
     & 1.607E-01, 1.323E-01, 1.146E-01, 1.035E-01, 9.622E-02,           &
     & 8.958E-02, 8.006E-02, 6.698E-02, 4.958E-02, 3.695E-02,           &
     & 2.519E-02, 1.736E-02, 1.158E-02, 7.665E-03, 5.321E-03,           &
     & 3.215E-03, 2.030E-03, 1.397E-03, 1.020E-03, 7.772E-04,           &
     & 6.257E-04, 5.166E-04, 4.352E-04, 3.727E-04, 3.237E-04,           &
     & 2.844E-04, 2.524E-04, 2.260E-04, 2.039E-04, 1.851E-04/           
!                                                                       
!     DATA  N2O      /                                                  
!                                                                       
      DATA AMOL34/                                                      &
     & 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01,           &
     & 3.200E-01, 3.200E-01, 3.200E-01, 3.195E-01, 3.163E-01,           &
     & 3.096E-01, 2.989E-01, 2.936E-01, 2.860E-01, 2.800E-01,           &
     & 2.724E-01, 2.611E-01, 2.421E-01, 2.174E-01, 1.843E-01,           &
     & 1.621E-01, 1.362E-01, 1.230E-01, 1.124E-01, 1.048E-01,           &
     & 9.661E-02, 8.693E-02, 7.524E-02, 6.126E-02, 5.116E-02,           &
     & 3.968E-02, 2.995E-02, 2.080E-02, 1.311E-02, 8.071E-03,           &
     & 4.164E-03, 2.629E-03, 1.809E-03, 1.321E-03, 1.007E-03,           &
     & 7.883E-04, 6.333E-04, 5.194E-04, 4.333E-04, 3.666E-04,           &
     & 3.140E-04, 2.717E-04, 2.373E-04, 2.089E-04, 1.851E-04/           
!                                                                       
!     DATA  N2O      /                                                  
!                                                                       
      DATA AMOL44/                                                      &
     & 3.100E-01, 3.100E-01, 3.100E-01, 3.100E-01, 3.079E-01,           &
     & 3.024E-01, 2.906E-01, 2.822E-01, 2.759E-01, 2.703E-01,           &
     & 2.651E-01, 2.600E-01, 2.549E-01, 2.494E-01, 2.433E-01,           &
     & 2.355E-01, 2.282E-01, 2.179E-01, 2.035E-01, 1.817E-01,           &
     & 1.567E-01, 1.350E-01, 1.218E-01, 1.102E-01, 9.893E-02,           &
     & 8.775E-02, 7.327E-02, 5.941E-02, 4.154E-02, 3.032E-02,           &
     & 1.949E-02, 1.274E-02, 9.001E-03, 6.286E-03, 4.558E-03,           &
     & 2.795E-03, 1.765E-03, 1.214E-03, 8.866E-04, 6.756E-04,           &
     & 5.538E-04, 4.649E-04, 3.979E-04, 3.459E-04, 3.047E-04,           &
     & 2.713E-04, 2.439E-04, 2.210E-04, 2.017E-04, 1.851E-04/           
!                                                                       
!     DATA  N2O      /                                                  
!                                                                       
      DATA AMOL54/                                                      &
     & 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01,           &
     & 3.200E-01, 3.200E-01, 3.200E-01, 3.195E-01, 3.163E-01,           &
     & 3.096E-01, 2.989E-01, 2.936E-01, 2.860E-01, 2.800E-01,           &
     & 2.724E-01, 2.611E-01, 2.421E-01, 2.174E-01, 1.843E-01,           &
     & 1.621E-01, 1.362E-01, 1.230E-01, 1.122E-01, 1.043E-01,           &
     & 9.570E-02, 8.598E-02, 7.314E-02, 5.710E-02, 4.670E-02,           &
     & 3.439E-02, 2.471E-02, 1.631E-02, 1.066E-02, 7.064E-03,           &
     & 3.972E-03, 2.508E-03, 1.726E-03, 1.260E-03, 9.602E-04,           &
     & 7.554E-04, 6.097E-04, 5.024E-04, 4.210E-04, 3.579E-04,           &
     & 3.080E-04, 2.678E-04, 2.350E-04, 2.079E-04, 1.851E-04/           
!                                                                       
!     DATA  N2O      /                                                  
!                                                                       
      DATA AMOL64/                                                      &
     & 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01,           &
     & 3.200E-01, 3.200E-01, 3.200E-01, 3.200E-01, 3.195E-01,           &
     & 3.179E-01, 3.140E-01, 3.095E-01, 3.048E-01, 2.999E-01,           &
     & 2.944E-01, 2.877E-01, 2.783E-01, 2.671E-01, 2.527E-01,           &
     & 2.365E-01, 2.194E-01, 2.051E-01, 1.967E-01, 1.875E-01,           &
     & 1.756E-01, 1.588E-01, 1.416E-01, 1.165E-01, 9.275E-02,           &
     & 6.693E-02, 4.513E-02, 2.751E-02, 1.591E-02, 9.378E-03,           &
     & 4.752E-03, 3.000E-03, 2.065E-03, 1.507E-03, 1.149E-03,           &
     & 8.890E-04, 7.056E-04, 5.716E-04, 4.708E-04, 3.932E-04,           &
     & 3.323E-04, 2.837E-04, 2.443E-04, 2.120E-04, 1.851E-04/           
!                                                                       
!     DATA CO        /                                                  
!                                                                       
      DATA AMOL15/                                                      &
     & 1.500E-01, 1.450E-01, 1.399E-01, 1.349E-01, 1.312E-01,           &
     & 1.303E-01, 1.288E-01, 1.247E-01, 1.185E-01, 1.094E-01,           &
     & 9.962E-02, 8.964E-02, 7.814E-02, 6.374E-02, 5.025E-02,           &
     & 3.941E-02, 3.069E-02, 2.489E-02, 1.966E-02, 1.549E-02,           &
     & 1.331E-02, 1.232E-02, 1.232E-02, 1.307E-02, 1.400E-02,           &
     & 1.521E-02, 1.722E-02, 1.995E-02, 2.266E-02, 2.487E-02,           &
     & 2.738E-02, 3.098E-02, 3.510E-02, 3.987E-02, 4.482E-02,           &
     & 5.092E-02, 5.985E-02, 6.960E-02, 9.188E-02, 1.938E-01,           &
     & 5.688E-01, 1.549E+00, 3.849E+00, 6.590E+00, 1.044E+01,           &
     & 1.705E+01, 2.471E+01, 3.358E+01, 4.148E+01, 5.000E+01/           
!                                                                       
!     DATA CO        /                                                  
!                                                                       
      DATA AMOL25/                                                      &
     & 1.500E-01, 1.450E-01, 1.399E-01, 1.349E-01, 1.312E-01,           &
     & 1.303E-01, 1.288E-01, 1.247E-01, 1.185E-01, 1.094E-01,           &
     & 9.962E-02, 8.964E-02, 7.814E-02, 6.374E-02, 5.025E-02,           &
     & 3.941E-02, 3.069E-02, 2.489E-02, 1.966E-02, 1.549E-02,           &
     & 1.331E-02, 1.232E-02, 1.232E-02, 1.307E-02, 1.400E-02,           &
     & 1.521E-02, 1.722E-02, 1.995E-02, 2.266E-02, 2.487E-02,           &
     & 2.716E-02, 2.962E-02, 3.138E-02, 3.307E-02, 3.487E-02,           &
     & 3.645E-02, 3.923E-02, 4.673E-02, 6.404E-02, 1.177E-01,           &
     & 2.935E-01, 6.815E-01, 1.465E+00, 2.849E+00, 5.166E+00,           &
     & 1.008E+01, 1.865E+01, 2.863E+01, 3.890E+01, 5.000E+01/           
!                                                                       
!     DATA CO        /                                                  
!                                                                       
      DATA AMOL35/                                                      &
     & 1.500E-01, 1.450E-01, 1.399E-01, 1.349E-01, 1.312E-01,           &
     & 1.303E-01, 1.288E-01, 1.247E-01, 1.185E-01, 1.094E-01,           &
     & 9.962E-02, 8.964E-02, 7.814E-02, 6.374E-02, 5.025E-02,           &
     & 3.941E-02, 3.069E-02, 2.489E-02, 1.966E-02, 1.549E-02,           &
     & 1.331E-02, 1.232E-02, 1.232E-02, 1.307E-02, 1.400E-02,           &
     & 1.498E-02, 1.598E-02, 1.710E-02, 1.850E-02, 1.997E-02,           &
     & 2.147E-02, 2.331E-02, 2.622E-02, 3.057E-02, 3.803E-02,           &
     & 6.245E-02, 1.480E-01, 2.926E-01, 5.586E-01, 1.078E+00,           &
     & 1.897E+00, 2.960E+00, 4.526E+00, 6.862E+00, 1.054E+01,           &
     & 1.709E+01, 2.473E+01, 3.359E+01, 4.149E+01, 5.000E+01/           
!                                                                       
!     DATA CO        /                                                  
!                                                                       
      DATA AMOL45/                                                      &
     & 1.500E-01, 1.450E-01, 1.399E-01, 1.349E-01, 1.312E-01,           &
     & 1.303E-01, 1.288E-01, 1.247E-01, 1.185E-01, 1.094E-01,           &
     & 9.962E-02, 8.964E-02, 7.814E-02, 6.374E-02, 5.025E-02,           &
     & 3.941E-02, 3.069E-02, 2.489E-02, 1.966E-02, 1.549E-02,           &
     & 1.331E-02, 1.232E-02, 1.232E-02, 1.307E-02, 1.400E-02,           &
     & 1.510E-02, 1.649E-02, 1.808E-02, 1.997E-02, 2.183E-02,           &
     & 2.343E-02, 2.496E-02, 2.647E-02, 2.809E-02, 2.999E-02,           &
     & 3.220E-02, 3.650E-02, 4.589E-02, 6.375E-02, 1.176E-01,           &
     & 3.033E-01, 7.894E-01, 1.823E+00, 3.402E+00, 5.916E+00,           &
     & 1.043E+01, 1.881E+01, 2.869E+01, 3.892E+01, 5.000E+01/           
!                                                                       
!     DATA CO        /                                                  
!                                                                       
      DATA AMOL55/                                                      &
     & 1.500E-01, 1.450E-01, 1.399E-01, 1.349E-01, 1.312E-01,           &
     & 1.303E-01, 1.288E-01, 1.247E-01, 1.185E-01, 1.094E-01,           &
     & 9.962E-02, 8.964E-02, 7.814E-02, 6.374E-02, 5.025E-02,           &
     & 3.941E-02, 3.069E-02, 2.489E-02, 1.966E-02, 1.549E-02,           &
     & 1.331E-02, 1.232E-02, 1.232E-02, 1.307E-02, 1.400E-02,           &
     & 1.521E-02, 1.722E-02, 2.037E-02, 2.486E-02, 3.168E-02,           &
     & 4.429E-02, 6.472E-02, 1.041E-01, 1.507E-01, 2.163E-01,           &
     & 3.141E-01, 4.842E-01, 7.147E-01, 1.067E+00, 1.516E+00,           &
     & 2.166E+00, 3.060E+00, 4.564E+00, 6.877E+00, 1.055E+01,           &
     & 1.710E+01, 2.473E+01, 3.359E+01, 4.149E+01, 5.000E+01/           
!                                                                       
!     DATA CO        /                                                  
!                                                                       
      DATA AMOL65/                                                      &
     & 1.500E-01, 1.450E-01, 1.399E-01, 1.349E-01, 1.312E-01,           &
     & 1.303E-01, 1.288E-01, 1.247E-01, 1.185E-01, 1.094E-01,           &
     & 9.962E-02, 8.964E-02, 7.814E-02, 6.374E-02, 5.025E-02,           &
     & 3.941E-02, 3.069E-02, 2.489E-02, 1.966E-02, 1.549E-02,           &
     & 1.331E-02, 1.232E-02, 1.232E-02, 1.307E-02, 1.400E-02,           &
     & 1.498E-02, 1.598E-02, 1.710E-02, 1.850E-02, 2.009E-02,           &
     & 2.220E-02, 2.497E-02, 2.824E-02, 3.241E-02, 3.717E-02,           &
     & 4.597E-02, 6.639E-02, 1.073E-01, 1.862E-01, 3.059E-01,           &
     & 6.375E-01, 1.497E+00, 3.239E+00, 5.843E+00, 1.013E+01,           &
     & 1.692E+01, 2.467E+01, 3.356E+01, 4.148E+01, 5.000E+01/           
!                                                                       
!     DATA  CH4      /                                                  
!                                                                       
      DATA AMOL16/                                                      &
     & 1.700E+00, 1.700E+00, 1.700E+00, 1.700E+00, 1.700E+00,           &
     & 1.700E+00, 1.700E+00, 1.699E+00, 1.697E+00, 1.693E+00,           &
     & 1.685E+00, 1.675E+00, 1.662E+00, 1.645E+00, 1.626E+00,           &
     & 1.605E+00, 1.582E+00, 1.553E+00, 1.521E+00, 1.480E+00,           &
     & 1.424E+00, 1.355E+00, 1.272E+00, 1.191E+00, 1.118E+00,           &
     & 1.055E+00, 9.870E-01, 9.136E-01, 8.300E-01, 7.460E-01,           &
     & 6.618E-01, 5.638E-01, 4.614E-01, 3.631E-01, 2.773E-01,           &
     & 2.100E-01, 1.651E-01, 1.500E-01, 1.500E-01, 1.500E-01,           &
     & 1.500E-01, 1.500E-01, 1.500E-01, 1.400E-01, 1.300E-01,           &
     & 1.200E-01, 1.100E-01, 9.500E-02, 6.000E-02, 3.000E-02/           
!                                                                       
!     DATA  CH4      /                                                  
!                                                                       
      DATA AMOL26/                                                      &
     & 1.700E+00, 1.700E+00, 1.700E+00, 1.700E+00, 1.697E+00,           &
     & 1.687E+00, 1.672E+00, 1.649E+00, 1.629E+00, 1.615E+00,           &
     & 1.579E+00, 1.542E+00, 1.508E+00, 1.479E+00, 1.451E+00,           &
     & 1.422E+00, 1.390E+00, 1.356E+00, 1.323E+00, 1.281E+00,           &
     & 1.224E+00, 1.154E+00, 1.066E+00, 9.730E-01, 8.800E-01,           &
     & 7.888E-01, 7.046E-01, 6.315E-01, 5.592E-01, 5.008E-01,           &
     & 4.453E-01, 3.916E-01, 3.389E-01, 2.873E-01, 2.384E-01,           &
     & 1.944E-01, 1.574E-01, 1.500E-01, 1.500E-01, 1.500E-01,           &
     & 1.500E-01, 1.500E-01, 1.500E-01, 1.400E-01, 1.300E-01,           &
     & 1.200E-01, 1.100E-01, 9.500E-02, 6.000E-02, 3.000E-02/           
!                                                                       
!     DATA  CH4      /                                                  
!                                                                       
      DATA AMOL36/                                                      &
     & 1.700E+00, 1.700E+00, 1.700E+00, 1.700E+00, 1.697E+00,           &
     & 1.687E+00, 1.672E+00, 1.649E+00, 1.629E+00, 1.615E+00,           &
     & 1.579E+00, 1.542E+00, 1.508E+00, 1.479E+00, 1.451E+00,           &
     & 1.422E+00, 1.390E+00, 1.356E+00, 1.323E+00, 1.281E+00,           &
     & 1.224E+00, 1.154E+00, 1.066E+00, 9.730E-01, 8.800E-01,           &
     & 7.931E-01, 7.130E-01, 6.438E-01, 5.746E-01, 5.050E-01,           &
     & 4.481E-01, 3.931E-01, 3.395E-01, 2.876E-01, 2.386E-01,           &
     & 1.944E-01, 1.574E-01, 1.500E-01, 1.500E-01, 1.500E-01,           &
     & 1.500E-01, 1.500E-01, 1.500E-01, 1.400E-01, 1.300E-01,           &
     & 1.200E-01, 1.100E-01, 9.500E-02, 6.000E-02, 3.000E-02/           
!                                                                       
!     DATA  CH4      /                                                  
!                                                                       
      DATA AMOL46/                                                      &
     & 1.700E+00, 1.700E+00, 1.700E+00, 1.700E+00, 1.697E+00,           &
     & 1.687E+00, 1.672E+00, 1.649E+00, 1.629E+00, 1.615E+00,           &
     & 1.579E+00, 1.542E+00, 1.506E+00, 1.471E+00, 1.434E+00,           &
     & 1.389E+00, 1.342E+00, 1.290E+00, 1.230E+00, 1.157E+00,           &
     & 1.072E+00, 9.903E-01, 9.170E-01, 8.574E-01, 8.013E-01,           &
     & 7.477E-01, 6.956E-01, 6.442E-01, 5.888E-01, 5.240E-01,           &
     & 4.506E-01, 3.708E-01, 2.992E-01, 2.445E-01, 2.000E-01,           &
     & 1.660E-01, 1.500E-01, 1.500E-01, 1.500E-01, 1.500E-01,           &
     & 1.500E-01, 1.500E-01, 1.500E-01, 1.400E-01, 1.300E-01,           &
     & 1.200E-01, 1.100E-01, 9.500E-02, 6.000E-02, 3.000E-02/           
!                                                                       
!     DATA  CH4      /                                                  
!                                                                       
      DATA AMOL56/                                                      &
     & 1.700E+00, 1.700E+00, 1.700E+00, 1.700E+00, 1.697E+00,           &
     & 1.687E+00, 1.672E+00, 1.649E+00, 1.629E+00, 1.615E+00,           &
     & 1.579E+00, 1.542E+00, 1.506E+00, 1.471E+00, 1.434E+00,           &
     & 1.389E+00, 1.342E+00, 1.290E+00, 1.230E+00, 1.161E+00,           &
     & 1.084E+00, 1.014E+00, 9.561E-01, 9.009E-01, 8.479E-01,           &
     & 7.961E-01, 7.449E-01, 6.941E-01, 6.434E-01, 5.883E-01,           &
     & 5.238E-01, 4.505E-01, 3.708E-01, 3.004E-01, 2.453E-01,           &
     & 1.980E-01, 1.590E-01, 1.500E-01, 1.500E-01, 1.500E-01,           &
     & 1.500E-01, 1.500E-01, 1.500E-01, 1.400E-01, 1.300E-01,           &
     & 1.200E-01, 1.100E-01, 9.500E-02, 6.000E-02, 3.000E-02/           
!                                                                       
!     DATA  CH4      /                                                  
!                                                                       
      DATA AMOL66/                                                      &
     & 1.700E+00, 1.700E+00, 1.700E+00, 1.700E+00, 1.700E+00,           &
     & 1.700E+00, 1.700E+00, 1.699E+00, 1.697E+00, 1.693E+00,           &
     & 1.685E+00, 1.675E+00, 1.662E+00, 1.645E+00, 1.626E+00,           &
     & 1.605E+00, 1.582E+00, 1.553E+00, 1.521E+00, 1.480E+00,           &
     & 1.424E+00, 1.355E+00, 1.272E+00, 1.191E+00, 1.118E+00,           &
     & 1.055E+00, 9.870E-01, 9.136E-01, 8.300E-01, 7.460E-01,           &
     & 6.618E-01, 5.638E-01, 4.614E-01, 3.631E-01, 2.773E-01,           &
     & 2.100E-01, 1.650E-01, 1.500E-01, 1.500E-01, 1.500E-01,           &
     & 1.500E-01, 1.500E-01, 1.500E-01, 1.400E-01, 1.300E-01,           &
     & 1.200E-01, 1.100E-01, 9.500E-02, 6.000E-02, 3.000E-02/           
!                                                                       
!     DATA O2        /                                                  
!                                                                       
      DATA AMOL17/                                                      &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.000E+05, 1.900E+05, 1.800E+05,           &
     & 1.600E+05, 1.400E+05, 1.200E+05, 9.400E+04, 7.250E+04/           
!                                                                       
!     DATA O2        /                                                  
!                                                                       
      DATA AMOL27/                                                      &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.000E+05, 1.900E+05, 1.800E+05,           &
     & 1.600E+05, 1.400E+05, 1.200E+05, 9.400E+04, 7.250E+04/           
!                                                                       
!     DATA O2        /                                                  
!                                                                       
      DATA AMOL37/                                                      &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.000E+05, 1.900E+05, 1.800E+05,           &
     & 1.600E+05, 1.400E+05, 1.200E+05, 9.400E+04, 7.250E+04/           
!                                                                       
!     DATA O2        /                                                  
!                                                                       
      DATA AMOL47/                                                      &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.000E+05, 1.900E+05, 1.800E+05,           &
     & 1.600E+05, 1.400E+05, 1.200E+05, 9.400E+04, 7.250E+04/           
!                                                                       
!     DATA O2        /                                                  
!                                                                       
      DATA AMOL57/                                                      &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.000E+05, 1.900E+05, 1.800E+05,           &
     & 1.600E+05, 1.400E+05, 1.200E+05, 9.400E+04, 7.250E+04/           
!                                                                       
!     DATA O2        /                                                  
!                                                                       
      DATA AMOL67/                                                      &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05, 2.090E+05,           &
     & 2.090E+05, 2.090E+05, 2.000E+05, 1.900E+05, 1.800E+05,           &
     & 1.600E+05, 1.400E+05, 1.200E+05, 9.400E+04, 7.250E+04/           
!                                                                       
!     DATA DENSITY   /                                                  
!                                                                       
      DATA AMOL18/                                                      &
     & 2.450E+19, 2.231E+19, 2.028E+19, 1.827E+19, 1.656E+19,           &
     & 1.499E+19, 1.353E+19, 1.218E+19, 1.095E+19, 9.789E+18,           &
     & 8.747E+18, 7.780E+18, 6.904E+18, 6.079E+18, 5.377E+18,           &
     & 4.697E+18, 4.084E+18, 3.486E+18, 2.877E+18, 2.381E+18,           &
     & 1.981E+18, 1.651E+18, 1.381E+18, 1.169E+18, 9.920E+17,           &
     & 8.413E+17, 5.629E+17, 3.807E+17, 2.598E+17, 1.789E+17,           &
     & 1.243E+17, 8.703E+16, 6.147E+16, 4.352E+16, 3.119E+16,           &
     & 2.291E+16, 1.255E+16, 6.844E+15, 3.716E+15, 1.920E+15,           &
     & 9.338E+14, 4.314E+14, 1.801E+14, 7.043E+13, 2.706E+13,           &
     & 1.098E+13, 4.445E+12, 1.941E+12, 8.706E+11, 4.225E+11/           
      DATA AMOL28/                                                      &
     & 2.496E+19, 2.257E+19, 2.038E+19, 1.843E+19, 1.666E+19,           &
     & 1.503E+19, 1.351E+19, 1.212E+19, 1.086E+19, 9.716E+18,           &
     & 8.656E+18, 7.698E+18, 6.814E+18, 6.012E+18, 5.141E+18,           &
     & 4.368E+18, 3.730E+18, 3.192E+18, 2.715E+18, 2.312E+18,           &
     & 1.967E+18, 1.677E+18, 1.429E+18, 1.223E+18, 1.042E+18,           &
     & 8.919E+17, 6.050E+17, 4.094E+17, 2.820E+17, 1.927E+17,           &
     & 1.338E+17, 9.373E+16, 6.624E+16, 4.726E+16, 3.398E+16,           &
     & 2.500E+16, 1.386E+16, 7.668E+15, 4.196E+15, 2.227E+15,           &
     & 1.109E+15, 4.996E+14, 1.967E+14, 7.204E+13, 2.541E+13,           &
     & 9.816E+12, 3.816E+12, 1.688E+12, 8.145E+11, 4.330E+11/           
      DATA AMOL38/                                                      &
     & 2.711E+19, 2.420E+19, 2.158E+19, 1.922E+19, 1.724E+19,           &
     & 1.542E+19, 1.376E+19, 1.225E+19, 1.086E+19, 9.612E+18,           &
     & 8.472E+18, 7.271E+18, 6.237E+18, 5.351E+18, 4.588E+18,           &
     & 3.931E+18, 3.368E+18, 2.886E+18, 2.473E+18, 2.115E+18,           &
     & 1.809E+18, 1.543E+18, 1.317E+18, 1.125E+18, 9.633E+17,           &
     & 8.218E+17, 5.536E+17, 3.701E+17, 2.486E+17, 1.647E+17,           &
     & 1.108E+17, 7.540E+16, 5.202E+16, 3.617E+16, 2.570E+16,           &
     & 1.863E+16, 1.007E+16, 5.433E+15, 2.858E+15, 1.477E+15,           &
     & 7.301E+14, 3.553E+14, 1.654E+14, 7.194E+13, 3.052E+13,           &
     & 1.351E+13, 6.114E+12, 2.952E+12, 1.479E+12, 7.836E+11/           
      DATA AMOL48/                                                      &
     & 2.549E+19, 2.305E+19, 2.080E+19, 1.873E+19, 1.682E+19,           &
     & 1.508E+19, 1.357E+19, 1.216E+19, 1.088E+19, 9.701E+18,           &
     & 8.616E+18, 7.402E+18, 6.363E+18, 5.471E+18, 4.699E+18,           &
     & 4.055E+18, 3.476E+18, 2.987E+18, 2.568E+18, 2.208E+18,           &
     & 1.899E+18, 1.632E+18, 1.403E+18, 1.207E+18, 1.033E+18,           &
     & 8.834E+17, 6.034E+17, 4.131E+17, 2.839E+17, 1.938E+17,           &
     & 1.344E+17, 9.402E+16, 6.670E+16, 4.821E+16, 3.516E+16,           &
     & 2.581E+16, 1.421E+16, 7.946E+15, 4.445E+15, 2.376E+15,           &
     & 1.198E+15, 5.311E+14, 2.022E+14, 7.221E+13, 2.484E+13,           &
     & 9.441E+12, 3.624E+12, 1.610E+12, 7.951E+11, 4.311E+11/           
      DATA AMOL58/                                                      &
     & 2.855E+19, 2.484E+19, 2.202E+19, 1.950E+19, 1.736E+19,           &
     & 1.552E+19, 1.383E+19, 1.229E+19, 1.087E+19, 9.440E+18,           &
     & 8.069E+18, 6.898E+18, 5.893E+18, 5.039E+18, 4.308E+18,           &
     & 3.681E+18, 3.156E+18, 2.704E+18, 2.316E+18, 1.982E+18,           &
     & 1.697E+18, 1.451E+18, 1.241E+18, 1.061E+18, 9.065E+17,           &
     & 7.742E+17, 5.134E+17, 3.423E+17, 2.292E+17, 1.533E+17,           &
     & 1.025E+17, 6.927E+16, 4.726E+16, 3.266E+16, 2.261E+16,           &
     & 1.599E+16, 8.364E+15, 4.478E+15, 2.305E+15, 1.181E+15,           &
     & 6.176E+14, 3.127E+14, 1.531E+14, 7.244E+13, 3.116E+13,           &
     & 1.403E+13, 6.412E+12, 3.099E+12, 1.507E+12, 7.814E+11/           
      DATA AMOL68/                                                      &
     & 2.548E+19, 2.313E+19, 2.094E+19, 1.891E+19, 1.704E+19,           &
     & 1.532E+19, 1.373E+19, 1.228E+19, 1.094E+19, 9.719E+18,           &
     & 8.602E+18, 7.589E+18, 6.489E+18, 5.546E+18, 4.739E+18,           &
     & 4.050E+18, 3.462E+18, 2.960E+18, 2.530E+18, 2.163E+18,           &
     & 1.849E+18, 1.575E+18, 1.342E+18, 1.144E+18, 9.765E+17,           &
     & 8.337E+17, 5.640E+17, 3.830E+17, 2.524E+17, 1.761E+17,           &
     & 1.238E+17, 8.310E+16, 5.803E+16, 4.090E+16, 2.920E+16,           &
     & 2.136E+16, 1.181E+16, 6.426E+15, 3.386E+15, 1.723E+15,           &
     & 8.347E+14, 3.832E+14, 1.711E+14, 7.136E+13, 2.924E+13,           &
     & 1.189E+13, 5.033E+12, 2.144E+12, 9.688E+11, 5.114E+11/           
                                                                        
      DATA ANO        /                                                 &
     &  3.00E-04,  3.00E-04,  3.00E-04,  3.00E-04,  3.00E-04,           &
     &  3.00E-04,  3.00E-04,  3.00E-04,  3.00E-04,  3.00E-04,           &
     &  3.00E-04,  3.00E-04,  3.00E-04,  2.99E-04,  2.95E-04,           &
     &  2.83E-04,  2.68E-04,  2.52E-04,  2.40E-04,  2.44E-04,           &
     &  2.55E-04,  2.77E-04,  3.07E-04,  3.60E-04,  4.51E-04,           &
     &  6.85E-04,  1.28E-03,  2.45E-03,  4.53E-03,  7.14E-03,           &
     &  9.34E-03,  1.12E-02,  1.19E-02,  1.17E-02,  1.10E-02,           &
     &  1.03E-02,  1.01E-02,  1.01E-02,  1.03E-02,  1.15E-02,           &
     &  1.61E-02,  2.68E-02,  7.01E-02,  2.13E-01,  7.12E-01,           &
     &  2.08E+00,  4.50E+00,  7.98E+00,  1.00E+01,  1.00E+01/           
      DATA SO2       /                                                  &
     &  3.00E-04,  2.74E-04,  2.36E-04,  1.90E-04,  1.46E-04,           &
     &  1.18E-04,  9.71E-05,  8.30E-05,  7.21E-05,  6.56E-05,           &
     &  6.08E-05,  5.79E-05,  5.60E-05,  5.59E-05,  5.64E-05,           &
     &  5.75E-05,  5.75E-05,  5.37E-05,  4.78E-05,  3.97E-05,           &
     &  3.19E-05,  2.67E-05,  2.28E-05,  2.07E-05,  1.90E-05,           &
     &  1.75E-05,  1.54E-05,  1.34E-05,  1.21E-05,  1.16E-05,           &
     &  1.21E-05,  1.36E-05,  1.65E-05,  2.10E-05,  2.77E-05,           &
     &  3.56E-05,  4.59E-05,  5.15E-05,  5.11E-05,  4.32E-05,           &
     &  2.83E-05,  1.33E-05,  5.56E-06,  2.24E-06,  8.96E-07,           &
     &  3.58E-07,  1.43E-07,  5.73E-08,  2.29E-08,  9.17E-09/           
      DATA ANO2       /                                                 &
     &  2.30E-05,  2.30E-05,  2.30E-05,  2.30E-05,  2.30E-05,           &
     &  2.30E-05,  2.30E-05,  2.30E-05,  2.30E-05,  2.32E-05,           &
     &  2.38E-05,  2.62E-05,  3.15E-05,  4.45E-05,  7.48E-05,           &
     &  1.71E-04,  3.19E-04,  5.19E-04,  7.71E-04,  1.06E-03,           &
     &  1.39E-03,  1.76E-03,  2.16E-03,  2.58E-03,  3.06E-03,           &
     &  3.74E-03,  4.81E-03,  6.16E-03,  7.21E-03,  7.28E-03,           &
     &  6.26E-03,  4.03E-03,  2.17E-03,  1.15E-03,  6.66E-04,           &
     &  4.43E-04,  3.39E-04,  2.85E-04,  2.53E-04,  2.31E-04,           &
     &  2.15E-04,  2.02E-04,  1.92E-04,  1.83E-04,  1.76E-04,           &
     &  1.70E-04,  1.64E-04,  1.59E-04,  1.55E-04,  1.51E-04/           
      DATA ANH3       /                                                 &
     &  5.00E-04,  5.00E-04,  4.63E-04,  3.80E-04,  2.88E-04,           &
     &  2.04E-04,  1.46E-04,  9.88E-05,  6.48E-05,  3.77E-05,           &
     &  2.03E-05,  1.09E-05,  6.30E-06,  3.12E-06,  1.11E-06,           &
     &  4.47E-07,  2.11E-07,  1.10E-07,  6.70E-08,  3.97E-08,           &
     &  2.41E-08,  1.92E-08,  1.72E-08,  1.59E-08,  1.44E-08,           &
     &  1.23E-08,  9.37E-09,  6.35E-09,  3.68E-09,  1.82E-09,           &
     &  9.26E-10,  2.94E-10,  8.72E-11,  2.98E-11,  1.30E-11,           &
     &  7.13E-12,  4.80E-12,  3.66E-12,  3.00E-12,  2.57E-12,           &
     &  2.27E-12,  2.04E-12,  1.85E-12,  1.71E-12,  1.59E-12,           &
     &  1.48E-12,  1.40E-12,  1.32E-12,  1.25E-12,  1.19E-12/           
      DATA HNO3      /                                                  &
     &  5.00E-05,  5.96E-05,  6.93E-05,  7.91E-05,  8.87E-05,           &
     &  9.75E-05,  1.11E-04,  1.26E-04,  1.39E-04,  1.53E-04,           &
     &  1.74E-04,  2.02E-04,  2.41E-04,  2.76E-04,  3.33E-04,           &
     &  4.52E-04,  7.37E-04,  1.31E-03,  2.11E-03,  3.17E-03,           &
     &  4.20E-03,  4.94E-03,  5.46E-03,  5.74E-03,  5.84E-03,           &
     &  5.61E-03,  4.82E-03,  3.74E-03,  2.59E-03,  1.64E-03,           &
     &  9.68E-04,  5.33E-04,  2.52E-04,  1.21E-04,  7.70E-05,           &
     &  5.55E-05,  4.45E-05,  3.84E-05,  3.49E-05,  3.27E-05,           &
     &  3.12E-05,  3.01E-05,  2.92E-05,  2.84E-05,  2.78E-05,           &
     &  2.73E-05,  2.68E-05,  2.64E-05,  2.60E-05,  2.57E-05/           
      DATA OH        /                                                  &
     &  4.40E-08,  4.40E-08,  4.40E-08,  4.40E-08,  4.40E-08,           &
     &  4.40E-08,  4.40E-08,  4.41E-08,  4.45E-08,  4.56E-08,           &
     &  4.68E-08,  4.80E-08,  4.94E-08,  5.19E-08,  5.65E-08,           &
     &  6.75E-08,  8.25E-08,  1.04E-07,  1.30E-07,  1.64E-07,           &
     &  2.16E-07,  3.40E-07,  5.09E-07,  7.59E-07,  1.16E-06,           &
     &  2.18E-06,  5.00E-06,  1.17E-05,  3.40E-05,  8.35E-05,           &
     &  1.70E-04,  2.85E-04,  4.06E-04,  5.11E-04,  5.79E-04,           &
     &  6.75E-04,  9.53E-04,  1.76E-03,  3.74E-03,  7.19E-03,           &
     &  1.12E-02,  1.13E-02,  6.10E-03,  1.51E-03,  2.42E-04,           &
     &  4.47E-05,  1.77E-05,  1.19E-05,  1.35E-05,  2.20E-05/           
      DATA HF        /                                                  &
     &  1.00E-08,  1.00E-08,  1.23E-08,  1.97E-08,  3.18E-08,           &
     &  5.63E-08,  9.18E-08,  1.53E-07,  2.41E-07,  4.04E-07,           &
     &  6.57E-07,  1.20E-06,  1.96E-06,  3.12E-06,  4.62E-06,           &
     &  7.09E-06,  1.05E-05,  1.69E-05,  2.57E-05,  4.02E-05,           &
     &  5.77E-05,  7.77E-05,  9.90E-05,  1.23E-04,  1.50E-04,           &
     &  1.82E-04,  2.30E-04,  2.83E-04,  3.20E-04,  3.48E-04,           &
     &  3.72E-04,  3.95E-04,  4.10E-04,  4.21E-04,  4.24E-04,           &
     &  4.25E-04,  4.25E-04,  4.25E-04,  4.25E-04,  4.25E-04,           &
     &  4.25E-04,  4.25E-04,  4.25E-04,  4.25E-04,  4.25E-04,           &
     &  4.25E-04,  4.25E-04,  4.25E-04,  4.25E-04,  4.25E-04/           
      DATA HCL       /                                                  &
     &  1.00E-03,  7.49E-04,  5.61E-04,  4.22E-04,  3.19E-04,           &
     &  2.39E-04,  1.79E-04,  1.32E-04,  9.96E-05,  7.48E-05,           &
     &  5.68E-05,  4.59E-05,  4.36E-05,  6.51E-05,  1.01E-04,           &
     &  1.63E-04,  2.37E-04,  3.13E-04,  3.85E-04,  4.42E-04,           &
     &  4.89E-04,  5.22E-04,  5.49E-04,  5.75E-04,  6.04E-04,           &
     &  6.51E-04,  7.51E-04,  9.88E-04,  1.28E-03,  1.57E-03,           &
     &  1.69E-03,  1.74E-03,  1.76E-03,  1.79E-03,  1.80E-03,           &
     &  1.80E-03,  1.80E-03,  1.80E-03,  1.80E-03,  1.80E-03,           &
     &  1.80E-03,  1.80E-03,  1.80E-03,  1.80E-03,  1.80E-03,           &
     &  1.80E-03,  1.80E-03,  1.80E-03,  1.80E-03,  1.80E-03/           
      DATA HBR       /                                                  &
     &  1.70E-06,  1.70E-06,  1.70E-06,  1.70E-06,  1.70E-06,           &
     &  1.70E-06,  1.70E-06,  1.70E-06,  1.70E-06,  1.70E-06,           &
     &  1.70E-06,  1.70E-06,  1.70E-06,  1.70E-06,  1.70E-06,           &
     &  1.70E-06,  1.70E-06,  1.70E-06,  1.70E-06,  1.70E-06,           &
     &  1.70E-06,  1.70E-06,  1.70E-06,  1.70E-06,  1.70E-06,           &
     &  1.71E-06,  1.76E-06,  1.90E-06,  2.26E-06,  2.82E-06,           &
     &  3.69E-06,  4.91E-06,  6.13E-06,  6.85E-06,  7.08E-06,           &
     &  7.14E-06,  7.15E-06,  7.15E-06,  7.15E-06,  7.15E-06,           &
     &  7.15E-06,  7.15E-06,  7.15E-06,  7.15E-06,  7.15E-06,           &
     &  7.15E-06,  7.15E-06,  7.15E-06,  7.15E-06,  7.15E-06/           
      DATA HI        /                                                  &
     &  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,           &
     &  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,           &
     &  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,           &
     &  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,           &
     &  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,           &
     &  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,           &
     &  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,           &
     &  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,           &
     &  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,           &
     &  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06,  3.00E-06/           
      DATA CLO       /                                                  &
     &  1.00E-08,  1.00E-08,  1.00E-08,  1.00E-08,  1.00E-08,           &
     &  1.00E-08,  1.00E-08,  1.00E-08,  1.01E-08,  1.05E-08,           &
     &  1.21E-08,  1.87E-08,  3.18E-08,  5.61E-08,  9.99E-08,           &
     &  1.78E-07,  3.16E-07,  5.65E-07,  1.04E-06,  2.04E-06,           &
     &  4.64E-06,  8.15E-06,  1.07E-05,  1.52E-05,  2.24E-05,           &
     &  3.97E-05,  8.48E-05,  1.85E-04,  3.57E-04,  5.08E-04,           &
     &  6.07E-04,  5.95E-04,  4.33E-04,  2.51E-04,  1.56E-04,           &
     &  1.04E-04,  7.69E-05,  6.30E-05,  5.52E-05,  5.04E-05,           &
     &  4.72E-05,  4.49E-05,  4.30E-05,  4.16E-05,  4.03E-05,           &
     &  3.93E-05,  3.83E-05,  3.75E-05,  3.68E-05,  3.61E-05/           
      DATA OCS       /                                                  &
     &  6.00E-04,  5.90E-04,  5.80E-04,  5.70E-04,  5.62E-04,           &
     &  5.55E-04,  5.48E-04,  5.40E-04,  5.32E-04,  5.25E-04,           &
     &  5.18E-04,  5.09E-04,  4.98E-04,  4.82E-04,  4.60E-04,           &
     &  4.26E-04,  3.88E-04,  3.48E-04,  3.09E-04,  2.74E-04,           &
     &  2.41E-04,  2.14E-04,  1.88E-04,  1.64E-04,  1.37E-04,           &
     &  1.08E-04,  6.70E-05,  2.96E-05,  1.21E-05,  4.31E-06,           &
     &  1.60E-06,  6.71E-07,  4.35E-07,  3.34E-07,  2.80E-07,           &
     &  2.47E-07,  2.28E-07,  2.16E-07,  2.08E-07,  2.03E-07,           &
     &  1.98E-07,  1.95E-07,  1.92E-07,  1.89E-07,  1.87E-07,           &
     &  1.85E-07,  1.83E-07,  1.81E-07,  1.80E-07,  1.78E-07/           
      DATA H2CO      /                                                  &
     &  2.40E-03,  1.07E-03,  4.04E-04,  2.27E-04,  1.40E-04,           &
     &  1.00E-04,  7.44E-05,  6.04E-05,  5.01E-05,  4.22E-05,           &
     &  3.63E-05,  3.43E-05,  3.39E-05,  3.50E-05,  3.62E-05,           &
     &  3.62E-05,  3.58E-05,  3.50E-05,  3.42E-05,  3.39E-05,           &
     &  3.43E-05,  3.68E-05,  4.03E-05,  4.50E-05,  5.06E-05,           &
     &  5.82E-05,  7.21E-05,  8.73E-05,  1.01E-04,  1.11E-04,           &
     &  1.13E-04,  1.03E-04,  7.95E-05,  4.82E-05,  1.63E-05,           &
     &  5.10E-06,  2.00E-06,  1.05E-06,  6.86E-07,  5.14E-07,           &
     &  4.16E-07,  3.53E-07,  3.09E-07,  2.76E-07,  2.50E-07,           &
     &  2.30E-07,  2.13E-07,  1.98E-07,  1.86E-07,  1.75E-07/           
      DATA HOCL      /                                                  &
     &  7.70E-06,  1.06E-05,  1.22E-05,  1.14E-05,  9.80E-06,           &
     &  8.01E-06,  6.42E-06,  5.42E-06,  4.70E-06,  4.41E-06,           &
     &  4.34E-06,  4.65E-06,  5.01E-06,  5.22E-06,  5.60E-06,           &
     &  6.86E-06,  8.77E-06,  1.20E-05,  1.63E-05,  2.26E-05,           &
     &  3.07E-05,  4.29E-05,  5.76E-05,  7.65E-05,  9.92E-05,           &
     &  1.31E-04,  1.84E-04,  2.45E-04,  2.96E-04,  3.21E-04,           &
     &  3.04E-04,  2.48E-04,  1.64E-04,  9.74E-05,  4.92E-05,           &
     &  2.53E-05,  1.50E-05,  1.05E-05,  8.34E-06,  7.11E-06,           &
     &  6.33E-06,  5.78E-06,  5.37E-06,  5.05E-06,  4.78E-06,           &
     &  4.56E-06,  4.37E-06,  4.21E-06,  4.06E-06,  3.93E-06/           
      DATA AN2        /                                                 &
     &  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,           &
     &  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,           &
     &  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,           &
     &  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,           &
     &  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,           &
     &  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,           &
     &  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,           &
     &  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,  7.81E+05,           &
     &  7.81E+05,  7.81E+05,  7.81E+05,  7.80E+05,  7.79E+05,           &
     &  7.77E+05,  7.74E+05,  7.70E+05,  7.65E+05,  7.60E+05/           
      DATA HCN       /                                                  &
     &  1.70E-04,  1.65E-04,  1.63E-04,  1.61E-04,  1.60E-04,           &
     &  1.60E-04,  1.60E-04,  1.60E-04,  1.60E-04,  1.60E-04,           &
     &  1.60E-04,  1.60E-04,  1.60E-04,  1.59E-04,  1.57E-04,           &
     &  1.55E-04,  1.52E-04,  1.49E-04,  1.45E-04,  1.41E-04,           &
     &  1.37E-04,  1.34E-04,  1.30E-04,  1.25E-04,  1.19E-04,           &
     &  1.13E-04,  1.05E-04,  9.73E-05,  9.04E-05,  8.46E-05,           &
     &  8.02E-05,  7.63E-05,  7.30E-05,  7.00E-05,  6.70E-05,           &
     &  6.43E-05,  6.21E-05,  6.02E-05,  5.88E-05,  5.75E-05,           &
     &  5.62E-05,  5.50E-05,  5.37E-05,  5.25E-05,  5.12E-05,           &
     &  5.00E-05,  4.87E-05,  4.75E-05,  4.62E-05,  4.50E-05/           
      DATA CH3CL     /                                                  &
     &  7.00E-04,  6.70E-04,  6.43E-04,  6.22E-04,  6.07E-04,           &
     &  6.02E-04,  6.00E-04,  6.00E-04,  5.98E-04,  5.94E-04,           &
     &  5.88E-04,  5.79E-04,  5.66E-04,  5.48E-04,  5.28E-04,           &
     &  5.03E-04,  4.77E-04,  4.49E-04,  4.21E-04,  3.95E-04,           &
     &  3.69E-04,  3.43E-04,  3.17E-04,  2.86E-04,  2.48E-04,           &
     &  1.91E-04,  1.10E-04,  4.72E-05,  1.79E-05,  7.35E-06,           &
     &  3.03E-06,  1.32E-06,  8.69E-07,  6.68E-07,  5.60E-07,           &
     &  4.94E-07,  4.56E-07,  4.32E-07,  4.17E-07,  4.05E-07,           &
     &  3.96E-07,  3.89E-07,  3.83E-07,  3.78E-07,  3.73E-07,           &
     &  3.69E-07,  3.66E-07,  3.62E-07,  3.59E-07,  3.56E-07/           
      DATA H2O2      /                                                  &
     &  2.00E-04,  1.95E-04,  1.92E-04,  1.89E-04,  1.84E-04,           &
     &  1.77E-04,  1.66E-04,  1.49E-04,  1.23E-04,  9.09E-05,           &
     &  5.79E-05,  3.43E-05,  1.95E-05,  1.08E-05,  6.59E-06,           &
     &  4.20E-06,  2.94E-06,  2.30E-06,  2.24E-06,  2.68E-06,           &
     &  3.68E-06,  5.62E-06,  1.03E-05,  1.97E-05,  3.70E-05,           &
     &  6.20E-05,  1.03E-04,  1.36E-04,  1.36E-04,  1.13E-04,           &
     &  8.51E-05,  6.37E-05,  5.17E-05,  4.44E-05,  3.80E-05,           &
     &  3.48E-05,  3.62E-05,  5.25E-05,  1.26E-04,  3.77E-04,           &
     &  1.12E-03,  2.00E-03,  1.68E-03,  4.31E-04,  4.98E-05,           &
     &  6.76E-06,  8.38E-07,  9.56E-08,  1.00E-08,  1.00E-09/           
      DATA C2H2      /                                                  &
     &  3.00E-04,  1.72E-04,  9.57E-05,  6.74E-05,  5.07E-05,           &
     &  3.99E-05,  3.19E-05,  2.80E-05,  2.55E-05,  2.40E-05,           &
     &  2.27E-05,  2.08E-05,  1.76E-05,  1.23E-05,  7.32E-06,           &
     &  4.52E-06,  2.59E-06,  1.55E-06,  8.63E-07,  5.30E-07,           &
     &  3.10E-07,  1.89E-07,  1.04E-07,  5.75E-08,  2.23E-08,           &
     &  8.51E-09,  4.09E-09,  2.52E-09,  1.86E-09,  1.52E-09,           &
     &  1.32E-09,  1.18E-09,  1.08E-09,  9.97E-10,  9.34E-10,           &
     &  8.83E-10,  8.43E-10,  8.10E-10,  7.83E-10,  7.60E-10,           &
     &  7.40E-10,  7.23E-10,  7.07E-10,  6.94E-10,  6.81E-10,           &
     &  6.70E-10,  6.59E-10,  6.49E-10,  6.40E-10,  6.32E-10/           
      DATA C2H6      /                                                  &
     &  2.00E-03,  2.00E-03,  2.00E-03,  2.00E-03,  1.98E-03,           &
     &  1.95E-03,  1.90E-03,  1.85E-03,  1.79E-03,  1.72E-03,           &
     &  1.58E-03,  1.30E-03,  9.86E-04,  7.22E-04,  4.96E-04,           &
     &  3.35E-04,  2.14E-04,  1.49E-04,  1.05E-04,  7.96E-05,           &
     &  6.01E-05,  4.57E-05,  3.40E-05,  2.60E-05,  1.89E-05,           &
     &  1.22E-05,  5.74E-06,  2.14E-06,  8.49E-07,  3.42E-07,           &
     &  1.34E-07,  5.39E-08,  2.25E-08,  1.04E-08,  6.57E-09,           &
     &  4.74E-09,  3.79E-09,  3.28E-09,  2.98E-09,  2.79E-09,           &
     &  2.66E-09,  2.56E-09,  2.49E-09,  2.43E-09,  2.37E-09,           &
     &  2.33E-09,  2.29E-09,  2.25E-09,  2.22E-09,  2.19E-09/           
      DATA PH3       /                                                  &
     &  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,           &
     &  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,           &
     &  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,           &
     &  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,           &
     &  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,           &
     &  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,           &
     &  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,           &
     &  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,           &
     &  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,           &
     &  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/           
      DATA COF2 / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/ 

      DATA SF6  / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/ 

      DATA H2S  / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/ 

      DATA HCOOH /1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA HO2  / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA O    / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA CLONO2  / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA NOPLUS  / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA HOBR  / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA C2H4 / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA CH3OH / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA CH3BR / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA CH3CN / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA CF4 / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA C4H2 / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA HC3N / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA H2   / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA CS   / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/

      DATA SO3  / 1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14, &
     &            1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14,  1.00E-14/
      END                                           
!                                                                       
!     ******************************************************************
!                                                                       
      SUBROUTINE LDEFAL  (Z,P,T) 
!                                                                       
!     ******************************************************************
!                                                                       
!     THIS SUBROUTINE LOADS ONE OF THE 6 BUILT IN ATMOSPHERIC PROFILES  
!     FROM WHICH IT WILL INTERPOLATE "DEFAULT" VALUES FOR ALTITUDE "Z"  
!                                                                       
!                                                                       
!     ***  THIS SUBROUTINE IS CALLED BY "RDUNIT" WHICH                  
!     ***  READS USER SUPPLIED INPUT PROFILES OR SINGLE VALUES          
!     ***  UNDER "MODEL = 0     " SPECIFICATIONS                        
!                                                                       
!     *** SEE DOCUMENTATION FOR CLARIFICATION ***                       
!                                                                       
!     SUBROUTINE "DEFALT"IS TRIGGERRED WHENEVER ANY ONE OF              
!     THE INPUT PARAMETERS JCHARP, JCART, (JCHAR(K),K=1,NMOL) IS = 1-6  
!                                                                       
!     FOR SIMPLICITY, ALL INTERPOLATIONS ARE DONE AT ONE TIME BECAUSE   
!     THE LAGRANGE WEIGHTS (4PT), BASED ON (ALT-Z), REMAIN UNCHANGED    
!                                                                       
!     JCHAR(K) FOR K<8 ALLOW MODEL-DEPENDENT CHOICES                    
!                                                                       
!     JCHAR=JUNIT                                                       
!                                                                       
!     1       CHOOSES TROPICAL                                          
!     2         "     MID-LATITUDE SUMMER                               
!     3         "     MID-LATITUDE WINTER                               
!     4         "     HIGH-LAT SUMMER                                   
!     5         "     HIGH-LAT WINTER                                   
!     6         "     US STANDARD                                       
!                                                                       
!                                                                       
!     JUNIT(K) FOR K>7 CHOOSES FROM THE SINGLE TRACE CONSTITUENT        
!     PROFILES, ALL APPRORIATE FOR THE US STD ATMOSPHERE                
!                                                                       
!     ***  NOTE ***  T<0 WILL ALSO PRINT OUT A MESSAGE INDICATING       
!     ***  A POSSIBLE MISAPPLICATION OF TEMPERATURE UNITS, (K) VS (C)   
!                                                                       
!     ******************************************************************
!  
      USE lblparams, ONLY: MXMOL
                                                                   
      PARAMETER (NCASE=15, NCASE2=NCASE-2) 
      !parameter (mxmol=39) 
                                                                        
      COMMON /IFIL/ IRD,IPR,IPU,NPR,NFHDRF,NPHDRF,NFHDRL,               &
     &     NPHDRL,NLNGTH,KFILE,KPANEL,LINFIL,                           &
     &     NFILE,IAFIL,IEXFIL,NLTEFL,LNFIL4,LNGTH4                      
      COMMON /CARD1B/ JUNITP,JUNITT,JUNIT(NCASE2),WMOL(NCASE),          &
     &                WAIR,JLOW                                         
!                                                                       
      real*8           dum1 
      CHARACTER*8      HDUM 
!                                                                       
      COMMON /MLATML/ ALT(50),PMATM(50,6),TMATM(50,6),AMOL(50,8,6),     &
     &                dum1(6,3),HDUM(3),dum2(50,3),DUM3(50,mxmol),IDUM  
      COMMON /TRACL/ TRAC(50,22) 
!                                                                       
      DATA PZERO /1013.25/,TZERO/273.15/,XLOSCH/2.6868E19/ 
!                                                                       
!     *** 4PT INTERPOLATION FUNCTION                                    
!                                                                       
      VAL(A1,A2,A3,A4,X1,X2,X3,X4) = A1*X1+A2*X2+A3*X3+A4*X4 
!                                                                       
!                                                                       
      NMOL = 1 
      ILOWER = 0 
      IUPPER = 0 
      IM50 = 50 
      DO 10 IM = 2, IM50 
         I2 = IM 
         IF (ALT(IM).GE.Z) GO TO 20 
   10 END DO 
      I2 = IM50 
   20 I1 = I2-1 
      I0 = I2-2 
      I3 = I2+1 
      IF (I0.LT.1) GO TO 30 
      IF (I3.GT.IM50) GO TO 40 
!                                                                       
      GO TO 60 
!                                                                       
!     LOWER ENDPOINT CORRECTION                                         
!                                                                       
   30 CONTINUE 
      ILOWER = 1 
      I0 = I1 
      I1 = I2 
      I2 = I3 
      I3 = I3+1 
      GO TO 60 
!                                                                       
!     UPPER ENDPOINT CORRECTION                                         
!                                                                       
   40 CONTINUE 
      IUPPER = 1 
      IF (Z.GT.ALT(IM50)) GO TO 50 
      I3 = I2 
      I2 = I1 
      I1 = I0 
      I0 = I1-1 
      GO TO 60 
!                                                                       
!     UPPER ENDPOINT EXTRAPOLATION                                      
!                                                                       
   50 CONTINUE 
      Z0 = ALT(I0) 
      Z1 = ALT(I1) 
      Z2 = ALT(I2) 
      Z3 = Z2+2.*(Z-Z2) 
      IUPPER = 2 
      WRITE (IPR,900) Z 
      STOP 'DEFAULTZ' 
!                                                                       
!     I3=I2                                                             
!     GO TO 31                                                          
!                                                                       
!     LAGRANGE CONTINUATION                                             
!                                                                       
   60 CONTINUE 
!                                                                       
!     LAGRANGE COEF DETERMINATION                                       
!                                                                       
      Z1 = ALT(I1) 
      Z2 = ALT(I2) 
      Z0 = ALT(I0) 
      Z3 = ALT(I3) 
      DEN1 = (Z0-Z1)*(Z0-Z2)*(Z0-Z3) 
      DEN2 = (Z1-Z2)*(Z1-Z3)*(Z1-Z0) 
      DEN3 = (Z2-Z3)*(Z2-Z0)*(Z2-Z1) 
      DEN4 = (Z3-Z0)*(Z3-Z1)*(Z3-Z2) 
      A1 = ((Z-Z1)*(Z-Z2)*(Z-Z3))/DEN1 
      A2 = ((Z-Z2)*(Z-Z3)*(Z-Z0))/DEN2 
      A3 = ((Z-Z3)*(Z-Z0)*(Z-Z1))/DEN3 
      A4 = ((Z-Z0)*(Z-Z1)*(Z-Z2))/DEN4 
!                                                                       
!                                                                       
!     TEST INPUT PARAMETERS (JUNIT'S) SEQUENTIALLY FOR TRIGGER          
!     I.E.  JUNIT(P,T,K) = 1-6                                          
!                                                                       
      IF (JUNITP.GT.6) GO TO 70 
      MATM = JUNITP 
!                                                                       
!     WRITE (IPR,60) Z,MATM                                             
!                                                                       
      X1 =  LOG(PMATM(I0,MATM)) 
      X2 =  LOG(PMATM(I1,MATM)) 
      X3 =  LOG(PMATM(I2,MATM)) 
      X4 =  LOG(PMATM(I3,MATM)) 
      IF (IUPPER.EQ.2) X4 = X3+2*(X3-X2) 
      P = VAL(A1,A2,A3,A4,X1,X2,X3,X4) 
      P = EXP(P) 
   70 IF (JUNITT.GT.6) GO TO 80 
      MATM = JUNITT 
!                                                                       
!     WRITE (IPR,65) Z,MATM                                             
!                                                                       
      X1 = TMATM(I0,MATM) 
      X2 = TMATM(I1,MATM) 
      X3 = TMATM(I2,MATM) 
      X4 = TMATM(I3,MATM) 
      T = VAL(A1,A2,A3,A4,X1,X2,X3,X4) 
   80 DO 110 K = 1, NMOL 
         IF (JUNIT(K).GT.6) GO TO 110 
!                                                                       
         IF (K.GT.7) GO TO 90 
         MATM = JUNIT(K) 
!                                                                       
         X1 = AMOL(I0,K,MATM) 
         X2 = AMOL(I1,K,MATM) 
         X3 = AMOL(I2,K,MATM) 
         X4 = AMOL(I3,K,MATM) 
         GO TO 100 
   90    ITR = K-7 
         MATM = 6 
!                                                                       
         X1 = TRAC(I0,ITR) 
         X2 = TRAC(I1,ITR) 
         X3 = TRAC(I2,ITR) 
         X4 = TRAC(I3,ITR) 
  100    WMOL(K) = VAL(A1,A2,A3,A4,X1,X2,X3,X4) 
         JUNIT(K) = 10 
         GO TO 110 
!                                                                       
!        53 JUNIT(K)=10                                                 
!        WRITE(IPR,54)K                                                 
!        54 FORMAT('  **** INCONSISTENCY IN THE USER SPECIFICATION',    
!        A ' , JUNIT = 9 AND WMOL(K) = 0 , K =',I2,/,                   
!        B '  ****   DENNUM(K) HAS BEEN SET TO 0, NOT DEFAULT VALUE')   
!                                                                       
  110 END DO 
      WMOL(12) = WMOL(12)*1.0E+3 
!                                                                       
!     THE UNIT FOR NEW PROFILE IS PPMV.                                 
!                                                                       
      RETURN 
!                                                                       
!     100  CONTINUE                                                     
!                                                                       
!                                                                       
!     STOP'DEFAULT'                                                     
!                                                                       
  900 FORMAT(/,'   *** Z IS GREATER THAN 120 KM ***, Z = ',F10.3) 
!                                                                       
      END                                           
      BLOCK DATA ATMCOL 
!                                                                       
!     >    BLOCK DATA                                                   
!     ******************************************************************
!     THIS SUBROUTINE INITIALIZES THE CONSTANTS  USED IN THE            
!     PROGRAM. CONSTANTS RELATING TO THE ATMOSPHERIC PROFILES ARE STORED
!     IN BLOCK DATA MLATMB.                                             
!     ******************************************************************
!                                                                       
      USE lblparams, ONLY: MXFSC, MXLAY, MXZMD, MXPDIM, IM2,      &
                                  MXMOL, MXTRAC, MX_XS
!      PARAMETER (MXFSC=600, MXLAY=MXFSC+3,MXZMD=6000,                   &
!     &           MXPDIM=MXLAY+MXZMD,IM2=MXPDIM-2,MXMOL=39,MXTRAC=22)    
!                                                                       
      COMMON /CONSTL/ PZERO,TZERO,ADCON,ALZERO,AVMWT,AMWT(MXMOL) 
      DATA PZERO/1013.25/,TZERO/273.15/ 
!                                                                       
!     **   ALZERO IS THE MEAN LORENTZ HALFWIDTH AT PZERO AND 296.0 K.   
!     **   AVMWT IS THE MEAN MOLECULAR WEIGHT USED TO AUTOMATICALLY     
!     **   GENERATE THE LBLRTM BOUNDARIES IN AUTLAY                     
!                                                                       
      DATA ALZERO/0.1/,AVMWT/36.0/ 
      DATA    AMWT /   18.015 ,  44.010 , 47.998 , 44.01 ,              &
     &              28.011 ,  16.043 , 31.999 , 30.01 ,                 &
     &              64.06  ,  46.01  , 17.03  , 63.01 ,                 &
     &              17.00  ,  20.01  , 36.46  , 80.92 ,                 &
     &             127.91  ,  51.45  , 60.08  , 30.03 ,                 &
     &              52.46  ,  28.014 , 27.03  , 50.49 ,                 &
     &              34.01  ,  26.03  , 30.07  , 34.00 ,                 &
     &              66.01  , 146.05  , 34.08  , 46.03 ,                 &
     &              33.00  ,  15.99  , 98.    , 30.00 ,                 &
     &              97.    ,  28.05  , 32.04  , 94.94 ,                 &
     &              41.05  ,  88.0043, 50.06  , 51.05 ,                 &
     &               2.016 ,  44.08  , 80.066 /                         
!     approx;                                                           
!                                                                       
      END                                           
      SUBROUTINE YDIAR (IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH &
     &                 ,RAINRT,GNDALT,YID)                              
!                                                                       
!     IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,VIS,WSS,WHH,RAINRT,GNDALT     
!                                                                       
      DIMENSION YID(10) 
!                                                                       
      CHARACTER*8      YID 
!                                                                       
      CHARACTER GOUT*64,BLNK*18 
      DATA BLNK / '                  '/ 
      WRITE (GOUT,900) (YID(I),I=3,7) 
      IVIS = VIS*10 
      IWSS = WSS*10 
      IWHH = WHH*10 
      IRAINR = RAINRT*10 
      IGNDAL = GNDALT*10 
      WRITE (GOUT(19:40),905) IHAZE,ISEASN,IVULCN,ICSTL,ICLD,IVSA,IVIS, &
     &   IWSS,IWHH,IRAINR,IGNDAL                                        
      GOUT(1:18) = BLNK(1:18) 
      READ (GOUT,900) (YID(I),I=3,7) 
!                                                                       
      RETURN 
!                                                                       
  900 FORMAT (8A8) 
  905 FORMAT (4I1,I2,I1,I4,3I3,I2) 
!                                                                       
      END                                           
