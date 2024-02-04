extends Node

var left: bool = true
var right: bool = true
var top: bool = true
var bottom: bool = true
var any: bool = true

func clearLeft():
	left = false
	updateAny()
	
func clearRight():
	right = false
	updateAny()
	
func clearTop():
	top = false
	updateAny()
	
func clearBottom():
	bottom = false
	updateAny()			

func updateAny():
	if left || right || top || bottom: any = true
	else: any = false
