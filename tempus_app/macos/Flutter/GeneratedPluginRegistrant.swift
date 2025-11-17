//
//  Generated file. Do not edit.
//

import FlutterMacOS
import Foundation

import auth0_flutter
import device_info_plus
import package_info_plus
import path_provider_foundation
import screen_brightness_macos
import shared_preferences_foundation
import wakelock_plus

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  Auth0FlutterPlugin.register(with: registry.registrar(forPlugin: "Auth0FlutterPlugin"))
  DeviceInfoPlusMacosPlugin.register(with: registry.registrar(forPlugin: "DeviceInfoPlusMacosPlugin"))
  FPPPackageInfoPlusPlugin.register(with: registry.registrar(forPlugin: "FPPPackageInfoPlusPlugin"))
  PathProviderPlugin.register(with: registry.registrar(forPlugin: "PathProviderPlugin"))
  ScreenBrightnessMacosPlugin.register(with: registry.registrar(forPlugin: "ScreenBrightnessMacosPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  WakelockPlusMacosPlugin.register(with: registry.registrar(forPlugin: "WakelockPlusMacosPlugin"))
}
