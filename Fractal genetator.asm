.data
bitmapDisplay: .space 0x80000 # enough memory for a 512x256 bitmap display
resolution: .word  512 256    # width and height of the bitmap display

windowlrbt: 
.float -2.5 2.5 -1.25 1.25					# good window for viewing Julia sets
#.float -3 2 -1.25 1.25  					# good window for viewing full Mandelbrot set
#.float -0.807298 -0.799298 -0.179996 -0.175996 		# double spiral
#.float -1.019741354 -1.013877846  -0.325120847 -0.322189093 	# baby Mandelbrot
 
bound: .float 100	# bound for testing for unbounded growth during iteration
maxIter: .word 16	# maximum iteration count to be used by drawJulia and drawMandelbrot
scale: .word 16	# scale parameter used by computeColour

# TODO: define various constants you need in your .data segment here

STRsps: .asciiz " + "
STRsms: .asciiz " - "
STRses: .asciiz " = "
STRsi: .asciiz " i"
STRx: .asciiz "x"
STRy: .asciiz "y"
NEWLINE: .asciiz "\n"

z0: .float 0 0

FLO1: .float 1
FLO2: .float 2
FLOm1: .float -1

PAR1: .float -0.6
PAR2: .float 0.5
PAR3: .float 0
PAR4: .float 0

########################################################################################
.text
	
	# User's part
	
	lwc1 $f12 PAR1
	lwc1 $f13 PAR2
	
	# If you want to generate a certain Julia fractal with parameters x and y, comment out the next line and modify the values of PAR1,PAR2 10 lines above for x and y
	#jal drawJulia
	
	li $a0 20000  #  You can change this parameter to make juliaRevese iterate longer
	lwc1 $f12 PAR1
	lwc1 $f13 PAR2
	lwc1 $f14 PAR3
	lwc1 $f15 PAR4
	
	# If you want to draw the boundary of the fractal as well, choose a starting point (x0,y0) and change the values of PAR3,PAR4 11 lines above for x0 and y0
	#jal juliaReverse
	
	# To draw the Mandelbrot set, comment out the next line
	#jal drawMandelBrot
	
	li $v0 10
	syscall
	



# Do not modify what's after unless you want to deal with hours of debugging

juliaReverse:   # takes inputs a0, f12, f13, f14, f15, plots everything in display
	
	li $t0 0   # t0 = counter for juRevLoop
	juRevLoop:
		
		beq $t0 $a0 JuRevLoopExit   # verifies if we reached max nb of iterations
		
		### calling a func ###
		sw $t0 0($sp)
		sw $a0 4($sp)
		swc1 $f12 8($sp)
		swc1 $f13 12($sp)
		swc1 $f14 16($sp)
		swc1 $f15 20($sp)
		sw $ra 24($sp)
		
		addi $sp $sp 64
		
		mov.s $f12 $f14
		mov.s $f13 $f15
		jal plotComplex   # plotting x,y in the plane
		
		addi $sp $sp -64
		
		lw $t0 0($sp)
		lw $a0 4($sp)
		lwc1 $f12 8($sp)
		lwc1 $f13 12($sp)
		lwc1 $f14 16($sp)
		lwc1 $f15 20($sp)
		lw $ra 24($sp)
		### called a func ###
		
		### calling a func ###
		sw $t0 0($sp)
		sw $a0 4($sp)
		swc1 $f12 8($sp)
		swc1 $f13 12($sp)
		swc1 $f14 16($sp)
		swc1 $f15 20($sp)
		sw $ra 24($sp)
		
		addi $sp $sp 64
		
		sub.s $f12 $f14 $f12
		sub.s $f13 $f15 $f13
		jal complexSqrt   # plotting x,y in the plane
		
		addi $sp $sp -64
		
		lw $t0 0($sp)
		lw $a0 4($sp)
		lwc1 $f12 8($sp)
		lwc1 $f13 12($sp)
		lwc1 $f14 16($sp)
		lwc1 $f15 20($sp)
		lw $ra 24($sp)
		### called a func ###
		
		mov.s $f14 $f0
		mov.s $f15 $f1
		
		add $t0 $t0 1   # increase counter by 1
		j juRevLoop
		
	JuRevLoopExit:
	
	jr $ra



plotComplex:   # takes inputs f12, f13, plots them as a yellow dot in display
	
	la $t6 bitmapDisplay   # t6 = address of bitmapDisplay
	
	la $t0 resolution
	l.s $f4 0($t0)
	mfc1 $t2 $f4   # f4 = t2 = width of the rectangle
	cvt.s.w $f4 $f4
	l.s $f5 4($t0)
	mfc1 $t3 $f5   # f5 = t3 = height of the rectangle
	cvt.s.w $f5 $f5
	
	la $t0 windowlrbt
	l.s $f7 0($t0)   # f7 = l
	l.s $f8 4($t0)   # f8 = r
	l.s $f9 8($t0)   # f9 = b
	l.s $f10 12($t0)   # f10 = t
	
	### if statements ### we check if the point is in the boundaries of display
	
	c.lt.s $f12 $f7
	bc1t Skip
	
	c.lt.s $f8 $f12
	bc1t Skip
	
	c.lt.s $f13 $f9
	bc1t Skip
	
	c.lt.s $f10 $f13
	bc1t Skip
	
	### end of if ###
	
	
	sub.s $f12 $f12 $f7   # f12 = round ( w*(f12-l)/(r-l) )
	mul.s $f12 $f12 $f4
	sub.s $f11 $f8 $f7
	div.s $f12 $f12 $f11
	round.w.s $f12 $f12
	mfc1 $t4 $f12   # t4 = int ( f12 ) = col
	
	sub.s $f13 $f13 $f9   # f12 = round ( h*(f13-b)/(t-b) )
	mul.s $f13 $f13 $f5
	sub.s $f11 $f10 $f9
	div.s $f13 $f13 $f11
	round.w.s $f13 $f13
	mfc1 $t5 $f13   # t5 = int ( f13 ) = row
	
	mul $t7 $t5 $t2   # t7 = w*row
	add $t7 $t7 $t4   # t7 = w*row + col
	li $t0 4
	mul $t7 $t7 $t0   # t7 = 4*(w*row + col)
	
	add $t6 $t6 $t7   # t6 = bitmapDisplay + w*row + col
	
	li $t0 0x00FFFF44   # stores color yellow at the right pixel
	sw $t0 0($t6)
	
	Skip:
	
	jr $ra



norm:   # takes inputs f12 f13, outputs f0 = | {f12} + {f13}i |
	
	mul.s $f0 $f12 $f12   # f0 = f12^2
	mul.s $f4 $f13 $f13   # f4 = f13^2
	add.s $f0 $f0 $f4   # f0 = f12^2 + f13^2
	sqrt.s $f0 $f0
	
	jr $ra


complexSqrt:   # takes input {f12} + {f13}i and outputs the square root in f0 and f1
	
	la $t0 z0   # f4 = 0.0
	l.s $f4 0($t0)
	
	### if statement ###
	c.eq.s $f13 $f4   # verifies if b==0
	bc1f ElseCoSq1
	
		### if statement ###
		c.le.s $f4 $f12   # verifies if a >= 0
		bc1f ElseCoSq2
			
			sqrt.s $f0 $f12   # returns (sqrt(a),0)
			mov.s $f1 $f4
			
		j EndIfCoSq2
		ElseCoSq2:
			
			mov.s $f0 $f4
			sqrt.s $f1 $f12
			
		EndIfCoSq2:
		### end of if ###
	
	j EndIfCoSq1
	ElseCoSq1:
		
		### func call ###
		sw $t0 0($sp)
		swc1 $f4 4($sp)
		swc1 $f12 8($sp)
		swc1 $f13 12($sp)
		sw $ra 16($sp)
		
		addi $sp $sp 64
		
		jal norm
		mov.s $f5 $f0   # f5 = norm(a,b)
		
		addi $sp $sp -64
		
		lw $t0 0($sp)
		lwc1 $f4 4($sp)
		lwc1 $f12 8($sp)
		lwc1 $f13 12($sp)
		lw $ra 16($sp)
		### end call ###
		
		add.s $f6 $f12 $f5   # f6 = a + norm(a,b)
		
		### func call ###
		sw $t0 0($sp)
		swc1 $f4 4($sp)
		swc1 $f5 8($sp)
		swc1 $f6 12($sp)
		swc1 $f12 16($sp)
		swc1 $f13 20($sp)
		sw $ra 24($sp)
		
		addi $sp $sp 64
		
		mov.s $f12 $f6
		jal norm
		mov.s $f7 $f0   # f7 = norm( a + norm(a,b) , b )
		
		addi $sp $sp -64
		
		lw $t0 0($sp)
		lwc1 $f4 4($sp)
		lwc1 $f5 8($sp)
		lwc1 $f6 12($sp)
		lwc1 $f12 16($sp)
		lwc1 $f13 20($sp)
		lw $ra 24($sp)
		### end call ###
		
		sqrt.s $f0 $f5   # f0 = sqrt(norm(a,b)) / (norm( a + norm(a,b) , b )) * (a + norm(a,b))
		div.s $f0 $f0 $f7
		mul.s $f0 $f0 $f6
		
		sqrt.s $f1 $f5   # f1 = sqrt(norm(a,b)) / (norm( a + norm(a,b) , b )) * b
		div.s $f1 $f1 $f7
		mul.s $f1 $f1 $f13
		
		
	EndIfCoSq1:
	### end of if ###
	
	li $v0 41
	syscall
	
	li $t1 2
	rem $t1 $a0 $t1   # t1 = 0 or 1 randomly
	
	### if statement ###
	li $t0 0
	beq $t1 $t0 IfCoSq3
		
		la $t0 FLO1
		l.s $f5 0($t0)
		
	j EndCoSq3   # if f5==0, f5=-1, else f5=1
	IfCoSq3:
		
		la $t0 FLOm1
		l.s $f5 0($t0)
		
	EndCoSq3:
	### end of if ###
	
	mul.s $f0 $f0 $f5
	mul.s $f1 $f1 $f5
	
	jr $ra



drawMandelBrot:
	
	la $t0 z0
	l.s $f14 0($t0)   # f14=f15=0
	l.s $f15 4($t0)
	
	la $t6 bitmapDisplay
	
	la $t0 maxIter
	l.s $f4 0($t0)
	mfc1 $t5 $f4   # t5 = maxIter
	
	la $t0 resolution
	l.s $f4 0($t0)
	mfc1 $t2 $f4   # t2 = width of the rectangle
	l.s $f4 4($t0)
	mfc1 $t3 $f4   # t3 = height of the rectangle
	
	li $t1 0   # t1 = counter for the outer loop
	
	drMandLoop1:
		
		beq $t1 $t3 ExDrMandLoop1   # verifies if we reached 256
		
		li $t0 0   # t0 = counter for the inner looop
		
		drMandLoop2:
			
			beq $t0 $t2 ExDrMandLoop2   # verifies if we reached 512
			
			sw $t0 0($sp)   # storing variables before calling
			sw $t1 4($sp)
			sw $t2 8($sp)
			sw $t3 12($sp)
			sw $t6 16($sp)
			sw $ra 20($sp)
			swc1 $f14 32($sp)
			swc1 $f15 36($sp)
			addi $sp $sp 64   # stack pointer up
			
			move $a0 $t0   # inputs for pixel2ComplexInWindow
			move $a1 $t1
			
			jal pixel2ComplexInWindow
			
			mov.s $f12 $f0   # stores return values of pixel2ComplexInWindow in f14 and f15
			mov.s $f13 $f1   # inputs for iterate
			
			move $a0 $t5
			
			addi $sp $sp -64   # stack pointer down
			lw $t0 0($sp)   # storing variables after calling
			lw $t1 4($sp)
			lw $t2 8($sp)
			lw $t3 12($sp)
			lw $t6 16($sp)
			lw $ra 20($sp)
			lwc1 $f14 32($sp)
			lwc1 $f15 36($sp)
			
			sw $t0 0($sp)   # storing variables before calling
			sw $t1 4($sp)
			sw $t2 8($sp)
			sw $t3 12($sp)
			sw $t6 16($sp)
			sw $ra 20($sp)
			swc1 $f12 24($sp)
			swc1 $f13 28($sp)
			swc1 $f14 32($sp)
			swc1 $f15 36($sp)
			addi $sp $sp 64   # stack pointer up
			
			jal iterate
			
			move $t4 $v0   # stores the return value of iterate in t4
			
			addi $sp $sp -64   # stack pointer down
			lw $t0 0($sp)   # storing variables after calling
			lw $t1 4($sp)
			lw $t2 8($sp)
			lw $t3 12($sp)
			lw $t6 16($sp)
			lw $ra 20($sp)
			lwc1 $f12 24($sp)
			lwc1 $f13 28($sp)
			lwc1 $f14 32($sp)
			lwc1 $f15 36($sp)
			
			### if statement ###
			beq $t4 $t5 drMandIf1   # if n == maxIter
			
			# else
			move $a0 $t4   # input for computeColour = n
			
			sw $t0 0($sp)   # storing variables before calling
			sw $t1 4($sp)
			sw $t2 8($sp)
			sw $t3 12($sp)
			sw $t6 16($sp)
			sw $ra 20($sp)
			swc1 $f12 24($sp)
			swc1 $f13 28($sp)
			swc1 $f14 32($sp)
			swc1 $f15 36($sp)
			addi $sp $sp 64   # stack pointer up
			
			jal computeColour
			
			move $t4 $v0   # stores the return value of computeColour in t4
			
			addi $sp $sp -64   # stack pointer down
			lw $t0 0($sp)   # storing variables after calling
			lw $t1 4($sp)
			lw $t2 8($sp)
			lw $t3 12($sp)
			lw $t6 16($sp)
			lw $ra 20($sp)
			lwc1 $f12 24($sp)
			lwc1 $f13 28($sp)
			lwc1 $f14 32($sp)
			lwc1 $f15 36($sp)
			
			j drMandEnd1
			#end
			#if
			drMandIf1:
			li $t4 0
			
			drMandEnd1:
			### end ###
			
			sw $t4 0($t6)
			
			addi $t6 $t6 4   # increase bitmapDisplay
			
			beq $t4 $t5   ExDrMandLoop2 # if (nb of iterations) == (max nb of iterations)
			
			addi $t0 $t0 1   # increase counter t0 by 1
			j drMandLoop2
			
		ExDrMandLoop2:
		
		add $t1 $t1 1   # increase counter t1 by 1
		j drMandLoop1
	
	ExDrMandLoop1:
	
	jr $ra



drawJulia:
	
	la $t6 bitmapDisplay
	
	la $t0 maxIter
	l.s $f4 0($t0)
	mfc1 $t5 $f4   # t5 = maxIter
	
	la $t0 resolution
	l.s $f4 0($t0)
	mfc1 $t2 $f4   # t2 = width of the rectangle
	l.s $f4 4($t0)
	mfc1 $t3 $f4   # t3 = height of the rectangle
	
	li $t1 0   # t1 = counter for the outer loop
	
	drJuLoop1:
		
		beq $t1 $t3 ExDrJuLoop1   # verifies if we reached 256
		
		li $t0 0   # t0 = counter for the inner looop
		
		drJuLoop2:
			
			beq $t0 $t2 ExDrJuLoop2   # verifies if we reached 512
			
			sw $t0 0($sp)   # storing variables before calling
			sw $t1 4($sp)
			sw $t2 8($sp)
			sw $t3 12($sp)
			sw $t6 16($sp)
			sw $ra 20($sp)
			addi $sp $sp 64   # stack pointer up
			
			move $a0 $t0   # inputs for pixel2ComplexInWindow
			move $a1 $t1
			
			jal pixel2ComplexInWindow
			
			mov.s $f14 $f0   # stores return values of pixel2ComplexInWindow in f14 and f15
			mov.s $f15 $f1   # inputs for iterate
			
			move $a0 $t5
			
			addi $sp $sp -64   # stack pointer down
			lw $t0 0($sp)   # storing variables after calling
			lw $t1 4($sp)
			lw $t2 8($sp)
			lw $t3 12($sp)
			lw $t6 16($sp)
			lw $ra 20($sp)
			
			sw $t0 0($sp)   # storing variables before calling
			sw $t1 4($sp)
			sw $t2 8($sp)
			sw $t3 12($sp)
			sw $t6 16($sp)
			sw $ra 20($sp)
			swc1 $f14 24($sp)
			swc1 $f15 28($sp)
			addi $sp $sp 64   # stack pointer up
			
			jal iterate
			
			move $t4 $v0   # stores the return value of iterate in t4
			
			addi $sp $sp -64   # stack pointer down
			lw $t0 0($sp)   # storing variables after calling
			lw $t1 4($sp)
			lw $t2 8($sp)
			lw $t3 12($sp)
			lw $t6 16($sp)
			lw $ra 20($sp)
			lwc1 $f14 24($sp)
			lwc1 $f15 28($sp)
			
			### if statement ###
			beq $t4 $t5 drJuIf1   # if n == maxIter
			
			# else
			move $a0 $t4   # input for computeColour = n
			
			sw $t0 0($sp)   # storing variables before calling
			sw $t1 4($sp)
			sw $t2 8($sp)
			sw $t3 12($sp)
			sw $t6 16($sp)
			sw $ra 20($sp)
			swc1 $f14 24($sp)
			swc1 $f15 28($sp)
			addi $sp $sp 64   # stack pointer up
			
			jal computeColour
			
			move $t4 $v0   # stores the return value of computeColour in t4
			
			addi $sp $sp -64   # stack pointer down
			lw $t0 0($sp)   # storing variables after calling
			lw $t1 4($sp)
			lw $t2 8($sp)
			lw $t3 12($sp)
			lw $t6 16($sp)
			lw $ra 20($sp)
			lwc1 $f14 24($sp)
			lwc1 $f15 28($sp)
			
			j drJuEnd1
			#end
			#if
			drJuIf1:
			li $t4 0
			
			drJuEnd1:
			### end ###
			
			sw $t4 0($t6)
			
			addi $t6 $t6 4   # increase bitmapDisplay
			
			beq $t4 $t5   ExDrJuLoop2 # if (nb of iterations) == (max nb of iterations)
			
			addi $t0 $t0 1   # increase counter t0 by 1
			j drJuLoop2
		
		ExDrJuLoop2:
		
		add $t1 $t1 1   # increase counter t1 by 1
		j drJuLoop1
	
	ExDrJuLoop1:
	
	jr $ra



pixel2ComplexInWindow:
	
	mtc1 $a0 $f4   # f4 = float(col)
	mtc1 $a1 $f5   # f5 = float(row)
	
	la $t0 resolution   # f11 = w, f16 = h
	l.s $f11 0($t0)
	l.s $f16 4($t0)
	
	la $t0 windowlrbt
	l.s $f7 0($t0)   # f7 = l
	l.s $f8 4($t0)   # f8 = r
	l.s $f9 8($t0)   # f9 = b
	l.s $f10 12($t0)   # f10 = t
	
	div.s $f0 $f4 $f11   # f0 = col/w*(r-l) + l
	sub.s $f17 $f8 $f7
	mul.s $f0 $f0 $f17
	add.s $f0 $f0 $f7
	
	div.s $f1 $f5 $f16   # f1 = row/h*(t-b) + b
	sub.s $f17 $f10 $f9
	mul.s $f1 $f1 $f17
	add.s $f1 $f1 $f9
	
	jr $ra
	


printComplex:   # takes f12, f13 as inputs, outputs "{f12} + {f13} i"  ---DONE---

	li $v0 2   # set to print float
	syscall   # print "{f12}"
	
	la $a0 STRsps   # print " + "
	li $v0 4   # set to print string
	syscall
	
	li $v0 2   # set to print float
	mov.s $f12 $f13   # print "{f13}"
	syscall
	
	la $a0 STRsi   # print " i"
	li $v0 4   # set to print string
	syscall 
	
	jr $ra
	
	
	
printNewLine:   # print "\n"
	
	li $v0 4
	la $a0 NEWLINE
	syscall
	
	jr $ra
	
	
	
multComplex:   # takes f12, f13, f14, f15 as inputs

	mul.s $f0 $f12 $f14   # f0 = f12*f14 - f13*f15
	mul.s $f4 $f13 $f15
	sub.s $f0 $f0 $f4
	
	mul.s $f1 $f12 $f15   # f1 = f12*f15 + f13*f14
	mul.s $f4 $f13 $f14
	add.s $f1 $f1 $f4
	
	jr $ra
	
	
	
iterateVerbose:   # takes inputs a0, f12, f13, f14, f15
	
	move $t1 $a0
	
	li $t0 0   # counter for the loop
	itVerLoop1:   # prints all the lines of new coordinates
		
		beq $t0 $t1 exitItVerLoop1   # verifies if counter reached its max
		
		la $a0 STRx   # prints x
		li $v0 4
		syscall
		
		move $a0 $t0   # prints the digit
		li $v0 1
		syscall
	
		la $a0 STRsps   # print " + "
		li $v0 4
		syscall
		
		la $a0 STRy   # prints y
		syscall
		
		move $a0 $t0   # prints the digit
		li $v0 1
		syscall
		
		la $a0 STRsi   # prints " i"
		li $v0 4
		syscall
	
		la $a0 STRses   # print " = "
		li $v0 4
		syscall
		
		swc1 $f12 0($sp)   # storing variables before calling
		swc1 $f13 4($sp)
		swc1 $f14 8($sp)
		swc1 $f15 12($sp)
		sw $ra 16($sp)
		mov.s $f12 $f14   # stores the arguments for printComplex
		mov.s $f13 $f15
		
		addi $sp $sp 64   # stack pointer goes up
		jal printComplex   # calling
		addi $sp $sp -64   # stack pointer goes down
		
		lw $ra 16($sp)
		lwc1 $f12 0($sp)   # loading variables after calling
		lwc1 $f13 4($sp)
		lwc1 $f14 8($sp)
		lwc1 $f15 12($sp)
		
		sw $ra 16($sp)
		addi $sp $sp 64   # stack pointer goes up
		jal printNewLine   # printing a new line
		addi $sp $sp -64   # stack pointer goes down
		lw $ra 16($sp)
	
		swc1 $f12 0($sp)   # storing variables before calling
		swc1 $f13 4($sp)
		swc1 $f14 8($sp)
		swc1 $f15 12($sp)
		sw $ra 16($sp)
		
		mov.s $f12 $f14   # inputs for multComplex
		mov.s $f13 $f15
		
		addi $sp $sp 64   # stack pointer goes up
		jal multComplex   # calling
		addi $sp $sp -64   # stack pointer goes down
		
		lw $ra 16($sp)
		lwc1 $f12 0($sp)   # loading variables after calling
		lwc1 $f13 4($sp)
		lwc1 $f14 8($sp)
		lwc1 $f15 12($sp)
		
		mov.s $f14 $f0   # storing return values of mutlComplex in f0, f1
		mov.s $f15 $f1
		
		add.s $f14 $f14 $f12   # f14 = x^y - y^2 + a
		add.s $f15 $f15 $f13   # f14 = 2xy + b
		
		mul.s $f4 $f14 $f14   # f4 = f14^2 + f15^2
		mul.s $f5 $f15 $f15
		add.s $f4 $f4 $f5
		
		l.s $f5 bound   # verifies if bound < f14^2 + f15^2
		c.lt.s $f5 $f4
		bc1t exitItVerLoop1
		
		addi $t0 $t0 1  # increase counter by 1
		
		j itVerLoop1
		
		
	exitItVerLoop1:
	
	li $v0 1   # print the number of iterations
	move $a0 $t0
	syscall
	
	move $v0 $t0   # return the number of iterations in v0
	
	jr $ra
	
	
	
iterate:   # takes inputs a0, f12, f13, f14, f15
	
	move $t1 $a0
	
	li $t0 0   # counter for the loop
	itLoop1:   # prints all the lines of new coordinates
		
		beq $t0 $t1 exitItLoop1   # verifies if counter reached its max
	
		swc1 $f12 0($sp)   # storing variables before calling
		swc1 $f13 4($sp)
		swc1 $f14 8($sp)
		swc1 $f15 12($sp)
		sw $ra 16($sp)
		
		mov.s $f12 $f14   # inputs for multComplex
		mov.s $f13 $f15
		
		addi $sp $sp 64   # stack pointer goes up
		jal multComplex   # calling
		addi $sp $sp -64   # stack pointer goes down
		
		lw $ra 16($sp)
		lwc1 $f12 0($sp)   # loading variables after calling
		lwc1 $f13 4($sp)
		lwc1 $f14 8($sp)
		lwc1 $f15 12($sp)
		
		mov.s $f14 $f0   # storing return values of mutlComplex in f0, f1
		mov.s $f15 $f1
		
		add.s $f14 $f14 $f12   # f14 = x^y - y^2 + a
		add.s $f15 $f15 $f13   # f14 = 2xy + b
		
		mul.s $f4 $f14 $f14   # f4 = f14^2 + f15^2
		mul.s $f5 $f15 $f15
		add.s $f4 $f4 $f5
		
		l.s $f5 bound   # verifies if bound < f14^2 + f15^2
		c.lt.s $f5 $f4
		bc1t exitItLoop1
		
		addi $t0 $t0 1  # increase counter by 1
		
		j itLoop1
		
		
	exitItLoop1:
	
	move $v0 $t0   # return the number of iterations in v0
	
	jr $ra


########################################################################################
# Computes a colour corresponding to a given iteration count in $a0
# The colours cycle smoothly through green blue and red, with a speed adjustable 
# by a scale parametre defined in the static .data segment
computeColour:
	la $t0 scale
	lw $t0 ($t0)
	mult $a0 $t0
	mflo $a0
ccLoop:
	slti $t0 $a0 256
	beq $t0 $0 ccSkip1
	li $t1 255
	sub $t1 $t1 $a0
	sll $t1 $t1 8
	add $v0 $t1 $a0
	jr $ra
ccSkip1:
  	slti $t0 $a0 512
	beq $t0 $0 ccSkip2
	addi $v0 $a0 -256
	li $t1 255
	sub $t1 $t1 $v0
	sll $v0 $v0 16
	or $v0 $v0 $t1
	jr $ra
ccSkip2:
	slti $t0 $a0 768
	beq $t0 $0 ccSkip3
	addi $v0 $a0 -512
	li $t1 255
	sub $t1 $t1 $v0
	sll $t1 $t1 16
	sll $v0 $v0 8
	or $v0 $v0 $t1
	jr $ra
ccSkip3:
 	addi $a0 $a0 -768
 	j ccLoop
