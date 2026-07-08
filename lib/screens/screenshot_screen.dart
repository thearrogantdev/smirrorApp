import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_wire/generated/frame_frame_data_generated.dart' as frame_data;

@RoutePage()
class FrameScreen extends StatefulWidget {
  const FrameScreen({super.key});

  @override
  State<FrameScreen> createState() => _FrameScreenState();
}

class _FrameScreenState extends State<FrameScreen> {

  ui.Image? _image;
  bool _loading = true;
  String? _errorMessage;
  frame_data.MetaT? _cameraMeta;

  @override
  void initState() {
    super.initState();
    _requestScreenshot();
  }

  void _requestScreenshot() {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    context.read<BackAppWebSocketBloc>().sendGetScreenshot();
  }

  void _requestCameraMeta() {
    context.read<BackAppWebSocketBloc>().sendGetCameraMeta();
  }

  Future<void> _processFrame(frame_data.FrameT frame) async {
    final data = frame.data;
    if (data == null || data.isEmpty) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = "Received empty frame data";
        });
      }
      return;
    }

    final width = frame.width;
    final height = frame.height;
    final format = frame.format;

    if (format != frame_data.PixelFormat.GRAY8) {
      if (mounted) {
        setState(() {
          _loading = false;
          _errorMessage = "Unsupported pixel format: ${format.name}. Only GRAY8 is currently supported.";
        });
      }
      return;
    }

    // Gray8 to RGBA expanded
    final rgbaData = Uint8List(width * height * 4);
    for (var i = 0; i < width * height; i++) {
        final gray = data[i];
        rgbaData[i * 4] = gray;
        rgbaData[i * 4 + 1] = gray;
        rgbaData[i * 4 + 2] = gray;
        rgbaData[i * 4 + 3] = 255;
    }

    ui.decodeImageFromPixels(
      rgbaData,
      width,
      height,
      ui.PixelFormat.rgba8888,
      (ui.Image image) {
        if (mounted) {
          setState(() {
            _image = image;
            _loading = false;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BackAppWebSocketBloc, BackAppWebSocketState>(
      listener: (context, state) {
        if (state is BackAppWebSocketGotFrame) {
          _processFrame(state.frame);
        } else if (state is BackAppWebSocketGotCameraMeta) {
          setState(() {
            _cameraMeta = state.meta;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Device Screenshot'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _requestScreenshot,
              tooltip: 'Refresh Screenshot',
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: Colors.black, // Background for the screenshot area
                child: Center(
                  child: _loading
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Requesting screenshot...',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                            ),
                          ],
                        )
                      : _errorMessage != null
                          ? Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton.icon(
                                    onPressed: _requestScreenshot,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Retry'),
                                  ),
                                ],
                              ),
                            )
                          : _image == null
                              ? const Text('Screenshot ready to be captured', style: TextStyle(color: Colors.white70))
                              : InteractiveViewer(
                                  boundaryMargin: const EdgeInsets.all(20.0),
                                  minScale: 0.1,
                                  maxScale: 5.0,
                                  child: RawImage(
                                    image: _image,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.wb_sunny_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Camera Luminance',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _cameraMeta != null
                                      ? '${_cameraMeta!.lumen.toStringAsFixed(2)} lm'
                                      : 'No metadata fetched',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _requestCameraMeta,
                            icon: const Icon(Icons.analytics_outlined),
                            label: const Text('Get Camera Meta'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton.filledTonal(
                          onPressed: _requestScreenshot,
                          icon: const Icon(Icons.refresh),
                          tooltip: 'Refresh Screenshot',
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

