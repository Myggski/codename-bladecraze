ANIMATION_STATE_TYPES = {
  IDLE = "idle",
  WALKING = "walking",
  DEAD = "dead",
}

AUDIO_TYPES = {
  MUSIC = 0,
  SFX = 1,
}

BUTTON_CLICK_TYPES = {
  LEFT = 1,
  RIGHT = 2,
  MIDDLE = 3,
}

BUTTON_EVENT_TYPES = {
  CLICK = "click",
  RELEASE = "release",
  ENTER = "enter",
  LEAVE = "leave",
}

BUTTON_ANIMATION_STATE_TYPES = {
  DEFAULT = 1,
  HOVER = 2,
  CLICK = 3,
}

COLOR = {
  RED = { 1, 0, 0, 1 },
  BLUE = { 0, 0, 1, 1 },
  GREEN = { 0, 1, 0, 1 },
  CYAN = { 0, 1, 1, 1 },
  YELLOW = { 1, 1, 0, 1 },
  MAGENTA = { 1, 0, 1, 1 },
  WHITE = { 1, 1, 1, 1 },
  BLACK = { 0, 0, 0, 1 }
}

CONTROLLER_TYPES = { KEYBOARD = 0, GAMEPAD = 1, }

GAME_EVENT_TYPES = {
  LOAD = "load",
  QUIT = "quit",
  MOUSE_PRESSED = "mousepressed",
  MOUSE_RELEASED = "mousereleased",
  DRAW_WORLD = "drawworld",
  DRAW_HUD = "drawhud",
  DRAW_WORLD_DEBUG = "drawworlddebug",
  DRAW_HUD_DEBUG = "drawhuddebug",
  UPDATE = "update",
  LATE_UPDATE = "lateupdate",
  JOYSTICK_ADDED = "joystickadded",
  JOYSTICK_REMOVED = "joystickremoved",
  JOYSTICK_PRESSED = "joystickpressed",
  JOYSTICK_RELEASED = "joystickreleased",
  KEY_PRESSED = "keypressed",
  KEY_RELEASED = "keyreleased",
}

GAMEPAD = {
  BUTTONS = {
    A = "a",
    B = "b",
    X = "x",
    Y = "y",
    BACK = "back",
    GUIDE = "guide",
    START = "start",
    LEFT_STICK = "leftstick",
    RIGHT_STICK = "rightstick",
    LEFT_SHOULDER = "leftshoulder",
    RIGHT_SHOULDER = "rightshoulder",
    DP_UP = "dpup",
    DP_DOWN = "dpdown",
    DP_LEFT = "dpleft",
    DP_RIGHT = "dpright",
  },
  AXES = {
    LEFT_X = "leftx",
    LEFT_Y = "lefty",
    RIGHT_X = "right_x",
    RIGHT_Y = "right_y",
    TRIGGER_LEFT = "triggerleft",
    TRIGGER_RIGHT = "triggerright",
  },
}

GAMEPAD.AXES.TRIGGERS = {
  GAMEPAD.AXES.TRIGGER_LEFT, GAMEPAD.AXES.TRIGGER_RIGHT,
}

GAMEPAD.BUTTONS.ALL = {
  GAMEPAD.BUTTONS.A, GAMEPAD.BUTTONS.B, GAMEPAD.BUTTONS.X, GAMEPAD.BUTTONS.Y,
  GAMEPAD.BUTTONS.BACK, GAMEPAD.BUTTONS.GUIDE, GAMEPAD.BUTTONS.START,
  GAMEPAD.BUTTONS.LEFT_STICK, GAMEPAD.BUTTONS.RIGHT_STICK,
  GAMEPAD.BUTTONS.LEFT_SHOULDER, GAMEPAD.BUTTONS.RIGHT_SHOULDER,
  GAMEPAD.BUTTONS.DP_UP, GAMEPAD.BUTTONS.DP_DOWN, GAMEPAD.BUTTONS.DP_LEFT, GAMEPAD.BUTTONS.DP_RIGHT,
}

KEYBOARD = {
  W = "w",
  A = "a",
  S = "s",
  D = "d",
  Q = "q",
  R = "r",
  UP = "up",
  LEFT = "left",
  DOWN = "down",
  RIGHT = "right",
  SPACE = "space",
  ENTER = "return",
  ESCAPE = "escape",
}

KEYBOARD.ALL = {
  KEYBOARD.W, KEYBOARD.A, KEYBOARD.S, KEYBOARD.D,
  KEYBOARD.UP, KEYBOARD.LEFT, KEYBOARD.DOWN, KEYBOARD.RIGHT,
  KEYBOARD.SPACE, KEYBOARD.ENTER, KEYBOARD.ESCAPE,
}
