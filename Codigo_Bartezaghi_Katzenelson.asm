.data 
	A: 		.float 2,1,0,1
			.float 2,3,1,4
			.float 5,1,3,2
	
	X: 		.space 44
	espacio:	.asciz " "
	err: 		.asciz "error"
.text
	main: 
		li t6, 3 #				t6 = n
		li a3, 4 #				size = a3
		
		addi t5,t6,1 #				t5 = n+1                    
		la a0, A #                              a0 = A
		la a1, X # 				a1 = X	
		la a4, err # 				a4 = err	
		la a5, espacio # 			a1 = X		
		li t1, 0 #				i = 1  
		li t2, 0 #				j = 1
		li t3, 0 #				k = 1	
		
	verificarMatriz:
		mul a2, t6, t6 # (n * n)
		add a2, a2, t6 # (n * n) + n
		mul a2, a2, a3 # ((n * n) + n ) * 4 
		add a2, a2, a0 # Sumo a la dirección 
		
		# a2 (calculo) = a1 (X)
		bne a2, a1, error
		
	for1:
		slt s0, t1, t6		#si t1<t6 escribe 1 en t0,
		beqz s0,solucion
		addi t1,t1,1	# indice for1
		addi s10,t1,-1	# indice i
		
		# a[i][i]
		mul t4, s10, t5  # fila (i)  * (n-1)
		add t4, t4, s10  # 	   		+ columna (i)
		mul t4, t4, a3  #              	 			* tamaño dato
		add t4, t4, a0  # 	 						+ addr A
		
		lw t4,(t4) # t4 = a[i][i]
		
		#if(a[i][i] == 0.0) error
		beqz t4,error
		
		li t2,0 #reinicio iterador for2
		
		for2:
			slt s1, t2, t6  
			beqz s1,for1
			addi t2, t2, 1 # indice for2
			
			beq t1,t2, for2  #if(i!=j) sigo, sino vuelvo
			
			addi s11,t2,-1	#indice j
			
			# ratio = a[j][i]/a[i][i]
			
			# obtengo a[j][i]
			mul t4, s11, t5  
			add t4, t4, s10  
			mul t4, t4, a3  
			add t4, t4, a0 
			flw fs3,(t4) #		fs3 = a[j][i]
			
			#obtengo a[i][i]
			mul t4, s10, t5  
			add t4, t4, s10  
			mul t4, t4, a3  
			add t4, t4, a0 
			flw fs4, (t4) #		fs4 = a[i][i]
			
			fdiv.s ft5,fs3,fs4 #	ft5 = ratio = a[j][i]/a[i][i] 
			
			li t3,0  #reinicio iterador for3
			
			for3:
				slt s2, t3, t5  
				beqz s2,for2
				addi t3, t3, 1  # indice for3
				addi s9,t3,-1	# indice k
				
				
				#a[j][k] = a[j][k] - ratio*a[i][k];
				
				# obtengo a[i][k]
				mul t4, s10, t5 
				add t4, t4, s9
				mul t4, t4, a3 
				add t4, t4, a0 
				flw fs7, (t4)    #  	a[i][k]
				fmul.s ft3,ft5,fs7   #  ft3 = ratio*a[i][k]
				
				# obtengo a[j][k]
				mul t4, s11, t5  
				add t4, t4, s9 
				mul t4, t4, a3  
				add t4, t4, a0
				flw fs8, (t4)  #fs8 = a[j][k]
				
				
				fsub.s ft3,fs8,ft3   #  s3 = a[j][k] - ratio*a[i][k]
				
				
				# Hago la asignacion  a[j][k] = a[j][k] - ratio*a[i][k]
				fsw ft3,(t4)  # t4 es la direccion de a[j][k]
				
				
				j for3
				
			
			j for2
		
		
		j for1		
		
	
					
	#Obtengo la solucion
	solucion:	
		li t3,0 # indice for4
		la a0,A  # reseteo la direccion de A	
		la a1,X	 # Cargo dirección de X	
	for4:
		slt s2, t3, t6   # itera hasta n
		beqz s2,fin
		addi t3, t3, 1 
		addi s9,t3,-1	#indice para acceso a matriz
	
		#x[i] = a[i][n+1]/a[i][i]
		
		# a[i][n+1]
		mul t4, s9, t5 
		add t4, t4, t6  
		mul t4, t4, a3  
		add t4, t4, a0  
		flw ft1, (t4) #		ft1 = a[i][n+1]
	
		#a[i][i]
		mul t4, s9, t5  
		add t4, t4, s9 
		mul t4, t4, a3  
		add t4, t4, a0 
		flw ft2, (t4) #		ft2 = a[i][i]
	
		fdiv.s ft3,ft1,ft2  #		s8 = a[i][n+1]/a[i][i]
		fsw ft3,(a1)
		
		# imprimir solución
		li  a7, 2	
		fadd.s fa0,ft3,ft0
    		ecall
    		
    		li  a7, 4
    		add a0, a5, zero  
    		ecall
		
		la a0,A  #		reseteo la direccion de A	
		addi a1,a1,4   # 	aumento 4 bits del vector x
		
		j for4
	
		
		error:
			li  a7, 4        
    			add a0, a4, zero  
    			ecall 
    			
		fin: ecall

