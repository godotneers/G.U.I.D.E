## Helper class for modelling sets

const GUIDESet = preload("guide_set.gd")

var _values: Dictionary = {}


## Adds the given value to the set.
## If the value is already in the set, it will not be added again.
func add(value: Variant) -> void:
	_values[value] = value


## Adds all values in the given array to the set.
## If a value is already in the set, it will not be added again.
func add_all(values: Array) -> void:
	for value in values:
		_values[value] = value


## Removes the given value from the set.
func remove(value: Variant) -> void:
	_values.erase(value)


## Removes all values from the set.
func clear() -> void:
	_values.clear()


## Returns true if the set is empty, false otherwise.
func is_empty() -> bool:
	return _values.is_empty()
	

## Returns a new set containing only the values for which the given predicate returns true.
## The predicate should take a single argument and return a boolean.
func filter(predicate:Callable) -> GUIDESet:
	var result = GUIDESet.new()
	for key in _values.keys():
		if predicate.call(key):
			result.add(key)
	return result

## Returns the first item in the set and removes it from the set.
## If the set is empty, returns null.
func pull() -> Variant:
	if is_empty():
		return null
	
	var key = _values.keys()[0]
	remove(key)
	return key


## Checks whether the set contains the given value.
func has(value: Variant) -> bool:
	return _values.has(value)


## Returns the first item for which the given matcher function returns
## a true value.
func first_match(matcher: Callable) -> Variant:
	for key in _values.keys():
		if matcher.call(key):
			return key
	return null


## Assigns all values in the set to the given array.
func assign_to(values: Array) -> void:
	values.assign(_values.keys())


## Returns an array of all values in the set.
func values() -> Array:
	return _values.keys()

	
## Returns the number of items in the set.
func size() -> int:
	return _values.size()
