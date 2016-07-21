function love.conf(t)

	t.title = "TravelerDemo"
	t.author = "ArchAngel075"
	--t.version = "0.8.0"
	t.url = nil
	t.identity = nil
	t.release = false
  t.console = true

	t.window.width = 1200
	t.window.height = 600
	t.window.fullscreen = false
	t.window.vsync = true
	t.window.fsaa = 0

	t.modules.timer = true
	t.modules.keyboard = true
	t.modules.event = true
	t.modules.graphics = true
	t.modules.mouse = true

	t.modules.image = false
	t.modules.audio = false
	t.modules.sound = false
	t.modules.joystick = false
	t.modules.physics = true
end
