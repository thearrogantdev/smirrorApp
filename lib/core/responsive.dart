import 'package:flutter/material.dart';

const double kMobileBreakpoint = 800;
const double kTabletBreakpoint = 1200;

bool isMobile(BuildContext context) =>
    MediaQuery.of(context).size.width < kMobileBreakpoint;

bool isTablet(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  return width >= kMobileBreakpoint && width < kTabletBreakpoint;
}

bool isDesktop(BuildContext context) =>
    MediaQuery.of(context).size.width >= kTabletBreakpoint;
