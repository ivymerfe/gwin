package cpu_shader

import "core:log"
import "core:os"
import "core:sync"
import "core:sys/linux"
import "core:thread"
import "core:time"

import ".."
import "../wl"

WIDTH :: 1920
HEIGHT :: 1080
NUM_BUFFERS :: 3 // render, present, free

g_context: gwin.WaylandContext
g_window: ^gwin.WaylandWindow

Framebuffer :: struct {
	data: [^]u32,
	wl:   ^wl.buffer,
}

g_buffers: [NUM_BUFFERS]Framebuffer

g_last_rendered_buffer: uint = 0
g_shown_buffer: uint = 0

create_shm_file :: proc(size: i64) -> (linux.Fd, linux.Errno) {
	name: cstring = "wayland-shm"
	r := linux.syscall(linux.SYS_memfd_create, cast(rawptr)name, 1)
	if r < 0 {
		return -1, linux.Errno(-r)
	}
	fd := linux.Fd(r)
	err := linux.ftruncate(fd, size)
	if err != .NONE {
		return -1, linux.Errno(-err)
	}
	return fd, .NONE
}

main :: proc() {
	context.logger = log.create_console_logger()

	wl_start := time.now()
	if (!gwin.create_wayland_context(&g_context, event_handler)) {
		log.panic("Failed to initialize wayland context")
	}
	window, success := gwin.create_window(
		&g_context,
		0,
		"gwin",
		"test",
		WIDTH,
		HEIGHT,
		WIDTH,
		HEIGHT,
	)
	if !success {
		log.panic("Failed to create window")
	}
	g_window = window
	wl_time := time.duration_milliseconds(time.diff(wl_start, time.now()))
	log.infof("Wayland init took %.2f ms", wl_time)

	stride := WIDTH * 4
	buf_size := stride * HEIGHT
	pool_size := buf_size * NUM_BUFFERS

	fd, err := create_shm_file(i64(pool_size))
	if err != .NONE {
		log.panic("Failed to create shm file: %v", err)
	}
	data: rawptr
	data, err = linux.mmap(0, uint(pool_size), {.READ, .WRITE}, {.SHARED}, fd, 0)
	if err != .NONE {
		log.panic("mmap failed with err = %v", err)
	}
	buf_data := cast([^]u32)data
	g_buffers[0].data = &buf_data[0]
	g_buffers[1].data = &buf_data[1 * WIDTH * HEIGHT]
	g_buffers[2].data = &buf_data[2 * WIDTH * HEIGHT]

	pool := wl.shm_create_pool(g_context.shm, int(fd), pool_size)
	g_buffers[0].wl = wl.shm_pool_create_buffer(pool, 0, WIDTH, HEIGHT, stride, .xrgb8888)
	g_buffers[1].wl = wl.shm_pool_create_buffer(
		pool,
		1 * buf_size,
		WIDTH,
		HEIGHT,
		stride,
		.xrgb8888,
	)
	g_buffers[2].wl = wl.shm_pool_create_buffer(
		pool,
		2 * buf_size,
		WIDTH,
		HEIGHT,
		stride,
		.xrgb8888,
	)
	wl.shm_pool_destroy(pool)
	linux.close(fd)

	log.info("Initialized")
	wl.surface_attach(g_window.surface, g_buffers[g_shown_buffer].wl, 0, 0)
	wl.surface_damage_buffer(g_window.surface, 0, 0, WIDTH, HEIGHT)

	thread.create_and_start(render_proc, context)
	request_next_frame()
	for gwin.dispatch_events(&g_context) {

	}
}

request_next_frame :: proc "c" () {
	callback := wl.surface_frame(g_window.surface)
	wl.callback_add_listener(callback, &frame_listener, nil)
	wl.surface_commit(g_window.surface)
}

on_frame_done :: proc "c" (data: rawptr, callback: ^wl.callback, time: uint) {
	wl.callback_destroy(callback)

	rend_buffer := sync.atomic_load(&g_last_rendered_buffer)
	curr_buffer := sync.atomic_exchange(&g_shown_buffer, rend_buffer)
	if rend_buffer != curr_buffer {
		wl.surface_attach(g_window.surface, g_buffers[rend_buffer].wl, 0, 0)
		wl.surface_damage_buffer(g_window.surface, 0, 0, WIDTH, HEIGHT)
	}

	request_next_frame()
}

frame_listener := wl.callback_listener {
	done = on_frame_done,
}

g_free_table := [3][3]uint{{1, 2, 1}, {2, 0, 0}, {1, 0, 1}}
render_proc :: proc() {
	stopwatch: time.Stopwatch
	time.stopwatch_start(&stopwatch)

	for {
		shown_index := sync.atomic_load(&g_shown_buffer)
		last_index := g_last_rendered_buffer
		buf_index := g_free_table[last_index][shown_index]
		buffer := g_buffers[buf_index].data

		current_time := time.duration_seconds(time.stopwatch_duration(stopwatch))
		info := RenderInfo {
			time   = f32(current_time),
			width  = WIDTH,
			height = HEIGHT,
		}
		render(buffer, info)

		sync.atomic_store(&g_last_rendered_buffer, buf_index)
		log.infof("frame done")
	}
}

event_handler :: proc(window: ^gwin.WaylandWindow, event_union: gwin.WindowEvent) {
	#partial switch event in event_union {
	case gwin.EventWindowClose:
		os.exit(0)
	case gwin.EventPointerButton:
		gwin.lock_pointer(event.pointer, true, window)
	case gwin.EventKeyDown:
		log.infof("Pressed key: %d -> %s", event.key, event.str)
	}
}

