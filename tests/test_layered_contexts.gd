extends GUIDETestBase

var _context1:GUIDEMappingContext
var _context2:GUIDEMappingContext
var _action1:GUIDEAction
var _action2:GUIDEAction

func _setup() -> void:
	_context1 = mapping_context()
	_context2 = mapping_context()
	_action1 = action_bool()
	_action2 = action_bool()
	
	map(_context1, _action1, input_key(KEY_A))
	map(_context2, _action2, input_key(KEY_B))
	

## https://github.com/godotneers/G.U.I.D.E/issues/89
## When layering contexts we should not get duplicate action mappings.
func test_mapping_works() -> void:
	GUIDE.enable_mapping_context(_context1)

	assert_int(GUIDE._active_action_mappings.size()).is_equal(1)
	
	# when i add the second context
	GUIDE.enable_mapping_context(_context2)
	
	assert_int(GUIDE._active_action_mappings.size()).is_equal(2)


## https://github.com/godotneers/G.U.I.D.E/issues/94
## When layering contexts, the inputs are properly mapped.
func test_mapping_inputs_works() -> void:
	GUIDE.enable_mapping_context(_context1)
	
	# when i press the A key
	tap_key(KEY_A)
	
	# then action1 is triggered
	await assert_triggered(_action1)
	
	# when i add the second context
	GUIDE.enable_mapping_context(_context2)
	
	# i should be able to press both keys now and they should trigger their actions
	tap_key(KEY_A)
	await assert_triggered(_action1)
	tap_key(KEY_B)
	await assert_triggered(_action2)


## When layering contexts, disabling one context should not affect the other.
func test_disable_one_context() -> void:
	# enable both contexts
	GUIDE.enable_mapping_context(_context1)
	GUIDE.enable_mapping_context(_context2)
	
	# verify both inputs work
	tap_key(KEY_A)
	await assert_triggered(_action1)
	tap_key(KEY_B)
	await assert_triggered(_action2)
	
	# disable the second context
	GUIDE.disable_mapping_context(_context2)
	
	# the first context should still work
	tap_key(KEY_A)
	await assert_triggered(_action1)
	
	# but the second context should not
	tap_key(KEY_B)
	await assert_not_triggered(_action2)
	
