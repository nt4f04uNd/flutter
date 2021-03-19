// Copyright 2014 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// @dart = 2.8

import 'package:meta/meta.dart';
import 'package:process/process.dart';

import '../base/file_system.dart';
import '../base/logger.dart';
import '../base/os.dart';
import '../base/platform.dart';
import '../build_info.dart';
import '../desktop_device.dart';
import '../device.dart';
import '../features.dart';
import '../project.dart';
import 'application_package.dart';
import 'build_linux.dart';
import 'linux_workflow.dart';

/// A device that represents a desktop Linux target.
class LinuxDevice extends DesktopDevice {
  LinuxDevice({
    @required ProcessManager processManager,
    @required Logger logger,
    @required FileSystem fileSystem,
    @required OperatingSystemUtils operatingSystemUtils,
  })  : _operatingSystemUtils = operatingSystemUtils,
        super(
          'linux',
          platformType: PlatformType.linux,
          ephemeral: false,
          logger: logger,
          processManager: processManager,
          fileSystem: fileSystem,
          operatingSystemUtils: operatingSystemUtils,
        );

  final OperatingSystemUtils _operatingSystemUtils;

  TargetPlatform _targetPlatform;

  @override
  bool isSupported() => true;

  @override
  String get name => 'Linux';

  @override
  Future<TargetPlatform> get targetPlatform async {
    if (_targetPlatform == null) {
      if (_operatingSystemUtils.hostPlatform == HostPlatform.linux_x64) {
        _targetPlatform = TargetPlatform.linux_x64;
      } else {
        _targetPlatform = TargetPlatform.linux_arm64;
      }
    }

    return _targetPlatform;
  }

  @override
  bool isSupportedForProject(FlutterProject flutterProject) {
    return flutterProject.linux.existsSync();
  }

  @override
  Future<void> buildForDevice(
    covariant LinuxApp package, {
    String mainPath,
    BuildInfo buildInfo,
  }) async {
    await buildLinux(
      FlutterProject.current().linux,
      buildInfo,
      target: mainPath,
      targetPlatform: _targetPlatform,
    );
  }

  @override
  String executablePathForDevice(covariant LinuxApp package, BuildMode buildMode) {
    return package.executable(buildMode);
  }
}

class LinuxDevices extends PollingDeviceDiscovery {
  LinuxDevices({
    @required Platform platform,
    @required FeatureFlags featureFlags,
    @required OperatingSystemUtils operatingSystemUtils,
    @required FileSystem fileSystem,
    @required ProcessManager processManager,
    @required Logger logger,
  }) : _platform = platform,
       _linuxWorkflow = LinuxWorkflow(
          platform: platform,
          featureFlags: featureFlags,
       ),
       _fileSystem = fileSystem,
       _logger = logger,
       _processManager = processManager,
       _operatingSystemUtils = operatingSystemUtils,
       super('linux devices');

  final Platform _platform;
  final LinuxWorkflow _linuxWorkflow;
  final ProcessManager _processManager;
  final Logger _logger;
  final FileSystem _fileSystem;
  final OperatingSystemUtils _operatingSystemUtils;

  @override
  bool get supportsPlatform => _platform.isLinux;

  @override
  bool get canListAnything => _linuxWorkflow.canListDevices;

  @override
  Future<List<Device>> pollingGetDevices({ Duration timeout }) async {
    if (!canListAnything) {
      return const <Device>[];
    }
    return <Device>[
      LinuxDevice(
        logger: _logger,
        processManager: _processManager,
        fileSystem: _fileSystem,
        operatingSystemUtils: _operatingSystemUtils,
      ),
    ];
  }

  @override
  Future<List<String>> getDiagnostics() async => const <String>[];
}
