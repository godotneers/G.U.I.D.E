using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Guide;

public partial class GUIDEInputState : RefCounted {
	public const int ANY_JOY_DEVICE_ID = -1;
	public const int VIRTUAL_JOY_DEVICE_ID_OFFSET = -2;

	private Dictionary<int, int> _virtualJoyDevices = new();

	[Signal]
	public delegate void KeyboardStateChangedEventHandler();
	[Signal]
	public delegate void MousePositionChangedEventHandler();
	[Signal]
	public delegate void MouseButtonStateChangedEventHandler();
	[Signal]
	public delegate void JoyButtonStateChangedEventHandler();
	[Signal]
	public delegate void JoyAxisStateChangedEventHandler();
	[Signal]
	public delegate void TouchStateChangedEventHandler();

	private Dictionary<int, bool> _keys = new();
	private Dictionary<int, Vector2> _fingerPositions = new();
	private Vector2 _mouseMovement = Vector2.Zero;
	private Dictionary<int, bool> _mouseButtons = new();
	private Dictionary<int, Dictionary<int, bool>> _joyButtons = new();
	private Dictionary<int, Dictionary<int, float>> _joyAxes = new();

	private Dictionary<int, int> _joyIndexToDeviceId = new();

	private Dictionary<int, bool> _pendingKeys = new();
	private Dictionary<int, bool> _pendingMouseButtons = new();
	private Dictionary<int, Dictionary<int, bool>> _pendingJoyButtons = new();

	public GUIDEInputState() {
		Input.JoyConnectionChanged += _RefreshJoyDeviceIds;
		_Clear();
	}

	public int ConnectVirtualStick(int stickIndex) {
		if (stickIndex < 0) {
			GD.PushError($"Invalid stick index {stickIndex} for virtual stick. Must be >= 0.");
			stickIndex = 0;
		}

		int deviceId = VIRTUAL_JOY_DEVICE_ID_OFFSET - stickIndex;
		if (_virtualJoyDevices.ContainsKey(deviceId)) {
			_virtualJoyDevices[deviceId]++;
			return deviceId;
		}

		_virtualJoyDevices[deviceId] = 1;
		_RefreshJoyDeviceIds(0, false);

		return deviceId;
	}

	public void DisconnectVirtualStick(int deviceId) {
		if (!_virtualJoyDevices.ContainsKey(deviceId)) return;

		int count = _virtualJoyDevices[deviceId];
		if (count > 1) {
			_virtualJoyDevices[deviceId]--;
			return;
		}

		_virtualJoyDevices.Remove(deviceId);
		_joyIndexToDeviceId.Remove(deviceId);

		if (_joyButtons.ContainsKey(deviceId)) {
			_joyButtons.Remove(deviceId);
			EmitSignal(SignalName.JoyButtonStateChanged);
		}

		if (_joyAxes.ContainsKey(deviceId)) {
			_joyAxes.Remove(deviceId);
			EmitSignal(SignalName.JoyAxisStateChanged);
		}
	}

	public void _Clear() {
		_keys.Clear();
		_fingerPositions.Clear();
		_mouseMovement = Vector2.Zero;
		_mouseButtons.Clear();
		_joyButtons.Clear();
		_joyAxes.Clear();

		_RefreshJoyDeviceIds(0, false);

		_joyButtons[ANY_JOY_DEVICE_ID] = new();
		_joyAxes[ANY_JOY_DEVICE_ID] = new();

		foreach (var deviceId in _virtualJoyDevices.Keys) {
			_joyIndexToDeviceId.Remove(deviceId);
		}

		_virtualJoyDevices.Clear();
	}

	private void _RefreshJoyDeviceIds(long _ignore1, bool _ignore2) {
		_joyIndexToDeviceId.Clear();
		var connectedJoys = Input.GetConnectedJoypads();

		foreach (var deviceId in _virtualJoyDevices.Keys) {
			connectedJoys.Add(deviceId);
		}

		for (int i = 0; i < connectedJoys.Count; i++) {
			int deviceId = connectedJoys[i];
			if (deviceId >= 0) {
				_joyIndexToDeviceId[i] = deviceId;
			}
			else {
				_joyIndexToDeviceId[deviceId] = deviceId;
			}

			if (!_joyButtons.ContainsKey(deviceId)) _joyButtons[deviceId] = new();
			if (!_joyAxes.ContainsKey(deviceId)) _joyAxes[deviceId] = new();
			if (!_pendingJoyButtons.ContainsKey(deviceId)) _pendingJoyButtons[deviceId] = new();
		}

		_joyIndexToDeviceId[-1] = ANY_JOY_DEVICE_ID;

		foreach (var deviceId in _pendingJoyButtons.Keys.ToList()) {
			if (deviceId != ANY_JOY_DEVICE_ID && !connectedJoys.Contains(deviceId)) {
				_pendingJoyButtons.Remove(deviceId);
			}
		}

		bool dirty = false;
		foreach (var deviceId in _joyButtons.Keys.ToList()) {
			if (deviceId != ANY_JOY_DEVICE_ID && !connectedJoys.Contains(deviceId)) {
				dirty = true;
				_joyButtons.Remove(deviceId);
			}
		}

		if (dirty) EmitSignal(SignalName.JoyButtonStateChanged);

		dirty = false;
		foreach (var deviceId in _joyAxes.Keys.ToList()) {
			if (deviceId != ANY_JOY_DEVICE_ID && !connectedJoys.Contains(deviceId)) {
				dirty = true;
				_joyAxes.Remove(deviceId);
			}
		}

		if (dirty) EmitSignal(SignalName.JoyAxisStateChanged);
	}

	public void _Reset() {
		_mouseMovement = Vector2.Zero;

		foreach (var kvp in _pendingKeys) {
			int key = kvp.Key;
			bool isDown = kvp.Value;
			if (isDown && !_keys.ContainsKey(key)) {
				_keys[key] = true;
				EmitSignal(SignalName.KeyboardStateChanged);
			}
			else if (!isDown && _keys.ContainsKey(key)) {
				_keys.Remove(key);
				EmitSignal(SignalName.KeyboardStateChanged);
			}
		}
		_pendingKeys.Clear();

		foreach (var kvp in _pendingMouseButtons) {
			int button = kvp.Key;
			bool isDown = kvp.Value;
			if (isDown && !_mouseButtons.ContainsKey(button)) {
				_mouseButtons[button] = true;
				EmitSignal(SignalName.MouseButtonStateChanged);
			}
			else if (!isDown && _mouseButtons.ContainsKey(button)) {
				_mouseButtons.Remove(button);
				EmitSignal(SignalName.MouseButtonStateChanged);
			}
		}
		_pendingMouseButtons.Clear();

		foreach (var joy in _pendingJoyButtons.Keys) {
			foreach (var buttonKvp in _pendingJoyButtons[joy]) {
				int button = buttonKvp.Key;
				bool isDown = buttonKvp.Value;
				bool changed = false;

				if (isDown && !_joyButtons[joy].ContainsKey(button)) {
					_joyButtons[joy][button] = true;
					changed = true;
				}
				else if (!isDown && _joyButtons[joy].ContainsKey(button)) {
					_joyButtons[joy].Remove(button);
					changed = true;
				}

				if (changed) {
					bool anyValue = false;
					foreach (var inner in _joyButtons.Keys) {
						if (inner != ANY_JOY_DEVICE_ID && _joyButtons[inner].ContainsKey(button)) {
							anyValue = true;
							break;
						}
					}

					if (anyValue) {
						_joyButtons[ANY_JOY_DEVICE_ID][button] = true;
					}
					else {
						_joyButtons[ANY_JOY_DEVICE_ID].Remove(button);
					}
					EmitSignal(SignalName.JoyButtonStateChanged);
				}
			}
			_pendingJoyButtons[joy].Clear();
		}
	}

	public void _Input(InputEvent @event) {
		if (@event is InputEventKey keyEvent) {
			int index = (int)keyEvent.PhysicalKeycode;
			if (_pendingKeys.ContainsKey(index)) {
				_pendingKeys[index] = keyEvent.Pressed;
				return;
			}

			_pendingKeys[index] = keyEvent.Pressed;

			if (keyEvent.Pressed && !_keys.ContainsKey(index)) {
				_keys[index] = true;
				EmitSignal(SignalName.KeyboardStateChanged);
				return;
			}

			if (!keyEvent.Pressed && _keys.ContainsKey(index)) {
				_keys.Remove(index);
				EmitSignal(SignalName.KeyboardStateChanged);
				return;
			}
			return;
		}

		if (@event is InputEventMouseMotion mouseMotion) {
			_mouseMovement += mouseMotion.Relative;
			EmitSignal(SignalName.MousePositionChanged);
			return;
		}

		if (@event is InputEventMouseButton mouseButton) {
			int index = (int)mouseButton.ButtonIndex;
			if (_pendingMouseButtons.ContainsKey(index)) {
				_pendingMouseButtons[index] = mouseButton.Pressed;
				return;
			}

			_pendingMouseButtons[index] = mouseButton.Pressed;

			if (mouseButton.Pressed && !_mouseButtons.ContainsKey(index)) {
				_mouseButtons[index] = true;
				EmitSignal(SignalName.MouseButtonStateChanged);
				return;
			}

			if (!mouseButton.Pressed && _mouseButtons.ContainsKey(index)) {
				_mouseButtons.Remove(index);
				EmitSignal(SignalName.MouseButtonStateChanged);
				return;
			}
			return;
		}

		if (@event is InputEventJoypadButton joyButton) {
			int deviceId = joyButton.Device;
			int button = (int)joyButton.ButtonIndex;

			if (!_pendingJoyButtons.ContainsKey(deviceId)) _pendingJoyButtons[deviceId] = new();

			if (_pendingJoyButtons[deviceId].ContainsKey(button)) {
				_pendingJoyButtons[deviceId][button] = joyButton.Pressed;
				return;
			}

			_pendingJoyButtons[deviceId][button] = joyButton.Pressed;

			bool changed = false;
			if (joyButton.Pressed && !_joyButtons[deviceId].ContainsKey(button)) {
				_joyButtons[deviceId][button] = true;
				changed = true;
			}
			else if (!joyButton.Pressed && _joyButtons[deviceId].ContainsKey(button)) {
				_joyButtons[deviceId].Remove(button);
				changed = true;
			}

			if (changed) {
				bool anyValue = false;
				foreach (var inner in _joyButtons.Keys) {
					if (inner != ANY_JOY_DEVICE_ID && _joyButtons[inner].ContainsKey(button)) {
						anyValue = true;
						break;
					}
				}

				if (anyValue) {
					_joyButtons[ANY_JOY_DEVICE_ID][button] = true;
				}
				else {
					_joyButtons[ANY_JOY_DEVICE_ID].Remove(button);
				}
				EmitSignal(SignalName.JoyButtonStateChanged);
			}
			return;
		}

		if (@event is InputEventJoypadMotion joyMotion) {
			int deviceId = joyMotion.Device;
			int axis = (int)joyMotion.Axis;

			if (!_joyAxes.ContainsKey(deviceId)) _joyAxes[deviceId] = new();
			_joyAxes[deviceId][axis] = joyMotion.AxisValue;

			float anyValue = 0.0f;
			float maximumActuation = 0.0f;
			foreach (var inner in _joyAxes.Keys) {
				if (inner != ANY_JOY_DEVICE_ID && _joyAxes[inner].ContainsKey(axis)) {
					float strength = Math.Abs(_joyAxes[inner][axis]);
					if (strength > maximumActuation) {
						maximumActuation = strength;
						anyValue = _joyAxes[inner][axis];
					}
				}
			}

			_joyAxes[ANY_JOY_DEVICE_ID][axis] = anyValue;
			EmitSignal(SignalName.JoyAxisStateChanged);
			return;
		}

		if (@event is InputEventScreenTouch screenTouch) {
			if (screenTouch.Pressed) {
				_fingerPositions[screenTouch.Index] = screenTouch.Position;
			}
			else {
				_fingerPositions.Remove(screenTouch.Index);
			}
			EmitSignal(SignalName.TouchStateChanged);
			return;
		}

		if (@event is InputEventScreenDrag screenDrag) {
			_fingerPositions[screenDrag.Index] = screenDrag.Position;
			EmitSignal(SignalName.TouchStateChanged);
			return;
		}
	}

	public bool IsKeyPressed(Key key) => _keys.ContainsKey((int)key);

	public bool IsAtLeastOneKeyPressed(IEnumerable<Key> keys) {
		foreach (var key in keys) {
			if (_keys.ContainsKey((int)key)) return true;
		}
		return false;
	}

	public bool AreAllKeysPressed(IEnumerable<Key> keys) {
		foreach (var key in keys) {
			if (!_keys.ContainsKey((int)key)) return false;
		}
		return true;
	}

	public bool IsAnyKeyPressed() => _keys.Count > 0;

	public Vector2 GetMouseDeltaSinceLastFrame() => _mouseMovement;

	public Vector2 GetMousePosition() => Engine.GetMainLoop() is SceneTree tree ? tree.Root.GetMousePosition() : Vector2.Zero;

	public bool IsMouseButtonPressed(MouseButton buttonIndex) => _mouseButtons.ContainsKey((int)buttonIndex);

	public bool IsAnyMouseButtonPressed() => _mouseButtons.Count > 0;

	public float GetJoyAxisValue(int index, JoyAxis axis) {
		if (!_joyIndexToDeviceId.TryGetValue(index, out int deviceId)) return 0.0f;
		if (_joyAxes.TryGetValue(deviceId, out var inner)) {
			if (inner.TryGetValue((int)axis, out float value)) return value;
		}
		return 0.0f;
	}

	public bool IsJoyButtonPressed(int index, JoyButton button) {
		if (!_joyIndexToDeviceId.TryGetValue(index, out int deviceId)) return false;
		if (_joyButtons.TryGetValue(deviceId, out var inner)) {
			return inner.ContainsKey((int)button);
		}
		return false;
	}

	public bool IsAnyJoyButtonPressed() {
		foreach (var inner in _joyButtons.Values) {
			if (inner.Count > 0) return true;
		}
		return false;
	}

	public bool IsAnyJoyAxisActuated(float minimumStrength) {
		foreach (var inner in _joyAxes.Values) {
			foreach (var value in inner.Values) {
				if (Math.Abs(value) >= minimumStrength) return true;
			}
		}
		return false;
	}

	public Vector2 GetFingerPosition(int fingerIndex, int fingerCount) {
		if (_fingerPositions.Count == 0) return Vector2.Inf;
		if (_fingerPositions.Count != fingerCount) return Vector2.Inf;

		if (fingerIndex > -1) {
			if (_fingerPositions.TryGetValue(fingerIndex, out Vector2 pos)) return pos;
			return Vector2.Inf;
		}

		Vector2 result = Vector2.Zero;
		foreach (var value in _fingerPositions.Values) {
			result += value;
		}
		return result / fingerCount;
	}

	public Vector2[] GetFingerPositions() => _fingerPositions.Values.ToArray();

	public bool IsAnyFingerDown() => _fingerPositions.Count > 0;
}
