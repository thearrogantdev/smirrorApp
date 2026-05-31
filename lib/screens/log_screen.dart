import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/app_websocket_event.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_bloc.dart';
import 'package:smirror_app/bloc/backendConnection/back_app_websocket_state.dart';
import 'package:smirror_app/bloc/setup_cubit.dart';
import 'package:smirror_app/l10n/app_localizations.dart';
import 'package:smirror_app/core/responsive.dart' as responsive;
import 'package:intl/intl.dart';

enum LogSortField { time, level }

@RoutePage()
class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  LogSortField _sortField = LogSortField.time;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    context.read<AppWebSocketBloc>().add(
      AppWebSocketRequestLogs(numOfMessages: 50),
    );
  }

  /// Level priority for sorting (lower = more severe).
  /// Matches quill::LogLevel enum order.
  static int _levelPriority(String level) {
    final upper = level.toUpperCase();
    if (upper.contains('CRITICAL')) return 0;
    if (upper.contains('ERROR')) return 1;
    if (upper.contains('WARNING') || upper.contains('WARN')) return 2;
    if (upper.contains('NOTICE')) return 3;
    if (upper.contains('INFO')) return 4;
    if (upper.contains('DEBUG')) return 5;
    if (upper.contains('TRACE_L1') || upper.contains('TRACEL1')) return 6;
    if (upper.contains('TRACE_L2') || upper.contains('TRACEL2')) return 7;
    if (upper.contains('TRACE_L3') || upper.contains('TRACEL3')) return 8;
    if (upper.contains('TRACE')) return 6; // generic trace fallback
    return 9;
  }

  List<ParsedLog> _sortLogs(List<ParsedLog> logs) {
    final sorted = List<ParsedLog>.from(logs);
    sorted.sort((a, b) {
      int cmp;
      if (_sortField == LogSortField.time) {
        cmp = a.time.compareTo(b.time);
      } else {
        cmp = _levelPriority(a.level).compareTo(_levelPriority(b.level));
      }
      return _sortAscending ? cmp : -cmp;
    });
    return sorted;
  }

  void _toggleSort(LogSortField field) {
    setState(() {
      if (_sortField == field) {
        _sortAscending = !_sortAscending;
      } else {
        _sortField = field;
        _sortAscending = (field == LogSortField.time) ? false : true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final setupState = context.watch<SetupCubit>().state;
    final isMobile = responsive.isMobile(context);

    return BlocBuilder<BackAppWebSocketBloc, BackAppWebSocketState>(
      buildWhen: (previous, current) => current is BackAppWebSocketGotLogs,
      builder: (context, state) {
        if (state is BackAppWebSocketGotLogs) {
          if (state.logs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(loc.logNoLogsAvailable),
                  const SizedBox(height: 16),
                  IconButton(
                    tooltip: loc.logRefresh,
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<AppWebSocketBloc>().add(
                        AppWebSocketRequestLogs(numOfMessages: 50),
                      );
                    },
                  ),
                ],
              ),
            );
          }

          final parsed = state.logs.map(_parseLogLine).toList();
          final sorted = _sortLogs(parsed);

          return Column(
            children: [
              // Header row with sortable columns
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _SortableHeader(
                      label: loc.logTime,
                      width: isMobile ? 50 : 180,
                      isActive: _sortField == LogSortField.time,
                      ascending: _sortAscending,
                      onTap: () => _toggleSort(LogSortField.time),
                    ),
                    if (setupState.developerLogs && !isMobile) ...[
                      SizedBox(
                        width: 70,
                        child: Text(
                          loc.logThreadId,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: 180,
                        child: Text(
                          loc.logSourceLocation,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    _SortableHeader(
                      label: loc.logLevel,
                      width: isMobile ? 50 : 90,
                      isActive: _sortField == LogSortField.level,
                      ascending: _sortAscending,
                      onTap: () => _toggleSort(LogSortField.level),
                    ),
                    Expanded(
                      child: Text(
                        loc.logMessage,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      tooltip: loc.logRefresh,
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        context.read<AppWebSocketBloc>().add(
                          AppWebSocketRequestLogs(numOfMessages: 50),
                        );
                      },
                    ),
                    if (setupState.developerMode)
                      IconButton(
                        tooltip: loc.developerLogs,
                        icon: Icon(
                          setupState.developerLogs
                              ? Icons.bug_report
                              : Icons.bug_report_outlined,
                          color: setupState.developerLogs
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                        onPressed: () =>
                            context.read<SetupCubit>().toggleDeveloperLogs(),
                      ),
                  ],
                ),
              ),
              // Log list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: sorted.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final logData = sorted[index];
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Log Details'),
                            content: SingleChildScrollView(
                              child: SelectableText(
                                logData.rawLine,
                                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: logData.rawLine));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Log copied to clipboard'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                child: const Text('Copy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                      onLongPress: () {
                        Clipboard.setData(ClipboardData(text: logData.rawLine));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Log copied to clipboard'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Time
                            SizedBox(
                              width: isMobile ? 50 : 180,
                              child: Text(
                                isMobile ? logData.shortTime : logData.time,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: isMobile ? 10 : 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Expert columns: thread ID + source location
                            if (setupState.developerLogs && !isMobile) ...[
                              SizedBox(
                                width: 70,
                                child: Text(
                                  logData.threadId ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 180,
                                child: Text(
                                  logData.sourceLocation ?? '',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            // Level
                            SizedBox(
                              width: isMobile ? 50 : 90,
                              child: Text(
                                isMobile ? logData.shortLevel : logData.level,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: isMobile ? 10 : 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getLevelColor(logData.level),
                                ),
                              ),
                            ),
                            // Message
                            Expanded(
                              child: Text(
                                logData.message,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  /// Parses a log line from quill in either format:
  ///  - Detailed: `<date> <time> [<threadId>] <sourceLocation> <level> <message>`
  ///  - Simple:   `<date> <time> <level> <message>`
  /// The timestamp is always two tokens: date + time (e.g. `2026-03-24 10:40:11.482`).
  static ParsedLog _parseLogLine(String rawLine) {
    // Try detailed format first:
    // date time [threadId] sourceLocation(padded) level message
    final detailedRegex = RegExp(
      r'^(\d{4}-\d{2}-\d{2}\s+\S+)\s+\[(\d+)\]\s+(\S+)\s+(\S+)\s+(.*)$',
    );
    final detailedMatch = detailedRegex.firstMatch(rawLine);
    if (detailedMatch != null) {
      return ParsedLog(
        rawLine: rawLine,
        time: _formatToLocal(detailedMatch.group(1) ?? ''),
        threadId: detailedMatch.group(2),
        sourceLocation: detailedMatch.group(3)?.trim(),
        level: detailedMatch.group(4) ?? '',
        message: detailedMatch.group(5) ?? '',
      );
    }

    // Simple format: date time level message
    final simpleRegex = RegExp(r'^(\d{4}-\d{2}-\d{2}\s+\S+)\s+(\S+)\s+(.*)$');
    final simpleMatch = simpleRegex.firstMatch(rawLine);
    if (simpleMatch != null) {
      return ParsedLog(
        rawLine: rawLine,
        time: _formatToLocal(simpleMatch.group(1) ?? ''),
        level: simpleMatch.group(2) ?? '',
        message: simpleMatch.group(3) ?? '',
      );
    }

    // Fallback
    return ParsedLog(
      rawLine: rawLine,
      time: '-',
      level: 'UNKNOWN',
      message: rawLine,
    );
  }

  static String _formatToLocal(String gmtTimeStr) {
    if (gmtTimeStr.isEmpty || gmtTimeStr == '-') return gmtTimeStr;
    try {
      // Append 'Z' to treat the string as UTC/GMT
      final utc = DateTime.parse('${gmtTimeStr}Z');
      return DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(utc.toLocal());
    } catch (_) {
      return gmtTimeStr;
    }
  }

  static Color _getLevelColor(String level) {
    final upper = level.toUpperCase();
    if (upper.contains('CRITICAL')) return Colors.red.shade900;
    if (upper.contains('ERROR')) return Colors.red;
    if (upper.contains('WARNING') || upper.contains('WARN')) {
      return Colors.orange;
    }
    if (upper.contains('NOTICE')) return Colors.teal;
    if (upper.contains('INFO')) return Colors.yellow;
    if (upper.contains('DEBUG')) return Colors.blue;
    if (upper.contains('TRACE')) return Colors.grey;
    return Colors.grey;
  }
}

/// Sortable column header widget.
class _SortableHeader extends StatelessWidget {
  final String label;
  final double width;
  final bool isActive;
  final bool ascending;
  final VoidCallback onTap;

  const _SortableHeader({
    required this.label,
    required this.width,
    required this.isActive,
    required this.ascending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (isActive)
              Icon(
                ascending ? Icons.arrow_upward : Icons.arrow_downward,
                size: 14,
              ),
          ],
        ),
      ),
    );
  }
}

/// Data class for a parsed log line.
class ParsedLog {
  final String rawLine;
  final String time;
  final String? threadId;
  final String? sourceLocation;
  final String level;
  final String message;

  ParsedLog({
    required this.rawLine,
    required this.time,
    this.threadId,
    this.sourceLocation,
    required this.level,
    required this.message,
  });

  String get shortTime {
    final parts = time.split(' ');
    if (parts.length > 1) {
      final timePart = parts[1];
      if (timePart.length >= 5) {
        return timePart.substring(0, 5); // HH:MM
      }
      return timePart;
    }
    return time;
  }

  String get shortLevel {
    final upper = level.toUpperCase();
    if (upper.contains('CRITICAL')) return 'CRI';
    if (upper.contains('ERROR')) return 'ERR';
    if (upper.contains('WARNING') || upper.contains('WARN')) return 'WRN';
    if (upper.contains('NOTICE')) return 'NOT';
    if (upper.contains('INFO')) return 'INF';
    if (upper.contains('DEBUG')) return 'DBG';
    if (upper.contains('TRACE')) return 'TRC';
    return level.substring(0, level.length > 3 ? 3 : level.length);
  }
}
