import '/flutter_flow/flutter_flow_util.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'shimmer_banner_widget.dart' show ShimmerBannerWidget;
import 'package:flutter/material.dart';

class ShimmerBannerModel extends FlutterFlowModel<ShimmerBannerWidget> {
  ///  State fields for stateful widgets in this component.

  // State field(s) for Carousel widget.
  CarouselSliderController? carouselController;
  int carouselCurrentIndex = 0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
