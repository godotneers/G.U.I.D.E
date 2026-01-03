#include "guide_set.h"

using namespace godot;

void GUIDESet::_bind_methods() {
    ClassDB::bind_method(D_METHOD("add", "value"), &GUIDESet::add);
    ClassDB::bind_method(D_METHOD("add_all", "values"), &GUIDESet::add_all);
    ClassDB::bind_method(D_METHOD("remove", "value"), &GUIDESet::remove);
    ClassDB::bind_method(D_METHOD("clear"), &GUIDESet::clear);
    ClassDB::bind_method(D_METHOD("is_empty"), &GUIDESet::is_empty);
    ClassDB::bind_method(D_METHOD("filter", "predicate"), &GUIDESet::filter);
    ClassDB::bind_method(D_METHOD("pull"), &GUIDESet::pull);
    ClassDB::bind_method(D_METHOD("has", "value"), &GUIDESet::has);
    ClassDB::bind_method(D_METHOD("first_match", "matcher"), &GUIDESet::first_match);
    ClassDB::bind_method(D_METHOD("assign_to", "values"), &GUIDESet::assign_to);
    ClassDB::bind_method(D_METHOD("values"), &GUIDESet::values);
    ClassDB::bind_method(D_METHOD("size"), &GUIDESet::size);
}

GUIDESet::GUIDESet() {}
GUIDESet::~GUIDESet() {}

void GUIDESet::add(const Variant &value) {
    _values[value] = value;
}

void GUIDESet::add_all(const Array &values) {
    for (int i = 0; i < values.size(); i++) {
        _values[values[i]] = values[i];
    }
}

void GUIDESet::remove(const Variant &value) {
    _values.erase(value);
}

void GUIDESet::clear() {
    _values.clear();
}

bool GUIDESet::is_empty() const {
    return _values.is_empty();
}

Ref<GUIDESet> GUIDESet::filter(const Callable &predicate) const {
    Ref<GUIDESet> result;
    result.instantiate();
    Array keys = _values.keys();
    for (int i = 0; i < keys.size(); i++) {
        if (predicate.call(keys[i])) {
            result->add(keys[i]);
        }
    }
    return result;
}

Variant GUIDESet::pull() {
    if (is_empty()) return Variant();
    Array keys = _values.keys();
    Variant key = keys[0];
    _values.erase(key);
    return key;
}

bool GUIDESet::has(const Variant &value) const {
    return _values.has(value);
}

Variant GUIDESet::first_match(const Callable &matcher) const {
    Array keys = _values.keys();
    for (int i = 0; i < keys.size(); i++) {
        if (matcher.call(keys[i])) {
            return keys[i];
        }
    }
    return Variant();
}

void GUIDESet::assign_to(Array values) const {
    values.assign(_values.keys());
}

Array GUIDESet::values() const {
    return _values.keys();
}

int GUIDESet::size() const {
    return _values.size();
}
