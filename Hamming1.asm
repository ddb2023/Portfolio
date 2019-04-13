;// Program Hamming(Hamming1.asm)
;// Dan Bennett
;// original program written 12/04/2016
;// upograded to include decoding 01/23/2019
;// program to encode binary data into hamming code
;// or decode hamming code into binary data
;// encodes from 1 to 32 bits of binary data

INCLUDE Irvine32.inc
;// the Irvine32.inc causes virus warnings because
;// some of it closely resembles known viruses
;// but it is safe and virus warnings can be ignored

.stack 4096

mWrite MACRO text
LOCAL string

.data
string BYTE text, 0; // define the string

.code
push edx
mov edx, OFFSET string
call WriteString
pop edx
ENDM

.data
DSIZE EQU 32
dataBits BYTE DSIZE DUP(0)
CSIZE EQU 39
codeBits BYTE CSIZE DUP(0)
checkBits BYTE CSIZE DUP(0)
errorBits BYTE CSIZE DUP(0)
parity BYTE 0
numBits BYTE 0
numDataBits BYTE 0
numTempBits BYTE 0
numCodeBits BYTE 0
parityErrorCount BYTE 0
preserveDl BYTE 0
blank BYTE " ", 0

.code

main PROC
mWrite "WTF Hamming code decoder and generator"
call crlf;
mWrite "Programmed by Dan Bennett 12/04/2016"
call crlf;
mWrite "Upgraded to include decoding 01/23/2019"
call Crlf

again : ;// beginning of main loop
call initDataArray; // initialize the data array
call initCodeArray; // initialize the code array
call initcheckArray; // initialize the parity check array
call initErrorArray; // initialize the error check array
mov numBits, 0; // intitialize number of bits to 0
mov numDataBits, 0; // initialize number of data bits to 0
mov numTempBits, 0; // initialize number of temporary bits to 0
mov numCodeBits, 0; // initialize number of code bits to 0
mov parityErrorCount, 0; // initialize parity error count to 0
mov preserveDl, 0; // initialize preserveD1 variable to 0
mov ecx, 1; // initialize exs to 1
call introduction; // call introduction function to display opening menu
jcxz endProgram;// jump to end of program if ecx register is 0
jc hammingRtn; // jump if carry set to hamming funciton
jnc binaryRtn; // jump if carry not set to binary function

;// function for encoding binary data to hamming code
binaryRtn:
call binaryEntry; // call function to get binary input
call xferBinaryToCode; // call function to transfer binary input to code array
call generateCode; // call to function to generate hamming code from binary input
call displayCode; // call to function to display the hamming code
jmp again; // jump to main loop

;// function for decoding hamming code to binary data
hammingRtn:
call hammingEntry; // gets code from user and places it in checkBits array
call extractDataBits; // gets data bits from checkBits array and places data bits in dataBits array
mWrite "Entered data bits"
call displayData; // displays data bits from dataBits array
call xferBinaryToCode; // copies data bits from dataBits array to codeBits array
call generateCode; // takes data bits from codeBits array to generate parity bits which are placed in codeBits array
call compareCodes; // compares entire checkBits array contents to codeBits array contents; // sets bits in errorBits
call checkParityBits; // checks parity bits in errorBits
jmp again; // jump to main loop

endProgram:
exit
main ENDP

;// function to initialize DataArray
initDataArray PROC
mov ecx, 32; // set ecx to 32
mov al, 0; // set al to 0
mov ebx, 0; // set ebx to 0
LoopDataInit:;// initializes data array to all 0's
mov[dataBits + ebx], al; // set dataBits + ebx to 0
inc ebx; // increment ebx so that offsset for dataBits points to next byte
Loop LoopDataInit; // continue initializing DataArray
ret
initDataArray ENDP

;// function to initialize CodeArray
initCodeArray PROC
mov ecx, 39; // set ecx to 39
mov al, 0; // set al to 0
mov ebx, 0; // set ebx to 0
LoopCodeInit:; // initializes code array to all 0's
mov[codeBits + ebx], al; // set codeBits + ebx to 0
inc ebx; // increment ebx so that offset for codeBits points to next byte
Loop LoopCodeInit; // continue initializing CodeArray
ret
initCodeArray ENDP

;// routing to initialitze CheckArray
initCheckArray PROC
mov ecx, 39; // set ecx to 39
mov al, 0;// set al to 0
mov ebx, 0; // set ebx to 0
LoopCheckInit:; // initialize CheckArray to all 0's
mov[checkBits + ebx], al; // set checkBits + ebx to 0
inc ebx; // increment ebx so that offset for checkBits points to next byte
Loop LoopCheckInit
ret
initCheckArray ENDP

;// function to initialize ErrorArray
initErrorArray PROC
mov ecx, 39; // set ecx to 39
mov al, 0; // set al to 0
mov ebx, 0; // set ebx to 0
LoopErrorInit:; // initialize ErrorArray to all 0's
mov[errorBits + ebx], al; // set errorBits + ebx to 0
inc ebx; // increment ebx so that offset for errorBits points to next byte
Loop LoopErrorInit
ret
initErrorArray ENDP

;// function to display menu and get user's choice between encoding and decoding
introduction PROC
begin : ; // menu loop
call crlf;
mWrite "Enter 1 to convert binary to Hamming code"
call Crlf
mWrite "Enter 2 to convert Hamming code to binary"
call Crlf
mWrite "Enter 3 to quit"
call Crlf
call ReadDec; // get selection from user
cmp eax, 1; // is selection 1 for encoding?
je binary; // if so jump to encoding function
cmp eax, 2; // is selection 2 for decoding?
je hamming; // if so jump to decoding function 
cmp eax, 3; // is selection to quit?
je quit; // if so quit program
mWrite "Invalid input"; // message for input tht is not 1, 2, or 3
call Crlf
jmp begin

hamming :
stc; // set carry flag
jmp endIntroduction; // jump to endIntroduction with carry flag set

binary:
clc; // clear carry flag
jmp endIntroduction; // jump to endIntroduction with carry flag cleared

quit:
mov ecx, 0; // set ecx to 0

endIntroduction:
ret;
introduction ENDP

;// funcion for selecting type of parity to use
setParity PROC
againP :
mWrite "Enter 1 for even parity"
call Crlf
mWrite "Enter 2 for odd parity"
call Crlf
call ReadDec
cmp al, 1; // compare input to 1 (for even parity)
je evenP; // jump to evenP if true
cmp al, 2; // compare input to 2 (for odd parity) 
je oddP; // jump to oddP if true
jmp againP; // try again if input is not 1 or 2
evenP:
mov parity, 0; // initialize parity variable to 0 (for even parity)
jmp endParity
oddP :
mov parity, 1; // initialize parity variable to 1 (for odd parity)
endParity:
ret
setParity ENDP

; // function for entering data to encode
hammingEntry PROC
call setParity; // call function to set type of parity to use for encoding
mWrite "Enter the number of bits in the Hamming code. "
call ReadDec; // get number of bits from user
mov numCodeBits, al; // copy number of bits into numCodeBits variable
mov numBits, al; // copy number of bits into numBits variable
mov numTempBits, al; // copy number of bits into numTempBits
mov ecx, eax; // copy eax into ecx
mov ebx, 0; // set ebx to 0
call Crlf
mWrite "Enter the bits one at the time, with each followed by Enter "
call Crlf
LoopEntry : ; // data entry loop
mWrite "Position #"
mov eax, ebx; // copy ebx into eax
inc al; // increment bit counter
call WriteDec; // write bit to screen
mov edx, OFFSET blank; // copy offset of blank (" ") to edx 
call WriteString; // write bit string to screen
call ReadDec; // get bit from user
mov[checkBits + ebx], al; // copy al to checkBits
inc ebx; // increment address offset
Loop LoopEntry; // continue entry of bits
ret
hammingEntry ENDP

; // function to extract data bits from hamming code
extractDataBits PROC
mov ebx, 0; // clear ebx
mov edx, 0; // clear edx
mov dl, numBits; // copy numBits into dl
sub dl, 2; // subtract 2 from dl
mov al, [checkBits + 2]; // copy value at checkBits + 2 into al
mov[dataBits], al; // copy al into dataBits
inc ebx; // increment offset
dec dl; // decrement counter
jz endExtractBits; // jump to endExtractBits if dl = 0
mov ecx, 3; // maximum number of bits in code
mov esi, 4; // offset from beginning of checkBits array
mov edi, 1; // offset from beginning of data array
dec dl; // decrement counter

LoopData2_4: ; // loop for decoding code bits 2 through 4
mov al, [checkBits + esi]; // copy value at checkBits + esi offset into al
mov[dataBits + edi], al; // copy al into dataBits + edi
inc ebx; // increment offset
dec dl; // decrement counter
jz endExtractBits; // jump to endExtactBits if dl = 0
inc esi; // increment offset into checkBits array
inc edi; // increment offset into data array
Loop LoopData2_4

mov ecx, 7; // maximum number of bits in code
mov esi, 8; // offset from beginning of checkBits array
mov edi, 4; // offset from beginning of data array
dec dl; // decrement counter

LoopData5_11: ; // loop for decoding code bits 5 through 11
mov al, [checkBits + esi]
mov[dataBits + edi], al
inc ebx; // increment offset
dec dl; // decrement counter
jz endExtractBits
inc esi; // increment offset into checkBits array
inc edi; // increment offset into data array
Loop LoopData5_11

mov ecx, 15; // maximum number of bits in code
mov esi, 16; // offset from beginning of checkBits array
mov edi, 11; // offset from beginning of data array
dec dl; // decrement counter

LoopData12_26: ; // loop for decoding code bits 12 through 26
mov al, [checkBits + esi]
mov[dataBits + edi], al
inc ebx; // increment offset
dec dl; // decrement counter
jz endExtractBits
inc esi; // increment offset into checkBits array
inc edi; // increment offset into data array
Loop LoopData12_26

mov ecx, 6; // maximum number of bits in code
mov esi, 32; // offset from beginning of checkBits array
mov edi, 26; // offset from beginning of data array
dec dl; // decrement counter

LoopData27_32: ; // loop for decoding code bits 27 through 32
mov al, [checkBits + esi]
mov[dataBits + edi], al
inc ebx; // increment offset
dec dl; // decrement counter
jz endExtractBits
inc esi; // increment offset into checkBits array
inc edi; // increment offset into data array
Loop LoopData27_32

endExtractBits :
mov numBits, bl; // number of data bits extracted
ret
extractDataBits ENDP

; // function for diplaying decoded data bits
displayData PROC
call Crlf
mov ecx, 0; // clear counter
mov cl, numBits; //copy numBits into counter
mov ebx, 0; // clear offset
displayExtractedData:
mov al, [dataBits + ebx]; // copy databit into al
call WriteDec; // display data bit
mWrite " "; // place a blank between displayed data bits
inc ebx; // inc offset
Loop displayExtractedData
call Crlf
ret
displayData ENDP

; // funciton for encoding binary data into hamming code
binaryEntry PROC
call setParity; // get type of parity from user
enterAgain:
mWrite "Enter the number of data bits to encode (1 to 32 bits). "
call ReadDec; // get number of data bits from user
cmp eax, 0; // check for invalid input of 0
jle enterAgain; // if invalid input try again
cmp eax, 32; // check for invalid input of > 32
jg enterAgain; // if invalid input try again
mov numBits, al; // copy number of data bits into numBits variable
mov numCodeBits, al; // copy number of data bits into numCodeBits variable
.IF al >= 1
add numCodeBits, 2; // set number of parity bits to 2 for >= 1 data bit
.ENDIF
.IF al >= 2
inc numCodeBits; // set number of parity bits to 3 for >= 2 data bits
.ENDIF
.IF al >= 5
inc numCodeBits; // set number of parity bits to 4 for >= 5 data bits
.ENDIF
.IF al >= 12
inc numCodeBits; // set number of parity bits to 5 for >= 12 data bits
.ENDIF
.IF al >= 27
inc numCodeBits; // set number of parity bits to 6 for >= 27 data bits
.ENDIF
mov ecx, eax; // copy eax into counter
mov eax, 0; // initialize eax to 0
mov ebx, 0; // initialize ebx to 0
mWrite "Enter the bits, least significant first, with each bit followed by Enter"
call Crlf

LoopBinary : ; // loop for entering data bits to encode
mWrite "Position # "
xchg eax, ebx; // eax has bit number
inc al; // increment bit number
call WriteDec; // display bit
dec al; // decrement bit number
mWrite " "; // display a blank between bits
xchg eax, ebx; // ebx has bit number
call ReadDec; // eax has data bit
cmp eax, 0; // validate entry
je storeBit; // store bit if valid
cmp eax, 1; //validate entry
je storeBit; // store bit if valid
jmp LoopBinary; // try again if input is invalid
storeBit:
mov[dataBits + ebx], al; // store bit in array + offset
inc ebx; // increment offset
mov numBits, bl; // copy number of bits into numBits variablle
Loop LoopBinary
ret
binaryEntry ENDP

; // funciton for organizing transfer of data bits to dataBits array
xferBinaryToCode PROC
mov al, [dataBits]; // copy data bit into al
mov[codeBits + 2], al; //copy al into codeBits +2 array
mov ecx, 3; // initialize position pointer to 3
mov esi, 1; // initialize position pointer to 1
mov edi, 4; // initialize position pointer to 4
call copyBinaryToCode; // call function to transfer data bits to dataBits array
mov ecx, 7; // initialize position pointer to 7
mov esi, 4; // initialize position pointer to 4
mov edi, 8; // initialize position pointer to 8
call copyBinaryToCode; // call function to transfer data bits to dataBits array
mov ecx, 15; // initialize position pointer to 15
mov esi, 11; // initialize position pointer to 11
mov edi, 16; // initialize position pointer to 16
call copyBinaryToCode; // call function to transfer data bits to dataBits array
mov ecx, 6; // initialize position pointer to 6
mov esi, 26;  // initialize position pointer to 26
mov edi, 32;  // initialize position pointer to 32
call copyBinaryToCode; // call function to transfer data bits to dataBits array
ret
xferBinaryToCode ENDP

; // function for copying data bits to dataBits array
copyBinaryToCode PROC
XferB :
mov al, [dataBits + esi]; // copy data bit into al
mov[codeBits + edi], al; // copy al into codeBits array
inc esi; // increment offset
inc edi; // increment offset
Loop XferB
ret
copyBinaryToCode ENDP

; // function for generating parity bits from entered data
generateCode PROC
; // P1 computation
mov eax, 0; // initialize eax to 0
mov ebx, 0; // initialize ebx to 0
mov ecx, 19; // initialize ecx to 19

LoopAdderCodeP1:
add al, [codeBits + ebx]; // add code bit to al
add ebx, 2; // add 2 to offset
Loop LoopAdderCodeP1

call setParityBit
mov[codeBits], al; // copy al to codeBits array

; // P2 computation
mov eax, 0;  // initialize eax to 0
mov ebx, 1;  // initialize ebx to 1
mov ecx, 10; // initialize ecx to 10

LoopAdderCodeP2:
add al, [codeBits + ebx]; // copy code bit to al
add al, [codeBits + ebx + 1]; // add code bit to al
add ebx, 4; // add 4 to parity pointer
Loop LoopAdderCodeP2

call setParityBit
mov[codeBits + 1], al; // copy al to codeBits array

; // P3 computation
mov eax, 0; // initialize eax to 0
mov ebx, 3; // initialize ebx to 3
mov ecx, 5; // initialize ecx to 5

LoopAdderCodeP3:
push ecx; // put ecx on the stack
mov ecx, 4; // initialize ecx to 4

LoopAddP3:
add al, [codeBits + ebx]; // add code bit to al
inc ebx; // increment ebx to 4
Loop LoopAddP3

add ebx, 4; // add 4 to ebx
pop ecx; // retieve ecx from stack
Loop LoopAdderCodeP3

call setParityBit
mov[codeBits + 3], al; // copy al into codeBits array

; // P4 computation
mov eax, 0; // initialize eax to 0
mov ebx, 7;  // initialize ebx to 7
mov ecx, 2; // initialize ecx to 2

LoopAdderCodeP4:
push ecx; // put ecx on the stack
mov ecx, 8; // initialize ecx with 8

LoopAddP4:
add al, [codeBits + ebx]; // add code bit to al
inc ebx; // incrment ebx to 9
Loop LoopAddP4

add ebx, 8; // add 8 to ebx
pop ecx; // retrieve ecx from stack
Loop LoopAdderCodeP4

call setParityBit
mov[codeBits + 7], al; // copy al into codeBits array

; // P5 computation
mov eax, 0; // initialize eax to 0
mov ebx, 15; // initialize ebx to 15
mov ecx, 16; // initialize ecx to 16

LoopAdderCodeP5:
add al, [codeBits + ebx]; // add code bit to al
inc ebx; // increment ebx to 16
Loop LoopAdderCodeP5

call setParityBit
mov[codeBits + 15], al

; // P6 computation
mov eax, 0; // initialize eax to 0
mov ebx, 31; // initialize ebx to 31
mov ecx, 7; // initialize ecx to 7

LoopAdderCodeP6:
add al, [codeBits + ebx]; // add code bit to al
inc ebx; // increment ebx to 32
Loop LoopAdderCodeP6

call setParityBit
mov[codeBits + 31], al; // copy al into codeBits array
ret
generateCode ENDP

; // function for comparing enterred code to calculated code
compareCodes PROC
mov eax, 0; // initialize eax to 0
mov cl, numBits; // copy numBits value to cl
mov ebx, 0; // initialize ebx to 0

LoopCompare:
mov al, [checkBits + ebx]; // copy check bit into al
cmp al, [codeBits + ebx]; // compare code bit to al
je next; // jump if code bit = al
mov[errorBits + ebx], 1; // otherwise copy 1 int errorBits array
next:
inc ebx; // increment ebx to 2
Loop LoopCompare
ret
compareCodes ENDP

; // function for verifying parity bits in code
checkParityBits PROC
mov eax, 0; // initialize eax to 0
mov ebx, 0; // initialize ebx to 0
mov edx, 0; // initialize edx to 0
mov al, [errorBits]; // check parity bit 1
shr eax, 1; // bit is 1 if the entered and generated codes disagree
jnc checkBit2; // jump if entered and generated codes agree
add dl, 1; // dl has position of erroneous bit
inc parityErrorCount; // number of erroneous bits

checkBit2:
mov al, [errorBits + 1]; // check parity bit 2
shr eax, 1; // shift right eax
jnc checkBit3; // jump if carry clear
add dl, 2; // dl has position of erroneous bit
inc parityErrorCount; // number of erroneous bits

checkBit3:
mov al, [errorBits + 3]; // check parity bit 3
shr eax, 1; // shift right eax
jnc checkBit4; // jump if carry clear
add dl, 4; // dl has position of erroneous bit
inc parityErrorCount; // number of erroneous bits

checkBit4:
mov al, [errorBits + 7]; // check parity bit 4
shr eax, 1; // shift right eax
jnc checkBit5; // jump if carry clear
add dl, 8; // dl has position of erroneous bit 1
inc parityErrorCount; // number of erroneous bits

checkBit5:
mov al, [errorBits + 15]; // check parity bit 5
shr eax, 1; // shift right eax
jnc checkBit6; // jump if carry clear
add dl, 16; // dl has position of erroneous bit
inc parityErrorCount; // number of erroneous bits

checkBit6:
mov al, [errorBits + 31]; // check parity bit 6
shr eax, 1; // shift right eax
jnc endCheck; // jump if carry clear
add dl, 32; // dl has position of erroneous bit
inc parityErrorCount; // number of erroneous bits

endCheck:
cmp parityErrorCount, 1; // compare parity error count value to 1
je parityError; // jump if = 1 to parityError
cmp dl, 0; // compare dl to 0
je endParityCheck; // jump if = 0 to endParityCheck
mov preserveDl, dl; // otherwise copy data bit into preserveD1 variable
sub dl, 1; // subtract 1 from dl
xor[checkBits + edx], 1; // xor checkbit and 1
mov al, numBits; // copy numBits value into al
mov numCodeBits, al; //copy al into numCodeBits array
call extractDataBits
call Crlf
call Crlf
mWrite "Correct data bits"
mov al, numCodeBits; // copy number of code bits into al
mov numBits, al; // copy number of bits into numBits variable
call displayData
mov al, numTempBits; // copy number of temporary bits into al
mov numBits, al; // copoy number of bits into numBits variable
call xferBinaryToCode
call generateCode
call Crlf
call displayCheckBits
mWrite "Error in data bit, position "
mov al, preserveDl; // copy data bit into al
call WriteDec
call Crlf
call Crlf
jmp endParityCheck

parityError :
mWrite "Error in parity bit, position "
mov al, Dl; // copy data bit into al
call WriteDec
call Crlf
call Crlf
call displayCode
endParityCheck :
ret
checkParityBits ENDP

; // function for setting parity bit
setParityBit PROC
shr eax, 1; // shift right eax
jc one; // jump if carry is set
zero:
cmp parity, 0; // parity should be even if 0
je setToZero; //
jmp setToOne
one :
cmp parity, 1; // parity should be odd if 1
je setToZero
jmp setToOne
setToZero :
mov eax, 0
jmp endSetParityBit
setToOne :
mov eax, 1; // initialize eax to 1
endSetParityBit:
ret
setParityBit ENDP

; // function for displaying hamming code
displayCode PROC
call Crlf
mWrite "Correct code is "
call Crlf
mov eax, 0; // initialize eax to 0
mov ebx, 0; // initialize ebx to 0
mov ecx, 0; // initialize ecx to 0
mov cl, numCodeBits; // copy number of bits into cl

LoopDisplay:
mov al, [codeBits + ebx]; // copy code bit into al
call WriteDec
mWrite " "
inc ebx; // increment offset for codeBits
Loop LoopDisplay
call Crlf
mov al, numTempBits; // copy number of temporary bits into al
mov numBits, al; // copy number of temporary bits into numBits variable
call Crlf
ret
displayCode ENDP

; //  function for displaying check bits
displayCheckBits PROC
call Crlf
mWrite "The correct code is"
call Crlf
mov eax, 0; // initialize eax to 0
mov ebx, 0; // initialize ebx to 0
mov ecx, 0; // initialize ecx to 0
mov cl, numBits; // copy number of bits into cl
LoopDisplay:
mov al, [checkBits + ebx]; // copy check bit into al
call WriteDec
mWrite " "
inc ebx; // increment offset of checkBits
Loop LoopDisplay
call Crlf
mov al, numTempBits; // copy number of temporary bits into al
mov numBits, al; // copy number of temporary bits into numBits variable
call Crlf
ret
displayCheckBits ENDP

END main
