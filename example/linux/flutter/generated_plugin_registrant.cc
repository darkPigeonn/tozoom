//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <tozoom/tozoom_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) tozoom_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "TozoomPlugin");
  tozoom_plugin_register_with_registrar(tozoom_registrar);
}
