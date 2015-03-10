*-----------------------------------------------------------
* Title      : Writing "Methods"
* Written by : Josh Desmond
* Date       : 5/7/14
* Description: This program will be an exercise in writing
* the equivilent of "methods". The user will be prompted to
* call one of three different methods, each which are written
* in different sections of the code. Data is transferred, or
* given to methods via the STACK. 
*-----------------------------------------------------------

            ORG	    $1000
START  

*-----------------------------------------------------------
* The first task is to prompt the user to input a task,
* and to input values that will be executed upon. 

            move    #14,D0
            lea     promptIntro,A1
            trap    #15
            ;trap #15 will run the trap task according to D0,
            ;which was set to #14. Task 14 prints the message
            ;in the A1 register, which is promptIntro, defined
            ;in the variables section at the end of the program
            
INPUT       move    #4,D0
            trap    #15
            ;trap task #4 will take the inputted value from
            ;the user IO and store it in D1.L
            ;If the value is 1: Add two numbers.
            ;If the value is 2: Multiply two numbers.
            ;And if the value is 0: Quit the program.
            ;If the value is not 0-2, run the error sequence
            
            cmp     #0,D1
            ;CMP compares the number 0 with the value that was
            ;just entered. What this does is change the CCR register.
            ;The CCR register can be analyzed in the next lines
            ;of code in order to figure out what was just input.
            blt     ERROR   Branch to ERROR if the command was less than 0
            
            cmp     #2,D1   Branch to ERROR if the command was greater than 2
            bgt     ERROR
            
            cmp     #0,D1
            beq     DONE    Branch do DONE if command == 0
            
            cmp     #2,D1
            beq     TWO     Branch to TWO if command == 2
            
            move.b  #1,D4   Store the value in D4
            bra     VALUES
                     

TWO         move.b  #2,D4   Store the value in D4.
            bra     VALUES  in case more code needs to be added
                           ;this is here as a safeguard
                           
*-----------------------------------------------------------
* VALUES: by now, we know according to D4 if we have to
* add the two numbers or if we have to multiply the two.
* The goal here is to take two numbers for multiplication.

VALUES
            
            move    #14,D0
            lea     promptNumber,A1
            trap    #15
            ;Prints the message asking for the first number
            
            move    #4,D0
            trap    #15
            ;Inputs a number from IO and stores it in D1
            
            move.l  D1,-(SP)
            ;This command is moving the first value (which is num1)
            ;to the Stack Pointer. This is a "Push" command for
            ;the stack. The - is moving the stack so we can put
            ;another value into the SP. It's location will then
            ;be know relatively according to the SP when the data
            ;is used in a later method.
            
            move    #14,D0
            lea     promptSecond,A1
            trap    #15
            ;Prints the message asking for the second number
            
            move    #4,D0
            trap    #15
            ;Inputs a number from IO and stores it in D1
            
            move.l  D1,-(SP)
            ;This again pushes the second number into the stack
            move.l  #666,-(SP)
            ;This is to make room for the sum in the stack. The
            ;stack will move backwards more and write a zero in
            ;the place of sum (or product). (I changed it to #666
            ;to identify if what the problem is).
            
*-----------------------------------------------------------
* THE IF STATEMENT: In this section of the code, we now have
* two numbers stored in the stack, and we have our D4 register
* storing either a 1 or a 2. This section of the code runs the
* subsection MULTSEQ if D4 == 2, and else, will run ADDSEQ.
* The code will then converge back into one sequence after the
* if else statement.

            cmp     #1,D4
            beq     IF1    Branch if equal to IF.1
            bra     ELSE1  Otherwise branch to ELSE.1
IF1        
            bsr     ADDSEQ  If D4 == 1, Add
            bra     BACK1  Skip over that next line
ELSE1         
            bsr     MULTSEQ Multiply them and come back
            
BACK1      
            

            
            
*-----------------------------------------------------------
* CONVERGING BACK: The correct function has been run, and now
* this section of code just pops the value calculated from the
* stack and loops back to START.
            
            move.l  (SP)+,D1
            ;This is a pop command, it pops the value from the
            ;stack to be stored back onto D1. D1 is printed
            ;via Trap Task #3, which is run in a tiny bit...
            
            lea     (8,SP),SP
            ;This is "cleaning" the stack. What it's actually
            ;doing is moving the Stack Pointer forward eight
            ;units. The reason its 8, is probably because that's
            ;the offset we declared. It could also be because
            ;that's just how much LINK auto moves the pointer?
            ;However that's unlikely.
            
            move    #14,D0      prints the prompt for answer:
            lea     promptAnswer,A1
            trap    #15     
            
            move    #3,D0       prints D1
            trap    #15
            
            move    #14,D0      prints a new line
            lea     clrf,A1
            trap    #15
            
            bra     START   Loop back to start (Branch Always)
            
            
            
            
*-----------------------------------------------------------
* ERROR: Prints the error message when an invalid number is
* input, and returns the program back to the start.
* Also clears the D1 register.

ERROR
            move    #14,D0
            lea     promptError,A1
            trap    #15
            
            bra     INPUT

*-----------------------------------------------------------
* ADDSEQ: this subroutine will add the numbers stored
* and passed by the stack. 

            OFFSET  8       I have no clue what 4+4 is doing here...
sum         ds.l    1       The tutorial said it was "four bytes of A0
num1        ds.l    1       saved by link, and four bytes for return
num2        ds.l    1       address. So idk.
            ORG     *
            
            ;What this table is doing is easily defining and calculating a distance for us
            ;This is an alternative way of representing the table:
            ;OFFSET = 8
            ;sum = 8 = 8
            ;num1 = 8 + sum.length = 8 + 4 = 12
            ;num2 = 8 + sum.length + num1.length = 4 + 12 = 16
            ;
            ;These numbers are only representing distances, nothing else.
            ;Thats why in the commands we are writing (num1,A0), that represents
            ;the figure of memory that's at num1 (=12) below A0's first entry.

ADDSEQ
            
            link    A0,#0
            ;What we're doing here is moving the SP from -(SP);SP over to the A0
            ;register. We're creating a local workspace instead of working right on
            ;the SP. The #0 is there if we wanted to allocate extra space to our local
            ;stack frame, however, we don't need to make any extra space so it's left at
            ;zero. It would be a negative number if we wanted to make SP + #n -> SP and
            ;allocate extra space.
            
            move.l  D0,-(SP)
            ;Okay, so this command here is what is going to prevent us from accidently
            ;destorying D0. Because we'll be doing the addition on D0, we are temporarily
            ;storing D0 onto the stack, for the situation that someone calls ADDSEQ with the
            ;hope that we didn't destroy what was on the D0 register. We can retrieve and restore
            ;the D0 register later in this sub routine
            
            move.l  (num1,A0),D0
            ;Right now we're popping the top value from the stack. Just like in the regular code
            ;how we were pushing values onto (SP) to store them, we're now popping from the stack
            ;by moving in the opposite direction. num1,A0 is a location itself.
            
            add.l   (num2,A0),D0
            ;This is popping another value from the stack, specifically, whatever offset is
            ;labeling to be num2. Then we're adding this number with whatever D0 is, and storing
            ;the value on D0 as well. So D0 = num2 + D0.
            
            move.l  D0,(sum,A0)
            ;So we have the offset chart at the top, yeah? There are three terms that are being
            ;described, sum is 8 away from A0, because it's the first and the offset is 8 (the
            ;reason its 8 is because sbr uses 4 to store where it has to go back in the stack,
            ;and link creates 4 to store whatever A0 was.
            
            move.l  (SP)+,D0
            ;This command is the opposite of the one, like, three lines above, this is saying,
            ;take what I put on the top of the stack pointer, and put it back on D0. But what
            ;we're doing with the SP here and the reason there's this + and - notation going on
            ;is that we're "unarily"(?) affecting it. It's like saying SP++ or SP--. So we move
            ;the SP backwards and put D0 there, then now, we're moving it back forwards where it
            ;was and retrieiving D0. We haven't been messing with SP so it'll still be there.
            
            unlk    A0                      
            ;Removes local workspace from stack
            
            rts
            ;Return to script. Now we've stored sum right back on the top of the stack pointer
            ;since we just unlinked A0. So I guess that means A0 like, moves its data to 
            ;to A7 I guess?
            

*-----------------------------------------------------------
* MULTSEQ: this subroutine will multiply the numbers stored
* in the stack

            OFFSET  8
prod        ds.l    1
val1        ds.l    1
val2p1      ds.w    1
val2p2      ds.w    1
            ORG     *
            ;Okay, this offset table looks different than the ADDSEQ table.
            ;The reason for this is that multiply can only happen with at max
            ;two WORDS, as opposed to add, which can add two LONGS. So, basically,
            ;in order to have both MULTSEQ and ADDSEQ work exactly the same way,
            ;this is just ignoring the first half of the LONG.
            ;
            ;--prod is normal, and is working just like sum is in ADDSEQ.
            ;--val1 is a little bit deceiving, because it's actually not a "LONG",
            ;while it's being labeled as a "LONG". The reason is that I can move the
            ;LONG val1 onto a register, and it will move both WORDS making up the LONG.
            ;Then I can run multiply and just prentend like I only moved over the second
            ;half of the value entered.
            ;--val2p1 is part 1 of val2. I'm divided the long that was entered into two
            ;words and calling them different things. val2p1 is going to be ignored, because
            ;we can only multiply words together.
            ;--val2p2 is the second part of val2, which is a word. I'm calling this value in
            ;the code in MULTSEQ.

MULTSEQ 
            link    A0,#0
            ;See ADDSEQ for explanation.
            move.l  D0,-(SP)
            ;Storing D0 register at the stack and moving the stack pointer down.
            move.l  (val1,A0),D0
            ;moving the long val1 into D0
            muls.w  (val2p2,A0),D0
            ;multiplying the second half of the second long stored (which is called
            ;val2p2) with the second half of the long already stored on D0, and then
            ;storing the answer on D0. D0 = D0 * val2p2
            move.l  D0,(prod,A0)
            ;Move D0 onto the stack at the label prod (which is 8 away as defined
            ;by the offset table
            move.l  (SP)+,D0
            ;restore the original value of D0 that was kept by the SP
            unlk    A0
            ;Stop using A0 as the local stack pointer.
            rts
            ;rts means return to script.
            ;the value of prod is now stored at the top of the stack,
            ;and the next command called will be to pop the top value from SP.
            
*-----------------------------------------------------------
* DONE: If the user entered 0, we can end the program.
*

DONE
            move.b  #9,D0
            trap    #15
            ;Trap task #9 halts the simulation

            SIMHALT

*-----------------------------------------------------------
* Variable storage and strings
* ds (define storage) is used to reserve memory for variables
* dc (define constant) is used to place data in memory

clrf        dc.b     $d,$a,0                   


promptIntro dc.b    'Hello, welcome to "Methods", enter 1 to add,',$d,$a
            dc.b    'or enter 2 to multiply, or 0 to quit:',$d,$a,0
promptNumber
            dc.b    'Now enter a number: ',$d,$a,0
promptSecond
            dc.b    'And another number: ',$d,$a,0
promptAnswer
            dc.b    'The answer is: ',0
promptError
            dc.b    'That is not a valid answer.',$d,$a,0       


    END    START




*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
