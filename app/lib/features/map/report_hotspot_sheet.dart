import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../app/theme.dart';
import '../../core/models/hotspot.dart';
import '../../l10n/generated/app_localizations.dart';
import 'hotspot_style.dart';

typedef ReportHotspotResult = ({
  HotspotCategory category,
  String? description,
  LatLng location,
  String? photoPath,
});

/// Bottom sheet for FR-HS: category (required), location (pinned map point
/// or live GPS), optional description, and an optional photo — all other
/// fields collapse to sensible defaults, but the sheet always hands back
/// exactly where the report should land, since that's no longer assumed to
/// be wherever the map happened to be tapped.
Future<ReportHotspotResult?> showReportHotspotSheet(
  BuildContext context, {
  required LatLng tappedLocation,
  required LatLng currentLocation,
}) {
  return showModalBottomSheet<ReportHotspotResult>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _ReportHotspotSheet(
      tappedLocation: tappedLocation,
      currentLocation: currentLocation,
    ),
  );
}

class _ReportHotspotSheet extends StatefulWidget {
  final LatLng tappedLocation;
  final LatLng currentLocation;

  const _ReportHotspotSheet({required this.tappedLocation, required this.currentLocation});

  @override
  State<_ReportHotspotSheet> createState() => _ReportHotspotSheetState();
}

class _ReportHotspotSheetState extends State<_ReportHotspotSheet> {
  HotspotCategory _selectedCategory = HotspotCategory.noLighting;
  final _descriptionController = TextEditingController();
  late bool _useCurrentLocation;
  XFile? _photo;
  bool _pickingPhoto = false;

  bool get _sameLocation =>
      const Distance().as(LengthUnit.Meter, widget.tappedLocation, widget.currentLocation) < 5;

  @override
  void initState() {
    super.initState();
    // If the tap effectively *is* the live position already (e.g. reporting
    // right where you're standing), default to "my location" so there's
    // nothing redundant to choose between.
    _useCurrentLocation = _sameLocation;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  LatLng get _resolvedLocation =>
      _useCurrentLocation ? widget.currentLocation : widget.tappedLocation;

  Future<void> _pickPhoto(ImageSource source) async {
    setState(() => _pickingPhoto = true);
    try {
      final picked = await ImagePicker().pickImage(source: source, maxWidth: 1600, imageQuality: 85);
      if (picked != null) setState(() => _photo = picked);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).cameraUnavailable)),
        );
      }
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.add_location_alt, color: SafeHerColors.magenta),
                const SizedBox(width: 8),
                Text(t.reportHotspotTitle, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              t.reportHotspotDisclaimer,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Text(t.locationLabel, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            _LocationChoice(
              tappedLocation: widget.tappedLocation,
              currentLocation: widget.currentLocation,
              hideTappedOption: _sameLocation,
              useCurrentLocation: _useCurrentLocation,
              onChanged: (value) => setState(() => _useCurrentLocation = value),
            ),
            const SizedBox(height: 20),
            Text(t.categoryLabel, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HotspotCategory.values.map((category) {
                final isSelected = category == _selectedCategory;
                return ChoiceChip(
                  label: Text(labelForCategory(context, category)),
                  avatar: Icon(iconForCategory(category),
                      size: 18, color: isSelected ? Colors.white : SafeHerColors.violet),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedCategory = category),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: t.descriptionLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(t.photoLabel, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _PhotoPicker(
                key: ValueKey(_photo?.path ?? (_pickingPhoto ? 'busy' : 'empty')),
                photo: _photo,
                busy: _pickingPhoto,
                onTakePhoto: () => _pickPhoto(ImageSource.camera),
                onChooseFromGallery: () => _pickPhoto(ImageSource.gallery),
                onRemove: () => setState(() => _photo = null),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => Navigator.of(context).pop((
                  category: _selectedCategory,
                  description: _descriptionController.text.trim().isEmpty
                      ? null
                      : _descriptionController.text.trim(),
                  location: _resolvedLocation,
                  photoPath: _photo?.path,
                )),
                label: Text(t.publishToMap),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationChoice extends StatelessWidget {
  final LatLng tappedLocation;
  final LatLng currentLocation;
  final bool hideTappedOption;
  final bool useCurrentLocation;
  final ValueChanged<bool> onChanged;

  const _LocationChoice({
    required this.tappedLocation,
    required this.currentLocation,
    required this.hideTappedOption,
    required this.useCurrentLocation,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    if (hideTappedOption) {
      return _LocationCard(
        icon: Icons.my_location,
        title: t.locationMyLocation,
        coordinates: currentLocation,
        selected: true,
        onTap: null,
      );
    }

    return Row(
      children: [
        Expanded(
          child: _LocationCard(
            icon: Icons.push_pin_outlined,
            title: t.locationPinnedSpot,
            coordinates: tappedLocation,
            selected: !useCurrentLocation,
            onTap: () => onChanged(false),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _LocationCard(
            icon: Icons.my_location,
            title: t.locationMyLocation,
            coordinates: currentLocation,
            selected: useCurrentLocation,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final LatLng coordinates;
  final bool selected;
  final VoidCallback? onTap;

  const _LocationCard({
    required this.icon,
    required this.title,
    required this.coordinates,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? SafeHerColors.violet : SafeHerColors.surfaceTint,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? SafeHerColors.violet : SafeHerColors.violet.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: selected ? Colors.white : SafeHerColors.violet),
                const SizedBox(width: 6),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: selected ? Colors.white : SafeHerColors.violet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '${coordinates.latitude.toStringAsFixed(4)}, ${coordinates.longitude.toStringAsFixed(4)}',
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white.withValues(alpha: 0.85) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final XFile? photo;
  final bool busy;
  final VoidCallback onTakePhoto;
  final VoidCallback onChooseFromGallery;
  final VoidCallback onRemove;

  const _PhotoPicker({
    super.key,
    required this.photo,
    required this.busy,
    required this.onTakePhoto,
    required this.onChooseFromGallery,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (photo != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              File(photo!.path),
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: _RemovePhotoButton(onPressed: onRemove),
          ),
        ],
      );
    }

    if (busy) {
      return Container(
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: SafeHerColors.surfaceTint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const CircularProgressIndicator(),
      );
    }

    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(t.takePhoto),
            onPressed: onTakePhoto,
          ),
        ),
        const SizedBox(width: 8),
        IconButton.outlined(
          icon: const Icon(Icons.photo_library_outlined),
          tooltip: t.chooseFromGallery,
          onPressed: onChooseFromGallery,
        ),
      ],
    );
  }
}

class _RemovePhotoButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _RemovePhotoButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: const Padding(
          padding: EdgeInsets.all(6),
          child: Icon(Icons.close, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
