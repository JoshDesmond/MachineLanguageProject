*-----------------------------------------------------------
* Title      :Hello World
* Written by :Josh Desmond
* Date       :5/6/14
* Description:
*-----------------------------------------------------------


START   ORG     $1000           ;first instruction of program, I don't really know what ORG means or what the
                                ;$1000 is doing there either. Hmph. The MESSAGE however is being stored straight
                                ;at point 1000 in the memory. So, it's probably something like that.

* Put program code here

        LEA     MESSAGE,A1      ;LEA stands for loads effective address. This command will load what is stored
                                ;at "MESSAGE" into the address register #1, A1
                                
        MOVE.B  #14,D0          ;This command moves the Byte sized (B for Byte) integer 14 (just the number
                                ;14 itself) into the D0 register. This is for use in the next step. What 14
                                ;means is that the next command will run Trap Task (15), #14. This is according to
                                ;the online documentation, "Display the NULL terminated string at (A1) without
                                ;CR, LF".
                                
        TRAP    #15             ;TRAP is a complicated instruction that has the opperand #n, which in this case
                                ;is 15 which is the TRAP used to run simulator tasks. This will run simulator task
                                ;#14
                                
        MOVE.B  #9,D0           ;This is again for use with the next TRAP task that will be run. #9 will terminate
                                ;the program.
                                
        TRAP    #15             ;Terminates the program, or Halts Simulator

 *-----------------------------------------------------------*
 *
 *-----------------------------------------------------------*

CR      EQU     $0D             ;$OD is the character for (ASCII code) Carraige Return
                                ;EQU seems to not be allocating any memory towards storing $OD, but simply lets
LF      EQU     $0A             ;CR and LF be referred to throughout the program.

MESSAGE DC.B    'Hello World',CR,LF     ;DC.B "reserves memory for the item following it". MESSAGE is a label that can be
                                        ;referred to in other portions of the program. The reason there is a zero at the
                                        ;end of the code is because TRAP Task #14 requires that the string is NULL terminated
                                        ;,or rather, it ends with a null.
        DC.B    'This is the second line',0   
                                
                                

        END     START           ; last line of source

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
