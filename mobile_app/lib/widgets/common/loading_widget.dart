import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget reutilizable para mostrar estado de carga con esqueleto shimmer
class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool showShimmer;
  final int itemCount;

  const LoadingWidget({
    super.key,
    this.message,
    this.showShimmer = true,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (showShimmer) {
      return ListView.builder(
        itemCount: itemCount,
        itemBuilder: (context, index) => _buildShimmerSkeleton(context),
      );
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _buildShimmerSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 16,
                  color: Colors.grey[300],
                  width: double.infinity,
                ),
                const SizedBox(height: 12),
                Container(height: 14, color: Colors.grey[300], width: 250),
                const SizedBox(height: 12),
                Container(height: 14, color: Colors.grey[300], width: 200),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget para carga circular simple
class SimpleLoadingWidget extends StatelessWidget {
  final String? message;

  const SimpleLoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
