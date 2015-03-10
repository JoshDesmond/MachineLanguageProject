*-----------------------------------------------------------
* Title      :Input Branching Tutorial
* Written by :Josh Desmond
* Date       :5/6/14
* Description:The following program will interpret user
*            :input and run different sections of code
*            :depending on what was input.
*-----------------------------------------------------------

* Defining what are essentially static final "variables" *
*--------------------------------------------------------*
CR              EQU         $0D
LF              EQU         $0A

* Start of the program *
*----------------------*
START           ORG         $1000


* This is the message output Loop *
*---------------------------------*
LOOP            LEA         LMESSAGE,A1
                MOVE.B      #14,D0
                TRAP        #15
                
                ;LEA loads LMESSAGE (defined above) into A1.
                ;This is because Trap Task 14 prints what is in
                ;the A1 Register. TRAP will run Trap Task 14
                ;Because #14 is in the D0 register and that's
                ;What TRAP #15 looks for specifically
                
                
* This is code run after the Loop, awaiting INPUT *
*-------------------------------------------------*
INPUT           MOVE.B      #4,D0
                TRAP        #15
                ;TRAP Task #14 awaits a response from the keyboard
                ;and then sets D1 to the input. We can now evaluate
                ;or branch depending on the value of D1 at the moment
                
* This is the code that will compare the input to values, and then *
* accordingly branch to the proper section of code after           *
*------------------------------------------------------------------*
                
                CMP.B       #0,D1
                BLT         INVALID
                ;CMP.B #0,D1 is comparing the value of D1 (which is
                ;our input), to the actual Byte 0000.
                ;BLT is saying to GOTO "INVALID" if the above statement
                ;evaluated to say D1 was less than 0. We're doing this
                ;because it outside of the range of valid inputs.
                
                CMP.B       #3,D1
                BGT         INVALID
                ;Again, if D1 is greater than the Byte sized int 3,
                ;then GOTO INVALID
                ;
                ;note: the mnemonic is that GT means Greater Than,
                ;and LT means less than, B is probably like Byte? 
                
* The goal here is to now figure out if D1 is == 0, 1, or 2, and then Execute *
*-----------------------------------------------------------------------------*

                CMP.B       #0,D1
                BNE         ONE
                ;If the program didn't jump, then D1 == #0, (NE means Not Equal)
                ;this means we can end the program now, but we'll keep a reference
                ;to DONE just incase it is needed.
                
DONE            MOVE.B      #9,D0
                TRAP        #15
                
ONE             CMP.B       #1,D1
                BNE         TWO
                ;Just like testing for Zero, we know the program would have jumped
                ;to TWO if D1 != #1. Thus, we can execute our message for inpute 1
                
                LEA         DISPONE,A1
                MOVE.B      #14,D0
                TRAP        #15
                ;Now that the message has been displayed, we can branch back to
                ;INPUT, and await another command.
                BRA         INPUT
                
                
TWO             LEA         DISPTWO,A1
                MOVE.B      #14,D0
                TRAP        #15 
                BRA         INPUT
                
                
                
                
* If the inputted value is outside of the range of proper values, GOTO here *
*---------------------------------------------------------------------------*
INVALID         LEA         IMESSAGE,A1
                MOVE.B      #14,D0
                TRAP        #15
                ;This is the same code as in LOOP, only now the
                ;message being loaded is IMESSAGE, which is defined
                ;at the beginning of the program.
                
                BRA         LOOP
                ;Branch back to the loop, which will display the first
                ;message again.
                
                
* Writing our variables into memory *
*-----------------------------------*
LMESSAGE        DC.B    'Press any number between 0 and 3: 0 will quit',CR,LF,0
IMESSAGE        DC.B    'That is not a valid number man!',CR,LF,0
DISPONE         DC.B    'You pressed one!',CR,LF,0
DISPTWO         DC.B    'You pressed two! (or three...)',CR,LF,0

    END    START        ; last line of source


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
