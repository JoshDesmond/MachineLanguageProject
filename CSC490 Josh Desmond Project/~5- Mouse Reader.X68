*-----------------------------------------------------------
* Title      : Mouse Reader
* Written by : Josh Desmond
* Date       : 5/15/14
* Description: This program will have a main loop that increments
* a counter. When the mouse is pressed, the program will respond
* with the coordinates of the mouse press and will display the
* current counter.
*
* MAIN LOOP:
* 1: Add one to counter
* 2: If (mouseFlag == true) {
* print out the x and y coords}
* 3: If (true) {run Main Loop}
*
* MouseDown IRQ: (An IRQ is an iterrupt request), it will stop the thread
* 1: Get the X and Y of the mouse and store the variables on DRegisters
* 2: Turn on the mouseFlag
*-----------------------------------------------------------

	ORG	$1000
START  

    move.l  #mouseDownIRQ,$70       ; IRQ4
    ; #mouseDownIRQ is an arbitrary name that points to the
    ; exception script I titled mouseDownIRQ. The $70 is a
    ; 68000 constant: There are 7 reserved locations for IRQ's
    ; and the fourth (which was again arbitrarily choosen) 
    ; was $70. $74 for example would be IRQ5.
    
    move.b  #60,d0                  ; We are about to call trap #60
    move.w  #$0401,d1               ; TrapTask #60 defining the IRQ
    trap    #15
    ; Okay, this is kind of complicated: TT #60, according to the help
    ; documentation: "An IRQ is created when a mouse button is pressed 
    ;   or released in the output window.
    ; D1.W High Byte = IRQ level (1-7), 0 to turn off
    ; D1.W Low Byte = 1 in the corresponding bit to indicate which 
    ;   mouse event triggers IRQ where:
    ;      Bit2 = Move, Bit1 = button Up, Bit0 = button Down
    ;
    ; So for my instruction, I am saying "IRQ level 4 for (01), which
    ;   button Down.


*-----------------------------------------------------------
* Main Loop
* NOP is an instruction that causes a (very tiny) pause. This
* is just to ensure I don't overuse my CPU

Loop
    nop             ; Pause a bit
    If flag1 <eq> #255 THEN
        bsr     mousePrint
        not.b   flag1
    ENDI
    addq.l  #1,D7   ; D7 is the register working as the counter
    
    bra     Loop    ; Branch Always to loop
    

*-----------------------------------------------------------
* mouseDownIRQ
* mouseDownIRQ will call mouseParse after recording the state
* of the mouse.

mouseDownIRQ
    move.b  #61,D0
    move.b  #0,D1   ; This is part of TT #61, D1 will read a certain
                    ; Mouse state, and in this case, it is reading the
                    ; current mouse state. (It could be #2 for mouse
                    ; down state, or #1 for the last time the mouse
                    ; was in the up state).
    trap    #15
    ; After running TT #61, we have read and stored the mouse state in
    ; D0 and D1. According to the documentation, this is how TT #61 stores
    ; the data: "Post: The mouse data is contained in the following registers:
    ;    D0 as bits = Ctrl, Alt, Shift, Double, Middle, Right, Left
    ;       Left is Bit0, Right is Bit 1 etc. 1 = true, 0 = false
    ;       Shift, Alt, Ctrl represent the state of the corresponding keys.
    ;    D1.L = 16 bits Y, 16 bits X in pixel coordinates. (0,0 is top left)
    
    ; Since we only care about the pixel coordinates of the click, we can
    ; ignore D0, and run the following code to parse D1 for the coordinates.
    
    bsr mouseParse
    
    not.b   flag1
    
    rte             ; Return From Exception (because this is
                    ; an IRQ
                    

*-----------------------------------------------------------
* mouseParse:
* PRECONDITION: D1.L contains the pixel coordinates of the 
* mouse condition to be read.
* POSTCONDITION: D1.L will be set to 0
* POST: D4.l will contain mouseX
*       D5.l will contain mouseY
* 
* mouseParse will decode the coordinates stored in D1.L and
* store the coordinates in D4 and D5 (where D5 = X, D6 = Y)

mouseParse
    move.l  d1,d2               ; Copies D1.L into D5 (the Y Register)
    and.l   #$0000FFFF,d1       ; remove Y from D1 (We only want the low bytes)
    move.w  d1,mouseX
    
    swap    D2                  ;bitwise swapping of the first word and second word of D5
    and.l   #$0000FFFF,D2       ;now that the x and y has been swapped, and out the X to save just the y
    move.w  d2,mouseY
    rts 
    
*-----------------------------------------------------------
* mousePrint:
* PRECONDITION: D5.l contains X, and D6.l contains Y
* POST: prints the coordinates of X and Y

mousePrint
    MOVEM    D0-D4,-(SP)    ;pushes D0-D4 onto the stack, and thus saves the variables from descruction
    
    move.b  #14,d0
    lea     promptX,a1
    trap    #15     prints promptX
    
    move.w  mouseX,d1   ;Trap Task #3 displays the int a D1
    move.b  #3,d0   ;meaning this will print the X out.
    trap    #15
    
    move.b  #14,d0
    lea     promptY,a1
    trap    #15     prints promptY
    
    move.w  mouseY,d1   ;Trap Task #3 displays the int a D1
    move.b  #3,d0   ;meaning this will print the Y out.
    trap    #15
    
    move.b  #14,D0
    lea     promptT,a1
    trap    #15     prints promptT
    
    move.l  d7,d1   d6 is the register containing the counter
    move.b  #3,d0   ;displays int in D1
    trap    #15
    
    MOVEM    (SP)+,D0-D4    ;pops from the stack D0-D4, to return the registers to their original position
    
    rts
    


*-----------------------------------------------------------
* Variable storage and strings
* ds (define storage) is used to reserve memory for variables
* dc (define constant) is used to place data in memory

CR  EQU     $0D   Carriage Return
LF  EQU     $0A   Line Feed

flag1
    ds.b    1
    ds.w    0
    
mouseX
    ds.w    1
mouseY
    ds.w    1

promptX
    dc.b    CR,LF,'The X is: ',0
promptY     
    dc.b    CR,LF,'The Y is: ',0
promptT     
    dc.b    CR,LF,'The Time is: ',0

    END    START

*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
