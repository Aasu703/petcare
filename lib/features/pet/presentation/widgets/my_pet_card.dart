import 'package:flutter/material.dart';
import 'package:petcare/app/theme/app_colors.dart';
import 'package:petcare/app/theme/theme_extensions.dart';
import 'package:petcare/core/api/api_endpoints.dart';
import 'package:petcare/features/pet/domain/entities/pet_entity.dart';

class MyPetCard extends StatefulWidget {
  final PetEntity pet;
  final VoidCallback onTap;
  final VoidCallback onCare;
  final VoidCallback onAssignVet;
  final VoidCallback onDelete;

  const MyPetCard({
    super.key,
    required this.pet,
    required this.onTap,
    required this.onCare,
    required this.onAssignVet,
    required this.onDelete,
  });

  @override
  State<MyPetCard> createState() => _MyPetCardState();
}

class _MyPetCardState extends State<MyPetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _getSpeciesIcon(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.catching_pokemon;
      case 'bird':
        return Icons.flutter_dash;
      case 'rabbit':
        return Icons.pets;
      case 'hamster':
        return Icons.pets;
      default:
        return Icons.pets;
    }
  }

  Color _getSpeciesColor(String species) {
    switch (species.toLowerCase()) {
      case 'dog':
        return const Color(0xFF8B4513);
      case 'cat':
        return const Color(0xFF4A4A4A);
      case 'bird':
        return const Color(0xFFFFD700);
      case 'rabbit':
        return const Color(0xFFFFC0CB);
      case 'hamster':
        return const Color(0xFFFFA500);
      default:
        return AppColors.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.pet.imageUrl;
    final speciesColor = _getSpeciesColor(widget.pet.species);

    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onExit: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isHovered
                      ? context.primaryColor.withValues(alpha: 0.5)
                      : context.borderColor,
                  width: _isHovered ? 2 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.08),
                    blurRadius: _isHovered ? 16 : 12,
                    offset: Offset(0, _isHovered ? 6 : 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Pet Image Section
                    Hero(
                      tag: 'pet_image_${widget.pet.petId}',
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              speciesColor.withValues(alpha: 0.15),
                              speciesColor.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: speciesColor.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: (imageUrl != null && imageUrl.isNotEmpty)
                              ? Image.network(
                                  ApiEndpoints.resolveMediaUrl(imageUrl),
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) =>
                                          loadingProgress == null
                                          ? child
                                          : Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.primaryColor,
                                              ),
                                            ),
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              speciesColor.withValues(
                                                alpha: 0.15,
                                              ),
                                              speciesColor.withValues(
                                                alpha: 0.05,
                                              ),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                        ),
                                        child: Icon(
                                          _getSpeciesIcon(widget.pet.species),
                                          size: 40,
                                          color: speciesColor,
                                        ),
                                      ),
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        speciesColor.withValues(alpha: 0.15),
                                        speciesColor.withValues(alpha: 0.05),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Icon(
                                    _getSpeciesIcon(widget.pet.species),
                                    size: 40,
                                    color: speciesColor,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Pet Info Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pet Name and Species Badge
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.pet.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: context.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: speciesColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: speciesColor.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  widget.pet.species.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: speciesColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.medical_services_outlined,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.pet.assignedVetName ??
                                      'No vet assigned',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: widget.pet.assignedVetName != null
                                        ? AppColors.successColor
                                        : context.textSecondary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: widget.onAssignVet,
                                child: Text(
                                  widget.pet.assignedVetName == null
                                      ? 'Assign vet'
                                      : 'Change',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Breed
                          if (widget.pet.breed != null &&
                              widget.pet.breed!.isNotEmpty) ...[
                            Text(
                              widget.pet.breed!,
                              style: TextStyle(
                                fontSize: 14,
                                color: context.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                          ],
                          // Age and Weight Info
                          Row(
                            children: [
                              if (widget.pet.age != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.cake_outlined,
                                        size: 13,
                                        color: AppColors.primaryColor,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${widget.pet.age}y',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (widget.pet.weight != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentColor.withValues(
                                      alpha: 0.08,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.monitor_weight_outlined,
                                        size: 13,
                                        color: AppColors.accentColor,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${widget.pet.weight}kg',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.accentColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Action Buttons Section
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withValues(
                              alpha: _isHovered ? 0.15 : 0.08,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.favorite_outline,
                              color: AppColors.primaryColor,
                              size: 20,
                            ),
                            onPressed: widget.onCare,
                            tooltip: 'Pet care plan',
                            constraints: const BoxConstraints.tightFor(
                              width: 36,
                              height: 36,
                            ),
                            padding: EdgeInsets.zero,
                            splashRadius: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: AppColors.errorColor.withValues(
                              alpha: _isHovered ? 0.15 : 0.08,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: AppColors.errorColor,
                              size: 20,
                            ),
                            onPressed: widget.onDelete,
                            tooltip: 'Delete pet',
                            constraints: const BoxConstraints.tightFor(
                              width: 36,
                              height: 36,
                            ),
                            padding: EdgeInsets.zero,
                            splashRadius: 18,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
