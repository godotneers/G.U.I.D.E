using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

namespace Guide;

public partial class GUIDESet : RefCounted {
	private Dictionary<Variant, Variant> _values = new();

	public void Add(Variant value) {
		_values[value] = value;
	}

	public void AddAll(IEnumerable<Variant> values) {
		foreach (var value in values) {
			_values[value] = value;
		}
	}

	public void Remove(Variant value) {
		_values.Remove(value);
	}

	public void Clear() {
		_values.Clear();
	}

	public bool IsEmpty() {
		return _values.Count == 0;
	}

	public GUIDESet Filter(Func<Variant, bool> predicate) {
		var result = new GUIDESet();
		foreach (var key in _values.Keys) {
			if (predicate(key)) {
				result.Add(key);
			}
		}
		return result;
	}

	public Variant Pull() {
		if (IsEmpty()) {
			return default;
		}

		var key = _values.Keys.First();
		Remove(key);
		return key;
	}

	public bool Has(Variant value) {
		return _values.ContainsKey(value);
	}

	public Variant FirstMatch(Func<Variant, bool> matcher) {
		foreach (var key in _values.Keys) {
			if (matcher(key)) {
				return key;
			}
		}
		return default;
	}

	public void AssignTo(IList<Variant> values) {
		values.Clear();
		foreach (var key in _values.Keys) {
			values.Add(key);
		}
	}

	public Variant[] Values() {
		return _values.Keys.ToArray();
	}

	public int Size() {
		return _values.Count;
	}
}
