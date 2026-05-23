package gwin

EventWindowClose :: struct {}

EventWindowResize :: struct {
	width:  int,
	height: int,
}

EventKeyboardEnter :: struct {
	keyboard: ^WaylandKeyboard,
}

EventKeyboardLeave :: struct {
	keyboard: ^WaylandKeyboard,
}

EventKeyDown :: struct {
	keyboard: ^WaylandKeyboard,
	key:      u32,
	str:      string,
}

EventKeyUp :: struct {
	keyboard: ^WaylandKeyboard,
	key:      u32,
	str:      string,
}

EventPointerEnter :: struct {
	pointer: ^WaylandPointer,
	x:       f32,
	y:       f32,
}

EventPointerLeave :: struct {
	pointer: ^WaylandPointer,
}

EventPointerMotion :: struct {
	pointer: ^WaylandPointer,
	x:       f32,
	y:       f32,
}

EventPointerRelative :: struct {
	pointer: ^WaylandPointer,
	dx:      f32,
	dy:      f32,
}

EventPointerButton :: struct {
	pointer: ^WaylandPointer,
	button:  u32,
	pressed: bool,
}

EventPointerScroll :: struct {
	pointer: ^WaylandPointer,
	dx:      f32,
	dy:      f32,
}

WindowEvent :: union {
	EventWindowClose,
	EventWindowResize,
	EventKeyboardEnter,
	EventKeyboardLeave,
	EventKeyDown,
	EventKeyUp,
	EventPointerEnter,
	EventPointerLeave,
	EventPointerMotion,
	EventPointerRelative,
	EventPointerButton,
	EventPointerScroll,
}

WindowEventHandler :: proc(window: ^WaylandWindow, event: WindowEvent)

