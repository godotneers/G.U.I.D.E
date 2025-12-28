#ifndef GUIDE_INPUT_DETECTOR_H
#define GUIDE_INPUT_DETECTOR_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/timer.hpp>
#include <godot_cpp/classes/input_event.hpp>
#include "inputs/guide_input.h"
#include "guide_mapping_context.h"
#include "guide_action.h"

using namespace godot;

class GUIDEInputDetector : public Node {
    GDCLASS(GUIDEInputDetector, Node)

public:
    enum JoyIndex {
        ANY = 0,
        DETECTED = 1
    };

    enum DetectionState {
        IDLE = 0,
        COUNTDOWN = 3,
        INPUT_PRE_CLEAR = 4,
        DETECTING = 1,
        INPUT_POST_CLEAR = 2
    };

    GUIDEInputDetector();
    virtual ~GUIDEInputDetector();

    void _ready() override;
    void _process(double delta) override;
    void _input(const Ref<InputEvent> &event) override;

    void detect_bool(const TypedArray<int> &device_types = TypedArray<int>());
    void detect_axis_1d(const TypedArray<int> &device_types = TypedArray<int>());
    void detect_axis_2d(const TypedArray<int> &device_types = TypedArray<int>());
    void detect_axis_3d(const TypedArray<int> &device_types = TypedArray<int>());
    void detect(GUIDEAction::GUIDEActionValueType value_type, const TypedArray<int> &device_types = TypedArray<int>());
    void abort_detection();

    // Getters and Setters
    double get_detection_countdown_seconds() const { return detection_countdown_seconds; }
    void set_detection_countdown_seconds(double p_val) { detection_countdown_seconds = p_val; }

    double get_minimum_axis_amplitude() const { return minimum_axis_amplitude; }
    void set_minimum_axis_amplitude(double p_val) { minimum_axis_amplitude = p_val; }

    TypedArray<GUIDEInput> get_abort_detection_on() const { return abort_detection_on; }
    void set_abort_detection_on(const TypedArray<GUIDEInput> &p_val) { abort_detection_on = p_val; }

    int get_use_joy_index() const { return (int)use_joy_index; }
    void set_use_joy_index(int p_val) { use_joy_index = (JoyIndex)p_val; }

    bool get_allow_triggers_for_boolean_actions() const { return allow_triggers_for_boolean_actions; }
    void set_allow_triggers_for_boolean_actions(bool p_val) { allow_triggers_for_boolean_actions = p_val; }

    bool is_detecting() const { return _status != IDLE; }

protected:
    static void _bind_methods();

private:
    double detection_countdown_seconds = 0.5;
    double minimum_axis_amplitude = 0.2;
    TypedArray<GUIDEInput> abort_detection_on;
    JoyIndex use_joy_index = ANY;
    bool allow_triggers_for_boolean_actions = true;

    Timer *_timer = nullptr;
    DetectionState _status = IDLE;
    TypedArray<GUIDEMappingContext> _saved_mapping_contexts;
    Ref<GUIDEInput> _last_detected_input;

    int _value_type = 0;
    TypedArray<int> _device_types;

    void _begin_detection();
    void _deliver(const Ref<GUIDEInput> &input);
    bool _matches_device_types(const Ref<InputEvent> &event) const;
    int _find_joy_index(int device_id) const;

    void _try_detect_bool(const Ref<InputEvent> &event);
    void _try_detect_axis_1d(const Ref<InputEvent> &event);
    void _try_detect_axis_2d(const Ref<InputEvent> &event);
    void _try_detect_axis_3d(const Ref<InputEvent> &event);
};

VARIANT_ENUM_CAST(GUIDEInputDetector::JoyIndex);
VARIANT_ENUM_CAST(GUIDEInputDetector::DetectionState);

#endif // GUIDE_INPUT_DETECTOR_H
