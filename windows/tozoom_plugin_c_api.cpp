#include "include/tozoom/tozoom_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "tozoom_plugin.h"

void TozoomPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  tozoom::TozoomPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
