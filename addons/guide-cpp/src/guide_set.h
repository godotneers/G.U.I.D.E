#ifndef GUIDE_SET_H
#define GUIDE_SET_H

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/variant/callable.hpp>
#include <godot_cpp/classes/ref_counted.hpp>

using namespace godot;

class GUIDESet : public RefCounted {
    GDCLASS(GUIDESet, RefCounted)

public:
    GUIDESet();
    virtual ~GUIDESet();

    void add(const Variant &value);
    void add_all(const Array &values);
    void remove(const Variant &value);
    void clear();
    bool is_empty() const;
    Ref<GUIDESet> filter(const Callable &predicate) const;
    Variant pull();
    bool has(const Variant &value) const;
    Variant first_match(const Callable &matcher) const;
    void assign_to(Array values) const;
    Array values() const;
    int size() const;

protected:
    static void _bind_methods();

private:
    Dictionary _values;
};

#endif // GUIDE_SET_H