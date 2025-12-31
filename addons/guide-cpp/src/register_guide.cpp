
#include "register_guide.h"

void RegisterGuide::register_types() {
    GDREGISTER_CLASS(GUIDE);
    GDREGISTER_CLASS(GUIDEAction);
    GDREGISTER_CLASS(GUIDEActionMapping);
    GDREGISTER_CLASS(GUIDEInputMapping);
    GDREGISTER_CLASS(GUIDEMappingContext);
    GDREGISTER_CLASS(GUIDEReset);
    GDREGISTER_CLASS(GUIDESet);
    GDREGISTER_CLASS(GUIDEInputTracker);
}