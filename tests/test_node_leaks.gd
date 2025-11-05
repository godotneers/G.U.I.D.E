extends GUIDETestBase

# Test for https://github.com/godotneers/G.U.I.D.E/issues/13
func test_node_leak() -> void:
	var context := mapping_context()
	@warning_ignore("shadowed_variable")
	var action := action_bool()
	var input := input_key(KEY_Q)
	
	map(context, action, input)
	
	GUIDE.enable_mapping_context(context)

	# test formatting something	
	var formatter := GUIDEInputFormatter.for_active_contexts()
	var text := await formatter.action_as_richtext_async(action)
	assert_str(text).contains("[img")
	
	# WHEN: i run the cdleanup
	var orphans_before := Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	
	GUIDEInputFormatter.cleanup()
	# give the thing one frame to let the cleanup kick in
	await get_tree().process_frame
	
	# THEN: the cleanup works
	var orphans := Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	assert_float(orphans).is_less(orphans_before)
