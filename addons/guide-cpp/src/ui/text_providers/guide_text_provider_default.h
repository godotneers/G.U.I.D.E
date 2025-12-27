#ifndef GUIDE_TEXT_PROVIDER_DEFAULT_H
#define GUIDE_TEXT_PROVIDER_DEFAULT_H

#include "guide_formatting_base.h"

using namespace godot;

class GUIDETextProviderDefault : public GUIDETextProvider {
    GDCLASS(GUIDETextProviderDefault, GUIDETextProvider)

public:
    GUIDETextProviderDefault();
    virtual ~GUIDETextProviderDefault();

    virtual bool supports(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) const override;
    virtual String v_get_text(const Ref<GUIDEInput> &input, const Ref<GUIDEInputFormattingOptions> &options) const;

protected:
    static void _bind_methods();

private:
    bool _is_on_desktop = false;
    String _format(const String &input) const;
};

#endif // GUIDE_TEXT_PROVIDER_DEFAULT_H