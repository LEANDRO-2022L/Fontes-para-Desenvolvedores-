#include "protheus.ch"

User Function AjuAtf()   

cAlias  := Alias()           // Salvar o Contexto em Utilizacao
nRecord := Recno()
cOrder  := IndexOrd()
cPerg   := "XCHBEM" 
 ValidPerg()
 pergunte(cPerg,.F.) 
 If !Pergunte(cPerg, .T.)
	Return(.T.)
Endif
//
cMsg := "Confirma o Processamento do Arquivo de Dados"
cTit := ""
cTip := "YESNO"
//
nRegs := 0                   // Numero Total de Registros Processados
//
Processa({|| u_CorrSn3()}, "Processando... Aguarde!")
//
//DbSelectArea(cAlias)
//DbSetOrder(cOrder)
//DbGoto(nRecord)
//
//Return

User Function ValidSn3()    

XRET:=.T.
Dbselectarea("SN3")
dbsetorder(1)
DBSEEK(XFILIAL("SN3")+MV_PAR01+MV_PAR02)
IF found()
	if SN3->N3_BAIXA<>"1"
   msgalert("O BEM "+MV_PAR01+"-"+MV_PAR02+" NÃO NECESSITA AJUSTE.")
   XRET:=.F.
   endif
else
   msgalert("O BEM "+MV_PAR01+"-"+MV_PAR02+" NÃO FOI ENCONTRADO")
   XRET:=.F.
ENDIF
RETURN(XRET)
   
User Function CorrSn3()
Dbselectarea("SN3")
dbsetorder(1)
DBSEEK(XFILIAL("SN3")+MV_PAR01+MV_PAR02)
IF found()
IF SN3->N3_BAIXA=="1"
   SN3->(RecLock("SN3", .F.))
   SN3->N3_BAIXA:="0"
   SN3->N3_DTBAIXA:=CTOD("  /  /  ")
   SN3->(MsUnlock())
endif
endif
	MsgInfo( "Ajuste realizado com sucesso!!!")
RETURN

//**************************************************************************************
//                            Valida Perguntas
//**************************************************************************************
Static Function ValidPerg()

_sAlias := Alias()
DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PADR(cPerg,10)
aRegs :={}

//-------------------------------------------------------------------
// Variaveis utilizadas para parametros
// mv_par01    De Codigo

AADD(aRegs,{cPerg,"01","Codigo Base         ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SN1",""})
AADD(aRegs,{cPerg,"02","Item                ?","","","mv_ch2","C",4,0,0,"G","U_ValidSn3()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//AADD(aRegs,{cPerg,"03","Codigo Base         ?","","","mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SN1",""})

For i:=1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		For j:=1 to FCount()
			If j <= Len(aRegs[i])
				FieldPut(j,aRegs[i,j])
			Else
				Exit
			Endif
		Next
		MsUnlock()
	Endif
Next
DbSelectArea(_sAlias)

Return