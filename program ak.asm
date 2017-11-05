	 ORG 800H  
WYBOR  
	 LXI H,MENU  
	 RST 3  
	 RST 2  
	 CPI '1'  
	 CZ PROCEDURA_1  
	 CPI '2'  
	 CZ PROCEDURA_2  
	 JMP WYBOR  
PROCEDURA_1  
	 MVI H,0  
	 MVI L,0  
	 LXI H,ENTER  
	 RST 3  
	 RST 5  
	 MOV B,D  
	 MOV C,E  
	 RST 5  
	 MVI H,0  
	 MVI L,0  
PETLA 	 DAD D  
	 DCX B  
	 MOV A,B  
	 CPI 0  
	 JNZ PETLA  
	 MOV A,C  
	 CPI 0  
	 JNZ PETLA  
	 HLT  
PROCEDURA_2  
	 LXI H,ENTER  
	 RST 3  
	 RST 5  
	 MOV B,D  
	 MOV C,E  
	 LXI H,ENTER  
	 RST 3  
	 RST 5  
	 MVI H,0  
	 MVI L,0  
PETLA1  
	 MOV A,C  
	 SBB E  
	 MOV C,A  
	 MOV A,B  
	 SBB D  
	 MOV B,A  
	 JC KONIEC  
	 INX H  
	 JMP PETLA1  
KONIEC  
	 RST 6  
MENU 	 DB 10,13,'wpisz 1 lub 2 > ','@'                       
ENTER 	 DB 10,13,'','@'                          
