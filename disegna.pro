; **** crea un oggetto destinazione

oWindow = OBJ_NEW('IDLgrWindow')

; **** crea un visualizzatore che occupa la finestra ****
;oView = OBJ_NEW('IDLgrView')
oView = OBJ_NEW('IDLgrView', VIEWPLANE_RECT=[-4, -4, 80, 80])
oView-> setProperty, COLOR = [160, 200, 160]


	; **** crea una scena

;oScene = OBJ_NEW('IDLgrScene')
;oScene->Add, oView

	; **** crea un grafico **** 


; **** crea un model e l'aggiunge al view ****

oModel = OBJ_NEW('IDLgrModel')


; **** crea un plot e l'aggiunge al modello ****

X=[1, 3, 6, 9, 12, 15, 18, 21]
Y=[2, 6, 12, 18, 24, 30, 36, 42]
print, X, Y
disegna = OBJ_NEW('IDLgrPlot', X, Y)

; **** crea gli assi e aggiungili 

xaxis = OBJ_NEW('IDLgrAxis', 0)
yaxis = OBJ_NEW('IDLgrAxis', 1)
xaxis ->SetProperty, RANGE = [0, 50]
yaxis ->SetProperty, RANGE = [0, 50] 
disegna->SetProperty, xrange = [1, 42]
disegna->SetProperty, symbol = 5

; **** crea una casella di testo e la aggiunge al modello

otext = OBJ_NEW('IDLgrTExt', 'grafico 1', ALIGNMENT=0.5, location = [60, 60])
oModel->Add, oText


; **** aggiungi il il modello al visore

oView->Add, oModel

; **** aggiungi il plot al modelllo

oModel->Add, disegna
oModel->Add, xaxis
oMOdel->Add, yaxis

; **** disegna il visore ****


Owindow->Draw, oView





;-----------------------------------------------



;read, b
;OBJ_DESTROY, oWindow
;OBJ_DESTROY, oView
end
