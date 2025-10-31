extends GUIDETestBase

var _input_detector: GUIDEInputDetector

func _setup():
	_input_detector = auto_free(GUIDEInputDetector.new())
	_input_detector.detection_countdown_seconds = 0
	_input_detector.detection_started.connect(func(): print_f("Detection started."))
	_input_detector.input_detected.connect(func(val): print_f("Input detected: %s" % val))
	
	add_child(_input_detector)
	

func test_input_is_detected():
	monitor_signals(_input_detector)
	
	# when i try to detect boolean input
	_input_detector.detect(GUIDEAction.GUIDEActionValueType.BOOL)
	
	# and i press a key
	tap_key(KEY_A)
	
	# then the input detector should emit a signal with the detected input
	await assert_signal(_input_detector).is_emitted("input_detected", [GUIDEInputMatcher.new(input_key(KEY_A))])
	

func test_axis_1d_input_is_detected():
	monitor_signals(_input_detector)
	
	# when i try to detect axis 1D input
	_input_detector.detect(GUIDEAction.GUIDEActionValueType.AXIS_1D)
	
	# and i move the mouse horizontally
	await mouse_move_by(Vector2(20, 0))
	
	# then the input detector should emit a signal with the detected input
	await assert_signal(_input_detector).is_emitted("input_detected", [GUIDEInputMatcher.new(input_mouse_axis_1d(GUIDEInputMouseAxis1D.GUIDEInputMouseAxis.X))])
	
	

func test_axis_2d_input_is_detected():
	monitor_signals(_input_detector)
	
	# when i try to detect axis 2D input
	_input_detector.detect(GUIDEAction.GUIDEActionValueType.AXIS_2D)
	
	# and i move the mouse diagonally
	await mouse_move_by(Vector2(20, 20))
	
	# then the input detector should emit a signal with the detected input
	await assert_signal(_input_detector).is_emitted("input_detected", [GUIDEInputMatcher.new(input_mouse_axis_2d())])

	
func test_aborting_input_detection_works():
	monitor_signals(_input_detector)
	_input_detector.abort_detection_on = [input_key(KEY_ESCAPE)]
	
	# when i try to detect boolean input
	_input_detector.detect(GUIDEAction.GUIDEActionValueType.BOOL)
	
	# and i press the abort key
	tap_key(KEY_ESCAPE)
	
	# then the input detector should emit a signal with null as the detected input
	await assert_signal(_input_detector).is_emitted("input_detected", [null])
	

func test_input_detector_ensures_that_abort_input_is_released_before_detection():
	monitor_signals(_input_detector)
	_input_detector.abort_detection_on = [input_key(KEY_ESCAPE)]
	var holder:Array = []
	# when i start pressing the abort key
	await key_down(KEY_ESCAPE)
	
	# and then run an input detection
	var detect = func(): 
		_input_detector.detect(GUIDEAction.GUIDEActionValueType.BOOL) 
		holder.append(await _input_detector.input_detected)
	
	detect.call()
	
	# and then release the abort key
	await key_up(KEY_ESCAPE)
	
	# and then send a normal escape
	await tap_key(KEY_ESCAPE)
	
	# then the input detector should emit a signal with null as the detected input
	assert_array(holder).has_size(1)
	assert_object(holder[0]).is_null()
