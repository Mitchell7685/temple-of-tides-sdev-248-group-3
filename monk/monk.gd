extends StaticBody2D
signal talking

var message: String = "text"

func talk():
	talking.emit(message)
