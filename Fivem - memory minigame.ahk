; <<Copyright (C)  2022 Abel Granados>>
; <<https://es.fiverr.com/abelgranados>>

Process, Priority, , High
SetBatchLines, -1
ListLines, Off
SetKeyDelay, -1, -1
SendMode, Event
CoordMode, Pixel, Window  
CoordMode, Mouse, Window  
CoordMode, ToolTip, Window 


reset := false, playBack := false, pattern := [], cGris := 0xBFBFBF, cNormal := 0x614D39, delay := 3000
containerX := 650, containerY := 236, squareWidth := 83, squareHeight := 83  ; test containerX := 200, containerY := 60, squareWidth := 83, squareHeight := 83
marginRigth := 20, marginBottom := 20, regiones := [], pixeles := []

xPrev := containerX + 10 - 1
yPrev := containerY + 10 - 1
loop, 6 {
	
	loop, 6 {
		
		n := regiones.push(crearRegion(xPrev + 1, yPrev + 1, xPrev + squareWidth, yPrev + squareHeight))
		xPrev := regiones[n].x2 + marginRigth
		
		middleX := (regiones[n].x2 + regiones[n].x1)//2
		middleY := (regiones[n].y2 + regiones[n].y1)//2
		pixeles.push(new _Pixel(middleX, middleY))

	}

	xPrev := containerX + 10 - 1
	yPrev := regiones[n].y2 + marginBottom

}

Hotkey, ^f12, showLayout
Hotkey, ^f11, toggleScript
Hotkey, ^f10, reload
Hotkey, ^f9, pause
return

esc::
	ExitApp
return

pause:
	Pause, Toggle, 1
	if(A_IsPaused){
		showNotificationMsg("Script Paused", 1)
	}else{
		showNotificationMsg("Script Unpaused", 1)
	}
return


reload:
	showNotificationMsg("Reloading...", 1)
	Sleep, 500
	Reload
return

toggleScript:
	if(toggleScript:=!toggleScript){
		setTimer, script, 20
		showNotificationMsg("Script On")
		return
	}

	setTimer, script, Off
	reset := true
	BlockInput, MouseMoveOff
	showNotificationMsg("Script will Off")
return


showLayout:

	if (toggleLayout:=!toggleLayout){
		
		winActiva := WinExist("A")
		idGrafico := crearColeccionGraficos(regiones.Count())
		dibujarColeccionRectangulos(idGrafico, regiones, winActiva)

	}else{

		destruirColeccionGraficos(idGrafico)
		idGrafico := []
	}

return

script(){

	Global
	
	if(reset){
		playBack := false, pattern = []
		reset := false
	}
	
	if(!minigameIsOpen()){
		;showNotificationMsg("Waiting minigame")
		playBack := false, pattern = []
		return
	}

	BlockInput, MouseMove
	if(playBack){

		randomSleep(160, 200)
		
		if(!pattern.Count()){
			showNotificationMsg("No pattern recorded")
			playBack := false, pattern := []
			BlockInput, MouseMoveOff
			return
		}

		;showNotificationMsg("Play Back")
		loop, % pattern.Count(){

			if(pattern[A_Index]){
				clicRegion(pattern[A_Index], 10, 10)
				randomSleep(80, 120)
			}
		}
		
		BlockInput, MouseMoveOff
		playBack := false, pattern := []
		Sleep, delay
	}

	;showNotificationMsg("Memorizing")
	playBack := true
	loop, % regiones.Count() {

		if(pixeles[A_Index].Is(cGris, 16)){
		
			playBack := false 

			if(pattern[A_Index]){
				
			}else{

				pattern.push(regiones[A_Index])
			
			}
		
		}else{

			if(pattern[A_Index]){ 
				
			}else{

				pattern[A_Index] := 0
			
			}
		
		}
	}

}


;#################### Script functions

minigameIsOpen(){

	Global cGris, cNormal, pixeles

	loop, % pixeles.Count() {
		if(!(pixeles[A_Index].Is(cNormal, 16) or pixeles[A_Index].Is(cGris, 16))){
			return false
		}		
	}

	return true

}
















;#################### libreria func


class _Pixel {
	
	__New(x:=0, y:=0, color:=0xffffff){
		this.x := x
		this.y := y
		this.color := color
	}

	Is(color, variation){

		PixelSearch, , , this.x, this.y, this.x, this.y, color, variation, fast
		if(ErrorLevel){
			return false
		}
		
		return true

	}
}



crearRegion(x1, y1, x2, y2){

	if (x1<0 or y1<0 or x2<0 or y2<0){
		return 0
	}

	if(x2 < x1){
		temp := x1
		x1 := x2
		x2 := temp
	}

	if(y2 < y1){
		temp := y1
		y1 := y2
		y2 := temp
	}

	return {"x1":x1, "y1":y1, "x2":x2, "y2":y2}

}

crearGrafico(cc:="0x3CFF3C") {

	Gui, New, +HwndGrafico  +AlwaysOnTop -Caption +E0x00000020 +E0x08000000
	Gui, Color, %cc%
	return Grafico

}

crearColeccionGraficos(cantidad){

	ids := []
	loop, %cantidad%
		ids[A_Index] := crearGrafico()
	
	return ids
}

dibujarRectangulo(winHwnd:=0, punto:=0, hwndGrafico:=0, x1:=0, y1:=0, x2:=0, y2:=0, borde:=2){
    
    if (!hwndGrafico or x1<0 or y1<0 or x2<0 or y2<0){
        return 1
    }

    addX := 0, addY := 0 
    if (winHwnd != 0){
        
        win := WinExist("ahk_id " winHwnd)
        if !win
            return 2
        
        WinGetPos, wx, wy, , , ahk_id %win%
      	addX := wx
       	addY := wy
    }

    if(punto != 0){
        addX += punto.x
        addY += punto.y
    }

    x1+=addX
    y1+=addY
    x2+=addX
    y2+=addY

    w := x2 - x1
    h := y2 - y1
    w2:= w - borde
    h2:= h - borde
  
    Gui, %hwndGrafico%: Show, w%w% h%h% x%x1% y%y1% NA
    WinSet, Transparent, 255
    WinSet, Region, 0-0 %w%-0 %w%-%h% 0-%h% 0-0 %borde%-%borde% %w2%-%borde% %w2%-%h2% %borde%-%h2% %borde%-%borde%, ahk_id %hwndGrafico%

}

dibujarColeccionRectangulos(idGraficos, regiones, winHwnd:=0, punto:=0){

	loop, % idGraficos.Count()
		dibujarRectangulo(winHwnd, punto, idGraficos[A_Index], regiones[A_Index].x1, regiones[A_Index].y1, regiones[A_Index].x2, regiones[A_Index].y2)
	
}

destruirGrafico(hwndGrafico){
	
	if (!hwndGrafico)
		return

	Gui, %hwndGrafico%:Destroy
}

destruirColeccionGraficos(ids){
	
	loop, % ids.Count()
		destruirGrafico(ids[A_Index]) 
	
}

clicRegion(region, insetX:=0, insetY:=0){

    ;El caller se aseguro de que la region es valida
    mex := (region.x1 + region.x2)//2
    rax := distribucionAlObjetivo((region.x1+insetX), mex, (region.x2-insetX))

    mey := (region.y1 + region.y2)//2
    ray := distribucionAlObjetivo((region.y1+insetY), mey, (region.y2-insetY))

    SetDefaultMouseSpeed, randomValue(2, 4)
    SetMouseDelay, randomValue(15, 30)
    
    MouseMove, rax, ray
    randomSleep(80, 120) 

    SetMouseDelay, randomValue(60, 110)
    Click
    
    SetMouseDelay, 10
    SetDefaultMouseSpeed, 2
}


showNotificationMsg(msg:="", centrar :=0){
    
   	CoordMode, ToolTip, Window
    
    if(centrar){
    	WinGetPos, X, Y, Width, Height, A
    	Tooltip, % msg, Width//2, Height//2, 1
    }else{
    	Tooltip, % msg , , , 1
    }

    setTimer, quitarTooltip, -2000
    return

    quitarTooltip:
        Tooltip, , , , 1
    return

}

showErrorMsg(msg){

	CoordMode, ToolTip, Window
    
    WinGetPos,,, Width, Height, A
    Tooltip, % msg, Width//2, Height//2, 20

}

randomSleep(min:=30, max:=1000){
    Sleep,  distribucionAlObjetivo(min, ((min+max)//2), max)
}

randomValue(min, max){
    return  distribucionAlObjetivo(min, ((min+max)//2), max)
}

distribucionAlObjetivo(ini, objetivo, fin){
  
    Random, izq, ini, objetivo
    Random, der, objetivo, fin
    Random, cerca, izq, der
    return cerca

}