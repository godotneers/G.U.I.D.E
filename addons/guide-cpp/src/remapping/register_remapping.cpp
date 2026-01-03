
#include "remapping/register_remapping.h"

void RegisterRemapping::register_types() {
    GDREGISTER_CLASS(GUIDERemapper);
    GDREGISTER_CLASS(GUIDERemapperConfigItem);
    GDREGISTER_CLASS(GUIDERemappingConfig);
    GDREGISTER_CLASS(GUIDEInputDetector);
}