# Assembly
Assembly Examples written in ARM Assembly for TM4C123GH6PM microcontroller

This examples are written in ARM assebly for TM4C123GH6PM uC. If you use other uC, then you should change the register base addresses according to you uC.Some subroutines are used in other subroutines which is uploaded.
//*********************************EXAMPLE1***************************************************************************************
 CONVRT Subroutine
Description:
Write a subroutine, CONVRT, that converts an m-digit decimal number represented by n
bits (n < 32) in register R4 into such a format that the ASCII codes of the digits of its decimal
equivalent would listed in the memory starting from the location address of which is stored in
register R5. When printed using OutStr, the printed number is to contain no leading 0s, that is,
exactly m digits should be printed for an m-digit decimal number. Before writing the subroutine,
the corresponding pseudo-code or flow chart is to be generated. TERMIT is used for the terminal part in UART communication.
Some exemplar printings (righthand side) for the corresponding register contents (lefthand side)
are provided below:
R4: 0x7FFFFFFF --- 2147483647 (max. value possible)
R4: 0x0000000A --- 10
R4: 0x00000000 --- 0

//*********************************EXAMPLE2*************************************************************
NUM subroutine
Description:
Write a program that, in an infinite loop, waits for a user prompt (any key to be pressed on keyboard) and
prints the decimal equivalent of the number stored in 4 bytes starting from the memory location
NUM to TERMIT terminal by using UART.
//**********************************EXAMPLE3*****************************************************************
Binary Search Subroutine
Description:
Write a program for decimal number guessing using binary search method. The number is
to be an integer in the range (0, 2
n), i.e. 0 < number < 2^n, where n < 32 and n is determined by a user-input from TERMIT terminal via UART. Then, the guessing phase is to be handled through a simple interface where the processor outputs its current guess in decimal base and calculate the next according to the user inputs, D standing for down, U standing for up, or C standing for correct. To fulfill the requirements given above, include the subroutine CONVRT from the Part-1 in your main program as well as a new subroutine UPBND that updates the search boundaries after each guess. 
//**********************************EXAMPLE4*****************************************************************

RECURSIVE function
Description:
Imagine you are in a fantastic realm where you are trapped in a fortress controlled by two
evil creatures. Surprisingly enough, Vol’jin, the keeper of the fortress, the former of the two, is a
little bit whimsy, he likes to play games with his hostages. Hence, he offers you your freedom in
exchange with your complicity, sort of a quid pro quo. He lends you a number of soulstones to
be able to travel through portals and meanwhile do his dirty work. There are 4 portals that are
created within the great hall of the fortress in which you can consume the soulstones upon passing
through and return back to the great hall. Besides, within the great hall, there is a 5th portal,
namely, the Dark Portal, that leads to the way out and it is guarded by Gul’dan. As is so often
the case when Gul’dan, the latter and the more sinister of the two, is wroth by Vol’jin’s monkey
business, he vents his anger on the hostages. He loathes the idea that those poor mortals would
lay hands on his mighty soulstones. You had better not get caught red-handed, needless to say,
with any soulstones left or he will make you suffer as much as you carry.
Now that you are totally aware of the fact that each and every one of the claimed at the beginning
are to be employed before facing Gul’dan, you search for the aforementioned portals. However,
upon your reach at the portal, you notice that activation of each portal obeys a different criterion.
8
Portal 1 : If the traveler has a number of soulstones larger than 99, this portal can be
activated using 47 soulstones.
Portal 2 : This one allows travelers holding an odd, larger than 50, number of soulstones
provided that they use an amount that is equal to multiplication of the non-zero digits, in
decimal base, they already have in hand to pass through.
Portal 3 : Greedy by nature, this portal allows all travelers, except for the odd-numberbearers, to pass, by looting half of the soulstones.
Portal 4 : If the number of soulstones remaining is a multiple of 7, then this portal is
unlocked with the maximum number of soulstones possible, that is to be a multiple of 3.
To make the long story short, you are expected to create a RECURSIVE function that returns
the minimum number of soulstones where no further move is possible. Develop a flowchart or
pseudo-code of the algorithm and the corresponding assembly code itself and determine your fate,
(wheter you will flee or how much you will howl with pain), assuming that the number of soulstones
retrieved at the beginning is a user-input. Please remember that the input is to be provided via
Termite in decimal base and you are expected return the output via Termite in decimal base.
The following examples are to illustrate what is meant by the aforementioned explanations.
Ex: If you are given 147 soulstones, you may flee with none (0 soulstones) since it is possible to
spend them in a single step as such:
147 ---- Portal 4 ---- 0
Input: 147, Output: 0
Nevertheless, there is no possible way to spend all the soulstones if the initial is 100:
100 ---- Portal 3 ---- 50
50 ---- Portal 3 ---- 25
OR
100 ---- Portal 1 ---- 53
53 ---- Portal 2 ---- 38
38 ---- Portal 3 ---- 19 (min possible)
Input: 100, Output: 19
EDIT: This subroutine has some problems since lack of time I couldnt focus on it. it is open to be improved.
//**********************************EXAMPLE5*****************************************************************
100Ms DELAY
Description:
 Write a subroutine, DELAY100, that causes approximately 100 msec delay upon calling
 
 //**********************************EXAMPLE6*****************************************************************
 DATA TRANSFER
 Description:
 Write a program for a simple data transfer scheme. You are required to take inputs from
push buttons and reflect the status of the buttons to the LEDs that are connected to the output
port for approximately every 5 seconds. Namely, an input should be read for every 5 seconds and
the status of that reading should remain at the output until the next reading. The status of a
pressed button is 1 and the status of a released button is 0. You should use low nibble of Port B
(B3 to B0) for inputs, and high nibble of Port B (B7 to B4) for outputs.

 //**********************************EXAMPLE7*****************************************************************
4x4 KEYPAD READING AND TRANSFERRING via UART
Description:
continuously detects which key is pressed and outputs the ID of the key through
Termite Window after the key is released. The IDs can be sequential numbers. For instance, the
ID of the key at row 1 and column 1 can be 0 and the key at row 4 and column 4 can be F (0:F
total 16 IDs). You may assume that only one key is to be pressed at a time and no other key
can be pressed before releasing a key. Your program should be robust to possible bouncing effect
during both pressing and releasing.
